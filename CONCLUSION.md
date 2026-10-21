# Conclusion: Seattle-Area Housing Analysis

*All figures are medians from 4,551 valid home sales (49 rows with price = 0 removed) across 44 cities, May 2 – July 10, 2014.*

## Answer to the business question

**Best value:** Auburn, Federal Way, Covington, and Kent offer the lowest price per square foot in the region (about $144–$151/sqft, versus $313 in Seattle). Auburn, Federal Way, and Kent also deliver larger homes, about 1,900 sqft at the median, with Seattle's median home at 1,651 sqft.

**Is the Seattle premium justified?** Not by size. Seattle homes are smaller, yet cost far more per square foot. The premium is better explained by location and neighborhood factors the dataset only partly captures, such as proximity to jobs, views, and a more established housing stock.

## Key findings

1. **The Seattle premium is large.** Seattle's median price ($490,000) is 73% above Kent, 78% above Auburn, 85% above Federal Way, and 96% above Covington. Per square foot it is 107% to 117% higher.
2. **The premium is not a size effect.** Seattle homes are about 250–290 sqft *smaller* than those in Auburn, Federal Way, and Kent, and about the same size as Covington's. When homes are compared within the same size band, Seattle still costs 71% to 151% more, and the gap widens as homes get bigger (about +71% under 1,200 sqft, about +98% at 2,000–2,500 sqft, about +150% above 3,000 sqft). A quick regression controlling for size, view, waterfront, and condition still shows Seattle roughly 90% more expensive.
3. **Size is the strongest price driver, but not the only one.** Correlation with price: square footage 0.45, bathrooms 0.34, view 0.24, bedrooms 0.21, waterfront 0.15. Condition (0.04) and year built (0.02) are nearly irrelevant on their own.
4. **Seattle homes differ in what you get.** Compared with the four value cities, Seattle homes are older (median built 1946 vs. 1983), sit on smaller lots (5,000 vs. 8,400 sqft), and have better views (average rating 0.29 vs. 0.10).
5. **Inside Seattle, views and condition carry a premium; renovation does not.** Homes with the top view rating sell for about 168% more than homes with no view. Condition 5 homes sell for about 41% more than condition 3. Renovated homes show **no premium** (median $475,000 vs. $502,100 for non-renovated, with price per sqft roughly equal). Renovated homes are likely older and smaller, so this is not evidence that renovation lowers value.
6. **Waterfront is promising but not conclusive.** Seattle waterfront homes sold for a median of $1.43M vs. $490K, but that is only **4 sales**, so it is an anecdote, not a finding.

## Recommendation

- **A buyer who wants space and value** should focus on Kent, Auburn, or Federal Way: roughly 1,900 sqft for about $265,000–$284,000.
- **A buyer who wants Seattle** should expect to pay about twice as much per square foot and accept a smaller, older home on a smaller lot in exchange for location and views.
- **Covington** is the best "same size as Seattle" comparison: a similar 1,650 sqft home for about half the price.

## Limitations

- **Short time window.** The data covers about 10 weeks in 2014 with no price trend (monthly median price per sqft stayed at $244–$247), so it is a snapshot and not a current market view.
- **Descriptive, not causal.** I can show Seattle costs more at the same size, but not *why* (school districts, commute, neighborhood, and so on).
- **Small samples** for waterfront (4 Seattle sales) and top view ratings (22 sales).
- **Data quality.** 49 sales had a price of 0 and were excluded. A few extreme values remain (for example, a $26.6M sale of a 1,180 sqft Kent home); medians limit their effect, but they likely include data errors.
- **Renovation is a rough flag.** `yr_renovated = 0` is treated as "not renovated," and it ignores renovation size and recency.

## Next steps

- Add a neighborhood- or zip-level view inside Seattle (the `statezip` column).
- Fit a fuller regression (lot size, floors, age) to separate location from home features.
- Refresh with newer sales data to test whether the premium has persisted.
