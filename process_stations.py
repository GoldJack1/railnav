import csv
import os
import logging
from datetime import datetime
import shutil

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    force=True
)
logger = logging.getLogger(__name__)

def get_sort_key(station_name: str) -> str:
    """Create sort key for station name."""
    # Remove 'The' from the beginning for sorting
    name = station_name.lower()
    if name.startswith('the '):
        name = name[4:]
    return name.strip()

def backup_existing_file(file_path: str):
    """Create a backup of the existing file."""
    if os.path.exists(file_path):
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        backup_path = f"{file_path}.{timestamp}.bak"
        shutil.copy2(file_path, backup_path)
        logger.info(f"Created backup at {backup_path}")

def main():
    try:
        input_file = 'railnav/Resources/stations.csv'
        logger.info(f"Reading stations from {input_file}")
        
        # Read all stations
        stations = []
        with open(input_file, 'r') as f:
            reader = csv.reader(f)
            header = next(reader)  # Save header
            stations = list(reader)
        
        logger.info(f"Read {len(stations)} stations")
        
        # Sort stations alphabetically
        logger.info("Sorting stations alphabetically...")
        stations.sort(key=lambda x: get_sort_key(x[0]))
        
        # Backup and write back to CSV
        backup_existing_file(input_file)
        
        logger.info(f"Writing {len(stations)} sorted stations back to CSV...")
        with open(input_file, 'w', newline='') as f:
            writer = csv.writer(f)
            writer.writerow(header)  # Write header
            writer.writerows(stations)
        
        logger.info("Successfully sorted stations")
        
    except Exception as e:
        logger.error(f"Error: {str(e)}")
        raise

if __name__ == "__main__":
    main() 