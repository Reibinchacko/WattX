import requests
import time
import random
import json

# --- CONFIGURATION ---
# Replace with your actual Firebase URL
FIREBASE_URL = "https://your-project-id.firebaseio.com"
METER_ID = "METER001"

def simulate_iot():
    print(f"Starting IoT Simulation for {METER_ID}...")
    
    url = f"{FIREBASE_URL}/EnergyReadings/live/{METER_ID}.json"
    
    while True:
        # Generate mock data
        voltage = round(230 + random.uniform(-5, 5), 1)
        current = round(10 + random.uniform(-2, 2), 2)
        power = round((voltage * current) / 1000, 2)  # kW
        
        payload = {
            "power": power,
            "voltage": voltage,
            "current": current,
            "timestamp": {".sv": "timestamp"} # Server-side timestamp
        }
        
        try:
            response = requests.put(url, json=payload)
            if response.status_code == 200:
                print(f"Update Success: {power}kW | {voltage}V | {current}A")
            else:
                print(f"Error {response.status_code}: {response.text}")
        except Exception as e:
            print(f"Connection Error: {e}")
            
        time.sleep(2) # Send data every 2 seconds

if __name__ == "__main__":
    simulate_iot()
