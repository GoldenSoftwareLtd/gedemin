unit gd_UniqueDBKey;

interface

  function GetUniqueDBKey: Cardinal;

implementation

function GetUniqueDBKey: Cardinal;
begin
  Randomize;
  Result := Random($7FFFFFFF);
end;

end.
