from pathlib import Path
import pandas as pd
import polars as pl
from analysis.io_utils import load_csv


def test_load_csv_pandas(tmp_path: Path):
    p = tmp_path / "toy.csv"
    pd.DataFrame({"a": [1, 2], "b": [3, 4]}).to_csv(p, index=False)
    out = load_csv(p, engine="pandas")
    assert list(out.columns) == ["a", "b"]
    assert out["a"].tolist() == [1, 2]


def test_load_csv_polars(tmp_path: Path):
    p = tmp_path / "toy.csv"
    pl.DataFrame({"a": [1, 2], "b": [3, 4]}).write_csv(p)
    out = load_csv(p, engine="polars")
    assert out.columns == ["a", "b"]
    assert out["a"].to_list() == [1, 2]
