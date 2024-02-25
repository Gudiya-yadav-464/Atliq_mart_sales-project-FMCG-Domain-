
show databases;

use retail_events_db;

show tables;

select * from dim_campaigns;

select * from dim_products;

select * from dim_stores;

select * from fact_events;


-- product name and base_price > 500 and catgory 


select product_name,base_price , promo_type from 
dim_products  inner join 
fact_events on dim_products.product_code = fact_events.product_code 
where base_price > 500 
And promo_type = "BOGOF";

-- No. of stores in each city

SELECT 
    city,
    COUNT(store_id) AS num_stores
FROM 
    dim_stores 
WHERE 
    store_id IN (SELECT DISTINCT store_id FROM fact_events)
GROUP BY 
    city 
ORDER BY 
    num_stores Desc;
    
    
-- Revenue by campaign before and after the promotions

WITH PromoPrices AS (
    SELECT
        fe.*,
        CASE
            WHEN fe.promo_type = '50% OFF' THEN fe.base_price * 0.5
            WHEN fe.promo_type = '33% OFF' THEN fe.base_price * 0.67
            WHEN fe.promo_type = '25% OFF' THEN fe.base_price * 0.75
            WHEN fe.promo_type = '500 Cashback' THEN fe.base_price - 500
            WHEN fe.promo_type = 'BOGOF' THEN fe.base_price / 2
            ELSE fe.base_price  -- Default to base price if promo_type doesn't match any condition
        END AS promo_price
    FROM
        fact_events fe
)
SELECT
    dc.campaign_name,
    ROUND(SUM(f.`quantity_sold(before_promo)` * f.base_price) / 1000000, 2) AS total_revenue_before_promotion,
    ROUND(SUM(f.`quantity_sold(after_promo)` * p.promo_price) / 1000000, 2) AS total_revenue_after_promotion
FROM
    dim_campaigns dc
JOIN
    fact_events f ON dc.campaign_id = f.campaign_id
JOIN
    PromoPrices p ON p.event_id = f.event_id
GROUP BY
    dc.campaign_name;





-- Top catgory by ISU % 

 SELECT
    p.category,
    ((SUM(f.`quantity_sold(after_promo)`)-SUM(f.`quantity_sold(before_promo)`))/SUM(f.`quantity_sold(before_promo)`) * 100) AS ISU_percentage ,
    RANK() 
    OVER (ORDER BY((SUM(f.`quantity_sold(after_promo)`)-SUM(f.`quantity_sold(before_promo)`)) / SUM(f.`quantity_sold(before_promo)`) * 100) DESC) 
    AS Rank_order
FROM
    dim_products p
JOIN
    fact_events f ON p.product_code = f.product_code
    where campaign_id = 'CAMP_DIW_01'
GROUP BY
    p.category
ORDER BY
    ISU_percentage DESC;




-- Top product by Incremental revenue percantage

WITH PromoPrices AS (
    SELECT
        fe.*,
        CASE
            WHEN fe.promo_type = '50% OFF' THEN fe.base_price * 0.5
            WHEN fe.promo_type = '33% OFF' THEN fe.base_price * 0.67
            WHEN fe.promo_type = '25% OFF' THEN fe.base_price * 0.75
            WHEN fe.promo_type = '500 Cashback' THEN fe.base_price - 500
            WHEN fe.promo_type = 'BOGOF' THEN fe.base_price / 2
            ELSE fe.base_price  -- Default to base price if promo_type doesn't match any condition
        END AS promo_price
    FROM
        fact_events fe
)
SELECT
    dp.product_name, dp.category,
    ((sum(f.`quantity_sold(after_promo)`*p.promo_price) - sum(f.`quantity_sold(before_promo)`*f.base_price))/sum(f.`quantity_sold(before_promo)`*f.base_price)*100) AS IR_PERc
    
FROM
    dim_products dp
JOIN
    fact_events f ON dp.product_code = f.product_code
JOIN
    PromoPrices p ON p.event_id = f.event_id
GROUP BY
    dp.category
    order by IR_PERc DESC
    limit 5;












