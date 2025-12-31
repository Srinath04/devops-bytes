from flask import Flask, render_template_string, request, session, redirect, url_for
import random

app = Flask(__name__)
app.secret_key = 'secret123'  # Needed for session management

HTML_TEMPLATE = '''
<!DOCTYPE html>
<html>
<head><title>Guess The Number</title></head>
<body>
  <h2>I am thinking of a number between 1 and 20</h2>
  {% if message %}<p><strong>{{ message }}</strong></p>{% endif %}
  {% if not game_over %}
    <form method="post">
      <input type="number" name="guess" min="1" max="20" required>
      <button type="submit">Guess</button>
    </form>
  {% else %}
    <a href="/">Play Again</a>
  {% endif %}
</body>
</html>
'''

@app.route("/", methods=["GET", "POST"])
def index():
    if 'secret' not in session or 'attempts' not in session:
        session['secret'] = random.randint(1, 20)
        session['attempts'] = 0
        session['max_attempts'] = 5

    message = ""
    game_over = False

    if request.method == "POST":
        try:
            guess = int(request.form["guess"])
            session['attempts'] += 1

            if guess == session['secret']:
                message = f"Good job! You guessed it in {session['attempts']} tries!"
                game_over = True
            elif session['attempts'] >= session['max_attempts']:
                message = f"Nope. The number was {session['secret']}."
                game_over = True
            elif guess < session['secret']:
                message = "Your guess is low."
            else:
                message = "Your guess is high."

        except:
            message = "Invalid input!"

    if game_over:
        session.clear()

    return render_template_string(HTML_TEMPLATE, message=message, game_over=game_over)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

