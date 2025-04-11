from flask import Flask, request, jsonify
import subprocess
import os

app = Flask(__name__)

# Get API key from environment variable (will be populated by the secret reference)
API_KEY_PATH = os.environ.get("API_KEY_PATH")
if API_KEY_PATH:
    with open(API_KEY_PATH, "r") as file:
        API_KEY = file.read().strip()

# Middleware to check API key
def check_api_key():
    auth_header = request.headers.get("Authorization")
    if not auth_header or auth_header.split("Bearer ")[-1] != API_KEY:
        return jsonify({"error": "Unauthorized"}), 401
    return None  # Success case

@app.route("/api/server/start", methods=["POST"])
def start_server():
    auth_response = check_api_key()
    if auth_response:
        return auth_response
    
    try:
        subprocess.run(["sudo", "systemctl", "start", "minecraft-server-paradisum.service"], check=True)
        return jsonify({"status": "started"}), 200
    except subprocess.CalledProcessError as e:
        return jsonify({"error": str(e)}), 500

@app.route("/api/server/stop", methods=["POST"])
def stop_server():
    auth_response = check_api_key()
    if auth_response:
        return auth_response

    try:
        subprocess.run(["sudo", "systemctl", "stop", "minecraft-server-paradisum.service"], check=True)
        return jsonify({"status": "stopped"}), 200
    except subprocess.CalledProcessError as e:
        return jsonify({"error": str(e)}), 500


if __name__ == "__main__":
    port = os.environ.get("FLASK_RUN_PORT")
    if port:
        port = int(port)  # Convert the port to an integer
    else:
        port = 5000  # Default to port 5000 if not set

    app.run(host="0.0.0.0", port=port)


