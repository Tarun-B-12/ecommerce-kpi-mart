import duckdb
import os

DB_PATH = "data/ecommerce.duckdb"
RAW_DATA_PATH = "data/raw"

FILES = {
    "raw_orders": "olist_orders_dataset.csv",
    "raw_order_items": "olist_order_items_dataset.csv",
    "raw_customers": "olist_customers_dataset.csv",
    "raw_sellers": "olist_sellers_dataset.csv",
    "raw_products": "olist_products_dataset.csv",
    "raw_order_payments": "olist_order_payments_dataset.csv",
    "raw_order_reviews": "olist_order_reviews_dataset.csv",
    "raw_category_translation": "product_category_name_translation.csv",
}

def load_data():
    os.makedirs("data", exist_ok=True)
    con = duckdb.connect(DB_PATH)
    con.execute("CREATE SCHEMA IF NOT EXISTS raw")

    for table_name, filename in FILES.items():
        filepath = os.path.join(RAW_DATA_PATH, filename)
        if not os.path.exists(filepath):
            print(f"MISSING: {filepath}")
            continue
        con.execute(f"DROP TABLE IF EXISTS raw.{table_name}")
        con.execute(f"""
            CREATE TABLE raw.{table_name} AS
            SELECT * FROM read_csv_auto('{filepath}', header=true)
        """)
        count = con.execute(f"SELECT COUNT(*) FROM raw.{table_name}").fetchone()[0]
        print(f"Loaded raw.{table_name}: {count:,} rows")

    con.close()
    print("Done. Database saved to:", DB_PATH)

if __name__ == "__main__":
    load_data()
    