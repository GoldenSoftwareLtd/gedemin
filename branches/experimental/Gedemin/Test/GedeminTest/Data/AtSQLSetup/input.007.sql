SELECT
  *
FROM
  rdb$database r1 JOIN rdb$database r2
    ON
      case coalesce(1,0)
        when 1 then '�����.������'
        when 2 then '����.������'
        when 3 then '��������'
        when 4 then '���.���.(��.���)'
        else '���.���.'
      end = ''