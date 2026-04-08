SET search_path TO bd_lab1;

DROP VIEW IF EXISTS vw_stg_clean;

DROP TABLE IF EXISTS fact_sales CASCADE;
DROP TABLE IF EXISTS dim_customer CASCADE;
DROP TABLE IF EXISTS dim_seller CASCADE;
DROP TABLE IF EXISTS dim_product CASCADE;
DROP TABLE IF EXISTS dim_store CASCADE;
DROP TABLE IF EXISTS dim_supplier CASCADE;
DROP TABLE IF EXISTS dim_pet CASCADE;
DROP TABLE IF EXISTS dim_date CASCADE;
DROP TABLE IF EXISTS dim_country CASCADE;
DROP TABLE IF EXISTS dim_product_category CASCADE;
DROP TABLE IF EXISTS dim_product_brand CASCADE;
DROP TABLE IF EXISTS dim_product_material CASCADE;
DROP TABLE IF EXISTS dim_product_color CASCADE;
DROP TABLE IF EXISTS dim_product_size CASCADE;

CREATE TABLE dim_country (
    country_key BIGSERIAL PRIMARY KEY,
    country_name TEXT NOT NULL UNIQUE
);

CREATE TABLE dim_pet (
    pet_key BIGSERIAL PRIMARY KEY,
    pet_type TEXT,
    pet_name TEXT,
    pet_breed TEXT,
    pet_category TEXT
);

CREATE TABLE dim_customer (
    customer_key BIGSERIAL PRIMARY KEY,
    customer_first_name TEXT,
    customer_last_name TEXT,
    customer_age INTEGER,
    customer_email TEXT,
    customer_postal_code TEXT,
    country_key BIGINT REFERENCES dim_country(country_key),
    pet_key BIGINT REFERENCES dim_pet(pet_key)
);

CREATE TABLE dim_seller (
    seller_key BIGSERIAL PRIMARY KEY,
    seller_first_name TEXT,
    seller_last_name TEXT,
    seller_email TEXT,
    seller_postal_code TEXT,
    country_key BIGINT REFERENCES dim_country(country_key)
);

CREATE TABLE dim_store (
    store_key BIGSERIAL PRIMARY KEY,
    store_name TEXT,
    store_location TEXT,
    store_city TEXT,
    store_state TEXT,
    store_phone TEXT,
    store_email TEXT,
    country_key BIGINT REFERENCES dim_country(country_key)
);

CREATE TABLE dim_supplier (
    supplier_key BIGSERIAL PRIMARY KEY,
    supplier_name TEXT,
    supplier_contact TEXT,
    supplier_email TEXT,
    supplier_phone TEXT,
    supplier_address TEXT,
    supplier_city TEXT,
    country_key BIGINT REFERENCES dim_country(country_key)
);

CREATE TABLE dim_product_category (
    product_category_key BIGSERIAL PRIMARY KEY,
    product_category_name TEXT NOT NULL UNIQUE
);

CREATE TABLE dim_product_brand (
    product_brand_key BIGSERIAL PRIMARY KEY,
    product_brand_name TEXT NOT NULL UNIQUE
);

CREATE TABLE dim_product_material (
    product_material_key BIGSERIAL PRIMARY KEY,
    product_material_name TEXT NOT NULL UNIQUE
);

CREATE TABLE dim_product_color (
    product_color_key BIGSERIAL PRIMARY KEY,
    product_color_name TEXT NOT NULL UNIQUE
);

CREATE TABLE dim_product_size (
    product_size_key BIGSERIAL PRIMARY KEY,
    product_size_name TEXT NOT NULL UNIQUE
);

CREATE TABLE dim_product (
    product_key BIGSERIAL PRIMARY KEY,
    product_name TEXT,
    product_category_key BIGINT REFERENCES dim_product_category(product_category_key),
    product_brand_key BIGINT REFERENCES dim_product_brand(product_brand_key),
    product_material_key BIGINT REFERENCES dim_product_material(product_material_key),
    product_color_key BIGINT REFERENCES dim_product_color(product_color_key),
    product_size_key BIGINT REFERENCES dim_product_size(product_size_key),
    product_weight NUMERIC(10, 2),
    product_description TEXT,
    product_rating NUMERIC(3, 1),
    product_reviews INTEGER,
    product_release_date DATE,
    product_expiry_date DATE,
    product_price NUMERIC(10, 2),
    product_quantity INTEGER
);

CREATE TABLE dim_date (
    date_key INTEGER PRIMARY KEY,
    full_date DATE NOT NULL UNIQUE,
    day_of_month SMALLINT NOT NULL,
    month_num SMALLINT NOT NULL,
    month_name TEXT NOT NULL,
    quarter_num SMALLINT NOT NULL,
    year_num INTEGER NOT NULL,
    week_num SMALLINT NOT NULL,
    day_of_week SMALLINT NOT NULL,
    day_name TEXT NOT NULL
);

CREATE TABLE fact_sales (
    sale_key BIGSERIAL PRIMARY KEY,
    source_row_id BIGINT NOT NULL UNIQUE REFERENCES stg_mock_data_raw(stg_id),
    sale_date_key INTEGER REFERENCES dim_date(date_key),
    customer_key BIGINT REFERENCES dim_customer(customer_key),
    seller_key BIGINT REFERENCES dim_seller(seller_key),
    product_key BIGINT REFERENCES dim_product(product_key),
    store_key BIGINT REFERENCES dim_store(store_key),
    supplier_key BIGINT REFERENCES dim_supplier(supplier_key),
    source_sale_customer_id INTEGER,
    source_sale_seller_id INTEGER,
    source_sale_product_id INTEGER,
    sale_quantity INTEGER,
    sale_total_price NUMERIC(12, 2),
    unit_price NUMERIC(12, 2)
);

CREATE INDEX idx_fact_sales_sale_date_key ON fact_sales(sale_date_key);
CREATE INDEX idx_fact_sales_customer_key ON fact_sales(customer_key);
CREATE INDEX idx_fact_sales_seller_key ON fact_sales(seller_key);
CREATE INDEX idx_fact_sales_product_key ON fact_sales(product_key);
CREATE INDEX idx_fact_sales_store_key ON fact_sales(store_key);
CREATE INDEX idx_fact_sales_supplier_key ON fact_sales(supplier_key);

CREATE OR REPLACE VIEW vw_stg_clean AS
SELECT
    stg_id,
    CASE WHEN NULLIF(TRIM(source_id), '') ~ '^[0-9]+$' THEN NULLIF(TRIM(source_id), '')::INTEGER END AS source_id,
    NULLIF(TRIM(customer_first_name), '') AS customer_first_name,
    NULLIF(TRIM(customer_last_name), '') AS customer_last_name,
    CASE WHEN NULLIF(TRIM(customer_age), '') ~ '^[0-9]+$' THEN NULLIF(TRIM(customer_age), '')::INTEGER END AS customer_age,
    NULLIF(TRIM(customer_email), '') AS customer_email,
    NULLIF(TRIM(customer_country), '') AS customer_country,
    NULLIF(TRIM(customer_postal_code), '') AS customer_postal_code,
    NULLIF(TRIM(customer_pet_type), '') AS customer_pet_type,
    NULLIF(TRIM(customer_pet_name), '') AS customer_pet_name,
    NULLIF(TRIM(customer_pet_breed), '') AS customer_pet_breed,
    NULLIF(TRIM(seller_first_name), '') AS seller_first_name,
    NULLIF(TRIM(seller_last_name), '') AS seller_last_name,
    NULLIF(TRIM(seller_email), '') AS seller_email,
    NULLIF(TRIM(seller_country), '') AS seller_country,
    NULLIF(TRIM(seller_postal_code), '') AS seller_postal_code,
    NULLIF(TRIM(product_name), '') AS product_name,
    NULLIF(TRIM(product_category), '') AS product_category,
    CASE
        WHEN NULLIF(TRIM(product_price), '') ~ '^[0-9]+([.][0-9]+)?$'
            THEN NULLIF(TRIM(product_price), '')::NUMERIC(10, 2)
    END AS product_price,
    CASE
        WHEN NULLIF(TRIM(product_quantity), '') ~ '^[0-9]+$'
            THEN NULLIF(TRIM(product_quantity), '')::INTEGER
    END AS product_quantity,
    CASE
        WHEN NULLIF(TRIM(sale_date), '') ~ '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$'
            THEN TO_DATE(NULLIF(TRIM(sale_date), ''), 'MM/DD/YYYY')
    END AS sale_date,
    CASE
        WHEN NULLIF(TRIM(sale_customer_id), '') ~ '^[0-9]+$'
            THEN NULLIF(TRIM(sale_customer_id), '')::INTEGER
    END AS sale_customer_id,
    CASE
        WHEN NULLIF(TRIM(sale_seller_id), '') ~ '^[0-9]+$'
            THEN NULLIF(TRIM(sale_seller_id), '')::INTEGER
    END AS sale_seller_id,
    CASE
        WHEN NULLIF(TRIM(sale_product_id), '') ~ '^[0-9]+$'
            THEN NULLIF(TRIM(sale_product_id), '')::INTEGER
    END AS sale_product_id,
    CASE
        WHEN NULLIF(TRIM(sale_quantity), '') ~ '^[0-9]+$'
            THEN NULLIF(TRIM(sale_quantity), '')::INTEGER
    END AS sale_quantity,
    CASE
        WHEN NULLIF(TRIM(sale_total_price), '') ~ '^[0-9]+([.][0-9]+)?$'
            THEN NULLIF(TRIM(sale_total_price), '')::NUMERIC(12, 2)
    END AS sale_total_price,
    NULLIF(TRIM(store_name), '') AS store_name,
    NULLIF(TRIM(store_location), '') AS store_location,
    NULLIF(TRIM(store_city), '') AS store_city,
    NULLIF(TRIM(store_state), '') AS store_state,
    NULLIF(TRIM(store_country), '') AS store_country,
    NULLIF(TRIM(store_phone), '') AS store_phone,
    NULLIF(TRIM(store_email), '') AS store_email,
    NULLIF(TRIM(pet_category), '') AS pet_category,
    CASE
        WHEN NULLIF(TRIM(product_weight), '') ~ '^[0-9]+([.][0-9]+)?$'
            THEN NULLIF(TRIM(product_weight), '')::NUMERIC(10, 2)
    END AS product_weight,
    NULLIF(TRIM(product_color), '') AS product_color,
    NULLIF(TRIM(product_size), '') AS product_size,
    NULLIF(TRIM(product_brand), '') AS product_brand,
    NULLIF(TRIM(product_material), '') AS product_material,
    NULLIF(TRIM(product_description), '') AS product_description,
    CASE
        WHEN NULLIF(TRIM(product_rating), '') ~ '^[0-9]+([.][0-9]+)?$'
            THEN NULLIF(TRIM(product_rating), '')::NUMERIC(3, 1)
    END AS product_rating,
    CASE
        WHEN NULLIF(TRIM(product_reviews), '') ~ '^[0-9]+$'
            THEN NULLIF(TRIM(product_reviews), '')::INTEGER
    END AS product_reviews,
    CASE
        WHEN NULLIF(TRIM(product_release_date), '') ~ '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$'
            THEN TO_DATE(NULLIF(TRIM(product_release_date), ''), 'MM/DD/YYYY')
    END AS product_release_date,
    CASE
        WHEN NULLIF(TRIM(product_expiry_date), '') ~ '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$'
            THEN TO_DATE(NULLIF(TRIM(product_expiry_date), ''), 'MM/DD/YYYY')
    END AS product_expiry_date,
    NULLIF(TRIM(supplier_name), '') AS supplier_name,
    NULLIF(TRIM(supplier_contact), '') AS supplier_contact,
    NULLIF(TRIM(supplier_email), '') AS supplier_email,
    NULLIF(TRIM(supplier_phone), '') AS supplier_phone,
    NULLIF(TRIM(supplier_address), '') AS supplier_address,
    NULLIF(TRIM(supplier_city), '') AS supplier_city,
    NULLIF(TRIM(supplier_country), '') AS supplier_country
FROM stg_mock_data_raw;
