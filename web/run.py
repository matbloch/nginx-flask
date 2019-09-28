from flask import Flask
application = Flask("My Flask Application")

@application.route("/")
def hello():
    return "Hello world"

if __name__ == "__main__":
    application.run()
