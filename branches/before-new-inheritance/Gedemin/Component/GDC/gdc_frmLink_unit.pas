unit gdc_frmLink_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmSGR_unit, Db, IBCustomDataSet, gdcBase, gdcLink, gd_MacrosMenu,
  Menus, ActnList, Grids, DBGrids, gsDBGrid, gsIBGrid, StdCtrls, ExtCtrls,
  TB2Item, TB2Dock, TB2Toolbar, ComCtrls;

type
  Tgdc_frmLink = class(Tgdc_frmSGR)
    gdcLink: TgdcLink;
    procedure FormCreate(Sender: TObject);
    procedure actNewExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gdc_frmLink: Tgdc_frmLink;

implementation

{$R *.DFM}

uses
  gd_ClassList;

procedure Tgdc_frmLink.FormCreate(Sender: TObject);
begin
  gdcObject := gdcLink;

  inherited;
end;

procedure Tgdc_frmLink.actNewExecute(Sender: TObject);
begin
  if gdcLink.ObjectKey > 0 then
    gdcLink.AddLinkedObjectDialog
  else
    inherited;  
end;

initialization
  RegisterFrmClass(Tgdc_frmLink);

finalization
  UnRegisterFrmClass(Tgdc_frmLink);
end.
