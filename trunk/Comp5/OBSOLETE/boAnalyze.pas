unit boAnalyze;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  boObject, DBTables;

type
  TboAnalyze = class(TComponent)
  private
  protected
  public
    function AddAnalyze(var Key: Integer): Boolean;
    function EditAnalyze(Analyzekey: Integer): Boolean;
    function DeleteAnalyze(Analyzekey: Integer): Boolean;

    function AddValue(name: String; AnalyzeKey: Integer;
      parent: Integer; var Key: Integer): Boolean;
    function EditValue(Valuekey: Integer): Boolean;
    function DeleteValue(Valuekey: Integer): Boolean;
    function ReplaceValue(ValueKey, GroupValue: Integer): Boolean;

  published
  end;

procedure Register;

implementation

{ TboAnalyze }

uses
  dlgAnalyze_unit, dlgAnTableValue_unit;

function TboAnalyze.AddAnalyze(var Key: Integer): Boolean;
var
  dlgAnalyze: TdlgAnalyze;
begin
  dlgAnalyze := TdlgAnalyze.Create(nil, - 1);
  try
    dlgAnalyze.tblAnalyzeTable.Append;
    Result := dlgAnalyze.ShowModal = mrOk;
    if Result then
    begin
      dlgAnalyze.tblAnalyzeTable.Refresh;
      Key := dlgAnalyze.tblAnalyzeTable.FieldByName('id').AsInteger
    end;
  finally
    dlgAnalyze.Free;
  end;
end;

function TboAnalyze.AddValue(name: String; AnalyzeKey, parent: Integer;
  var Key: Integer): Boolean;
var
  dlgAnTableValue: TdlgAnTableValue;
begin
  dlgAnTableValue := TdlgAnTableValue.Create(nil);
  try
    dlgAnTableValue.tblAnTableValue.Append;
    if Parent <> 0 then
      dlgAnTableValue.tblAnTableValue.FieldByName('parent').AsInteger := Parent;
    dlgAnTableValue.tblAnTableValue.FieldByName('analyzekey').AsInteger := AnalyzeKey;
    dlgAnTableValue.Parent := Parent;
    dlgAnTableValue.AnalyzeKey := AnalyzeKey;
    dlgAnTableValue.tblAnTableValue.FieldByName('name').AsString := name;
    Result := dlgAnTableValue.ShowModal = mrOk;
    if Result then
    begin
      dlgAnTableValue.tblAnTableValue.Refresh;
      Key := dlgAnTableValue.tblAnTableValue.FieldByName('id').AsInteger
    end;
  finally
    dlgAnTableValue.Free;
  end;
end;

function TboAnalyze.DeleteAnalyze(Analyzekey: Integer): Boolean;
var
  tblAnalyze: TTable;
begin
  Result := False;
  tblAnalyze := TTable.Create(Self);
  try
    tblAnalyze.DatabaseName := 'xxx';
    tblAnalyze.TableName := 'fin_Analyze';
    if tblAnalyze.FindKey([Analyzekey]) and
      (MessageBox(Application.Handle, 'Удалить запись?', 'Внимание',
          MB_ICONQUESTION + MB_YESNO) = mrYes) then
    begin
      try
        tblAnalyze.Delete;
        Result := True;
      except
        MessageBox(Application.Handle, 'Данная таблица уже где-то используется!', 'Внимание',
          MB_ICONEXCLAMATION);
      end;
    end
  finally
    tblAnalyze.Free;
  end;
end;

function TboAnalyze.DeleteValue(Valuekey: Integer): Boolean;
var
  tblAnTableValue: TTable;
begin
  Result := False;
  tblAnTableValue := TTable.Create(Self);
  try
    tblAnTableValue.DatabaseName := 'xxx';
    tblAnTableValue.TableName := 'fin_AnTableValue';
    if tblAnTableValue.FindKey([Valuekey]) and
      (MessageBox(Application.Handle, 'Удалить запись?', 'Внимание',
          MB_ICONQUESTION + MB_YESNO) = mrYes) then
    begin
      try
        tblAnTableValue.Delete;
        Result := True;
      except
        MessageBox(Application.Handle, 'Данная запись уже где-то используется!', 'Внимание',
          MB_ICONEXCLAMATION);
      end;
    end
  finally
    tblAnTableValue.Free;
  end;
end;

function TboAnalyze.EditAnalyze(Analyzekey: Integer): Boolean;
var
  dlgAnalyze: TdlgAnalyze;
begin
  dlgAnalyze := TdlgAnalyze.Create(Application, Analyzekey);
  try
    dlgAnalyze.mbbNext.Visible := False;
    if dlgAnalyze.tblAnalyzeTable.FindKey([Analyzekey]) then
    begin
      dlgAnalyze.tblAnalyzeTable.Edit;
      Result := dlgAnalyze.ShowModal = mrOk;
    end
    else
      Result := False;
  finally
    dlgAnalyze.Free;
  end;
end;

function TboAnalyze.EditValue(Valuekey: Integer): Boolean;
var
  dlgAnTableValue: TdlgAnTableValue;
begin
  dlgAnTableValue := TdlgAnTableValue.Create(nil);
  try
    dlgAnTableValue.mbbNext.Visible := False;
    if dlgAnTableValue.tblAnTableValue.FindKey([Valuekey]) then
    begin
      dlgAnTableValue.tblAnTableValue.Edit;
      Result := dlgAnTableValue.ShowModal = mrOk;
    end
    else
      Result := False;
  finally
    dlgAnTableValue.Free;
  end;
end;

function TboAnalyze.ReplaceValue(ValueKey, GroupValue: Integer): Boolean;
begin

end;

procedure Register;
begin
  RegisterComponents('gsBO', [TboAnalyze]);
end;

end.
