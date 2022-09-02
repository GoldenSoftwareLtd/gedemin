// ShlTanya, 07.10.2019
unit prp_dlgViewProperty2_unit;

interface

uses
  prp_dlgViewProperty_unit, gdcEvent, gdcFunction, gdcBase, gdcObject,
  Menus, Dialogs, Db, IBQuery, IBSQL, Classes, ActnList, IBCustomDataSet,
  Messages, IBDatabase, SynCompletionProposal, SynHighlighterJScript,
  SynEditHighlighter, SynHighlighterVBScript, ImgList, Controls, StdCtrls,
  ComCtrls, Forms, SynEdit, SynDBEdit, DBCtrls, Mask, ExtCtrls, TB2Item,
  TB2Dock, TB2Toolbar, Windows, prm_ParamFunctions_unit, evt_i_Base, TypInfo,
  evt_Base, mtd_Base, mtd_i_Base, gd_ClassList, gdcMacros, DBClient,
  gdcTemplate, gdcReport, Buttons, gdcTree, gdcDelphiObject,
  gsFunctionSyncEdit, StdActns, TB2ToolWindow, FR_Dock;

type
  TCrackDBSynEdit = class(TDBSynEdit);

  TdlgViewProperty2 = class(TdlgViewProperty)
    procedure tvClassesChange(Sender: TObject; Node: TTreeNode);
    procedure actFuncCommitExecute(Sender: TObject);
    procedure actFuncRollbackExecute(Sender: TObject);
    procedure dblcbSetFunctionClick(Sender: TObject);
    procedure dblcbSetFunctionKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  protected
    // Полный коммит
    function OverallCommit: Boolean; override;
    // Полный откат
    procedure OverallRollback; override;

    function GetObjectId(ANode: TTreeNode): Integer; override;
    // ищет класс в БД если не находит добавл-ет
//    procedure FindClass(const AnTreeNode: TTreeNode);
    function FindClass(const AnTreeNode: TTreeNode; const AnIsCreate: Boolean = True): Boolean;
    // добавл-е класса в ТБД evt_object
    procedure AddClass(const AnMethodClass: TMethodClass; const AnParent: Variant;
     const AnObjectType: Integer = 1);

    function SaveMethod(const AnClassNode: TTreeNode;
     const AnMethodNode: TTreeNode): Boolean;

    function AddClassItem(const AnClassMethods: TgdcClassMethods;{ const AnClassName: String;}
     const AnParentNode: TTreeNode; gdcCLIndex: Integer): TTreeNode;

    function AddMethodItem(AnMethod: TMethodItem;  const AnParentNode: TTreeNode): TTreeNode;
{    function AddMethodItem(OwnerClass: TMethodClass; const AnMethodName: String;
     AnMethodData: PTypeData;  const AnParentNode: TTreeNode): TTreeNode;}
    function GetMethodControl: TMethodControl;
    property LocMethodControl: TMethodControl read GetMethodControl;
  public
    { Public declarations }
    procedure Execute(const AnComponent: TComponent;
     const AnShowMode: TShowModeSet = smAll; const AnName: String = '');
  end;

var
  dlgViewProperty2: TdlgViewProperty2;

implementation

uses gd_SetDataBase, rp_report_const, rp_frmParamLineSE_unit, SysUtils
  {gd_ClassList{, evt_Base}{prp_MainTestForm_unit};
{$R *.DFM}


{ TdlgViewProperty2 }

function TdlgViewProperty2.AddMethodItem(AnMethod: TMethodItem;  const AnParentNode: TTreeNode): TTreeNode;
begin
    Result := tvClasses.Items.AddChild(AnParentNode, AnMethod.Name);
    Result.ImageIndex := 3;
    Result.SelectedIndex := Result.ImageIndex;
    Result.Data := AnMethod;
end;

function TdlgViewProperty2.AddClassItem(const AnClassMethods: TgdcClassMethods;
 const AnParentNode: TTreeNode; gdcCLIndex: Integer): TTreeNode;
var
  TheClass, TheParentClass: TMethodClass;
  TheMethod: TMethodItem;
  PrntMethName: String;
  I: Integer;
begin
    Result := tvClasses.Items.AddChild(AnParentNode, AnClassMethods.gdcClass.ClassName);
    Result.ImageIndex := 0;
    Result.SelectedIndex := Result.ImageIndex;
    TheClass := LocMethodControl.MethodClassList.FindClass2(AnClassMethods.gdcClass.ClassName,
     LocMethodControl.MethodClassList.InitCount - 1);
    if TheClass = nil then
    begin
      LocMethodControl.MethodClassList.AddClass(0, AnClassMethods.gdcClass.ClassName, AnClassMethods.gdcClass);
      TheClass := LocMethodControl.MethodClassList.Last;
    end;
    Result.Data := TheClass;

  // Adding own methods
  for I := 0 to AnClassMethods.gdcMethods.Count - 1 do
  begin
    TheMethod := TheClass.MethodList.Find(AnClassMethods.gdcMethods.Methods[I].Name);
    if TheMethod = nil then // if not exist in DB but registered
    begin
      TheClass.MethodList.Add(AnClassMethods.gdcMethods.Methods[I].Name, 0);
      TheMethod := TheClass.MethodList.Last;
      TheMethod.MethodClass := TheClass;
    end
    else
    //rev?
      TheMethod.Name := AnClassMethods.gdcMethods.Methods[I].Name;  {case correct as while registering}

    TheMethod.MethodData := @AnClassMethods.gdcMethods.Methods[I].ParamsData;
    AddMethodItem(TheMethod, Result);
  end;

   // Adding inherited methods
  if Assigned(AnParentNode) then
  begin
    TheParentClass := TMethodClass(AnParentNode.Data);

    for I := 0 to TheParentClass.MethodList.Count - 1 do
    begin
      PrntMethName := TheParentClass.MethodList.Name[I];
      if AnClassMethods.gdcMethods.MethodByName(PrntMethName) = nil then //if not reg-d in curr. class
      begin
        TheMethod := TheClass.MethodList.Find(PrntMethName);
        if TheMethod = nil then // if not exists in MethodList
        begin
          TheClass.MethodList.Add(PrntMethName, 0);
          TheMethod := TheClass.MethodList.Last;
          TheMethod.MethodClass := TheClass;
        end;
        TheMethod.MethodData := TheParentClass.MethodList.Items[I].MethodData;
        AddMethodItem(TheMethod, Result);
      end;
    end;
  end;

end;

procedure TdlgViewProperty2.Execute(const AnComponent: TComponent;
 const AnShowMode: TShowModeSet = smAll; const AnName: String = '');
var
  I, J, K: Integer;
  TreeList, CountList: TList;
  LocClassList: TgdcClassInfoList;
  TempClass: TClass;
  LEventObject: TEventObject;
  LEventList: TEventObjectList;

  function GetObject(const LComponent: TComponent; const LClassName: String): TComponent;
  var
    L: Integer;
  begin
    if UpperCase(LComponent.ClassName) = UpperCase(LClassName) then
    begin
      Result := LComponent;
      Exit;
    end;
    Result := nil;
    for L := 0 to LComponent.ComponentCount - 1 do
    begin
      Result := GetObject(LComponent.Components[L], LClassName);
      if Result <> nil then
        Break;
    end;
  end;

  function InheritsFromCount(AnMainClass, AnParentClass: TClass): Integer;
  asm
        { ->    EAX     Pointer to our class    }
        {       EDX     Pointer to AClass               }
        { <-    EAX      Boolean result          }
        PUSH    EBX
        MOV     EBX, 0
        JMP     @@haveVMT
@@loop:
        MOV     EAX,[EAX]
@@haveVMT:
        CMP     EAX,EDX
        JE      @@success
        INC     EBX
        MOV     EAX,[EAX].vmtParent
        TEST    EAX,EAX
        JNE     @@loop
        MOV     EAX, -1
        JMP     @@exit
@@success:
        MOV     EAX, EBX
@@exit:
        POP     EBX
  end;

  procedure AddClass(const AnIndex: Integer);
  var
    TempPC: TComponentClass;
    TempComp: TComponent;
    ObjCreated: Boolean;
    LTreeNode: TTreeNode;
    TempRC: TgdcClassMethods;
  begin
    if Integer(CountList.Items[AnIndex]) < -1 then
      Exit;

    ObjCreated := False;
    TempComp := nil;
    try
      try
        //TempPC := TComponentClass(LocClassList.Items[AnIndex]);
        TempRC := LocClassList.gdcItems[AnIndex];

{        if (TempPC <> nil) and TempPC.InheritsFrom(TComponent) then
        begin
          TempComp := GetObject(Application, TempPC.ClassName);
          ObjCreated := TempComp = nil;
          if ObjCreated then
          begin
            TempPC := TComponentClass(TempPC);
            TempComp := TempPC.Create(nil);
          end;
        end;}

        LTreeNode := nil;
        if Integer(CountList.Items[AnIndex]) >= 0 then
        begin
          AddClass(Integer(CountList.Items[AnIndex]));
          LTreeNode := TreeList.Items[Integer(CountList.Items[AnIndex])];
        end;
        // oleg_m
        TreeList.Items[AnIndex] := AddClassItem(TempRC, LTreeNode, AnIndex);
        CountList.Items[AnIndex] := Pointer(-2);
      except
        // Существуют компоненты которые нельзя создавать два раза
      end;
    finally
      if ObjCreated then
        FreeAndNil(TempComp)
      else
        TempComp := nil;
    end;
  end;
begin
  tvClasses.Items.BeginUpdate;//oleg_m
  try

    FRootShowName := AnName;
    FRootObject := AnComponent;
    if smEvent in AnShowMode then
    begin

      if not Assigned(gdcClassList) then
        Exit;

      if AnComponent = Application then
        LocClassList := gdcClassList
      else
      begin
        LocClassList := TgdcClassInfoList.Create;
        TempClass := AnComponent.ClassType;
        while TempClass <> nil do
        begin
          I := gdcClassList.IndexOf(TComponentClass(TempClass));
          if I > -1 then
            LocClassList.Insert(0, gdcClassList.Items[I]);
          TempClass := TempClass.ClassParent;
        end;
      end;

      try
        TreeList := TList.Create;
        try
          CountList := TList.Create;
          try
            for I := 0 to LocClassList.Count - 1 do
            begin
              CountList.Add(Pointer(-1));
              TreeList.Add(Pointer($FFFF));
            end;

            for I := 0 to LocClassList.Count - 1 do
              for J := 0 to LocClassList.Count - 1 do
              begin
                K := InheritsFromCount(LocClassList.Items[I], LocClassList.Items[J]);
                if (K > 0) then
                  if (Integer(TreeList.Items[I]) > K) and (Integer(CountList.Items[I]) <> J) then
                  begin
      //              CountList.Items[J] := CountList.Items[I];
                    CountList.Items[I] := Pointer(J);
                    TreeList.Items[I] := Pointer(K);
                  end;
              end;

            Assert((LocClassList.Count = TreeList.Count) and
             (TreeList.Count = CountList.Count));

            for I := 0 to LocClassList.Count - 1 do
            begin
              AddClass(I);
            end;

          finally
            CountList.Free;
          end;
        finally
          TreeList.Free;
        end;
      finally
        if LocClassList <> gdcClassList then
          LocClassList.Free;
      end;
    end;

    if smEvent in AnShowMode then
    begin
      if AnComponent = Application then
        for I := 0 to AnComponent.ComponentCount - 1 do
          AddEventItem(AnComponent.Components[I], nil, False, GetEventControl.EventObjectList)
      else
      begin
        LEventObject := GetEventControl.EventObjectList.FindAllObject(AnComponent);
        if Assigned(LEventObject) then
          LEventList := LEventObject.ParentList
        else
          LEventList := nil;
        AddEventItem(AnComponent, nil, False, LEventList);
      end;
    end;

  finally//oleg_m
    tvClasses.Items.EndUpdate;
  end;
  ShowModal;

end;

procedure TdlgViewProperty2.tvClassesChange(Sender: TObject;
  Node: TTreeNode);
begin
  DisableControls;
  StartTrans;
  try
    if GetSelectedNodeType = fpNone then
      Exit;

    if ibqrySetFunction.Active then
      ibqrySetFunction.Close;

    ibqrySetFunction.Close;

    if GetSelectedNodeType = fpMethod then
    begin
      ibqrySetFunction.Params[0].AsString := scrMethodModuleName;
      ibqrySetFunction.Params[1].AsInteger := GetObjectId(tvClasses.Selected);
      ibqrySetFunction.Open;
      dblcbSetFunction.KeyValue := TMethodItem(tvClasses.Selected.Data).FunctionKey;

      LoadFunction(scrMethodModuleName, TMethodItem(tvClasses.Selected.Data).FunctionKey,
       TMethodItem(tvClasses.Selected.Data).AutoFunctionName, TMethodItem(tvClasses.Selected.Data).ComplexParams[fplVBScript]);

    end
    else
      inherited tvClassesChange(Sender, Node);
  finally
    EnableControls;
    ChangePageVisible;
  end;
end;

function TdlgViewProperty2.GetObjectId(ANode: TTreeNode): Integer;
begin
  Assert(Assigned(ANode) and Assigned(ANode.Data) and
  Assigned(ANode.Parent.Data), MSG_ERROR);

  if (TObject(ANode.Data) is TMethodItem) and Assigned(ANode.Parent.Data) then
  begin
    Result := TMethodClass(ANode.Parent.Data).ClassKey;
    if Result = 0 then
    begin
      FindClass(ANode.Parent);
      Result := TEventObject(ANode.Parent.Data).ObjectKey;
    end;
  end
  else
    Result := inherited GetObjectId(ANode);
end;

function TdlgViewProperty2.OverallCommit: Boolean;
var
  LFunctionKey: Integer;
begin
  Result := True;
  if GetSelectedNodeType = fpMethod then
  begin
    FindClass(tvClasses.Selected.Parent);

    LFunctionKey := (TObject(tvClasses.Selected.Data) as TMethodItem).FunctionKey;
    Result := PostFunction(LFunctionKey);
    if Result then
      (TObject(tvClasses.Selected.Data) as TMethodItem).FunctionKey := LFunctionKey;
    if Result then
      Result := Result and (tvClasses.Selected.Parent <> nil);

    if Result then
      Result := Result and SaveMethod(tvClasses.Selected.Parent, tvClasses.Selected);
  end;

  if Result then
    Result := CommitTrans
  else
    ibtrFunction.RollbackRetaining;

  FChanged := not Result;

end;

procedure TdlgViewProperty2.OverallRollback;
begin
  if GetSelectedNodeType = fpMethod then
    CancelFunction;
  inherited OverallRollback;
end;

procedure TdlgViewProperty2.actFuncCommitExecute(Sender: TObject);
begin
  if OverallCommit then
    tvClassesChange(tvClasses, tvClasses.Selected);
end;

procedure TdlgViewProperty2.actFuncRollbackExecute(Sender: TObject);
begin
  OverallRollback;
  tvClassesChange(tvClasses, tvClasses.Selected);
end;

procedure TdlgViewProperty2.dblcbSetFunctionClick(Sender: TObject);
var
  LAllowChange: Boolean;
begin
//  FFunctionChanged := FChanged;
  tvClassesChanging(tvClasses, tvClasses.Selected, LAllowChange);
  if LAllowChange then
  begin
    (TObject(tvClasses.Selected.Data) as TCustomFunctionItem).FunctionKey :=
     dblcbSetFunction.KeyValue;
    tvClassesChange(tvClasses, tvClasses.Selected);
    FFunctionChanged :=True;
  end else
    dblcbSetFunction.KeyValue :=
     (TObject(tvClasses.Selected.Data) as TCustomFunctionItem).FunctionKey;
end;

procedure TdlgViewProperty2.dblcbSetFunctionKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_DELETE then
  begin
    dblcbSetFunction.KeyValue := 0;
    dblcbSetFunctionClick(dblcbSetFunction);
  end;
end;

function TdlgViewProperty2.SaveMethod(const AnClassNode: TTreeNode;
  const AnMethodNode: TTreeNode): Boolean;
var
  LibsqlCheck: TIBSQL;
begin
  Result := False;
  try
    LibsqlCheck := TIBSQL.Create(nil);
    try
      LibsqlCheck.Database := ibsqlInsertEvent.Database;
      LibsqlCheck.Transaction := ibsqlInsertEvent.Transaction;
      LibsqlCheck.SQL.Text := 'SELECT * FROM evt_objectevent WHERE objectkey = ' +
       ' :objectkey AND eventname = :eventname';
      LibsqlCheck.Params[0].AsInteger :=
       (TObject(AnClassNode.Data) as TMethodClass).ClassKey;
      LibsqlCheck.Params[1].AsString :=
       AnsiUpperCase((TObject(AnMethodNode.Data) as TMethodItem).Name);
      LibsqlCheck.ExecQuery;
      if not LibsqlCheck.Eof then
      begin
        Result := LibsqlCheck.FieldByName('functionkey').AsInteger =
         (TObject(AnMethodNode.Data) as TMethodItem).FunctionKey;
        if not Result then
        begin
          LibsqlCheck.Close;
          LibsqlCheck.SQL.Text := 'DELETE FROM evt_objectevent WHERE objectkey = ' +
           ' :objectkey AND eventname = :eventname';
          LibsqlCheck.Params[0].AsInteger :=
           (TObject(AnClassNode.Data) as TMethodClass).ClassKey;
          LibsqlCheck.Params[1].AsString :=
           AnsiUpperCase((TObject(AnMethodNode.Data) as TMethodItem).Name);
          LibsqlCheck.ExecQuery;
        end else
          Exit;
      end;
    finally
      LibsqlCheck.Free;
    end;

    if (TObject(AnMethodNode.Data) as TMethodItem).FunctionKey <> 0 then
    begin
      ibsqlInsertEvent.Close;
      ibsqlInsertEvent.ParamByName('objectkey').AsInteger :=
       (TObject(AnClassNode.Data) as TMethodClass).ClassKey;
      ibsqlInsertEvent.ParamByName('functionkey').AsInteger :=
       (TObject(AnMethodNode.Data) as TMethodItem).FunctionKey;
      ibsqlInsertEvent.ParamByName('eventname').AsString :=
       AnsiUpperCase((TObject(AnMethodNode.Data) as TMethodItem).Name);
      ibsqlInsertEvent.ParamByName('afull').AsInteger := -1;
      ibsqlInsertEvent.ExecQuery;
      ibsqlInsertEvent.Close;
    end;
    Result := True;
  except
    on E: Exception do
      MessageBox(Handle, PChar(MSG_ERROR_SAVE_EVENT + E.Message),
       MSG_ERROR, MB_OK or MB_ICONERROR);
  end;
end;

procedure TdlgViewProperty2.AddClass(const AnMethodClass: TMethodClass; const AnParent: Variant;
 const AnObjectType: Integer = 1);
begin
  try
    AnMethodClass.ClassKey := GetUniqueKey(ibtrFunction.DefaultDatabase,
     ibtrFunction);
    gdcObject.SubSet := 'ByID';
    gdcObject.ID := -1;
    gdcObject.Open;
    gdcObject.Insert;
    gdcObject.FieldByName('id').AsInteger := AnMethodClass.ClassKey;
    gdcObject.FieldByName('name').AsString := AnMethodClass.Class_Name;
    SetVar2Field(gdcObject.FieldByName('parent'), AnParent);
    gdcObject.FieldByName('objecttype').AsInteger := AnObjectType;
    gdcObject.FieldByName('afull').AsInteger := -1;
    gdcObject.FieldByName('achag').AsInteger := -1;
    gdcObject.FieldByName('aview').AsInteger := -1;
    gdcObject.FieldByName('lb').Required := False;
    gdcObject.FieldByName('rb').Required := False;
    gdcObject.Post;
  except
    on E: Exception do
      MessageBox(Handle, PChar(MSG_ERROR_CREATE_OBJECT +
       E.Message), MSG_ERROR, MB_OK or MB_ICONERROR);
  end;
end;

function TdlgViewProperty2.FindClass(const AnTreeNode: TTreeNode;
 const AnIsCreate: Boolean = True): Boolean;
var
  TopParentKey: Variant;
begin
  TopParentKey := NULL;
  try
    if (TObject(AnTreeNode.Data) as TMethodClass).ClassKey <> 0 then
    begin
      Result := True;
      Exit;
    end;

    if AnTreeNode.Parent <> nil then
    begin
      Result := FindClass(AnTreeNode.Parent, AnIsCreate);
      TopParentKey := TMethodClass(AnTreeNode.Parent.Data).ClassKey;
    end else
    begin

        AddClass(TMethodClass(AnTreeNode.Data), NULL);{needs tst}
      Result := (TObject(AnTreeNode.Data) as TMethodClass).ClassKey <> 0;
      Exit;
    end;

    if Result then
      {Result := }AddClass(TMethodClass(AnTreeNode.Data), TopParentKey);
  except
    on E: Exception do
    begin
      MessageBox(Handle, PChar(MSG_ERROR_FIND_OBJECT + E.Message),
       MSG_ERROR, MB_OK or MB_ICONERROR);
      Result := False;
    end;
  end;
end;

function TdlgViewProperty2.GetMethodControl: TMethodControl;
begin
  Result := nil;
  if Assigned(MethodControl) then
    Result := MethodControl.Get_Self as TMethodControl;
end;

end.
