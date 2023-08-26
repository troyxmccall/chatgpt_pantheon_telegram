# Use an official Python runtime as a parent image
FROM python:3.11-alpine as builder

# Set environment variables
ENV PYTHONFAULTHANDLER=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONHASHSEED=random \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100

# Install necessary packages and create code directory
RUN apk add --no-cache build-base libffi-dev && \
    mkdir -p /code

# Set the working directory to /code
WORKDIR /code

# Copy the current directory contents into the container at /code
COPY . /code/

# Manually build and install PyYAML
RUN pip install cython && \
    pip install --upgrade pyyaml

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Final stage to keep only necessary files and dependencies
FROM python:3.11-alpine

# Install necessary libraries for ffmpeg
RUN apk add --no-cache libgcc libstdc++ musl ffmpeg

# Copy necessary files and dependencies from builder stage
COPY --from=builder /usr/local/lib/python3.11/site-packages/ /usr/local/lib/python3.11/site-packages/
COPY --from=builder /usr/lib/ /usr/lib/
COPY --from=builder /code/ /code/

# Set the working directory to /code
WORKDIR /code

# Set environment variables
ENV PYTHONFAULTHANDLER=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONHASHSEED=random \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100

# Run the command when the container launches
CMD ["bash"]
