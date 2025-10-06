# app.py
from flask import Flask, render_template, request, redirect, url_for
import requests
import json
from datetime import datetime, date, timedelta

rowflow = Flask(__name__)

# Base API URL for Environment Agency flood monitoring data
BASE_API_URL = "http://environment.data.gov.uk/flood-monitoring/id/stations/{station_id}/readings?parameter=flow&_sorted&date={selected_date}"

@rowflow.route('/', methods=['GET', 'POST'])
def index():
    processed_data = []
    error_message = None
    station_id = request.args.get('station_id', '3400TH') # Default station ID
    selected_date = request.args.get('date', date.today().isoformat()) # Default to today's date in YYYY-MM-DD
    date_options = [(date.today() - timedelta(days=i)).isoformat() for i in range(28)] # Only last 28 days data is available via this API
    # print (f"Selected Station ID: {station_id}, Date: {selected_date}, Date Options: {date_options}")

    if request.method == 'POST':
        station_id = request.form.get('station_id', '').strip()
        selected_date = request.form.get('date', '').strip()

        # Basic validation for inputs
        if not station_id:
            error_message = "Please enter a Station ID."
        elif not selected_date:
            error_message = "Please select a Date."
        else:
            try:
                # Validate date format (optional, as HTML input type="date" handles this well)
                datetime.strptime(selected_date, '%Y-%m-%d')
            except ValueError:
                error_message = "Invalid date format. Please use YYYY-MM-DD."

        if not error_message:
            # Redirect to GET request with parameters to make URL shareable and refresh-friendly
            return redirect(url_for('index', station_id=station_id, date=selected_date))

    # If it's a GET request (initial load or redirect from POST) and inputs are valid
    if station_id and selected_date and not error_message:
        api_url = BASE_API_URL.format(station_id=station_id, selected_date=selected_date)
        print(f"Fetching data from: {api_url}") # For debugging

        try:
            # Step 1: Query data from the API
            response = requests.get(api_url, timeout=10) # Increased timeout for potentially larger responses
            response.raise_for_status() # Raise HTTPError for bad responses (4xx or 5xx)
            raw_data = response.json()

            # Step 2: Process the API data to extract level-stage (i.e. water level) and flow-water values
            # Check if 'items' key exists and is a list
            if 'items' in raw_data and isinstance(raw_data['items'], list):
                for item in raw_data['items']:
                    measure = item.get('measure', '')
                    date_time = item.get('dateTime')
                    value = item.get('value')

                    # Extract flow-water values
                    if "flow-water" in measure.lower() and date_time and value is not None:
                        processed_data.append({
                            'dateTime': date_time,
                            'value': value
                        })
            else:
                error_message = "API response does not contain expected 'items' array or is empty."
                print("API Response Structure Error: 'items' array not found or invalid.")

        except requests.exceptions.RequestException as e:
            # Handle network errors, timeouts, etc.
            error_message = f"Error fetching data from API: {e}."
            print(f"API Request Error: {e}")
        except json.JSONDecodeError:
            # Handle cases where the response is not valid JSON
            error_message = "Error decoding API response as JSON. The response might not be valid JSON or API returned an error."
            print(f"JSON Decode Error: Invalid API response format.")
        except Exception as e:
            # Catch any other unexpected errors
            error_message = f"An unexpected error occurred: {e}"
            print(f"Unexpected Error: {e}")

    return render_template(
        'index.html',
        data=processed_data,
        error=error_message,
        station_id=station_id,
        selected_date=selected_date,
        date_options=date_options
    )

if __name__ == '__main__':
    # When running locally, set debug to True for auto-reloading and debugging.
    rowflow.run(debug=True, host='0.0.0.0', port=5000)
