--2a. App Trader will purchase apps for 10,000 times the price of the app. For apps that are priced from free up to $1.00, the purchase price is $10,000. 

SELECT name, COUNT(name)
FROM play_store_apps
GROUP BY name;

--to find duplicate in table
SELECT name, COUNT(*)
FROM app_store_apps
GROUP BY name
HAVING COUNT(*) > 1


--app store apps top rating by genre

select DISTINCT primary_genre, COUNT(name)
from app_store_apps
WHERE rating > 4.5
GROUP BY DISTINCT primary_genre
ORDER BY COUNT(name) DESC;

--play store apps top rating by genre

Select DISTINCT genres, COUNT(name)
from play_store_apps
WHERE rating > 4.5
GROUP BY DISTINCT genres
ORDER BY COUNT(name) DESC;

--app store avg price of apps over $1.00 by genre
SELECT primary_genre, avg(price)
FROM app_store_apps
WHERE price > 1
group by primary_genre
order by avg(price) DESC;

-- play store avg price of apps over $1.00 by genre
SELECT primary_genre, avg(price)
FROM play_store_apps
WHERE price > 1
group by category
order by avg(price) DESC;

----finding data types for all columns in both tables

SELECT 'app-store' AS table_name, column_name, data_type
FROM information_schema.columns
WHERE table_name = 'app_store_apps'
UNION
SELECT 'play_store' AS table, column_name, data_type
FROM information_schema.columns
WHERE table_name = 'play_store_apps'
ORDER BY table_name;

SELEC