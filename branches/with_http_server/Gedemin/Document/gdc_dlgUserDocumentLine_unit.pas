
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
    class function GetSubTypeList(SubTypeList: TStrings): Boolean; override;
  end;

var
  gdc_dlgUserDocumentLine: Tgdc_dlgUserDocumentLine;

implementation

{$R *.DFM}

uses
  gd_ClassList, gdcClasses;

{ Tgdc_dlgUserDocumentLine }

class function Tgdc_dlgUserDocumentLine.GetSubTypeList(
  SubTypeList: TStrings): Boolean;
begin
  Result := TgdcUserDocument.GetSubTypeList(SubTypeList);
end;

initialization
  RegisterFrmClass(Tgdc_dlgUserDocumentLine);

finalization
  UnRegisterFrmClass(Tgdc_dlgUserDocumentLine);
end.
