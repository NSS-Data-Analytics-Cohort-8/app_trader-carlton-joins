SELECT *
FROM app_store_apps;


SELECT *
FROM play_store_apps;


-- #### 2. Assumptions

-- Based on research completed prior to launching App Trader as a company, you can assume the following:

-- a. App Trader will purchase apps for 10,000 times the price of the app. For apps that are priced from free up to $1.00, the purchase price is $10,000.

--remove dollar sign
--SELECT name, CAST(REPLACE(price, '$',' ') AS float),
--FROM play_store_apps;


SELECT d.name AS dname, i.name AS iname, d.rating AS drating, i.rating AS irating, size AS dsize, size_bytes AS isize, primary_genre, genres, i.price, CAST(REPLACE(d.price, '$',' ') AS float)
FROM play_store_apps AS d
INNER JOIN app_store_apps AS i
ON d.name = i.name
WHERE i.name IS NOT NULL AND GREATEST();

    
-- - For example, an app that costs $2.00 will be purchased for $20,000.
    
-- - The cost of an app is not affected by how many app stores it is on. A $1.00 app on the Apple app store will cost the same as a $1.00 app on both stores. 
    
-- - If an app is on both stores, it's purchase price will be calculated based off of the highest app price between the two stores. 

-- b. Apps earn $5000 per month, per app store it is on, from in-app advertising and in-app purchases, regardless of the price of the app.
    
-- - An app that costs $200,000 will make the same per month as an app that costs $1.00. 

-- - An app that is on both app stores will make $10,000 per month. 

-- c. App Trader will spend an average of $1000 per month to market an app regardless of the price of the app. If App Trader owns rights to the app in both stores, it can market the app for both stores for a single cost of $1000 per month.
    
-- - An app that costs $200,000 and an app that costs $1.00 will both cost $1000 a month for marketing, regardless of the number of stores it is in.

-- d. For every half point that an app gains in rating, its projected lifespan increases by one year. In other words, an app with a rating of 0 can be expected to be in use for 1 year, an app with a rating of 1.0 can be expected to last 3 years, and an app with a rating of 4.0 can be expected to last 9 years.
    
-- - App store ratings should be calculated by taking the average of the scores from both app stores and rounding to the nearest 0.5.

--find average of playstore apps
SELECT name, d.category, ROUND(AVG(d.rating),1) AS rating
FROM play_store_apps AS d
WHERE rating IS NOT NULL
GROUP BY name, d.category
ORDER BY rating DESC;
--LIMIT 10;

SELECT DISTINCT(genres)
FROM play_store_apps;
--119 genres in the play_store / 33 categories

SELECT DISTINCT(primary_genre)
FROM app_store_apps;
--23 genres in the app_store

SELECT name, primary_genre, ROUND(AVG(i.rating),1) AS rating
FROM app_store_apps AS i
GROUP BY name, primary_genre
ORDER BY rating DESC;
--LIMIT 10;
--name/genre/avg rating of all app_store games 

--CREATE VIEW all_ratings AS
SELECT d.name AS dname, i.name AS iname, d.rating AS drating, i.rating AS irating, size AS dsize, size_bytes AS isize, primary_genre, genres
FROM play_store_apps AS d
INNER JOIN app_store_apps AS i
ON d.name = i.name
WHERE i.name IS NOT NULL;


-- e. App Trader would prefer to work with apps that are available in both the App Store and the Play Store since they can market both for the same $1000 per month.


-- #### 3. Deliverables

-- a. Develop some general recommendations as to the price range, genre, content rating, or anything else for apps that the company should target.

-- b. Develop a Top 10 List of the apps that App Trader should buy.
