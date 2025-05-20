CREATE OR REPLACE PROCEDURE Usun_Seans (
    p_id_seans IN SEANS.ID_SEANS%TYPE
) IS
    v_count NUMBER;
    v_opis VARCHAR2(3000);
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM REZERWACJA
    WHERE ID_SEANS = p_id_seans;

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20010, 'Nie można usunąć seansu, ponieważ istnieją rezerwacje.');
    ELSE
        DELETE FROM SEANS WHERE ID_SEANS = p_id_seans;

        INSERT INTO LOG_OPERACJI(NAZWA_TABELI, OPERACJA, UZYTKOWNIK, OPIS)
    	VALUES ('REZERWACJA', 'INSERT', USER, 'Usunięto seans ' || p_id_seans);

    END IF;
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