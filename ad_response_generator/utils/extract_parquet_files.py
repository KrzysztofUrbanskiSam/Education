#!/usr/bin/env python3

import argparse
import pyarrow.parquet as pq

def main():
    parser = argparse.ArgumentParser(description="Convert a Parquet file to JSON.")
    parser.add_argument("input_parquet", help="Path to the input Parquet file")
    parser.add_argument("output_json", help="Path to the output JSON file")
    args = parser.parse_args()

    # Read the Parquet file into a PyArrow Table
    table = pq.read_table(args.input_parquet)

    # Convert the PyArrow Table to a Pandas DataFrame
    df = table.to_pandas()

    # Convert the DataFrame to a JSON file
    # Using orient="records" and lines=True writes line-delimited JSON
    df.to_json(args.output_json, orient="records", lines=True)

if __name__ == "__main__":
    main()