FROM python:3.11-slim

# System deps (optional but useful for wheels and locale)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential curl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Workdir
WORKDIR /app
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONPATH=/app

# deps first (cache-friendly)
COPY week3/requirements.txt /app/requirements.txt
RUN python -m pip install --upgrade pip && pip install -r /app/requirements.txt

# copy only sources / config (avoid caches)
COPY week3/analysis /app/analysis
COPY week3/tests /app/tests
COPY week3/pytest.ini /app/pytest.ini
# optional, for reference
COPY week3/README.md /app/README.md

# Default CMD runs tests (override with `docker run ... bash` if you want a shell)
CMD ["pytest", "-q", "--cov=analysis", "--cov-report=term-missing"]