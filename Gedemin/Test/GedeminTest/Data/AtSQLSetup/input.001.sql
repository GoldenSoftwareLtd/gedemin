SELECT
   case coalesce(1,0)
    when 1 then '�����.������'
    when 2 then '����.������'
    when 3 then '��������'
    when 4 then '���.���.(��.���)'
    else '���.���.'
  end as TYPE_INV
  FROM
  rdb$database