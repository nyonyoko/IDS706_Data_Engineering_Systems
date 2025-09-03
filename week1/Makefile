# Use the first target as the default
.DEFAULT_GOAL := all
SHELL := /bin/bash

# Mark task-like targets as phony so Make never confuses them with files
.PHONY: help install format format-check lint test clean all

# Pin interpreter and shared paths
PY  := python
PIP := $(PY) -m pip
REQ := requirements.txt

# simple log capture
LOG_DIR := .logs
TIMESTAMP := $(shell date +%Y-%m-%d_%H-%M-%S)

help: ## Show available targets
	@awk 'BEGIN {FS=":.*##"} /^[a-zA-Z_-]+:.*##/ {printf "\033[36m%-16s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install: ## Install deps
	$(PIP) install --upgrade pip
	[ -f $(REQ) ] && $(PIP) install -r $(REQ) || true

format: ## Format code
	black .

format-check: ## Check formatting (no changes)
	black --check .

lint: ## Lint
	flake8 .

test: ## Run tests with coverage and save the log
	mkdir -p $(LOG_DIR)
	$(PY) -m pytest -vv --cov=hello --cov-report=term-missing \
	| tee $(LOG_DIR)/pytest_$(TIMESTAMP).log

clean: ## Clean caches/artifacts
	rm -rf __pycache__ .pytest_cache .coverage .mypy_cache .ruff_cache $(LOG_DIR)

# Run the full local dev workflow
all: install format lint test ## Full workflow
