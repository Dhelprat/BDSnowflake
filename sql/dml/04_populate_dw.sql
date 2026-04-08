SET search_path TO bd_lab1;

TRUNCATE TABLE
    fact_sales,
    dim_customer,
    dim_seller,
    dim_product,
    dim_store,
    dim_supplier,
    dim_pet,
    dim_date,
    dim_country,
    dim_product_category,
    dim_product_brand,
    dim_product_material,
    dim_product_color,
    dim_product_size
RESTART IDENTITY;

INSERT INTO dim_country (country_name)
SELECT DISTINCT country_name
FROM (
    SELECT customer_country AS country_name FROM vw_stg_clean
    UNION
    SELECT seller_country AS country_name FROM vw_stg_clean
    UNION
    SELECT store_country AS country_name FROM vw_stg_clean
    UNION
    SELECT supplier_country AS country_name FROM vw_stg_clean
) c
WHERE country_name IS NOT NULL;

INSERT INTO dim_pet (pet_type, pet_name, pet_breed, pet_category)
SELECT DISTINCT
    customer_pet_type,
    customer_pet_name,
    customer_pet_breed,
    pet_category
FROM vw_stg_clean
WHERE customer_pet_type IS NOT NULL
   OR customer_pet_name IS NOT NULL
   OR customer_pet_breed IS NOT NULL
   OR pet_category IS NOT NULL;

INSERT INTO dim_customer (
    customer_first_name,
    customer_last_name,
    customer_age,
    customer_email,
    customer_postal_code,
    country_key,
    pet_key
)
SELECT DISTINCT
    s.customer_first_name,
    s.customer_last_name,
    s.customer_age,
    s.customer_email,
    s.customer_postal_code,
    c.country_key,
    p.pet_key
FROM vw_stg_clean s
LEFT JOIN dim_country c
    ON c.country_name IS NOT DISTINCT FROM s.customer_country
LEFT JOIN dim_pet p
    ON p.pet_type IS NOT DISTINCT FROM s.customer_pet_type
   AND p.pet_name IS NOT DISTINCT FROM s.customer_pet_name
   AND p.pet_breed IS NOT DISTINCT FROM s.customer_pet_breed
   AND p.pet_category IS NOT DISTINCT FROM s.pet_category
WHERE s.customer_first_name IS NOT NULL
   OR s.customer_last_name IS NOT NULL
   OR s.customer_email IS NOT NULL;

INSERT INTO dim_seller (
    seller_first_name,
    seller_last_name,
    seller_email,
    seller_postal_code,
    country_key
)
SELECT DISTINCT
    s.seller_first_name,
    s.seller_last_name,
    s.seller_email,
    s.seller_postal_code,
    c.country_key
FROM vw_stg_clean s
LEFT JOIN dim_country c
    ON c.country_name IS NOT DISTINCT FROM s.seller_country
WHERE s.seller_first_name IS NOT NULL
   OR s.seller_last_name IS NOT NULL
   OR s.seller_email IS NOT NULL;

INSERT INTO dim_store (
    store_name,
    store_location,
    store_city,
    store_state,
    store_phone,
    store_email,
    country_key
)
SELECT DISTINCT
    s.store_name,
    s.store_location,
    s.store_city,
    s.store_state,
    s.store_phone,
    s.store_email,
    c.country_key
FROM vw_stg_clean s
LEFT JOIN dim_country c
    ON c.country_name IS NOT DISTINCT FROM s.store_country
WHERE s.store_name IS NOT NULL
   OR s.store_location IS NOT NULL
   OR s.store_city IS NOT NULL
   OR s.store_email IS NOT NULL;

INSERT INTO dim_supplier (
    supplier_name,
    supplier_contact,
    supplier_email,
    supplier_phone,
    supplier_address,
    supplier_city,
    country_key
)
SELECT DISTINCT
    s.supplier_name,
    s.supplier_contact,
    s.supplier_email,
    s.supplier_phone,
    s.supplier_address,
    s.supplier_city,
    c.country_key
FROM vw_stg_clean s
LEFT JOIN dim_country c
    ON c.country_name IS NOT DISTINCT FROM s.supplier_country
WHERE s.supplier_name IS NOT NULL
   OR s.supplier_contact IS NOT NULL
   OR s.supplier_email IS NOT NULL;

INSERT INTO dim_product_category (product_category_name)
SELECT DISTINCT product_category
FROM vw_stg_clean
WHERE product_category IS NOT NULL;

INSERT INTO dim_product_brand (product_brand_name)
SELECT DISTINCT product_brand
FROM vw_stg_clean
WHERE product_brand IS NOT NULL;

INSERT INTO dim_product_material (product_material_name)
SELECT DISTINCT product_material
FROM vw_stg_clean
WHERE product_material IS NOT NULL;

INSERT INTO dim_product_color (product_color_name)
SELECT DISTINCT product_color
FROM vw_stg_clean
WHERE product_color IS NOT NULL;

INSERT INTO dim_product_size (product_size_name)
SELECT DISTINCT product_size
FROM vw_stg_clean
WHERE product_size IS NOT NULL;

INSERT INTO dim_product (
    product_name,
    product_category_key,
    product_brand_key,
    product_material_key,
    product_color_key,
    product_size_key,
    product_weight,
    product_description,
    product_rating,
    product_reviews,
    product_release_date,
    product_expiry_date,
    product_price,
    product_quantity
)
SELECT DISTINCT
    s.product_name,
    c.product_category_key,
    b.product_brand_key,
    m.product_material_key,
    clr.product_color_key,
    sz.product_size_key,
    s.product_weight,
    s.product_description,
    s.product_rating,
    s.product_reviews,
    s.product_release_date,
    s.product_expiry_date,
    s.product_price,
    s.product_quantity
FROM vw_stg_clean s
LEFT JOIN dim_product_category c
    ON c.product_category_name IS NOT DISTINCT FROM s.product_category
LEFT JOIN dim_product_brand b
    ON b.product_brand_name IS NOT DISTINCT FROM s.product_brand
LEFT JOIN dim_product_material m
    ON m.product_material_name IS NOT DISTINCT FROM s.product_material
LEFT JOIN dim_product_color clr
    ON clr.product_color_name IS NOT DISTINCT FROM s.product_color
LEFT JOIN dim_product_size sz
    ON sz.product_size_name IS NOT DISTINCT FROM s.product_size
WHERE s.product_name IS NOT NULL;

INSERT INTO dim_date (
    date_key,
    full_date,
    day_of_month,
    month_num,
    month_name,
    quarter_num,
    year_num,
    week_num,
    day_of_week,
    day_name
)
SELECT DISTINCT
    TO_CHAR(s.sale_date, 'YYYYMMDD')::INTEGER AS date_key,
    s.sale_date AS full_date,
    EXTRACT(DAY FROM s.sale_date)::SMALLINT AS day_of_month,
    EXTRACT(MONTH FROM s.sale_date)::SMALLINT AS month_num,
    TO_CHAR(s.sale_date, 'FMMonth') AS month_name,
    EXTRACT(QUARTER FROM s.sale_date)::SMALLINT AS quarter_num,
    EXTRACT(YEAR FROM s.sale_date)::INTEGER AS year_num,
    EXTRACT(WEEK FROM s.sale_date)::SMALLINT AS week_num,
    EXTRACT(ISODOW FROM s.sale_date)::SMALLINT AS day_of_week,
    TO_CHAR(s.sale_date, 'FMDay') AS day_name
FROM vw_stg_clean s
WHERE s.sale_date IS NOT NULL;

INSERT INTO fact_sales (
    source_row_id,
    sale_date_key,
    customer_key,
    seller_key,
    product_key,
    store_key,
    supplier_key,
    source_sale_customer_id,
    source_sale_seller_id,
    source_sale_product_id,
    sale_quantity,
    sale_total_price,
    unit_price
)
SELECT
    s.stg_id AS source_row_id,
    d.date_key AS sale_date_key,
    c.customer_key,
    se.seller_key,
    p.product_key,
    st.store_key,
    su.supplier_key,
    s.sale_customer_id AS source_sale_customer_id,
    s.sale_seller_id AS source_sale_seller_id,
    s.sale_product_id AS source_sale_product_id,
    s.sale_quantity,
    s.sale_total_price,
    CASE
        WHEN s.sale_quantity > 0 AND s.sale_total_price IS NOT NULL
            THEN ROUND(s.sale_total_price / s.sale_quantity, 2)
    END AS unit_price
FROM vw_stg_clean s
LEFT JOIN dim_date d
    ON d.full_date = s.sale_date
LEFT JOIN dim_country c_country
    ON c_country.country_name IS NOT DISTINCT FROM s.customer_country
LEFT JOIN dim_pet pet
    ON pet.pet_type IS NOT DISTINCT FROM s.customer_pet_type
   AND pet.pet_name IS NOT DISTINCT FROM s.customer_pet_name
   AND pet.pet_breed IS NOT DISTINCT FROM s.customer_pet_breed
   AND pet.pet_category IS NOT DISTINCT FROM s.pet_category
LEFT JOIN dim_customer c
    ON c.customer_first_name IS NOT DISTINCT FROM s.customer_first_name
   AND c.customer_last_name IS NOT DISTINCT FROM s.customer_last_name
   AND c.customer_age IS NOT DISTINCT FROM s.customer_age
   AND c.customer_email IS NOT DISTINCT FROM s.customer_email
   AND c.customer_postal_code IS NOT DISTINCT FROM s.customer_postal_code
   AND c.country_key IS NOT DISTINCT FROM c_country.country_key
   AND c.pet_key IS NOT DISTINCT FROM pet.pet_key
LEFT JOIN dim_country se_country
    ON se_country.country_name IS NOT DISTINCT FROM s.seller_country
LEFT JOIN dim_seller se
    ON se.seller_first_name IS NOT DISTINCT FROM s.seller_first_name
   AND se.seller_last_name IS NOT DISTINCT FROM s.seller_last_name
   AND se.seller_email IS NOT DISTINCT FROM s.seller_email
   AND se.seller_postal_code IS NOT DISTINCT FROM s.seller_postal_code
   AND se.country_key IS NOT DISTINCT FROM se_country.country_key
LEFT JOIN dim_product_category pc
    ON pc.product_category_name IS NOT DISTINCT FROM s.product_category
LEFT JOIN dim_product_brand pb
    ON pb.product_brand_name IS NOT DISTINCT FROM s.product_brand
LEFT JOIN dim_product_material pm
    ON pm.product_material_name IS NOT DISTINCT FROM s.product_material
LEFT JOIN dim_product_color pcl
    ON pcl.product_color_name IS NOT DISTINCT FROM s.product_color
LEFT JOIN dim_product_size psz
    ON psz.product_size_name IS NOT DISTINCT FROM s.product_size
LEFT JOIN dim_product p
    ON p.product_name IS NOT DISTINCT FROM s.product_name
   AND p.product_category_key IS NOT DISTINCT FROM pc.product_category_key
   AND p.product_brand_key IS NOT DISTINCT FROM pb.product_brand_key
   AND p.product_material_key IS NOT DISTINCT FROM pm.product_material_key
   AND p.product_color_key IS NOT DISTINCT FROM pcl.product_color_key
   AND p.product_size_key IS NOT DISTINCT FROM psz.product_size_key
   AND p.product_weight IS NOT DISTINCT FROM s.product_weight
   AND p.product_description IS NOT DISTINCT FROM s.product_description
   AND p.product_rating IS NOT DISTINCT FROM s.product_rating
   AND p.product_reviews IS NOT DISTINCT FROM s.product_reviews
   AND p.product_release_date IS NOT DISTINCT FROM s.product_release_date
   AND p.product_expiry_date IS NOT DISTINCT FROM s.product_expiry_date
   AND p.product_price IS NOT DISTINCT FROM s.product_price
   AND p.product_quantity IS NOT DISTINCT FROM s.product_quantity
LEFT JOIN dim_country st_country
    ON st_country.country_name IS NOT DISTINCT FROM s.store_country
LEFT JOIN dim_store st
    ON st.store_name IS NOT DISTINCT FROM s.store_name
   AND st.store_location IS NOT DISTINCT FROM s.store_location
   AND st.store_city IS NOT DISTINCT FROM s.store_city
   AND st.store_state IS NOT DISTINCT FROM s.store_state
   AND st.store_phone IS NOT DISTINCT FROM s.store_phone
   AND st.store_email IS NOT DISTINCT FROM s.store_email
   AND st.country_key IS NOT DISTINCT FROM st_country.country_key
LEFT JOIN dim_country su_country
    ON su_country.country_name IS NOT DISTINCT FROM s.supplier_country
LEFT JOIN dim_supplier su
    ON su.supplier_name IS NOT DISTINCT FROM s.supplier_name
   AND su.supplier_contact IS NOT DISTINCT FROM s.supplier_contact
   AND su.supplier_email IS NOT DISTINCT FROM s.supplier_email
   AND su.supplier_phone IS NOT DISTINCT FROM s.supplier_phone
   AND su.supplier_address IS NOT DISTINCT FROM s.supplier_address
   AND su.supplier_city IS NOT DISTINCT FROM s.supplier_city
   AND su.country_key IS NOT DISTINCT FROM su_country.country_key;
