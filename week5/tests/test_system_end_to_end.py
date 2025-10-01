from pathlib import Path
import pandas as pd
from analysis.io_utils import load_csv
from analysis.transform import filter_rows, groupby_agg
from analysis.ml import build_preprocessor, train_logreg, evaluate_accuracy


def test_end_to_end(tmp_path: Path):
    # Create small CSV
    p = tmp_path / "data.csv"
    pd.DataFrame(
        {
            "group": ["a", "a", "b", "b", "b"],
            "x": [1.0, 2.0, 3.0, None, 5.0],
            "y": [0, 0, 1, 1, 1],
        }
    ).to_csv(p, index=False)

    # Load (pandas), filter, group, preprocess, train, evaluate
    df = load_csv(p, engine="pandas")
    df_f = filter_rows(df, "x", ">=", 1.0, engine="pandas")
    agg = groupby_agg(df_f, by="group", agg_col="x", agg="mean", engine="pandas")

    # Prepare ML data from original (simple demo)
    X = df_f[["x"]]
    y = df_f["y"]
    pre = build_preprocessor(["x"])
    Xp = pre.fit_transform(X)
    assert Xp.shape[0] == len(X)

    model = train_logreg(X, y, random_state=123)
    acc = evaluate_accuracy(model, X, y)
    assert acc >= 0.5  # system sanity
    # sanity on grouped shape too
    assert set(agg.columns) == {"group", "x"}
