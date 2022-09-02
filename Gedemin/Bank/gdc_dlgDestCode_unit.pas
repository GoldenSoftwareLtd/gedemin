// ShlTanya, 30.01.2019

unit gdc_dlgDestCode_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgG_unit, StdCtrls, Mask, DBCtrls, Db, ActnList, Menus;

type
  Tgdc_dlgDestCode = class(Tgdc_dlgG)
    Label1: TLabel;
    dbeCode: TDBEdit;
    Label2: TLabel;
    dbeDescription: TDBEdit;
  private
  public
  end;

var
  gdc_dlgDestCode: Tgdc_dlgDestCode;

implementation
uses
  gd_ClassList;

{$R *.DFM}

initialization
  RegisterFrmClass(Tgdc_dlgDestCode);

finalization
  UnRegisterFrmClass(Tgdc_dlgDestCode);

end.
