import numpy as np
import pandas as pd
from analysis.ml import build_preprocessor, train_logreg, evaluate_accuracy


def test_build_preprocessor_and_fit():
    X = pd.DataFrame({"f1": [1.0, 2.0, None, 4.0], "f2": [10.0, 9.0, 8.0, None]})
    pre = build_preprocessor(["f1", "f2"])
    Xt = pre.fit_transform(X)
    # imputed + scaled numeric, so 2 columns remain
    assert Xt.shape == (4, 2)


def test_train_and_eval_logreg():
    # Linearly separable tiny set
    X = pd.DataFrame({"f": [-2, -1, 1, 2]})
    y = np.array([0, 0, 1, 1])
    model = train_logreg(X, y, random_state=42)
    acc = evaluate_accuracy(model, X, y)
    assert acc >= 0.99
