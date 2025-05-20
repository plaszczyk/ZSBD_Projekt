CREATE OR REPLACE TRIGGER archiwizuj_rezerwacje
BEFORE DELETE ON REZERWACJA
FOR EACH ROW
BEGIN
    INSERT INTO ARCHIWUM_REZERWACJI (
        ID_REZ,
        ID_SEANS,
        IMIE,
        NAZWISKO,
        EMAIL,
        LICZBA_MIEJSC,
        DATA_REZERWACJI
    ) VALUES (
        :OLD.ID_REZ,
        :OLD.ID_SEANS,
        :OLD.IMIE,
        :OLD.NAZWISKO,
        :OLD.EMAIL,
        :OLD.LICZBA_MIEJSC,
        :OLD.DATA_REZERWACJI
    );

    INSERT INTO LOG_OPERACJI(NAZWA_TABELI, OPERACJA, UZYTKOWNIK, OPIS)
    VALUES ('REZERWACJA', 'DELETE', USER, 'Rezerwacja przeniesiona do archiwum');
END;
