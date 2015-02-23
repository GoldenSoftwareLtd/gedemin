unit gdcRplDatabase;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, IBCustomDataSet, gdcBase, gdcBaseInterface, gd_ClassList;

type
  TgdcRplDatabase2 = class(TgdcBase)
  public
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
  end;

procedure Register;

implementation

uses
  gdc_frmRplDatabase2_unit, gdc_dlgRplDatabase2_unit;

procedure Register;
begin
  RegisterComponents('gdc', [TgdcRplDatabase2]);
end;

{ TgdcRplDatabase2 }

class function TgdcRplDatabase2.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmRplDatabase2';
end;

class function TgdcRplDatabase2.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgRplDatabase2';
end;

class function TgdcRplDatabase2.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'RPL_DATABASE';
end;

class function TgdcRplDatabase2.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'NAME';
end;

initialization
  RegisterGDCClass(TgdcRplDatabase2);

finalization
  UnRegisterGDCClass(TgdcRplDatabase2);
end.
