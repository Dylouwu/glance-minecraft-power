from flask import Flask, request, jsonify
import subprocess
import os

app = Flask(__name__)

# Get API key from environment variable (will be populated by the secret reference)
API_KEY = os.environ.get("MINECRAFT_API_KEY")

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
        subprocess.run(["systemctl", "start", "minecraft-server-paradisum.service"], check=True)
        return jsonify({"status": "started"}), 200
    except subprocess.CalledProcessError as e:
        return jsonify({"error": str(e)}), 500

@app.route("/api/server/stop", methods=["POST"])
def stop_server():
    auth_response = check_api_key()
    if auth_response:
        return auth_response

    try:
        subprocess.run(["systemctl", "stop", "minecraft-server-paradisum.service"], check=True)
        return jsonify({"status": "stopped"}), 200
    except subprocess.CalledProcessError as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
