select
  iif((case 1
    when 1 then 10
    when 2 then 20
  else
    30
  end) = 10, 1, 0)
from
  rdb$database