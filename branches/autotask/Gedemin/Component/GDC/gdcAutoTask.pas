unit gdcAutoTask;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, IBCustomDataSet, gdcBase, gdcBaseInterface, gd_ClassList;

type
  TgdcAutoTask = class(TgdcBase)
  public
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
  end;

  TgdcAutoTaskLog = class(TgdcBase)
  public
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
  end;

procedure Register;

implementation

uses
  gdc_frmAutoTask_unit, gdc_dlgAutoTask_unit;

procedure Register;
begin
  RegisterComponents('gdc', [TgdcAutoTask, TgdcAutoTaskLog]);
end;

{ TgdcAutoTask }

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

class function TgdcAutoTaskLog.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'GD_AUTOTASK_LOG';
end;

class function TgdcAutoTaskLog.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'ID';
end;

initialization
  RegisterGDCClass(TgdcAutoTask);
  RegisterGDCClass(TgdcAutoTaskLog);

finalization
  UnregisterGdcClass(TgdcAutoTask);
  UnRegisterGDCClass(TgdcAutoTaskLog);
end.
