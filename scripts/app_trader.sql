-- ### App Trader

-- Your team has been hired by a new company called App Trader to help them explore and gain insights from apps that are made available through the Apple App Store and Android Play Store. App Trader is a broker that purchases the rights to apps from developers in order to market the apps and offer in-app purchase. 

-- Unfortunately, the data for Apple App Store apps and Android Play Store Apps is located in separate tables with no referential integrity.

-- #### 1. Loading the data
-- a. Launch PgAdmin and create a new database called app_trader.  

-- b. Right-click on the app_trader database and choose `Restore...`  

-- c. Use the default values under the `Restore Options` tab. 

-- d. In the `Filename` section, browse to the backup file `app_store_backup.backup` in the data folder of this repository.  

-- e. Click `Restore` to load the database.  

-- f. Verify that you have two tables:  
--     - `app_store_apps` with 7197 rows  
--     - `play_store_apps` with 10840 rows
-- Combined 18037
-- 553 overlapping
-- Should be 17484 distinct

-- #### 2. Assumptions

-- Based on research completed prior to launching App Trader as a company, you can assume the following:

-- a. App Trader will purchase apps for 10,000 times the price of the app. For apps that are priced from free up to $1.00, the purchase price is $10,000.

-- consider using bytes as a key!
-- Found some duplicates -- including WWE

WITH price_cte AS (SELECT name, price
FROM app_store_apps
UNION ALL
SELECT name, price 
FROM (SELECT name,
	CASE WHEN price LIKE '$%' THEN CAST(SUBSTRING(price,2,length(price)) as float)
	ELSE CAST(price as float) END as price
	FROM play_store_apps) as sub)
	
-- Now to identify all duplicates and find highest app price

SELECT p.name, a.name, p.price, a.price, GREATEST(p.price, a.price) as max_price
FROM (SELECT name,
	CASE WHEN price LIKE '$%' THEN CAST(SUBSTRING(price,2,length(price)) as float)
	ELSE CAST(price as float) END as price
	FROM play_store_apps) as p
FULL JOIN app_store_apps as a
ON a.name=p.name
ORDER BY max_price DESC;

-- Added in coalesce to get rid of null values in names from app store exclusives 

SELECT COALESCE(p.name,a.name), GREATEST(p.price, a.price) as max_price,
	CASE WHEN GREATEST(p.price, a.price) > 1 THEN (10000 * GREATEST(p.price, a.price))
	ELSE 10000 END as cost
FROM (SELECT name,
	CASE WHEN price LIKE '$%' THEN CAST(SUBSTRING(price,2,length(price)) as float)
	ELSE CAST(price as float) END as price
	FROM play_store_apps) as p
FULL JOIN app_store_apps as a
ON a.name=p.name
ORDER BY max_price DESC; -- returns 17709 rows


SELECT DISTINCT(COALESCE(p.name,a.name)), GREATEST(p.price, a.price) as max_price,
	CASE WHEN GREATEST(p.price, a.price) > 1 THEN (10000 * GREATEST(p.price, a.price))
	ELSE 10000 END as cost
FROM (SELECT name,
	CASE WHEN price LIKE '$%' THEN CAST(SUBSTRING(price,2,length(price)) as float)
	ELSE CAST(price as float) END as price
	FROM play_store_apps) as p
FULL JOIN app_store_apps as a
ON a.name=p.name
ORDER BY max_price DESC; --returns 16528 rows


-- 18037 combined rows. 18037 minus 553 is 17484
-- Are there any apps in app store but not play store? 6869
-- In play store but not app store? 10287 (added equals 17156)
-- There are 553 that overlap
-- 17709 total entries. Why does this not equal the value up top? Difference is 225
-- Should use FULL JOIN

SELECT name
FROM play_store_apps
WHERE name NOT IN (SELECT name
				  FROM app_store_apps)
SELECT name
FROM app_store_apps
WHERE name NOT IN (SELECT name
				  FROM play_store_apps)	
				  
SELECT name
FROM play_store_apps
WHERE name IN (SELECT name
				  FROM app_store_apps)

-- - For example, an app that costs $2.00 will be purchased for $20,000.
    
-- - The cost of an app is not affected by how many app stores it is on. A $1.00 app on the Apple app store will cost the same as a $1.00 app on both stores. 
    
-- - If an app is on both stores, it's purchase price will be calculated based off of the highest app price between the two stores. 

-- b. Apps earn $5000 per month, per app store it is on, from in-app advertising and in-app purchases, regardless of the price of the app.

WITH stores AS (SELECT DISTINCT(name)
FROM app_store_apps
UNION ALL
SELECT DISTINCT(name)
FROM play_store_apps)

SELECT name, COUNT(name) * 5000 as monthly_earnings
FROM stores
GROUP BY name
ORDER BY monthly_earnings DESC -- returns 16526 rows

-- or

SELECT COALESCE(p.name,a.name) as name, (COUNT(DISTINCT(p.name))+COUNT(DISTINCT(a.name))) * 5000 as monthly_earnings
FROM play_store_apps as p
FULL JOIN app_store_apps as a
ON a.name = p.name
GROUP BY p.name, a.name
ORDER BY monthly_earnings DESC; -- returns 16526 rows


-- WITH stores AS (SELECT name
-- FROM app_store_apps
-- UNION ALL
-- SELECT name
-- FROM play_store_apps)

-- --18037 rows

-- SELECT name
-- FROM stores
-- EXCEPT 
-- SELECT name 
-- FROM app_store_apps

-- -- 9331 rows

-- WITH stores AS (SELECT name
-- FROM app_store_apps
-- UNION ALL
-- SELECT name
-- FROM play_store_apps)

-- SELECT name
-- FROM stores
-- EXCEPT 
-- SELECT name 
-- FROM play_store_apps

-- --6867 rows 

-- SELECT name
-- FROM play_store_apps
-- EXCEPT
-- SELECT name
-- FROM app_store_apps -- 9931

-- SELECT name
-- FROM app_store_apps
-- EXCEPT
-- SELECT name
-- FROM play_store_apps -- 6867

-- SELECT name
-- FROM play_store_apps
-- UNION
-- SELECT name
-- FROM app_store_apps -- 16526 shared

-- - An app that costs $200,000 will make the same per month as an app that costs $1.00. 

-- - An app that is on both app stores will make $10,000 per month. 

-- c. App Trader will spend an average of $1000 per month to market an app regardless of the price of the app. If App Trader owns rights to the app in both stores, it can market the app for both stores for a single cost of $1000 per month.

SELECT COALESCE(p.name,a.name) as name, 1000 as monthly_cost
FROM play_store_apps as p
FULL JOIN app_store_apps as a
ON p.name = a.name
WHERE p.name LIKE 'FreeCell' or a.name LIKE 'FreeCell'
    
-- - An app that costs $200,000 and an app that costs $1.00 will both cost $1000 a month for marketing, regardless of the number of stores it is in.

-- d. For every half point that an app gains in rating, its projected lifespan increases by one year. In other words, an app with a rating of 0 can be expected to be in use for 1 year, an app with a rating of 1.0 can be expected to last 3 years, and an app with a rating of 4.0 can be expected to last 9 years.
    
-- - App store ratings should be calculated by taking the average of the scores from both app stores and rounding to the nearest 0.5.

-- e. App Trader would prefer to work with apps that are available in both the App Store and the Play Store since they can market both for the same $1000 per month.


-- #### 3. Deliverables

-- a. Develop some general recommendations as to the price range, genre, content rating, or anything else for apps that the company should target.

-- b. Develop a Top 10 List of the apps that App Trader should buy.



-- updated 2/18/2023

-- First figure out purchase prices for each app
