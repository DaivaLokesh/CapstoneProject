# Step 1: Base image
FROM python:3.12-slim

# Step 2: Set work directory
WORKDIR /app

# Step 3: Copy and install dependencies
COPY requirements.txt .
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Step 4: Copy project files
COPY . .

# Step 5: Expose port
EXPOSE 8000

# Step 6: Default command for production (can override in CI)
CMD ["gunicorn", "myproject.wsgi:application", "--bind", "0.0.0.0:8000"]
