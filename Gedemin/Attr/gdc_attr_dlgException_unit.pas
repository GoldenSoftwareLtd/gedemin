// ShlTanya, 03.02.2019

unit gdc_attr_dlgException_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgGMetaData_unit, Db, ActnList, StdCtrls, Mask, DBCtrls, Menus;

type
  Tgdc_dlgException = class(Tgdc_dlgGMetaData)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    dbeName: TDBEdit;
    dbeMessage: TDBEdit;
    dbeLMessage: TDBEdit;
  end;

var
  gdc_dlgException: Tgdc_dlgException;

implementation

uses
  gd_ClassList;

{$R *.DFM}

initialization
  RegisterFrmClass(Tgdc_dlgException);

finalization
  UnRegisterFrmClass(Tgdc_dlgException);
end.
