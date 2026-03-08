
/*
 * WattX - ESP8266 + L298N Motor Driver Fan Control
 * Controls 2 DC motor fans via L298N H-Bridge
 * Reads commands from Firebase Realtime Database via MQTT
 *
 * Hardware:
 *   ESP8266 NodeMCU v3
 *   L298N Dual H-Bridge Motor Driver
 *   2x DC Motor (Fan 1 & Fan 2)
 *   PZEM-004T v3.0 (energy meter sensor)
 *
 * L298N Pin Connections:
 *   IN1 -> D1 (GPIO5)   - Fan1 direction A
 *   IN2 -> D2 (GPIO4)   - Fan1 direction B
 *   IN3 -> D5 (GPIO14)  - Fan2 direction A
 *   IN4 -> D6 (GPIO12)  - Fan2 direction B
 *   ENA -> D7 (GPIO13)  - Fan1 enable (PWM speed)
 *   ENB -> D8 (GPIO15)  - Fan2 enable (PWM speed)
 *   GND -> GND (shared)
 *   12V -> External 12V DC supply
 *
 * MQTT Topics:
 *   Subscribe: METER001/controls  (receive fan1/fan2 ON/OFF commands)
 *   Publish:   METER001/readings  (publish energy sensor data)
 *   Publish:   METER001/status    (publish fan states)
 */

#include <ESP8266WiFi.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>
#include <SoftwareSerial.h>
#include <PZEM004Tv30.h>

// ============================================================
// WIFI CONFIGURATION - Change to your WiFi credentials
// ============================================================
const char* WIFI_SSID     = "YOUR_WIFI_SSID";
const char* WIFI_PASSWORD = "YOUR_WIFI_PASSWORD";

// ============================================================
// MQTT BROKER CONFIGURATION (HiveMQ Cloud)
// ============================================================
const char* MQTT_BROKER   = "YOUR_CLUSTER.hivemq.cloud";
const int   MQTT_PORT     = 1883;                   // Use 8883 for TLS
const char* MQTT_USER     = "YOUR_MQTT_USERNAME";
const char* MQTT_PASS     = "YOUR_MQTT_PASSWORD";
const char* METER_ID      = "METER001";

// MQTT Topics
const char* TOPIC_CONTROLS = "METER001/controls";   // subscribe
const char* TOPIC_READINGS = "METER001/readings";   // publish
const char* TOPIC_STATUS   = "METER001/status";     // publish

// ============================================================
// L298N MOTOR DRIVER PIN DEFINITIONS
// ============================================================
// Fan 1 (Motor A)
#define FAN1_IN1  5    // D1 - GPIO5  - Fan1 Forward
#define FAN1_IN2  4    // D2 - GPIO4  - Fan1 Backward (set LOW for ON)
#define FAN1_ENA  13   // D7 - GPIO13 - Fan1 PWM speed control

// Fan 2 (Motor B)
#define FAN2_IN3  14   // D5 - GPIO14 - Fan2 Forward
#define FAN2_IN4  12   // D6 - GPIO12 - Fan2 Backward (set LOW for ON)
#define FAN2_ENB  15   // D8 - GPIO15 - Fan2 PWM speed control

// Fan speed (0-255 PWM, 255 = full speed, 128 = half speed)
#define FAN_SPEED 200  // Default speed (78% of full speed)

// ============================================================
// PZEM-004T ENERGY SENSOR
// ============================================================
// PZEM TX -> D3 (GPIO0), PZEM RX -> D4 (GPIO2)
SoftwareSerial pzemSerial(0, 2); // RX=GPIO0, TX=GPIO2
PZEM004Tv30 pzem(pzemSerial);

// ============================================================
// GLOBAL STATE VARIABLES
// ============================================================
bool fan1State = false;   // false = OFF, true = ON
bool fan2State = false;

WiFiClient   espClient;
PubSubClient mqttClient(espClient);

unsigned long lastReadingTime  = 0;
unsigned long lastReconnectTime = 0;
const long    READING_INTERVAL = 2000;    // Publish readings every 2 seconds
const long    RECONNECT_INTERVAL = 5000;  // Try reconnect every 5 seconds

// ============================================================
// SETUP
// ============================================================
void setup() {
  Serial.begin(115200);
  delay(100);
  Serial.println("\n\n=== WattX L298N Fan Controller ===");

  // Initialize L298N motor driver pins
  initL298N();

  // Connect to WiFi
  connectWiFi();

  // Configure MQTT
  mqttClient.setServer(MQTT_BROKER, MQTT_PORT);
  mqttClient.setCallback(onMqttMessage);
  mqttClient.setBufferSize(512);

  // Connect to MQTT broker
  connectMQTT();

  Serial.println("Setup complete. Starting main loop...");
}

// ============================================================
// MAIN LOOP
// ============================================================
void loop() {
  // Maintain MQTT connection
  if (!mqttClient.connected()) {
    unsigned long now = millis();
    if (now - lastReconnectTime >= RECONNECT_INTERVAL) {
      lastReconnectTime = now;
      connectMQTT();
    }
  } else {
    mqttClient.loop();    // Process incoming MQTT messages
  }

  // Publish energy readings every 2 seconds
  unsigned long now = millis();
  if (now - lastReadingTime >= READING_INTERVAL) {
    lastReadingTime = now;
    publishEnergyReading();
  }
}

// ============================================================
// L298N INITIALIZATION
// ============================================================
void initL298N() {
  Serial.println("Initializing L298N motor driver pins...");

  // Fan 1 pins
  pinMode(FAN1_IN1, OUTPUT);
  pinMode(FAN1_IN2, OUTPUT);
  pinMode(FAN1_ENA, OUTPUT);

  // Fan 2 pins
  pinMode(FAN2_IN3, OUTPUT);
  pinMode(FAN2_IN4, OUTPUT);
  pinMode(FAN2_ENB, OUTPUT);

  // Start with both fans OFF
  setFan1(false);
  setFan2(false);

  Serial.println("L298N initialized. Both fans OFF.");
}

// ============================================================
// FAN CONTROL FUNCTIONS
// ============================================================

/*
 * Control Fan 1 (Motor A on L298N)
 * Fan ON:  IN1=HIGH, IN2=LOW, ENA=PWM(FAN_SPEED) -> motor spins forward
 * Fan OFF: IN1=LOW,  IN2=LOW, ENA=LOW             -> motor stops
 */
void setFan1(bool turnOn) {
  fan1State = turnOn;
  if (turnOn) {
    digitalWrite(FAN1_IN1, HIGH);   // Forward direction
    digitalWrite(FAN1_IN2, LOW);    // Reverse pin LOW
    analogWrite(FAN1_ENA, FAN_SPEED); // PWM speed (0-255)
    Serial.println("[FAN1] -> ON (speed=" + String(FAN_SPEED) + ")");
  } else {
    digitalWrite(FAN1_IN1, LOW);    // Stop forward
    digitalWrite(FAN1_IN2, LOW);    // Stop reverse
    analogWrite(FAN1_ENA, 0);       // Disable enable pin -> motor stop
    Serial.println("[FAN1] -> OFF");
  }
}

/*
 * Control Fan 2 (Motor B on L298N)
 * Fan ON:  IN3=HIGH, IN4=LOW, ENB=PWM(FAN_SPEED) -> motor spins forward
 * Fan OFF: IN3=LOW,  IN4=LOW, ENB=LOW             -> motor stops
 */
void setFan2(bool turnOn) {
  fan2State = turnOn;
  if (turnOn) {
    digitalWrite(FAN2_IN3, HIGH);   // Forward direction
    digitalWrite(FAN2_IN4, LOW);    // Reverse pin LOW
    analogWrite(FAN2_ENB, FAN_SPEED); // PWM speed (0-255)
    Serial.println("[FAN2] -> ON (speed=" + String(FAN_SPEED) + ")");
  } else {
    digitalWrite(FAN2_IN3, LOW);
    digitalWrite(FAN2_IN4, LOW);
    analogWrite(FAN2_ENB, 0);
    Serial.println("[FAN2] -> OFF");
  }
}

/*
 * Set fan speed using PWM (0-255)
 * 255 = 100% speed, 128 = 50% speed, 0 = stop
 * Can be called separately for variable speed control
 */
void setFan1Speed(int speed) {
  speed = constrain(speed, 0, 255);
  if (speed > 0) {
    digitalWrite(FAN1_IN1, HIGH);
    digitalWrite(FAN1_IN2, LOW);
  }
  analogWrite(FAN1_ENA, speed);
  Serial.println("[FAN1] Speed set to: " + String(speed));
}

void setFan2Speed(int speed) {
  speed = constrain(speed, 0, 255);
  if (speed > 0) {
    digitalWrite(FAN2_IN3, HIGH);
    digitalWrite(FAN2_IN4, LOW);
  }
  analogWrite(FAN2_ENB, speed);
  Serial.println("[FAN2] Speed set to: " + String(speed));
}

// ============================================================
// MQTT MESSAGE CALLBACK
// Called when a message arrives on subscribed topics
// ============================================================
void onMqttMessage(char* topic, byte* payload, unsigned int length) {
  // Convert payload bytes to String
  String message = "";
  for (unsigned int i = 0; i < length; i++) {
    message += (char)payload[i];
  }

  Serial.println("=== MQTT Message Received ===");
  Serial.println("Topic  : " + String(topic));
  Serial.println("Payload: " + message);
  Serial.println("============================");

  // Parse JSON payload
  // Expected format: {"fan1":true,"fan2":false}
  //            or:   {"fan1":true}
  //            or:   {"fan1Speed":200,"fan2Speed":150}

  StaticJsonDocument<256> doc;
  DeserializationError error = deserializeJson(doc, message);

  if (error) {
    Serial.println("JSON parse error: " + String(error.c_str()));
    return;
  }

  // --- Fan 1 ON/OFF control ---
  if (doc.containsKey("fan1")) {
    bool newFan1State = doc["fan1"].as<bool>();
    if (newFan1State != fan1State) {
      setFan1(newFan1State);
    }
  }

  // --- Fan 2 ON/OFF control ---
  if (doc.containsKey("fan2")) {
    bool newFan2State = doc["fan2"].as<bool>();
    if (newFan2State != fan2State) {
      setFan2(newFan2State);
    }
  }

  // --- Fan 1 speed control (0-255) ---
  if (doc.containsKey("fan1Speed")) {
    int speed = doc["fan1Speed"].as<int>();
    setFan1Speed(speed);
  }

  // --- Fan 2 speed control (0-255) ---
  if (doc.containsKey("fan2Speed")) {
    int speed = doc["fan2Speed"].as<int>();
    setFan2Speed(speed);
  }

  // Publish updated status back to broker
  publishStatus();
}

// ============================================================
// PUBLISH ENERGY READINGS (from PZEM-004T)
// ============================================================
void publishEnergyReading() {
  float voltage     = pzem.voltage();
  float current     = pzem.current();
  float power       = pzem.power();
  float energy      = pzem.energy();
  float frequency   = pzem.frequency();
  float powerFactor = pzem.pf();

  // Handle NaN from PZEM (no load connected or sensor error)
  if (isnan(voltage))     voltage     = 0.0;
  if (isnan(current))     current     = 0.0;
  if (isnan(power))       power       = 0.0;
  if (isnan(frequency))   frequency   = 50.0;
  if (isnan(powerFactor)) powerFactor = 1.0;

  // Build JSON payload
  StaticJsonDocument<256> doc;
  doc["meterId"]     = METER_ID;
  doc["voltage"]     = voltage;
  doc["current"]     = current;
  doc["power"]       = power / 1000.0;  // Convert W to kW
  doc["energy"]      = energy;          // kWh cumulative
  doc["frequency"]   = frequency;
  doc["powerFactor"] = powerFactor;
  doc["fan1"]        = fan1State;
  doc["fan2"]        = fan2State;
  doc["timestamp"]   = millis();        // Relative timestamp (ms since boot)

  char jsonBuffer[256];
  serializeJson(doc, jsonBuffer);

  // Publish to MQTT broker
  if (mqttClient.connected()) {
    bool published = mqttClient.publish(TOPIC_READINGS, jsonBuffer, false);
    if (published) {
      Serial.println("Published: " + String(jsonBuffer));
    } else {
      Serial.println("Publish failed! Buffer size exceeded?");
    }
  }
}

// ============================================================
// PUBLISH DEVICE STATUS
// ============================================================
void publishStatus() {
  StaticJsonDocument<128> doc;
  doc["fan1"] = fan1State;
  doc["fan2"] = fan2State;

  char jsonBuffer[128];
  serializeJson(doc, jsonBuffer);

  if (mqttClient.connected()) {
    mqttClient.publish(TOPIC_STATUS, jsonBuffer, false);
    Serial.println("Status published: " + String(jsonBuffer));
  }
}

// ============================================================
// WIFI CONNECTION
// ============================================================
void connectWiFi() {
  Serial.print("Connecting to WiFi: ");
  Serial.println(WIFI_SSID);

  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
    attempts++;
    if (attempts > 40) {
      Serial.println("\nWiFi connection failed! Restarting...");
      ESP.restart();
    }
  }

  Serial.println("\nWiFi connected!");
  Serial.println("IP Address: " + WiFi.localIP().toString());
  Serial.println("Signal strength (RSSI): " + String(WiFi.RSSI()) + " dBm");
}

// ============================================================
// MQTT CONNECTION
// ============================================================
void connectMQTT() {
  Serial.print("Connecting to MQTT broker: ");
  Serial.println(MQTT_BROKER);

  String clientId = "WattX_ESP8266_" + String(ESP.getChipId(), HEX);

  if (mqttClient.connect(clientId.c_str(), MQTT_USER, MQTT_PASS)) {
    Serial.println("MQTT connected! Client ID: " + clientId);

    // Subscribe to control commands
    if (mqttClient.subscribe(TOPIC_CONTROLS)) {
      Serial.println("Subscribed to: " + String(TOPIC_CONTROLS));
    } else {
      Serial.println("Subscribe FAILED!");
    }

    // Publish initial status
    publishStatus();

  } else {
    Serial.print("MQTT connection FAILED. State: ");
    Serial.println(mqttClient.state());
    // States: -4=TIMEOUT, -3=LOST, -2=FAILED, -1=DISCONNECTED
    // 0=CONNECTED, 1=BAD_PROTOCOL, 2=BAD_CLIENT_ID, 3=UNAVAILABLE
    // 4=BAD_CREDENTIALS, 5=UNAUTHORIZED
  }
}
