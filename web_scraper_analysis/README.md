# Properties on Sale in Santander - Colombia

The purpose of this project is to extract some insights into the Properties Market Prices in Santander - Colombia.

- Scraped over 1700 descriptions of properties on sale from Mercado Libre using Python and BeatifulSoup.
- Cleaned, Transformed and Extracted data from the text of each property description using Pandas, and csv.
- Data Exploration and visualization. Matplotlib and seaborn.


**Python Version**: 3.9.7
**Packages**: Numpy, Pandas, csv, BeautifulSoup, Requests, Matplotlib, Seaborn

## Web Scraping
For each property we obtained the following fields: 
- Property_type
- Description
- Location
- Price
- Features

## Data cleaning, Transformation, Imputation

- Removed undesired characters and substrings in column Property_Type
- Parsed numeric fields.
- Extracted Area and Rooms from Features.
- Extracted City_name and Address from Location.
- Added a new column for Price per square meter.
- Filled missing data with median and mode values.

## Exploratory Data Analysis (EDA)
I looked at the distributions of the data. The three features exhibit a right-skewed distribution since ```Mean > Median > Mode```
<img src="https://github.com/camm93/data_science/blob/main/web_scraper_analysis/dist_mult_features.png" alt="Distributions of Numeric Features"></img>

Created several char types to showcase different information. Below a few of them:
<img src="https://github.com/camm93/data_science/blob/main/web_scraper_analysis/nPropTypeCityRooms.png" alt="Number of Properties per Type, City and Rooms"></img>

The point size and its annotation indicate the number of properties per subcategory. Similarly, the color reflects the median number of rooms, for example:
- The plot indicates that Bucaramanga is the city with the largest number of properties on sale. Also, 521 out of the 793 properties are apartments with a median number of rooms of 3.
- In Piedecuesta, 55 houses "casas" are on sale, and their median number of rooms is 4.

<img src="https://github.com/camm93/data_science/blob/main/web_scraper_analysis/priceCityType.png" alt="Distributions of Price per City and Property Type"></img>
