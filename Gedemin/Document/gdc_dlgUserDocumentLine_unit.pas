
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
    
  public
    class procedure RegisterClassHierarchy(AClass: TClass = nil;
      AValue: String = ''); override;
  end;

var
  gdc_dlgUserDocumentLine: Tgdc_dlgUserDocumentLine;

implementation

{$R *.DFM}

uses
  gd_ClassList, gdcClasses, IBSQL, gdcBaseInterface, gdcBase;

{ Tgdc_dlgUserDocumentLine }

class procedure Tgdc_dlgUserDocumentLine.RegisterClassHierarchy(AClass: TClass = nil;
  AValue: String = '');
begin
  if AClass = nil then
    TgdcUserDocumentLine.RegisterClassHierarchy(Self, 'TgdcUserDocumentType')
  else
  begin
    Assert(AValue <> '');
    TgdcUserDocumentLine.RegisterClassHierarchy(AClass, AValue);
  end;
end;


initialization
  RegisterFrmClass(Tgdc_dlgUserDocumentLine);

finalization
  UnRegisterFrmClass(Tgdc_dlgUserDocumentLine);
end.
