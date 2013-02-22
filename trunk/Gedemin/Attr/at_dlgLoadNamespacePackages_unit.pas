unit at_dlgLoadNamespacePackages_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, FileCtrl, ActnList, gdcNamespace, Db, DBClient,
  ComCtrls, gsDBTreeView, CheckLst, IBSQL, gsTreeView, gd_createable_form;

const
  TItemColor: array [0..4] of TColor = (clBlack, clBlue, clBlack, clRed, clBlack);
  TItemFontStyles: array [0..4] of TFontStyles = ([fsBold], [fsBold], [], [], []);

type 
  Tat_dlgLoadNamespacePackages = class(TCreateableForm)
    Panel1: TPanel;
    ActionListLoad: TActionList;
    actSearch: TAction;
    lPackages: TLabel;
    mInfo: TMemo;
    Label3: TLabel;
    actInstallPackage: TAction;
    gsTreeView: TgsTreeView;
    Panel5: TPanel;
    lSearch: TLabel;
    Label1: TLabel;
    eSearchPath: TEdit;
    btnBrowse: TButton;
    btnSearch: TButton;
    Panel6: TPanel;
    btnInstallPackage: TButton;
    btnClose: TButton;
    Panel2: TPanel;
    cbLegend: TCheckListBox;
    Label2: TLabel;
    procedure btnBrowseClick(Sender: TObject);
    procedure actSearchExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cbLegendDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure actSearchUpdate(Sender: TObject);
    procedure actInstallPackageExecute(Sender: TObject);
    procedure actInstallPackageUpdate(Sender: TObject);
  private
    FgdcNamespace: TgdcNamespace;
    FOldWndProc: TWndMethod;

    procedure SelectAllChild(Node: TTreeNode; bSel: boolean);
    procedure OverridingWndProc(var Message: TMessage);
    procedure SetFileList(SL: TStringList);
    procedure CreateTree; 
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
  gd_GlobalParams_unit, gd_security, gdcBaseInterface, IBDatabase;

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
  q: TIBSQL;
begin
  Assert(SL <> nil);

  q := TIBSQL.Create(nil);
  try
    q.Transaction := gdcBaseManager.ReadTransaction;
    q.SQL.Text := 'SELECT * FROM at_namespace_gtt WHERE settingruid = :sr';

    for I := 0 to gsTreeView.Items.Count - 1 do
    begin
      if gsTreeView.Items[I].StateIndex = 1 then
      begin
        q.Close;
        q.ParamByName('sr').AsString := String(gsTreeView.Items[I].Data);
        q.ExecQuery;

        if not q.Eof then
        begin
          Index := SL.IndexOf(q.FieldByName('filename').AsString);
          if Index <> -1 then
            SL.Delete(Index);
          SL.Insert(0, q.FieldByName('filename').AsString);
        end;
      end;
    end;
  finally
    q.Free;
  end;
end;

procedure Tat_dlgLoadNamespacePackages.actSearchExecute(Sender: TObject);
var
  Tr: TIBTransaction;
  q: TIBSQL;
begin
  Assert(gdcBaseManager <> nil);

  Tr := TIBTransaction.Create(nil);
  q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := gdcBaseManager.Database;
    Tr.StartTransaction;
    q.Transaction := Tr;
    q.SQL.Text := 'DELETE FROM at_namespace_gtt';
    q.ExecQuery;
    q.Close;

    Tr.Commit;
    Tr.StartTransaction;

    q.SQL.Text := 'DELETE FROM at_namespace_link_gtt';
    q.ExecQuery;
    q.Close;

    Tr.Commit;
  finally
    Tr.Free;
    q.Free;
  end;

  gsTreeView.SortType := stNone;
  gsTreeView.Items.Clear;

  if Trim(eSearchPath.Text) <> '' then
  begin
    TgdcNamespace.ScanLinkNamespace2(eSearchPath.Text);
    gsTreeView.Items.BeginUpdate;
    try
      CreateTree;
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
        if Node.StateIndex <> 1 then
          Node.StateIndex := 1
        else
          Node.StateIndex := 2; 
        SelectAllChild(Node.getFirstChild, Node.StateIndex = 1);
      end;
      Old := False;
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
   // TgdcNamespace.InstallPackages(SL);
  finally
    SL.Free;
  end;
end;

procedure Tat_dlgLoadNamespacePackages.actInstallPackageUpdate(
  Sender: TObject);
begin
  TAction(Sender).Enabled := Assigned(IBLogin)
    and IBLogin.IsIBUserAdmin;
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

procedure Tat_dlgLoadNamespacePackages.CreateTree;

  procedure AddNamespace(Node: TTreeNode; const RUID: String);
  var
    q: TIBSQL;
    Temp: TTreeNode;
  begin
     q := TIBSQL.Create(nil);
     try
       q.Transaction := gdcBasemanager.ReadTransaction;
       q.SQL.Text := 'SELECT * FROM at_namespace_gtt WHERE settingruid = :sr';
       q.ParamByName('sr').AsString := RUID;
       q.ExecQuery;

       if not q.Eof then
       begin
         Temp := gsTreeView.Items.AddChildObject(Node, q.FieldByname('name').AsString, PChar(q.FieldByname('settingruid').AsString));
         Temp.StateIndex := 2;
         q.Close;
         q.SQL.Text := 'SELECT * FROM at_namespace_link_gtt WHERE namespaceruid = :ur';
         q.ParamByName('ur').AsString := RUID;
         q.ExecQuery;

         while not q.Eof do
         begin
           AddNamespace(Temp, q.FieldByName('usesruid').AsString);
           q.Next;
         end;
       end;
     finally
       q.Free;
     end;
  end;
  
var
  q: TIBSQL;
begin

  q := TIBSQL.Create(nil);
  try
    q.Transaction := gdcBaseManager.ReadTransaction;
    q.SQL.Text := 'SELECT * FROM at_namespace_gtt n ' +
      'WHERE EXISTS(SELECT * FROM at_namespace_link_gtt WHERE namespaceruid = n.settingruid) ' +
      '  AND NOT EXISTS(SELECT * FROM at_namespace_link_gtt WHERE usesruid = n.settingruid)';
    q.ExecQuery;
    while not q.Eof do
    begin
      AddNamespace(nil, q.FieldByName('settingruid').AsString);
      q.Next;
    end;
  finally
    q.Free;
  end;
end;

initialization
  RegisterClass(Tat_dlgLoadNamespacePackages);

finalization
  UnRegisterClass(Tat_dlgLoadNamespacePackages);
end.
