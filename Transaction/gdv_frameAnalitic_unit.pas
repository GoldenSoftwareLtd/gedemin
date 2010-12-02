unit gdv_frameAnalitic_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdv_frameBaseAnalitic_unit, ActnList, StdCtrls, contnrs, AcctUtils;

type
  TframeAnalitic = class(TframeBaseAnalitic)
  private
    { Private declarations }
  protected
    FFields: TObjectList;
    function GetValues: string; override;
    procedure SetValues(const Value: string);override;
  public
    { Public declarations }
    procedure UpdateAvail(IdList: TList); override;
  end;

var
  frameAnalitic: TframeAnalitic;

implementation
uses at_Classes, IBSQL, gdcBaseInterface;
{$R *.DFM}

{ TframeAnalitic }

function TframeAnalitic.GetValues: string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to Selected.Count- 1 do
  begin
    if Result > '' then
      Result := Result + #13#10;
    Result := Result + TatRelationField(Selected.Objects[I]).FieldName;
  end;
end;

procedure TframeAnalitic.SetValues(const Value: string);
var
  L: TStrings;
  I: Integer;
  Index: Integer;

  function IndexOf(FieldName: string): integer;
  var
    I: Integer;
    F: TatRelationField;
  begin
    Result := - 1;
    for I := 0 to Avail.Count - 1 do
    begin
      F := TatRelationField(Avail.Objects[I]);
      if F.FieldName = FieldName then
      begin
        Result := I;
        Exit;
      end;
    end;
  end;
begin
  Selected.Clear;
  L := TStringList.Create;
  try
    L.Text := Value;
    for I := 0 to L.Count - 1 do
    begin
      Index := IndexOf(L[I]);
      if Index > - 1 then
      begin
        Selected.AddObject(Avail[Index], Avail.Objects[Index]);
      end;
    end;
  finally
    L.Free;
  end;
end;

procedure TframeAnalitic.UpdateAvail(IdList: TList);
var
  I: Integer;
  SQL: TIBSQl;
begin
  Avail.BeginUpdate;
  try
    Avail.Clear;
    if IDList.Count > 0 then
    begin
      SQL := TIBSQL.Create(nil);
      try
        SQL.Transaction := gdcBaseManager.ReadTransaction;
        if FFields = nil then
        begin
          FFields := TObjectList.Create;
          GetAnalyticsFields(FFields);
        end;

        for I := 0 to FFields.Count - 1 do
        begin
          SQL.SQL.Text := Format('SELECT COUNT(*) FROM AC_ACCOUNT WHERE (id IN ' +
            '(%s)) AND (%s = 1)', [AcctUtils.IdList(IdList), TatRelationField(FFields[i]).FieldName]);
          SQL.ExecQuery;
          try
            if SQl.Fields[0].AsInteger = IDList.Count then
              Avail.AddObject(TatRelationField(FFields[i]).LName,
                FFields[i]);
          finally
            SQL.Close;
          end;
        end;
      finally
        SQL.Free;
      end;
    end;

    for I := Selected.Count - 1 downto 0 do
    begin
      if Avail.IndexOfObject(Selected.Objects[I]) = - 1 then
        Selected.Delete(i);
    end;
  finally
    Avail.EndUpdate;
  end;
  inherited;
end;

end.
