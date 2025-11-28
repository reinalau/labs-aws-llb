# Multi-stage build para reducir tamaño de imagen
FROM python:3.11-alpine AS builder

WORKDIR /app

# Install build dependencies
RUN apk add --no-cache \
    gcc \
    musl-dev \
    mariadb-connector-c-dev \
    pkgconfig

# Copy and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# Final stage
FROM python:3.11-alpine

WORKDIR /app

# Install runtime dependencies only
RUN apk add --no-cache \
    mariadb-connector-c \
    curl

# Copy Python packages from builder
COPY --from=builder /root/.local /home/appuser/.local

# Create non-root user first
RUN adduser -D -u 1000 appuser

# Copy application code
COPY --chown=appuser:appuser app.py .
COPY --chown=appuser:appuser frontend/ /app/frontend/

# Fix permissions
RUN chown -R appuser:appuser /home/appuser/.local

USER appuser

# Make sure scripts in .local are usable
ENV PATH=/home/appuser/.local/bin:$PATH

EXPOSE 5000

CMD ["gunicorn", "-w", "2", "-b", "0.0.0.0:5000", "app:app"]