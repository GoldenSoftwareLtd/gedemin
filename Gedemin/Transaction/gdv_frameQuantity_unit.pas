// ShlTanya, 09.03.2019, #4135

unit gdv_frameQuantity_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdv_frameBaseAnalitic_unit, ActnList, StdCtrls, AcctUtils;

type
  TframeQuantity = class(TframeBaseAnalitic)
    procedure actUpUpdate(Sender: TObject);
  private
    { Private declarations }
  protected
    function GetValues: string; override;
    procedure SetValues(const Value: string);override;
  public
    { Public declarations }
    procedure UpdateAvail(IdList: TList; Context: String); override;
    function InClause: string;
    procedure ValueList(const ValueList: TStrings; const AccountList: TList; BeginDate,
      EndDate: TDateTime);
  end;

var
  frameQuantity: TframeQuantity;

implementation
uses at_Classes, IBSQL, gdcBaseInterface, gd_security;
{$R *.DFM}

{ TframeQuantity }

function TframeQuantity.GetValues: string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to Selected.Count - 1 do
  begin
    if Result > '' then
      Result := Result + #13#10;

    Result := Result + TID2S(GetTID(Selected.Objects[I], Name));
  end;
end;

function TframeQuantity.InClause: string;
var
  I: Integer;
begin
  Result := '';
  for i := 0 to Selected.Count - 1 do
  begin
    if Result > '' then
      Result := Result + ', ';
    Result := Result + TID2S(GetTID(Selected.Objects[I], Name));
  end;
end;

procedure TframeQuantity.SetValues(const Value: string);
var
  FN: TStrings;
  I: Integer;
  Index: Integer;
begin
  Selected.Clear;
  FN := TStringList.Create;
  try
    FN.Text := Value;
    for I := 0 to FN.Count - 1 do
    begin
      Index :=  Avail.IndexOfObject(TID2Pointer(GetTID(FN[I]), Name));
      if Index > - 1 then
      begin
        Selected.AddObject(Avail[Index], Avail.Objects[Index]);
      end;
    end;
  finally
    FN.Free;
  end;
end;

procedure TframeQuantity.UpdateAvail(IdList: TList; Context: String);
var
  SQL: TIBSQL;
  I: Integer;
  Index: Integer;
begin
  Avail.Clear;
  SQL := TIBSQL.Create(nil);
  try
    SQL.Transaction := gdcBaseManager.ReadTransaction;
    SQL.SQl.Text :=  'SELECT DISTINCT ' +
      'v.id, v.name ' +
      'FROM ' +
      '  ac_account a ' +
      '  JOIN ac_accvalue av ON av.accountkey = a.id ' +
      '  JOIN gd_value v ON av.valuekey = v.id ';
      if IDList.Count > 0 then
        SQL.SQL.Text := SQL.SQL.Text + 'WHERE  a.id IN(' + AcctUtils.IDList(IdList, Context) + ') ';

    SQL.ExecQuery;
    Avail.BeginUpdate;
    try
      while not SQl.Eof do
      begin
        Avail.AddObject(SQl.FieldByName('name').AsString,
          TID2Pointer(GetTID(SQL.FieldByName('id')), Name));
        SQl.Next;
      end;
    finally
      Avail.EndUpdate;
    end;
    Selected.BeginUpdate;
    try
      for I := Selected.Count - 1 downto 0 do
      begin
        Index := Avail.IndexOfObject(Selected.Objects[I]);
        if Index = - 1 then
          Selected.Delete(i);
      end;
    finally
      Selected.EndUpdate;
    end;

  finally
    SQL.Free;
  end;
  inherited;
end;

procedure TframeQuantity.ValueList(const ValueList: TStrings; const AccountList: TList;
  BeginDate, EndDate: TDateTime);
var
  SQL: TIBSQL;
begin
  ValueList.Clear;
  if Selected.Count > 0 then
  begin
    SQL := TIBSQL.Create(nil);
    try
      SQL.Transaction := gdcBaseManager.ReadTransaction;
      SQL.SQl.Text :=  'SELECT DISTINCT ' +
        'q.valuekey, v.name ' +
        'FROM ' +
        '  ac_entry e ' +
        '  LEFT JOIN ac_record r ON r.id = e.recordkey ' +
        '  LEFT JOIN ac_entry e1 ON e.id = e1.id AND e1.entrydate < :begindate ' +
        '  LEFT JOIN ac_entry e2 ON e.id = e2.id AND e2.entrydate  >= :begindate AND ' +
        '    e2.entrydate <=:enddate ' +
        '  JOIN ac_quantity q ON q.entrykey = e.id ' +
        '  JOIN gd_value v ON v.id = q.valuekey ' +
        'WHERE ' +
        '  e.accountkey IN(' + AcctUtils.IdList(AccountList, Name) + ') AND ' +
        '  e.entrydate <= :enddate AND ' +
        '  r.companykey IN(' + IBLogin.HoldingList + ' ) AND ' +
        '  G_SEC_TEST ( r.aview, ' + IntToStr(IBLogin.InGroup) + ' ) <> 0 AND ' +
        '  v.id IN (' + InClause + ') ' +
        'GROUP BY q.valuekey, v.name ' +
        'HAVING (SUM(e2.debitncu) <> 0 or SUM(e2.creditncu) <> 0 or '#13#10 +
        'SUM(e1.debitncu - e1.creditncu) <> 0 or SUM(e1.debitcurr - e1.creditcurr) <> 0 or '#13#10 +
        'SUM(e2.debitcurr) <> 0 or SUM(e2.creditcurr) <> 0)';
      SQL.ParamByName('begindate').AsDateTime := BeginDate;
      SQL.ParamByName('enddate').AsDateTime := EndDate;
      SQl.ExecQuery;
      while not SQl.Eof do
      begin
        ValueList.Add(SQL.FieldByName('valuekey').AsString + '=' +
          SQl.FieldByName('name').AsString);
        SQl.Next;
      end;
    finally
      SQL.Free;
    end;
  end;
end;

procedure TframeQuantity.actUpUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := False;
end;

end.
