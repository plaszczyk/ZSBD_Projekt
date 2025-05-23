import pandas as pd
import oracledb
import os
from datetime import datetime

dsn = oracledb.makedsn("213.184.8.44", 1521, service_name="orcl")
conn = oracledb.connect(user="###", password="###", dsn=dsn)
cursor = conn.cursor()

CSV_FILE = "filmy.csv"
ARCHIVE_FOLDER = "archiwum"
REJECTED_FILE = "odrzucone.csv"

def walidacja(row):
    try:
        if not isinstance(row["TYTUL"], str) or len(row["TYTUL"]) > 100:
            return False
        if not isinstance(row["GATUNEK"], str) or len(row["GATUNEK"]) > 50:
            return False
        if row["CZY_3D"] not in ('Y', 'N'):
            return False
        if row["CZY_DUBBING"] not in ('Y', 'N'):
            return False
        if not isinstance(row["CZAS_TRWANIA"], (int, float)) or row["CZAS_TRWANIA"] <= 0:
            return False
        return True
    except:
        return False

def przetworz_csv():
    df = pd.read_csv(CSV_FILE)

    maska_poprawne = df.apply(walidacja, axis=1)
    poprawne = df[maska_poprawne]
    odrzucone = df[~maska_poprawne]

    for index, row in poprawne.iterrows():
        try:
            cursor.execute("""
                INSERT INTO FILM (TYTUL, GATUNEK, CZY_3D, CZY_DUBBING, CZAS_TRWANIA)
                VALUES (:1, :2, :3, :4, :5)
            """, (
                row["TYTUL"],
                row["GATUNEK"],
                row["CZY_3D"],
                row["CZY_DUBBING"],
                int(row["CZAS_TRWANIA"])
            ))
        except Exception as e:
            print(f"Błąd przy dodawaniu filmu '{row['TYTUL']}': {e}")
    conn.commit()

    if not os.path.exists(ARCHIVE_FOLDER):
        os.makedirs(ARCHIVE_FOLDER)
    today_str = datetime.today().strftime('%Y-%m-%d')
    filename, ext = os.path.splitext(CSV_FILE)
    new_filename = f"{filename}_{today_str}{ext}"
    destination_path = os.path.join(ARCHIVE_FOLDER, new_filename)

    poprawne.to_csv(destination_path, index=False)

    if not odrzucone.empty:
        odrzucone.to_csv(REJECTED_FILE, index=False)

    os.remove(CSV_FILE)

if __name__ == "__main__":
    if os.path.exists(CSV_FILE):
        przetworz_csv()
    else:
        print("Brak pliku filmy.csv")