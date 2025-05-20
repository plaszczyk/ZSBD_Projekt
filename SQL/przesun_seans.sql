CREATE OR REPLACE PROCEDURE Przesun_seans (
    p_id_seans IN SEANS.ID_SEANS%TYPE,
    p_nowa_data_godzina IN SEANS.DATA_GODZINA%TYPE
) IS
    v_id_sala SEANS.ID_SALA%TYPE;
    v_id_film SEANS.ID_FILM%TYPE;
    v_czas_trwania NUMBER;
    v_kolizje NUMBER;
    v_opis VARCHAR2(3000);
BEGIN

    SELECT ID_SALA, ID_FILM INTO v_id_sala, v_id_film
    FROM SEANS
    WHERE ID_SEANS = p_id_seans;

    SELECT CZAS_TRWANIA INTO v_czas_trwania
    FROM FILM
    WHERE ID_FILM = v_id_film;

    SELECT COUNT(*) INTO v_kolizje
    FROM SEANS s
    JOIN FILM f ON s.ID_FILM = f.ID_FILM
    WHERE s.ID_SALA = v_id_sala
      AND s.ID_SEANS <> p_id_seans
      AND (
            p_nowa_data_godzina BETWEEN s.DATA_GODZINA AND (s.DATA_GODZINA + (f.CZAS_TRWANIA / 1440))
            OR
            (p_nowa_data_godzina + (v_czas_trwania / 1440)) BETWEEN s.DATA_GODZINA AND (s.DATA_GODZINA + (f.CZAS_TRWANIA / 1440))
            OR
            s.DATA_GODZINA BETWEEN p_nowa_data_godzina AND (p_nowa_data_godzina + (v_czas_trwania / 1440))
          );

    IF v_kolizje > 0 THEN
        RAISE_APPLICATION_ERROR(-20020, 'Nowa data seansu koliduje z innym seansem w tej samej sali.');
    END IF;

    UPDATE SEANS
    SET DATA_GODZINA = p_nowa_data_godzina
    WHERE ID_SEANS = p_id_seans;
    COMMIT;
    INSERT INTO LOG_OPERACJI(NAZWA_TABELI, OPERACJA, UZYTKOWNIK, OPIS)
            VALUES ('REZERWACJA', 'ERROR', USER, 'Przesunięto seans ' || p_id_seans || ' na ' || p_nowa_data_godzina);

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
