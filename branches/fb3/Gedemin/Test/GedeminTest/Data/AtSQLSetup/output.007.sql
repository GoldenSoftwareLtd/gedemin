SELECT 
  *  
FROM 
  RDB$DATABASE R1
    JOIN 
      RDB$DATABASE R2
    ON 
      CASE COALESCE(1, 0)
      WHEN 1 THEN
        'Ивест.проект'
      WHEN 2 THEN
        'Инов.проект'
      WHEN 3 THEN
        'Экономия'
      WHEN 4 THEN
        'Осн.кап.(уд.вес)'
      ELSE
        'Осн.кап.'
      END  =  ''