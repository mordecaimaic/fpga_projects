from flask import Flask, render_template, request
from cs50 import SQL
from helpers import random_string

app = Flask(__name__)
db = SQL("sqlite:///history.db")

@app.route("/", methods=["GET", "POST"])
def index():
    if request.method == "GET":
        history=db.execute("SELECT * FROM history;")
        return render_template('index.html', rows=history)
    elif request.method == "POST":
        if request.form.get("clear") == "true":
            db.execute("DELETE FROM history")
            history=db.execute("SELECT * FROM history;")
            return render_template('index.html', rows=history)
        try:
            num = int(request.form.get('page'))
        except ValueError:
            return("Input a number!")
        if num <= 0:
            return("Input a positive integer!")
        db.execute("INSERT INTO history (pages) VALUES (?);", num)
        history=db.execute("SELECT * FROM history;")
        return render_template('index.html', random_text=random_string(num), rows=history)