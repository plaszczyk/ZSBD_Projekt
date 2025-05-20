BEGIN
  FOR rec IN (SELECT id_film, id_sala, data_godzina, cena_biletu FROM TEMP_SEANSE) LOOP
    BEGIN
      Dodaj_Seans(rec.id_film, rec.id_sala, rec.data_godzina, rec.cena_biletu);
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  END LOOP;
END;