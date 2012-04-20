unit gdcTableMetaData;

interface

uses
  Classes, IBDatabase;

type
  TBaseTableTriggersName = record
    BITriggerName,
    BI5TriggerName,
    BU5TriggerName: String
  end;

function GetBaseTableBITriggerName(const ARelName: String; const ATr: TIBTRansaction): String;
procedure GetBaseTableTriggersName(const ARelName: String; const ATr: TIBTRansaction;
  out Names: TBaseTableTriggersName);
procedure InitBaseTableTriggersName(out Names: TBaseTableTriggersName);

implementation

uses
  SysUtils, IBSQL;

function GetBaseTableBITriggerName(const ARelName: String; const ATr: TIBTRansaction): String;
var
  q: TIBSQL;
begin
  Result := '';
  if (ATr <> nil) and (ATr.InTransaction) then
  begin
    q := TIBSQL.Create(nil);
    try
      q.Transaction := ATr;
      q.SQL.Text :=
        'SELECT t.rdb$trigger_name FROM rdb$triggers t ' +
        '  JOIN rdb$dependencies d1 ON d1.rdb$dependent_name = t.rdb$trigger_name ' +
        '    AND d1.rdb$depended_on_name = :G1 ' +
        '  JOIN rdb$dependencies d2 ON d2.rdb$dependent_name = t.rdb$trigger_name ' +
        '    AND d2.rdb$depended_on_name = :G2 ' +
        'WHERE t.rdb$trigger_type = :T ' +
        '  AND t.rdb$relation_name = :RN';
      q.ParamByName('T').AsInteger := 1;
      q.ParamByName('G1').AsString := 'GD_G_OFFSET';
      q.ParamByName('G2').AsString := 'GD_G_UNIQUE';
      q.ParamByName('RN').AsString := ARelName;
      q.ExecQuery;

      Result := q.Fields[0].AsTrimString;
    finally
      q.Free;
    end;
  end;
end;

procedure GetBaseTableTriggersName(const ARelName: String; const ATr: TIBTRansaction;
  out Names: TBaseTableTriggersName);
var
  q: TIBSQL;
begin
  InitBaseTableTriggersName(Names);
  if (ATr <> nil) and (ATr.InTransaction) then
  begin
    Names.BITriggerName := GetBaseTableBITriggerName(ARelName, Atr);
    
    q := TIBSQL.Create(nil);
    try
      q.Transaction := ATr;
      q.SQL.Text :=
        'SELECT t.rdb$trigger_name FROM rdb$triggers t ' +
        '  JOIN rdb$dependencies d1 ON d1.rdb$dependent_name = t.rdb$trigger_name ' +
        '    AND d1.rdb$field_name = :F1 ' +
        '  JOIN rdb$dependencies d2 ON d2.rdb$dependent_name = t.rdb$trigger_name ' +
        '    AND d2.rdb$field_name = :F2 ' +
        'WHERE t.rdb$trigger_type = :T ' +
        '  AND t.rdb$relation_name = :RN' +
        '  AND t.rdb$trigger_sequence = :P';
      q.ParamByName('T').AsInteger := 1;
      q.ParamByName('F1').AsString := 'EDITIONDATE';
      q.ParamByName('F2').AsString := 'EDITORKEY';
      q.ParamByName('RN').AsString := ARelName;
      q.ParamByName('P').AsInteger := 5;
      q.ExecQuery;

      Names.BI5TriggerName := q.Fields[0].AsTrimString;

      q.Close;

      q.ParamByName('T').AsInteger := 3;
      q.ExecQuery;

      Names.BU5TriggerName := q.Fields[0].AsTrimString;
    finally
      q.Free;
    end;
  end;
end;

procedure InitBaseTableTriggersName(out Names: TBaseTableTriggersName);
begin
  with Names do
  begin
    BITriggerName := '';
    BI5TriggerName := '';
    BU5TriggerName := '';
  end;
end;

end.
