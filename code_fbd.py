import json
import psycopg2

# Carregar credenciais do JSON
with open("config.json", "r") as file:
    config = json.load(file)

# Extrair as variáveis
DB_HOST = config["DB_HOST"]
DB_PORT = config["DB_PORT"]
DB_NAME = config["DB_NAME"]
DB_USER = config["DB_USER"]
DB_PASS = config["DB_PASS"]

try:
    # Conectar ao PostgreSQL
    conn = psycopg2.connect(
        host=DB_HOST,
        port=DB_PORT,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASS
    )
    
    cur = conn.cursor()
    
    # Consulta para listar todas as tabelas do esquema público
    cur.execute("""
    SELECT table_name, column_name, data_type 
    FROM information_schema.columns 
    WHERE table_schema = 'public'
    ORDER BY table_name, ordinal_position;
    """)

    columns = cur.fetchall()

    print("\n📌 Estrutura das tabelas:")
    current_table = None
    for table, column, dtype in columns:
        if table != current_table:
            print(f"\n📌 {table.upper()}:")
            current_table = table
        print(f"   - {column} ({dtype})")

    cur.close()
    conn.close()

except Exception as e:
    print("Erro ao conectar ao banco:", e)