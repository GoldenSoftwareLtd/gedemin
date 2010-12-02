unit prp_Filter;

interface
uses Sysutils;

type
 TFilterOptions = (foAll, foBegining, foContaining, foEnding);

function Filter(Str, Filter: string; FilterOptions: TFilterOptions): Boolean;
implementation

function Filter(Str, Filter: string; FilterOptions: TFilterOptions): Boolean;
var
  Tmp: string;
begin
  Result := True;
  case FilterOptions of
    foAll: Result := True;
    foBegining: Result := Pos(UpperCase(Filter), UpperCase(Str)) = 1;
    foContaining: Result := Pos(UpperCase(Filter), UpperCase(Str)) > 0;
    foEnding:
    begin
      Tmp := Copy(UpperCase(Str), Length(Str) - Length(Filter) + 1, Length(Filter));
      Result := Pos(UpperCase(Filter), Tmp) = 1;
    end;
  end;
end;

end.
