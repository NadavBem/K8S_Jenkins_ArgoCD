# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Install any needed packages specified in requirements.txt
# If requirements.txt doesn't exist, you can install Flask directly
RUN pip install --no-cache-dir Flask

# Make port 80 available to the world outside this container
EXPOSE 80

# Define environment variable to ensure output is sent directly to the terminal
ENV PYTHONUNBUFFERED=1

# Run app.py when the container launches
CMD ["python", "main.py"]
