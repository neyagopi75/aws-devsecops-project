from flask import Flask

app = Flask(__name__)

@app.get("/")
def hello():
    return "Hello World - AWS DevSecOps Platform!"

@app.get("/health")
def health():
    return {"status": "healthy"}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
