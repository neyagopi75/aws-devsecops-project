
from flask import Flask
from prometheus_flask_exporter import PrometheusMetrics

app = Flask(__name__)

# Enable Prometheus metrics endpoint
metrics = PrometheusMetrics(app)

# Application information
metrics.info(
    "app_info",
    "AWS DevSecOps application information",
    version="1.0.0"
)

@app.get("/")
def hello():
    return "Hello World - AWS DevSecOps Platform!"

@app.get("/health")
def health():
    return {"status": "healthy"}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
