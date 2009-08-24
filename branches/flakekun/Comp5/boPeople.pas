
unit boPeople;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  boObject, DBTables;

type
  TboPeople = class(TComponent)
  private
  protected
  public
    function AddPeople(const Parent: Integer; const Name: String; var K: Integer): Boolean;
    function EditPeople(Key: Integer): Boolean;
    function DeletePeople(Key: Integer): Boolean;
    function ReplacePeople(PeopleKey, GroupPeople: Integer): Boolean;
  published
  end;

implementation

uses
  dlgPeople_unit;

function TboPeople.AddPeople(const Parent: Integer; const Name: String; var K: Integer): Boolean;
var
  dlgPeople: TdlgPeople;
begin
  dlgPeople := TdlgPeople.Create(Application);
  try
    dlgPeople.tblPeople.Append;
    if Parent <> 0 then
      dlgPeople.tblPeople.FieldByName('parent').AsInteger := Parent;
    dlgPeople.tblPeople.FieldByName('name').AsString := Name;
    dlgPeople.Parent := Parent;

    Result := dlgPeople.ShowModal = mrOk;
    if Result then
      K := dlgPeople.tblPeople.FieldByName('id').AsInteger;
  finally
    dlgPeople.Free;
  end;
end;

function TboPeople.EditPeople(Key: Integer): Boolean;
var
  dlgPeople: TdlgPeople;
begin
  dlgPeople := TdlgPeople.Create(Application);
  try
    if dlgPeople.tblPeople.Locate('id', Key, []) then
    begin
      dlgPeople.tblPeople.Edit;
      Result := dlgPeople.ShowModal = mrOk;
    end
    else
      Result := False;
  finally
    dlgPeople.Free;
  end;
end;

function TboPeople.DeletePeople(Key: Integer): Boolean;
var
  qryDeletePeople: TQuery;
begin
  qryDeletePeople := TQuery.Create(Self);
  try
    Result := False;
    if MessageBox(0, 'Удалить человека?', 'Внимание!',
      MB_YESNO + MB_ICONQUESTION) = mrYes then
      try
        qryDeletePeople.DataBaseName := 'xxx';
        qryDeletePeople.SQL.Text := 'DELETE FROM ph_people WHERE id = ' + IntToStr(Key);
        qryDeletePeople.ExecSQL;
        Result := True;
      except
        MessageBox(0, 'Невозможно удалить человека, т.к. он где-то используется',
          'Внимание', MB_ICONEXCLAMATION);
      end;
  finally
    qryDeletePeople.Free;
  end;
end;

function TboPeople.ReplacePeople(PeopleKey, GroupPeople: Integer): Boolean;
var
  spTestReplacePeople: TStoredProc;
  qryPeople: TQuery;
begin
  Result := PeopleKey = GroupPeople;
  if not Result then
  begin
    spTestReplacePeople := TStoredProc.Create(Self);
    try
      spTestReplacePeople.DataBaseName := 'xxx';
      if GroupPeople <> 0 then
      begin
        spTestReplacePeople.StoredProcName := 'ph_p_testreplacePeople';
        spTestReplacePeople.Prepare;
        spTestReplacePeople.ParamByName('id').AsInteger := PeopleKey;
        spTestReplacePeople.ParamByName('groupPeople').AsInteger := GroupPeople;
        spTestReplacePeople.ExecProc;
        Result := spTestReplacePeople.ParamByName('replace').AsInteger = 1;
      end
      else
        Result := True;
      if Result then
      begin
        qryPeople := TQuery.Create(Self);
        try
          qryPeople.DatabaseName := 'xxx';
          if groupPeople <> 0 then
            qryPeople.SQL.Text := Format('UPDATE ph_People SET ph_People.parent = %d ' +
              'WHERE ph_People.id = %d ', [groupPeople, Peoplekey])
          else
            qryPeople.SQL.Text := Format('UPDATE ph_People SET ph_People.parent = NULL ' +
              'WHERE ph_People.id = %d ', [Peoplekey]);
          qryPeople.ExecSQL;
        finally
          qryPeople.Free;
        end;
      end
    finally
      spTestReplacePeople.Free;
    end;
  end;
end;

end.

