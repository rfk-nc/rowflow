# Python app to retrieve historical CSV records for every date since the specified start date and extract records matching the given station_id value.
# We cannot use this app exclusively as the historical data takes a few days to become available, so the app.py version should be used for real-time data.
# Once we have cached a sufficient volume of historical data, we can switch to using app.py for all data retrieval.

import os
import requests
import csv
import io
from datetime import datetime, timedelta, UTC
from dotenv import load_dotenv
from database import get_database_container, save_daily_max # Import shared functions

# --- Configuration ---
load_dotenv()

# API and Station Configuration
# This endpoint returns a CSV for a full day's readings for ALL stations.
BASE_API_URL = "https://environment.data.gov.uk/flood-monitoring/archive/readings-{date}.csv"
# This is the station ID used for creating unique IDs in our database.
STATION_ID = os.getenv("STATION_ID", "3400TH")
# This is the specific text we will search for in the CSV measure column.
MEASURE_FILTER = f"{STATION_ID}-flow-water"

# --- Functions ---

def get_start_date(STATION_ID):
    # TODO: replace with database lookup
    dt = (datetime.now(UTC) - timedelta(days=28)).date()
    return dt

def fetch_csv_data(reading_date):
    date_str = reading_date.strftime('%Y-%m-%d')
    api_url = BASE_API_URL.format(date=date_str)
    print(f"Fetching data from: {api_url}")  # For debugging

    try:
        response = requests.get(api_url, timeout=60) # Increased timeout for potentially larger responses
        response.raise_for_status() # Raise HTTPError for bad responses (4xx or 5xx)
        return response.text

    except requests.exceptions.RequestException as e:
        print(f"API request failed for {date_str}: {e}")
        return None
    except Exception as e:
        print(f"An unexpected error occurred on {date_str}: {e}")
        return None

def get_daily_max_from_csv(csv_content, measure_filter):
    """Parses CSV content and finds the maximum value for a specific measure."""
    max_value = float('-inf')
    found_match = False
    
    # Use io.StringIO to treat the CSV string as a file
    csv_file = io.StringIO(csv_content)
    reader = csv.reader(csv_file)
    
    for row in reader:
        # Ensure the row has the expected number of columns
        if len(row) >= 3 and measure_filter in row[1]:
            try:
                value = float(row[2])
                if value > max_value:
                    max_value = value
                found_match = True
            except (ValueError, IndexError):
                # Ignore rows where the value is not a valid float
                continue
                
    return max_value if found_match else None

def main():
    container = get_database_container()
    if not container:
        print("Could not connect to database. Exiting.")
        return

    # Get start date from lookup
    start_date = get_start_date(STATION_ID)
    # Historical data is usually available up to yesterday.
    end_date = (datetime.now(UTC) - timedelta(days=1)).date()

    print(f"Starting historical data fetch from {start_date} to {end_date} for measure '{MEASURE_FILTER}'.")

    current_date = start_date
    while current_date <= end_date:
        date_str = current_date.strftime('%Y-%m-%d')
        print(f"\n--- Processing {date_str} ---")
        
        csv_data = fetch_csv_data(current_date)
        daily_max = get_daily_max_from_csv(csv_data, MEASURE_FILTER)

        if daily_max is not None:
            print(f"Maximum flow for {date_str}: {daily_max}")
            save_daily_max(container, STATION_ID, date_str, daily_max)
        else:
            print(f"No valid data found for '{MEASURE_FILTER}' on {date_str}.")
        
        current_date += timedelta(days=1)

    print("\nHistorical data loading process finished.")

if __name__ == "__main__":
    main()
