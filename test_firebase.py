"""
WattX Firebase Debug Tool
Run this to see exactly what is stored under Devices/METER001/controls
and test publishing MQTT messages directly.
"""
import firebase_admin
from firebase_admin import credentials, db
import paho.mqtt.client as mqtt
import ssl, time, json

FIREBASE_KEY_PATH = r"C:\Users\ACER\Downloads\wattx-16024-firebase-adminsdk-fbsvc-0a16dc3bb8.json"
DATABASE_URL      = "https://wattx-16024-default-rtdb.firebaseio.com/"

MQTT_BROKER = "27b6e110383147789c44e19ac200f7ce.s1.eu.hivemq.cloud"
MQTT_PORT   = 8883
MQTT_USER   = "r_e_i_b_i_n"
MQTT_PASS   = "Reibin@07"

# ── Step 1: Init Firebase ──────────────────────────────────────────────────────
print("Initializing Firebase...")
cred = credentials.Certificate(FIREBASE_KEY_PATH)
firebase_admin.initialize_app(cred, {'databaseURL': DATABASE_URL})
print("Firebase OK\n")

# ── Step 2: Read current state of controls ─────────────────────────────────────
print("=" * 55)
print("  Current Firebase: Devices/METER001/controls")
print("=" * 55)
snapshot = db.reference("Devices/METER001/controls").get()
if snapshot:
    for key, val in snapshot.items():
        print(f"  [{key}]  ->  {val}")
else:
    print("  (empty — no data found!)")
print()

# ── Step 3: Connect MQTT and test publish ──────────────────────────────────────
print("Connecting to MQTT...")
mqttc = mqtt.Client(client_id="WattX_Test", protocol=mqtt.MQTTv5)
mqttc.username_pw_set(MQTT_USER, MQTT_PASS)
mqttc.tls_set(cert_reqs=ssl.CERT_REQUIRED)

connected = False

def on_connect(c, u, f, rc, p=None):
    global connected
    if rc == 0:
        connected = True
        print(f"MQTT connected!\n")
    else:
        print(f"MQTT FAILED rc={rc}")

mqttc.on_connect = on_connect
mqttc.connect(MQTT_BROKER, MQTT_PORT)
mqttc.loop_start()

# Wait up to 5 sec to connect
for _ in range(10):
    if connected:
        break
    time.sleep(0.5)

if not connected:
    print("Could not connect to MQTT. Check credentials.")
    exit(1)

# ── Step 4: Publish test messages to all LED topics ───────────────────────────
print("=" * 55)
print("  Publishing test ON messages to LED topics...")
print("=" * 55)

topics = {
    "app/led1": ("LED 1 / Light 1", "1"),
    "app/led2": ("LED 2 / Light 2", "1"),
    "app/led3": ("LED 3 / Light 3", "1"),
    "app/motor1/speed": ("Motor 1 / Fan 1", "255"),
    "app/motor2/speed": ("Motor 2 / Fan 2", "255"),
}

for topic, (name, payload) in topics.items():
    result = mqttc.publish(topic, payload)
    result.wait_for_publish()
    print(f"  PUBLISHED  {topic:30s}  payload='{payload}'  ({name})")
    time.sleep(0.3)

print()
print("If your ESP32 is connected, all LEDs should be ON and motors spinning.")
print("Waiting 3 seconds then turning everything OFF...\n")
time.sleep(3)

# ── Step 5: Turn everything OFF ────────────────────────────────────────────────
print("=" * 55)
print("  Publishing OFF messages...")
print("=" * 55)
off_payloads = {
    "app/led1": "0",
    "app/led2": "0",
    "app/led3": "0",
    "app/motor1/speed": "0",
    "app/motor2/speed": "0",
}
for topic, payload in off_payloads.items():
    mqttc.publish(topic, payload).wait_for_publish()
    print(f"  PUBLISHED  {topic:30s}  payload='{payload}'")
    time.sleep(0.2)

print("\nDone! Check your ESP32 serial monitor for received messages.")
mqttc.loop_stop()
mqttc.disconnect()
