// ShlTanya, 09.03.2019

unit gdc_frmAcctAccCard_Unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, gd_MacrosMenu, Db, Menus, ActnList, Grids, DBGrids,
  gsDBGrid, gsIBGrid, StdCtrls, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar,
  ComCtrls, IBCustomDataSet, gdcBase, gdcLedger, gd_ClassList,
  gdcAcctConfig;

type
  Tgdc_frmAcctAccCard = class(Tgdc_frmSGR)
    gdcAcctAccConfig: TgdcAcctAccConfig;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_frmAcctAccCard: Tgdc_frmAcctAccCard;

implementation

{$R *.DFM}

procedure Tgdc_frmAcctAccCard.FormCreate(Sender: TObject);
begin
  inherited;
  gdcObject := gdcAcctAccConfig;
  gdcObject.Open;
end;
initialization
  RegisterFrmClass(Tgdc_frmAcctAccCard);
finalization
  UnRegisterFrmClass(Tgdc_frmAcctAccCard);

end.
