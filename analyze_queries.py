#!/usr/bin/env python3
"""
Analyze JOB benchmark queries for:
1. Number of tables per query
2. Number of FK-PK joins per query
3. Number of FK-FK joins per query
4. Range of table row counts (min-max) per query
5. Number of filters (non-join predicates) per query
"""

import re
import json
from pathlib import Path

# Base directory
BASE_DIR = Path(__file__).parent
QUERIES_DIR = BASE_DIR / "queries"
CSV_DIR = BASE_DIR / "csv"
FKEYS_FILE = BASE_DIR / "fkeys.sql"


def parse_foreign_keys(fkeys_file):
    """
    Parse fkeys.sql to extract foreign key relationships.
    Returns two dictionaries:
    - fk_to_pk: {(table, fk_column): (ref_table, ref_column)}
    - pk_tables: set of tables that have primary keys referenced
    """
    fk_to_pk = {}

    with open(fkeys_file, 'r') as f:
        content = f.read()

    # Pattern to match: ALTER TABLE <table> ADD FOREIGN KEY (<column>) REFERENCES <ref_table>(<ref_column>)
    # Handle multi-line statements
    content = re.sub(r'--.*$', '', content, flags=re.MULTILINE)  # Remove comments

    # Split by ALTER TABLE statements
    alter_pattern = r'ALTER\s+TABLE\s+(\w+)\s+(.*?);'
    for match in re.finditer(alter_pattern, content, re.IGNORECASE | re.DOTALL):
        table = match.group(1).lower()
        body = match.group(2)

        # Find all FK definitions in this ALTER statement
        fk_pattern = r'ADD\s+FOREIGN\s+KEY\s*\((\w+)\)\s+REFERENCES\s+(\w+)\s*\((\w+)\)'
        for fk_match in re.finditer(fk_pattern, body, re.IGNORECASE):
            fk_column = fk_match.group(1).lower()
            ref_table = fk_match.group(2).lower()
            ref_column = fk_match.group(3).lower()
            fk_to_pk[(table, fk_column)] = (ref_table, ref_column)

    return fk_to_pk


def get_table_row_counts(csv_dir):
    """
    Get row counts for each table from CSV files.
    Row count = number of lines in the CSV file (data rows, no header in these files).
    """
    row_counts = {}

    for csv_file in csv_dir.glob("*.csv"):
        table_name = csv_file.stem.lower()
        # Count lines in the file
        with open(csv_file, 'r') as f:
            count = sum(1 for _ in f)
        row_counts[table_name] = count

    return row_counts


def parse_query(query_file):
    """
    Parse a SQL query to extract tables, joins, and filters.
    Returns:
    - tables: dict of {alias: table_name}
    - joins: list of join predicates [(alias1, col1, alias2, col2)]
    - filters: list of filter predicates (single-table conditions)
    """
    with open(query_file, 'r') as f:
        content = f.read()

    # Normalize whitespace
    content = ' '.join(content.split())

    # Extract FROM clause
    from_match = re.search(r'\bFROM\s+(.*?)\s+WHERE\b', content, re.IGNORECASE)
    if not from_match:
        return {}, [], []

    from_clause = from_match.group(1)

    # Parse tables and aliases from FROM clause
    # Pattern: table_name AS alias or just table_name
    tables = {}
    # Split by comma, handling potential whitespace
    table_parts = re.split(r'\s*,\s*', from_clause)
    for part in table_parts:
        part = part.strip()
        # Match "table AS alias" or "table alias" or just "table"
        alias_match = re.match(r'(\w+)\s+(?:AS\s+)?(\w+)', part, re.IGNORECASE)
        if alias_match:
            table_name = alias_match.group(1).lower()
            alias = alias_match.group(2).lower()
            tables[alias] = table_name
        else:
            # No alias, use table name
            table_name = part.lower()
            tables[table_name] = table_name

    # Extract WHERE clause
    where_match = re.search(r'\bWHERE\s+(.*?)(?:GROUP\s+BY|ORDER\s+BY|LIMIT|;|$)', content, re.IGNORECASE)
    if not where_match:
        return tables, [], []

    where_clause = where_match.group(1)

    # Split WHERE clause into predicates
    # Need to handle AND, OR, and parentheses carefully
    # For simplicity, we'll use a regex-based approach to find join and filter predicates

    joins = []

    # Pattern for equality join: alias1.column1 = alias2.column2
    join_pattern = r'(\w+)\.(\w+)\s*=\s*(\w+)\.(\w+)'

    for match in re.finditer(join_pattern, where_clause):
        alias1 = match.group(1).lower()
        col1 = match.group(2).lower()
        alias2 = match.group(3).lower()
        col2 = match.group(4).lower()

        # This is a join if both aliases are different tables
        if alias1 != alias2 and alias1 in tables and alias2 in tables:
            joins.append((alias1, col1, alias2, col2))

    # Count filters: predicates that involve only one table
    # Pattern for single-table predicates: alias.column <op> value
    # We need to count predicates that are NOT joins

    # Find all predicates with alias.column patterns
    single_table_pattern = r'(\w+)\.(\w+)\s*(?:=|!=|<>|<|>|<=|>=|LIKE|NOT\s+LIKE|IN|NOT\s+IN|IS\s+NULL|IS\s+NOT\s+NULL|BETWEEN)'

    # Track positions of join predicates to avoid double counting
    join_positions = set()
    for match in re.finditer(join_pattern, where_clause):
        join_positions.add(match.start())

    filter_count = 0
    for match in re.finditer(single_table_pattern, where_clause, re.IGNORECASE):
        # Check if this is not part of a join predicate
        if match.start() not in join_positions:
            alias = match.group(1).lower()
            if alias in tables:
                filter_count += 1

    return tables, joins, filter_count


def classify_joins(joins, tables, fk_to_pk):
    """
    Classify joins as FK-PK or FK-FK.

    FK-PK: One side is a foreign key and the other is the primary key it references.
    FK-FK: Both sides are foreign keys.

    Returns:
    - fk_pk_count: number of FK-PK joins
    - fk_fk_count: number of FK-FK joins
    """
    fk_pk_count = 0
    fk_fk_count = 0

    for alias1, col1, alias2, col2 in joins:
        table1 = tables.get(alias1)
        table2 = tables.get(alias2)

        if not table1 or not table2:
            continue

        # Check if (table1, col1) is a FK pointing to (table2, col2)
        is_fk1_to_pk2 = (table1, col1) in fk_to_pk and fk_to_pk[(table1, col1)] == (table2, col2)
        # Check if (table2, col2) is a FK pointing to (table1, col1)
        is_fk2_to_pk1 = (table2, col2) in fk_to_pk and fk_to_pk[(table2, col2)] == (table1, col1)

        # Check if both are foreign keys
        is_fk1 = (table1, col1) in fk_to_pk
        is_fk2 = (table2, col2) in fk_to_pk

        if is_fk1_to_pk2 or is_fk2_to_pk1:
            # One is FK, other is PK (and FK references that PK)
            fk_pk_count += 1
        elif is_fk1 and is_fk2:
            # Both are foreign keys
            fk_fk_count += 1
        # else: neither is a FK relationship we know about (could be PK-PK or other)

    return fk_pk_count, fk_fk_count


def analyze_queries():
    """
    Analyze all queries in the queries directory.
    """
    # Parse foreign keys
    fk_to_pk = parse_foreign_keys(FKEYS_FILE)
    print(f"Loaded {len(fk_to_pk)} foreign key relationships")

    # Get table row counts
    row_counts = get_table_row_counts(CSV_DIR)
    print(f"Loaded row counts for {len(row_counts)} tables")

    # Analyze each query
    results = {}

    query_files = sorted(QUERIES_DIR.glob("*.sql"))

    for query_file in query_files:
        query_name = query_file.stem

        tables, joins, filter_count = parse_query(query_file)
        fk_pk_count, fk_fk_count = classify_joins(joins, tables, fk_to_pk)

        # Get row count range for tables in this query
        table_names = set(tables.values())
        table_rows = [row_counts.get(t, 0) for t in table_names if t in row_counts]

        if table_rows:
            min_rows = min(table_rows)
            max_rows = max(table_rows)
        else:
            min_rows = 0
            max_rows = 0

        results[query_name] = {
            "num_tables": len(tables),
            "fk_pk_joins": fk_pk_count,
            "fk_fk_joins": fk_fk_count,
            "min_rows": min_rows,
            "max_rows": max_rows,
            "num_filters": filter_count,
            "tables": list(table_names)
        }

    return results


def print_results(results):
    """
    Print analysis results in a formatted table.
    """
    print("\n" + "=" * 100)
    print("JOB QUERY ANALYSIS RESULTS")
    print("=" * 100)
    print(f"{'Query':<10} {'Tables':>8} {'FK-PK':>8} {'FK-FK':>8} {'Min Rows':>15} {'Max Rows':>15} {'Filters':>8}")
    print("-" * 100)

    # Sort by query name (numeric then alphabetic suffix)
    def sort_key(name):
        match = re.match(r'(\d+)([a-z]*)', name)
        if match:
            return (int(match.group(1)), match.group(2))
        return (999, name)

    for query_name in sorted(results.keys(), key=sort_key):
        r = results[query_name]
        print(f"{query_name:<10} {r['num_tables']:>8} {r['fk_pk_joins']:>8} {r['fk_fk_joins']:>8} "
              f"{r['min_rows']:>15,} {r['max_rows']:>15,} {r['num_filters']:>8}")

    print("=" * 100)


def save_results(results, output_file):
    """
    Save results to a JSON file.
    """
    with open(output_file, 'w') as f:
        json.dump(results, f, indent=2)
    print(f"\nResults saved to {output_file}")


if __name__ == "__main__":
    results = analyze_queries()
    print_results(results)

    output_file = BASE_DIR / "query_analysis.json"
    save_results(results, output_file)
