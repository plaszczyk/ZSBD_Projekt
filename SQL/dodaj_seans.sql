create or replace PROCEDURE Dodaj_Seans (
    p_id_film IN SEANS.ID_FILM%TYPE,
    p_id_sala IN SEANS.ID_SALA%TYPE,
    p_data_godzina IN SEANS.DATA_GODZINA%TYPE,
    p_cena_biletu IN SEANS.CENA_BILETU%TYPE DEFAULT 15.00
) IS
    v_czas_trwania NUMBER;
    v_kolizje NUMBER;
    v_opis VARCHAR(3000);
BEGIN

    SELECT CZAS_TRWANIA INTO v_czas_trwania
    FROM FILM
    WHERE ID_FILM = p_id_film;

    SELECT COUNT(*) INTO v_kolizje
    FROM SEANS s
    JOIN FILM f ON s.ID_FILM = f.ID_FILM
    WHERE s.ID_SALA = p_id_sala
      AND (
            p_data_godzina BETWEEN s.DATA_GODZINA AND (s.DATA_GODZINA + (f.CZAS_TRWANIA / 1440))
            OR
            (p_data_godzina + (v_czas_trwania / 1440)) BETWEEN s.DATA_GODZINA AND (s.DATA_GODZINA + (f.CZAS_TRWANIA / 1440))
            OR
            s.DATA_GODZINA BETWEEN p_data_godzina AND (p_data_godzina + (v_czas_trwania / 1440))
        );

    IF v_kolizje > 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Sala jest już zajęta w tym terminie.');
    END IF;

    INSERT INTO SEANS (ID_FILM, ID_SALA, DATA_GODZINA, CENA_BILETU)
    VALUES (p_id_film, p_id_sala, p_data_godzina, p_cena_biletu);

    INSERT INTO LOG_OPERACJI(NAZWA_TABELI, OPERACJA, UZYTKOWNIK, OPIS)
    VALUES ('SEANS', 'INSERT', USER, 'Dodano nowy seans filmu ' || p_id_film || ' na sali ' || p_id_sala);

EXCEPTION
    WHEN OTHERS THEN
        BEGIN
	    v_opis := SQLERRM;
            INSERT INTO LOG_OPERACJI(NAZWA_TABELI, OPERACJA, UZYTKOWNIK, OPIS)
            VALUES ('SEANS', 'ERROR', USER, v_opis);
            COMMIT;
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
        RAISE;
END;