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
    procedure gsTreeViewAdvancedCustomDrawItem(Sender: TCustomTreeView;
      Node: TTreeNode; State: TCustomDrawState; Stage: TCustomDrawStage;
      var PaintImages, DefaultDraw: Boolean);
    procedure gsTreeViewClick(Sender: TObject);
  private
    FgdcNamespace: TgdcNamespace;
    FOldWndProc: TWndMethod;
    List: TgsyamlList;

    procedure SelectAllChild(Node: TTreeNode; bSel: boolean);
    procedure OverridingWndProc(var Message: TMessage); 
    procedure CreateTree; 
  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure SaveSettings; override;
    procedure LoadSettingsAfterCreate; override;
    procedure SetFileList(SL: TStringList);
  end;

var
  at_dlgLoadNamespacePackages: Tat_dlgLoadNamespacePackages;

implementation
                               
{$R *.DFM}

uses
  gd_GlobalParams_unit, gd_security, gdcBaseInterface, IBDatabase,  gd_KeyAssoc;

constructor Tat_dlgLoadNamespacePackages.Create(AnOwner: TComponent);
begin
  inherited;
  FgdcNamespace := TgdcNamespace.Create(nil);
  List := TgsyamlList.Create;
end;

destructor Tat_dlgLoadNamespacePackages.Destroy;
begin
  FgdcNamespace.Free;
  List.Free;
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
  KA: TgdKeyArray;
begin
  Assert(SL <> nil);

  KA := TgdKeyArray.Create;
  try
    for I := 0 to gsTreeView.Items.Count - 1 do
    begin
      if gsTreeView.Items[I].StateIndex = 1 then
        KA.Add(Integer(gsTreeView.Items[I].Data), True);
    end;

    if KA.Count > 0 then
    begin
      q := TIBSQL.Create(nil);
      try
        q.Transaction := gdcBaseManager.ReadTransaction;
        q.SQL.Text :=
          'WITH RECURSIVE ' +
          '  ns_tree AS ( ' +
          '    SELECT ' +
          '      n.settingruid, ' +
          '      n.id, ' +
          '      0 AS cnt, ' +
          '      n.filename ' +
          '    FROM ' +
          '      at_namespace_gtt n ' +
          '    WHERE ' +
          '      id = :id ' +
          '    UNION ALL ' +
          '    SELECT ' +
          '      u.settingruid, ' +
          '      u.id, ' + 
          '      (t.cnt + 1), ' +
          '      u.filename ' +
          '    FROM at_namespace_link_gtt l ' +
          '      JOIN ns_tree t ON l.namespaceruid = t.settingruid ' +
          '      JOIN at_namespace_gtt u ON u.settingruid = l.usesruid' +
          '    WHERE ' +
          '      t.cnt < 20 ' +
          '  ) ' +
          'SELECT ' +
          '  id, cnt, filename ' +
          'FROM ' +
          '  ns_tree ' +
          'ORDER BY cnt desc';

        while KA.Count > 0 do
        begin
          q.Close;
          q.ParamByName('id').AsInteger := KA[0];
          q.ExecQuery;

          if q.Eof then
          begin
            KA.Delete(0);
            continue;
          end;

          while not q.Eof do
          begin
            Index := KA.IndexOf(q.FieldByName('id').AsInteger);
            if  Index <> -1 then
            begin
              SL.Add(q.FieldByName('filename').AsString);
              KA.Delete(Index);
            end;
            q.Next;
          end;
        end;
      finally
        q.Free;
      end;
    end;
  finally
    KA.Free; 
  end;
end;

procedure Tat_dlgLoadNamespacePackages.actSearchExecute(Sender: TObject);
var
  Tr: TIBTransaction;
  q: TIBSQL;
begin
  gsTreeView.SortType := stNone;
  gsTreeView.Items.Clear;
  gsTreeView.Invalidate;
  List.Clear;

    if Trim(eSearchPath.Text) <> '' then
      List.GetFilesForPath(Trim(eSearchPath.Text));

    minfo.Lines.Add('количество = ' + IntToStr(List.Count));
    gsTreeView.Items.BeginUpdate;
    try
      TgdcNamespace.FillTree(gsTreeView, List, True);
    finally
      gsTreeView.Items.EndUpdate;
    end; 
 { Assert(gdcBaseManager <> nil);

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
  end; }
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
    begin
      if TgsyamlNode(Node.Data).Optional = False then
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
begin
  FgdcNamespace.DoLoadNamespace(List);
  ModalResult := mrOK;
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
         Temp := gsTreeView.Items.AddChildObject(Node, q.FieldByname('name').AsString, Pointer(q.FieldByname('id').AsInteger));
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

procedure Tat_dlgLoadNamespacePackages.gsTreeViewAdvancedCustomDrawItem(
  Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState;
  Stage: TCustomDrawStage; var PaintImages, DefaultDraw: Boolean);
var
  R: OleVariant;
begin
  DefaultDraw := True;
 { if (Stage = cdPrePaint) and (Node <> nil) and (Integer(Node.Data) > 0) then
  begin
    gdcBaseManager.ExecSingleQueryResult(
      'SELECT operation FROM at_namespace_gtt WHERE id = :id',
      Integer(Node.Data), R);
    if not VarIsEmpty(R) then
    begin
      if cdsSelected in State then
        gsTreeView.Canvas.Font.Color := clWhite
      else
        gsTreeView.Canvas.Font.Color := TItemColor[Integer(R[0, 0]) - 1];
        gsTreeView.Canvas.Font.Style := TItemFontStyles[Integer(R[0, 0]) - 1];
    end;
    DefaultDraw := True;
  end; }
end;

procedure Tat_dlgLoadNamespacePackages.gsTreeViewClick(Sender: TObject);
var
  Node: TTreeNode;
  q: TIBSQL;
  Ver: String;
begin
  mInfo.Clear;
  Node := gsTreeView.Selected;
  if Node <> nil then
  begin
    mInfo.Lines.Add(TgsyamlNode(Node.Data).Name);
    mInfo.Lines.Add('Версия: ' + TgsyamlNode(Node.Data).Version);
    //mInfo.Lines.Add('Изменен: ' + q.FieldByName('filetimestamp').AsString);
    mInfo.Lines.Add('RUID: ' + TgsyamlNode(Node.Data).settingruid);
    mInfo.Lines.Add('Путь: ' + ExtractFilePath(TgsyamlNode(Node.Data).Filename));
    mInfo.Lines.Add('Файл: ' + ExtractFileName(TgsyamlNode(Node.Data).Filename));
  end;
 { mInfo.Clear;
  Node := gsTreeView.Selected;
  if Node <> nil then
  begin
    q := TIBSQL.Create(nil);
    try
      q.Transaction := gdcBaseManager.ReadTransaction;
      q.SQL.Text := 'SELECT * FROM at_namespace_gtt WHERE id = :id';
      q.ParamByName('id').AsInteger := Integer(Node.Data);
      q.ExecQuery;

      if not q.EOF then
      begin
        case q.FieldByName('operation').AsInteger of
          nvNotInstalled: Ver := ' - пакет не установлен';
          nvNewer: Ver := ' - новая версия';
          nvEqual: Ver := ' - версии совпадают';
          nvOlder: Ver := ' - старая версия';
          nvIndefinite: Ver := ' - INDEFINITE';
        else
          Ver := '';
        end;
        mInfo.Lines.Add(q.FieldByName('Name').AsString);
        mInfo.Lines.Add('Версия: ' + q.FieldByName('version').AsString + Ver);
        mInfo.Lines.Add('Изменен: ' + q.FieldByName('filetimestamp').AsString);
        mInfo.Lines.Add('RUID: ' + q.FieldByName('settingruid').AsString);
        mInfo.Lines.Add('Путь: ' + ExtractFilePath(q.FieldByName('filename').AsString));
        mInfo.Lines.Add('Файл: ' + ExtractFileName(q.FieldByName('filename').AsString));
      end;
    finally
      q.Free;
    end;
  end;}
end;

initialization
  RegisterClass(Tat_dlgLoadNamespacePackages);

finalization
  UnRegisterClass(Tat_dlgLoadNamespacePackages); 
end.
