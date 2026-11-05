from flask import Flask, request, redirect, render_template_string
import psycopg
from dotenv import load_dotenv
import os

load_dotenv()

app = Flask(__name__)

def conectar():
    return psycopg.connect(
        host=os.getenv("DB_HOST"),
        port=os.getenv("DB_PORT"),
        dbname=os.getenv("DB_NAME"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD")
    )

@app.route("/", methods=["GET", "POST"])
def inicio():
    if request.method == "POST":
        nome = request.form["nome"]
        email = request.form["email"]

        with conectar() as conn:
            conn.execute(
                "INSERT INTO usuarios (nome, email) VALUES (%s, %s)",
                (nome, email)
            )

        return redirect("/")

    with conectar() as conn:
        usuarios = conn.execute(
            "SELECT id, nome, email, criado_em FROM usuarios ORDER BY id DESC"
        ).fetchall()

    return render_template_string("""
        <!DOCTYPE html>
        <html lang="pt-BR">
        <head>
            <meta charset="UTF-8">
            <title>Projeto de Redes</title>
            <style>
                body {
                    font-family: Arial, sans-serif;
                    background: #f2f4f8;
                    margin: 40px;
                }
                main {
                    max-width: 700px;
                    margin: auto;
                    background: white;
                    padding: 25px;
                    border-radius: 10px;
                }
                input, button {
                    padding: 10px;
                    margin: 5px 0;
                    width: 100%;
                    box-sizing: border-box;
                }
                button {
                    background: #1769aa;
                    color: white;
                    border: none;
                    cursor: pointer;
                }
                li {
                    margin: 12px 0;
                }
            </style>
        </head>
        <body>
            <main>
                <h1>Cadastro de usuários</h1>
                <form method="POST">
                    <input name="nome" placeholder="Nome" required>
                    <input name="email" type="email" placeholder="E-mail" required>
                    <button type="submit">Cadastrar</button>
                </form>

                <h2>Usuários cadastrados</h2>
                <ul>
                    {% for usuario in usuarios %}
                        <li>
                            {{ usuario[1] }} — {{ usuario[2] }}
                        </li>
                    {% else %}
                        <li>Nenhum usuário cadastrado.</li>
                    {% endfor %}
                </ul>
            </main>
        </body>
        </html>
    """, usuarios=usuarios)

if __name__ == "__main__":
    app.run(host="127.0.0.1", port=5000)
