import firebase_admin
from firebase_admin import credentials, db
import paho.mqtt.client as mqtt
import json
import ssl
import time
import os
import threading

# --- CONFIGURE PATHS ---
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
FIREBASE_KEY_PATH = os.path.join(BASE_DIR, "..", "..", "wattx-16024-firebase-adminsdk-fbsvc-0a16dc3bb8.json")
DATABASE_URL = "https://wattx-16024-default-rtdb.firebaseio.com/"

# MQTT (HiveMQ Cloud) Settings
MQTT_BROKER = "27b6e110383147789c44e19ac200f7ce.s1.eu.hivemq.cloud"
MQTT_PORT   = 8883
MQTT_USER   = "r_e_i_b_i_n"
MQTT_PASS   = "Reibin@07"

# ── Alert / Automation Config (kept small for testing) ────────────────────────
OVERAGE_POWER_KW    = 0.5   # kW  → overage alert threshold
IDLE_AUTO_OFF_SECS  = 120   # 2 minutes → auto-off idle device
BILL_MILESTONE_RS   = 10.0  # ₹   → alert every ₹10
COST_PER_KWH        = 6.50  # ₹/kWh (KSEB basic slab)
METER_ID            = "METER001"

# ── Friendly device names ─────────────────────────────────────────────────────
DEVICE_LABELS = {
    "LED 1": "Light 1", "LED 2": "Light 2", "LED 3": "Light 3",
    "Motor 1": "Fan 1", "Motor 2": "Fan 2",
}

# ── MQTT topic map ─────────────────────────────────────────────────────────────
TOPIC_MAP = {
    "LED 1": "app/led1", "LED 2": "app/led2", "LED 3": "app/led3",
    "Motor 1": "app/motor1", "Motor 2": "app/motor2",
}

# ── Runtime state ──────────────────────────────────────────────────────────────
device_on_since   = {}          # key -> time.time() when turned ON
idle_timers       = {}          # key -> threading.Timer
last_power        = 0.0
session_start     = time.time()
accumulated_kwh   = 0.0
last_bill_mile    = 0.0
overage_alerted   = False

# ── Firebase init ──────────────────────────────────────────────────────────────
print("Initializing Firebase...")
try:
    cred = credentials.Certificate(FIREBASE_KEY_PATH)
    firebase_admin.initialize_app(cred, {'databaseURL': DATABASE_URL})
    print("Firebase initialized successfully.")
except Exception as e:
    print(f"Error initializing Firebase: {e}")
    exit(1)

# ── Helpers ────────────────────────────────────────────────────────────────────

def push_alert(title: str, message: str, alert_type: str):
    """Write an alert to Firebase Alerts/system/."""
    ref = db.reference(f"Alerts/system").push()
    ref.set({
        "title": title,
        "message": message,
        "type": alert_type,
        "timestamp": {".sv": "timestamp"},
        "isRead": False,
    })
    print(f"[ALERT] [{alert_type.upper()}] {title}: {message}")


def friendly(key: str) -> str:
    return DEVICE_LABELS.get(key, key)

# ── MQTT client ────────────────────────────────────────────────────────────────
client = mqtt.Client(client_id="", userdata=None, protocol=mqtt.MQTTv5)
client.username_pw_set(MQTT_USER, MQTT_PASS)
client.tls_set(cert_reqs=ssl.CERT_REQUIRED)


def publish_control(device, is_on):
    if device in TOPIC_MAP:
        payload = "1" if is_on else "0"
        client.publish(TOPIC_MAP[device], payload)
        print(f"Published to {TOPIC_MAP[device]}: {payload}")


def _set_mqtt_status(connected: bool):
    """Write MQTT broker connection status to Firebase so the Flutter app
    can show the green/red status dot on the dashboard."""
    try:
        db.reference("System/mqtt_status").update({
            "connected": connected,
            "lastSeen": {".sv": "timestamp"},
            "broker": MQTT_BROKER,
        })
        print(f"[STATUS] MQTT status set to connected={connected}")
    except Exception as e:
        print(f"[STATUS] Failed to update MQTT status: {e}")


def on_connect(client, userdata, flags, rc, properties=None):
    if rc == 0:
        print("Connected to MQTT Broker successfully!")
        client.subscribe("esp32/energy")
        _set_mqtt_status(True)   # ← tell Flutter we're live
    else:
        print(f"Failed to connect, rc={rc}")
        _set_mqtt_status(False)


# ── Power message handler (overage + bill milestone) ──────────────────────────
def on_message(client, userdata, msg):
    global last_power, accumulated_kwh, last_bill_mile, overage_alerted
    try:
        data = json.loads(msg.payload.decode())
        print(f"Recv Energy Data: {data}")

        # Write live reading to Firebase
        db.reference(f"EnergyReadings/live/{METER_ID}").update(data)

        power = float(data.get("power", 0.0))
        last_power = power

        # ── Overage alert ──────────────────────────────────────────────────
        if power > OVERAGE_POWER_KW and not overage_alerted:
            overage_alerted = True
            push_alert(
                "⚡ Power Overage!",
                f"Current usage is {power:.2f} kW, above your "
                f"{OVERAGE_POWER_KW:.1f} kW limit.",
                "critical",
            )
        elif power <= OVERAGE_POWER_KW:
            overage_alerted = False  # reset so it can fire again

        # ── Bill milestone ─────────────────────────────────────────────────
        elapsed_hours = (time.time() - session_start) / 3600.0
        accumulated_kwh = power * elapsed_hours
        cost = accumulated_kwh * COST_PER_KWH
        milestone = int(cost / BILL_MILESTONE_RS) * BILL_MILESTONE_RS
        if milestone > last_bill_mile and milestone > 0:
            last_bill_mile = milestone
            push_alert(
                "💸 Bill Milestone",
                f"Estimated session cost crossed ₹{milestone:.0f}. "
                f"Current: ₹{cost:.2f}.",
                "warning",
            )

    except Exception as e:
        print(f"Error parsing MQTT message: {e}")


client.on_connect = on_connect
client.on_message = on_message


# ── Firebase control listener (device toggle + idle timer) ────────────────────
def handle_idle_auto_off(key: str):
    """Called by timer after IDLE_AUTO_OFF_SECS of device being ON."""
    label = friendly(key)
    minutes = IDLE_AUTO_OFF_SECS // 60
    # Turn off in Firebase → mqtt_sync will relay to ESP32 via on_value
    db.reference(f"Devices/{METER_ID}/controls/{key}").update({"isOn": False})
    push_alert(
        f"💡 Auto-Off: {label}",
        f"{label} was ON for {minutes} minute(s) with no change "
        f"and was turned OFF automatically.",
        "warning",
    )
    device_on_since.pop(key, None)
    idle_timers.pop(key, None)
    print(f"[AUTO-OFF] {label} turned off after {minutes} min idle.")


def control_listener(event):
    if event.data is None:
        return

    path = event.path.strip("/")

    def process_device(device: str, state):
        is_on = False
        if isinstance(state, dict):
            is_on = state.get("isOn", False) is True
        elif isinstance(state, bool):
            is_on = state

        publish_control(device, is_on)

        if is_on:
            device_on_since[device] = time.time()
            # Cancel existing idle timer and start fresh
            if device in idle_timers:
                idle_timers[device].cancel()
            t = threading.Timer(IDLE_AUTO_OFF_SECS, handle_idle_auto_off, args=[device])
            t.daemon = True
            t.start()
            idle_timers[device] = t
            print(f"[TIMER] Idle auto-off timer started for {friendly(device)} ({IDLE_AUTO_OFF_SECS}s)")
        else:
            # Cancel timer when device goes off
            if device in idle_timers:
                idle_timers[device].cancel()
                idle_timers.pop(device, None)
            device_on_since.pop(device, None)

    if not path:
        # Initial full data load
        for device, state in event.data.items():
            process_device(device, state)
    else:
        parts = path.split("/")
        device = parts[0]
        if len(parts) > 1 and parts[1] == "isOn":
            process_device(device, {"isOn": event.data})
        elif isinstance(event.data, dict) and "isOn" in event.data:
            process_device(device, event.data)


def ota_listener(event):
    """Listen for OTA trigger written by the Flutter app and relay to ESP32."""
    if event.data is None:
        return

    data = event.data
    # Triggered when data is a dict with trigger=True
    if isinstance(data, dict) and data.get("trigger") is True:
        print("[OTA] Firmware update requested from app. Publishing to ESP32...")
        client.publish("app/ota", "1", qos=1)
        # Reset the trigger so it can be fired again
        try:
            db.reference(f"Devices/{METER_ID}/ota_trigger").update({"trigger": False})
        except Exception as e:
            print(f"[OTA] Failed to reset trigger: {e}")
        push_alert(
            "🔧 OTA Update Triggered",
            "A firmware update signal was sent to the ESP32 device. "
            "The device will restart and apply the update.",
            "info",
        )


# ── Start bridge ───────────────────────────────────────────────────────────────
print("Connecting to MQTT...")
try:
    client.connect(MQTT_BROKER, MQTT_PORT)
    client.loop_start()

    print("Setting up Firebase listener...")
    db.reference(f"Devices/{METER_ID}/controls").listen(control_listener)
    db.reference(f"Devices/{METER_ID}/ota_trigger").listen(ota_listener)

    print(f"\n[ACTIVE] MQTT <-> Firebase Synchronizer running.")
    print(f"  Overage threshold : {OVERAGE_POWER_KW} kW")
    print(f"  Idle auto-off     : {IDLE_AUTO_OFF_SECS // 60} minutes")
    print(f"  Bill milestone    : ₹{BILL_MILESTONE_RS}")
    print("Toggling devices in the app will now trigger MQTT messages.\n")

    while True:
        time.sleep(1)

except KeyboardInterrupt:
    print("\nShutting down...")
    _set_mqtt_status(False)   # ← mark offline before exit
    for t in idle_timers.values():
        t.cancel()
    client.loop_stop()
    client.disconnect()
except Exception as e:
    print(f"Critical error: {e}")
    _set_mqtt_status(False)
