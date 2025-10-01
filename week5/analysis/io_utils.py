from __future__ import annotations
from pathlib import Path
import pandas as pd
import polars as pl


def load_csv(path: str | Path, engine: str = "pandas"):
    """Load CSV with pandas or polars."""
    path = str(path)
    if engine == "pandas":
        return pd.read_csv(path)
    elif engine == "polars":
        return pl.read_csv(path)
    else:
        raise ValueError("engine must be 'pandas' or 'polars'")
