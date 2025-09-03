
````markdown
# IDS 706 – Week 1: Python Template

This folder contains the Week 1 assignment for **Data Engineering Systems (IDS 706)**.  
It demonstrates a minimal Python project with formatting, linting, tests, and CI automation.

## What’s in here
- `hello.py` – simple example functions (`say_hello`, `add`)
- `test_hello.py` – unit tests with `pytest`
- `Makefile` – handy commands for install/format/lint/test/clean
- `requirements.txt` – Python dependencies for local/devcontainer/CI
- (This) `README.md` – setup, usage, and examples

> Repo-level configs like `.devcontainer/` and `.github/workflows/` live at the repository root.

---

## Quickstart

### A) Using the Dev Container (recommended)
1. Open the repository in VS Code.
2. Reopen in container (`Command+Shift+P` → *Dev Containers: Reopen in Container*).
3. From the repo root, run:
   ```bash
   make -C week1 install
   make -C week1 test
````

Or `cd week1` and run `make install`, `make test`.

### B) Local setup (no container)

1. (Optional) Create a virtual environment:

   ```bash
   python3 -m venv .venv
   source .venv/bin/activate   # macOS/Linux
   # .venv\Scripts\activate    # Windows PowerShell
   ```
2. Install deps and run tests:

   ```bash
   cd week1
   make install
   make test
   ```

---

## Makefile commands

From `week1/`:

```bash
make install   # upgrade pip, install dependencies
make format    # format code with black
make lint      # static checks with flake8
make test      # run pytest with coverage
make clean     # remove caches/coverage files
make           # same as `make all` if configured
```

From repo root (without cd):

```bash
make -C week1 install
make -C week1 test
```

---

## Usage examples

### 1) Import and call functions in Python

```python
from hello import say_hello, add

print(say_hello("Annie"))
# -> "Hello, Annie, welcome to Data Engineering Systems (IDS 706)!"

print(add(2, 3))
# -> 5
```

### 2) Run tests

```bash
pytest -q        # or: make test
```

### 3) Format & lint

```bash
make format
make lint
```

---

## Continuous Integration (CI)

A GitHub Actions workflow (at the repo root, under `.github/workflows/`) runs on every push/PR.
It installs dependencies, lints (`flake8`), checks formatting (`black --check`), and runs tests (`pytest`) **in this `week1/` folder**.

> If your workflow file runs from the repository root, set `working-directory: ./week1` or add a root `Makefile` that forwards to `week1`.

---

## Troubleshooting

* **`flake8: command not found` or `pytest: command not found`**
  Run `make install` (or ensure `postCreateCommand` ran in the dev container).
* **CI can’t find files**
  Confirm the workflow’s `working-directory: ./week1` or use a root Makefile that forwards to `week1`.
* **Tabs vs spaces in Makefile**
  Make recipes must be indented with a **tab**, not spaces.

---

## License

Educational template for IDS 706 coursework.

```
```
