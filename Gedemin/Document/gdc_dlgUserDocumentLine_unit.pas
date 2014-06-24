
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
    class function GetSubTypeList(SubTypeList: TStrings;
      Subtype: string = ''; OnlyDirect: Boolean = False): Boolean; override;
    class function ClassParentSubtype(Subtype: String): String; override;
  end;

var
  gdc_dlgUserDocumentLine: Tgdc_dlgUserDocumentLine;

implementation

{$R *.DFM}

uses
  gd_ClassList, gdcClasses;

{ Tgdc_dlgUserDocumentLine }

class function Tgdc_dlgUserDocumentLine.GetSubTypeList(
  SubTypeList: TStrings; Subtype: string = ''; OnlyDirect: Boolean = False): Boolean;
begin
  Result := TgdcUserDocument.GetSubTypeList(SubTypeList, Subtype, OnlyDirect);
end;

class function Tgdc_dlgUserDocumentLine.ClassParentSubtype(
  Subtype: String): String;
begin
  Result := TgdcUserDocument.ClassParentSubtype(SubType);
end;

initialization
  RegisterFrmClass(Tgdc_dlgUserDocumentLine);

finalization
  UnRegisterFrmClass(Tgdc_dlgUserDocumentLine);
end.
