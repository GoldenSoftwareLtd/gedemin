unit gedemin_cc_frmMain_unit;

interface

uses
  Classes, Controls, Forms, SysUtils, FileCtrl, StdCtrls, Windows,
  Menus, ExtCtrls, ComCtrls, Grids, DBGrids, Db, DBCtrls;

type
  Tfrm_gedemin_cc_main = class(TForm)
    pnlTop: TPanel;
    pnlLeft: TPanel;
    pnlRight: TPanel;
    pnlBottom: TPanel;
    pnlCenter: TPanel;
    pnlFilt: TPanel;
    mLog: TMemo;
    lbClients: TListBox;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    DBGr: TDBGrid;
    SB: TStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

  private

  protected

  public
    procedure DBGrWidth();
  end;

var
  frm_gedemin_cc_main: Tfrm_gedemin_cc_main;

implementation

uses
  gedemin_cc_DataModule_unit, gedemin_cc_TCPServer_unit;

{$R *.DFM}

procedure Tfrm_gedemin_cc_main.FormCreate(Sender: TObject);
begin
  SB.Panels[0].Text := DM.IBDB.DatabaseName;
  ccTCPServer.Connect;
end;

procedure Tfrm_gedemin_cc_main.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  ccTCPServer.Disconnect;
end;

procedure Tfrm_gedemin_cc_main.DBGrWidth();
var
  i, cf, cc, FWidth, CWidth: Integer;
begin
  FWidth := 0;
  if DM.IBDS.RecordCount > 0 then
  begin
    cf := DBGr.FieldCount - 1;
    cc := DBGr.Columns.Count - 1;
    for i := 0 to cf do
      DBGr.Fields[i].DisplayWidth := Length(DBGr.Fields[i].Value);
    for i := 0 to cc do
      FWidth := FWidth + DBGr.Columns[i].Width;
    FWidth := FWidth + DBGr.FieldCount;
    CWidth := DBGr.ClientWidth - FWidth;
    // DisplayWidth - ширина в символах, ClientWidth - ширина в px
    if CWidth > 0 then
      DBGr.Columns[cc].Width := DBGr.Columns[cc].Width + CWidth;
  end;
end;


end.
