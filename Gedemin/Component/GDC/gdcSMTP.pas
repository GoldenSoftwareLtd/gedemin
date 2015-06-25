unit gdcSMTP;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, IBCustomDataSet, gdcBase, gdcBaseInterface, gd_ClassList;

type
  TgdcSMTP = class(TgdcBase)
  public
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
  end;

procedure Register;

implementation

uses
  gdc_frmSMTP_Unit, gdc_dlgSMTP_Unit, gd_common_functions;

procedure Register;
begin
  RegisterComponents('gdc', [TgdcSMTP]);
end;

{ TgdcSMTP }

class function TgdcSMTP.GetViewFormClassName(const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmSMTP';
end;

class function TgdcSMTP.GetDialogFormClassName(const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgSMTP';
end;

class function TgdcSMTP.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'GD_SMTP';
end;

class function TgdcSMTP.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'NAME';
end;

initialization
  RegisterGDCClass(TgdcSMTP, 'Почтовый ящик');

finalization
  UnregisterGDCClass(TgdcSMTP);
end.
