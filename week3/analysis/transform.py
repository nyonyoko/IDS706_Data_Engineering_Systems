from __future__ import annotations
import operator
import pandas as pd
import polars as pl

_OPS = {
    "==": operator.eq,
    "!=": operator.ne,
    ">": operator.gt,
    ">=": operator.ge,
    "<": operator.lt,
    "<=": operator.le,
}


def filter_rows(df, col: str, op: str, value, engine: str = "pandas"):
    """Filter rows by comparison on a column."""
    if op not in _OPS:
        raise ValueError(f"Unsupported op {op}")
    cmp = _OPS[op]

    if engine == "pandas":
        if not isinstance(df, pd.DataFrame):
            raise TypeError("Expected pandas DataFrame for engine='pandas'")
        return df[cmp(df[col], value)]
    elif engine == "polars":
        if not isinstance(df, pl.DataFrame):
            raise TypeError("Expected polars DataFrame for engine='polars'")
        return df.filter(cmp(pl.col(col), value))
    else:
        raise ValueError("engine must be 'pandas' or 'polars'")


def groupby_agg(df, by: str, agg_col: str, agg: str = "sum", engine: str = "pandas"):
    """Group by a column and aggregate another column."""
    if engine == "pandas":
        if not isinstance(df, pd.DataFrame):
            raise TypeError("Expected pandas DataFrame")
        if agg == "sum":
            out = df.groupby(by, as_index=False)[agg_col].sum()
        elif agg == "mean":
            out = df.groupby(by, as_index=False)[agg_col].mean()
        else:
            raise ValueError("agg must be 'sum' or 'mean'")
        return out
    elif engine == "polars":
        if not isinstance(df, pl.DataFrame):
            raise TypeError("Expected polars DataFrame")
        if agg == "sum":
            out = df.group_by(by).agg(pl.col(agg_col).sum()).sort(by)
        elif agg == "mean":
            out = df.group_by(by).agg(pl.col(agg_col).mean()).sort(by)
        else:
            raise ValueError("agg must be 'sum' or 'mean'")
        return out
    else:
        raise ValueError("engine must be 'pandas' or 'polars'")


def to_pandas(df):
    """Convert polars -> pandas (no-op if already pandas)."""
    if isinstance(df, pd.DataFrame):
        return df
    if isinstance(df, pl.DataFrame):
        return df.to_pandas()
    raise TypeError("df must be pandas or polars DataFrame")
