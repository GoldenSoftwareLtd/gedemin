unit gd_DatabasesListDlg_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ActnList, gd_DatabasesList_unit;

type
  Tgd_DatabasesListDlg = class(TForm)
    Label1: TLabel;
    edName: TEdit;
    Label2: TLabel;
    edServer: TEdit;
    Label4: TLabel;
    edFileName: TEdit;
    btnOk: TButton;
    btnCancel: TButton;
    btnSelectFile: TButton;
    ActionList: TActionList;
    actOk: TAction;
    Label3: TLabel;
    OpenDialog: TOpenDialog;
    btnCliboard: TButton;
    procedure btnSelectFileClick(Sender: TObject);
    procedure actOkUpdate(Sender: TObject);
    procedure actOkExecute(Sender: TObject);
    procedure btnCliboardClick(Sender: TObject);

  private
    FDI: Tgd_DatabaseItem;
    procedure SetDI(const Value: Tgd_DatabaseItem);

  public
    property DI: Tgd_DatabaseItem read FDI write SetDI;
  end;

var
  gd_DatabasesListDlg: Tgd_DatabasesListDlg;

implementation

{$R *.DFM}

uses
  ClipBrd, gd_common_functions;

procedure Tgd_DatabasesListDlg.btnSelectFileClick(Sender: TObject);
begin
  if edFileName.Text > '' then
    OpenDialog.FileName := edFileName.Text
  else
    OpenDialog.InitialDir := ExtractFilePath(Application.EXEName);
  if OpenDialog.Execute then
  begin
    edFileName.Text := OpenDialog.FileName;
    if edName.Text = '' then
      edName.Text := ExtractFileName(edFileName.Text);
  end;
end;

procedure Tgd_DatabasesListDlg.actOkUpdate(Sender: TObject);
begin
  actOk.Enabled := (Trim(edName.Text) > '')
    and (Trim(edFileName.Text) > '')
    and (
      (FDI = nil)
      or
      ((FDI.Collection as Tgd_DatabasesList).FindByName(Trim(edName.Text)) = nil)
      or
      ((FDI.Collection as Tgd_DatabasesList).FindByName(Trim(edName.Text)) = FDI)
    );
end;

procedure Tgd_DatabasesListDlg.actOkExecute(Sender: TObject);
begin
  if FDI <> nil then
  begin
    FDI.Name := Trim(edName.Text);
    FDI.Server := Trim(edServer.Text);
    FDI.FileName := Trim(edFileName.Text);
  end;

  ModalResult := mrOk;
end;

procedure Tgd_DatabasesListDlg.SetDI(const Value: Tgd_DatabaseItem);
begin
  FDI := Value;

  if FDI <> nil then
  begin
    edName.Text := FDI.Name;
    edServer.Text := FDI.Server;
    edFileName.Text := FDI.FileName;
  end;
end;

procedure Tgd_DatabasesListDlg.btnCliboardClick(Sender: TObject);
var
  FN, Srv: String;
  Port: Integer;
begin
  if Length(Clipboard.AsText) < 299 then
  begin
    ParseDatabaseName(Clipboard.AsText, Srv, Port, FN);
    edName.Text := ExtractFileName(FN);
    edServer.Text := Srv;
    edFileName.Text := FN;
  end;
end;

end.
