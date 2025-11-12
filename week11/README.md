[![Python Template for IDS706](https://github.com/nyonyoko/IDS706_Data_Engineering_Systems/actions/workflows/main.yml/badge.svg)](https://github.com/nyonyoko/IDS706_Data_Engineering_Systems/actions/workflows/main.yml)

# IDS 706 – Week 11: NYC Taxi PySpark Data Pipeline

This assignment uses the **NYC Taxi & Limousine Commission (TLC) Trip Record Data**, a large-scale open dataset that contains detailed information about yellow taxi trips in New York City.

## Dataset Description and Source

Each record includes pickup/dropoff times, trip distances, fares, tips, passenger counts, and payment types.

- **Source:** `/databricks-datasets/nyctaxi/tripdata/yellow/*.csv.gz` (Databricks public dataset)
- **Format:** Compressed CSV (`.csv.gz`)
- **Original Size:** ~40 GB compressed (~187 GB uncompressed)
- **Sample Used:** 0.75% random sample (~4 GB compressed) to ensure feasible runtime
- **Years Covered:** 2009–2010 subset (columns: `pickup_datetime`, `dropoff_datetime`, `fare_amount`, `tip_amount`, `trip_distance`, etc.)

## Performance Analysis

### Physical Execution Plan (`.explain()`)

Spark’s `.explain("formatted")` was used to examine query plans for key transformations such as:

- Zone-level aggregations (`groupBy`)
- Daily summaries (`groupBy(pickup_date)`)
- SQL queries filtering and sorting (`ORDER BY`, `LIMIT`)

The `.explain()` output revealed:

- Early **Filter pushdown** for columns like `fare_amount`, `trip_distance`, and `trip_mins`
- **Column pruning**, where Spark only scanned the selected subset of columns instead of the entire dataset
- **Exchange (Shuffle) stages** were visible in wide operations (`groupBy`, `join`), which required data movement across executors

### How Spark Optimized the Queries

Spark’s Catalyst optimizer automatically:

- **Reordered filters** to minimize scanned rows early in the DAG
- Applied **predicate pushdown**, reading only matching rows directly from the source files
- Used **projection pruning**, scanning only relevant columns needed for each computation
- Combined adjacent logical operations into a single physical stage for efficiency

### Performance Bottlenecks and Optimizations

#### Bottlenecks Identified:

- **Long initial load time (20-40 minutes)**: due to CSV decompression and schema inference
- **Wide shuffles during groupBy and joins**: incurred high network I/O
- **Large dataset size (~187 GB)** made even sampled queries take several minutes (10–40 minutes per job)

#### Optimizations Applied:

1. **Sampling (0.75%)** to reduce dataset size
2. **Filter Ordering**: Early filters for `fare_amount`, `trip_distance`, and `trip_mins` minimized row count
3. **Column Pruning**: Selected only required fields
4. **Converted to Parquet** for faster reloads in subsequent sessions

## Key Findings from Data Analysis

1. **Trip characteristics:** Most trips were short-distance (under 3 miles) with fares under \$20.
2. **Tip behavior:** Credit card payments had the highest tip percentages (~18–20%), while cash tips were usually under 10%.
3. **Hourly patterns:** Taxi activity peaked between 6–9 PM, with slightly higher average fares during evening hours.
4. **Trip durations:** Longer trips had higher fare-to-tip ratios, indicating that short trips tended to receive better tips relative to fare.
5. **Data Quality:** Some numeric columns were stored as strings, requiring cleaning and casting.

## Machine Learning with MLlib

### Objective
To build a simple **regression model** predicting `tip_amount` based on features such as:
- `fare_amount`
- `trip_distance`
- `passenger_count`
- `pickup_hour`
- `payment_type`

### Model Configuration
- **Algorithm:** Linear Regression (`pyspark.ml.regression.LinearRegression`)  
- **Preprocessing:**
  - Encoded categorical variables (`payment_type`)
  - Standardized numeric features with `StandardScaler`
  - Assembled all predictors into a feature vector (`VectorAssembler`)
- **Data Split:** 80% train, 20% test
- **Evaluation Metrics:** RMSE, MAE, and R² using `RegressionEvaluator`

### Results
| Metric | Value |
|---------|--------|
| RMSE | 1.424 |
| MAE | 0.878 |
| R² | 0.357 |

### Interpretation
- The **R² score (~0.36)** indicates the model explains around **36% of the variance** in tip amount — a reasonable baseline for this noisy dataset.  
- **RMSE ≈ 1.42** means the model’s predictions differ from actual tips by about \$1.42 on average.  
- Taxi tip behavior depends on many unobserved factors (customer generosity, trip location, driver attitude, rounding habits), so perfect prediction isn’t realistic.  
- Despite modest accuracy, the model correctly captures general trends: higher fares and longer trips correlate with larger tips.

### Potential Improvements
- Try **tree-based regressors** like `GBTRegressor` or `RandomForestRegressor`  
- Engineer features like `hour_of_day`, `day_of_week`, or `trip_duration`  
- Remove outliers (extremely long or short trips)  
- Train on newer (2015+) taxi data with cleaner schema (`tpep_pickup_datetime`)

## Visualization and Results

### 1. Query Execution Plan (`.explain()` output or Spark UI)

![Query Execution Plan](assets/query_execution_explain.png)

### 2. Databricks Query Details View (Optimization Summary)

![Query Details View](assets/optimization.png)

### 3. Successful Pipeline Execution

![Pipeline Execution 1](assets/successful_pipeline_execution1.png)
![Pipeline Execution 2](assets/successful_pipeline_execution2.png)
![Pipeline Execution 3](assets/successful_pipeline_execution3.png)
![Pipeline Execution 4](assets/successful_pipeline_execution4.png)
![Pipeline Execution 5](assets/successful_pipeline_execution5.png)
![Pipeline Execution 6](assets/successful_pipeline_execution6.png)
![Pipeline Execution 7](assets/successful_pipeline_execution7.png)
![Pipeline Execution 8](assets/successful_pipeline_execution8.png)
![Pipeline Execution 9](assets/successful_pipeline_execution9.png)
![Pipeline Execution 10](assets/successful_pipeline_execution10.png)
![Pipeline Execution 11](assets/successful_pipeline_execution11.png)
![Pipeline Execution 12](assets/successful_pipeline_execution12.png)
![Pipeline Execution 13](assets/successful_pipeline_execution13.png)
![Pipeline Execution 14](assets/successful_pipeline_execution14.png)
![Pipeline Execution 15](assets/successful_pipeline_execution15.png)
![Pipeline Execution 16](assets/successful_pipeline_execution16.png)

## References

- NYC TLC Data: [https://www1.nyc.gov/site/tlc/about/tlc-trip-record-data.page](https://www1.nyc.gov/site/tlc/about/tlc-trip-record-data.page)
- Databricks Public Datasets: [https://docs.databricks.com/en/data/databricks-datasets.html](https://docs.databricks.com/en/data/databricks-datasets.html)
- Apache Spark Documentation: [https://spark.apache.org/docs/latest/sql-performance-tuning.html](https://spark.apache.org/docs/latest/sql-performance-tuning.html)

## Notes

- All code was developed and executed in **Databricks (Community Edition)** using **PySpark**.
- The dataset exceeded 40 GB compressed; due to hardware limitations, a 0.75% random sample was used for analysis.
- Total runtime for full notebook: ~2.5 hours (including the machine learning part).
- MLlib model successfully trained and evaluated (results above).
