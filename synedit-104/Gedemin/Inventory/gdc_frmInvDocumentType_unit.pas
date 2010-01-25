
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

unit gdc_frmInvDocumentType_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, Db, Menus, ActnList, Grids, DBGrids, gsDBGrid, gsIBGrid,
  ComCtrls, ToolWin, ExtCtrls, IBCustomDataSet, gdcBase,
  gdcInvDocument_unit, TB2Item, TB2Dock, TB2Toolbar, gdcTree, gdcClasses,
  gd_MacrosMenu, StdCtrls;

type
  Tgdc_frmInvDocumentType = class(Tgdc_frmSGR)
    gdcDocumentType: TgdcInvDocumentType;
    procedure FormCreate(Sender: TObject);
    procedure actHlpExecute(Sender: TObject);
  private

  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;

  end;

var
  gdc_frmInvDocumentType: Tgdc_frmInvDocumentType;

implementation

{$R *.DFM}

uses gdc_frmInvDocument_unit,  gd_ClassList;

procedure Tgdc_frmInvDocumentType.FormCreate(Sender: TObject);
begin
  inherited;

  gdcObject := gdcDocumentType;
  gdcDocumentType.Open;
end;

procedure Tgdc_frmInvDocumentType.actHlpExecute(Sender: TObject);
begin
  inherited;

  with Tgdc_frmInvDocument.CreateSubType(Self,
    gdcDocumentType.FieldByName('ruid').AsString) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

class function Tgdc_frmInvDocumentType.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gdc_frmInvDocumentType) then
    gdc_frmInvDocumentType := Tgdc_frmInvDocumentType.Create(AnOwner);

  Result := gdc_frmInvDocumentType;
end;

initialization
  RegisterFrmClass(Tgdc_frmInvDocumentType);

  //RegisterClass(Tgdc_frmInvDocumentType);

finalization
  UnRegisterFrmClass(Tgdc_frmInvDocumentType);

end.
