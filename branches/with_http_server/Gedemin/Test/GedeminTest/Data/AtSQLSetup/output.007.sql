SELECT 
  *  
FROM 
  RDB$DATABASE R1
    JOIN 
      RDB$DATABASE R2
    ON 
      CASE COALESCE(1, 0)
      WHEN 1 THEN
        '�����.������'
      WHEN 2 THEN
        '����.������'
      WHEN 3 THEN
        '��������'
      WHEN 4 THEN
        '���.���.(��.���)'
      ELSE
        '���.���.'
      END  =  ''