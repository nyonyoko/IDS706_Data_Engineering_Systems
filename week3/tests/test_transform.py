import pandas as pd
import polars as pl
from analysis.transform import filter_rows, groupby_agg, to_pandas


def test_filter_rows_pandas():
    df = pd.DataFrame({"x": [1, 2, 3], "y": [10, 20, 30]})
    out = filter_rows(df, "x", ">=", 2, engine="pandas")
    assert out["x"].tolist() == [2, 3]


def test_groupby_sum_polars():
    df = pl.DataFrame({"g": ["a", "a", "b"], "v": [1, 2, 5]})
    out = groupby_agg(df, by="g", agg_col="v", agg="sum", engine="polars")
    assert out.shape == (2, 2)
    # Ensure correct sums
    sums = dict(zip(out["g"].to_list(), out["v"].to_list()))
    assert sums == {"a": 3, "b": 5}


def test_to_pandas_roundtrip():
    dfp = pd.DataFrame({"z": [1, 2, 3]})
    dpp = to_pandas(dfp)
    assert dpp.equals(dfp)

    dpl = pl.DataFrame({"z": [1, 2, 3]})
    dpp2 = to_pandas(dpl)
    assert isinstance(dpp2, pd.DataFrame)
    assert dpp2["z"].tolist() == [1, 2, 3]
