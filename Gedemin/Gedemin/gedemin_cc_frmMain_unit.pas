unit gedemin_cc_frmMain_unit;

interface

uses
  Classes, Controls, Forms, SysUtils, FileCtrl, StdCtrls,
  Menus, ExtCtrls, ComCtrls, Grids, DBGrids, Db;

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
    DBGrid1: TDBGrid;
    SB: TStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

  private

  protected

  public

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

end.
