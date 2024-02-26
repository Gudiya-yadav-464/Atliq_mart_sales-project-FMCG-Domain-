# Atliq_mart_sales-project-FMCG-Domain-

## Introduction </p>
### Codebasics Reume project Challenge - 9 </p>
The project is about a retail company which is an Atliq Mart. Now we will understand about the company and their needs.</p>

## Problem Statement </p>
**Atliq Mart** is a retail giant company with over **50+ supermarkets** in **southern region** of india.</p> Atliq mart ran a massive promotion during **Diwali 2024 and Sankranti 2025**(festive time in india) on their Atliq Branded Products.</p> Now their Sales director wants to know the which promotion did well and which not so that they which promotion did well and which not so tthat they can make informed decision from them.

## Business Request </p>
So the company gave us an ad-hoc-request file int this file campany gave us a some question and want the ans in the form of SQL queries. And their is some Addtional Analyses also they gve us as a task.so We will talk abou them one by one--</p>


**1.Provide a list of products with a base price greater than 500 and that are featured in promo type of BOGOF.**
```
select product_name, base_price , promo_type
from dim_products
inner join fact_events
on dim_products.product_code = fact_events.product_code 
where base_price > 500 
And promo_type = "BOGOF";

```
**2. Generate a report that provides an overview of number of stores in each city.**
```
select city , count(store_id) AS num_stores
from dim_stores
Group By city
Order by num_stores DESC;
```
**3.Generate a report that displayes each campaign along with their total revenue before and after the campaign.**
```
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
```
**4. Generate a report that calculates the incremental sold quantity for each category during the diwali campaign.**
```
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
```
**5. Create a report featuring the top 5 products ranked by the incremental revenue percantage across all campaigns.**
```
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
```

## Additional Analaysis</p> 

### Store Performance Analaysis</p>
 1. Which are the top 10 stores in terms of the incremetal revenue (IR) generated from the promotions?
 2. Which are the bottom 10 stores when it comes to incremental sold units during the ISU promotional period?
 3. How does the performance of stores vary city by city? Are there any common characterstics that can be levraged across other stores?

### Promotional Type Analaysis
1. What are the two promotion types that resulted in the highest incremental Revenue?
2. Is there any significan difference in the performance of discount based promotions versus BOGO or Cashback Promotions?
3. Which Promotions strike best balance between incremental sold units and maintaining healthy margins?
4. What are bottom two promotion types in temrs of incremental sod units?

### Product and Category Analysis 
1. Which product categories saw the most significant lift in sales from the promotions?
2. Are there any specific products that respond exceptionally well or poorely to promotions?
3. What is the correlation between product category and promotion type effectivness?


## Project Links 
My Linkedin profile link -- [https://www.linkedin.com/in/nikita-y-481861229/]</p>
Video presentation link --[https://www.linkedin.com/feed/update/urn:li:activity:7167770919669645312/]</p>
Project challenge link --[https://codebasics.io/challenge/codebasics-resume-project-challenge]</p>
Dashboard link --[https://www.novypro.com/project/atliq-mart-sales-analysis-project-fmcg-domain]</p>



