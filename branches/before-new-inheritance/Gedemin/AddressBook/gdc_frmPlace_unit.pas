{
  Окно просмотра
  Адм. территориальная единица
  gdcObject TgdcObject
}

unit gdc_frmPlace_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActnList, 
  ComCtrls, ToolWin, StdCtrls, ExtCtrls, gsDBTreeView, dmDatabase_unit,
  IBDatabase, Db, IBCustomDataSet, gdcBase, gdcPlace, Grids, DBGrids,
  gsDBGrid, gsIBGrid, Menus, flt_sqlFilter, gdcClasses, gdc_frmMDV_unit,
  gdc_frmMDVTree_unit, gdcConst, TB2Item, TB2Dock, TB2Toolbar, gdcTree,
  gd_MacrosMenu;

type
  Tgdc_frmPlace = class(Tgdc_frmMDVTree)
    actCopyToClipboardDetail2: TAction;
    actCutToClipboardDetail2: TAction;
    actPasteFromClipboardDetail2: TAction;
    gdcPlace: TgdcPlace;
    gdcPlaceDetail: TgdcPlace;

    procedure FormCreate(Sender: TObject);
    procedure actNewExecute(Sender: TObject);
  end;

var
  gdc_frmPlace: Tgdc_frmPlace;

implementation

{$R *.DFM}

uses
  gd_ClassList;

procedure Tgdc_frmPlace.FormCreate(Sender: TObject);
begin
  gdcObject := gdcPlace;
  gdcDetailObject := gdcPlaceDetail;

  inherited;
end;

procedure Tgdc_frmPlace.actNewExecute(Sender: TObject);
begin
  if gdcObject.CreateDialog then
    tvGroup.Refresh;
end;

initialization
  RegisterFrmClass(Tgdc_frmPlace);

finalization
  UnRegisterFrmClass(Tgdc_frmPlace);
end.
