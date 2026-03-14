from appium import webdriver
from appium.options.android import UiAutomator2Options

caps = {
    "platformName": "Android",
    "automationName": "UiAutomator2",
    "deviceName": "Android",
    "appPackage": "com.example.energy_monitor",
    "appActivity": ".MainActivity",
}

options = UiAutomator2Options().load_capabilities(caps)

driver = webdriver.Remote(
    "http://127.0.0.1:4723",
    options=options,
)

print("App Launched Successfully")
driver.quit()