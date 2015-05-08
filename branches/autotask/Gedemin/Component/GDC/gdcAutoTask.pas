unit gdcAutoTask;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, IBCustomDataSet, gdcBase, gdcBaseInterface, gd_ClassList;

type
  TgdcAutoTask = class(TgdcBase)
  protected
    procedure CustomInsert(Buff: Pointer); override;
    procedure CustomDelete(Buff: Pointer); override;
    procedure CustomModify(Buff: Pointer); override;
    
  public
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
  end;

  TgdcAutoTaskLog = class(TgdcBase)
  protected
    procedure CustomInsert(Buff: Pointer); override;
    procedure CustomDelete(Buff: Pointer); override;
    procedure CustomModify(Buff: Pointer); override;
    
  public
    procedure GetWhereClauseConditions(S: TStrings); override;
    class function GetSubSetList: String; override;
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
  end;

procedure Register;

implementation

uses
  gd_TaskManager, gdc_frmAutoTask_unit, gdc_dlgAutoTask_unit;

procedure Register;
begin
  RegisterComponents('gdc', [TgdcAutoTask, TgdcAutoTaskLog]);
end;

{ TgdcAutoTask }

procedure TgdcAutoTask.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  Task: TgdTask;
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCAUTOTASK', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCAUTOTASK', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCAUTOTASK') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCAUTOTASK',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCAUTOTASK' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  Task := gdTaskManager.Add;

  Task.Id := FieldbyName('id').AsInteger;
  Task.Name := FieldbyName('name').AsString;
  Task.Description := FieldbyName('description').AsString;
  Task.FunctionKey := FieldbyName('functionkey').AsInteger;
  Task.CmdLine := FieldbyName('cmdline').AsString;
  Task.BackupFile := FieldbyName('backupfile').AsString;
  Task.UserKey := FieldbyName('userkey').AsInteger;
  Task.ExactDate := FieldbyName('exactdate').AsDateTime;
  Task.Monthly := FieldbyName('monthly').AsInteger;
  Task.Weekly := FieldbyName('weekly').AsInteger;
  Task.StartTime := FieldbyName('starttime').AsDateTime;
  Task.EndTime := FieldbyName('endtime').AsDateTime;
  Task.Disabled := FieldbyName('disabled').AsInteger = 1;

  gdTaskManager.Restart;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCAUTOTASK', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCAUTOTASK', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcAutoTask.CustomDelete(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}var
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCAUTOTASK', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCAUTOTASK', KEYCUSTOMDELETE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMDELETE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCAUTOTASK') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCAUTOTASK',
  {M}          'CUSTOMDELETE', KEYCUSTOMDELETE, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCAUTOTASK' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  gdTaskManager.Remove(FieldbyName('id').AsInteger);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCAUTOTASK', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCAUTOTASK', 'CUSTOMDELETE', KEYCUSTOMDELETE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcAutoTask.CustomModify(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  Task: TgdTask;
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCAUTOTASK', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCAUTOTASK', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCAUTOTASK') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCAUTOTASK',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCAUTOTASK' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  Task := gdTaskManager.Get(FieldbyName('id').AsInteger);

  Task.Name := FieldbyName('name').AsString;
  Task.Description := FieldbyName('description').AsString;
  Task.FunctionKey := FieldbyName('functionkey').AsInteger;
  Task.CmdLine := FieldbyName('cmdline').AsString;
  Task.BackupFile := FieldbyName('backupfile').AsString;
  Task.UserKey := FieldbyName('userkey').AsInteger;
  Task.ExactDate := FieldbyName('exactdate').AsDateTime;
  Task.Monthly := FieldbyName('monthly').AsInteger;
  Task.Weekly := FieldbyName('weekly').AsInteger;
  Task.StartTime := FieldbyName('starttime').AsDateTime;
  Task.EndTime := FieldbyName('endtime').AsDateTime;
  Task.Disabled := FieldbyName('disabled').AsInteger = 1;

  gdTaskManager.Restart;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCAUTOTASK', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCAUTOTASK', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}
end;

class function TgdcAutoTask.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmAutoTask';
end;

class function TgdcAutoTask.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgAutoTask';
end;

class function TgdcAutoTask.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'GD_AUTOTASK';
end;

class function TgdcAutoTask.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'NAME';
end;

{ TgdcAutoTaskLog }

procedure TgdcAutoTaskLog.CustomInsert(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  Task: TgdTask;
  TaskLog: TgdTaskLog;
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCAUTOTASKLOG', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCAUTOTASKLOG', KEYCUSTOMINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCAUTOTASKLOG') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCAUTOTASKLOG',
  {M}          'CUSTOMINSERT', KEYCUSTOMINSERT, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCAUTOTASKLOG' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  Task := gdTaskManager.Get(FieldbyName('autotaskkey').AsInteger);
  TaskLog := Task.Add;

  TaskLog.Id := FieldbyName('id').AsInteger;
  TaskLog.AutotaskKey := FieldbyName('autotaskkey').AsInteger;
  TaskLog.EventTime := FieldbyName('eventtime').AsDateTime;
  TaskLog.EventText := FieldbyName('eventtext').AsString;
  TaskLog.CreatorKey := FieldbyName('creatorkey').AsInteger;
  TaskLog.CreationDate := FieldbyName('creationdate').AsDateTime;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCAUTOTASKLOG', 'CUSTOMINSERT', KEYCUSTOMINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCAUTOTASKLOG', 'CUSTOMINSERT', KEYCUSTOMINSERT);
  {M}  end;
  {END MACRO}
end;

procedure TgdcAutoTaskLog.CustomDelete(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS()}
  {M}var
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  Task: TgdTask;
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCAUTOTASKLOG', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCAUTOTASKLOG', KEYCUSTOMDELETE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMDELETE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCAUTOTASKLOG') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCAUTOTASKLOG',
  {M}          'CUSTOMDELETE', KEYCUSTOMDELETE, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCAUTOTASKLOG' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  Task := gdTaskManager.Get(FieldbyName('autotaskkey').AsInteger);
  Task.Remove(FieldbyName('id').AsInteger);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCAUTOTASKLOG', 'CUSTOMDELETE', KEYCUSTOMDELETE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCAUTOTASKLOG', 'CUSTOMDELETE', KEYCUSTOMDELETE);
  {M}  end;
  {END MACRO}
end;

procedure TgdcAutoTaskLog.CustomModify(Buff: Pointer);
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  Task: TgdTask;
  TaskLog: TgdTaskLog;
begin
  {@UNFOLD MACRO INH_ORIG_CUSTOMINSERT('TGDCAUTOTASKLOG', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCAUTOTASKLOG', KEYCUSTOMMODIFY);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCUSTOMMODIFY]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCAUTOTASKLOG') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), Integer(Buff)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCAUTOTASKLOG',
  {M}          'CUSTOMMODIFY', KEYCUSTOMMODIFY, Params, LResult) then
  {M}          exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCAUTOTASKLOG' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  Task := gdTaskManager.Get(FieldbyName('autotaskkey').AsInteger);
  TaskLog := Task.Get(FieldbyName('id').AsInteger);

  TaskLog.AutotaskKey := FieldbyName('autotaskkey').AsInteger;
  TaskLog.EventTime := FieldbyName('eventtime').AsDateTime;
  TaskLog.EventText := FieldbyName('eventtext').AsString;
  TaskLog.CreatorKey := FieldbyName('creatorkey').AsInteger;
  TaskLog.CreationDate := FieldbyName('creationdate').AsDateTime;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCAUTOTASKLOG', 'CUSTOMMODIFY', KEYCUSTOMMODIFY)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCAUTOTASKLOG', 'CUSTOMMODIFY', KEYCUSTOMMODIFY);
  {M}  end;
  {END MACRO}
end;

class function TgdcAutoTaskLog.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'GD_AUTOTASK_LOG';
end;

class function TgdcAutoTaskLog.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'ID';
end;

class function TgdcAutoTaskLog.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + 'ByAutoTask;';
end;

procedure TgdcAutoTaskLog.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  
  if HasSubSet('ByAutoTask') then
    S.Add(' Z.AUTOTASKKEY = :AUTOTASKKEY ');
end;

initialization
  RegisterGDCClass(TgdcAutoTask);
  RegisterGDCClass(TgdcAutoTaskLog);

finalization
  UnregisterGdcClass(TgdcAutoTask);
  UnRegisterGDCClass(TgdcAutoTaskLog);
end.
