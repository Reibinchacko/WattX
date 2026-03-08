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
FIREBASE_KEY_PATH = r"C:\Users\ACER\Downloads\wattx-16024-firebase-adminsdk-fbsvc-0a16dc3bb8.json"
DATABASE_URL = "https://wattx-16024-default-rtdb.firebaseio.com/"

# MQTT (HiveMQ Cloud) Settings
MQTT_BROKER = "27b6e110383147789c44e19ac200f7ce.s1.eu.hivemq.cloud"
MQTT_PORT   = 8883
MQTT_USER   = "r_e_i_b_i_n"
MQTT_PASS   = "Reibin@07"

# ── Alert / Automation Config ──────────────────────────────────────────────────
OVERAGE_POWER_KW    = 0.5   # kW  → overage alert threshold
IDLE_AUTO_OFF_SECS  = 120   # 2 minutes → auto-off idle device
BILL_MILESTONE_RS   = 10.0  # ₹   → alert every ₹10
COST_PER_KWH        = 6.50  # ₹/kWh (KSEB basic slab)
METER_ID            = "METER001"

# ── Friendly device names ──────────────────────────────────────────────────────
DEVICE_LABELS = {
    "LED 1": "Light 1", "LED 2": "Light 2", "LED 3": "Light 3",
    "Motor 1": "Fan 1", "Motor 2": "Fan 2",
}

# ── MQTT topic map ─────────────────────────────────────────────────────────────
# LED topics: publish "1" (ON) or "0" (OFF)
# Motor topics: publish speed integer as string "0"-"255"
TOPIC_MAP = {
    "LED 1":   "app/led1",
    "LED 2":   "app/led2",
    "LED 3":   "app/led3",
    "Motor 1": "app/motor1/speed",   # Updated: ESP32 listens on app/motor1/speed
    "Motor 2": "app/motor2/speed",   # Updated: ESP32 listens on app/motor2/speed
}

# ── Motor default speed when turned ON (0-255) ─────────────────────────────────
MOTOR_ON_SPEED  = 255   # Full speed when turned ON from app
MOTOR_OFF_SPEED = 0     # 0 = stop motor

# ── Topics ESP32 publishes to (we subscribe to these) ─────────────────────────
ESP32_VOLTAGE_TOPIC = "home/voltage"
ESP32_CURRENT_TOPIC = "home/current"
ESP32_POWER_TOPIC   = "home/power"

# ── Sensor correction factors ──────────────────────────────────────────────────
# ZMPT101B reads ~420V but real mains is ~230V  -> scale factor = 230/420 ≈ 0.548
# Fine-tune this until the app shows ~230V
VOLTAGE_CORRECTION = 0.548

# ── Runtime state ──────────────────────────────────────────────────────────────
device_on_since  = {}           # key -> time.time() when turned ON
idle_timers      = {}           # key -> threading.Timer
last_power       = 0.0
session_start    = time.time()
accumulated_kwh  = 0.0
last_bill_mile   = 0.0
overage_alerted  = False

# Live readings buffer (updated from home/voltage, home/current, home/power)
live_voltage = 0.0
live_current = 0.0
live_power   = 0.0

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
    ref = db.reference("Alerts/system").push()
    ref.set({
        "title":     title,
        "message":   message,
        "type":      alert_type,
        "timestamp": {".sv": "timestamp"},
        "isRead":    False,
    })
    print(f"[ALERT] [{alert_type.upper()}] {title}: {message}")


def friendly(key: str) -> str:
    return DEVICE_LABELS.get(key, key)


# ── MQTT client ────────────────────────────────────────────────────────────────
client = mqtt.Client(client_id="", userdata=None, protocol=mqtt.MQTTv5)
client.username_pw_set(MQTT_USER, MQTT_PASS)
client.tls_set(cert_reqs=ssl.CERT_REQUIRED)


def publish_control(device: str, is_on: bool):
    """
    Publish ON/OFF command to ESP32 via MQTT.

    LEDs   → topic: app/led1 / app/led2 / app/led3
              payload: "1" (ON) or "0" (OFF)

    Motors → topic: app/motor1/speed / app/motor2/speed
              payload: "255" (full speed ON) or "0" (stop OFF)
    """
    if device not in TOPIC_MAP:
        print(f"[WARN] Unknown device: {device}")
        return

    topic = TOPIC_MAP[device]

    if device.startswith("Motor"):
        # Motor: send speed value as string
        payload = str(MOTOR_ON_SPEED) if is_on else str(MOTOR_OFF_SPEED)
    else:
        # LED: send "1" or "0"
        payload = "1" if is_on else "0"

    client.publish(topic, payload)
    print(f"[MQTT PUBLISH] {topic} -> {payload}  ({friendly(device)} {'ON' if is_on else 'OFF'})")


def on_connect(mqttc, userdata, flags, rc, properties=None):
    if rc == 0:
        print("Connected to MQTT Broker successfully!")

        # Subscribe to ESP32 sensor data topics
        mqttc.subscribe(ESP32_VOLTAGE_TOPIC)
        mqttc.subscribe(ESP32_CURRENT_TOPIC)
        mqttc.subscribe(ESP32_POWER_TOPIC)
        mqttc.subscribe("esp32/energy")

        # Subscribe to our own outgoing topics to confirm delivery
        mqttc.subscribe("app/led1")
        mqttc.subscribe("app/led2")
        mqttc.subscribe("app/led3")
        mqttc.subscribe("app/motor1/speed")
        mqttc.subscribe("app/motor2/speed")

        print(f"  Listening for sensor data on:")
        print(f"    {ESP32_VOLTAGE_TOPIC}, {ESP32_CURRENT_TOPIC}, {ESP32_POWER_TOPIC}")
        print(f"  Listening for control echos on:")
        print(f"    app/led1, app/led2, app/led3, app/motor1/speed, app/motor2/speed")
    else:
        print(f"Failed to connect to MQTT, rc={rc}")


# ── Power message handler ──────────────────────────────────────────────────────
def check_overage_and_bill(power_w: float):
    """Check overage and bill milestones. power_w is in Watts."""
    global last_power, accumulated_kwh, last_bill_mile, overage_alerted

    power_kw = power_w / 1000.0
    last_power = power_kw

    # ── Overage alert ──────────────────────────────────────────────────────────
    if power_kw > OVERAGE_POWER_KW and not overage_alerted:
        overage_alerted = True
        push_alert(
            "⚡ Power Overage!",
            f"Current usage is {power_kw:.3f} kW, above your "
            f"{OVERAGE_POWER_KW:.2f} kW limit.",
            "critical",
        )
    elif power_kw <= OVERAGE_POWER_KW:
        overage_alerted = False  # reset so it can fire again

    # ── Bill milestone ─────────────────────────────────────────────────────────
    elapsed_hours = (time.time() - session_start) / 3600.0
    accumulated_kwh = power_kw * elapsed_hours
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


def on_message(mqttc, userdata, msg):
    """
    Handle all incoming MQTT messages from ESP32.
    Also echoes back our own published control commands (for logging).
    """
    global live_voltage, live_current, live_power

    topic   = msg.topic
    payload = msg.payload.decode().strip()

    # ── Echo: our own control commands (we subscribed to these for logging) ──
    if topic.startswith("app/"):
        print(f"[MQTT ECHO] {topic:30s} -> '{payload}'")
        return

    try:
        # ── Individual sensor topics from your ESP32 code ──────────────────────
        if topic == ESP32_VOLTAGE_TOPIC:
            raw_v = float(payload)
            live_voltage = round(raw_v * VOLTAGE_CORRECTION, 2)  # correct ~420V -> ~230V

        elif topic == ESP32_CURRENT_TOPIC:
            live_current = float(payload)

        elif topic == ESP32_POWER_TOPIC:
            live_power = float(payload)

            # Corrected voltage for power factor calculation
            v = live_voltage if live_voltage > 0 else 230.0
            i = live_current
            pf = round(live_power / (v * i), 3) if (v > 0 and i > 0) else 1.0
            pf = max(0.0, min(1.0, pf))  # clamp to valid range

            # Use integer ms timestamp — {'.sv':'timestamp'} not reliable w/ Admin SDK
            reading = {
                "voltage":     live_voltage,           # corrected V (~230V)
                "current":     round(live_current, 3), # A
                "power":       round(live_power / 1000.0, 4),  # W -> kW
                "frequency":   50.0,
                "powerFactor": pf,
                "timestamp":   int(time.time() * 1000),  # ms epoch
            }

            # .set() replaces the whole node — ensures app always gets fresh data
            db.reference(f"EnergyReadings/live/{METER_ID}").set(reading)
            print(f"[SENSOR] {live_voltage:.1f}V | {live_current:.3f}A | "
                  f"{live_power:.1f}W -> {reading['power']:.4f}kW | "
                  f"PF={pf} | Firebase ✓")

            check_overage_and_bill(live_power)

        # ── Legacy JSON topic (esp32/energy) ──────────────────────────────────
        elif topic == "esp32/energy":
            data = json.loads(payload)
            print(f"[esp32/energy] {data}")

            # Write raw JSON to Firebase
            db.reference(f"EnergyReadings/live/{METER_ID}").update(data)

            power_w = float(data.get("power", data.get("power_w", 0.0)))
            check_overage_and_bill(power_w)

    except ValueError as e:
        print(f"[WARN] Could not parse payload '{payload}' on topic '{topic}': {e}")
    except Exception as e:
        print(f"[ERROR] on_message: {e}")


client.on_connect = on_connect
client.on_message = on_message


# ── Previous device states (for change detection) ─────────────────────────────
prev_states = {}   # key -> bool


def handle_idle_auto_off(key: str):
    """Called by timer after IDLE_AUTO_OFF_SECS of device being ON."""
    label   = friendly(key)
    minutes = IDLE_AUTO_OFF_SECS // 60
    db.reference(f"Devices/{METER_ID}/controls/{key}").update({"isOn": False})
    push_alert(
        f"💡 Auto-Off: {label}",
        f"{label} was ON for {minutes} minute(s) idle and was turned OFF automatically.",
        "warning",
    )
    device_on_since.pop(key, None)
    idle_timers.pop(key, None)
    print(f"[AUTO-OFF] {label} turned off after {minutes} min idle.")


def process_device(device: str, is_on: bool):
    """Publish MQTT command and manage idle timer for a device."""
    publish_control(device, is_on)

    if is_on:
        device_on_since[device] = time.time()
        if device in idle_timers:
            idle_timers[device].cancel()
        t = threading.Timer(IDLE_AUTO_OFF_SECS, handle_idle_auto_off, args=[device])
        t.daemon = True
        t.start()
        idle_timers[device] = t
        print(f"  [TIMER] Idle timer started for {friendly(device)} ({IDLE_AUTO_OFF_SECS}s)")
    else:
        if device in idle_timers:
            idle_timers[device].cancel()
            idle_timers.pop(device, None)
        device_on_since.pop(device, None)


def poll_firebase_controls():
    """
    Poll Firebase Devices/METER001/controls every second.
    Publish MQTT only when a device's isOn state changes.
    Also handles fan speed changes for motors.
    """
    global prev_states
    controls_ref = db.reference(f"Devices/{METER_ID}/controls")

    print("[POLL] Starting Firebase controls polling loop (1s interval)...")

    while True:
        try:
            snapshot = controls_ref.get()   # one-time read
            if isinstance(snapshot, dict):
                for device, data in snapshot.items():
                    if not isinstance(data, dict):
                        continue

                    is_on = bool(data.get("isOn", False))

                    # ── Detect isOn state change ───────────────────────────
                    if prev_states.get(device) != is_on:
                        prev_states[device] = is_on
                        state_str = "ON " if is_on else "OFF"
                        print(f"\n{'*'*45}")
                        print(f"  DEVICE CHANGE: {device:10s} -> {state_str}")
                        print(f"{'*'*45}")
                        process_device(device, is_on)

                    # ── Fan speed change (Motor only) ──────────────────────
                    if device.startswith("Motor") and is_on:
                        speed = data.get("speed", 1)
                        if isinstance(speed, (int, float)):
                            speed = max(1, min(5, int(speed)))
                            pwm   = int((speed / 5.0) * 255)
                            prev_key = f"{device}_speed"
                            if prev_states.get(prev_key) != pwm:
                                prev_states[prev_key] = pwm
                                topic = TOPIC_MAP.get(device)
                                if topic:
                                    client.publish(topic, str(pwm))
                                    print(f"  [SPEED] {topic} -> PWM={pwm} (speed={speed}/5)")

        except Exception as e:
            print(f"[POLL ERROR] {e}")

        time.sleep(1)


# ── Start bridge ───────────────────────────────────────────────────────────────
print("Connecting to MQTT broker...")
try:
    client.connect(MQTT_BROKER, MQTT_PORT)
    client.loop_start()

    # Start polling thread — reads Firebase every 1 second
    poll_thread = threading.Thread(target=poll_firebase_controls, daemon=True)
    poll_thread.start()
    print("[POLL] Firebase controls polling started.")

    print(f"\n{'='*55}")
    print(f"  WattX MQTT <-> Firebase Bridge ACTIVE")
    print(f"{'='*55}")
    print(f"  MQTT Broker       : {MQTT_BROKER}:{MQTT_PORT}")
    print(f"  Meter ID          : {METER_ID}")
    print(f"  Overage threshold : {OVERAGE_POWER_KW} kW")
    print(f"  Idle auto-off     : {IDLE_AUTO_OFF_SECS // 60} minutes")
    print(f"  Bill milestone    : ₹{BILL_MILESTONE_RS}")
    print(f"{'='*55}")
    print(f"\n  ESP32 reading topics subscribed:")
    print(f"    {ESP32_VOLTAGE_TOPIC}  ->  Firebase EnergyReadings/live/{METER_ID}/voltage")
    print(f"    {ESP32_CURRENT_TOPIC}  ->  Firebase EnergyReadings/live/{METER_ID}/current")
    print(f"    {ESP32_POWER_TOPIC}    ->  Firebase EnergyReadings/live/{METER_ID}/power")
    print(f"\n  App device control topics published:")
    print(f"    LED 1   ->  app/led1          (\"1\"/\"0\")")
    print(f"    LED 2   ->  app/led2          (\"1\"/\"0\")")
    print(f"    LED 3   ->  app/led3          (\"1\"/\"0\")")
    print(f"    Motor 1 ->  app/motor1/speed  (\"255\" ON / \"0\" OFF)")
    print(f"    Motor 2 ->  app/motor2/speed  (\"255\" ON / \"0\" OFF)")
    print(f"\nRunning... Press Ctrl+C to stop.\n")

    while True:
        time.sleep(1)

except KeyboardInterrupt:
    print("\nShutting down gracefully...")
    for t in idle_timers.values():
        t.cancel()
    client.loop_stop()
    client.disconnect()
    print("Disconnected. Bye!")

except Exception as e:
    print(f"Critical error: {e}")
    import traceback
    traceback.print_exc()
