// ShlTanya, 24.02.2019

unit gdc_dlgUserDocumentLine_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgTR_unit, IBDatabase, Menus, Db, ActnList, StdCtrls, at_Container,
  ExtCtrls;

type
  Tgdc_dlgUserDocumentLine = class(Tgdc_dlgTR)
    pnlAttributes: TPanel;
    Bevel1: TBevel;
    atAttributes: TatContainer;
  end;

var
  gdc_dlgUserDocumentLine: Tgdc_dlgUserDocumentLine;

implementation

{$R *.DFM}

uses
  gd_ClassList, gdcClasses, IBSQL, gdcBaseInterface, gdcBase;

initialization
  RegisterFrmClass(Tgdc_dlgUserDocumentLine).AbstractBaseForm := True;

finalization
  UnRegisterFrmClass(Tgdc_dlgUserDocumentLine);
end.
