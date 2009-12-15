
unit gdcStorage;

{ TODO 5 -oandreik -cStorage : Триггеры после удаления компании, пользователя и раб. стола }
{ TODO 5 -oandreik -cStorage : CheckTheSameStatement }
{ TODO 5 -oandreik -cStorage : Определиться с максимальной длиной имени }

interface

uses
  Classes, IBCustomDataSet, gdcBase, Forms, gd_createable_form, Controls, DB,
  gdcBaseInterface, IBDataBase, gdcTree;

type
  TgdcStorage = class(TgdcLBRBTree)
  public
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
  end;

procedure Register;

implementation

uses
  SysUtils,
  gdc_dlgStorage_unit,
  gdc_frmStorage_unit,
  gd_ClassList;

procedure Register;
begin
  RegisterComponents('gdc', [TgdcStorage]);
end;

{ TgdcStorage ------------------------------------------------}

class function TgdcStorage.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'NAME';
end;

class function TgdcStorage.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'GD_STORAGE_DATA';
end;

class function TgdcStorage.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmStorage';
end;

class function TgdcStorage.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgStorage';
end;

initialization
  RegisterGdcClass(TgdcStorage);

finalization
  UnRegisterGdcClass(TgdcStorage);

end.
