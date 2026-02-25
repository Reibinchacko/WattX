import firebase_admin
from firebase_admin import credentials, db
import paho.mqtt.client as mqtt
import json
import ssl
import time
import os

# --- CONFIGURE PATHS ---
# Looking for the service account key in the Downloads folder
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
FIREBASE_KEY_PATH = os.path.join(BASE_DIR, "..", "..", "wattx-16024-firebase-adminsdk-fbsvc-0a16dc3bb8.json")
DATABASE_URL = "https://wattx-16024-default-rtdb.firebaseio.com/"

# MQTT (HiveMQ Cloud) Settings
MQTT_BROKER = "27b6e110383147789c44e19ac200f7ce.s1.eu.hivemq.cloud"
MQTT_PORT = 8883
MQTT_USER = "r_e_i_b_i_n"
MQTT_PASS = "Reibin@07"

# --- INITIALIZATION ---
print("Initializing Firebase...")
try:
    cred = credentials.Certificate(FIREBASE_KEY_PATH)
    firebase_admin.initialize_app(cred, {'databaseURL': DATABASE_URL})
    print("Firebase initialized successfully.")
except Exception as e:
    print(f"Error initializing Firebase: {e}")
    exit(1)

# MQTT Client setup
client = mqtt.Client(client_id="", userdata=None, protocol=mqtt.MQTTv5)
client.username_pw_set(MQTT_USER, MQTT_PASS)
client.tls_set(cert_reqs=ssl.CERT_REQUIRED)

def on_connect(client, userdata, flags, rc, properties=None):
    if rc == 0:
        print("Connected to MQTT Broker successfully!")
        client.subscribe("esp32/energy")
    else:
        print(f"Failed to connect to MQTT, return code {rc}")

def on_message(client, userdata, msg):
    try:
        data = json.loads(msg.payload.decode())
        print(f"Recv Energy Data: {data}")
        # Sync live reading to Firebase
        db.reference("EnergyReadings/live/METER001").update(data)
    except Exception as e:
        print(f"Error parsing MQTT message: {e}")

client.on_connect = on_connect
client.on_message = on_message

def publish_control(device, is_on):
    topic_map = {
        "LED 1": "app/led1",
        "LED 2": "app/led2",
        "LED 3": "app/led3",
        "Motor 1": "app/motor1",
        "Motor 2": "app/motor2"
    }
    if device in topic_map:
        payload = "1" if is_on else "0"
        client.publish(topic_map[device], payload)
        print(f"Published to {topic_map[device]}: {payload}")

def control_listener(event):
    if event.data is None: return
    
    # event.path is something like "/LED 1/isOn" or "/" on initial load
    path = event.path.strip("/")
    if not path:
        # Handling initial multi-device state
        for device, state in event.data.items():
            if isinstance(state, dict) and 'isOn' in state:
                publish_control(device, state['isOn'])
    else:
        parts = path.split("/")
        device = parts[0]
        if len(parts) > 1 and parts[1] == 'isOn':
            publish_control(device, event.data)
        elif isinstance(event.data, dict) and 'isOn' in event.data:
            publish_control(device, event.data['isOn'])

# --- START BRIDGE ---
print("Connecting to MQTT...")
try:
    client.connect(MQTT_BROKER, MQTT_PORT)
    client.loop_start()

    print("Setting up Firebase listener...")
    db.reference("Devices/METER001/controls").listen(control_listener)

    print("\n[ACTIVE] MQTT <-> Firebase Synchronizer running.")
    print("Toggling devices in the app will now trigger MQTT messages.")
    
    while True:
        time.sleep(1)
except KeyboardInterrupt:
    print("\nShutting down...")
    client.loop_stop()
    client.disconnect()
except Exception as e:
    print(f"Critical error: {e}")
