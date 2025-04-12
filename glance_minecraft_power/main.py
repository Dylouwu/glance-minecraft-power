from flask import Flask, request, jsonify
import subprocess
import os

app = Flask(__name__)

MINECRAFT_SERVER_NAME = os.environ.get("MINECRAFT_SERVER_NAME")
API_KEY_PATH = os.environ.get("API_KEY_PATH")
if API_KEY_PATH:
    with open(API_KEY_PATH, "r") as file:
        API_KEY = file.read().strip()


def check_api_key():
    auth_header = request.headers.get("Authorization")
    if not auth_header or auth_header.split("Bearer ")[-1] != API_KEY:
        return jsonify({"error": "Unauthorized"}), 401
    return None 


@app.route("/api/server/start", methods=["POST"])
def start_server():
    auth_response = check_api_key()
    if auth_response:
        return auth_response
    
    try:
        subprocess.run(["systemctl", "start", "minecraft-server-${MINECRAFT_SERVER_NAME}.service"], check=True)
        return jsonify({"status": "started"}), 200
    except subprocess.CalledProcessError as e:
        return jsonify({"error": str(e)}), 500


@app.route("/api/server/stop", methods=["POST"])
def stop_server():
    auth_response = check_api_key()
    if auth_response:
        return auth_response

    try:
        subprocess.run(["systemctl", "stop", "minecraft-server-${MINECRAFT_SERVER_NAME}.service"], check=True)
        return jsonify({"status": "stopped"}), 200
    except subprocess.CalledProcessError as e:
        return jsonify({"error": str(e)}), 500


def main():
    host = os.environ.get("FLASK_HOST")
    port = int(os.environ.get("FLASK_PORT", 5000))
    app.run(host=host, port=port)


# Ensure script still runs when executed directly
if __name__ == "__main__":
    main()
