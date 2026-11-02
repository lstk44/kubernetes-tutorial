import os
import requests

def main():
    # Read configuration values injected via environment variables from the ConfigMap
    log_level = os.getenv("LOG_LEVEL", "info")
    app_mode = os.getenv("APP_MODE", "production")
    max_retries = os.getenv("MAX_RETRIES", "1")

    print(f"Starting application...")
    print(f"Configuration loaded -> LOG_LEVEL: {log_level}, APP_MODE: {app_mode}, MAX_RETRIES: {max_retries}")

    # Confirming the imported dependency is active and ready
    print(f"Requests library successfully loaded for network operations.")

    # Simulate an operational task based on configuration
    if app_mode == "development":
        print("Running in development diagnostic mode.")
    else:
        print("Running in standard operational mode.")

    print("Application executed successfully.")

if __name__ == "__main__":
    main()
