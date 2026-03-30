# Install dependencies into an isolated directory
FROM python:3.12-slim AS builder

WORKDIR /app

# Disable .pyc files and force unbuffered logging for CloudWatch
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Install dependencies into a custom directory to copy cleanly into runtime
COPY requirements.txt .
RUN pip install --upgrade pip && \
    pip install --prefix=/install --no-cache-dir -r requirements.txt

# Set up the minimal runtime image
FROM python:3.12-slim AS runtime

WORKDIR /app

# Disable .pyc files and force unbuffered logging for CloudWatch
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Create a user with minimal permissions for security
RUN addgroup --system appgroup && \
    adduser --system --ingroup appgroup appuser

# Copy the installed packages from builder
COPY --from=builder /install /usr/local

# Copy only the application source
COPY . .

USER appuser

EXPOSE 8000

# Override APP_WORKERS via ECS task definition environment variables
# Use (CPU cores * 2) + 1 workers, since Fargate uses 1 core by default, our default num workers is 3
ENV APP_WORKERS=3

CMD ["sh", "-c", "uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers $APP_WORKERS"]
