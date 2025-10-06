import os
import requests
import json
from datetime import datetime, timedelta, UTC
from dotenv import load_dotenv
from database import get_database_container, save_daily_max # Import shared functions

# --- Configuration ---
load_dotenv()

# API and Station Configuration
# This endpoint returns a JSON doc for a single 15 minute reading for the specified station.
BASE_API_URL = "http://environment.data.gov.uk/flood-monitoring/id/stations/{station_id}/readings?parameter=flow&_sorted&_limit=10000&since={start_date}"
# This is the station ID used for creating unique IDs in our database.
STATION_ID = os.getenv("STATION_ID", "3400TH")

# --- Functions ---

def get_start_date(STATION_ID):
    # TODO: replace with database lookup
    dt = (datetime.now(UTC) - timedelta(days=2)).date()
    return dt

def fetch_json_data(station_id):
    """
    Fetches recent data from the API and processes it to extract only 'flow-water' values.
    Returns a list of dictionaries, e.g., [{'dateTime': '...', 'value': ...}].
    """
    start_date = (get_start_date(station_id)).isoformat()
    api_url = BASE_API_URL.format(station_id=station_id, start_date=start_date)
    print(f"Fetching data from: {api_url}")

    try:
        # Step 1: Query data from the API
        response = requests.get(api_url, timeout=30) # Increased timeout for potentially larger responses
        response.raise_for_status() # Raise HTTPError for bad responses (4xx or 5xx)
        raw_data = response.json()

        # Step 2: Process the API data to extract level-stage (i.e. water level) and flow-water values
        processed_data = []
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
                    print(f"Processed Flow Data: {processed_data[-1]}")  # Debugging output
        else:
            print("API Response Structure Error: 'items' array not found or invalid.")

        return processed_data

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

    return None # Return None on error

def summarise_by_date(data):
    """
    Takes a list of processed data and returns a list of dictionaries 
    containing the maximum value for each date.
    """
    if not data:
        return []

    # Extract maximum flow value per date
    summarised_data = {}
    for entry in data:
        try:
            date = entry['dateTime'][:10]
            value = float(entry['value'])
            # If date is new or value is greater than existing, update it
            if date not in summarised_data or value > summarised_data[date]:
                summarised_data[date] = value
        except (TypeError, KeyError, ValueError):
            # Ignore malformed entries
            continue

    # Convert the dictionary to the desired list format
    return [{'date': date, 'value': value} for date, value in summarised_data.items()]

def main():
    container = get_database_container()
    if not container:
        print("Could not connect to database. Exiting.")
        return

    print("--- Starting recent data update process ---")
    processed_data = fetch_json_data(STATION_ID)
    
    if processed_data is None:
        print("Fetching data failed. Exiting.")
        return

    daily_maxes = summarise_by_date(processed_data)

    if not daily_maxes:
        print("No data to process. Exiting.")
        return

    print(f"\n--- Found daily maxes to process: {daily_maxes} ---")
    # Loop through the list of dictionaries and save each daily max
    for item in daily_maxes:
        date_str = item['date']
        max_value = item['value']
        save_daily_max(container, STATION_ID, date_str, max_value)
    
    print("\nRecent data update process finished.")

if __name__ == "__main__":
    main()