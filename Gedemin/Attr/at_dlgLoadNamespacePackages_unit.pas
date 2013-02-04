unit at_dlgLoadNamespacePackages_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, FileCtrl, ActnList, gdcNamespace, Db, DBClient,
  ComCtrls, gsDBTreeView, CheckLst;

const
  TItemColor: array [0..4] of TColor = (clBlack, clBlue, clBlack, clRed, clBlack);
  TItemFontStyles: array [0..4] of TFontStyles = ([fsBold], [fsBold], [], [], []);

type 
  Tat_dlgLoadNamespacePackages = class(TForm)
    Panel1: TPanel;
    eSearchPath: TEdit;
    btnBrowse: TButton;
    lSearch: TLabel;
    btnSearch: TButton;
    ActionListLoad: TActionList;
    actSearch: TAction;
    cds: TClientDataSet;
    cdsID: TIntegerField;
    cdsParent: TIntegerField;
    cdsNamespaceName: TStringField;
    ds: TDataSource;
    gsDBTreeView: TgsDBTreeView;
    lPackages: TLabel;
    cdsFilename: TStringField;
    cdsVersion: TStringField;
    cdsComment: TBlobField;
    mInfo: TMemo;
    cdsVersionInfo: TIntegerField;
    Label3: TLabel;
    Label5: TLabel;
    Panel2: TPanel;
    cbLegend: TCheckListBox;
    cdsRUID: TStringField;
    cdsDBVersion: TStringField;
    cdsFileTimeStamp: TDateTimeField;
    btnInstallPackage: TButton;
    btnClose: TButton;
    actInstallPackage: TAction;
    procedure btnBrowseClick(Sender: TObject);
    procedure actSearchExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cdsNewRecord(DataSet: TDataSet);
    procedure gsDBTreeViewClick(Sender: TObject);
    procedure cbLegendDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure actSearchUpdate(Sender: TObject);
    procedure gsDBTreeViewAdvancedCustomDrawItem(Sender: TCustomTreeView;
      Node: TTreeNode; State: TCustomDrawState; Stage: TCustomDrawStage;
      var PaintImages, DefaultDraw: Boolean);
    procedure gsDBTreeViewClickCheck(Sender: TObject; CheckID: String;
      var Checked: Boolean);
    procedure actInstallPackageExecute(Sender: TObject);
    procedure actInstallPackageUpdate(Sender: TObject);
  private
    FgdcNamespace: TgdcNamespace;
    FID: Integer;
    FOldWndProc: TWndMethod;

    function GetId: Integer;
    procedure SelectAllChild(Node: TTreeNode; bSel: boolean);
    procedure OverridingWndProc(var Message: TMessage);
    procedure SetFileList(SL: TStringList);
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
  FgdcNamespace := TgdcNamespace.Create(nil);
end;

destructor Tat_dlgLoadNamespacePackages.Destroy;
begin
  FgdcNamespace.Free;
  inherited;
end;

function Tat_dlgLoadNamespacePackages.GetId: Integer;
begin
  Inc(FID);
  Result := FID;
end;

procedure Tat_dlgLoadNamespacePackages.btnBrowseClick(Sender: TObject);
var
  Path: String;
begin
  if SelectDirectory('Укажите папку', '', Path) then
  begin
    eSearchPath.Text := Path;
  end;
end;

procedure Tat_dlgLoadNamespacePackages.SetFileList(SL: TStringList);
var
  I, Index: Integer;
  V: Variant;
begin
  Assert(SL <> nil);

  for I := 0 to gsDBTreeView.Items.Count - 1 do
  begin
    if gsDBTreeView.Items[I].StateIndex = 1 then
    begin
      V := cds.Lookup('id', Integer(gsDBTreeView.Items[I].Data), 'FileName');
      if not VarIsNull(V) then
      begin
        Index := SL.IndexOf(V);
        if Index <> -1 then
          SL.Delete(Index);
        SL.Insert(0, V);  
      end;
    end;
  end;
end;

procedure Tat_dlgLoadNamespacePackages.actSearchExecute(Sender: TObject);
begin
  if Trim(eSearchPath.Text) <> '' then
  begin
    FID := 0;
    gsDBTreeView.DataSource := nil;
    cds.DisableControls;
    try
      cds.EmptyDataSet;
      cds.Filtered := False;
      TgdcNamespace.ScanLinkNamespace(cds, eSearchPath.Text);
      gsDBTreeView.DataSource := ds;
    finally
      cds.EnableControls;
    end;
  end;
end;

procedure Tat_dlgLoadNamespacePackages.FormCreate(Sender: TObject);
begin
  FOldWndProc := gsDBTreeView.WindowProc;
  gsDBTreeView.WindowProc := OverridingWndProc;
  cds.CreateDataSet;
  cds.Open;
end;

procedure Tat_dlgLoadNamespacePackages.cdsNewRecord(DataSet: TDataSet);
begin
  DataSet.FieldByname('id').AsInteger := GetID;
end;

procedure Tat_dlgLoadNamespacePackages.gsDBTreeViewClick(Sender: TObject);
var
  Node: TTreeNode; 
begin
  mInfo.Clear;
  Node := gsDBTreeView.Selected;
  if Node <> nil then
  begin
    if cds.Locate('id', Integer(Node.Data), []) then
    begin
      mInfo.Lines.Add(cds.FieldByName('NamespaceName').AsString);
      mInfo.Lines.Add('Версия: ' + cds.FieldByName('version').AsString);
      mInfo.Lines.Add('RUID: ' + cds.FieldByName('ruid').AsString);
      mInfo.Lines.Add('Путь: ' + cds.FieldByName('filename').AsString);
      mInfo.Lines.Add('Изменен: ' + cds.FieldByName('filetimestamp').AsString);
    end;
  end;
end;

procedure Tat_dlgLoadNamespacePackages.cbLegendDrawItem(
  Control: TWinControl; Index: Integer; Rect: TRect;
  State: TOwnerDrawState);
var
  R: TRect;
begin
  R := Rect;
  cbLegend.Canvas.Font.Color := TItemColor[Index];
  cbLegend.Canvas.Font.Style  := TItemFontStyles[Index];
  cbLegend.Canvas.FillRect(Rect);
  cbLegend.Canvas.TextOut(R.left, R.top, cbLegend.Items[index]);
end;

procedure Tat_dlgLoadNamespacePackages.actSearchUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := Trim(eSearchPath.Text) <> '';
end;

procedure Tat_dlgLoadNamespacePackages.gsDBTreeViewAdvancedCustomDrawItem(
  Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState;
  Stage: TCustomDrawStage; var PaintImages, DefaultDraw: Boolean);
var
  V: Variant;
begin
  if (Stage = cdPrePaint) and (Node <> nil) and (Integer(Node.Data) > 0) then
  begin
    V := cds.Lookup('id', Integer(Node.Data), 'VersionInfo');
    if not VarIsNull(V) and (VarType(V) = varInteger) and (V > 0) then
    begin
      if cdsSelected in State then
        gsDBTreeView.Canvas.Font.Color := clWhite
      else
        gsDBTreeView.Canvas.Font.Color := TItemColor[Integer(V) - 1];
        gsDBTreeView.Canvas.Font.Style := TItemFontStyles[Integer(V) - 1];
    end;
    DefaultDraw := True;
  end;
end;

procedure Tat_dlgLoadNamespacePackages.SelectAllChild(Node: TTreeNode; bSel: boolean);
begin
  if (Node <> nil) then
  begin
    if bSel then
      Node.StateIndex := 1
    else
      Node.StateIndex := 2;
    if Node.HasChildren then
      SelectAllChild(Node.getFirstChild, bSel);
    SelectAllChild(Node.Parent.getNextChild(Node), bSel);
  end;
end;

procedure Tat_dlgLoadNamespacePackages.gsDBTreeViewClickCheck(
  Sender: TObject; CheckID: String; var Checked: Boolean);
var
  Node: TTreeNode;
begin
  Node := gsDBTreeView.Find(StrToInt(CheckID));
  if Node <> nil then
  begin
    SelectAllChild(Node.getFirstChild, Checked);
  end;
end; 

procedure Tat_dlgLoadNamespacePackages.OverridingWndProc(var Message: TMessage);
var
  Node: TTreeNode;
  V: Variant;
  Old: Boolean;
begin
  Old := True;
  if Message.Msg = WM_LBUTTONDOWN then
  begin
    if (htOnStateIcon in gsDBTreeView.GetHitTestInfoAt(TWMLButtonDown(Message).XPos, TWMLButtonDown(Message).YPos))
      or ((GetAsyncKeyState(VK_SHIFT) shr 1) <> 0) then
    begin
      Node := gsDBTreeView.GetNodeAt(TWMLButtonDown(Message).XPos, TWMLButtonDown(Message).YPos);
      if Node <> nil then
      begin
        V := cds.Lookup('id', Integer(Node.Data), 'VersionInfo');
        if not VarIsNull(V) and V = nvEqual then
          Old := False;
      end;
    end;
  end; 
  if Old then FOldWndProc(Message);
end;

procedure Tat_dlgLoadNamespacePackages.actInstallPackageExecute(
  Sender: TObject);
var
  SL: TStringList;
begin
  SL := TStringList.Create;
  try
    SetFileList(SL);
    TgdcNamespace.InstallPackeges(SL);
  finally
    SL.Free;
  end;
end;

procedure Tat_dlgLoadNamespacePackages.actInstallPackageUpdate(
  Sender: TObject);
begin
  TAction(Sender).Enabled := gsDBTreeView.TVState.Checked.Count > 0;
end;

initialization
  RegisterClass(Tat_dlgLoadNamespacePackages);

finalization
  UnRegisterClass(Tat_dlgLoadNamespacePackages);
end.
