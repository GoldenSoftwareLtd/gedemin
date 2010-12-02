unit prp_MainTestForm_unit2;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OleCtrls, MSScriptControl_TLB, rp_ReportScriptControl, StdCtrls,
  prp_i_MethodsList, Menus, flt_sqlFilter, Db, IBCustomDataSet, evt_Base,
  DBClient, IBDatabase, IBQuery, syn_ManagerInterface_body_unit, scrMacrosGroup,
  gd_ScriptFactory, gd_security_body, gd_Security, gdcBase, ExtCtrls,
  Grids, DBGrids, gsDBGrid, gsIBGrid, gsIBCtrlGrid, rp_msgErrorReport_unit,
  obj_WrapperGSClasses, Gedemin_TLB, gdcOLEClassList, gd_ClassList,
  TB2Dock, TB2Toolbar, gsIBLookupComboBox, xDateEdits, Mask, evt_InheritedEvent,
  ActiveX;

type
  TUserProc = procedure(a, b, c: Integer) of object;
  TUserFunc = function(var a: Integer; const b: Integer; out c: Integer; Sender: TObject): Boolean of object;
  TTestMethod = procedure (var I, J: Integer; Sender: TObject; var G: String); stdcall;
  TTempMethod = procedure(const AiMethodsList, AiEventsList: IMethodsList);

type
  TMainTestForm2 = class(TForm, IgsTypeInfo)
    ReportScript1: TReportScript;
    Button1: TButton;
    Memo1: TMemo;
    Button2: TButton;
    Edit1: TEdit;
    Button3: TButton;
    Button4: TButton;
    PopupMenu1: TPopupMenu;
    N4564561: TMenuItem;
    gsQueryFilter1: TgsQueryFilter;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    Button10: TButton;
    ClientDataSet1: TClientDataSet;
    ClientDataSet1wqeqwe: TIntegerField;
    ClientDataSet1wqeqweqwe: TStringField;
    IBQuery1: TIBQuery;
    IBDatabase1: TIBDatabase;
    IBTransaction1: TIBTransaction;
    ComboBox1: TComboBox;
    Button11: TButton;
    Button12: TButton;
    Button13: TButton;
    Button14: TButton;
    Button15: TButton;
    ComboBox2: TComboBox;
    gdScriptFactory1: TgdScriptFactory;
    Button16: TButton;
    Button17: TButton;
    Button18: TButton;
    Button19: TButton;
    Button20: TButton;
    Button21: TButton;
    boLogin1: TboLogin;
    SynManager1: TSynManager;
    Button22: TButton;
    gdcBaseManager1: TgdcBaseManager;
    CheckBoxCache: TCheckBox;
    CheckBoxRemote: TCheckBox;
    Panel1: TPanel;
    Button23: TButton;
    Button24: TButton;
    Button25: TButton;
    gsIBCtrlGrid1: TgsIBCtrlGrid;
    DataSource1: TDataSource;
    IBQuery2: TIBQuery;
    Button26: TButton;
    gsIBCtrlGrid2: TgsIBCtrlGrid;
    IBQuery3: TIBQuery;
    DataSource2: TDataSource;
    Button27: TButton;
    Button28: TButton;
    Button29: TButton;
    Button30: TButton;
    Edit2: TEdit;
    TBToolbar1: TTBToolbar;
    Button31: TButton;
    CheckBox1: TCheckBox;
    xDateEdit1: TxDateEdit;
    xDateDBEdit1: TxDateDBEdit;
    procedure ReportScript1CreateObject(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure Button13Click(Sender: TObject);
    procedure Button14Click(Sender: TObject);
    procedure Button15Click(Sender: TObject);
    procedure Button16Click(Sender: TObject);
    procedure Button17Click(Sender: TObject);
    procedure Button18Click(Sender: TObject);
    procedure Button19Click(Sender: TObject);
    procedure Button20Click(Sender: TObject);
    procedure Button21Click(Sender: TObject);
    procedure Button22Click(Sender: TObject);    procedure Button23Click(Sender: TObject);
    procedure Button24Click(Sender: TObject);
    procedure Button25Click(Sender: TObject);
    procedure Button26Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button28Click(Sender: TObject);
    procedure Button27Click(Sender: TObject);
    procedure Button29Click(Sender: TObject);
    procedure Button30Click(Sender: TObject);
    procedure Button31Click(Sender: TObject);
    procedure Button32Click(Sender: TObject);
  private
    FUserEvent: TUserProc;
    FTestProp: Integer;
    FEventControl: TEventControl;
    FFunctionList: TgsFunctionList;
    msgForm: TmsgErrorReport;
    ObjectList: TgdcClassInfoList;
    IObjectList: IgsGDCClassList;
    FInheritedEvent: TEvtInherited;
  protected
    procedure ReplaceEvent(a, b, c: Variant);
  public
    FMP1, FMP2: Pointer;
  published
    procedure GetMethodsList(const AiMethodsList, AiEventsList: IMethodsList);
    procedure EmptyTest(var I, J: Integer; Sender: TObject; var G: String); stdcall;
    procedure Test(var I, J: Integer; Sender: TObject; var G: String); stdcall;
    procedure TestProc(Sender, hh: Variant);
    property TestProp: Integer read FTestProp write FTestProp;
    property UserEvent: TUserProc read FUserEvent write FUserEvent;
//    property TgsQueryFilter1: TgsQueryFilter read gsQueryFilter1;
    property TButton5: TButton read Button5;
    property TButton6: TButton read Button6;
    property TButton7: TButton read Button7;
    property TButton8: TButton read Button8;
  end;

type
//  Tfff = class(TComponent)
  Tfff = class(TCustomEdit)
  private
    FUserEvent: TUserProc;
    FUserEvent2: TUserFunc;
    FTestProp: Integer;
    FPopupMenu: TPopupMenu;
    FEdit: TEdit;
//    FMacros: TgdcMacros;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property PopupMenu: TPopupMenu read FPopupMenu write FPopupMenu;
    property Edit: TEdit read FEdit write FEdit;
//    property Macros: TgdcMacros read
  published
    property UserEvent: TUserProc read FUserEvent write FUserEvent;
    property UserEvent2: TUserFunc read FUserEvent2 write FUserEvent2;
//    property PopupMenu: TPopupMenu read FPopupMenu write FPopupMenu;
    property TestProp: Integer read FTestProp write FTestProp;
  end;

  Tfff2 = class(Tfff);
  Tfff3 = class(Tfff2);
  Tfff4 = class(Tfff3);
  Tfff5 = class(Tfff4);

var
  MainTestForm2: TMainTestForm2;
  fff: Tfff;
  FMethodPointer: Pointer;

implementation

uses
  tst_BaseClass, tst_TwoClass, rp_BaseReport_unit, {obj_BaseClass, obj_TwoClass,}
  Provider, TypInfo, DsgnIntf, prp_dlgViewProperty_unit,
  gd_SetDatabase, evt_i_Base, obj_WrapperDelphiClasses, prp_TestForm2_unit,
  gdcMacros, prp_dlgViewProperty3_unit, prp_dlgViewProperty2_unit,
  gd_i_ScriptFactory, gd_security_operationconst;

{$R *.DFM}

type
  TCrackerFunction = class(TrpCustomFunction);

procedure TMainTestForm2.ReportScript1CreateObject(Sender: TObject);
begin
  ReportScript1.AddObject('BaseClass', TBaseClass.Create, False);
//  ReportScript1.AddObject('objBaseClass', ToleBaseClass.Create, False);
  ReportScript1.AddObject('TwoClass', TTwoClass.Create, False);
//  ReportScript1.AddObject('objTwoClass', ToleTwoClass.Create, False);
  ReportScript1.AddObject('EventInherited', FInheritedEvent.InheritedEvent, False);
end;

procedure TMainTestForm2.Button1Click(Sender: TObject);
var
  TestFunction: TrpCustomFunction;
  TempVar: Variant;
  Res: Variant;
begin
  TestFunction := TrpCustomFunction.Create;
  try
    TempVar := VarArrayOf([]);
    TCrackerFunction(TestFunction).FName := 'Test';
    TCrackerFunction(TestFunction).FLanguage := 'JScript';
    TestFunction.Script.Text := Memo1.Text;
    Res := ReportScript1.ExecuteFunction(TestFunction, TempVar);
  finally
    TestFunction.Free;
  end;
end;

procedure TMainTestForm2.FormCreate(Sender: TObject);
var
  MP: TMethod;
begin
  IBLogin.SubSystemKey := GD_SYS_GADMIN;
  if not IBLogin.Login then
  begin
    Application.ShowMainForm := False;
    Application.Terminate;
    exit;
  end;

  FEventControl := TEventControl.Create(Self);
  FFunctionList := TgsFunctionList.Create(Self);

  ReportScript1.Language := 'VBScript';
  MP.Code := Self.MethodAddress('TestProc');
  MP.Data := Self;
  SetMethodProp(Self, 'UserEvent', MP);

  IBDatabase1.Connected := True;
  FEventControl.Database := IBDatabase1;
  EventControl.LoadLists;
  FFunctionList.Database := IBDatabase1;
  ObjectList := TgdcClassInfoList.Create;
  iObjectList := GetGdcOLEObject(ObjectList) as IgsGDCClassList;//  IBQuery1.Open;

  OleInitialize(nil);
  FInheritedEvent := TEvtInherited.Create(nil, EventControl1);
//  UserEvent := ReplaceEvent;
end;

procedure TMainTestForm2.GetMethodsList(const AiMethodsList,
  AiEventsList: IMethodsList);
begin

end;

procedure TMainTestForm2.Button2Click(Sender: TObject);
var
  TempObj: TObject;
  TempPPropInfo: PPropInfo;
  TempTypeInfo: TTypeInfo;
  TempPTypeData: PTypeData;
  I: Integer;
  PPL: TPropList;
begin
{  TempTypeInfo.Kind := tkClass;
  TempTypeInfo.Name := 'TMainTestForm2';}
  TempPTypeData := GetTypeData(PTypeInfo(TMainTestForm2.ClassInfo));
  I := GetPropList(PTypeInfo(TMainTestForm2.ClassInfo), [tkMethod], @PPL);
  if I > 0 then
    TempPTypeData := GetTypeData(PPL[0]^.PropType^);

  TempPPropInfo := GetPropInfo(Self, Edit1.Text);

  TempObj := GetObjectProperty(Self, Edit1.Text);
end;

procedure TMainTestForm2.Button3Click(Sender: TObject);
var
  PE: TCustomModule;
begin
{  PE := TCustomModule.Create(Button1 as IComponent);
  try
    PE.Edit;
  finally
    PE.Free;
  end;}
end;

procedure TMainTestForm2.Button4Click(Sender: TObject);
var
  F: TdlgViewProperty;
begin
  F := TdlgViewProperty.Create(nil);
  try
    with TTestForm2.Create(Application) do
    try
      SetDatabase(F, IBDatabase1);
      F.Execute(Application);
      EventControl.LoadLists;
    finally
      Free;
    end;
  finally
    F.Free;
  end;
end;

{ Tfff }

constructor Tfff.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FPopupMenu := TPopupMenu.Create(Self);
  FPopupMenu.Name := 'TestPM';

  FEdit := TEdit.Create(Self);
  FEdit.Name := 'TestEdit';
end;

destructor Tfff.Destroy;
begin
  FPopupMenu.Free;
  FEdit.Free;

  inherited Destroy;
end;

procedure TMainTestForm2.Button5Click(Sender: TObject);
var
  MP: Pointer;
  IT: PInterfaceTable;
  TestPointer: Pointer;
begin
  MP := Self.MethodAddress('TestProc');
  IT := Self.GetInterfaceTable;
  TestPointer := Pointer(Integer(Self) + Integer(MP));
  asm
  AND  ESI,$00FFFFFF
  LEA  EDX,[EAX+ESI]
  MOV  EAX,ECX
    call MP
  end;
end;

procedure TMainTestForm2.TestProc(Sender, hh: Variant);
begin

end;

procedure TMainTestForm2.Button6Click(Sender: TObject);
var
  I: Integer;
  TempStr: String;
begin
  FMethodPointer := Self.MethodAddress('Test');
  I := 1;
  EmptyTest(I, I, Self, TempStr);
//  Test(I, I, Self, TempStr);
end;

procedure TMainTestForm2.Test(var I, J: Integer; Sender: TObject; var G: String);
begin
  I := I + J;
  (Sender as TForm).Visible := True;
end;

procedure TMainTestForm2.ReplaceEvent(a, b, c: Variant);
begin

end;

procedure TMainTestForm2.Button7Click(Sender: TObject);
begin
  if Assigned(FUserEvent) then
    FUserEvent(1, 2, 3);
end;

procedure TMainTestForm2.Button8Click(Sender: TObject);
var
  F: TEventControl;
begin
  F := TEventControl.Create(nil);
  try
  finally
    F.Free;
  end;
end;

procedure TMainTestForm2.FormDestroy(Sender: TObject);
begin
  ObjectList.Free;

  FreeAndNil(FEventControl);
end;

procedure TMainTestForm2.Button9Click(Sender: TObject);
var
  MS: TMemoryStream;
  SL: TStrings;
begin
  SL := TStringList.Create;
  try
    SL.AddObject('1', Pointer(123));
    SL.AddObject('123', Pointer(234234));
    MS := TMemoryStream.Create;
    try
      SL.SaveToStream(MS);
      SL.Clear;
      MS.Position := 0;
      SL.LoadFromStream(MS);
    finally
      MS.Free;
    end;
  finally
    SL.Free;
  end;
end;

procedure TMainTestForm2.Button10Click(Sender: TObject);
var
  TempObjectList: TEventObjectList;
  MS: TMemoryStream;

  procedure AddEventObject(AnComp: TComponent; AnEventList: TEventObjectList);
  var
    I: Integer;
  begin
    for I := 0 to AnComp.ComponentCount - 1 do
    begin
      AnEventList.AddObject(nil);
      TEventObject(AnEventList.Last).ObjectName := AnComp.Components[I].Name;
      AddEventObject(AnComp.Components[I], TEventObject(AnEventList.Last).ChildObjects);
    end;
  end;
begin
  TempObjectList := TEventObjectList.Create;
  try
    AddEventObject(Self, TempObjectList);
{    TempObjectList.AddObject(nil);
    TEventObject(TempObjectList.Last).ObjectName := 'Object1';
    TEventObject(TempObjectList.Last).EventList.AddObject('OnCreate', Pointer(1));
    TEventObject(TempObjectList.Last).EventList.AddObject('OnDestroy', Pointer(2));
    TempObjectList.AddObject(nil);
    TEventObject(TempObjectList.Last).ObjectName := 'Object2';
    TEventObject(TempObjectList.Last).EventList.AddObject('OnCreate', Pointer(3));
    TEventObject(TempObjectList.Last).EventList.AddObject('OnDestroy', Pointer(4));}
    MS := TMemoryStream.Create;
    try
      TempObjectList.SaveToStream(MS);
      MS.Position := 0;
      TempObjectList.LoadFromStream(MS);
    finally
      MS.Free;
    end;
  finally
    TempObjectList.Free;
  end;
end;

procedure TMainTestForm2.Button11Click(Sender: TObject);
var
  F: TdlgViewProperty;
begin
  F := TdlgViewProperty.Create(nil);
  try
    SetDatabase(F, IBDatabase1);
    F.Execute(fff);
    EventControl.LoadLists;
  finally
    F.Free;
  end;
end;

procedure TMainTestForm2.EmptyTest(var I, J: Integer; Sender: TObject;
  var G: String);
{var
  FMP1: Pointer;}
//begin
//  FMP := Self.MethodAddress('Test');}
asm
  mov ecx, [ebp + $04]
  mov MainTestForm2.FMP1, ecx
  mov ecx, [ebp + $0]
  mov MainTestForm2.FMP2, ecx
  pop ebp
  pop ecx
  call FMethodPointer
  jmp MainTestForm2.FMP1
{  mov ecx, MainTestForm2.FMP1
  push ecx
  mov ecx, MainTestForm2.FMP2
  push ecx}
end;
//end;

procedure TMainTestForm2.Button12Click(Sender: TObject);
begin
  Windows.Beep(3000, 300);
  Windows.Beep(2000, 300);
  Windows.Beep(3000, 300);
end;

procedure TMainTestForm2.Button13Click(Sender: TObject);
begin
  EventControl.SetEvents(fff);
end;

procedure TMainTestForm2.Button14Click(Sender: TObject);
begin
  fff.PopupMenu.Popup(10, 10);
end;

procedure TMainTestForm2.Button15Click(Sender: TObject);
var
  L: TEventItem;
  TempPPropInfo: PPropInfo;
  TempPTypeData: PTypeData;
begin
  L := TEventItem.Create;
  try
    TempPPropInfo := GetPropInfo(fff, 'UserEvent2');
    L.Name := 'UserEvent';
    L.EventData := GetTypeData(TempPPropInfo^.PropType^);
    case ComboBox2.ItemIndex of
      0: Memo1.Text := L.ComplexParams[fplDelphi];
      1: Memo1.Text := L.ComplexParams[fplVBScript];
      2: Memo1.Text := L.ComplexParams[fplJScript];
    end;
  finally
    L.Free;
  end;
end;

procedure TMainTestForm2.Button16Click(Sender: TObject);
begin
  with TTestForm2.Create(Application) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMainTestForm2.Button17Click(Sender: TObject);
var
  F: TdlgViewProperty3;
begin
  F := TdlgViewProperty3.Create(nil);
  try
    with TTestForm2.Create(Application) do
    try
      SetDatabase(F, IBDatabase1);
      F.Execute(Application);
      EventControl.LoadLists;
    finally
      Free;
    end;
  finally
    F.Free;
  end;
end;

procedure TMainTestForm2.Button18Click(Sender: TObject);
var
  F: TdlgViewProperty3;
begin
  F := TdlgViewProperty3.Create(nil);
  try
    SetDatabase(F, IBDatabase1);
    F.Execute(self);
    EventControl.LoadLists;
  finally
    F.Free;
  end;
end;

procedure TMainTestForm2.Button19Click(Sender: TObject);
var
  F: TdlgViewProperty2;
begin
  F := TdlgViewProperty2.Create(nil);
  try
    with TTestForm2.Create(Application) do
    try
      SetDatabase(F, IBDatabase1);
      F.Execute(Application);
      EventControl.LoadLists;
    finally
      Free;
    end;
  finally
    F.Free;
  end;
end;

procedure TMainTestForm2.Button20Click(Sender: TObject);
var
  F: TdlgViewProperty2;
begin
  F := TdlgViewProperty2.Create(nil);
  try
    SetDatabase(F, IBDatabase1);
    F.Execute(fff);
    EventControl.LoadLists;
  finally
    F.Free;
  end;
end;

procedure TMainTestForm2.Button21Click(Sender: TObject);
var
  TempFunc: TrpCustomFunction;
  TempVar: Variant;
//  Temp: TOnResultReceive;
begin
//  Temp := nil;
  TempFunc := TrpCustomFunction.Create;
  try
    TCrackerFunction(TempFunc).FFunctionKey := 147002004;
    TCrackerFunction(TempFunc).FLanguage := 'VBScript';
    TCrackerFunction(TempFunc).FName := 'Test';
    TCrackerFunction(TempFunc).FModule := 'REPORTMAIN';
    TempFunc.Script.Text := Memo1.Text;
    TempVar := VarArrayOf([]);
    ScriptFactory.InputParams(TempFunc, TempVar);
    ScriptFactory.ExecuteFunction(TempFunc, TempVar);
  finally
    TempFunc.Free;
  end;
end;

procedure TMainTestForm2.Button22Click(Sender: TObject);
var
  SL: TStringList;
begin
  SL := TStringList.Create;
  try
    EventControl.ObjectEventList(Self, SL);
    Memo1.Lines.Assign(SL);
  finally
    SL.Free;
  end;
end;

procedure TMainTestForm2.Button23Click(Sender: TObject);
var
  TempFunc: TrpCustomFunction;
  TempVar: Variant;
 // Temp: TOnResultReceive;
begin
//  Temp := nil;
  TempFunc := TrpCustomFunction.Create;
  try
    TCrackerFunction(TempFunc).FFunctionKey := 147276143;
    TCrackerFunction(TempFunc).FLanguage := 'VBScript';
    TCrackerFunction(TempFunc).FName := 'Test';
    TCrackerFunction(TempFunc).FModule := 'REPORTMAIN';
    TempFunc.Script.Text := Memo1.Text;
    TempVar := VarArrayOf([]);
    ScriptFactory.InputParams(TempFunc, TempVar);
    ScriptFactory.ExecuteFunction(TempFunc, TempVar);
  finally
    TempFunc.Free;
  end;
end;

procedure TMainTestForm2.Button24Click(Sender: TObject);
var
  TempMacros: TscrMacrosItem;
begin
  TempMacros := TscrMacrosItem.Create;
//  TempMacros.FunctionKey := 147276143;
//  TempMacros.IsLocalExecute := not CheckBoxRemote.Checked;
//  TempMacros.ServerKey := 153001760;

  try
    TempMacros.FunctionKey := IBQuery2.FieldByName('FUNCTIONKEY').AsInteger;
    TempMacros.IsLocalExecute := not CheckBoxRemote.Checked;
    TempMacros.ServerKey := IBQuery3.FieldByName('ID').AsInteger;
    ScriptFactory.ExecuteMacros(TempMacros);
  finally
    TempMacros.Free;
  end;
end;

procedure TMainTestForm2.Button25Click(Sender: TObject);
var
  TempMacros: TscrMacrosItem;
begin
  TempMacros := TscrMacrosItem.Create;
  TempMacros.ServerKey := 153001760;
  TempMacros.FunctionKey := 147276143;
  TempMacros.IsLocalExecute := not CheckBoxRemote.Checked;
  ScriptFactory.ExecuteMacros(TempMacros);
  TempMacros.Free;
end;

procedure TMainTestForm2.Button26Click(Sender: TObject);
var
  TempMacros: TscrMacrosItem;
begin
  TempMacros := TscrMacrosItem.Create;
  TempMacros.Free;

  IBQuery3.Open;
  IBQuery2.Open;
end;

procedure TMainTestForm2.FormShow(Sender: TObject);
begin
  Button26Click(Sender);
end;

procedure TMainTestForm2.Button28Click(Sender: TObject);
begin
  IObjectList.AddObject('TgdcMacrosGroup', 'Test2', 'Tfff', nil);
end;

procedure TMainTestForm2.Button27Click(Sender: TObject);
begin
  IObjectList.AddObject('TgdcMacros', 'Test', 'Tfff', nil);
end;

procedure TMainTestForm2.Button29Click(Sender: TObject);
var
  IBase: IgsGDCBase;
begin
  IBase := IObjectList.GetObject('Test2');
  Edit1.Text := IBase.NameInScript;
end;

procedure TMainTestForm2.Button30Click(Sender: TObject);
var
  IBase: IgsGDCBase;
begin
  IBase := IObjectList.GetObject('Test2\8');
  if not Assigned(IBase) then
    Edit1.Text := 'Not found';
  IObjectList.DeleteObject('Test2');

end;

procedure TMainTestForm2.Button31Click(Sender: TObject);
begin
  fff.Edit.Text := Edit1.Text;
end;

procedure TMainTestForm2.Button32Click(Sender: TObject);
var
  LFunction: TrpCustomFunction;
  LVar: Variant;
begin
  LFunction := TrpCustomFunction.Create;
  try
    TCrackerFunction(LFunction).FLanguage := 'VBScript';
    TCrackerFunction(LFunction).Script.Text := Memo1.Text;
    TCrackerFunction(LFunction).FName := 'OnClick';
    LVar := VarArrayOf([GetGdcOLEObject(self) as IDispatch]);
    ReportScript1.ExecuteFunction(LFunction, LVar);
  finally
    LFunction.Free;
  end;
end;

initialization
  RegisterGdcClass(TMainTestForm2);
  RegisterGdcClass(Tfff4);
  RegisterGdcClass(Tfff);
  RegisterGdcClass(Tfff3);
  RegisterGdcClass(Tfff2);
  RegisterGdcClass(Tfff5);

finalization
  UnRegisterGdcClass(TMainTestForm2);
  UnRegisterGdcClass(Tfff4);
  UnRegisterGdcClass(Tfff);
  UnRegisterGdcClass(Tfff3);
  UnRegisterGdcClass(Tfff2);
  UnRegisterGdcClass(Tfff5);

end.

