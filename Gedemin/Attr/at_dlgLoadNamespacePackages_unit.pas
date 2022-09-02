// ShlTanya, 02.02.2019

unit at_dlgLoadNamespacePackages_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, Forms, Dialogs,
  StdCtrls, FileCtrl, ActnList, Db, gsDBTreeView, gd_createable_form,
  gdcNamespaceSyncController, ComCtrls, ExtCtrls;

type
  Tat_dlgLoadNamespacePackages = class(TCreateableForm)
    pnlTree: TPanel;
    ActionListLoad: TActionList;
    actSearch: TAction;
    pnlTop: TPanel;
    lSearch: TLabel;
    Label1: TLabel;
    eSearchPath: TEdit;
    btnSearch: TButton;
    pnlBottom: TPanel;
    lPackages: TLabel;
    btnSelectFolder: TButton;
    actSelectFolder: TAction;
    dbtvFiles: TgsDBTreeView;
    ds: TDataSource;
    mInfo: TMemo;
    Panel1: TPanel;
    btnClose: TButton;
    procedure actSearchExecute(Sender: TObject);
    procedure actSelectFolderExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actSearchUpdate(Sender: TObject);

  private
    FNSC: TgdcNamespaceSyncController;

    procedure Log(const AMessageType: TLogMessageType; const AMessage: String);

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  at_dlgLoadNamespacePackages: Tat_dlgLoadNamespacePackages;

implementation

{$R *.DFM}

constructor Tat_dlgLoadNamespacePackages.Create(AnOwner: TComponent);
begin
  inherited;
  FNSC := TgdcNamespaceSyncController.Create;
  FNSC.UpdateCurrModified := False;
  FNSC.OnLogMessage := Log;
end;

destructor Tat_dlgLoadNamespacePackages.Destroy;
begin
  FNSC.Free;
  inherited;
end;

procedure Tat_dlgLoadNamespacePackages.Log(const AMessageType: TLogMessageType;
  const AMessage: string);
begin
  mInfo.Lines.Add(AMessage);
end;

procedure Tat_dlgLoadNamespacePackages.actSearchExecute(Sender: TObject);
var
  OldCursor: TCursor;
begin
  mInfo.Clear;
  FNSC.Directory := eSearchPath.Text;
  FNSC.Scan(True, False, True, True);

  OldCursor := Screen.Cursor;
  try
    Screen.Cursor := crHourGlass;
    FNSC.BuildTree;
  finally
    Screen.Cursor := OldCursor;
  end;
end;

procedure Tat_dlgLoadNamespacePackages.actSelectFolderExecute(
  Sender: TObject);
var
  Path: String;
begin
  Path := eSearchPath.Text;
  if SelectDirectory(Path, [], 0) then
    eSearchPath.Text := Path;
end;

procedure Tat_dlgLoadNamespacePackages.FormCreate(Sender: TObject);
begin
  ds.DataSet := FNSC.dsFileTree;
  eSearchPath.Text := FNSC.Directory;
end;

procedure Tat_dlgLoadNamespacePackages.actSearchUpdate(Sender: TObject);
begin
  actSearch.Enabled := DirectoryExists(eSearchPath.Text) or
    FileExists(eSearchPath.Text);
end;

initialization
  RegisterClass(Tat_dlgLoadNamespacePackages);

finalization
  UnRegisterClass(Tat_dlgLoadNamespacePackages);
end.
