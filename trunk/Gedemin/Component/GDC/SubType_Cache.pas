unit SubType_Cache;

interface

uses
  Classes, Windows;

function FindParentSubType(SubType: string): string;

var
  SubTypeList: TStringList;

implementation

uses
  IBSQL, gdcBaseInterface;

procedure FillSubTypeList;
var
  ibsql: TIBSQL;
begin
  SubTypeList.Clear;

  ibsql := TIBSQL.Create(nil);
  ibsql.Transaction := gdcBaseManager.ReadTransaction;
  try
    ibsql.Close;
    ibsql.SQL.Text :=
      'SELECT '#13#10 +
      '  d.RUID AS SubType, '#13#10 +
      '  p.RUID AS ParentSubType '#13#10 +
      'FROM '#13#10 +
      '  GD_DOCUMENTTYPE d '#13#10 +
      '  LEFT JOIN GD_DOCUMENTTYPE p ON p.ID = d.PARENT AND p.DOCUMENTTYPE = ''D'' '#13#10 +
      'Where d.DOCUMENTTYPE = ''D'' and  p.RUID <> ''''';
    ibsql.ExecQuery;
    while not ibsql.Eof do
    begin
      SubTypeList.Values[ibsql.Fields[0].AsString] := ibsql.Fields[1].AsString;
      ibsql.Next;
    end;
  finally
    ibsql.Free;
  end;
end;

function FindParentSubType(SubType: string): string;
begin
  Result := '';
  if SubTypeList.Count = 0 then
    FillSubTypeList;
  Result := SubTypeList.Values[SubType];
end;

initialization
  if not Assigned(SubTypeList) then
  begin
    SubTypeList := TStringList.Create;
  end;

finalization
  SubTypeList.Free;

end.


