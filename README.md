# Seattle-Area Housing Market Analysis

**Business question:** Where do buyers get the best value in the Seattle area, and is the Seattle price premium justified?

**Tools:** SQL (DuckDB), DBeaver  |  **Skills shown:** CTEs, aggregations, medians, correlation, CASE logic, data quality checks

---

## Summary of Findings

> Fill in the bracketed values from your query results.

1. **Seattle carries a significant premium.** Seattle's median price is **[X]%** higher than Kent, **[X]%** than Auburn, **[X]%** than Federal Way, and **[X]%** than Covington (query 4.5). On a per-square-foot basis the premium is **[X]%** to **[X]%**.
2. **Best-value markets:** **[City]** has the lowest median price per sqft (**$[X]**) while offering a median home size of **[X] sqft**, compared with **[X] sqft** in Seattle (queries 4.2 - 4.4).
3. **Size is the strongest driver of price.** The correlation between `sqft_living` and price is **[X]**, ahead of **[next factor]** at **[X]** (query 3.1).
4. **Inside Seattle, waterfront and renovation carry a premium.** Waterfront homes sell for **[X]%** more at the median; renovated homes for **[X]%** more (query 5.4).

**Recommendation:** A buyer prioritizing space and price per sqft should look at **[City]** first. A buyer who values Seattle's location should expect to pay roughly **[X]%** more for comparable-size homes.

---

## Dataset

- **Source:** [Link to dataset, e.g. Kaggle King County House Sales]
- **Size:** [X] home sales across [X] cities, from [earliest date] to [latest date]
- **Key fields:** price, bedrooms, bathrooms, sqft_living, price_per_sqft, city, yr_built, yr_renovated, waterfront, view, condition

## Approach

1. **Data quality checks:** missing values, min/max ranges, and suspicious values.
2. **Market overview:** sales volume and typical home by city.
3. **Price drivers:** correlation of home features with price.
4. **Location and value analysis:** city rankings, best-value shortlist, and Seattle premium calculation.
5. **Seattle deep dive:** waterfront, view, condition, and renovation premiums.

### Key methodology decisions

| Decision | Reason |
|---|---|
| Used **median** instead of mean | Housing prices are right-skewed; luxury sales inflate averages |
| Required **>= 20 sales per city** | Prevents tiny samples from distorting rankings |
| Treated `yr_renovated = 0` as "not renovated" | Zero is a placeholder for homes never renovated |
| Used **price per sqft** alongside price | Controls for home size when comparing cities |

## Limitations

- Data covers a single time period and may not reflect current market conditions.
- Comparisons are descriptive. Differences in price may also reflect factors not controlled for, such as lot size, school districts, or neighborhood within a city.
- Waterfront sample sizes are small, so those medians are less reliable.
- Waterfront, view, and renovation effects overlap with home size and location.

## How to Reproduce

1. Load the dataset into DuckDB as a table named `housing_data`.
2. Open `seattle_housing_analysis.sql` in DBeaver (or any SQL client).
3. Run each section in order. Each query ends with a semicolon.

## Files

- `seattle_housing_analysis.sql`: full commented analysis script
- `README.md`: this file
- `/charts`: visualizations (add yours here)

