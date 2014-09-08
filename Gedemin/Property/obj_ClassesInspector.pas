{++

  Copyright (c) 2001 by Golden Software of Belarus

  Module

    prp_frmClassesInspector_unit.pas

  Abstract

    Gedemin project. Object for classes inspector.

  Author

    Dubrovnik Alexander

  Revisions history

    1.00    03.01.03    DAlex        Initial version.
    1.10    20.01.03    DAlex        .
--}

unit obj_ClassesInspector;

interface

uses
  classes, prp_frmClassesInspector_unit, comctrls, ActiveX, MSScriptControl_TLB,
  contnrs, dmClientReport_unit;

const
  MaxFuncParams = 164;
  ciClassUndefined = 'Объект(класс неопределен)';

type
  PciBStrList = ^TciBStrList;
  TciBStrList = array[0..MaxFuncParams - 1] of TBStr;

type
  TVBModuleItem = class(TObject)
  private
    FScriptControl: TScriptControl;
    FVBClasses: array of TSingleGlObj;
    FModuleCode: Integer;
    FModuleName: String;

    procedure Clear;
    function GetCount: Integer;
    function GetVBClasses(Index: Integer): TSingleGlObj;
  public
    constructor Create;
    destructor  Destroy; override;

    function CreateVBClasses(
      const ModuleCode: Integer; const ModuleName: String): Boolean;
    property ModuleCode: Integer read FModuleCode;
    property ModuleName: String read FModuleName;
    property VBClasses[Index: Integer]: TSingleGlObj read GetVBClasses; default;
    property Count: Integer read GetCount;
  end;

  TVBModuleList = class(TObject)
  private
    FList: TObjectList;
    function GetCount: Integer;
    function GetModuleItem(Index: Integer): TVBModuleItem;

  public
    constructor Create;
    destructor  Destroy; override;

    procedure Clear;
    procedure CreateList;

    property  Count: Integer read GetCount;
    property  ModuleItem[Index: Integer]: TVBModuleItem read GetModuleItem; default;
  end;

  TprpClassesInspector = class(TComponent, IprpClassesInspector)
  private
    FNoShowList: TStringList;

    FVBModuleList: TVBModuleList;
    FGlScriptControl: TScriptControl;
    FGl_VBClasses: array of TSingleGlObj;

    function AddGlObjectNode(const Node: TTreeNode; PropName: String; const TypeInfo: ITypeInfo;
      out NodeItem: TInspectorItem; const prpClassesFrm: IprpClassesFrm): TTreeNode;
    function  GetResultType(const Node: TTreeNode; const TypeInfo: ITypeInfo;
      const ElemDesc: TElemDesc; out ResultStr: String; out AnClassRef: TClass;
      const prpClassesFrm: IprpClassesFrm): TTreeNode;
    function AddMethod(const Node: TTreeNode; const BStrList: PciBStrList;
      const FuncDesc: PFuncDesc; const TypeInfo: ITypeInfo; const FuncCount: Integer;
      const prpClassesFrm: IprpClassesFrm): TTreeNode;
    function AddProperty(const Node: TTreeNode; const NodeType: TciItemType;
      const BStrList: PciBStrList;
      const VarDesc: PVarDesc; const TypeInfo: ITypeInfo; const VarCount: Integer;
      const prpClassesFrm: IprpClassesFrm): TTreeNode;
    procedure AddForUndefined(const Node: TTreeNode; const TypeInfo: ITypeInfo;
      const prpClassesFrm: IprpClassesFrm);
    function  MarkName(const FullStr: String): String;

    procedure FillGlobal(const ObjectNode, MethodNode: TTreeNode;
      const TypeInfo: ITypeInfo; const CustomNoShowList: TStrings;
      const prpClassesFrm: IprpClassesFrm);
  protected
    procedure AddDelphiClassInList(const ClassRef: Pointer;
      const DataType: TRefDateType; const ClassGUID: TGUID;
      const prpClassesFrm: IprpClassesFrm);

    procedure AddItemsForDelphiClass(Node: TTreeNode; const ClassInterface: IUnknown;
      const ClassGUID: TGUID; const prpClassesFrm: IprpClassesFrm);
    procedure AddItemsForDelphiClass2(Node: TTreeNode; const TypeInfo: ITypeInfo;
      const prpClassesFrm: IprpClassesFrm);
    procedure AddItemsByDispath(Node: TTreeNode; const ClassInterface: IDispatch;
      const prpClassesFrm: IprpClassesFrm);
    // PDescr, MDescr - начало описания свойст и методов по умолчанию.
    // За добавляется PDescr, MDescr владелей Node.Text
    procedure AddItemsForVBClass(Node: TTreeNode; const ClassInterface: IDispatch;
      const PDescr, MDescr: String; const prpClassesFrm: IprpClassesFrm);

    procedure Clear;
    procedure CreateHierarchyNode(Node: TTreeNode; const ClassName: String;
      const BeginWithParent: Boolean; const prpClassesFrm: IprpClassesFrm);
    procedure CreateVBClasses(const prpClassesFrm: IprpClassesFrm);
    procedure CreateLoc_VBClasses(const prpClassesFrm: IprpClassesFrm);
    procedure ClearGl_VBClasses;
    procedure FillVBClass(const VBClassNode: TTreeNode; const prpClassesFrm: IprpClassesFrm);
    procedure FillStGlobalObjects(const ObjectNode, MethodNode: TTreeNode; const prpClassesFrm: IprpClassesFrm);
    procedure FillVBGlobalObjects(const ObjectNode, MethodNode: TTreeNode; const prpClassesFrm: IprpClassesFrm);
    procedure FillUsGlobalObjects(const ObjectNode, MethodNode: TTreeNode;
      const prpClassesFrm: IprpClassesFrm);

    procedure ShowHelpByGUIDString(const GUIDString: String);

    procedure SetClassDescription(Node: TTreeNode; const ClassInterface: IUnknown;
      const ClassGUID: TGUID);

    procedure SetFrmClassesInspector(const Frm: TfrmClassesInspector);

  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
  end;

var
  prpClassesInspectorObj: TprpClassesInspector;

implementation

uses
  Windows, IBDatabase, IBSQL, gd_Security, gd_security_operationconst,
  Sysutils, gd_ClassList, gdcBaseInterface, gdcOLEClassList, rp_report_const,
  Consts, obj_GedeminApplication, Comserv, Forms, prp_VBStandart_const, comobj,
  registry
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

const
  pdVBClass = 'Свойства VB-класса ';
  mdVBClass = 'Метод VB-класса ';
  pdVBObject = 'Свойства глобального VB-объекта ';
  mdVBObject = 'Метод глобального VB-объекта ';

type
  TCrackDmClientReport = class(TdmClientReport);
  TCrackTreeView = class(TTreeView);

{ TprpClassesInspector }


procedure TprpClassesInspector.AddDelphiClassInList(const ClassRef: Pointer;
  const DataType: TRefDateType; const ClassGUID: TGUID;
  const prpClassesFrm: IprpClassesFrm);
begin
  prpClassesFrm.GetLibArray.AddRef(ClassRef, DataType, ClassGUID);
end;

procedure TprpClassesInspector.AddItemsForDelphiClass(Node: TTreeNode;
  const ClassInterface: IUnknown; const ClassGUID: TGUID; const prpClassesFrm: IprpClassesFrm);
var
  TypeInfo: ITypeInfo;
begin
  if (ComServer.TypeLib.GetTypeInfoOfGuid(ClassGUID, TypeInfo) = S_OK) then
  try
    CreateHierarchyNode(Node, Node.Text, True, prpClassesFrm);
    AddItemsForDelphiClass2(Node, TypeInfo, prpClassesFrm);
  finally
  end;
end;

procedure TprpClassesInspector.AddItemsForVBClass(Node: TTreeNode;
  const ClassInterface: IDispatch; const PDescr, MDescr: String;
   const prpClassesFrm: IprpClassesFrm);
var
  I, J: Integer;
  TypeInfo: ITypeInfo;
  TypeAttr: PTypeAttr;
  BStrList: PciBStrList;
  FuncDesc: PFuncDesc;
  VarDesc: PVarDesc;
  cNames: Integer;
  Str: String;
  tmpNode: TTreeNode;
  MetNode, PropNode: TTreeNode;
  InspectorItem: TInspectorItem;

  function AddPropertyNode(const PropName: String): TTreeNode;
  begin
    if PropNode = nil then
    begin
      PropNode :=
        prpClassesFrm.GetClassesTree.Items.AddChild(Node, cnProperty);
      AddItemData(PropNode, ciPropertyFolder,
        PDescr + PropNode.Parent.Text + '.', prpClassesFrm);
    end;

    Result :=
      prpClassesFrm.GetClassesTree.Items.AddChild(PropNode, PropName);
  end;

begin

  if not Assigned(ClassInterface) then
    Exit;

  MetNode := nil;
  PropNode := nil;
  New(BStrList);
  try
    if (ClassInterface.GetTypeInfo(0, 0, TypeInfo) = S_OK) then
      if (TypeInfo.GetTypeAttr(TypeAttr) = S_Ok) then
      try
//        prpClassesFrm.GetClassesInspector.cbClasses.Items.AddObject(Node.Text + ' (' + Node.Parent.Text + ')', Node);

        for I := 0 to TypeAttr.cVars - 1 do
        begin
          if (TypeInfo.GetVarDesc(I, VarDesc) = S_OK) then
          try
            if (TypeInfo.GetNames(VarDesc.memid, PBStrList(BStrList), MaxFuncParams, cNames) =
              S_OK) then
            try
              Str := String(BStrList^[0]);
//              with FfrmClassesInspector do
              begin
                if FNoShowList.IndexOf(Str) = -1 then
                begin
                  tmpNode := AddPropertyNode(Str);
                  case VarDesc.elemdescVar.tdesc.vt of
                    DISPATCH_PROPERTYGET:
                      AddItemData(tmpNode, ciPropertyR,
                        PDescr + Node.Text + '.', prpClassesFrm);
                    DISPATCH_PROPERTYPUT:
                    begin
                      InspectorItem := AddItemData(tmpNode, ciPropertyW,
                        PDescr + Node.Text + '.', prpClassesFrm);
                      if InspectorItem.InheritsFrom(TWithResultItem) then
                      begin
                        TWithResultItem(InspectorItem).ResultTypeName := 'Variant';
                        TWithResultItem(InspectorItem).NodeText := tmpNode.Text;
                      end;
                    end;
                    DISPATCH_PROPERTYPUTREF:
                    begin
                      InspectorItem := AddItemData(tmpNode, ciPropertyRW,
                        PDescr + Node.Text + '.', prpClassesFrm);
                      if InspectorItem.InheritsFrom(TWithResultItem) then
                      begin
                        TWithResultItem(InspectorItem).ResultTypeName := 'Variant';
                        TWithResultItem(InspectorItem).NodeText := tmpNode.Text;
                      end;
                    end;
                    DISPATCH_PROPERTYPUTREF or DISPATCH_PROPERTYPUT:
                    begin
                      InspectorItem := AddItemData(tmpNode, ciPropertyRW,
                        PDescr + Node.Text + '.', prpClassesFrm);
                      if InspectorItem.InheritsFrom(TWithResultItem) then
                      begin
                        TWithResultItem(InspectorItem).ResultTypeName := 'Variant';
                        TWithResultItem(InspectorItem).NodeText := tmpNode.Text;
                      end;
                    end;
                  end;
                end;
              end;
            finally
              for J := cNames - 1 downto 1 do
              begin
                if BStrList^[J] <> nil then
                  SysFreeString(BStrList^[J]);
              end;
            end
          finally
            TypeInfo.ReleaseVarDesc(VarDesc);
          end;
        end;

        for I := 0 to TypeAttr.cFuncs - 1 do
        begin
          if (TypeInfo.GetFuncDesc(I, FuncDesc) = S_OK) then
          try
            if (TypeInfo.GetNames(FuncDesc.memid, PBStrList(BStrList), MaxFuncParams, cNames) =
              S_OK) then
            try
              if FuncDesc.invkind = DISPATCH_METHOD then
              begin
                Str := '';
                for J := cNames - 1 downto 1 do
                begin
                  if Str <> '' then
                    Str := String(BStrList^[J]) + '; ' + Str
                  else
                    Str := String(BStrList^[J]);
                end;

                Str := String(BStrList^[0]) + '(' + Str + ')';
              end else
                Str := String(BStrList^[0]);
              begin
                if FNoShowList.IndexOf(BStrList^[0]) = -1 then
                begin
                  case FuncDesc.invkind of
                    DISPATCH_METHOD:
                    begin
                      if MetNode = nil then
                      begin
//                        MetNode := tvClassesInsp.Items.AddChild(Node, cnMethods);
                        MetNode := TCrackTreeView(Node.TreeView).Items.AddChild(Node, cnMethods);
                        AddItemData(MetNode, ciMethodFolder,
                          MDescr + MetNode.Parent.Text + '.', prpClassesFrm);
                      end;
                      tmpNode := TCrackTreeView(Node.TreeView).Items.AddChild(MetNode, Str);

                      if FuncDesc.elemdescFunc.tdesc.vt = VT_VOID then
                        AddItemData(tmpNode, ciMethodGet, MDescr + Node.Text + '.', prpClassesFrm)
                      else
                        AddItemData(tmpNode, ciMethod, MDescr + Node.Text + '.', prpClassesFrm);
                    end;
                    DISPATCH_PROPERTYGET:
                    begin
                      tmpNode := AddPropertyNode(Str);
                      AddItemData(tmpNode, ciPropertyR,
                        PDescr + Node.Text + '.', prpClassesFrm);
                    end;
                    DISPATCH_PROPERTYPUT:
                    begin
                      tmpNode := AddPropertyNode(Str);
                      AddItemData(tmpNode, ciPropertyW,
                        PDescr + Node.Text + '.', prpClassesFrm);
                    end;
                    DISPATCH_PROPERTYPUTREF:
                    begin
                      tmpNode := AddPropertyNode(Str);
                      AddItemData(tmpNode, ciPropertyRW,
                        PDescr + Node.Text + '.', prpClassesFrm);
                    end;
                  end;
                end;
              end;
            finally
              for J := cNames - 1 downto 1 do
              begin
                if BStrList^[J] <> nil then
                  SysFreeString(BStrList^[J]);
              end;
            end
          finally
            TypeInfo.ReleaseFuncDesc(FuncDesc);
          end;
        end;
      finally
        TypeInfo.ReleaseTypeAttr(TypeAttr);
      end;
  finally
    Dispose(BStrList);
  end;
  Node.AlphaSort;
end;

procedure TprpClassesInspector.ClearGl_VBClasses;
begin
  SetLength(FGl_VBClasses, 0);
  if Assigned(FGlScriptControl) then
    FGlScriptControl.Reset;
end;

constructor TprpClassesInspector.Create(AOwner: TComponent);
begin
  inherited;

  FNoShowList := TStringList.Create;
  FNoShowList.Sorted := True;
  FNoShowList.Text := NoShowProp;

  //try
    FGlScriptControl := TScriptControl.Create(Self);
  //except
  //  Exit;
  //end;
  FGlScriptControl.Language := 'VBSCRIPT';
  FGlScriptControl.TimeOut := -1;
  prpClassesInspector := Self;

  FVBModuleList := TVBModuleList.Create;
end;

procedure TprpClassesInspector.CreateVBClasses(const prpClassesFrm: IprpClassesFrm);
var
  ibsqlCl: TIBSQL;
  objNum: Integer;
  fParam: PSafeArray;
  Name: String;
  ClObj: OleVariant;

const
  initStr =
    'Public %sObj'#13#10 +
    'Sub %s%s'#13#10 +
    '  Set %sObj = New %s'#13#10 +
    'End Sub';
  initEnding = '_Initialize';

  procedure ErrorObjectInitialization(const ErrMessage: String);
  begin
    MessageBox(0, PChar(String('Ошибка инициализации объекта с сообщением:'#13#10 +
      ErrMessage + #13#10 + 'Объект ' + ibsqlCl.FieldByName('Name').AsString +
      ' не будет доступен.'#13#10 + 'Обратитесь к администратору.')),
      PChar(String(ibsqlCl.FieldByName('Name').AsString + '_Initialize')),
      MB_Ok or MB_ICONERROR or MB_TOPMOST);
  end;

begin
  ClearGl_VBClasses;

  ibsqlCl := TIBSQL.Create(nil);
  try
    ibsqlCl.Transaction := gdcBaseManager.ReadTransaction;
    ibsqlCl.SQL.Text := 'SELECT * FROM gd_function WHERE ' +
      'module = ''VBCLASSES'' AND modulecode = ' + IntToStr(OBJ_APPLICATION);
    ibsqlCl.ExecQuery;

    if ibsqlCl.Eof then
      Exit;

    // создаем массив для хранения указателей интерфейсов гл. объектов
    SetLength(FGl_VBClasses, 128);

    objNum := 0;
    fParam := SafeArrayCreateVector(vtVariant, 0, 0);
    try
      while not ibsqlCl.Eof do
      begin
        // добавляется пустая функция уничтожения гл.объектов
        // если она определена в скрипте, то она будет переопределена
        try
          FGlScriptControl.AddCode(ibsqlCl.FieldByName('Script').AsString);

          Name := ibsqlCl.FieldByName('Name').AsString;
          FGlScriptControl.AddCode(
            Format(initStr, [Name, Name, initEnding, Name, Name]));
          FGlScriptControl.Run(Name + initEnding, fParam);

          // выполнение скрипт-функции по созданию гл. объекта
          // пытаемся получить гл. объект из скрипт-контрола
          ClObj := FGlScriptControl.Eval(Name + 'Obj');
          if VarType(ClObj) = VarDispatch then
          begin
            // сохраняем гл. объект в массив
            FGl_VBClasses[objNum].IDisp := IDispatch(ClObj);
            FGl_VBClasses[objNum].Name := Name;
            // увеличиваем счетчик гл.объектов на единицу
            Inc(objNum);
          end;
        except
        end;
        ibsqlCl.Next;
        if Length(FGl_VBClasses) <= objNum then
          SetLength(FGl_VBClasses, Length(FGl_VBClasses) * 2);
      end;
    finally
      SafeArrayDestroy(fParam);
    end;
    // устанавливаем длину массива, согласно кол-ву удачно созданных объектов
    SetLength(FGl_VBClasses, objNum);
  finally
    ibsqlCl.Free;
  end;
end;

procedure TprpClassesInspector.CreateHierarchyNode(Node: TTreeNode;
  const ClassName: String; const BeginWithParent: Boolean; const prpClassesFrm: IprpClassesFrm);
var
  TmpClass: TClass;
  HierNode, tmpNode: TTreeNode;
  LClassName: String;
  gdcFullClassName: TgdcFullClassName;
  I: Integer;
  FtmpUnsortList: TStrings;
begin
  FtmpUnsortList := TStringList.Create;
  try

    if Length(Trim(ClassName)) = 0 then
      LClassName := Node.Text
    else
      LClassName := ClassName;

    TmpClass := GetClass(LClassName);

    if not Assigned(TmpClass) then
    begin
      gdcFullClassName.gdClassName := LClassName;
      gdcFullClassName.SubType := '';
      TmpClass := gdClassList.GetFrmClass(gdcFullClassName);
      if not Assigned(TmpClass) then
      begin
        TmpClass := gdClassList.GetGDCClass(gdcFullClassName);
        if not Assigned(TmpClass) then
          TmpClass := OLEClassList.GetClass(LClassName);
      end;
    end;

    if (TmpClass <> nil) and (TmpClass.ClassParent <> nil) then
    begin
      FtmpUnsortList.Clear;

      if BeginWithParent then
        TmpClass := TmpClass.ClassParent;
      while TmpClass <> nil do
      begin
        FtmpUnsortList.Add(TmpClass.ClassName);
        TmpClass := TmpClass.ClassParent;
      end;

      HierNode :=
        prpClassesFrm.GetClassesTree.Items.AddChild(Node, cnHierarchy);
      AddItemData(HierNode, ciHierFolder,
        'Иерархия класса ' + HierNode.Parent.Text + '.', prpClassesFrm);
      for I := FtmpUnsortList.Count - 1 downto 0 do
      begin
        tmpNode := prpClassesFrm.GetClassesTree.Items.AddChild(
          HierNode, FtmpUnsortList[I]);
        AddItemData(tmpNode, ciHierClass, 'Класс ' + tmpNode.Text, prpClassesFrm);
      end;
    end;
  finally
    FtmpUnsortList.Free;
  end;
end;

procedure TprpClassesInspector.CreateLoc_VBClasses(const prpClassesFrm: IprpClassesFrm);
var
  I: Integer;
  LNode: TTreeNode;
begin
  FVBModuleList.CreateList;
  for I := 0 to FVBModuleList.Count - 1 do
  begin
    with prpClassesFrm.GetClassesInspector do
    begin
      LNode :=
        tvClassesInsp.Items.AddChild(VBClassesNode, FVBModuleList[I].ModuleName);
      AddItemData(LNode, ciVBModule,
        'Скрипт-модуль ' + LNode.Text + '.', Pointer(FVBModuleList[I]), prpClassesFrm);
      prpClassesInspector.FillVBClass(LNode, prpClassesFrm);

      LNode.HasChildren := True;
    end;
  end;
end;

destructor TprpClassesInspector.Destroy;
begin
  FNoShowList.Free;
  SetLength(FGl_VBClasses, 0);
  FVBModuleList.Free;
  prpClassesInspector := nil;

  inherited;
end;

procedure TprpClassesInspector.FillVBClass(const VBClassNode: TTreeNode;
  const prpClassesFrm: IprpClassesFrm);
var
  i: Integer;
  TmpNode: TTreeNode;
  VBModuleItem: TVBModuleItem;
begin
  if VBClassNode.Parent <> prpClassesFrm.GetClassesInspector.VBClassesNode then
    raise EAbort.Create('');

  if GetItemType(VBClassNode) = ciVBModule then
    VBModuleItem := TVBModuleItem(TInspectorItem(VBClassNode.Data).ItemData)
  else
    raise Exception.Create('Несоответствие типа узла.');

  for i := 0 to VBModuleItem.Count - 1 do
  with prpClassesFrm.GetClassesInspector do
  begin
    TmpNode := tvClassesInsp.Items.AddChild(
      VBClassNode, VBModuleItem[i].Name);
    if Length(Trim(VBModuleItem[i].Description)) = 0 then
      AddItemData(TmpNode, ciVBClass,
        'VB класс (описание отсутствует).',
        Pointer(VBModuleItem[i].IDisp), prpClassesFrm)
    else
      AddItemData(TmpNode, ciVBClass,
        VBModuleItem[i].Description, Pointer(VBModuleItem[i].IDisp), prpClassesFrm);

    AddItemsForVBClass(TmpNode, VBModuleItem[i].IDisp, pdVBClass, mdVBClass, prpClassesFrm);

  end;

  if VBClassNode.getFirstChild = nil then
    VBClassNode.HasChildren := False;
  VBClassNode.AlphaSort;
end;

procedure TprpClassesInspector.SetFrmClassesInspector(
  const Frm: TfrmClassesInspector);
begin
//  FfrmClassesInspector := Frm;
end;

procedure TprpClassesInspector.SetClassDescription(Node: TTreeNode;
  const ClassInterface: IUnknown; const ClassGUID: TGUID);
var
  TypeInfo: ITypeInfo;
  pbstrDocString: PWideChar;
begin
  if (ITypeLib(ClassInterface).GetTypeInfoOfGuid(ClassGUID, TypeInfo) = S_OK) then
  begin
    TypeInfo.GetDocumentation(-1, nil, @pbstrDocString, nil, nil);
    try
      if Length(Trim(TInspectorItem(Node.Data).Description)) = 0 then
        case TInspectorItem(Node.Data).ItemType of
          ciStClass:
            TInspectorItem(Node.Data).Description := 'Стандартный класс (описание отсутствует).';
          ciFrmClass:
            TInspectorItem(Node.Data).Description := 'Класс стандартной формы (описание отсутствует).';
          ciGdcClass:
            TInspectorItem(Node.Data).Description := 'Бизнес-класс (описание отсутствует).';
        end
      else
        TInspectorItem(Node.Data).Description := pbstrDocString;
    finally
      if pbstrDocString <> nil then
        SysFreeString(pbstrDocString);
    end;
  end;
end;

procedure TprpClassesInspector.FillStGlobalObjects(
  const ObjectNode, MethodNode: TTreeNode; const prpClassesFrm: IprpClassesFrm);
var
  I: Integer;
  TypeInfo: ITypeInfo;
  BStrList: PciBStrList;
  ApplList: TStringList;
  StorFlag: Boolean;

  procedure FillApplList(const PNode: TTreeNode);
  var
    fNode: TTreeNode;

  begin
    if PNode <> nil then
    begin
      fNode := PNode.getFirstChild;
      while fNode <> nil do
      begin
        ApplList.Add(MarkName(fNode.Text));
        fNode := PNode.GetNextChild(fNode);
      end;
    end
  end;

  procedure AddProperty(const AdtNode: TTreeNode; const AdtTypeInfo: ITypeInfo;
    const AdtFuncDesc: PFuncDesc);
  var
    APStr: String;
    APClassRef: TClass;
  begin
    GetResultType(AdtNode, AdtTypeInfo, AdtFuncDesc.elemdescFunc, APStr, APClassRef, prpClassesFrm);

  end;
begin
//  if FfrmClassesInspector = nil then
//    raise Exception.Create('Не создан инспектор классов.');

  if not Assigned(GedeminApplication) then
    Exit;

  New(BStrList);
  try
    ApplList := TStringList.Create;
    try
      ApplList.Sorted := True;
      with prpClassesFrm.GetClassesInspector do
      begin
        I := cbClasses.Items.IndexOf(Application.ClassName);
        if I > -1 then
          with TTreeNode(cbClasses.Items.Objects[I]) do
          begin
            StorFlag := Expanded;
            Expand(False);
            FillApplList(TClassItem(Data).MethodsNode);
            FillApplList(TClassItem(Data).PropertyNode);
            if not StorFlag then
              Collapse(False);
          end;
      end;

      if (IDispatch(GedeminApplication).GetTypeInfo(0, 0, TypeInfo) = S_OK) then
        FillGlobal(ObjectNode, MethodNode, TypeInfo, ApplList, prpClassesFrm);
    finally
      ApplList.Free;
    end;
  finally
    Dispose(BStrList);
  end;
end;

function TprpClassesInspector.GetResultType(const Node: TTreeNode;
  const TypeInfo: ITypeInfo; const ElemDesc: TElemDesc;
  out ResultStr: String; out AnClassRef: TClass; const prpClassesFrm: IprpClassesFrm): TTreeNode;
var
  ResTypeInfo: ITypeInfo;
  ResTypeAttr: PTypeAttr;
  TypeDesc: tagTYPEDESC;
  ResRecord: TResRecord;
  TypeLib: ITypeLib;
  I: Integer;
  pbstrResName: PWideChar;
  IntfNode: TTreeNode;
  bAdd: boolean;
begin
  Assert(TypeInfo <> nil);
  TypeDesc := ElemDesc.tdesc;

  Result := nil;
  AnClassRef := nil;
  case TypeDesc.vt of
    VT_PTR:
    begin
      try
        if TypeInfo.GetContainingTypeLib(TypeLib, I) = S_OK then
        ;

        Assert(Assigned(TypeDesc.ptdesc));

        if TypeInfo.GetRefTypeInfo(TypeDesc.ptdesc^.hreftype,
          ResTypeInfo) = S_OK then
        begin
          if ResTypeInfo.GetTypeAttr(ResTypeAttr) = S_OK then
          try
            ResRecord := prpClassesFrm.GetLibArray.GetRef(ResTypeAttr^.guid);
//            ResTypeAttr^.tdescAlias.hRefType
            if ResRecord.ClassRef <> nil then
            begin
              if ResRecord.DataType = rdClass then
              begin
                AnClassRef := TClass(ResRecord.ClassRef);
                ResultStr := AnClassRef.ClassName;
              end else
                if ResRecord.DataType = rdNode then
                begin
                  try
                    Result := TObject(ResRecord.ClassRef) as TTreeNode;;
                    ResultStr := Result.Text;
                  except
                  end;
                end else
                  ResultStr := 'Объект(неопределен)';
            end else begin
              if (ElemDesc.paramdesc.wParamFlags <> PARAMFLAG_FRETVAL) and
                (ElemDesc.paramdesc.wParamFlags <> PARAMFLAG_NONE) then
                ResultStr := 'Variant'
              else
              begin
                bAdd:= False;
                IntfNode:= prpClassesFrm.GetInterfacesNode;
                if Assigned(IntfNode) then begin
                  try
                    ResTypeInfo.GetDocumentation(-1, @pbstrResName, nil, nil, nil);
                    if Length(pbstrResName) > 0 then begin
                      ResultStr:= pbstrResName;
                      IntfNode:= TCrackTreeView(IntfNode.TreeView).Items.AddChild(IntfNode, ResultStr);
                      Result:= IntfNode;
                      AddItemData(IntfNode, ciInterface, 'Интерфейс ' + ResultStr, prpClassesFrm);
                      AddDelphiClassInList(IntfNode, rdNode, ResTypeAttr^.guid, prpClassesFrm);
                      AddForUndefined(IntfNode, ResTypeInfo, prpClassesFrm);
                      bAdd:= True;
                    end;
                  finally
                    if pbstrResName <> nil then
                      SysFreeString(pbstrResName);
                  end;
                end;
                if not bAdd then begin
                  AddDelphiClassInList(Node, rdNode, ResTypeAttr^.guid, prpClassesFrm);
                  AddForUndefined(Node, ResTypeInfo, prpClassesFrm);
                  try
                    ResTypeInfo.GetDocumentation(-1, @pbstrResName, nil, nil, nil);
                    if Length(pbstrResName) > 0 then
                      ResultStr:= pbstrResName;
                  finally
                    if pbstrResName <> nil then
                      SysFreeString(pbstrResName);
                  end;
                end;
              end;
            end;
          finally
            ResTypeInfo.ReleaseTypeAttr(ResTypeAttr);
          end;
        end;
      except
        ResultStr := 'unknown'
      end;
    end;
    VT_CY:
    begin
      ResultStr := 'Currency';
    end;
    VT_DATE:
    begin
      ResultStr := 'Date';
    end;
    VT_I2, VT_I4:
    begin
      ResultStr := 'Integer';
    end;
    VT_R4, VT_R8:
    begin
      ResultStr := 'Real';
    end;
    VT_BSTR:
    begin
      ResultStr := 'String';
    end;
    VT_BOOL:
    begin
      ResultStr := 'Boolean';
    end;
    VT_VARIANT:
    begin
      ResultStr := 'Variant';
    end;
    VT_DISPATCH:
    begin
      ResultStr := 'IDispatch';
    end;
    VT_I1:
    begin
      ResultStr := 'Signed char';
    end;
    VT_UI1:
    begin
      ResultStr := 'Unsigned char';
    end;
    VT_UI2, VT_UI4:
    begin
      ResultStr := 'Unsigned short';
    end;
    VT_USERDEFINED:
    begin
      ResultStr := 'Integer(перечисление)';
    end;
    VT_VOID: // не возвращает
      ;
  else

      ResultStr := 'Неопределен';
  end;
end;

function TprpClassesInspector.AddMethod(const Node: TTreeNode; const BStrList: PciBStrList;
  const FuncDesc: PFuncDesc; const TypeInfo: ITypeInfo; const FuncCount: Integer;
  const prpClassesFrm: IprpClassesFrm): TTreeNode;
var
  Str, tmpStr: String;
  ClassRef: TClass;
  J: Integer;
  InspectorItem: TInspectorItem;
  pbstrDocString: PWideChar;
  NodeRef: TTreeNode;
begin
  Str := '';
  Result := prpClassesFrm.GetClassesTree.Items.AddChild(Node, String(BStrList^[0]));
  InspectorItem := AddItemData(Result, ciMethod, '', ClassRef, prpClassesFrm);

  for J := FuncCount - 1 downto 1 do
  begin
    NodeRef :=
      GetResultType(Result, TypeInfo, FuncDesc^.lprgelemdescParam^[J - 1], tmpStr, ClassRef, prpClassesFrm);

    if Str <> '' then
      Str := String(BStrList^[J]) + ': ' + tmpStr + '; ' + Str
    else
      Str := String(BStrList^[J]) + ': ' + tmpStr;
    if ClassRef <> nil then
    begin
      if InspectorItem.InheritsFrom(TMethodItem) then
        TMethodItem(InspectorItem).AddParam(tmpStr, ClassRef, NodeRef);
    end;
  end;

  if Length(Str) > 0 then
    Str := String(BStrList^[0]) + '(' + Str + ')'
  else
    Str := String(BStrList^[0]);

  Result.Text := Str;

  if FuncDesc.elemdescFunc.tdesc.vt = VT_VOID then
    SetCorrectType(Result, ciMethodGet);

  TypeInfo.GetDocumentation(FuncDesc.memid, nil, @pbstrDocString, nil, nil);
  try
    if Length(pbstrDocString) > 0 then
      TInspectorItem(Result.Data).Description := pbstrDocString
    else
      begin
        TInspectorItem(Result.Data).Description := 'Описание отсутствует.';
      end;
  finally
    if pbstrDocString <> nil then
      SysFreeString(pbstrDocString);
  end;

  if InspectorItem.InheritsFrom(TWithResultItem) then
  begin
    NodeRef :=
      GetResultType(Result, TypeInfo, FuncDesc.elemdescFunc, Str, ClassRef, prpClassesFrm);
    if Length(Trim(Str)) > 0 then
    begin
      Result.Text := Result.Text + ': ' + Str;
      if (FuncDesc.invkind in [DISPATCH_PROPERTYGET, DISPATCH_PROPERTYPUT, DISPATCH_PROPERTYPUTREF]) and
        (FuncDesc.memid = 0) and (FuncCount > 1)
      then
        Result.Text := Result.Text + ' default';
    end;
    InspectorItem.ItemData := ClassRef;
    TWithResultItem(InspectorItem).ResultClassRef := ClassRef;
    TWithResultItem(InspectorItem).ResultNodeRef := NodeRef;
    TWithResultItem(InspectorItem).ResultTypeName := Str;
    TWithResultItem(InspectorItem).NodeText := Result.Text;
  end
end;

{procedure TprpClassesInspector.AddForUndefined(const Node: TTreeNode;
  const TypeInfo: ITypeInfo; const ElemDesc: TElemDesc);
var
  ResTypeInfo: ITypeInfo;
  ResTypeAttr: PTypeAttr;
  rTypeDesc: tagTYPEDESC;

begin
  rTypeDesc := ElemDesc.tdesc;
  case rTypeDesc.vt of
    VT_PTR:
    begin
      try
        if TypeInfo.GetRefTypeInfo(rTypeDesc.ptdesc^.hreftype,
          ResTypeInfo) = S_OK then
        begin
          if ResTypeInfo.GetTypeAttr(ResTypeAttr) = S_OK then
          try
            AddItemsForDelphiClass(Node, nil, ResTypeAttr^.guid);
          finally
            ResTypeInfo.ReleaseTypeAttr(ResTypeAttr);
          end;
        end;
      except
      end;
    end;
  end;
end;
}

function TprpClassesInspector.MarkName(const FullStr: String): String;
var
  MI: Integer;
const
  mcBracket = '(';
  mcColon   = ':';
begin
  MI := Pos(mcBracket, FullStr);
  if MI = 0 then
    MI := Pos(mcColon, FullStr);
  if MI = 0 then
    Result := FullStr
  else
    Result := Copy(FullStr, 1, MI - 1);
end;

procedure TprpClassesInspector.FillVBGlobalObjects(const ObjectNode,
  MethodNode: TTreeNode; const prpClassesFrm: IprpClassesFrm);
var
  TypeInfo: ITypeInfo;
  TypeLib: ITypeLib;
begin
  if (LoadTypeLib(cVBScript, TypeLib) = S_OK) and
    (TypeLib.GetTypeInfoOfGuid(GlobalObj_GUID, TypeInfo) = S_OK) then
  begin
    FillGlobal(ObjectNode, MethodNode, TypeInfo, nil, prpClassesFrm);
  end;
end;

procedure TprpClassesInspector.FillGlobal(const ObjectNode, MethodNode: TTreeNode;
  const TypeInfo: ITypeInfo; const CustomNoShowList: TStrings; const prpClassesFrm: IprpClassesFrm);
var
  TypeAttr: PTypeAttr;
  I, J: Integer;
  BStrList: PciBStrList;
  FuncDesc: PFuncDesc;
  VarDesc:  PVarDesc;
  cNames: Integer;
  Str: String;
  tmpNode: TTreeNode;
  InspectorItem: TInspectorItem;
  ClassRef: TClass;

begin
  if TypeInfo.GetTypeAttr(TypeAttr) = S_Ok then
  try
    New(BStrList);
    try
    for I := 0 to TypeAttr.cFuncs - 1 do
    begin
      if (TypeInfo.GetFuncDesc(I, FuncDesc) = S_OK) then
      try
        if (TypeInfo.GetNames(FuncDesc.memid, PBStrList(BStrList), MaxFuncParams, cNames) =
          S_OK) then
        try
          with prpClassesFrm.GetClassesInspector do
          begin
            if ('FINALLYOBJECT' <> AnsiUpperCase(String(BStrList^[0]))) and
              (FNoShowList.IndexOf(String(BStrList^[0])) = -1) and
              ((CustomNoShowList = nil) or
               (CustomNoShowList.IndexOf(String(BStrList^[0])) = -1)) then
            begin
              if FuncDesc.invkind = DISPATCH_METHOD then
              begin
                Str := '';
                for J := cNames - 1 downto 1 do
                begin
                  if Str <> '' then
                    Str := String(BStrList^[J]) + '; ' + Str
                  else
                    Str := String(BStrList^[J]);
                end;

                Str := String(BStrList^[0]) + '(' + Str + ')';
              end else
                Str := String(BStrList^[0]);

              case FuncDesc.invkind of
                DISPATCH_METHOD:
                begin
                  AddMethod(MethodNode, BStrList, FuncDesc, TypeInfo, cNames, prpClassesFrm);
                end;

                DISPATCH_PROPERTYGET:
                begin
                  tmpNode := AddGlObjectNode(ObjectNode, Str, TypeInfo, InspectorItem, prpClassesFrm);
                  Str := '';
                  if InspectorItem.InheritsFrom(TWithResultItem) then
                  begin
                    TWithResultItem(InspectorItem).ResultNodeRef :=
                      GetResultType(tmpNode, TypeInfo,
                        FuncDesc.elemdescFunc, Str, ClassRef, prpClassesFrm);
                    TWithResultItem(InspectorItem).ResultTypeName := Str;
                    TWithResultItem(InspectorItem).ResultClassRef := ClassRef;
                  end;
                  if Length(Str) > 0 then
                    tmpNode.Text := tmpNode.Text + ': ' + Str;

                end;
                DISPATCH_PROPERTYPUT:
                begin
                end;
              end;
            end;
          end;
        finally
          for J := cNames - 1 downto 1 do
          begin
            if BStrList^[J] <> nil then
              SysFreeString(BStrList^[J]);
          end;
        end
      finally
        TypeInfo.ReleaseFuncDesc(FuncDesc);
      end;
    end;
    for I := 0 to TypeAttr.cVars - 1 do
    begin
      if TypeInfo.GetVarDesc(I, VarDesc) = S_OK then
      try
        if (TypeInfo.GetNames(VarDesc.memid, PBStrList(BStrList),
          MaxFuncParams, cNames) = S_OK) then
        begin
          if VarDesc.wVarFlags = VARFLAG_FREADONLY then
            Str := BStrList^[0]
          else
            Str := BStrList^[0];

        end;
      finally
        TypeInfo.ReleaseVarDesc(VarDesc);
      end;
    end;

    finally
      Dispose(BStrList);
    end;
  finally
    TypeInfo.ReleaseTypeAttr(TypeAttr);
  end;

end;

procedure TprpClassesInspector.FillUsGlobalObjects(const ObjectNode,
  MethodNode: TTreeNode; const prpClassesFrm: IprpClassesFrm);
var
  LGlObjArray: TGlObjArray;
  I: Integer;
  InspectorItem: TInspectorItem;
  TypeInfo: ITypeInfo;
  TypeAttr: PTypeAttr;
  LNode: TTreeNode;
begin
  LGlObjArray := TCrackDmClientReport(dmClientReport).GlObjArray;
  if LGlObjArray = nil then
    Exit;

  for I := 0 to Length(LGlObjArray) - 1 do
  begin
    if LGlObjArray[I].IDisp = nil then
      Continue;

    if (LGlObjArray[I].IDisp.GetTypeInfo(0, 0, TypeInfo) = S_OK) then
    begin
      if (TypeInfo.GetTypeAttr(TypeAttr) = S_Ok) then
      try
        LNode := AddGlObjectNode(ObjectNode, LGlObjArray[I].Name, TypeInfo, InspectorItem, prpClassesFrm);

        if Length(LGlObjArray[I].Description) > 0 then
          InspectorItem.Description := LGlObjArray[I].Description;

        AddItemsByDispath(LNode, LGlObjArray[I].IDisp, prpClassesFrm);
      finally
        TypeInfo.ReleaseTypeAttr(TypeAttr);
      end;
    end;
  end;
end;

function TprpClassesInspector.AddGlObjectNode(const Node: TTreeNode;
  PropName: String; const TypeInfo: ITypeInfo;
  out NodeItem: TInspectorItem; const prpClassesFrm: IprpClassesFrm): TTreeNode;
begin
  Result :=
    prpClassesFrm.GetClassesTree.Items.AddChild(Node, PropName);
  NodeItem :=
    AddItemData(Result, ciPropertyR, 'Глобальный объект ' + PropName + '.', prpClassesFrm);

//  if NodeItem.InheritsFrom(TWithResultItem) then
//  begin
//    NodeItem.ItemData := Pointer(TypeInfo);
//    TWithResultItem(NodeItem).ResultClassRef := Pointer(TypeInfo);
//    TWithResultItem(NodeItem).ResultTypeName := Str;
//    TWithResultItem(NodeItem).NodeText := Result.Text;
//  end;

end;

procedure TprpClassesInspector.Clear;
begin
  ClearGl_VBClasses;
  FVBModuleList.Clear;
end;

procedure TprpClassesInspector.AddItemsByDispath(Node: TTreeNode;
  const ClassInterface: IDispatch; const prpClassesFrm: IprpClassesFrm);
var
  I, J, H: Integer;
  TypeInfo: ITypeInfo;
  TypeAttr: PTypeAttr;
  FuncDesc: PFuncDesc;
  VarDesc:  PVarDesc;
  cNames: Integer;
  Str: String;
  PropNode, MetNode, ItemNode: TTreeNode;
  ClassRef: TClass;
  pbstrDocString: PWideChar;
  InspectorItem: TInspectorItem;
  BStrList: PciBStrList;
  ResNode: TTreeNode;
  tmpSortList: TStringList;
  TypeLib: ITypeLib;
  pptlibattr: PTLibAttr;
  y: Integer;

begin
  Assert(ClassInterface <> nil);

  New(BStrList);
  try
    tmpSortList := TStringList.Create;
    try
      tmpSortList.Sorted := True;

      PropNode := nil;
      MetNode := nil;


//      ClassInterface.
      if (ClassInterface.GetTypeInfo(0, 0, TypeInfo) = S_OK) then
      try

        TypeInfo.GetContainingTypeLib(TypeLib, y);
        TypeLib.GetLibAttr(pptlibattr);
        try
        finally
          TypeLib.ReleaseTLibAttr(pptlibattr);
        end;



        TypeInfo.GetDocumentation(-1, nil, @pbstrDocString, nil, nil);
        try
          if (Node.Data <> nil) and (Length(pbstrDocString) > 0) then
            TInspectorItem(Node.Data).Description := pbstrDocString;
        finally
          if pbstrDocString <> nil then
            SysFreeString(pbstrDocString);
        end;
        if (TypeInfo.GetTypeAttr(TypeAttr) = S_Ok) then
        begin
          for I := 0 to TypeAttr.cFuncs - 1 do
          begin
            if (TypeInfo.GetFuncDesc(I, FuncDesc) = S_OK) then
            try
              if (TypeInfo.GetNames(FuncDesc.memid, PBStrList(BStrList), MaxFuncParams, cNames) =
                S_OK) then
//              with FfrmClassesInspector do
              try
                if FNoShowList.IndexOf(BStrList^[0]) = -1 then
                begin
                  Str := BStrList^[0];
                  Str := '';
                  case FuncDesc.invkind of
                    DISPATCH_METHOD:
                    begin
                      if MetNode = nil then
                      begin
                        MetNode := TCrackTreeView(Node.TreeView).Items.AddChild(Node, cnMethods);
                        AddItemData(MetNode, ciMethodFolder,
                          'Методы класса ' + Node.Text + '.', prpClassesFrm);
                      end;
                      AddMethod(MetNode, BStrList, FuncDesc, TypeInfo, cNames, prpClassesFrm);
                    end;

                    DISPATCH_PROPERTYGET, DISPATCH_PROPERTYPUT, DISPATCH_PROPERTYPUTREF:
                    begin
                      if not Assigned(PropNode) then
                      begin
                        PropNode := TCrackTreeView(Node.TreeView).Items.AddChild(Node, cnProperty);
                        AddItemData(PropNode, ciPropertyFolder,
                          'Свойства класса ' + Node.Text + '.', prpClassesFrm);
                      end;

                      H := tmpSortList.IndexOf(BStrList^[0]);

                      InspectorItem := nil;
                      if H = -1 then
                      begin
                        ItemNode := TCrackTreeView(Node.TreeView).Items.AddChild(PropNode, BStrList^[0]);
                        InspectorItem := AddItemData(ItemNode, ciPropertyR, '', ClassRef, prpClassesFrm);
                        InspectorItem.ItemType := ciUnknown;
                        H := tmpSortList.Add(String(BStrList^[0]));
                        tmpSortList.Objects[H] := ItemNode;
                      end else
                        begin
                          ItemNode := TTreeNode(tmpSortList.Objects[H]);
                          if TObject(ItemNode.Data).InheritsFrom(TInspectorItem) then
                            InspectorItem := TInspectorItem(ItemNode.Data);
                        end;

                      if InspectorItem = nil then
                        Continue;

                      case FuncDesc.invkind of
                        DISPATCH_PROPERTYGET:
                        begin
                          if InspectorItem.ItemType = ciPropertyW then
                            SetCorrectType(ItemNode, ciPropertyRW)
                          else
                            SetCorrectType(ItemNode, ciPropertyR);
                        end;
                        DISPATCH_PROPERTYPUT:
                        begin
                          if InspectorItem.ItemType = ciPropertyR then
                            SetCorrectType(ItemNode, ciPropertyRW)
                          else
                            SetCorrectType(ItemNode, ciPropertyW);
                        end;
                        DISPATCH_PROPERTYPUTREF:
                        begin
                          InspectorItem := AddItemData(ItemNode, ciPropertyRW, '', ClassRef, prpClassesFrm);
                        end;
                      end;
                      TypeInfo.GetDocumentation(FuncDesc.memid, nil, @pbstrDocString, nil, nil);
                      try
                        TInspectorItem(ItemNode.Data).Description := pbstrDocString;
                      finally
                        if pbstrDocString <> nil then
                          SysFreeString(pbstrDocString);
                      end;
                      if Length(Trim(TInspectorItem(ItemNode.Data).Description)) = 0 then
                      begin
                        TInspectorItem(ItemNode.Data).Description := 'Описание отсутствует.';
                      end;

                      if (FuncDesc.invkind = DISPATCH_PROPERTYGET) or
                        (FuncDesc.invkind = DISPATCH_PROPERTYPUTREF) or
                        (FuncDesc.invkind = DISPATCH_METHOD)
                      then
                      begin
                        ResNode :=
                          GetResultType(ItemNode, TypeInfo, FuncDesc.elemdescFunc, Str, ClassRef, prpClassesFrm);
                        if Length(Trim(Str)) > 0 then
                          ItemNode.Text := ItemNode.Text + ': ' + Str;
                        if InspectorItem.InheritsFrom(TWithResultItem) then
                        begin
                          TWithResultItem(InspectorItem).ResultNodeRef := ResNode;
                          TWithResultItem(InspectorItem).ResultClassRef := ClassRef;
                          TWithResultItem(InspectorItem).ResultTypeName := Str;
                          TWithResultItem(InspectorItem).NodeText := ItemNode.Text;
                        end;
                      end;

                    end;
                  end;
                end;
              finally
                for J := cNames - 1 downto 0 do
                begin
                  if BStrList^[J] <> nil then
                    SysFreeString(BStrList^[J]);
                end;
              end;
            finally
              TypeInfo.ReleaseFuncDesc(FuncDesc);
            end;
          end;
////////////////////
          for I := 0 to TypeAttr.cVars - 1 do
          begin
            if (TypeInfo.GetVarDesc(I, VarDesc) = S_OK) then
            try
              if (TypeInfo.GetNames(VarDesc.memid, PBStrList(BStrList), MaxFuncParams, cNames) =
                S_OK) then
//              with FfrmClassesInspector do
              try
                if FNoShowList.IndexOf(BStrList^[0]) = -1 then
                begin
//                  Str := BStrList^[0];
//                  Str := '';
//                  ItemNode := AddPropertyNode(Str);
                  if PropNode = nil then
                  begin
                    PropNode := TCrackTreeView(Node.TreeView).Items.AddChild(Node, cnProperty);
                    AddItemData(PropNode, ciPropertyFolder,
                      '', prpClassesFrm);
                  end;
                  case VarDesc.elemdescVar.tdesc.vt of
                    DISPATCH_PROPERTYGET:
                    begin
                      AddProperty(PropNode, ciPropertyR,
                        BStrList, VarDesc, TypeInfo, cNames, prpClassesFrm);
                    end;

                    DISPATCH_PROPERTYPUT:
                    begin
                      AddProperty(PropNode, ciPropertyW,
                        BStrList, VarDesc, TypeInfo, cNames, prpClassesFrm);
                    end;
                    DISPATCH_PROPERTYPUTREF, DISPATCH_PROPERTYPUTREF or DISPATCH_PROPERTYPUT:
                    begin
                      AddProperty(PropNode, ciPropertyRW,
                        BStrList, VarDesc, TypeInfo, cNames, prpClassesFrm);
                    end;
                  end;
                end;
              finally
                  for J := cNames - 1 downto 0 do
                begin
                  if BStrList^[J] <> nil then
                    SysFreeString(BStrList^[J]);
                end;
              end;


            finally
              TypeInfo.ReleaseFuncDesc(FuncDesc);
            end;
          end;
////////////////////

        end;
      finally
        TypeInfo.ReleaseTypeAttr(TypeAttr);
      end;
    finally
      tmpSortList.Free;
    end;
  finally
    Dispose(BStrList);
  end;

  if MetNode <> nil then
    MetNode.AlphaSort;
  if PropNode <> nil then
    PropNode.AlphaSort;
end;

procedure TprpClassesInspector.AddForUndefined(const Node: TTreeNode;
  const TypeInfo: ITypeInfo; const prpClassesFrm: IprpClassesFrm);
begin
  AddItemsForDelphiClass2(Node, TypeInfo, prpClassesFrm);
end;

procedure TprpClassesInspector.AddItemsForDelphiClass2(
  Node: TTreeNode; const TypeInfo: ITypeInfo; const prpClassesFrm: IprpClassesFrm);
var
  slInheritedList: TStringList;

  procedure FillInheritedList;
  var
    InhTypeInfo: ITypeInfo;
    BStrInhList: PciBStrList;
    InhNode: TTreeNode;
    InhTypeAttr: PTypeAttr;
    InhFuncDesc: PFuncDesc;
    COMClassItem: TgdcCOMClassItem;
    InhClass: TClass;
    k, cInhNames: integer;
  begin
    InhNode:= TClassItem(Node.Data).HierarchyNode.GetLastChild;
    if Assigned(InhNode) then begin
      InhClass:= OLEClassList.GetClass(InhNode.Text);
      if InhClass = nil then
        InhClass:= GetClass(InhNode.Text);
    end
    else
      Exit;
    COMClassItem := OLEClassList.FindOLEClassItem(InhClass);
    if Assigned(COMClassItem) then
      if (ComServer.TypeLib.GetTypeInfoOfGuid(COMClassItem.DispIntf, InhTypeInfo) <> S_OK) then
        InhTypeInfo:= nil;
    New(BStrInhList);
    try
      if Assigned(InhTypeInfo) and (InhTypeInfo.GetTypeAttr(InhTypeAttr) = S_OK) then begin
        for k:= 0 to InhTypeAttr.cFuncs - 1 do
          try
            if (InhTypeInfo.GetFuncDesc(k, InhFuncDesc) = S_OK) then begin
              if (InhTypeInfo.GetNames(InhFuncDesc.memid, PBStrList(BStrInhList),
                  MaxFuncParams, cInhNames) = S_OK) then
              slInheritedList.Add(BStrInhList^[0]);
            end;
          finally
            InhTypeInfo.ReleaseFuncDesc(InhFuncDesc);
          end;
      end;
    finally
      InhTypeInfo.ReleaseTypeAttr(InhTypeAttr);
      Dispose(BStrInhList);
    end;
  end;

var
  I, J, H: Integer;
  TypeAttr: PTypeAttr;
  FuncDesc: PFuncDesc;
  cNames: Integer;
  PropNode, MetNode, ItemNode: TTreeNode;
  InspectorItem: TInspectorItem;
  BStrList: PciBStrList;
  pBstrName, pbstrDocString, pdwHelpContext, pBstrHelpFile: PWideChar;
  tmpSortList: TStringList;
begin
  if TypeInfo = nil then
    raise Exception.Create('Не передан TypeInfo.');

  New(BStrList);
  try
    tmpSortList := TStringList.Create;
    slInheritedList:= TStringList.Create;
    try
      tmpSortList.Sorted := True;

      PropNode := nil;
      MetNode := nil;
      TypeInfo.GetDocumentation(-1, @pBstrName, @pbstrDocString, @pdwHelpContext, @pBstrHelpFile);
      try
        if Length(pbstrDocString) > 0 then
          TInspectorItem(Node.Data).Description := pbstrDocString;
      finally
        if pbstrDocString <> nil then
          SysFreeString(pbstrDocString);
      end;
      if (TypeInfo.GetTypeAttr(TypeAttr) = S_Ok) then
      try
        begin
          if not prpClassesFrm.IsShowInherited and Assigned(TClassItem(Node.Data).HierarchyNode) then begin
            try
              FillInheritedList;
            except
              slInheritedList.Clear;
            end;
          end;

          for I := 0 to TypeAttr.cFuncs - 1 do
          begin
            if (TypeInfo.GetFuncDesc(I, FuncDesc) = S_OK) then
            try
              if (TypeInfo.GetNames(FuncDesc.memid, PBStrList(BStrList), MaxFuncParams, cNames) =
                S_OK) then
              try
                if (FNoShowList.IndexOf(BStrList^[0]) = -1) and (slInheritedList.IndexOf(BStrList^[0]) = -1) then
                begin
                  case FuncDesc.invkind of
                    DISPATCH_METHOD:
                    begin
                      if MetNode = nil then
                      begin
                        MetNode := prpClassesFrm.GetClassesTree.Items.AddChild(Node, cnMethods);
                        AddItemData(MetNode, ciMethodFolder,
                          'Методы класса ' + Node.Text + '.', prpClassesFrm);
                      end;
                      AddMethod(MetNode, BStrList, FuncDesc, TypeInfo, cNames, prpClassesFrm);
                    end;

                    DISPATCH_PROPERTYGET, DISPATCH_PROPERTYPUT, DISPATCH_PROPERTYPUTREF:
                    begin
                      if not Assigned(PropNode) then
                      begin
                        PropNode := prpClassesFrm.GetClassesTree.Items.AddChild(Node, cnProperty);
                        AddItemData(PropNode, ciPropertyFolder,
                          'Свойства класса ' + Node.Text + '.', prpClassesFrm);
                      end;

                      H := tmpSortList.IndexOf(BStrList^[0]);

                      if H = -1 then
                      begin
                        ItemNode := AddMethod(PropNode, BStrList, FuncDesc,
                          TypeInfo, cNames, prpClassesFrm);

                        H := tmpSortList.Add(String(BStrList^[0]));
                        tmpSortList.Objects[H] := ItemNode;
                      end else
                        ItemNode := TTreeNode(tmpSortList.Objects[H]);
                      InspectorItem := TInspectorItem(ItemNode.Data);

                      case FuncDesc.invkind of
                        DISPATCH_PROPERTYGET:
                        begin
                          if InspectorItem.ItemType = ciPropertyW then
                            SetCorrectType(ItemNode, ciPropertyRW)
                          else
                            SetCorrectType(ItemNode, ciPropertyR);
                        end;
                        DISPATCH_PROPERTYPUT:
                        begin
                          if InspectorItem.ItemType = ciPropertyR then
                            SetCorrectType(ItemNode, ciPropertyRW)
                          else
                            SetCorrectType(ItemNode, ciPropertyW);
                        end;
                        DISPATCH_PROPERTYPUTREF:
                        begin
                          if InspectorItem.ItemType <> ciPropertyR then
                            SetCorrectType(ItemNode, ciPropertyRW)
                        end;
                      end;
                    end;
                  end;
                end;
              finally
                  for J := cNames - 1 downto 0 do
                begin
                  if BStrList^[J] <> nil then
                    SysFreeString(BStrList^[J]);
                end;
              end;
            finally
              TypeInfo.ReleaseFuncDesc(FuncDesc);
            end;
          end;
        end;
      finally
        TypeInfo.ReleaseTypeAttr(TypeAttr);
      end;
    finally
      tmpSortList.Free;
      slInheritedList.Free;
    end;
  finally
    Dispose(BStrList);
  end;

  if MetNode <> nil then
    MetNode.AlphaSort;
  if PropNode <> nil then
    PropNode.AlphaSort;
end;

procedure TprpClassesInspector.ShowHelpByGUIDString(
  const GUIDString: String);
var
  GUIDRec: TGUID;
  TypeInfo: ITypeInfo;
  TypeLib: ITypeLib;
  Registry: TRegistry;
  SubKeyList: TStrings;
  RegOpened: Boolean;
  szFile: PWideChar;
  str: WideString;

begin
  Registry := TRegistry.Create;
  try
    Registry.RootKey := HKEY_CLASSES_ROOT;
    SubKeyList := TStringList.Create;
    try
      RegOpened := Registry.OpenKeyReadOnly('CLSID\' + GUIDString + '\LocalServer32');
      try
        if not RegOpened then
          RegOpened := Registry.OpenKeyReadOnly('CLSID\' + GUIDString + '\InprocServer32');
        if not RegOpened then
          Exit;

        str := Registry.ReadString('');
        szFile := PWideChar(str);  
        if LoadTypeLib(szFile, TypeLib) = S_OK then
        begin
          GUIDRec := StringToGUID(GUIDString);
          if (TypeLib.GetTypeInfoOfGuid(GUIDRec, TypeInfo) = S_OK) then
          begin
            GUIDRec := StringToGUID(GUIDString);
          end;
        end;
      finally
        if RegOpened then
          Registry.CloseKey;
      end;


{      Registry.OpenKeyReadOnly('TypeLib\' + GUIDString);
      try
        Registry.GetKeyNames(SubKeyList);
        VerMajor := StrToInt(Copy(SubKeyList[SubKeyList.Count - 1], 1, Pos('.', SubKeyList[SubKeyList.Count - 1]) - 1));
        VerMinor := StrToInt(Copy(SubKeyList[SubKeyList.Count - 1], Pos('.', SubKeyList[SubKeyList.Count - 1]) + 1, Length(SubKeyList[SubKeyList.Count - 1])));
      finally
        Registry.CloseKey;
      end;   }
    finally
      SubKeyList.Free;
    end;
  finally
    Registry.Free;
  end;

{  GUIDRec := StringToGUID(GUIDString);
  LoadRegTypeLib(GUIDRec, VerMajor, VerMinor, 0, TypeLib);
  if (ComServer.TypeLib.GetTypeInfoOfGuid(GUIDRec, TypeInfo) = S_OK) then
  begin
    GUIDRec := StringToGUID(GUIDString);
  end;                 }
end;

function TprpClassesInspector.AddProperty(const Node: TTreeNode;
  const NodeType: TciItemType;
  const BStrList: PciBStrList; const VarDesc: PVarDesc;
  const TypeInfo: ITypeInfo; const VarCount: Integer;
  const prpClassesFrm: IprpClassesFrm): TTreeNode;
var
  Str, tmpStr: String;
  ClassRef: TClass;
  J: Integer;
  InspectorItem: TInspectorItem;
  pbstrDocString: PWideChar;
  NodeRef: TTreeNode;
begin
  Str := '';
  Result := prpClassesFrm.GetClassesTree.Items.AddChild(Node, String(BStrList^[0]));
  InspectorItem := AddItemData(Result, NodeType, '', ClassRef, prpClassesFrm);

  for J := VarCount - 1 downto 1 do
  begin
    NodeRef :=
      GetResultType(Result, TypeInfo, VarDesc^.elemdescVar, tmpStr, ClassRef, prpClassesFrm);

    if Str <> '' then
      Str := String(BStrList^[0]) + ': ' + tmpStr + '; ' + Str
    else
      Str := String(BStrList^[0]) + ': ' + tmpStr;
    if ClassRef <> nil then
    begin
      if InspectorItem.InheritsFrom(TMethodItem) then
        TMethodItem(InspectorItem).AddParam(tmpStr, ClassRef, NodeRef);
    end;
  end;

  if Length(Str) > 0 then
    Str := String(BStrList^[0]) + '(' + Str + ')'
  else
    Str := String(BStrList^[0]);

  Result.Text := Str;

  TypeInfo.GetDocumentation(VarDesc.memid, nil, @pbstrDocString, nil, nil);
  try
    if Length(pbstrDocString) > 0 then
      TInspectorItem(Result.Data).Description := pbstrDocString
    else
      begin
        TInspectorItem(Result.Data).Description := 'Описание отсутствует.';
      end;
  finally
    if pbstrDocString <> nil then
      SysFreeString(pbstrDocString);
  end;

  if InspectorItem.InheritsFrom(TWithResultItem) then
  begin
    GetResultType(Result, TypeInfo, VarDesc.elemdescVar, Str, ClassRef, prpClassesFrm);
    if Length(Trim(Str)) > 0 then
      Result.Text := Result.Text + ': ' + Str;
    InspectorItem.ItemData := ClassRef;
    TWithResultItem(InspectorItem).ResultClassRef := ClassRef;
    TWithResultItem(InspectorItem).ResultTypeName := Str;
    TWithResultItem(InspectorItem).NodeText := Result.Text;
  end;
end;

{ TVBModuleItem }

procedure TVBModuleItem.Clear;
begin
  SetLength(FVBClasses, 0);
  if Assigned(FScriptControl) then
    FScriptControl.Reset;
end;

constructor TVBModuleItem.Create;
begin
  FScriptControl := TScriptControl.Create(nil);
  FScriptControl.Language := 'VBSCRIPT';
  FScriptControl.TimeOut := -1; 
  Clear;
end;

function TVBModuleItem.CreateVBClasses(
  const ModuleCode: Integer; const ModuleName: String): Boolean;
var
  ibsqlCl: TIBSQL;
  objNum: Integer;
  fParam: PSafeArray;
  Name: String;
  ClObj: OleVariant;

const
  initStr =
    'Public %sObj'#13#10 +
    'Sub %s%s'#13#10 +
    '  Set %sObj = New %s'#13#10 +
    'End Sub';
  initEnding = '_Initialize';

  procedure ErrorObjectInitialization(const ErrMessage: String);
  begin
    MessageBox(0, PChar(String('Ошибка инициализации объекта с сообщением:'#13#10 +
      ErrMessage + #13#10 + 'Объект ' + ibsqlCl.FieldByName('Name').AsString +
      ' не будет доступен.'#13#10 + 'Обратитесь к администратору.')),
      PChar(String(ibsqlCl.FieldByName('Name').AsString + '_Initialize')),
      MB_Ok or MB_ICONERROR or MB_TOPMOST);
  end;

begin
  Clear;
  FModuleCode := ModuleCode;
  FModuleName := ModuleName;

  ibsqlCl := TIBSQL.Create(nil);
  try
    ibsqlCl.Transaction := gdcBaseManager.ReadTransaction;
    ibsqlCl.SQL.Text := 'SELECT * FROM gd_function WHERE ' +
      'module = ''VBCLASSES'' AND modulecode = ' + IntToStr(FModuleCode);
    ibsqlCl.ExecQuery;

    if ibsqlCl.Eof then
    begin
      Result := False;
      Exit;
    end;  

    // создаем массив для хранения указателей интерфейсов гл. объектов
    SetLength(FVBClasses, 128);

    objNum := 0;
    fParam := SafeArrayCreateVector(vtVariant, 0, 0);
    try
      while not ibsqlCl.Eof do
      begin
        try
          // добавляется пустая функция уничтожения гл.объектов
          // если она определена в скрипте, то она будет переопределена
          FScriptControl.AddCode(ibsqlCl.FieldByName('Script').AsString);

          Name := ibsqlCl.FieldByName('Name').AsString;
          FScriptControl.AddCode(
            Format(initStr, [Name, Name, initEnding, Name, Name]));
          FScriptControl.Run(Name + initEnding, fParam);

          // выполнение скрипт-функции по созданию гл. объекта
          // пытаемся получить гл. объект из скрипт-контрола
          ClObj := FScriptControl.Eval(Name + 'Obj');
          if VarType(ClObj) = VarDispatch then
          begin
            // сохраняем гл. объект в массив
            FVBClasses[objNum].IDisp := IDispatch(ClObj);
            FVBClasses[objNum].Name := Name;
            FVBClasses[objNum].Description := ibsqlCl.FieldByName('Comment').AsString;
            // увеличиваем счетчик гл.объектов на единицу
            Inc(objNum);
          end;
        except
          // nothing
        end;
        ibsqlCl.Next;
        if Length(FVBClasses) <= objNum then
          SetLength(FVBClasses, Length(FVBClasses) * 2);
      end;
    finally
      SafeArrayDestroy(fParam);
    end;
    // устанавливаем длину массива, согласно кол-ву удачно созданных объектов
    SetLength(FVBClasses, objNum);
  finally
    ibsqlCl.Free;
  end;

  Result := objNum > 0;
end;

destructor TVBModuleItem.Destroy;
begin
  Clear;
  FScriptControl.Free;
  inherited;
end;

function TVBModuleItem.GetCount: Integer;
begin
  Result := Length(FVBClasses);
end;

function TVBModuleItem.GetVBClasses(Index: Integer): TSingleGlObj;
begin
  if (Index > -1) and (Index < Count) then
    Result := FVBClasses[Index]
  else
    raise Exception.Create(Format(SListIndexError, [Index]));
end;

{ TVBModuleList }

procedure TVBModuleList.Clear;
begin
  FList.Clear;
end;

constructor TVBModuleList.Create;
begin
  FList := TObjectList.Create(True);
end;

procedure TVBModuleList.CreateList;
var
  ibsqlCl: TIBSQL;
  LModuleItem: TVBModuleItem;
begin
  ibsqlCl := TIBSQL.Create(nil);
  try
    ibsqlCl.Transaction := gdcBaseManager.ReadTransaction;
    ibsqlCl.SQL.Text :=
      'SELECT DISTINCT f.modulecode, o.objectname '#13#10 +
      'FROM gd_function f '#13#10 +
      '  LEFT JOIN evt_object o ON f.modulecode = o.id '#13#10 +
      'WHERE UPPER(f.module) = UPPER(:module)'#13#10 +
      '  ORDER BY f.modulecode';
    ibsqlCl.Params[0].AsString := scrVBClasses;
    ibsqlCl.ExecQuery;

    if ibsqlCl.Eof then
      Exit;

    while not ibsqlCl.Eof do
    begin
      LModuleItem := TVBModuleItem.Create;

      try
        if LModuleItem.CreateVBClasses(
          ibsqlCl.FieldByName('modulecode').AsInteger,
          ibsqlCl.FieldByName('objectname').AsString) then
        begin
          FList.Add(LModuleItem);
        end else
          LModuleItem.Free;
      except
        LModuleItem.Free;
      end;


      ibsqlCl.Next;
    end;
    ibsqlCl.Close;
  finally
    ibsqlCl.Free;
  end;
end;

destructor TVBModuleList.Destroy;
begin
  FList.Free;
  inherited;
end;

function TVBModuleList.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TVBModuleList.GetModuleItem(Index: Integer): TVBModuleItem;
begin
  Result := TVBModuleItem(FList[Index]);
end;

initialization
  prpClassesInspectorObj := TprpClassesInspector.Create(nil);

finalization
  prpClassesInspectorObj.Free;

end.
