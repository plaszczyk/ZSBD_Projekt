CREATE OR REPLACE PROCEDURE Wczytaj_Filmy(p_plik VARCHAR2) IS
    plik UTL_FILE.FILE_TYPE;
    linia VARCHAR2(1000);
    tytul VARCHAR2(100);
    gatunek VARCHAR2(50);
    czy_3d CHAR(1);
    czy_dubbing CHAR(1);
    czas NUMBER;
    v_opis VARCHAR2(1000);
BEGIN
    plik := UTL_FILE.FOPEN('CSV_DIR', p_plik, 'r');
    LOOP
        BEGIN
            UTL_FILE.GET_LINE(plik, linia);
            tytul := REGEXP_SUBSTR(linia, '[^,]+', 1, 1);
            gatunek := REGEXP_SUBSTR(linia, '[^,]+', 1, 2);
            czy_3d := REGEXP_SUBSTR(linia, '[^,]+', 1, 3);
            czy_dubbing := REGEXP_SUBSTR(linia, '[^,]+', 1, 4);
            czas := TO_NUMBER(REGEXP_SUBSTR(linia, '[^,]+', 1, 5));
            
            INSERT INTO FILM (ID_FILM, TYTUL, GATUNEK, CZY_3D, CZY_DUBBING, CZAS_TRWANIA)
            VALUES (NULL, tytul, gatunek, czy_3d, czy_dubbing, czas);
        EXCEPTION WHEN OTHERS THEN
            v_opis := 'Błąd: ' || SQLERRM || ' LINIA: ' || linia;
            INSERT INTO LOG_OPERACJI(NAZWA_TABELI, OPERACJA, UZYTKOWNIK, OPIS)
            VALUES ('FILM', 'ERROR', USER, v_opis);
        END;
    END LOOP;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        UTL_FILE.FCLOSE(plik);
END;