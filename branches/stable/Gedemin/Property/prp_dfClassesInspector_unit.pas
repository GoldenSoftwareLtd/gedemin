{++

  Copyright (c) 2001 by Golden Software of Belarus

  Module

    prp_frmClassesInspector_unit.pas

  Abstract

    Gedemin project. Inspector for Delphi, user form and VB classes.

  Author

    Dubrovnik Alexander

  Revisions history

    1.00    03.01.03    DAlex        Initial version.
--}

unit prp_dfClassesInspector_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, gdcOLEClassList, TB2Dock, TB2Toolbar, StdCtrls, gd_KeyAssoc,
  TB2Item, ActnList, Menus, ToolWin, ExtCtrls, ImgList, prp_DOCKFORM_unit;

const
  NoShowProp =
    'QueryInterface'#13#10 +
    'AddRef'#13#10 +
    'Release'#13#10 +
    'GetTypeInfoCount'#13#10 +
    'GetTypeInfo'#13#10 +
    'GetIDsOfNames'#13#10 +
    'Invoke'#13#10 +
    'Self';

  cnComponent = 'Компоненты';
  cnHierarchy = 'Иерархия';
  cnMethods   = 'Методы';
  cnProperty  = 'Свойства';

type
  TciInsertCurrentText =  procedure (const Text: String) of object;

type
  TfrmClassesInspector = class;
  TCurrentModule = record
    Name: String;
    ClassRef: TClass;
  end;

  IprpClassesInspector = interface
    procedure AddDelphiClassInList(const ClassRef: TClass; const ClassInterface: IUnknown;
      const ClassGUID: TGUID);

    procedure AddItemsForDelphiClass(Node: TTreeNode; const ClassInterface: IUnknown;
      const ClassGUID: TGUID);
    procedure AddItemsForVBClass(Node: TTreeNode; const ClassInterface: IDispatch);
    procedure CreateHierarchyNode(Node: TTreeNode; const ClassName: String;
      const BeginWithParent: Boolean);
    procedure CreateGl_VBClasses;
    procedure ClearGl_VBClasses;
    procedure CreateLoc_VBClasses;
    procedure FillGL_VBClassesTree;
    procedure FillVBClass(const VBClassNode: TTreeNode);


    procedure SetFrmClassesInspector(const Frm: TfrmClassesInspector);
  end;

  //Этот класс необходим для поддержания Drag&Drop
  TciTreeView = class(TTreeView)
  private
    FMemoryStream: TMemoryStream;
    //Индекс нода при сохранении в поток
    FNodeIndex: Integer;
    //Индексы основных нодов
    FSelectedIndex: Integer;

    FfrmClassesNode: TTreeNode;
    FDelphiClassesNode: TTreeNode;
    FgdcClassesNode: TTreeNode;
    FGl_VBClassesNode: TTreeNode;
    FLoc_VBClassesNode: TTreeNode;
    FUserFromNode: TTreeNode;

    FfrmClassesNodeIndex: Integer;
    FDelphiClassesNodeIndex: Integer;
    FgdcClassesNodeIndex: Integer;
    FGl_VBClassesNodeIndex: Integer;
    FLoc_VBClassesNodeIndex: Integer;
    FUserFromNodeIndex: Integer;

    procedure SetDelphiClassesNode(const Value: TTreeNode);
    procedure SetfrmClassesNode(const Value: TTreeNode);
    procedure SetgdcClassesNode(const Value: TTreeNode);
    procedure SetGl_VBClassesNode(const Value: TTreeNode);
    procedure SetLoc_VBClassesNode(const Value: TTreeNode);
    procedure SetUserFromNode(const Value: TTreeNode);
  protected
    procedure CreateWnd; override;
    procedure DestroyWnd; override;
    procedure ReadHasChildren(Stream: TStream);
    procedure ReadNodeHasChildren(N: TTreeNode; Stream: TStream);
    procedure SaveHasChildren(Stream: TStream);
    procedure SaveNodeHasChildren(N: TTreeNode; Stream: TStream);
    procedure ReadRootNodes;
    procedure InitRootIndexes;
    procedure UpdateRootIndexes(N: TTreeNode; Index: Integer);

  public
    destructor Destroy; override;

    property DelphiClassesNode: TTreeNode read FDelphiClassesNode write SetDelphiClassesNode;
    property frmClassesNode: TTreeNode read FfrmClassesNode write SetfrmClassesNode;
    property gdcClassesNode: TTreeNode read FgdcClassesNode write SetgdcClassesNode;
    property Gl_VBClassesNode: TTreeNode read FGl_VBClassesNode write SetGl_VBClassesNode;
    property Loc_VBClassesNode: TTreeNode read FLoc_VBClassesNode write SetLoc_VBClassesNode;
    property UserFromNode: TTreeNode read FUserFromNode write SetUserFromNode;
  end;

  TfrmClassesInspector = class(TDockableForm)
    sbCurrentNode: TStatusBar;
    actInsertCurrentItem: TAction;
    actCollapse: TAction;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    actExpand: TAction;
    N1: TMenuItem;
    pcMain: TPageControl;
    tsClasses: TTabSheet;
    tsSearch: TTabSheet;
    TBDock1: TTBDock;
    TBToolbar2: TTBToolbar;
    TBControlItem2: TTBControlItem;
    cbClasses: TComboBox;
    mmDescription: TMemo;
    Splitter1: TSplitter;
    pnlSearch: TPanel;
    edtSearch: TEdit;
    Label1: TLabel;
    Button1: TButton;
    CheckBox1: TCheckBox;
    Label2: TLabel;
    Label3: TLabel;
    lbClasses: TListBox;
    Button2: TButton;
    Label4: TLabel;
    actSearch: TAction;
    lbWords: TListBox;
    alMain1: TActionList;
    procedure actInsertCurrentItemExecute(Sender: TObject);
    procedure TBItem1Click(Sender: TObject);
    procedure tvClassesInspChange(Sender: TObject; Node: TTreeNode);
    procedure tvClassesInspExpanding(Sender: TObject; Node: TTreeNode;
      var AllowExpansion: Boolean);
    procedure cbClassesChange(Sender: TObject);
    procedure tvClassesInspDblClick(Sender: TObject);
    procedure tvClassesInspCompare(Sender: TObject; Node1,
      Node2: TTreeNode; Data: Integer; var Compare: Integer);
    procedure actCollapseExecute(Sender: TObject);
    procedure tvClassesInspChanging(Sender: TObject; Node: TTreeNode;
      var AllowChange: Boolean);
    procedure tvClassesInspAdvancedCustomDrawItem(Sender: TCustomTreeView;
      Node: TTreeNode; State: TCustomDrawState; Stage: TCustomDrawStage;
      var PaintImages, DefaultDraw: Boolean);
    procedure actExpandExecute(Sender: TObject);
    procedure tsSearchShow(Sender: TObject);
    procedure actSearchExecute(Sender: TObject);
    procedure lbWordsDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure lbWordsDblClick(Sender: TObject);
  private
    FNoShowList: TStringList;
    FSearchActivate: Boolean;

    FJumpList: TStrings;
    FJumpIndex: Integer;

    FOnInsertCurrentText: TciInsertCurrentText;
    FHLNodeList: TList;
    FCurrentModule: TCurrentModule;
    FSearchStr: String;
    FtvClassesInsp: TciTreeView;


    procedure ClearSearchResurs;
    procedure MarkChild(const Node: TTreeNode);



    procedure AddPropMethod(const Node: TTreeNode);
    procedure AddStandartComponent(var CompNode: TTreeNode; const Node: TTreeNode;
      const FrmClassName: String);
    procedure AddComponentName(var CompNode: TTreeNode; const Node: TTreeNode;
      CompList: TStrings);

    function  GetCorrectClass(const ClassName: String): TClass;

    procedure FillClassesNode(const Node: TTreeNode);
    procedure FillFormNode(const Node: TTreeNode);
    procedure GotoOnClass(const AClass: TClass);

    procedure InsertCurrentText(const Text: String);

    procedure CreateGl_VBClasses;

    procedure CreateFullTree;

    procedure FillClassesTree;
    procedure FillGL_VBClassesTree;
    procedure FillLoc_VBClassesTree;
    procedure FillUserFormClassesTree;

    procedure AddItemsForDelphiClass(Node: TTreeNode; const ClassInterface: IUnknown;
      const ClassGUID: TGUID);
    procedure SetOnInsertCurrentText(const Value: TciInsertCurrentText);
    procedure SetCurrentModule(const Value: TCurrentModule);

    property CurrentModule: TCurrentModule read FCurrentModule write SetCurrentModule;
    procedure SettvClassesInsp(const Value: TciTreeView);
    procedure SetDelphiClassesNode(const Value: TTreeNode);
    procedure SetfrmClassesNode(const Value: TTreeNode);
    procedure SetgdcClassesNode(const Value: TTreeNode);
    procedure SetGl_VBClassesNode(const Value: TTreeNode);
    procedure SetLoc_VBClassesNode(const Value: TTreeNode);
    function GetDelphiClassesNode: TTreeNode;
    function GetfrmClassesNode: TTreeNode;
    function GetgdcClassesNode: TTreeNode;
    function GetGl_VBClassesNode: TTreeNode;
    function GetLoc_VBClassesNode: TTreeNode;
    function GetUserFromNode: TTreeNode;
    procedure SetUserFromNode(const Value: TTreeNode);
  public
    FDispArray: TgdKeyIntAssoc;
    FLibArray: TgdKeyIntAssoc;

    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;


    procedure SetModuleClass(const ModuleName: string;
      const ModuleClass: TClass);

    property tvClassesInsp: TciTreeView read FtvClassesInsp write SettvClassesInsp;

    property DelphiClassesNode: TTreeNode read GetDelphiClassesNode write SetDelphiClassesNode;
    property frmClassesNode: TTreeNode read GetfrmClassesNode write SetfrmClassesNode;
    property gdcClassesNode: TTreeNode read GetgdcClassesNode write SetgdcClassesNode;
    property Gl_VBClassesNode: TTreeNode read GetGl_VBClassesNode write SetGl_VBClassesNode;
    property Loc_VBClassesNode: TTreeNode read GetLoc_VBClassesNode write SetLoc_VBClassesNode;
    property UserFromNode: TTreeNode read GetUserFromNode write SetUserFromNode;

    property NoShowList: TStringList read FNoShowList;

    property OnInsertCurrentText: TciInsertCurrentText read FOnInsertCurrentText
      write SetOnInsertCurrentText;
  end;

var
  frmClassesInspector: TfrmClassesInspector;
  prpClassesInspector: IprpClassesInspector;

implementation

uses
  IBSQL, IBDatabase, gd_ClassList, gdcBaseInterface, gd_directories_const,
  Storages, gsStorage, gdc_createable_form, dmImages_unit;

type
  TCrackCustomTreeView = class(TCustomTreeView);


{$R *.DFM}

{ Tprp_frmClassesInspector }

procedure TfrmClassesInspector.AddItemsForDelphiClass(Node: TTreeNode;
  const ClassInterface: IUnknown; const ClassGUID: TGUID);
begin
  if Assigned(prpClassesInspector) then
    prpClassesInspector.AddItemsForDelphiClass(Node, ClassInterface, ClassGUID);
end;

constructor TfrmClassesInspector.Create(AOwner: TComponent);
begin
  Assert(frmClassesInspector = nil, 'Форма может быть только одна.');

  inherited;
  FDispArray := TgdKeyIntAssoc.Create;
  FLibArray := TgdKeyIntAssoc.Create;
  tvClassesInsp := TciTreeView.Create(Self);
  with tvClassesInsp do
  begin
    Parent := tsClasses;
    Align := alClient;
    OnAdvancedCustomDrawItem := tvClassesInspAdvancedCustomDrawItem;
    OnChange := tvClassesInspChange;
    OnChanging := tvClassesInspChanging;
    OnCompare := tvClassesInspCompare;
    OnDblClick := tvClassesInspDblClick;
    OnExpanding := tvClassesInspExpanding;
  end;


  frmClassesInspector := Self;

  FHLNodeList := TList.Create;

  FNoShowList := TStringList.Create;
  FNoShowList.Sorted := True;
  FNoShowList.Text := NoShowProp;

//  tvClassesInsp.SortType := stText;
//  tvClassesInsp.CustomSort(@CustomSortProc, 0);

  if Assigned(prpClassesInspector) then
    prpClassesInspector.SetFrmClassesInspector(Self);

  CreateFullTree;

  FJumpList := TStringList.Create;
  FJumpIndex := -1;

  FSearchActivate := False;
end;

procedure TfrmClassesInspector.CreateGl_VBClasses;
begin
  prpClassesInspector.CreateGl_VBClasses;
end;

destructor TfrmClassesInspector.Destroy;
begin
  FJumpList.Free;
  FNoShowList.Free;
  FHLNodeList.Free;

  FDispArray.Free;
  FLibArray.Free;

  inherited;

  frmClassesInspector := nil;
end;

procedure TfrmClassesInspector.FillClassesTree;
var
  i: Integer;
  TreeNode, TmpNode: TTreeNode;
  COMClassItem: TgdcCOMClassItem;
  ClassRef: TClass;
begin
 TreeNode := frmClassesNode;
  for i := 0 to frmClassList.Count - 1 do
  begin
    COMClassItem := OLEClassList.FindOLEClassItem(frmClassList[i]);
    if Assigned(COMClassItem) then
    begin
      ClassRef := COMClassItem.DelphiClass;
      TmpNode := tvClassesInsp.Items.AddChildObject(TreeNode,
        frmClassList[i].ClassName, ClassRef);

      if Assigned(prpClassesInspector) then
        prpClassesInspector.AddDelphiClassInList(ClassRef,
          COMClassItem.TypeLib, COMClassItem.DispIntf);

      TmpNode.HasChildren := True;
      cbClasses.Items.AddObject(TmpNode.Text, TmpNode);
    end;
  end;
  TreeNode.AlphaSort;

  TreeNode := gdcClassesNode;
  for i := 0 to gdcClassList.Count - 1 do
  begin
    COMClassItem := OLEClassList.FindOLEClassItem(gdcClassList[i]);
    if Assigned(COMClassItem) then
    begin
      ClassRef := COMClassItem.DelphiClass;
      TmpNode := tvClassesInsp.Items.AddChildObject(TreeNode,
        gdcClassList[i].ClassName, ClassRef);

      if Assigned(prpClassesInspector) then
        prpClassesInspector.AddDelphiClassInList(ClassRef,
          COMClassItem.TypeLib, COMClassItem.DispIntf);

      TmpNode.HasChildren := True;
      cbClasses.Items.AddObject(TmpNode.Text, TmpNode);
    end;
  end;
  TreeNode.AlphaSort;

  TreeNode := DelphiClassesNode;
  for i := 0 to OLEClassList.Count - 1 do
  begin
    COMClassItem := TgdcCOMClassItem(OLEClassList.ValuesByIndex[i]);
    if cbClasses.Items.IndexOf(
      COMClassItem.DelphiClass.ClassName) > -1 then
      Continue;

    ClassRef := TClass(OLEClassList.Keys[i]);
    TmpNode := tvClassesInsp.Items.AddChildObject(TreeNode,
      TClass(OLEClassList.Keys[i]).ClassName, ClassRef);

    if Assigned(prpClassesInspector) then
      prpClassesInspector.AddDelphiClassInList(ClassRef,
        COMClassItem.TypeLib, COMClassItem.DispIntf);

    TmpNode.HasChildren := True;
    cbClasses.Items.AddObject(TmpNode.Text, TmpNode);
  end;
  TreeNode.AlphaSort;
end;

procedure TfrmClassesInspector.FillGL_VBClassesTree;
begin
  prpClassesInspector.FillGL_VBClassesTree;
end;

procedure TfrmClassesInspector.actInsertCurrentItemExecute(
  Sender: TObject);
begin
  InsertCurrentText(tvClassesInsp.Selected.Text);
end;

procedure TfrmClassesInspector.InsertCurrentText(const Text: String);
begin
  if Assigned(FOnInsertCurrentText) then
    FOnInsertCurrentText(Text);
end;

procedure TfrmClassesInspector.SetOnInsertCurrentText(
  const Value: TciInsertCurrentText);
begin
  FOnInsertCurrentText := Value;
end;

procedure TfrmClassesInspector.TBItem1Click(Sender: TObject);
begin
  tvClassesInsp.Items.Clear;
  CreateFullTree;
end;

procedure TfrmClassesInspector.CreateFullTree;
begin
  cbClasses.Items.Clear;

  DelphiClassesNode := tvClassesInsp.Items.Add(nil, 'Классы стандартные');
  DelphiClassesNode.ImageIndex := 8;
  DelphiClassesNode.SelectedIndex := 8;
  frmClassesNode := tvClassesInsp.Items.Add(nil, 'Классы стандартных форм');
  frmClassesNode.ImageIndex := 8;
  frmClassesNode.SelectedIndex := 8;
  gdcClassesNode := tvClassesInsp.Items.Add(nil, 'Классы бизнес объектов');
  gdcClassesNode.ImageIndex := 8;
  gdcClassesNode.SelectedIndex := 8;
  Gl_VBClassesNode := tvClassesInsp.Items.Add(nil, 'Классы VB - глобальные');
  Gl_VBClassesNode.ImageIndex := 8;
  Gl_VBClassesNode.SelectedIndex := 8;
  Loc_VBClassesNode := tvClassesInsp.Items.Add(nil, 'Классы VB - локальные');
  Loc_VBClassesNode.HasChildren := True;
  Loc_VBClassesNode.ImageIndex := 8;
  Loc_VBClassesNode.SelectedIndex := 8;
  UserFromNode := tvClassesInsp.Items.Add(nil, 'Классы пользовательских форм');
  UserFromNode.ImageIndex := 8;
  UserFromNode.SelectedIndex := 8;
  tvClassesInsp.AlphaSort;

  FillClassesTree;

  CreateGl_VBClasses;
  FillGL_VBClassesTree;
  FillUserFormClassesTree;
  FillLoc_VBClassesTree;

  tvClassesInsp.AlphaSort;
end;

procedure TfrmClassesInspector.FillUserFormClassesTree;
var
  gsStorageFolder: TgsStorageFolder;
  i: Integer;
  F: TMemoryStream;
  F1: TStringStream;
  S, gdcFrmClassName: String;
  CompList: TStrings;
  CompNode, CurrentUserFrmNode: TTreeNode;

begin
  if not Assigned(GlobalStorage) then
    Exit;

  gsStorageFolder := GlobalStorage.OpenFolder(st_ds_NewFormPath);
  try
    CompList := TStringList.Create;
    F := TMemoryStream.Create;
    try
        for i := 0 to gsStorageFolder.FoldersCount - 1 do
        begin
          F1 := TStringStream.Create('');
          try
            CurrentUserFrmNode :=
              tvClassesInsp.Items.AddChild(UserFromNode, gsStorageFolder.Folders[i].Name);

            gdcFrmClassName := gsStorageFolder.Folders[i].ReadString(st_ds_FormClass);
            prpClassesInspector.CreateHierarchyNode(CurrentUserFrmNode,
              gdcFrmClassName, False);

            gsStorageFolder.Folders[i].ReadStream(st_ds_UserFormDFM, F);
            F.Seek(0, soFromBeginning);
            try
              SetLength(S, 3);
              F.Read(S[1], 3);
              if S = 'TPF' then
              begin
                F.Position := 0;
                ObjectBinaryToText(F, F1);
              end else
                F1.CopyFrom(F, 0);

              CompList.Clear;
              S :=  F1.DataString;
              CompList.Text := S;
              CompNode := nil;
              AddComponentName(CompNode, CurrentUserFrmNode, CompList);
              AddStandartComponent(CompNode, CurrentUserFrmNode, gdcFrmClassName);
            except
              ShowMessage(Format('Ошибка считывания пользовательской формы: "%s"', [gsStorageFolder.Folders[i].Name]))
            end;
            F.Clear;
          finally
            F1.Free;
          end;
        end;
    finally
      CompList.Free;
      F.Free;
    end;
  finally
    GlobalStorage.CloseFolder(gsStorageFolder);
  end;
  UserFromNode.AlphaSort;
end;

procedure TfrmClassesInspector.tvClassesInspChange(Sender: TObject;
  Node: TTreeNode);
begin
  if not (csDocking in ControlState) then
    sbCurrentNode.SimpleText := Node.Text;
end;

procedure TfrmClassesInspector.tvClassesInspExpanding(Sender: TObject;
  Node: TTreeNode; var AllowExpansion: Boolean);
begin
  if Node.getFirstChild = nil then
  begin
    if (Node.Parent = DelphiClassesNode) or (Node.Parent = gdcClassesNode) then
    begin
      FillClassesNode(Node);
    end else
      if Node.Parent = frmClassesNode then
      begin
        FillFormNode(Node);
      end else
        if Node.Parent = Loc_VBClassesNode then
        begin
          prpClassesInspector.FillVBClass(Node);
        end;
    if FHLNodeList.IndexOf(Node) > -1 then
    begin
      MarkChild(Node);
      tvClassesInsp.Refresh;
    end;
    Node.AlphaSort;
  end;
end;

procedure TfrmClassesInspector.AddPropMethod(const Node: TTreeNode);
var
  COMClassItem: TgdcCOMClassItem;
begin
  COMClassItem := TgdcCOMClassItem(OLEClassList.ValuesByKey[Integer(Node.Data)]);
  if COMClassItem <> nil then
    AddItemsForDelphiClass(Node, COMClassItem.TypeLib, COMClassItem.DispIntf);

  Node.AlphaSort;
end;

procedure TfrmClassesInspector.FillClassesNode(const Node: TTreeNode);
begin
  AddPropMethod(Node);
end;

procedure TfrmClassesInspector.FillFormNode(const Node: TTreeNode);
var
  CompNode: TTreeNode;
begin
  AddPropMethod(Node);
  CompNode := nil;
  AddStandartComponent(CompNode, Node, Node.Text);
end;

procedure TfrmClassesInspector.cbClassesChange(Sender: TObject);
var
  i: Integer;
begin
  i := cbClasses.Items.IndexOf(cbClasses.Text);
  if i > -1 then
  begin
    TTreeNode(cbClasses.Items.Objects[i]).Selected := True;
    TTreeNode(cbClasses.Items.Objects[i]).Focused := True;
//    tvClassesInsp.SetFocus;
  end;
end;

procedure TfrmClassesInspector.tvClassesInspDblClick(Sender: TObject);
var
  TmpClass: TClass;
begin
  if not Assigned(tvClassesInsp.Selected.Parent) then
    Exit;

  if (tvClassesInsp.Selected.Parent.Text = cnComponent) then
  begin
    // находим индекс класса компонента в списке
    with tvClassesInsp.Selected do
      TmpClass := GetCorrectClass(Trim(Copy(Text, Pos(':', Text) + 1, Length(Text))));
    GotoOnClass(TmpClass);
{    if Assigned(TmpClass) then
    begin
        I := cbClasses.Items.IndexOf(TmpClass.ClassName);
      if I > -1 then
      begin
        TTreeNode(cbClasses.Items.Objects[I]).Selected := True;
      end;
    end;}
  end else
    if  (tvClassesInsp.Selected.Parent.Text = cnHierarchy) then
    begin
      // находим индекс класса компонента в списке
      with tvClassesInsp.Selected do
        TmpClass := OLEClassList.GetClass(Trim(Copy(Text, Pos('.', Text) + 1, Length(Text))));
      GotoOnClass(TmpClass);
    end else
      if  (tvClassesInsp.Selected.Parent.Text = cnMethods) then
      begin
        // находим индекс класса компонента в списке
        with tvClassesInsp.Selected do
          TmpClass := TClass(Data);
        GotoOnClass(TmpClass);
      end

end;

procedure TfrmClassesInspector.GotoOnClass(const AClass: TClass);
var
  I: Integer;
  TmpClass: TClass;
begin
  if Assigned(AClass) then
  begin
    I := -1;
    TmpClass := AClass;
    while (I > -1) or Assigned(TmpClass) do
    begin
      I := cbClasses.Items.IndexOf(TmpClass.ClassName);
      if I > -1 then
      begin
//        TTreeNode(cbClasses.Items.Objects[I]).Selected := True;
        Break;
      end;
      TmpClass := TmpClass.ClassParent;
    end;
  end;
end;

procedure TfrmClassesInspector.tvClassesInspCompare(Sender: TObject; Node1,
  Node2: TTreeNode; Data: Integer; var Compare: Integer);
begin
  if (Node1.Parent <> nil) and (Node1.Parent.Text <> cnHierarchy) then
    Compare := AnsiStrIComp(PChar(Node1.Text), PChar(Node2.Text));
end;

procedure TfrmClassesInspector.AddStandartComponent(
  var CompNode: TTreeNode; const Node: TTreeNode; const FrmClassName: String);
var
  HRsrc, HInst: THandle;
  gdcFullClassName: TgdcFullClassName;
  TmpClass: TClass;
  ResStream: TResourceStream;
  CompList: TStrings;
  StrStream: TStringStream;
begin
  gdcFullClassName.SubType := '';
  gdcFullClassName.gdClassName := FrmClassName;
  TmpClass := frmClassList.GetFrmClass(gdcFullClassName);
  if not Assigned(TmpClass) then
    TmpClass := GetClass(FrmClassName);
  if not Assigned(TmpClass) then
    Exit;

  HInst := FindResourceHInstance(FindClassHInstance(TmpClass));
  if HInst = 0 then HInst := HInstance;
  HRsrc := FindResource(HInst, PChar(FrmClassName), RT_RCDATA);
  if HRsrc = 0 then Exit;

  ResStream := TResourceStream.Create(HInst, PChar(FrmClassName), RT_RCDATA);
  try
    CompList := TStringList.Create;
    StrStream := TStringStream.Create('');
    try
//      ResStream.ReadComponent(Instance);
      ResStream.Seek(0, soFromBeginning);
      ObjectBinaryToText(ResStream, StrStream);
      CompList.Text := StrStream.DataString;
      AddComponentName(CompNode, Node, CompList);
    finally
      StrStream.Free;
      CompList.Free;
    end;
  finally
    ResStream.Free;
  end;
  TmpClass := TmpClass.ClassParent;
  if TmpClass.InheritsFrom(TgdcCreateableForm) then
    AddStandartComponent(CompNode, Node, TmpClass.ClassName);
end;

procedure TfrmClassesInspector.AddComponentName(var CompNode: TTreeNode;
  const Node: TTreeNode; CompList: TStrings);
var
  AI{, AP}: Integer;
  S: String;
begin
  for AI := 1 to CompList.Count - 1 do
  begin
    S := Trim(CompList[AI]);
    if Pos('object', S) = 1 then
    begin
      if not Assigned(CompNode) then
        CompNode :=
          tvClassesInsp.Items.AddChild(Node, cnComponent);
      tvClassesInsp.Items.AddChild(CompNode, Trim(Copy(S, 7, Length(S))));
    end;
  end;
  if CompNode <> nil then
    CompNode.AlphaSort;
end;

function TfrmClassesInspector.GetCorrectClass(
  const ClassName: String): TClass;
var
  fc: TgdcFullClassName;
begin
  fc.SubType := '';
  fc.gdClassName := ClassName;
  Result := frmClassList.GetFrmClass(fc);
  if not Assigned(Result) then
  begin
    Result := gdcClassList.GetGDCClass(fc);
    if not Assigned(Result) then
    begin
      Result := OLEClassList.GetClass(ClassName);
      if not Assigned(Result) then
      begin
        Result := GetClass(ClassName);
        while Result <> nil do
        begin
          Result := OLEClassList.FindOLEClassItem(Result).ClassType;
          if Result = nil then
            Result := Result.ClassParent;
        end;
      end;
    end;
  end;
end;

procedure TfrmClassesInspector.actCollapseExecute(Sender: TObject);
begin
  tvClassesInsp.FullCollapse;
end;

procedure TfrmClassesInspector.tvClassesInspChanging(Sender: TObject;
  Node: TTreeNode; var AllowChange: Boolean);
begin
  if not (csDocking in ControlState) then
  begin
    FJumpList.AddObject(Node.Text, Node);
    while FJumpList.Count > 19 do
      FJumpList.Delete(0);
  end;    
end;

procedure TfrmClassesInspector.tvClassesInspAdvancedCustomDrawItem(
  Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState;
  Stage: TCustomDrawStage; var PaintImages, DefaultDraw: Boolean);
{var
  LNode: TTreeNode;}
begin
  if FHLNodeList.IndexOf(Node) > -1 then
  begin
    Sender.Canvas.Font.Style := [fsBold];
    Sender.Canvas.Font.Color := clRed;
  end;
{  if (Node.Text = CurrentModule) or (Node.Text = CurrentFormClass.ClassName) then
  begin
    Sender.Canvas.Font.Style := [fsBold];
    LNode := Node.Parent;
    while Assigned(LNode) do
    begin
      TCrackCustomTreeView(tvClassesInsp).CustomDrawItem(
        LNode, State, Stage, PaintImages);
      LNode := LNode.Parent;
    end;
  end;
 }
end;

procedure TfrmClassesInspector.SetCurrentModule(
  const Value: TCurrentModule);
{var
  TmpNode: TTreeNode;}

  procedure FindNodeAndAddAll(const BeginFindNode: TTreeNode;
    const FindName: string);
  var
    FANode: TTreeNode;
  begin
    FANode := BeginFindNode.getFirstChild;
    while Assigned(FANode) do
    begin
      if FANode.Text = FindName then
      begin
        FHLNodeList.Add(Pointer(FANode));
        FANode := FANode.Parent;
        MarkChild(FANode);
        while Assigned(FANode) do
        begin
          FHLNodeList.Add(Pointer(FANode));
          FANode := FANode.Parent;
        end;
        Break;
      end else
        FANode := frmClassesNode.GetNextChild(FANode);
    end;
  end;

begin
  if not ((FCurrentModule.Name = Value.Name) and
    (FCurrentModule.ClassRef = Value.ClassRef)) then
  begin
    FCurrentModule := Value;
    FHLNodeList.Clear;
//    TmpNode := frmClassesNode.getFirstChild;
    if FCurrentModule.ClassRef.InheritsFrom(TgdcCreateableForm) then
      FindNodeAndAddAll(frmClassesNode, FCurrentModule.ClassRef.ClassName)
    else
      FindNodeAndAddAll(DelphiClassesNode, FCurrentModule.ClassRef.ClassName);

    if AnsiUpperCase(FCurrentModule.Name) <> 'APPLICATION' then
      FindNodeAndAddAll(Loc_VBClassesNode, Copy((FCurrentModule.ClassRef.ClassName), 6,
        Length(FCurrentModule.ClassRef.ClassName)))
    else
      begin
        FHLNodeList.Add(Pointer(Gl_VBClassesNode));
        MarkChild(Gl_VBClassesNode);
      end;
  end;
end;

procedure TfrmClassesInspector.SetModuleClass(const ModuleName: string;
  const ModuleClass: TClass);
var
  tmpCurrentModule: TCurrentModule;
begin
  tmpCurrentModule.Name := ModuleName;
  tmpCurrentModule.ClassRef := ModuleClass;
  CurrentModule := tmpCurrentModule;
  tvClassesInsp.Refresh;
end;

procedure TfrmClassesInspector.FillLoc_VBClassesTree;
begin
  prpClassesInspector.CreateLoc_VBClasses;
end;

procedure TfrmClassesInspector.MarkChild(const Node: TTreeNode);
var
  ChildNode: TTreeNode;
begin
  ChildNode := Node.getFirstChild;
  while Assigned(ChildNode) do
  begin
    FHLNodeList.Add(ChildNode);
    MarkChild(ChildNode);
    ChildNode := Node.GetNextChild(ChildNode);
  end;
end;

procedure TfrmClassesInspector.actExpandExecute(Sender: TObject);
begin
  tvClassesInsp.FullExpand;
end;

procedure TfrmClassesInspector.tsSearchShow(Sender: TObject);
var
  I: Integer;

const
  ActStr = 'Активация поиска: ';
begin
  edtSearch.Text := '';
  FSearchStr := '';
  if FSearchActivate then
    Exit;

  for I := 0 to tvClassesInsp.Items.Count - 1 do
  begin
    if not tvClassesInsp.Items[I].Expanded then
    begin
      tvClassesInsp.Items[I].Expand(False);
      sbCurrentNode.SimpleText := ActStr + tvClassesInsp.Items[I].Text;
      tvClassesInsp.Items[I].Collapse(False);
    end;
  end;
  FSearchActivate := True;
  sbCurrentNode.SimpleText := '';
end;

procedure TfrmClassesInspector.actSearchExecute(Sender: TObject);
var
  I: Integer;

begin
  ClearSearchResurs;

  FSearchStr := AnsiUpperCase(edtSearch.Text);
  for I := 0 to tvClassesInsp.Items.Count - 1 do
  begin
    if (tvClassesInsp.Items[I].Parent <> nil)
      and (Pos(FSearchStr, AnsiUpperCase(tvClassesInsp.Items[I].Text)) > 0) then
    begin
      lbWords.Items.AddObject(tvClassesInsp.Items[I].Text, tvClassesInsp.Items[I]);
    end;
  end;
//  FSearchActivate := True;
  sbCurrentNode.SimpleText := '';
end;

procedure TfrmClassesInspector.ClearSearchResurs;
var
  I: Integer;
begin
  for I := 0 to lbWords.Items.Count - 1 do
  begin
    if lbWords.Items.Objects[I] <> nil then
      lbWords.Items.Objects[I].Free;
  end;
  lbWords.Items.Clear;
  lbClasses.Items.Clear;
end;

procedure TfrmClassesInspector.lbWordsDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  Str, SearchStr, VisStr: String;
  I, X, Y: Integer;
begin
  if not Control.InheritsFrom(TListBox) then
    Exit;

  SearchStr := AnsiUpperCase(edtSearch.text);
  with TListBox(Control) do
  begin
    Str := Items[Index];
    VisStr := AnsiUpperCase(Str);
    Canvas.FillRect(Rect);
    I := Pos(SearchStr, VisStr);
    X := Rect.Left;
    Y := Rect.Top;
    if I > 1 then
    begin
      VisStr := copy(Str, 1, I - 1);
      Canvas.TextOut(X, Y, VisStr);
      X := X + Canvas.TextWidth(VisStr);
    end;
    Canvas.Font.Style := [fsBold];
    VisStr := copy(Str, I, Length(SearchStr));
    Canvas.TextOut(X, Y, VisStr);
    X := X + Canvas.TextWidth(VisStr);
    Canvas.Font.Style := [];
    VisStr := copy(Str, I + Length(SearchStr), Length(Str) - Length(SearchStr) - I + 1);
    Canvas.TextOut(X, Y, VisStr);
    Rect.Right := X + Canvas.TextWidth(VisStr);
  end;

end;


procedure TfrmClassesInspector.lbWordsDblClick(Sender: TObject);
begin
  if not Sender.InheritsFrom(TListBox) then
    Exit;

  with TListBox(Sender) do
  begin
    if Items.Objects[ItemIndex] <> nil then
    begin
      TTreeNode(Items.Objects[ItemIndex]).Selected := True;
      pcMain.ActivePage := tsClasses;
      tvClassesInsp.SetFocus;
    end;
  end;
end;

{ TciTreeView }

procedure TciTreeView.CreateWnd;
var
  I: Integer;
begin
  inherited CreateWnd;
  if FMemoryStream <> nil then
  begin
    ReadHasChildren(FMemoryStream);
    FMemoryStream.Destroy;
    FMemoryStream := nil;
    //Обновляен указатели
{    for I := 0 to Items.Count - 1 do
    begin
      TCustomTreeItem(Items[I].Data).Node := Items[I];
      if TCustomTreeItem(Items[I].Data).EditorFrame <> nil then
        TBaseFrame(TCustomTreeItem(Items[I].Data).EditorFrame).Node := Items[I];
    end;}
    if FSelectedIndex <> - 1 then
      Items[FSelectedIndex].Selected := True;
  end;
end;

destructor TciTreeView.Destroy;
var
  F: TCustomForm;
begin
  if FMemoryStream <> nil then FMemoryStream.Free;
  //В борландовском коде ошибка. Если дерево имеет
  //фокус ввода то при дестрое возникает исключение
  //поэтому при необходимоти снимаем фокус 
  if Parent <> nil then
  begin
    F := GetParentForm(Self);
    if F <> nil then
      F.DefocusControl(Self, True);
  end;
  inherited;
end;

procedure TciTreeView.DestroyWnd;
begin
  InitRootIndexes;
  if Items.Count > 0 then
  begin
    FMemoryStream := TMemoryStream.Create;
    SaveHasChildren(FMemoryStream);
    FMemoryStream.Position := 0;
    Selected := nil
  end;
  inherited DestroyWnd;
end;

procedure TciTreeView.InitRootIndexes;
begin
  FfrmClassesNodeIndex := -1;
  FDelphiClassesNodeIndex := - 1;
  FgdcClassesNodeIndex := - 1;
  FGl_VBClassesNodeIndex := -1;
  FLoc_VBClassesNodeIndex := -1;
  FUserFromNodeIndex := -1;
  FSelectedIndex := - 1;
end;

procedure TciTreeView.ReadHasChildren(Stream: TStream);
var
  Node: TTreeNode;
begin
  Node := Items.GetFirstNode;
  while Node <> nil do
  begin
    ReadNodeHasChildren(Node, Stream);
    Node := Node.GetNextSibling;
  end;
  ReadRootNodes;
end;

procedure TciTreeView.ReadNodeHasChildren(N: TTreeNode; Stream: TStream);
var
  I: Integer;
  H: Boolean;
  lCount: Integer;
begin
  Stream.ReadBuffer(H, SizeOf(H));
  N.HasChildren := H;
  Stream.ReadBuffer(lCount, SizeOf(lCount));
  if lCount <> N.Count then
    raise Exception.Create('asdas');

  for I := 0 to lCount - 1 do
    ReadNodeHasChildren(N.Item[I], Stream);
end;

procedure TciTreeView.ReadRootNodes;
begin
  if FfrmClassesNodeIndex <> - 1 then
    frmClassesNode := Items[FfrmClassesNodeIndex];
  if FDelphiClassesNodeIndex <> - 1 then
    FDelphiClassesNode := Items[FDelphiClassesNodeIndex];
  if FgdcClassesNodeIndex <> - 1 then
    FgdcClassesNode := Items[FgdcClassesNodeIndex];
  if FGl_VBClassesNodeIndex <> - 1 then
    FGl_VBClassesNode := Items[FGl_VBClassesNodeIndex];
  if FLoc_VBClassesNodeIndex <> - 1 then
    FLoc_VBClassesNode := Items[FLoc_VBClassesNodeIndex];
  if FUserFromNodeIndex <> - 1 then
    FUserFromNode := Items[FUserFromNodeIndex];  
end;

procedure TciTreeView.SaveHasChildren(Stream: TStream);
var
  Node: TTreeNode;
begin
  FNodeIndex := 0;
  Node := Items.GetFirstNode;
  while Node <> nil do
  begin
    UpdateRootIndexes(Node, FNodeIndex);
    //Выбранный нод
    SaveNodeHasChildren(Node, Stream);
    Node := Node.GetNextSibling;
  end;
end;

procedure TciTreeView.SaveNodeHasChildren(N: TTreeNode; Stream: TStream);
var
  lCount: Integer;
  I: Integer;
  H: Boolean;
begin
  H := N.HasChildren;
  Stream.WriteBuffer(H, SizeOf(H));
  if N = Selected then
    FSelectedIndex := FNodeIndex;
  Inc(FNodeIndex);
  lCount := N.Count;
  Stream.WriteBuffer(lCount, SizeOf(lCount));
  for I := 0 to lCount - 1 do
    SaveNodeHasChildren(N.Item[I], Stream);
end;

procedure TciTreeView.SetDelphiClassesNode(const Value: TTreeNode);
begin
  FDelphiClassesNode := Value;
end;

procedure TciTreeView.SetfrmClassesNode(const Value: TTreeNode);
begin
  FfrmClassesNode := Value;
end;

procedure TciTreeView.SetgdcClassesNode(const Value: TTreeNode);
begin
  FgdcClassesNode := Value;
end;

procedure TciTreeView.SetGl_VBClassesNode(const Value: TTreeNode);
begin
  FGl_VBClassesNode := Value;
end;

procedure TciTreeView.SetLoc_VBClassesNode(const Value: TTreeNode);
begin
  FLoc_VBClassesNode := Value;
end;

procedure TciTreeView.SetUserFromNode(const Value: TTreeNode);
begin
  FUserFromNode := Value;
end;

procedure TciTreeView.UpdateRootIndexes(N: TTreeNode; Index: Integer);
begin
  if FfrmClassesNode = N then
    FfrmClassesNodeIndex := Index;
  if FDelphiClassesNode = N then
    FDelphiClassesNodeIndex := Index;
  if FgdcClassesNode = N then
    FgdcClassesNodeIndex := Index;
  if FGl_VBClassesNode = N then
    FGl_VBClassesNodeIndex := Index;
  if FLoc_VBClassesNode = N then
    FLoc_VBClassesNodeIndex := Index;
  if FUserFromNode = N then
    FUserFromNodeIndex := Index;  
end;

procedure TfrmClassesInspector.SettvClassesInsp(const Value: TciTreeView);
begin
  FtvClassesInsp := Value;
end;

procedure TfrmClassesInspector.SetDelphiClassesNode(
  const Value: TTreeNode);
begin
  if tvClassesInsp <> nil then
    tvClassesInsp.DelphiClassesNode := Value;
end;

procedure TfrmClassesInspector.SetfrmClassesNode(const Value: TTreeNode);
begin
  if tvClassesInsp <> nil then
    tvClassesInsp.frmClassesNode := Value;
end;

procedure TfrmClassesInspector.SetgdcClassesNode(const Value: TTreeNode);
begin
  if tvClassesInsp <> nil then
    tvClassesInsp.gdcClassesNode := Value;
end;

procedure TfrmClassesInspector.SetGl_VBClassesNode(const Value: TTreeNode);
begin
  if tvClassesInsp <> nil then
    tvClassesInsp.Gl_VBClassesNode := Value;
end;

procedure TfrmClassesInspector.SetLoc_VBClassesNode(
  const Value: TTreeNode);
begin
  if tvClassesInsp <> nil then
    tvClassesInsp.Loc_VBClassesNode := Value;
end;

function TfrmClassesInspector.GetDelphiClassesNode: TTreeNode;
begin
  Result := nil;
  if tvClassesInsp <> nil then
    Result := tvClassesInsp.DelphiClassesNode;
end;

function TfrmClassesInspector.GetfrmClassesNode: TTreeNode;
begin
  Result := nil;
  if tvClassesInsp <> nil then
    Result := tvClassesInsp.frmClassesNode;
end;

function TfrmClassesInspector.GetgdcClassesNode: TTreeNode;
begin
  Result := nil;
  if tvClassesInsp <> nil then
    Result := tvClassesInsp.gdcClassesNode;
end;

function TfrmClassesInspector.GetGl_VBClassesNode: TTreeNode;
begin
  Result := nil;
  if tvClassesInsp <> nil then
    Result := tvClassesInsp.Gl_VBClassesNode;
end;

function TfrmClassesInspector.GetLoc_VBClassesNode: TTreeNode;
begin
  Result := nil;
  if tvClassesInsp <> nil then
    Result := tvClassesInsp.Loc_VBClassesNode;
end;

function TfrmClassesInspector.GetUserFromNode: TTreeNode;
begin
  Result := nil;
  if tvClassesInsp <> nil then
    Result := tvClassesInsp.UserFromNode;
end;

procedure TfrmClassesInspector.SetUserFromNode(const Value: TTreeNode);
begin
  if tvClassesInsp <> nil then
    tvClassesInsp.UserFromNode := Value;
end;

end.
