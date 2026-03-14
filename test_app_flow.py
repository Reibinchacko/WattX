import time
from appium import webdriver
from appium.options.android import UiAutomator2Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

# Configure capabilities
caps = {
    "platformName": "Android",
    "automationName": "UiAutomator2",
    "deviceName": "Android",
    "appPackage": "com.example.energy_monitor",
    "appActivity": ".MainActivity",
    "app": r"c:\Users\ACER\OneDrive\Documents\WattX-main (2)\WattX-main\build\app\outputs\apk\debug\app-debug.apk",
    "noReset": True,  # Keep login state if already logged in
    "ensureWebviewsHavePages": True,
    "nativeWebScreenshot": True,
    "newCommandTimeout": 3600,
    "connectHardwareKeyboard": True
}

options = UiAutomator2Options().load_capabilities(caps)

def run_tests():
    print("\n🚀 Starting WattX App Automation Suite...")
    driver = webdriver.Remote("http://127.0.0.1:4723", options=options)
    wait = WebDriverWait(driver, 20)

    try:
        # 1. Verify App Launch
        print("✅ App launched. Waiting for splash screen to pass...")
        time.sleep(3) # Wait for splash

        # 2. Login Flow (if not already logged in)
        try:
            # Look for Email field by text
            email_field = wait.until(EC.presence_of_element_located((By.XPATH, "//android.widget.EditText[contains(@text, 'email')]")))
            print("🔑 Login screen detected. Starting login flow...")
            
            email_field.send_keys("reibin@gmail.com")
            
            password_field = driver.find_element(By.XPATH, "//android.widget.EditText[contains(@text, 'password')]")
            password_field.send_keys("password123") # Replace with valid password if known
            
            login_btn = driver.find_element(By.XPATH, "//android.widget.Button[@content-desc='Log In' or @text='Log In']")
            login_btn.click()
            print("➡️ Login button clicked.")
        except Exception:
            print("ℹ️ Login screen not found, assuming already logged in or on Dashboard.")

        # 3. Dashboard Verification
        print("📊 Verifying Dashboard...")
        live_power_text = wait.until(EC.presence_of_element_located((By.XPATH, "//*[contains(@text, 'LIVE POWER USAGE')]")))
        print(f"✅ Dashboard confirmed: Found '{live_power_text.text}'")

        # 4. Navigation Verification
        print("🧭 Testing Bottom Navigation...")
        control_nav = wait.until(EC.element_to_be_clickable((By.XPATH, "//*[@content-desc='Control' or @text='Control']")))
        control_nav.click()
        print("✅ Navigated to Control Screen.")

        # 5. Toggle Device (Quick Check)
        print("💡 Testing Device Toggles...")
        led_toggle = wait.until(EC.presence_of_element_located((By.XPATH, "//*[contains(@text, 'Light 1')]")))
        led_toggle.click()
        print("✅ Toggled 'Light 1'.")

        print("\n✨ All tests passed successfully!")

    except Exception as e:
        print(f"\n❌ Test failed: {str(e)}")
    finally:
        print("🔌 Closing driver...")
        driver.quit()

if __name__ == "__main__":
    run_tests()
