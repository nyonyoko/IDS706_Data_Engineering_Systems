.DEFAULT_GOAL := all
SHELL := /bin/bash
.PHONY: help install format format-check lint test clean all

PY  := python
PIP := $(PY) -m pip
REQ := requirements.txt
LOG_DIR := .logs
TIMESTAMP := $(shell date +%Y-%m-%d_%H-%M-%S)

help: ## Show targets
	@awk 'BEGIN {FS=":.*##"} /^[a-zA-Z_-]+:.*##/ {printf "\033[36m%-16s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install: ## Install deps
	$(PIP) install --upgrade pip
	[ -f $(REQ) ] && $(PIP) install -r $(REQ) || true

format: ## Format code
	black .

format-check: ## Check formatting
	black --check .

lint: ## Lint
	flake8 .

test: ## Run tests w/ coverage; save log
	mkdir -p $(LOG_DIR)
	if ls tests/test_*.py 2>/dev/null | grep -q .; then \
		$(PY) -m pytest -q --cov=analysis --cov-report=term-missing | tee $(LOG_DIR)/pytest_$(TIMESTAMP).log; \
	else \
		echo "No tests found. Skipping." | tee $(LOG_DIR)/pytest_$(TIMESTAMP).log; \
	fi

clean: ## Clean caches/artifacts
	rm -rf __pycache__ .pytest_cache .coverage .mypy_cache .ruff_cache $(LOG_DIR)

all: install format lint test ## Full workflow