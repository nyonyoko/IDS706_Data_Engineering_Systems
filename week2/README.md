[![Python Template for IDS706](https://github.com/nyonyoko/IDS706_Data_Engineering_Systems/actions/workflows/main.yml/badge.svg)](https://github.com/nyonyoko/IDS706_Data_Engineering_Systems/actions/workflows/main.yml)

# IDS 706 – Week 2: Your First Data Analysis

This folder contains the Week 2 assignment for **Data Engineering Systems (IDS 706)**.  
The task was to perform an end-to-end exploratory and modeling workflow on the **Connect-4 dataset** (OpenML ID: 40668).

The notebook was first implemented using **pandas** and later re-implemented using **Polars** to highlight the similarities and differences between the two data-processing libraries.

---

## Dataset

- **Source:** [OpenML Connect-4 dataset](https://www.openml.org/d/40668)
- **Shape:** 67,557 rows × 42 columns (board positions `a1 ... g6`)
- **Values:**
  - `0`: Blank
  - `1`: Taken by Player 1
  - `2`: Taken by Player 2
- **Target:** `class` (game outcome: Win / Loss / Draw)

---

## Analysis Workflow (Pandas Notebook)

### 1. Import the Dataset

- Loaded the Connect-4 dataset from OpenML.
- Created `X` (features) and `y` (target variable).

### 2. Inspect the Data

- `.head()` for a first look at the board states.
- `.shape` to confirm dimensions.

### 3. Dataset Properties

- Counted instances, features, classes.
- Distinguished categorical vs. numerical features.
- Plotted class distribution to check for imbalance.

### 4. Exploratory Data Analysis (EDA)

- `.info()` and `.describe()` to understand data types and summary statistics.
- Checked for missing values and duplicate rows.

### 5. Basic Filtering and Grouping

- **Filter:** Subset games where Player 1 controls the center (`d3=1` and `d4=1`).
- **Groupby:** Compared outcome distributions when Player 1 controlled vs. did not control the center.
  - Player 1 wins ~81% of games when holding the center, versus ~24% otherwise.
- Highlighted the importance of center control in Connect-4.

### 6. Machine Learning Models

- Split into training/testing sets.
- Trained:
  - Decision Tree
  - Gradient Boosting Classifier
- Collected accuracy and training time across different training-set percentages.

### 7. Visualization

- Class distribution bar plot.
- Learning curve: accuracy vs. training data percentage.
- Training time comparisons.
- Outcome distribution plots for center control vs. not.

### 8. Summary

- Gradient Boosting consistently outperformed Decision Tree in accuracy, though with higher training time.
- Decision Tree accuracy improved with more data.
- Confirmed strong predictive importance of controlling the center column.

---

## Analysis Workflow (Polars Notebook)

The same workflow was repeated using **Polars** for data manipulation.

### Key Steps

1. **Conversion:** Loaded OpenML dataset with pandas, then converted `X` and `y` into Polars DataFrames/Series.
2. **EDA:** Used Polars equivalents:
   - `.schema` for data types.
   - `.describe()` for summary statistics.
   - `.null_count()` for missing values.
   - `.is_duplicated().sum()` for duplicates.
3. **Filtering:**

   ```python
   X_pl.filter((pl.col("d3") == 1) & (pl.col("d4") == 1))
   ```

4. **Grouping:**

   ```python
   df.group_by("class").agg(pl.len())
   ```

   Calculated counts and proportions of outcomes.

5. **Conversion for Modeling:**

   Since scikit-learn expects pandas/numpy, converted back using:

   ```python
   X_pd = X_pl.to_pandas()
   y_pd = y_pl.to_pandas()
   ```

6. **Modeling & Visualization:**

   Re-used the same ML and plotting code.

## Pandas vs. Polars: Key Differences

### Conceptual Differences

- **Execution model**: Pandas executes eagerly row-by-row in Python; Polars uses a Rust engine with vectorized operations and can run in lazy mode for query optimization.
- **Syntax style**: Pandas is method-chaining & indexing heavy; Polars emphasizes **expression-based queries** (`pl.col(...)` inside `filter`, `select`, `with_columns`).
- **Performance**: Polars is faster for large datasets and memory-efficient, especially with lazy execution.
- **Missing values**: Pandas uses `NaN`; Polars uses `Null`, and functions handle them explicitly.
- **Type strictness**: Polars enforces stricter types. In the pandas notebook, comparisons were made to string values (`"1"`) because OpenML returned them as strings. In the Polars notebook, columns were automatically or explicitly cast to numeric, so comparisons used integers (`1`).

## Conclusion

This assignment demonstrated a complete exploratory + modeling workflow on the Connect-4 dataset:

- Basic EDA, filtering, grouping, and visualization.
- Training Decision Tree vs. Gradient Boosting.
- Showed how strategic board positions (center control) affect outcomes.

It also compared **pandas** and **Polars**, highlighting how Polars provides a more modern, faster, and expression-driven API, while still interoperating easily with pandas/scikit-learn for modeling.
