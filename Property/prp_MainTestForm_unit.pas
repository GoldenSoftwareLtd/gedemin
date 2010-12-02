unit prp_MainTestForm_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OleCtrls, MSScriptControl_TLB, rp_ReportScriptControl, StdCtrls,
  prp_i_MethodsList, Menus, flt_sqlFilter, Db, IBCustomDataSet, evt_Base, mtd_Base,
  DBClient, IBDatabase, IBQuery, syn_ManagerInterface_body_unit,
  gd_ScriptFactory, gd_security_body, gd_Security, gdcBase, gd_MacrosMenu,
  gd_ReportMenu, ComCtrls, ToolWin, gd_createable_form, gd_ClassList,
  ActiveX, obj_WrapperDelphiClasses, rp_report_const,
  obj_WrapperGSClasses;

type
  TUserProc = procedure(a, b, c: Integer) of object;
  TUserFunc = function(var a: Integer; const b: Integer; out c: Integer; Sender: TObject): Boolean of object;
  TTestMethod = procedure (var I, J: Integer; Sender: TObject; var G: String); stdcall;
  TTempMethod = procedure(const AiMethodsList, AiEventsList: IMethodsList);

type
  TMainTestForm = class(TCreateableForm, IgsTypeInfo)
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
    IBDatabase2: TIBDatabase;
    IBTransaction1: TIBTransaction;
    ComboBox1: TComboBox;
    Button11: TButton;
    Button12: TButton;
    Button13: TButton;
    Button14: TButton;
    Button15: TButton;
    ComboBox2: TComboBox;
    Button16: TButton;
    Button19: TButton;
    Button20: TButton;
    Button21: TButton;
    Button22: TButton;
    CoolBar1: TCoolBar;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    Button17: TButton;
    gdMacrosMenu1: TgdMacrosMenu;
    Button18: TButton;
    Button23: TButton;
    Button24: TButton;
    Button25: TButton;
    Button26: TButton;
    Button27: TButton;
    Button28: TButton;
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
    procedure Button21Click(Sender: TObject);
    procedure Button22Click(Sender: TObject);
    procedure Button17Click(Sender: TObject);
    procedure Button18Click(Sender: TObject);
    procedure Button24Click(Sender: TObject);
    procedure Button26Click(Sender: TObject);
    procedure Button27Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Button28Click(Sender: TObject);
  private
    FUserEvent: TUserProc;
    FTestProp: Integer;
    FEventControl: TEventControl;
    FMethodControl: TMethodControl;
 //   FFunctionList: TgsFunctionList;
//    FInheritedObject: TInheritedEvent;

    function GetIBDatabase: TIBDatabase;
  protected
    procedure ReplaceEvent(a, b, c: Variant);
    property IBDatabase1: TIBDatabase read GetIBDatabase;
  public
    FMP1, FMP2: Pointer;
    procedure Show(Par1, Par2: Real);
    procedure Hide(Par1, Par2: String);
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
  Tfff = class(TComponent)
  private
//    FExecInMacros: TExecInMacros;
    FUserEvent: TUserProc;
    FUserEvent2: TUserFunc;
    FTestProp: Integer;
    FPopupMenu: TPopupMenu;
//    FInheritedObject: TInheritedEvent;
    FInheritedExec: Boolean;
    FLastCallClass: TStringList;

    procedure OnInvoker(const Name: WideString; AnParams: OleVariant);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    class procedure RegisterClass;

    procedure ShowMenu;
    function Method1(var a: integer; b: integer): integer; virtual;
    property PopupMenu: TPopupMenu read FPopupMenu write FPopupMenu;
//    property ExecInMacros: TExecInMacros read FExecInMacros write FExecInMacros;
    property LastCallClass: TStringList read FLastCallClass write FLastCallClass;
  published
    property UserEvent: TUserProc read FUserEvent write FUserEvent;
    property UserEvent2: TUserFunc read FUserEvent2 write FUserEvent2;
//    property PopupMenu: TPopupMenu read FPopupMenu write FPopupMenu;
    property TestProp: Integer read FTestProp write FTestProp;

  end;

  Tfff2 = class(Tfff)
  public
    procedure ShowMenu;
  end;

  Tfff3 = class(Tfff2)
  public
    procedure ShowMenu;
  end;

  Tfff4 = class(Tfff3)
  public
    function Method1(var a: integer; b: integer): integer; override;
  end;

  Tfff5 = class(Tfff4)
  public
    procedure ShowMenu;
  end;

var
  MainTestForm: TMainTestForm;
  MainTestForm2: TMainTestForm;
  fff: Tfff;
  fff2: Tfff2;
  fff5: Tfff5;
  FMethodPointer: Pointer;
  //oleg_m
  Param1, Param2: TgdcMethodParam;
  Method: TgdcMethod;

implementation

uses
  tst_BaseClass, tst_TwoClass, rp_BaseReport_unit, {obj_BaseClass, obj_TwoClass,}
  Provider, TypInfo, DsgnIntf, prp_dlgViewProperty_unit,
  gd_SetDatabase, evt_i_Base, mtd_i_Base, prp_TestForm2_unit,
  gdcMacros, gdcOLEClassList, mtd_i_Inherited, 
  gd_i_ScriptFactory, gd_security_operationconst,
  dmClientReport_unit, dmDatabase_unit;

{$R *.DFM}

type
  TCrackerFunction = class(TrpCustomFunction);

procedure TMainTestForm.ReportScript1CreateObject(Sender: TObject);
begin
//  ReportScript1.AddObject('objBaseClass', ToleBaseClass.Create, False);
//  ReportScript1.AddObject('TwoClass', TTwoClass.Create, False);
//  ReportScript1.AddObject('objTwoClass', ToleTwoClass.Create, False);
end;

procedure TMainTestForm.Button1Click(Sender: TObject);
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

procedure TMainTestForm.FormCreate(Sender: TObject);
var
  MP: TMethod;
begin
//  OleInitialize(nil);

//  FInheritedObject := TInheritedEvent.Create(nil);

{  IBLogin.SubSystemKey := GD_SYS_GADMIN;
  if not IBLogin.Login then
  begin
    Application.ShowMainForm := False;
    Application.Terminate;
    exit;
  end;}
//oleg_m
{  FEventControl := TEventControl.Create(Self);
  FFunctionList := TgsFunctionList.Create(Self);
 }
 // oleg _m
  if not Assigned(MethodControl) then
    FMethodControl := TMethodControl.Create(Self)
  else
    FMethodControl := dmClientReport.MethodControl1;

  ReportScript1.Language := 'VBScript';
  MP.Code := Self.MethodAddress('TestProc');
  MP.Data := Self;
  SetMethodProp(Self, 'UserEvent', MP);
  //oleg_m
  IBDatabase1.Connected := True;
  FMethodControl.Database := IBDatabase1;
 // oleg _m
{  IBDatabase1.Connected := True;
  FEventControl.Database := IBDatabase1;
  FFunctionList.Database := IBDatabase1;
}
  EventControl.LoadLists;
  MethodControl.LoadLists;

//  IBQuery1.Open;
//  UserEvent := ReplaceEvent;
  fff := Tfff.Create(Self);
  fff2 := Tfff2.Create(Self);
  fff5 := Tfff5.Create(Self);
end;

procedure TMainTestForm.GetMethodsList(const AiMethodsList,
  AiEventsList: IMethodsList);
begin

end;

procedure TMainTestForm.Button2Click(Sender: TObject);
var
//  TempObj: TObject;
//  TempPPropInfo: PPropInfo;
//  TempTypeInfo: TTypeInfo;
//  TempPTypeData: PTypeData;
  I: Integer;
  PPL: TPropList;
begin
{  TempTypeInfo.Kind := tkClass;
  TempTypeInfo.Name := 'TMainTestForm';}
//  TempPTypeData := GetTypeData(PTypeInfo(TMainTestForm.ClassInfo));
  I := GetPropList(PTypeInfo(TMainTestForm.ClassInfo), [tkMethod], @PPL);
  if I > 0 then
//    TempPTypeData := GetTypeData(PPL[0]^.PropType^);

///  TempPPropInfo := GetPropInfo(Self, Edit1.Text);

//  TempObj := GetObjectProperty(Self, Edit1.Text);
end;

procedure TMainTestForm.Button3Click(Sender: TObject);
//var
//  PE: TCustomModule;
begin
{  PE := TCustomModule.Create(Button1 as IComponent);
  try
    PE.Edit;
  finally
    PE.Free;
  end;}
end;

procedure TMainTestForm.Button4Click(Sender: TObject);
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
      MethodControl.LoadLists;
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
  OleInitialize(nil);

//  FExecInMacros := TExecInMacros.Create;
  FLastCallClass := TStringList.Create;

//  if Assigned(InheritedMethodInvoker) then
//    InheritedMethodInvoker.RegisterMethodInvoker(Self, OnInvoker);
end;

destructor Tfff.Destroy;
begin
  FPopupMenu.Free;

  if Assigned(InheritedMethodInvoker) then
    InheritedMethodInvoker.UnRegisterMethodInvoker(Self);

 // FExecInMacros.Free;
  FLastCallClass.Free;

  inherited Destroy;
end;

procedure TMainTestForm.Button5Click(Sender: TObject);
var
  MP: Pointer;
//  IT: PInterfaceTable;
//  TestPointer: Pointer;
begin
  MP := Self.MethodAddress('TestProc');
//  IT := Self.GetInterfaceTable;
//  TestPointer := Pointer(Integer(Self) + Integer(MP));
  asm
  AND  ESI,$00FFFFFF
  LEA  EDX,[EAX+ESI]
  MOV  EAX,ECX
    call MP
  end;
end;

procedure TMainTestForm.TestProc(Sender, hh: Variant);
begin

end;

procedure TMainTestForm.Button6Click(Sender: TObject);
var
  I: Integer;
  TempStr: String;
begin
  FMethodPointer := Self.MethodAddress('Test');
  I := 1;
  EmptyTest(I, I, Self, TempStr);
//  Test(I, I, Self, TempStr);
end;

procedure TMainTestForm.Test(var I, J: Integer; Sender: TObject; var G: String);
begin
  I := I + J;
  (Sender as TForm).Visible := True;
end;

procedure TMainTestForm.ReplaceEvent(a, b, c: Variant);
begin

end;

procedure TMainTestForm.Button7Click(Sender: TObject);
begin
  if Assigned(FUserEvent) then
    FUserEvent(1, 2, 3);
end;

procedure TMainTestForm.Button8Click(Sender: TObject);
var
  F: TEventControl;
begin
  F := TEventControl.Create(nil);
  try
  finally
    F.Free;
  end;
end;

procedure TMainTestForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FEventControl);
end;

procedure TMainTestForm.Button9Click(Sender: TObject);
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

procedure TMainTestForm.Button10Click(Sender: TObject);
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

procedure TMainTestForm.Button11Click(Sender: TObject);
begin
  if Assigned(EventControl) then
    EventControl.EditObject(Application);
end;

procedure TMainTestForm.EmptyTest(var I, J: Integer; Sender: TObject;
  var G: String);
{var
  FMP1: Pointer;}
//begin
//  FMP := Self.MethodAddress('Test');}
asm
  mov ecx, [ebp + $04]
  mov MainTestForm.FMP1, ecx
  mov ecx, [ebp + $0]
  mov MainTestForm.FMP2, ecx
  pop ebp
  pop ecx
  call FMethodPointer
  jmp MainTestForm.FMP1
{  mov ecx, MainTestForm.FMP1
  push ecx
  mov ecx, MainTestForm.FMP2
  push ecx}
end;
//end;

procedure TMainTestForm.Button12Click(Sender: TObject);
begin
  Windows.Beep(3000, 300);
  Windows.Beep(2000, 300);
  Windows.Beep(3000, 300);
end;

procedure TMainTestForm.Button13Click(Sender: TObject);
begin
  EventControl.SetEvents(fff);
end;

procedure TMainTestForm.Button14Click(Sender: TObject);
begin
  fff.PopupMenu.Popup(10, 10);
end;

procedure TMainTestForm.Button15Click(Sender: TObject);
var
  L: TEventItem;
  TempPPropInfo: PPropInfo;
//  TempPTypeData: PTypeData;
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

procedure TMainTestForm.Button16Click(Sender: TObject);
begin
  with TTestForm2.Create(Application) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMainTestForm.Button21Click(Sender: TObject);
var
  TempFunc: TrpCustomFunction;
  TempVar: Variant;
begin
  TempFunc := TrpCustomFunction.Create;
  try
    TCrackerFunction(TempFunc).FLanguage := 'VBScript';
    TCrackerFunction(TempFunc).FName := 'Test';
    TCrackerFunction(TempFunc).FModule := 'REPORTMAIN';
    TempFunc.Script.Text := Memo1.Text;
    TempVar := VarArrayOf([]);
    ScriptFactory.ExecuteFunction(TempFunc, TempVar);
  finally
    TempFunc.Free;
  end;
end;

procedure TMainTestForm.Button22Click(Sender: TObject);
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

function TMainTestForm.GetIBDatabase: TIBDatabase;
begin
  Result := dmDatabase.ibdbGAdmin;
end;

procedure TMainTestForm.Button17Click(Sender: TObject);
var
  F: TdlgViewProperty;
begin
  F := TdlgViewProperty.Create(nil);
  try
    SetDatabase(F, IBDatabase1);
    F.Execute(Self);
    EventControl.LoadLists;
  finally
    F.Free;
  end;
end;

procedure TMainTestForm.Button18Click(Sender: TObject);
var
  F: TdlgViewProperty;
  key: Integer;
begin
  F := TdlgViewProperty.Create(nil);
  try
    SetDatabase(F, IBDatabase1);
    Key := 153026537;
    F.EditScriptFunction(key, scrMacrosModuleName, true, 1);
    EventControl.LoadLists;
  finally
    F.Free;
  end;
end;

procedure TMainTestForm.Button24Click(Sender: TObject);
begin
  Show(1.2, 2.3);
  Hide('ABC', 'DEF');
end;

procedure TMainTestForm.Hide(Par1, Par2: String);
var
  Params, result: Variant;
  CurrClass: TClass;
begin
  CurrClass := Self.ClassType;
  repeat
    Params := VarArrayOf([Par1, Par2]);
//    MethodControl.ExecuteMethod(CurrClass.ClassName, 'Hide', Params, Result);
    CurrClass := CurrClass.ClassParent;
  until CurrClass = nil;
end;

procedure TMainTestForm.Show(Par1, Par2: Real);
var
  Params, result: Variant;
  CurrClass: TClass;
begin
  CurrClass := Self.ClassType;
  repeat
    Params := VarArrayOf([Par1, Par2]);
 //   MethodControl.ExecuteMethod(CurrClass.ClassName, 'Show', Params, result);
    CurrClass := CurrClass.ClassParent;
  until CurrClass = nil;
end;

function Tfff.Method1(var a: integer; b: integer): integer;
var
  Params, LResult: Variant;
begin
end;

procedure Tfff.OnInvoker(const Name: WideString; AnParams: OleVariant);
var
  A, B: Integer;
begin
  FInheritedExec := True;
  if Name = 'Method1' then
  begin
    A := AnParams[1];
    B := AnParams[2];
    Method1(A , B);
    AnParams[1] := A;
    AnParams[2] := B;
  end;
  FInheritedExec := False;
end;

class procedure Tfff.RegisterClass;
begin
  RegisterGdcClass(Tfff);
  RegisterClassMethod(Tfff, 'ShowMenu', 'Sender: TObject', '');
  RegisterClassMethod(Tfff, 'Method1', 'Sender: TObject; var a: integer; var b: integer', 'integer');
end;

procedure Tfff.ShowMenu;
var
  Params, LResult: Variant;
begin
  Params := VarArrayOf([]);
//  if not MethodControl.ExecuteMethod(Self.ClassName, 'ShowMenu', Params, LResult) then
    if Assigned(FPopupMenu) then
      FPopupMenu.Popup(10, 10);
end;

procedure TMainTestForm.Button26Click(Sender: TObject);
var
  a, b: integer;
begin
  a := 987;
  b := 786;
  fff.Method1(a, b);
end;

procedure TMainTestForm.Button27Click(Sender: TObject);
var
  a, b : integer;
begin
  a := 987;
  b := 453;
  fff2.Method1(a, b);
end;

{ Tfff2 }

procedure Tfff2.ShowMenu;
begin
  if Assigned(FPopupMenu) then
      FPopupMenu.Popup(10, 10);
  inherited ShowMenu;
end;

procedure TMainTestForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  ReportScript1.Reset;

//  FInheritedObject.Free;

//  OleUninitialize;
end;

procedure TMainTestForm.Button28Click(Sender: TObject);
var
  a, b: Integer;
begin
  a := 1;
  b := 4;
  fff5.Method1(a, b);
end;

{ Tfff5 }

procedure Tfff5.ShowMenu;
begin

end;

{ Tfff4 }

function Tfff4.Method1(var a: integer; b: integer): integer;
var
  Params, LResult: Variant;
begin
end;

{ Tfff3 }

procedure Tfff3.ShowMenu;
begin

end;

initialization
  RegisterGdcClass(TMainTestForm);
  Tfff.RegisterClass;
  RegisterGdcClass(Tfff4);
  RegisterGdcClass(Tfff3);
  RegisterGdcClass(Tfff2);
  RegisterGdcClass(Tfff5);

  //oleg_m
  Param1 := TgdcMethodParam.Create('Param1', 'Real', pfConst);
  try
    Param2 := TgdcMethodParam.Create('Param2', 'Real', pfConst);
    try
      Method := TgdcMethod.Create('Show', mkProcedure);
      try
        Method.AddParam(Param1);
        Method.AddParam(Param2);

        RegisterGdcClassMethod(TMainTestForm, Method);
      finally
        Method.Free;
      end;
    finally
      Param2.Free;
    end;
  finally
    Param1.Free;
  end;

  Param1 := TgdcMethodParam.Create('Param1', 'String', pfConst);
  try
    Param2 := TgdcMethodParam.Create('Param2', 'String', pfConst);
    try
      Method := TgdcMethod.Create('Hide', mkProcedure);
      try
        Method.AddParam(Param1);
        Method.AddParam(Param2);

        RegisterGdcClassMethod(TMainTestForm, Method);
      finally
        Method.Free;
      end;
    finally
      Param2.Free;
    end;
  finally
    Param1.Free;
  end;

  Method := TgdcMethod.Create('Post', mkProcedure);
  try
    RegisterGdcClassMethod(TgdcBase, Method);
  finally
    Method.Free;
  end;

finalization
//  RegisterGDCClasses();

end.

