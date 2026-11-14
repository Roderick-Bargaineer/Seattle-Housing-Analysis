# Seattle-Area Housing Market Analysis

> **Business question:** Where do buyers get the best value in the Seattle area, and is the Seattle price premium justified?

A SQL-driven analysis of 4,551 King County home sales (May 2 – July 10, 2014) across 44 cities. It compares Seattle with lower-cost cities on price, home size, and price per square foot, then tests whether Seattle's premium is explained by size alone.

**Tools:** SQL (DuckDB, DBeaver), Tableau Public
**Skills demonstrated:** CTEs, medians and aggregations, correlation, CASE logic, data-quality checks, size-band cohort comparison, business writing

> **Note on timing:** This is a 2014 snapshot. Dollar figures are historical and should not be read as current market prices. The method (and the finding that a premium persists after controlling for size) is the transferable part. See [Limitations](#limitations) and [Next Steps](#next-steps).

---

## Executive Summary

**Answer:** Auburn, Federal Way, Kent, and Covington offer the best value per square foot. Seattle's premium is **not** explained by home size: Seattle homes are smaller yet cost far more per square foot, so the premium reflects location and neighborhood factors that this dataset captures only partly.

| Median | Seattle | Auburn / Federal Way / Kent |
|---|---|---|
| Price per sqft | $313 | $144 – $151 (range across the four value cities) |
| Home size | 1,651 sqft | about 1,900 sqft |
| Typical price | $490,000 | about $265,000 – $284,000 |

### Key findings

1. **The Seattle premium is large.** Seattle's median price is 73% above Kent, 78% above Auburn, 85% above Federal Way, and 96% above Covington. On a per-square-foot basis the premium ranges from 107% to 117%.
2. **It is not a size effect.** Within the same size band, Seattle still costs more, and the gap widens as homes get bigger:

   | Size band | Seattle premium vs. value cities |
   |---|---|
   | Under 1,200 sqft | about +71% |
   | 2,000 – 2,499 sqft | about +98% |
   | 3,000+ sqft | about +150% |

3. **Size is the strongest single price driver.** Correlation with price: square footage 0.45, bathrooms 0.34, view 0.24, bedrooms 0.21, waterfront 0.15. Condition (0.04) and year built (0.02) are nearly irrelevant on their own.
4. **Seattle homes differ in what you get.** They are older (median built 1946 vs. 1983), sit on smaller lots (5,000 vs. 8,400 sqft), and have better views than homes in the value cities.
5. **Inside Seattle, views and condition carry a premium; renovation does not.** Top-view homes sell for about 168% more than homes with no view, and condition-5 homes for about 41% more than condition-3. Renovated homes show no premium, but they are likely older and smaller, so this is not evidence that renovation lowers value.
6. **Waterfront is anecdotal.** The 4 Seattle waterfront sales (median $1.43M) are too few to support a conclusion.

### Recommendation

- **Buyer prioritizing space and value:** focus on Kent, Auburn, or Federal Way, which offer about 1,900 sqft at roughly half of Seattle's price.
- **Buyer who wants Seattle:** expect to pay about twice as much per square foot for a smaller, older home on a smaller lot, in exchange for location and views.
- **Closest like-for-like comparison:** Covington offers a similar 1,650 sqft home for about half the price.

Full write-up: [CONCLUSION.md](docs/CONCLUSION.md)

---

## Dashboard and Charts

**Interactive dashboard:** <ADD TABLEAU PUBLIC LINK>

| | |
|---|---|
| ![Price per sqft by city](charts/01_price_per_sqft_by_city.png) | ![Size vs value](charts/02_size_vs_price_per_sqft.png) |
| ![Premium by size band](charts/03_premium_by_size_band.png) | ![Seattle premium](charts/04_seattle_premium_by_city.png) |

---

## Dataset

- **Source:** https://www.kaggle.com/datasets/debayank2024/house-price-prediction
- **Size:** 4,600 records, of which 4,551 are valid sales, across 44 cities
- **Period:** May 2 – July 10, 2014
- **Preparation:** 49 rows with `price = 0` (placeholders, not real sales) were removed through the `housing_clean` view.

| Field | Description |
|---|---|
| `date` | Sale date |
| `price` | Sale price (USD) |
| `bedrooms`, `bathrooms` | Counts |
| `sqft_living`, `sqft_lot` | Interior living area and lot size (sq ft) |
| `price_per_sqft` | Sale price divided by `sqft_living` (derived) |
| `yr_built`, `yr_renovated` | Year built; year renovated (0 = never renovated) |
| `waterfront` | 1 = waterfront, 0 = not |
| `view` | View rating (0 = none, higher = better) |
| `condition` | Condition rating (1 – 5) |
| `city`, `statezip` | Location |

---

## Methodology

1. **Data quality checks:** missing values, min/max ranges, and suspicious values.
2. **Market overview:** sales volume and typical home by city.
3. **Price drivers:** correlation of home features with price.
4. **Location and value:** city rankings, best-value shortlist, and Seattle premium calculation.
5. **Seattle deep dive:** waterfront, view, condition, and renovation premiums.
6. **Size test:** Seattle vs. value cities within the same size band.

| Decision | Reason |
|---|---|
| Used **median**, not mean | Housing prices are right-skewed; luxury sales inflate averages |
| Required **20+ sales per city** | Prevents tiny samples from distorting rankings |
| Treated `yr_renovated = 0` as "not renovated" | Zero is a placeholder for homes never renovated |
| Used **price per sqft** alongside price | Controls for home size when comparing cities |
| Compared within **size bands** | Tests whether the premium is only a size effect |

---

## Repository Structure

```
Seattle-Housing-Analysis/
├── README.md
├── data/
│   ├── raw/                  # original dataset, unmodified
│   └── processed/            # cleaned CSV used for analysis and Tableau
├── sql/
│   └── seattle_housing_analysis.sql
├── charts/                   # exported dashboard images
├── docs/
│   └── CONCLUSION.md         # detailed findings
├── LICENSE
└── .gitignore
```

---

## How to Reproduce

1. Install [DuckDB](https://duckdb.org/docs/installation/) (and optionally [DBeaver](https://dbeaver.io/)).
2. Clone the repo:
   ```bash
   git clone https://github.com/Roderick-Bargaineer/Seattle-Housing-Analysis.git
   cd Seattle-Housing-Analysis
   ```
3. Load the data into a table named `housing_data`:
   ```sql
   CREATE TABLE housing_data AS
   SELECT * FROM read_csv_auto('data/processed/housing_data.csv');
   ```
4. Run `sql/seattle_housing_analysis.sql` section by section (each statement ends with a semicolon). Part 1 creates the `housing_clean` view used by every later part.

---

## Limitations

- **Short, old time window.** About 10 weeks in 2014 with no visible price trend, so this is a snapshot, not a current market view.
- **Descriptive, not causal.** The analysis shows Seattle costs more at the same size, not why (schools, commute, neighborhood, and so on).
- **Small samples.** Waterfront (4 Seattle sales) and top view ratings (22 sales) are too few for firm conclusions.
- **Residual data errors.** A few extreme values remain, such as a $26.6M sale of a 1,180 sqft home in Kent. Medians limit their effect, but they are likely data errors.
- **Rough renovation flag.** `yr_renovated = 0` ignores the size and recency of renovations.
- **Comparison set.** The value cities were chosen as the lowest price per sqft, which can overstate the premium relative to a region-wide baseline.

---

## Next Steps

- [ ] Add a region-wide baseline and include Bellevue, Kirkland, and Redmond in the comparison
- [ ] Apply a documented outlier rule and report its impact on the results
- [ ] Fit a hedonic regression (log price on size, lot, age, view, condition, city) to separate location from home features, and add it to the repo
- [ ] Add bootstrap confidence intervals around the headline premiums
- [ ] Add affordability metrics: monthly mortgage payment and price-to-income by city
- [ ] Benchmark against current market data (for example Zillow, Redfin, or FRED)

---

## Author

**Roderick Bargaineer**, aspiring financial analyst
GitHub: [Roderick-Bargaineer](https://github.com/Roderick-Bargaineer) | LinkedIn: https://www.linkedin.com/in/roderick-bargaineer-2b8291111/
