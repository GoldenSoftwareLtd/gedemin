
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
  protected
    function GetFormCaptionPrefix: String; override;
  end;

var
  gdc_dlgUserDocumentLine: Tgdc_dlgUserDocumentLine;

implementation

{$R *.DFM}

uses
  gd_ClassList, gdcClasses, IBSQL, gdcBaseInterface, gdcBase;

{ Tgdc_dlgUserDocumentLine }

function Tgdc_dlgUserDocumentLine.GetFormCaptionPrefix: String;
begin
  if gdcObject.State = dsInsert then
    Result := 'Добавление позиции документа: '
  else if gdcObject.State = dsEdit then
    Result := 'Редактирование позиции документа: '
  else
    Result := 'Просмотр позиции документа: ';
end;

initialization
  RegisterFrmClass(Tgdc_dlgUserDocumentLine);

finalization
  UnRegisterFrmClass(Tgdc_dlgUserDocumentLine);
end.
