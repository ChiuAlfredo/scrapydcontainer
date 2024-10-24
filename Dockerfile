# Use Python 3.11.4 as the base image
FROM python:3.11.4-slim

# Set environment variables
ENV PYTHONUNBUFFERED 1

# Set the working directory in the container
WORKDIR /usr/src/app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3-dev \
    git \
    && apt-get clean
RUN apt-get update && \
    apt-get install -y curl gnupg2 && \
    curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list && \
    apt-get update && \
    ACCEPT_EULA=Y apt-get install -y msodbcsql17 unixodbc-dev && \
    apt-get clean

# Install pipenv
RUN pip install --upgrade pip setuptools wheel

# Install Scrapy and Scrapyd
COPY requirements.txt .

# 安装依赖
RUN pip install --no-cache-dir -r requirements.txt

# Copy custom scrapyd.conf file to the container
COPY scrapyd.conf /etc/scrapyd/scrapyd.conf

# Create directories for Scrapyd data
RUN mkdir -p /var/lib/scrapyd/eggs /var/log/scrapyd /var/lib/scrapyd/dbs

# Expose the Scrapyd port
EXPOSE 6800

# Start Scrapyd service
CMD ["scrapyd"]
