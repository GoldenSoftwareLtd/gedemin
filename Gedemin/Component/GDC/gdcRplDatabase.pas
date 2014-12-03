unit gdcRplDatabase;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, IBCustomDataSet, gdcBase, gdcBaseInterface, gd_ClassList;

type
  TgdcRplDatabase = class(TgdcBase)
  public
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('gdc', [TgdcRplDatabase]);
end;

{ TgdcRplDatabase }

class function TgdcRplDatabase.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := '';
end;

class function TgdcRplDatabase.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := '';
end;

class function TgdcRplDatabase.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'RPL_DATABASE';
end;

class function TgdcRplDatabase.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'NAME';
end;

initialization
  RegisterGDCClass(TgdcRplDatabase);

finalization
  UnRegisterGDCClass(TgdcRplDatabase);
end.
