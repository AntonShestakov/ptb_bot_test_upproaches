FROM python:3.12-slim

WORKDIR /app

# Install deps first (layer caching)
COPY bot/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy bot code
COPY bot/ .

# Non-root user for security
RUN adduser --disabled-password --gecos "" botuser
USER botuser

CMD ["python", "main.py"]