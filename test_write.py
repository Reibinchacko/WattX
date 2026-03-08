"""
Direct Firebase write test.
Run this and check if the app shows the values.
"""
import firebase_admin
from firebase_admin import credentials, db
import time

FIREBASE_KEY_PATH = r"C:\Users\ACER\Downloads\wattx-16024-firebase-adminsdk-fbsvc-0a16dc3bb8.json"
DATABASE_URL = "https://wattx-16024-default-rtdb.firebaseio.com/"

print("Initializing Firebase...")
cred = credentials.Certificate(FIREBASE_KEY_PATH)
firebase_admin.initialize_app(cred, {'databaseURL': DATABASE_URL})
print("Firebase OK\n")

# ---------- Read what is currently in Firebase ----------
print("=" * 50)
print("CURRENT DATA in EnergyReadings/live/METER001:")
print("=" * 50)
snap = db.reference("EnergyReadings/live/METER001").get()
if snap:
    for k, v in snap.items():
        print(f"  {k}: {v}")
else:
    print("  (EMPTY - nothing stored here!)")

print()

# ---------- Write known test values ----------
print("=" * 50)
print("WRITING TEST VALUES...")
print("=" * 50)

test_data = {
    "voltage": 230.5,
    "current": 1.500,
    "power":   0.3457,   # kW
    "frequency":   50.0,
    "powerFactor": 0.92,
    "timestamp": int(time.time() * 1000),
}

db.reference("EnergyReadings/live/METER001").set(test_data)
print("Written:")
for k, v in test_data.items():
    print(f"  {k}: {v}")

print()
print("NOW CHECK YOUR APP:")
print("  Dashboard -> should show 0.35 kW, 230.5V, 1.5A")
print()

# ---------- Verify it was saved ----------
time.sleep(1)
print("=" * 50)
print("VERIFYING - reading back from Firebase:")
print("=" * 50)
verify = db.reference("EnergyReadings/live/METER001").get()
if verify:
    for k, v in verify.items():
        print(f"  {k}: {v}")
    print("\nIf app still shows nothing, the Flutter Firebase path is WRONG.")
else:
    print("  WRITE FAILED - data not saved!")
