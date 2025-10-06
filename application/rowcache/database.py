import os
from azure.cosmos import CosmosClient, PartitionKey
from azure.cosmos.exceptions import CosmosHttpResponseError

# --- Functions ---

def get_database_container():
    """Establishes connection to Cosmos DB and returns the container client."""
    try:
        client = CosmosClient(os.getenv("COSMOS_ENDPOINT"), os.getenv("COSMOS_KEY"))
        db = client.create_database_if_not_exists(id=os.getenv("DATABASE_NAME"))
        container = db.create_container_if_not_exists(
            id=os.getenv("CONTAINER_NAME"),
            partition_key=PartitionKey(path="/id")
        )
        return container
    except CosmosHttpResponseError as e:
        print(f"Error connecting to or setting up Cosmos DB: {e}")
        return None
    except Exception as e:
        print(f"An unexpected error occurred during Cosmos DB setup: {e}")
        return None

def save_daily_max(container, station_id, record_date_str, daily_max):
    """
    Saves a single daily maximum value to Cosmos DB.
    It reads the existing item and updates it only if the new value is greater,
    or creates a new item if it doesn't exist.
    """
    if not container:
        print("Invalid container provided. Aborting database save.")
        return

    item_id = f"{station_id}-{record_date_str}"
    
    try:
        # Try to read the existing item
        stored_item = container.read_item(item=item_id, partition_key=item_id)

        # If it exists, check if the new value is greater and update if needed
        if daily_max > float(stored_item.get('value', float('-inf'))):
            print(f"Updating item {item_id} with new value {daily_max}")
            stored_item['value'] = daily_max
            container.replace_item(item=item_id, body=stored_item)
        else:
            print(f"No update needed for {item_id}. Stored: {stored_item.get('value')}, Fetched: {daily_max}")

    except CosmosHttpResponseError as e:
        # If the item is not found (404), create it.
        if e.status_code == 404:
            print(f"Item {item_id} not found. Creating new entry with value {daily_max}.")
            new_item = {'id': item_id, 'station_id': station_id, 'date': record_date_str, 'value': daily_max}
            container.upsert_item(new_item)
        else:
            print(f"Cosmos DB HTTP Error for item {item_id}: {e}")
    except Exception as e:
        print(f"An unexpected error occurred for item {item_id}: {e}")