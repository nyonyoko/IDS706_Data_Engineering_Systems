from __future__ import annotations
import pandas as pd
from sklearn.compose import ColumnTransformer
from sklearn.impute import SimpleImputer
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from sklearn.pipeline import Pipeline
from sklearn.metrics import accuracy_score


def build_preprocessor(numeric_features: list[str]):
    """Impute missing values and scale numeric columns."""
    transformer = ColumnTransformer(
        transformers=[
            (
                "num",
                Pipeline(
                    [
                        ("imputer", SimpleImputer(strategy="mean")),
                        ("scaler", StandardScaler()),
                    ]
                ),
                numeric_features,
            )
        ],
        remainder="drop",
    )
    return transformer


def train_logreg(X: pd.DataFrame, y, random_state: int = 42):
    """Train a simple logistic regression classifier."""
    model = LogisticRegression(max_iter=1000, random_state=random_state)
    model.fit(X, y)
    return model


def evaluate_accuracy(model, X, y) -> float:
    """Return accuracy on provided data."""
    preds = model.predict(X)
    return float(accuracy_score(y, preds))
