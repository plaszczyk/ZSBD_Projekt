create or replace PROCEDURE Dodaj_Rezerwacje(
    p_seans_id NUMBER,
    p_imie VARCHAR2,
    p_nazwisko VARCHAR2,
    p_email VARCHAR2,
    p_miejsc NUMBER
) IS
    zajete NUMBER;
    dostepne NUMBER;
    v_opis VARCHAR2(3000);
BEGIN
    SELECT SUM(LICZBA_MIEJSC) INTO zajete FROM REZERWACJA WHERE ID_SEANS = p_seans_id;
    SELECT S.LICZBA_MIEJSC INTO dostepne
    FROM SALA S JOIN SEANS SE ON SE.ID_SALA = S.ID_SALA
    WHERE SE.ID_SEANS = p_seans_id;

    IF NOT WERYFIKACJA_EMAIL(p_email) THEN
        RAISE_APPLICATION_ERROR(-20002, 'Niepoprawny adres e-mail');
    END IF;

    IF zajete + p_miejsc > dostepne THEN
        RAISE_APPLICATION_ERROR(-20001, 'Brak dostępnych miejsc');
    END IF;
    

    INSERT INTO REZERWACJA(ID_SEANS, IMIE, NAZWISKO, EMAIL, LICZBA_MIEJSC)
    VALUES (p_seans_id, p_imie, p_nazwisko, p_email, p_miejsc);

    INSERT INTO LOG_OPERACJI(NAZWA_TABELI, OPERACJA, UZYTKOWNIK, OPIS)
    VALUES ('REZERWACJA', 'INSERT', USER, 'Dodano rezerwację dla ' || p_miejsc || ' osób na seans ' || p_seans_id);

EXCEPTION
    WHEN OTHERS THEN
        BEGIN
            v_opis := SQLERRM;
            INSERT INTO LOG_OPERACJI(NAZWA_TABELI, OPERACJA, UZYTKOWNIK, OPIS)
            VALUES ('REZERWACJA', 'ERROR', USER, v_opis);
            COMMIT;
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;
        RAISE;    

END;