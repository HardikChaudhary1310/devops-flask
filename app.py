import os
import time
from flask import Flask, jsonify

app = Flask(__name__)
START_TIME = time.time()
APP_ENV = os.getenv("APP_ENV", "development")
APP_VERSION = os.getenv("APP_VERSION", "1.0.0")


@app.route("/")
def index():
    return jsonify(message="DevOps assessment App!!!", env=APP_ENV, version=APP_VERSION)


@app.route("/health")
def health():
    return jsonify(status="healthy", uptime_seconds=round(time.time() - START_TIME, 2)), 200


if __name__ == "__main__":
    # FIX : bind to 0.0.0.0 (not 127.0.0.1) so the app is reachable from outside the container
    app.run(host="0.0.0.0", port=int(os.getenv("PORT", 5000)))
