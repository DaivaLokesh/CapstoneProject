# Step 1: Base image
FROM python:3.11-slim

# Step 2: Set work directory
WORKDIR /app

# Step 3: Optimize build cache by copying only requirements first
COPY requirements.txt .

# Step 4: Install dependencies
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Step 5: Copy project files
COPY . .

# Step 6: Collect static files (optional for Django)
RUN python manage.py collectstatic --noinput

# Step 7: Expose the port
EXPOSE 8000

# Step 8: Run using Gunicorn (recommended for production)
CMD ["gunicorn", "myproject.wsgi:application", "--bind", "0.0.0.0:8000"]
