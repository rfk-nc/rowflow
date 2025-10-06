# Dockerfile
# Use an official Python runtime as a parent image
FROM python:3.9-slim-buster

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file into the container at /app
COPY requirements.txt .

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code into the container at /app
COPY . .

# Expose the port that the app will run on
EXPOSE 5000

# Run the application using Gunicorn, a production-ready WSGI server
# The command specifies:
# - 'gunicorn': the Gunicorn server
# - '-b 0.0.0.0:5000': bind to all network interfaces on port 5000
# - 'app:rowflow': specifies the Flask application instance.
#              The first 'app' refers to the 'app.py' file.
#              The second 'rowflow' refers to the 'rowflow = Flask(__name__)' instance inside 'app.py'.
CMD ["gunicorn", "-b", "0.0.0.0:5000", "app:rowflow"]
