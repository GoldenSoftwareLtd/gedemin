{++
   Project GDReference
   Copyright © 2000-2015 by Golden Software

   Модуль

     gdc_frmCurr_unit

   Описание

     Окно для работы с валютами

   Автор

     Smirnov Anton

   История

     ver    date         who    what
     1.00 - 29.08.2000 - SAI - Первая версия
     2.00 - 18.06.2002 - Julie - удаление лишних компонентов

 --}

unit gdc_frmCurr_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, ExtCtrls, ToolWin, gd_security,
  IBCustomDataSet, IBUpdateSQL, ImgList, IBSQL, Db, IBQuery, Menus,
  ActnList, Grids, DBGrids, StdCtrls, Mask, DBCtrls, IBDatabase, gsDBGrid,
  gsIBGrid, gdc_frmMDH_unit, flt_sqlFilter, gdc_frmMDV_unit, gdcCurr,
  gdcBase, TB2Item, TB2Dock, TB2Toolbar, dmDatabase_unit, gdc_frmMDVGR_unit,
  gd_MacrosMenu;

type
  Tgdc_frmCurr = class(Tgdc_frmMDVGR)
    gdcCurr: TgdcCurr;
    gdcCurrRate: TgdcCurrRate;
    procedure FormCreate(Sender: TObject);
  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  gdc_frmCurr: Tgdc_frmCurr;

implementation

{$R *.DFM}

uses
  Storages, gd_resourcestring,  gd_ClassList;

class function Tgdc_frmCurr.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gdc_frmCurr) then
    gdc_frmCurr := Tgdc_frmCurr.Create(AnOwner);
  Result := gdc_frmCurr
end;

procedure Tgdc_frmCurr.FormCreate(Sender: TObject);
begin
  gdcObject := gdcCurr;
  gdcDetailObject := gdcCurrRate;

  inherited;
end;

initialization
  RegisterFrmClass(Tgdc_frmCurr);

finalization
  UnRegisterFrmClass(Tgdc_frmCurr);

end.

