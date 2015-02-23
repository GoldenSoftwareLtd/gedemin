SELECT 
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
  END AS TYPE_INV 
FROM 
  RDB$DATABASE