SET search_path TO bd_lab1;

-- Проверка загрузки исходных данных
SELECT COUNT(*) AS stg_rows FROM stg_mock_data_raw;

-- Проверка заполнения таблицы фактов
SELECT COUNT(*) AS fact_rows FROM fact_sales;

-- Сверка суммы продаж между staging и fact
SELECT
    (SELECT ROUND(SUM(sale_total_price), 2) FROM vw_stg_clean) AS stg_sales_sum,
    (SELECT ROUND(SUM(sale_total_price), 2) FROM fact_sales) AS fact_sales_sum;

-- Количество записей в измерениях
SELECT 'dim_country' AS table_name, COUNT(*) AS row_count FROM dim_country
UNION ALL
SELECT 'dim_pet', COUNT(*) FROM dim_pet
UNION ALL
SELECT 'dim_customer', COUNT(*) FROM dim_customer
UNION ALL
SELECT 'dim_seller', COUNT(*) FROM dim_seller
UNION ALL
SELECT 'dim_product_category', COUNT(*) FROM dim_product_category
UNION ALL
SELECT 'dim_product_brand', COUNT(*) FROM dim_product_brand
UNION ALL
SELECT 'dim_product_material', COUNT(*) FROM dim_product_material
UNION ALL
SELECT 'dim_product_color', COUNT(*) FROM dim_product_color
UNION ALL
SELECT 'dim_product_size', COUNT(*) FROM dim_product_size
UNION ALL
SELECT 'dim_product', COUNT(*) FROM dim_product
UNION ALL
SELECT 'dim_store', COUNT(*) FROM dim_store
UNION ALL
SELECT 'dim_supplier', COUNT(*) FROM dim_supplier
UNION ALL
SELECT 'dim_date', COUNT(*) FROM dim_date
ORDER BY table_name;

-- Контроль потерь ключей в факте (ожидаем 0)
SELECT
    COUNT(*) FILTER (WHERE customer_key IS NULL) AS missing_customer_key,
    COUNT(*) FILTER (WHERE seller_key IS NULL) AS missing_seller_key,
    COUNT(*) FILTER (WHERE product_key IS NULL) AS missing_product_key,
    COUNT(*) FILTER (WHERE store_key IS NULL) AS missing_store_key,
    COUNT(*) FILTER (WHERE supplier_key IS NULL) AS missing_supplier_key,
    COUNT(*) FILTER (WHERE sale_date_key IS NULL) AS missing_sale_date_key
FROM fact_sales;
