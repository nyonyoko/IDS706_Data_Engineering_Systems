[![Python Template for IDS706](https://github.com/nyonyoko/IDS706_Data_Engineering_Systems/actions/workflows/main.yml/badge.svg)](https://github.com/nyonyoko/IDS706_Data_Engineering_Systems/actions/workflows/main.yml)

# IDS 706 – Week 1: Python Template

This folder contains the Week 1 assignment for **Data Engineering Systems (IDS 706)**.  
It demonstrates a minimal Python project with formatting, linting, tests, and CI automation.  
This week’s Makefile also **captures test logs** to `.logs/`.

## What’s in here
- `hello.py` – example functions (`say_hello`, `add`)
- `test_hello.py` – unit tests with `pytest`
- `Makefile` – install/format/lint/test/clean + `help` target and log capture
- `requirements.txt` – Python dependencies
- `README.md` – this guide

> Repo-level configs live at the root: `.devcontainer/`, `.github/workflows/`, `.gitignore`, and a course-level `README.md`.

---

## Dev Container workflow (auto-detect changed weeks)

The dev container is configured to call the **root** Makefile so it only runs for **changed `week*/` folders** (mirrors CI).  
Typical setup in `.devcontainer/devcontainer.json`:

```json
{
  "name": "IDS706",
  "image": "mcr.microsoft.com/devcontainers/python:3.11",
  "postCreateCommand": "bash -lc 'make test-changed || true'",
  "postStartCommand":  "bash -lc 'make test-changed || true'"
}
````

* On **first create** and every **start**, the root Makefile’s `test-changed` target finds changed `week*/` folders and runs their Makefiles’ `test` targets.
* The `week1/Makefile` saves logs under `week1/.logs/pytest_<timestamp>.log`.
* No need to switch an env var week-to-week.

> **Optional manual mode:** If you ever prefer to pin to a single week, you can set an env var and use `make test-week WEEK=weekN` in devcontainer commands instead. I have commented out the line ```"containerEnv": { "WEEK_DIR": "week1" },``` in ```.devcontainer/devcontainer.json``` You can uncomment it to pin to ```week1``` for example. But with `test-changed`, that’s not necessary.

---

## Local setup (no container)

1. (Optional) create a virtual environment:

```bash
python3 -m venv .venv
source .venv/bin/activate   # macOS/Linux
# .venv\Scripts\activate    # Windows PowerShell
```

2. Install & test:

```bash
cd week1
make install
make test
```

---

## Makefile commands (week1)

The Makefile is tab-indented and uses Bash (`SHELL := /bin/bash`). Use `make help` to see docs inline.

```bash
make help         # Show available targets and descriptions
make install      # Upgrade pip and install requirements.txt (if present)
make format       # Run black .
make format-check # Run black --check .
make lint         # Run flake8 .
make test         # Run pytest with coverage; saves log under .logs/
make clean        # Remove caches and .logs/
make              # Same as `make all`: install + format + lint + test
```

### Logs

* The dev container test output is saved as log to `week1/.logs/pytest_<YYYY-MM-DD_HH-MM-SS>.log`.

---

## Root Makefile helpers (from repo root)

There are some convenience targets at the repo root:

```bash
make test-changed             # Auto-detect and test only changed week*/ dirs
make test-week WEEK=week1     # Run tests in one week dir
make all-week WEEK=week1      # install + format + lint + test in one week dir
```

These are what the dev container hooks call when auto-running on create/start.

---

## Continuous Integration (CI): **changed weeks only**

The GitHub Actions workflow (at `.github/workflows/`) auto-discovers **which `week*/` folders changed** in your push/PR and runs the pipeline **only for those** (fallback: all `week*/` if none detected).

Per changed week, CI:

* installs dependencies,
* runs `flake8` and `black --check .`,
* runs `pytest` with coverage.

You **do not** need to edit YAML each week—just add `week2/`, `week3/`, etc., and commit changes there.

---

## Adding a new week

1. Copy the `week1/` layout to `week2/`:

```
week2/
  ├─ hello.py
  ├─ test_hello.py
  ├─ Makefile
  └─ requirements.txt
```

2. Update code/tests (the 2 ```.py``` files).

3. **Dev container:** nothing to change—`test-changed` will detect and run week2 when you modify it.

4. **Commit & push:** CI will run for `week2/` changes automatically.

---

## Troubleshooting

* **`flake8` / `pytest` not found**

  Run `make install` in the relevant week (or reopen/rebuild the dev container if your startup command includes an install step).

* **CI didn’t run for my new week**

  Ensure your commit actually modifies files under `weekN/`. If none are detected, the workflow falls back to testing all weeks.

* **Makefile: “missing separator”**

  Recipe lines must be indented with a **tab**, not spaces.

---

## License

Educational template for IDS 706 coursework.
