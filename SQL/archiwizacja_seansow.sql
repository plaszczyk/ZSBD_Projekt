create or replace TRIGGER archiwizuj_seanse
BEFORE DELETE ON SEANS
FOR EACH ROW
BEGIN
    INSERT INTO ARCHIWUM_SEANSOW (
        ID_SEANS,
        ID_FILM,
        ID_SALA,
        DATA_GODZINA,
        CENA_BILETU
    ) VALUES (
        :OLD.ID_SEANS,
        :OLD.ID_FILM,
        :OLD.ID_SALA,
        :OLD.DATA_GODZINA,
        :OLD.CENA_BILETU
    );

    INSERT INTO LOG_OPERACJI(NAZWA_TABELI, OPERACJA, UZYTKOWNIK, OPIS)
    VALUES ('REZERWACJA', 'DELETE', USER, 'Seans przeniesiony do archiwum');
END;