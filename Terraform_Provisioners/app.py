from flask import Flask

app = Flask(__name__)

@app.route("/")
def hello():
    return "Hello Everyone! This is a simple python flask applicaion deployed in ec2 instances using terraform with the help of provisioners. This is a day-to-day task of DevOps engineers"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)