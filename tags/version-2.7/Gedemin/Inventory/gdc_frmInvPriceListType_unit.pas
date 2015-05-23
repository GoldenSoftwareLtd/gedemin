
{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    gdc_frmInvDocumentType_unit.pas

  Abstract

    Part of a business class. Inventory documents.

  Author

    Romanovski Denis (23-09-2001)

  Revisions history

    Initial  23-09-2001  Dennis  Initial version.

--}

unit gdc_frmInvPriceListType_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, Db, Menus, ActnList, Grids, DBGrids, gsDBGrid, gsIBGrid,
  ComCtrls, ToolWin, ExtCtrls, IBCustomDataSet, gdcBase,
  gdcInvPriceList_unit, TB2Item, TB2Dock, TB2Toolbar, gdcTree, gdcClasses,
  gd_MacrosMenu, StdCtrls;

type
  Tgdc_frmInvPriceListType = class(Tgdc_frmSGR)
    gdcInvPriceListType: TgdcInvPriceListType;

    procedure FormCreate(Sender: TObject);
    procedure actHlpExecute(Sender: TObject);

  private

  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;

  end;

var
  gdc_frmInvPriceListType: Tgdc_frmInvPriceListType;

implementation

{$R *.DFM}

uses gdc_frmInvPriceList_unit,  gd_ClassList;

procedure Tgdc_frmInvPriceListType.FormCreate(Sender: TObject);
begin
  inherited;

  gdcObject := gdcInvPriceListType;

  gdcObject.Open;
end;

procedure Tgdc_frmInvPriceListType.actHlpExecute(Sender: TObject);
begin
  inherited;

  with Tgdc_frmInvPriceList.CreateSubType(Self,
    gdcInvPriceListType.FieldByName('ruid').AsString) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

class function Tgdc_frmInvPriceListType.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gdc_frmInvPriceListType) then
    gdc_frmInvPriceListType := Tgdc_frmInvPriceListType.Create(AnOwner);

  Result := gdc_frmInvPriceListType;
end;

initialization
  RegisterFrmClass(Tgdc_frmInvPriceListType);

  //RegisterClass(Tgdc_frmInvPriceListType);

finalization
  UnRegisterFrmClass(Tgdc_frmInvPriceListType);

end.

