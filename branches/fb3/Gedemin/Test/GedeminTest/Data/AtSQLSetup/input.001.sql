SELECT
   case coalesce(1,0)
    when 1 then 'Ивест.проект'
    when 2 then 'Инов.проект'
    when 3 then 'Экономия'
    when 4 then 'Осн.кап.(уд.вес)'
    else 'Осн.кап.'
  end as TYPE_INV
  FROM
  rdb$database