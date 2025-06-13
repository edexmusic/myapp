from flask import Flask

app = Flask(__name__)

@app.route("/")
def hello():
    return "Hello from Flask inside Docker! 🚀"

if __name__ == "__main__":
    # 0.0.0.0 потрібен, щоб Flask слухав на всіх інтерфейсах
    app.run(host="0.0.0.0", port=80)
