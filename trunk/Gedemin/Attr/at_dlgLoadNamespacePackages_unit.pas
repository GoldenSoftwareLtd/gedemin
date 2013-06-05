unit at_dlgLoadNamespacePackages_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, FileCtrl, ActnList, gdcNamespace, Db, DBClient,
  ComCtrls, gsDBTreeView, CheckLst, IBSQL, gsTreeView, gd_createable_form,
  gdcBase, gsNSObjects;

type
  Tat_dlgLoadNamespacePackages = class(TCreateableForm)
    pnlTree: TPanel;
    ActionListLoad: TActionList;
    actSearch: TAction;
    actInstallPackage: TAction;
    gsTreeView: TgsTreeView;
    pnlTop: TPanel;
    lSearch: TLabel;
    Label1: TLabel;
    eSearchPath: TEdit;
    btnSearch: TButton;
    pnlBottom: TPanel;
    mInfo: TMemo;
    lPackages: TLabel;
    pnlBottomRight: TPanel;
    btnInstallPackage: TButton;
    btnClose: TButton;
    cbAlwaysOverwrite: TCheckBox;
    cbDontRemove: TCheckBox;
    GroupBox1: TGroupBox;
    lblLegendNotInstalled: TLabel;
    lblLegendNewer: TLabel;
    lblLegendEqual: TLabel;
    lblLegendOlder: TLabel;
    procedure actSearchExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);  
    procedure gsTreeViewAdvancedCustomDrawItem(Sender: TCustomTreeView;
      Node: TTreeNode; State: TCustomDrawState; Stage: TCustomDrawStage;
      var PaintImages, DefaultDraw: Boolean);
    procedure gsTreeViewClick(Sender: TObject);
  private
    FgdcNamespace: TgdcNamespace;
    FOldWndProc: TWndMethod;
    List: TgsNSList;

    procedure SelectAllChild(Node: TTreeNode; bSel: boolean);
    procedure OverridingWndProc(var Message: TMessage);
    procedure Log(const AMessage: string);
  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure SaveSettings; override;
    procedure LoadSettingsAfterCreate; override;
  end;

var
  at_dlgLoadNamespacePackages: Tat_dlgLoadNamespacePackages;

implementation

{$R *.DFM}

uses
  gd_GlobalParams_unit, gd_security, gdcBaseInterface, IBDatabase,  gd_KeyAssoc;

const
  TItemColor: array [TgsNSState] of TColor = (clBlack, clBlack, clRed, clGray, clBlack);
  TItemFontStyles: array [TgsNSState] of TFontStyles = ([], [fsBold], [fsBold], [], []);
  InvalidFile = clRed;

constructor Tat_dlgLoadNamespacePackages.Create(AnOwner: TComponent);
begin
  inherited;
  FgdcNamespace := TgdcNamespace.Create(nil);
  List := TgsNSList.Create;
  List.Log := Log;
end;

destructor Tat_dlgLoadNamespacePackages.Destroy;
begin
  FgdcNamespace.Free;
  List.Free;
  inherited;
end;

procedure Tat_dlgLoadNamespacePackages.Log(const AMessage: string);
begin
  mInfo.Lines.Add(AMessage);
end;

procedure Tat_dlgLoadNamespacePackages.actSearchExecute(Sender: TObject);
var
  Path: String;
begin
  Path := eSearchPath.Text;
  mInfo.Clear;
  if SelectDirectory(Path, [], 0) then
  begin
    eSearchPath.Text := Path;
    List.GetFilesForPath(Path);

    gsTreeView.Items.BeginUpdate;
    try
      gsTreeView.Items.Clear;
      List.FillTree(gsTreeView);
    finally
      gsTreeView.Items.EndUpdate;
    end;
  end;
end;

procedure Tat_dlgLoadNamespacePackages.FormCreate(Sender: TObject);
begin
  FOldWndProc := gsTreeView.WindowProc;
  gsTreeView.WindowProc := OverridingWndProc;
end;

procedure Tat_dlgLoadNamespacePackages.SelectAllChild(Node: TTreeNode; bSel: boolean);
begin
  if (Node <> nil) then
  begin
    if bSel then
    begin
      if (TgsNSNode(Node.Data).Optional = False)
        and (TgsNSNode(Node.Data).GetNSState in [nsNotInstalled, nsNewer, nsEqual])
      then
        Node.StateIndex := 1
    end else
      Node.StateIndex := 2;
    SelectAllChild(Node.getFirstChild, bSel);
    SelectAllChild(Node.Parent.getNextChild(Node), bSel);
  end;
end;

procedure Tat_dlgLoadNamespacePackages.OverridingWndProc(var Message: TMessage);
var
  Node: TTreeNode;
  Old: Boolean;
begin
  Old := True;
  if Message.Msg = WM_LBUTTONDOWN then
  begin
    if htOnStateIcon in gsTreeView.GetHitTestInfoAt(TWMLButtonDown(Message).XPos, TWMLButtonDown(Message).YPos) then
    begin
      Node := gsTreeView.GetNodeAt(TWMLButtonDown(Message).XPos, TWMLButtonDown(Message).YPos);
      if Node <> nil then
      begin
        case Node.StateIndex of
          1:
          begin
            Node.StateIndex := 2;
            SelectAllChild(Node.getFirstChild, False);
          end;
          2:
          begin
            Node.StateIndex := 1;
            SelectAllChild(Node.getFirstChild, True);
          end;
        end; 
      end;
      Old := False;
    end;
  end;
  if Old then FOldWndProc(Message);
end;

procedure Tat_dlgLoadNamespacePackages.LoadSettingsAfterCreate;
begin
  inherited;
  eSearchPath.Text := gd_GlobalParams.NamespacePath;
end;

procedure Tat_dlgLoadNamespacePackages.SaveSettings;
begin
  gd_GlobalParams.NamespacePath := eSearchPath.Text;
  inherited;
end; 

procedure Tat_dlgLoadNamespacePackages.gsTreeViewAdvancedCustomDrawItem(
  Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState;
  Stage: TCustomDrawStage; var PaintImages, DefaultDraw: Boolean);
begin
  if (Stage = cdPrePaint) and (Node <> nil) then
  begin
    if cdsSelected in State then
      gsTreeView.Canvas.Font.Color := clWhite
    else if not TgsNSNode(Node.Data).Valid then
      gsTreeView.Canvas.Font.Color := InvalidFile
    else
     gsTreeView.Canvas.Font.Color := TItemColor[TgsNSNode(Node.Data).GetNSState];

    gsTreeView.Canvas.Font.Style := TItemFontStyles[TgsNSNode(Node.Data).GetNSState]; 
    if not TgsNSNode(Node.Data).CheckDBVersion then
      gsTreeView.Canvas.Font.Style := gsTreeView.Canvas.Font.Style + [fsStrikeOut];
    DefaultDraw := True;
  end;
end;

procedure Tat_dlgLoadNamespacePackages.gsTreeViewClick(Sender: TObject);
var
  Node: TTreeNode;
begin
  mInfo.Clear;
  Node := gsTreeView.Selected;
  if (Node <> nil) and (Node.Data <> nil) then
    TgsNSNode(Node.Data).FillInfo(mInfo.Lines);
end;

initialization  
  RegisterClass(Tat_dlgLoadNamespacePackages);

finalization
  UnRegisterClass(Tat_dlgLoadNamespacePackages);
end.
