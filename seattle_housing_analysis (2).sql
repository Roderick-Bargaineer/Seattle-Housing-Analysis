/* =============================================================================
   PROJECT:  Seattle-Area Housing Market Analysis
   QUESTION: Where do buyers get the best value in the Seattle area, and is
             the Seattle price premium justified?
   DATA:     King County home sales (housing_data table), loaded into DuckDB
   TOOLS:    DuckDB, DBeaver, SQL (CTEs, aggregates, window-free analysis)
   AUTHOR:   Roderick Bargaineer

   METHOD NOTES
   - Medians are used instead of means because housing prices are right-skewed;
     a few luxury sales would inflate averages.
   - City-level comparisons only include cities with >= 20 sales so a handful
     of homes cannot drive the result.
   - 49 rows have price = 0 (placeholders, not sales); they are removed via the
     housing_clean view (section 1.6) before Parts 2-6.
   - yr_renovated = 0 is treated as "never renovated".
   - Each statement ends with a semicolon and has no blank lines inside it, so
     it runs cleanly in DBeaver (Cmd/Ctrl + Enter).

   CONTENTS
   Part 1. Data Understanding & Quality Checks   (sections 1.1 - 1.6)
   Part 2. Market Overview                        (sections 2.1 - 2.3)
   Part 3. What Drives Price?                     (sections 3.1 - 3.2)
   Part 4. Location & Value Analysis              (sections 4.1 - 4.5)
   Part 5. Inside Seattle: Premium Features       (sections 5.1 - 5.4)
   Part 6. Is the Seattle Premium Just Size?      (sections 6.1 - 6.2)
   ============================================================================= */


/* =============================================================================
   PART 1. DATA UNDERSTANDING & QUALITY CHECKS
   ============================================================================= */

-- 1.1 Preview the table
SELECT *
FROM housing_data
LIMIT 10;

-- 1.2 Scope: how many homes, what time window, how many cities?
SELECT
    COUNT(*) AS total_homes,
    MIN(date) AS earliest_sale,
    MAX(date) AS latest_sale,
    COUNT(DISTINCT city) AS total_cities
FROM housing_data;

-- 1.3 Missing values check across key columns
SELECT
    COUNT(*) FILTER (WHERE price IS NULL) AS missing_price,
    COUNT(*) FILTER (WHERE bedrooms IS NULL) AS missing_bedrooms,
    COUNT(*) FILTER (WHERE bathrooms IS NULL) AS missing_bathrooms,
    COUNT(*) FILTER (WHERE sqft_living IS NULL) AS missing_sqft,
    COUNT(*) FILTER (WHERE city IS NULL) AS missing_city,
    COUNT(*) FILTER (WHERE yr_built IS NULL) AS missing_year_built
FROM housing_data;

-- 1.4 Suspicious values check: look for zeros, outliers, impossible years
SELECT
    MIN(price) AS min_price,
    MAX(price) AS max_price,
    MIN(bedrooms) AS min_bedrooms,
    MAX(bedrooms) AS max_bedrooms,
    MIN(bathrooms) AS min_bathrooms,
    MAX(bathrooms) AS max_bathrooms,
    MIN(sqft_living) AS min_sqft,
    MAX(sqft_living) AS max_sqft,
    MIN(yr_built) AS oldest_home,
    MAX(yr_built) AS newest_home
FROM housing_data;

-- 1.5 Data issues found: rows with price = 0 (not real sales) and bad sizes
SELECT
    COUNT(*) FILTER (WHERE price = 0) AS zero_price_rows,
    COUNT(*) FILTER (WHERE bedrooms = 0) AS zero_bedroom_rows,
    COUNT(*) FILTER (WHERE bathrooms = 0) AS zero_bathroom_rows,
    COUNT(*) FILTER (WHERE price_per_sqft > 1000) AS extreme_ppsf_rows
FROM housing_data;

-- 1.6 Cleaned view used for ALL analysis below (drops the price = 0 rows).
--     Extreme high-price sales are kept; medians are robust to them.
CREATE OR REPLACE VIEW housing_clean AS
SELECT *
FROM housing_data
WHERE price > 0;




/* =============================================================================
   PART 2. MARKET OVERVIEW
   ============================================================================= */

-- 2.1 Where are the homes located? (sample size per city)
SELECT
    city,
    COUNT(*) AS number_of_homes
FROM housing_clean
GROUP BY city
ORDER BY number_of_homes DESC;

-- 2.2 What does the typical Sea-Tac home look like? (mean vs. median)
SELECT
    COUNT(*) AS homes_sold,
    ROUND(AVG(price), 2) AS avg_price,
    ROUND(MEDIAN(price), 2) AS median_price,
    ROUND(AVG(sqft_living), 2) AS avg_sqft,
    ROUND(MEDIAN(sqft_living), 2) AS median_sqft,
    ROUND(AVG(price_per_sqft), 2) AS avg_price_per_sqft,
    ROUND(MEDIAN(price_per_sqft), 2) AS median_price_per_sqft
FROM housing_clean;

-- 2.3 Typical home by city
SELECT
    city,
    COUNT(*) AS homes_sold,
    ROUND(MEDIAN(price), 2) AS median_price,
    ROUND(MEDIAN(price_per_sqft), 2) AS median_price_per_sqft,
    ROUND(MEDIAN(sqft_living), 2) AS median_sqft
FROM housing_clean
GROUP BY city
ORDER BY homes_sold DESC;


/* =============================================================================
   PART 3. WHAT DRIVES PRICE?
   ============================================================================= */

-- 3.1 Correlation of each home characteristic with price
SELECT
    ROUND(CORR(sqft_living, price), 3) AS sqft_corr,
    ROUND(CORR(bedrooms, price), 3) AS bedroom_corr,
    ROUND(CORR(bathrooms, price), 3) AS bathroom_corr,
    ROUND(CORR(condition, price), 3) AS condition_corr,
    ROUND(CORR(yr_built, price), 3) AS year_built_corr,
    ROUND(CORR(view, price), 3) AS view_corr,
    ROUND(CORR(waterfront, price), 3) AS waterfront_corr
FROM housing_clean
WHERE price > 0;

-- 3.2 Raw size vs. price pull (export for a scatter plot)
SELECT
    sqft_living,
    price
FROM housing_clean
WHERE price > 0
  AND sqft_living > 0;


/* =============================================================================
   PART 4. LOCATION & VALUE ANALYSIS
   ============================================================================= */

-- 4.1 Does location influence price? City ranking by median price
--     (cities with >= 20 sales only)
SELECT
    city,
    COUNT(*) AS homes_sold,
    ROUND(MEDIAN(price), 2) AS median_price,
    ROUND(MEDIAN(sqft_living), 2) AS median_sqft,
    ROUND(MEDIAN(price_per_sqft), 2) AS median_price_per_sqft
FROM housing_clean
GROUP BY city
HAVING COUNT(*) >= 20
ORDER BY median_price DESC;

-- 4.2 Which cities offer the best value? Lowest price per sqft first
WITH city_stats AS (
    SELECT
        city,
        COUNT(*) AS homes_sold,
        MEDIAN(price) AS median_price,
        MEDIAN(sqft_living) AS median_sqft,
        MEDIAN(price_per_sqft) AS median_price_per_sqft
    FROM housing_clean
    GROUP BY city
    HAVING COUNT(*) >= 20
)
SELECT *
FROM city_stats
ORDER BY median_price_per_sqft ASC;

-- 4.3 Shortlist: the best-value cities identified in 4.2
--     (Auburn, Federal Way, Covington, Kent). Are they also reasonable
--     in terms of home size?
WITH city_stats AS (
    SELECT
        city,
        COUNT(*) AS homes_sold,
        MEDIAN(price) AS median_price,
        MEDIAN(sqft_living) AS median_sqft,
        MEDIAN(price_per_sqft) AS median_price_per_sqft
    FROM housing_clean
    GROUP BY city
    HAVING COUNT(*) >= 20
)
SELECT *
FROM city_stats
WHERE city IN ('Auburn', 'Federal Way', 'Covington', 'Kent')
ORDER BY median_price_per_sqft ASC;

-- 4.4 Benchmark the shortlist against Seattle
WITH city_stats AS (
    SELECT
        city,
        COUNT(*) AS homes_sold,
        MEDIAN(price) AS median_price,
        MEDIAN(sqft_living) AS median_sqft,
        MEDIAN(price_per_sqft) AS median_price_per_sqft
    FROM housing_clean
    GROUP BY city
    HAVING COUNT(*) >= 20
)
SELECT *
FROM city_stats
WHERE city IN ('Seattle', 'Auburn', 'Federal Way', 'Covington', 'Kent')
ORDER BY median_price_per_sqft ASC;

-- 4.5 Quantify the Seattle premium (% above each comparison city)
--     Positive % = Seattle costs that much more than the comparison city.
WITH city_stats AS (
    SELECT
        city,
        MEDIAN(price) AS median_price,
        MEDIAN(sqft_living) AS median_sqft,
        MEDIAN(price_per_sqft) AS median_price_per_sqft
    FROM housing_clean
    GROUP BY city
    HAVING COUNT(*) >= 20
),
seattle AS (
    SELECT
        median_price AS seattle_price,
        median_sqft AS seattle_sqft,
        median_price_per_sqft AS seattle_price_per_sqft
    FROM city_stats
    WHERE city = 'Seattle'
)
SELECT
    c.city,
    ROUND(c.median_price, 2) AS median_price,
    ROUND(((s.seattle_price - c.median_price) / c.median_price) * 100, 2) AS seattle_price_premium_pct,
    ROUND(c.median_price_per_sqft, 2) AS median_price_per_sqft,
    ROUND(((s.seattle_price_per_sqft - c.median_price_per_sqft) / c.median_price_per_sqft) * 100, 2) AS seattle_ppsf_premium_pct,
    ROUND(c.median_sqft, 2) AS median_sqft,
    ROUND(s.seattle_sqft - c.median_sqft, 2) AS seattle_sqft_difference
FROM city_stats c
CROSS JOIN seattle s
WHERE c.city IN ('Auburn', 'Federal Way', 'Covington', 'Kent')
ORDER BY seattle_price_premium_pct DESC;


/* =============================================================================
   PART 5. INSIDE SEATTLE: WHICH FEATURES COMMAND A PREMIUM?
   NOTE: Check homes_sold in each group. Small groups (e.g. waterfront) mean
   the medians are less reliable and should be flagged in the write-up.
   ============================================================================= */

-- 5.1 Waterfront vs. non-waterfront (waterfront: 1 = yes, 0 = no)
SELECT
    waterfront,
    COUNT(*) AS homes_sold,
    ROUND(MEDIAN(price), 2) AS median_price,
    ROUND(MEDIAN(sqft_living), 2) AS median_sqft,
    ROUND(MEDIAN(price_per_sqft), 2) AS median_price_per_sqft
FROM housing_clean
WHERE city = 'Seattle'
GROUP BY waterfront
ORDER BY waterfront;

-- 5.2 View rating and condition rating
SELECT
    view,
    COUNT(*) AS homes_sold,
    ROUND(MEDIAN(price), 2) AS median_price,
    ROUND(MEDIAN(price_per_sqft), 2) AS median_price_per_sqft,
    ROUND(MEDIAN(sqft_living), 2) AS median_sqft
FROM housing_clean
WHERE city = 'Seattle'
GROUP BY view
ORDER BY view;

SELECT
    condition,
    COUNT(*) AS homes_sold,
    ROUND(MEDIAN(price), 2) AS median_price,
    ROUND(MEDIAN(price_per_sqft), 2) AS median_price_per_sqft
FROM housing_clean
WHERE city = 'Seattle'
GROUP BY condition
ORDER BY condition;

-- 5.3 Renovated vs. not renovated
SELECT
    CASE
        WHEN yr_renovated = 0 THEN 'Not Renovated'
        ELSE 'Renovated'
    END AS renovation_status,
    COUNT(*) AS homes_sold,
    ROUND(MEDIAN(price), 2) AS median_price,
    ROUND(MEDIAN(price_per_sqft), 2) AS median_price_per_sqft,
    ROUND(MEDIAN(sqft_living), 2) AS median_sqft
FROM housing_clean
WHERE city = 'Seattle'
GROUP BY renovation_status
ORDER BY median_price DESC;

-- 5.4 Premium summary: waterfront and renovation, as % over the baseline
WITH waterfront_stats AS (
    SELECT
        waterfront,
        MEDIAN(price) AS median_price,
        MEDIAN(price_per_sqft) AS median_price_per_sqft
    FROM housing_clean
    WHERE city = 'Seattle'
    GROUP BY waterfront
)
SELECT
    'Waterfront' AS feature,
    ROUND((MAX(CASE WHEN waterfront = 1 THEN median_price END) - MAX(CASE WHEN waterfront = 0 THEN median_price END)) / MAX(CASE WHEN waterfront = 0 THEN median_price END) * 100, 2) AS price_premium_pct,
    ROUND((MAX(CASE WHEN waterfront = 1 THEN median_price_per_sqft END) - MAX(CASE WHEN waterfront = 0 THEN median_price_per_sqft END)) / MAX(CASE WHEN waterfront = 0 THEN median_price_per_sqft END) * 100, 2) AS ppsf_premium_pct
FROM waterfront_stats;

WITH renovation_stats AS (
    SELECT
        CASE WHEN yr_renovated = 0 THEN 'Not Renovated' ELSE 'Renovated' END AS renovation_status,
        MEDIAN(price) AS median_price,
        MEDIAN(price_per_sqft) AS median_price_per_sqft
    FROM housing_clean
    WHERE city = 'Seattle'
    GROUP BY renovation_status
)
SELECT
    'Renovated' AS feature,
    ROUND((MAX(CASE WHEN renovation_status = 'Renovated' THEN median_price END) - MAX(CASE WHEN renovation_status = 'Not Renovated' THEN median_price END)) / MAX(CASE WHEN renovation_status = 'Not Renovated' THEN median_price END) * 100, 2) AS price_premium_pct,
    ROUND((MAX(CASE WHEN renovation_status = 'Renovated' THEN median_price_per_sqft END) - MAX(CASE WHEN renovation_status = 'Not Renovated' THEN median_price_per_sqft END)) / MAX(CASE WHEN renovation_status = 'Not Renovated' THEN median_price_per_sqft END) * 100, 2) AS ppsf_premium_pct
FROM renovation_stats;


/* =============================================================================
   PART 6. IS THE SEATTLE PREMIUM JUST A SIZE EFFECT?
   Compare Seattle with the four value cities within the same size band.
   ============================================================================= */

-- 6.1 Median price and price per sqft by size band: Seattle vs. value cities
SELECT
    CASE
        WHEN sqft_living < 1200 THEN '1: <1,200'
        WHEN sqft_living < 1600 THEN '2: 1,200-1,599'
        WHEN sqft_living < 2000 THEN '3: 1,600-1,999'
        WHEN sqft_living < 2500 THEN '4: 2,000-2,499'
        WHEN sqft_living < 3000 THEN '5: 2,500-2,999'
        ELSE '6: 3,000+'
    END AS size_band,
    CASE WHEN city = 'Seattle' THEN 'Seattle' ELSE 'Value cities' END AS market,
    COUNT(*) AS homes_sold,
    ROUND(MEDIAN(price), 0) AS median_price,
    ROUND(MEDIAN(price_per_sqft), 2) AS median_price_per_sqft
FROM housing_clean
WHERE city IN ('Seattle', 'Auburn', 'Federal Way', 'Covington', 'Kent')
GROUP BY size_band, market
ORDER BY size_band, market;

-- 6.2 Do Seattle homes differ in age, view, and lot size from the value cities?
SELECT
    CASE WHEN city = 'Seattle' THEN 'Seattle' ELSE 'Value cities' END AS market,
    COUNT(*) AS homes_sold,
    MEDIAN(yr_built) AS median_year_built,
    ROUND(AVG(view), 2) AS avg_view_rating,
    MEDIAN(sqft_lot) AS median_lot_sqft,
    ROUND(AVG(condition), 2) AS avg_condition
FROM housing_clean
WHERE city IN ('Seattle', 'Auburn', 'Federal Way', 'Covington', 'Kent')
GROUP BY market;
