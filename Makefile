.DEFAULT_GOAL := help
SHELL := /bin/bash
.PHONY: help install install-week format format-check lint test test-week test-changed clean all all-week

PY  := python
PIP := $(PY) -m pip
REQ := requirements.txt
LOG_DIR := .logs
TIMESTAMP := $(shell date +%Y-%m-%d_%H-%M-%S)

# Compute a reasonable diff base, then include uncommitted changes too
BASE ?= $(shell git merge-base --fork-point HEAD 2>/dev/null || git merge-base origin/main HEAD 2>/dev/null || echo HEAD~1)
CHANGED_WEEKS := $(shell { git diff --name-only $(BASE) HEAD 2>/dev/null; git status --porcelain | awk '{print $$2}'; } \
                  | sed -n 's#^\(week[^/]*\)/.*#\1#p' | sort -u)

help:
	@echo "Targets:"
	@echo "  install           Install root requirements.txt (if present)"
	@echo "  install-week      Install inside one week dir: make install-week WEEK=week1"
	@echo "  format            Run black in repo root"
	@echo "  format-check      Check formatting without changing files"
	@echo "  lint              Run flake8 in repo root"
	@echo "  test              Run pytest in repo root (if any) and save log"
	@echo "  test-week         Run tests inside one week dir: make test-week WEEK=week1"
	@echo "  test-changed      Run tests only for changed week*/ dirs since BASE"
	@echo "  clean             Remove caches and logs"
	@echo "  all               install + format + lint + test"
	@echo "  all-week          install + format + lint + test (inside one week): make all-week WEEK=week1"

install:
	$(PIP) install --upgrade pip
	[ -f $(REQ) ] && $(PIP) install -r $(REQ) || true

# Install inside a week folder
# Usage: make install-week WEEK=week1
install-week:
	@[ -n "$(WEEK)" ] || (echo "Set WEEK=weekX, e.g. make install-week WEEK=week1"; exit 2)
	$$(cd $(WEEK) && $(MAKE) install)

format:
	black .

format-check:
	black --check .

lint:
	flake8 .

# Root tests are optional; skip gracefully if none
test:
	mkdir -p $(LOG_DIR)
	if compgen -G "test_*.py" >/dev/null; then \
		$(PY) -m pytest -vv --cov=hello --cov-report=term-missing | tee $(LOG_DIR)/pytest_root_$(TIMESTAMP).log; \
	else \
		echo "No root tests found. Skipping."; \
	fi

# Usage: make test-week WEEK=week1
test-week:
	@[ -n "$(WEEK)" ] || (echo "Set WEEK=weekX, e.g. make test-week WEEK=week1"; exit 2)
	mkdir -p $(LOG_DIR)
	$$(cd $(WEEK) && $(MAKE) test) | tee $(LOG_DIR)/pytest_$(WEEK)_$(TIMESTAMP).log

# Convenience: run the full flow inside a week dir
# Usage: make all-week WEEK=week1
all-week:
	@[ -n "$(WEEK)" ] || (echo "Set WEEK=weekX, e.g. make all-week WEEK=week1"; exit 2)
	$$(cd $(WEEK) && $(MAKE) all)

test-changed:
	@if [ -z "$(CHANGED_WEEKS)" ]; then \
		echo "No changed week*/ directories since $(BASE)"; \
	else \
		for w in $(CHANGED_WEEKS); do \
			echo "===> Testing $$w"; \
			( cd $$w && $(MAKE) test ) || exit $$?; \
		done; \
	fi

clean:
	rm -rf __pycache__ .pytest_cache .coverage .mypy_cache .ruff_cache $(LOG_DIR)

all: install format lint test
