FROM python:3.12-slim
WORKDIR /app

RUN useradd --create-home appuser && chown appuser:appuser /app
# Install uv (fast Python package manager)
RUN pip install uv

COPY --chown=appuser:appuser pyproject.toml .
COPY --chown=appuser:appuser uv.lock* .
# Copy dependency files first (Docker layer caching)

USER appuser
# Install dependencies
RUN uv sync --frozen --no-dev
# Copy application code
COPY --chown=appuser:appuser app/ app/
# Create non-root user for security


# Expose port
EXPOSE 8000
# Health check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1
# Run with uvicorn
CMD ["uv", "run", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]