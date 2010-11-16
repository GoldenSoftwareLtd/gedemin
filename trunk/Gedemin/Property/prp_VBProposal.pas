
{++

  Copyright (c) 2001 by Golden Software of Belarus

  Module

    prp_VBPropasal.pas

  Abstract

    Gedemin project. TVBPropasal.

  Author

    Karpuk Alexander

  Revisions history

    1.00    22.07.02    tiptop        Initial version.
            08.08.02    tiptop        Исправлены некоторые ошибки
--}
unit prp_VBProposal;

interface
uses VBParser, classes,  ActiveX, sysutils, Windows, gd_i_ScriptFactory,
  Gedemin_TLB, prp_i_VBProposal, contnrs;

type
  TVBProposal = class(TVBParser, IVBProposal)
  protected
    FFKObjects: TStrings;
    FOnCreateObject: TNotifyEvent;
    FInsertList: TStrings;
    FItemList: TStrings;
    FDesignators: TStrings;

    FReservedWords: TStrings;
    FReservedDesignators: TStrings;
    FInsertReservedDesignators: TStrings;
    FTypeLib: ITypeLib;
    //Указывает на необходимость определения тип переменной
    FTypeDetermin: Boolean;
    //Интерфейс информации о типе
    FTypeInfo: ITypeInfo;
    FTypeInfoList: TList;
    FIsObject: Boolean;
    FDefaultObjects: TStringList;
    FDefaultTypeInfoList: TList;
    FComponentTypeInfo: ITypeInfo;
    FGedeminApplication: IDispatch;
    FObjectList: TObjectList;

    function GetFKObjects: TStrings;
    function GetInsertList: TStrings;
    function GetItemList: TStrings;
    function GetOnCreateObject: TNotifyEvent;
    function GetReservedDesignators: TStrings;
    function GetReservedWords: TStrings;

    procedure SetFKObjects(const Value: TStrings);
    procedure SetOnCreateObject(const Value: TNotifyEvent);
    function GetObject(ObjectName: string): TObject;
    procedure WorkDesignator; override;
    procedure Statament; override;
    //Обработка простого оператора
    procedure SimpleStatement; override;
    procedure AddDesignator(Designator: String; TypeInfo: ITypeInfo);
    procedure SetObjectType(Name: string; TypeInfo: ITypeInfo);
    function GetWord(Str: String; Position: Integer): String; overload;
    //Разбирает строку и заполняет список определителей
    procedure BreakOnDesignators(Script: string; const DesignatorList: TStrings);
    //заполняет список зарезервированных слов
    procedure FillReservedWords; virtual;
    //заполняет список определителей VB
    procedure FillReservedDesignators;virtual;

    //возвращает интерфейс информации о типе
    //ATypeInfo - итерфейс иформ о типе объекта
    //Name - имя свойства или функции
    function GetTypeInfo(ATypeInfo: ITypeInfo;
      Name: string): ITypeInfo;
    function GetTypeInfoByInterfaceName(Name: string): ITypeInfo;
    procedure CreateObject;
    procedure ClearTypeInfoList;
    function ObjectIndex(Name: String): Integer;
    function DesignatorIndex(Name: String): Integer;
    function ReservedWordsIndex(Name: string): Integer;
    function ReservedDesignatorsIndex(Name: string): Integer;
    procedure GetMembers(TypeInfo: ITypeInfo); overload;
    procedure GetMembers(TypeInfo: ITypeInfo; ItemList: TStrings);overload;
    procedure SetObjectsTypeInfo;
    procedure SetDefaultObjects;
    function IsIDispatchMember(Member: String): Boolean;
    function GetDesignerTypeInfo: ITypeInfo;
    function GetSystemTypeInfo: ITypeInfo;
    procedure FillInsertList(SL: TStrings);

    property ReservedWords: TStrings read GetReservedWords;
    property ReservedDesignators: TStrings read GetReservedDesignators;
    property FKObjects: TStrings read GetFKObjects write SetFKObjects;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure PrepareScript(const ScriptName: String; const Script: TStrings;
      AtLine: Integer = - 1); override;
    procedure AddObject(Name: string; const Object_: IDispatch; AddMembers: Boolean);
    procedure ShowDefaultProposal;
    procedure AddFKObject(Name: String; AObject: TObject);
    procedure ClearFKObjects;

    property ItemList: TStrings read GetItemList;
    property InsertList: TStrings read GetInsertList;
  published
    property OnCreateObject: TNotifyEvent read GetOnCreateObject write SetOnCreateObject;
  end;

  function TrimName(S: String): string;

var
  VBProposalObject: TVBProposal;

implementation

uses
  obj_GedeminApplication, rp_report_const, scrOpenSaveDialog_unit,
  gsWinAPI_unit, gdcOLEClassList, Forms, prp_VBStandart_const;

const
  MaxFuncParams = 64;

type
  _PBStrList = ^_TBStrList;
  _TBStrList = array[0..MaxFuncParams - 1] of TBStr;

const
  IDispatchMembers = ' GETIDSOFNAMES; GETTYPEINFO; GETTYPEINFOCOUNT; INVOKE; ' +
    'QUERYINTERFACE; ADDREF; RELEASE; TAXDATE; CREATEFORM; FINALLYOBJECT; ';

  cObject = #1#240#81#81'object'#2#9;
  cMethod = #1#103#100#238'function'#2#9;
  cProperty = #1#31#189#39'property'#2#9;
  cVar = #1#146#86#126'var'#2#9;
  cConst = #1#149#142#83'const'#2#9;
{ TVBPropasal }

procedure TVBProposal.AddDesignator(Designator: String; TypeInfo: ITypeInfo);
var
  Index: Integer;
//  I: Integer;
begin
  if (ReservedWordsIndex(Designator) > - 1) or
     (ReservedDesignatorsIndex(Designator) > - 1) then
    Exit;

  Index := DesignatorIndex(Designator);
  if Index = - 1 then
  begin
    Index := FDesignators.Add(Designator);
    FDesignators.Objects[Index] := pointer(TypeInfo);
  end;
end;

constructor TVBProposal.Create(AOwner: TComponent);
begin
  if not Assigned(VBProposal) then
  begin
    inherited;

    FDefaultObjects := TStringList.Create;
    FFKObjects := TStringList.Create;
    FTypeInfoList := TList.Create;
    FItemList := TStringList.Create;
    FInsertList := TStringList.Create;
    FDesignators := TStringList.Create;
    FInsertReservedDesignators := TStringList.Create;
    FReservedWords := TStringList.Create;
    FillReservedWords;
    FReservedDesignators := TStringList.Create;
    FillReservedDesignators;
    CreateObject;
    FObjectList := TObjectList.Create;

    VBProposal := Self;
  end else
    raise Exception.Create(
      'Может быть создан только один экземпляр'#10#13 +
      'класса TVBProposal');

  VBProposal := Self;
end;

destructor TVBProposal.Destroy;
begin
  FDefaultObjects.Free;
  FTypeInfoList.Free;
  FItemList.Free;
  FInsertList.Free;
  FDesignators.Free;
  FInsertReservedDesignators.Free;
  FReservedWords.Free;
  FReservedDesignators.Free;
  FFKObjects.Free;
  FObjectList.Free;
  GedeminApplication := nil;

  inherited;
  VBProposal := nil;
end;

function TVBProposal.GetWord(Str: String; Position: Integer): String;
var
  BeginPos, EndPos: Integer;
begin
  BeginPos := Position;
  EndPos := Position;
  if Str <> '' then
  begin
    while (Pos(Str[BeginPos - 1], Letters) > 0) and (BeginPos > 0) do
      Dec(BeginPos);
    while (EndPos <= Length(Str)) and (Pos(Str[EndPos], Letters) > 0) do
      Inc(EndPos);
  end;
  if EndPos > BeginPos then
  begin
//    if EndPos < Length(FStr) then
      Result := System.Copy(Str, BeginPos, EndPos - BeginPos);
//    else
//      Result := System.Copy(FStr, BeginPos, EndPos - BeginPos + 1);
  end else
    Result := '';
end;

function TVBProposal.GetObject(ObjectName: string): TObject;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to FObjects.Count - 1 do
    if FObjects.Strings[I] = ObjectName then
      Result := FObjects.Objects[I];
end;

function StringListSortCompare(List: TStringList; Index1, Index2: Integer): Integer;
var
  S1, S2: string;
begin
  S1 := TrimName(List[Index1]);
  S2 := TrimName(List[Index2]);

  S1 := TrimName(S1);
  S2 := TrimName(S2);
  Result := AnsiCompareText(S1, S2);
end;

procedure TVBProposal.PrepareScript(const ScriptName: String;
  const Script: TStrings; AtLine: Integer = - 1);
var
//  Position: Integer;
//  Designator: Integer;
//  Index: Integer;
//  IObject: IDispatch;
  DesignatorList: TStrings;
  I: Integer;

begin
  FScript.Assign(Script);
  FInFunction := False;
  FScriptName := ScriptName;
  FItemList.Clear;
  FInsertList.Clear;
  FObjects.Clear;
  if Assigned(FComponent) then
    (GetGdcOLEObject(FComponent) as IDispatch).GetTypeInfo(0, 0,
      FComponentTypeInfo);
  SetObjectsTypeInfo;
  SetDefaultObjects;

  try
    inherited PrepareScript(ScriptName, Script, AtLine);

    DesignatorList :=  TStringList.Create;
    try
      BreakOnDesignators(ScriptName, DesignatorList);
      if DesignatorList.Count > 0 then
      begin
        if (ObjectIndex(DesignatorList[0]) > - 1) and
          Assigned(FObjects.Objects[ObjectIndex(DesignatorList[0])]) then
        begin
          Pointer(FTypeInfo) := nil;
          for I := 0 to DesignatorList.Count - 1 do
          begin
            if UpperCase(DesignatorList[I]) = 'DESIGNER' then
            begin
              FStr := Copy(ScriptName, Pos(ScriptName, 'DESIGNER'), Length(ScriptName));
              FCursorPos := 1;
              FTypeInfo := GetDesignerTypeInfo;
              Break;
            end else
            if UpperCase(DesignatorList[I]) = 'APPLICATION' then
            begin
              FStr := Copy(ScriptName, Pos(ScriptName, 'APPLICATION'), Length(ScriptName));
              FCursorPos := 1;
              FTypeInfo := GetSystemTypeInfo;
              Break;
            end else
              FTypeInfo := GetTypeInfo(FTypeInfo, DesignatorList[I]);
            if not Assigned(FTypeInfo) then
              Exit;
          end;
          if Assigned(FTypeInfo) then
            GetMembers(FTypeInfo);
        end
      end else
        ShowDefaultProposal;
    finally
      DesignatorList.Free;
    end;
  except
  end;
  TStringList(FItemList).CustomSort(StringListSortCompare);
  FillInsertList(FItemList);
  FObjectList.Clear;
end;

procedure TVBProposal.Statament;
var
  CurrentWord: String;
  ObjectVar: String;
begin
  if (FAtLine  > - 1) and (FCurrentLine >= FAtLine) then
  begin
    FCurrentLine := FScript.Count;
    Exit;
  end;

  CurrentWord := UpperCase(GetCurrentWord);
  if CurrentWord = 'SET' then
  begin
    FIsObject := True;
    SetExecutable;
    FCursorPos := NextWord;
    ObjectVar := GetCurrentWord;
    if Assigned(FTypeInfo) then
      Pointer(FTypeInfo) := nil;
    SimpleStatement;
    SetObjectType(ObjectVar, FTypeInfo);
    FIsObject := False;
    DoAfterStatament;
    Inc(FCurrentLine, FLineAdd);
  end else
    inherited;
end;

procedure TVBProposal.WorkDesignator;
var
  ObjectVar: String;
begin
  if (FAtLine  > - 1) and (FCurrentLine >= FAtLine) then
  begin
    FCurrentLine := FScript.Count;
    Exit;
  end;

  ObjectVar := UpperCase(GetCurrentWord);
  if ObjectVar = '' then
    Exit;
  SetExecutable;
  if FTypeDetermin then
  begin
    if ObjectVar = 'DESIGNER' then
    begin
      FTypeInfo := GetDesignerTypeInfo;
    end else
    if ObjectVar = 'APPLICATION' then
    begin
      FTypeInfo := GetSystemTypeInfo;
    end else
      FTypeInfo := GetTypeInfo(FTypeInfo, ObjectVar);
  end;
  if FAddDesignator and not FIsObject then
    AddDesignator(ObjectVar, nil);
  if FStr <> '' then
  begin
    while (FCursorPos < Length(FStr)) and (Pos(FStr[FCursorPos], Letters) > 0) do
      Inc(FCursorPos);
    //!!!!!  
    if FStr[FCursorPos] = '.' then
    begin
      Inc(FCursorPos);
      WorkDesignator;
    end else
    if (FCursorPos < Length(FStr)) and (FStr[FCursorPos] = '(') then
    begin
      FTypeDetermin := False;
      Inc(FCursorPos);
      WorkExprList;
      TrimSpace;
      if (FCursorPos < Length(FStr)) and (FStr[FCursorPos] = ')') then
      begin
        Inc(FCursorPos);
        if (FCursorPos < Length(FStr)) and (FStr[FCursorPos] = '.') then
        begin
          FTypeDetermin := True;
          Inc(FCursorPos);
          WorkDesignator;
        end;
      end{ else
        AddError(MSG_ER_VIOLATION_balance_bracket, FCurrentLine);}
    end
  end;
end;

procedure TVBProposal.BreakOnDesignators(Script: string;
  const DesignatorList: TStrings);
var
  BeginPos, EndPos: integer;
  Len: integer;
const
  Separators = '[]().';
begin
  if not Assigned(DesignatorList) then
    raise Exception.Create('Не инициализирован список');

  DesignatorList.Clear;
  EndPos := 1;
  Len := Length(Script);
  while EndPos <= Len do
  begin
    BeginPos := EndPos;
    while (EndPos <= Len) and (Pos(Script[EndPos], Separators) = 0) do
      Inc(EndPos);
    if EndPos <> BeginPos then
      DesignatorList.Add(Copy(Script, BeginPos, EndPos - BeginPos));
    if (EndPos < Len) and ((Script[EndPos] = '[') or (Script[EndPos] = '(')) then
      while (EndPos < Len) and ((Script[EndPos] <> ']') or (Script[EndPos] <> ')'))  do
        Inc(EndPos);
    Inc(EndPos);
  end;
end;

procedure TVBProposal.FillReservedWords;
begin
  FReservedWords.Clear;
  with FReservedWords do
  begin
    Add('if'); Add('each'); Add('do'); Add('and'); Add('end');
    Add('dim'); Add('case'); Add('call '); Add('is'); Add('on');
    Add('mod'); Add('get'); Add('or'); Add('rem'); Add('let');
    Add('imp'); Add('for'); Add('else'); Add('sub'); Add('eqv');
    Add('set'); Add('went'); Add('then'); Add('erase'); Add('redim');
    Add('not'); Add('xor'); Add('while'); Add('loop'); Add('exit');
    Add('next'); Add('public'); Add('select'); Add('const'); Add('error');
    Add('option'); Add('private'); Add('function');
    Add('randomize'); Add('property'); Add('''#include ');
    Add('except ');
  end;
end;

procedure TVBProposal.FillReservedDesignators;
var
  TypeInfo: ITypeInfo;
  TypeLib: ITypeLib;
begin
  FReservedDesignators.Clear;

  if (LoadTypeLib(cVBScript, TypeLib) = S_OK) and
    (TypeLib.GetTypeInfoOfGuid(GlobalObj_GUID, TypeInfo) = S_OK) then
  begin
    GetMembers(TypeInfo, FReservedDesignators);
  end;
end;

function TVBProposal.GetTypeInfo(ATypeInfo: ITypeInfo;
  Name: string): ITypeInfo;
var
  TypeInfo: ITypeInfo;
  I, Index: Integer;
  FuncDesc: PFuncDesc;
  TypeAttr: PTypeAttr;
  BStrList: _PBStrList;
  cNames: Integer;
  tdesc: TTypeDesc;
begin
  if AnsiCompareText(Name, 'SENDER') = 0 then Exit;

  Result := nil;
  TypeInfo := ATypeInfo;
  if not Assigned(TypeInfo) then
  begin
    Index := ObjectIndex(Name);
    if Index > - 1 then
      Result := ITypeInfo(Pointer(FObjects.Objects[Index]));
    Exit;
  end;

  if TypeInfo.GetTypeAttr(TypeAttr) = S_OK then
  begin
    New(BStrList);
    try
      for I := 0 to TypeAttr^.cFuncs - 1 do
      begin
        if (TypeInfo.GetFuncDesc(I, FuncDesc) = S_OK) and
         (TypeInfo.GetNames(FuncDesc^.memid, PBStrList(BStrList), MaxFuncParams, cNames) =
         S_OK) and (UpperCase(BStrList^[0]) = UpperCase(Name)) then
        begin
          tdesc := FuncDesc.elemdescFunc.tdesc;
          while tdesc.vt = VT_PTR do
            tdesc := tdesc.ptdesc^;
          case tdesc.vt of
            VT_USERDEFINED: TypeInfo.GetRefTypeInfo(tdesc.hreftype, Result);
          end;
        end;
      end;
    finally
      Dispose(BStrList);
      TypeInfo.ReleaseTypeAttr(TypeAttr);
      TypeInfo.ReleaseFuncDesc(FuncDesc);
    end;
  end;
end;

procedure TVBProposal.SetOnCreateObject(const Value: TNotifyEvent);
begin
  FOnCreateObject := Value;
end;


procedure TVBProposal.CreateObject;
var
  TypeInfo: ITypeInfo;
  pIndex: integer;
begin
  if Assigned(FOnCreateObject) then
    FOnCreateObject(Self);

  {$IFDEF GEDEMIN}
  if not Assigned(GedeminApplication) then
  begin
    GedeminApplication := TgsGedeminApplication.Create;
  end;
  FGedeminApplication := GedeminApplication;

  // Должен остаться только один объект
  AddObject('GedeminApplication', (FGedeminApplication as IDispatch), True);
  if (GedeminApplication as IDispatch).GetTypeInfo(0, 0, TypeInfo) = S_OK then
     TypeInfo.GetContainingTypeLib(FTypeLib, pIndex);
  // Для совместимости
  AddObject(ReportObjectName, ((GedeminApplication as
    IGedeminApplication).BaseQueryList as IDispatch), False);
  {$ENDIF}

 { TODO -oTipTop -cзрабіць :
  Кокого х... переменной GedeminApplication присваивается nil
  Если удастся решить данную проблему то можно удалить из
  dmClientReport_unit из ReportCreateObject проверку на инициализацию
  данной переменной }
end;

procedure TVBProposal.AddObject(Name: string; const Object_: IDispatch;
  AddMembers: Boolean);

var
//  I: Integer;
  TypeInfo{, TypeInfo1}: ITypeInfo;
{  TypeAttr: PTypeAttr;
  BStrList: _PBStrList;
  FuncDesc: PFuncDesc;
  cNames: Integer;
  tdesc: TTypeDesc;}
begin
  if not Assigned(Object_) then
    Exit;

  if Object_.GetTypeInfo(0, 0, TypeInfo) = S_OK then
  begin
     FDefaultObjects.Objects[FDefaultObjects.Add(cObject + Name)] := Pointer(TypeInfo);
     if AddMembers then
       GetMembers(TypeInfo, FDefaultObjects);
  end;
  {  if AddMembers then
  begin
    New(BStrList);
    try
      if (Object_.GetTypeInfo(0, 0, TypeInfo) = S_OK) and
        (TypeInfo.GetTypeAttr(TypeAttr) = S_Ok) then
        begin
          FDefaultObjects.Objects[FDefaultObjects.Add(cObject + Name)] := Pointer(TypeInfo);
          for I := 0 to TypeAttr.cFuncs - 1 do
          begin
            if (TypeInfo.GetFuncDesc(I, FuncDesc) = S_OK) and
              (TypeInfo.GetNames(FuncDesc.memid, PBStrList(BStrList), MaxFuncParams, cNames) =
              S_OK) and (FDefaultObjects.IndexOf(BStrList^[0]) = -1) and
              not IsIDispatchMember(BStrList^[0]) then
            begin
              tdesc := FuncDesc.elemdescFunc.tdesc;
              while tdesc.vt = VT_PTR do
                tdesc := tdesc.ptdesc^;
              case tdesc.vt of
                VT_USERDEFINED:
                begin
                  Pointer(TypeInfo1) := nil;
                  TypeInfo.GetRefTypeInfo(tdesc.hreftype, TypeInfo1);
                  FDefaultObjects.Objects[FDefaultObjects.Add(cObject + BStrList^[0])] :=
                    Pointer(TypeInfo1);
                end
              else
                FDefaultObjects.Add(cMethod + BStrList^[0]);
              end;
              TypeInfo.ReleaseFuncDesc(FuncDesc);
            end
          end;
        end;
    finally
      Dispose(BStrList);
      TypeInfo.ReleaseTypeAttr(TypeAttr);
    end
  end else
  begin
    if Object_.GetTypeInfo(0, 0, TypeInfo) = S_OK then
       FDefaultObjects.Objects[FDefaultObjects.Add(cObject +
       Name)] := Pointer(TypeInfo);
  end}
end;

procedure TVBProposal.SimpleStatement;
begin
  TrimSpace;
  FAddDesignator := True;
  WorkDesignator;
  FAddDesignator := False;
  TrimSpace;
  if (FCursorPos <= Length(FStr)) and (FStr[FCursorPos] = '=') then
  begin
    Inc(FCursorPos);
    FTypeDetermin := True;
    WorkExpression;
    FTypeDetermin := False;
  end;
//  Inc(FCurrentLine, FLineAdd);
end;

procedure TVBProposal.ClearTypeInfoList;
var
  I: Integer;
  TypeInfo: ITypeInfo;
begin
  for I := 0 to FTypeInfoList.Count - 1 do
  begin
    if Assigned(FTypeInfoList[I]) then
    begin
      TypeInfo := ITypeInfo(FTypeInfoList[I]);
      TypeInfo := nil;
    end;
  end;
  FTypeInfoList.Clear;
end;

function TVBProposal.DesignatorIndex(Name: String): Integer;
var
  I: Integer;
begin
  Name := UpperCase(Name);
  for I := 0 to FDesignators.Count - 1 do
    if UpperCase(FDesignators[I]) = Name then
      Break;
  if I < FDesignators.Count then
    Result := I
  else
    Result := - 1;
end;

function TVBProposal.ObjectIndex(Name: String): Integer;
var
  I: Integer;
begin
  Name := UpperCase(Name);
  for I := 0 to FObjects.Count - 1 do
    if UpperCase(TrimName(FObjects[I])) =  Name then
      Break;
  if I < FObjects.Count then
    Result := I
  else
    Result := - 1;
end;


procedure TVBProposal.ShowDefaultProposal;
begin
  FItemList.Text := FObjects.Text + FReservedWords.Text +
     FReservedDesignators.Text;
  FInsertList.Assign(FItemList);
end;

procedure TVBProposal.GetMembers(TypeInfo: ITypeInfo);
begin
  FItemList.Clear;
  GetMembers(TypeInfo, FItemList);
end;

procedure TVBProposal.SetDefaultObjects;
var
  I: Integer;
begin
  for I := 0 to FDefaultObjects.Count - 1 do
  begin
    FObjects.Objects[FObjects.Add(FDefaultObjects[I])] :=
      FDefaultObjects.Objects[I];
  end;
end;

function TVBProposal.IsIDispatchMember(Member: String): Boolean;
begin
  Result := Pos(' ' + UpperCase(Member) + ';', IDispatchMembers) > 0;
end;

function TVBProposal.ReservedWordsIndex(Name: string): Integer;
var
  I: Integer;
begin
  Name := UpperCase(Name);
  for I := 0 to FReservedWords.Count - 1 do
    if UpperCase(FReservedWords[I]) = Name then
      Break;
  if I < FReservedWords.Count then
    Result := I
  else
    Result := - 1;
end;

function TVBProposal.ReservedDesignatorsIndex(Name: string): Integer;
var
  I: Integer;
begin
  Name := UpperCase(Name);
  for I := 0 to FReservedDesignators.Count - 1 do
    if UpperCase(FReservedDesignators[I]) = Name then
      Break;
  if I < FReservedDesignators.Count then
    Result := I
  else
    Result := - 1;
end;

function TVBProposal.GetDesignerTypeInfo: ITypeInfo;
var
  Eval: string;
  cP, bP: Integer;
//  I: Integer;

  function EvalDesigner: ITypeInfo;
  begin
    Result := GetTypeInfo(FTypeInfo, 'DESIGNER');
  end;

begin
  Result := nil;
  Eval := Trim(Copy(FStr, FCursorPos, Length(FStr) - FCursorPos));
  if Eval <> '' then
  begin
    cP := Pos('CREATECOMPONENT', Eval);
    if cP = 0 then
      cP := Pos('CREATEOBJECT', Eval);
    bP := Pos('"', Eval);
    if (cP > 0) and (bP > 0) and (cP < bP)then
    begin
      Eval := Copy(Eval, bP + 1, Length(Eval) - bP - 1);
      bP := Pos('"', Eval);
      if bP > 0 then
        Eval := Copy(Eval, 1, bP - 1)
      else
        Exit;
      if Eval <> '' then
      begin

        Eval[1] := 'I';
        Insert('GS', Eval, 2);
        Result := GetTypeInfoByInterfaceName(Eval);
        if Assigned(Result) then
          FCursorPos := Length(FStr)
        else
          Result := EvalDesigner;
      end
    end else
    if (Pos('CREATEFORM', Eval) > 0) then
    begin
      Result := GetTypeInfoByInterfaceName('IgsCreateableForm');
      if Assigned(Result) then
        FCursorPos := Length(FStr)
      else
        Result := EvalDesigner;
    end else
      Result := EvalDesigner;
  end else
     Result := EvalDesigner;
end;

function TVBProposal.GetSystemTypeInfo: ITypeInfo;
var
  Eval: string;
  EvalResult: Variant;
  I: Integer;

  function EvalSystem: ITypeInfo;
  begin
    Result := GetTypeInfo(FTypeInfo, 'APPLICATION');
  end;

begin
  Result := nil;
  if Assigned(ScriptFactory) then
  begin
    Eval := Trim(Copy(FStr, FCursorPos, Length(FStr) - FCursorPos + 1));
    if Pos('APPLICATION.FINDCOMPONENT', UpperCAse(Eval)) = 1 then
    begin
      I := Length(Eval);
      while (I > 0) and (Eval[I] = '.') do
      begin
        Eval[I] := ' ';
        Dec(I);
      end;
      try
        EvalResult := ScriptFactory.Eval(Eval);
        if (VarType(EvalResult) = varDispatch) and
          Assigned(IDispatch(EvalResult)) then
        begin
          IDispatch(EvalResult).GetTypeInfo(0, 0, Result);
          FCursorPos := Length(FStr);
        end;
      except
        Result := EvalSystem;
      end;
    end else
      Result := EvalSystem;
  end else
    Result := EvalSystem;
end;

procedure TVBProposal.SetObjectsTypeInfo;
var
  I: Integer;
  AutoObject: TWrapperAutoObject;
begin
  for I := 0 to FFKObjects.Count -1 do
  begin
    if (Trim(FFKObjects[I]) <> '') and (ObjectIndex(FFKObjects[I]) = - 1) then
    begin
      if Assigned(FFKObjects.Objects[I]) then
      begin
        AutoObject := GetGdcOLEObject(FFKObjects.Objects[I]);
        if AutoObject <> nil then
        begin
          FObjects.Objects[FObjects.Add(FFKObjects[I])] := Pointer(AutoObject.DispTypeInfo);
          FObjectList.Add(AutoObject);
        end;
      end;
    end;
  end;
end;

procedure TVBProposal.SetFKObjects(const Value: TStrings);
begin
  FFKObjects := Value;
end;

function TVBProposal.GetTypeInfoByInterfaceName(Name: string): ITypeInfo;
var
  I, InfoCount: Integer;
  pbstrName: PWideString;
begin
  Result := nil;
  Name := Trim(UpperCase(Name));
  if Assigned(FTypeLib) then
  begin
    InfoCount := FTypeLib.GetTypeInfoCount;
    New(pbstrName);
    try
      for I := 0 to InfoCount do
      begin
        FTypeLib.GetDocumentation(I, pbstrName, nil, nil, nil);
        if UpperCase(pbstrName^) = Name then
        begin
          FTypeLib.GetTypeInfo(I, Result);
//          FCursorPos := Length(FStr);
          Exit;
        end;
      end;
    finally
      Dispose(pbstrName);
    end;
  end;
end;

procedure TVBProposal.SetObjectType(Name: string; TypeInfo: ITypeInfo);
var
  Index: Integer;
begin
  Index := ObjectIndex(Name);
  if Index > - 1 then
    FObjects.Objects[Index] := Pointer(TypeInfo)
  else
    FObjects.Objects[FObjects.Add(cObject + Name)] := Pointer(TypeInfo);
end;

function TVBProposal.GetFKObjects: TStrings;
begin
  Result := FFKObjects;
end;

function TVBProposal.GetInsertList: TStrings;
begin
  Result := FInsertList;
end;

function TVBProposal.GetItemList: TStrings;
begin
  Result := FItemList;
end;

function TVBProposal.GetOnCreateObject: TNotifyEvent;
begin
  Result := FOnCreateObject;
end;

function TVBProposal.GetReservedDesignators: TStrings;
begin
  Result := FReservedDesignators;
end;

function TVBProposal.GetReservedWords: TStrings;
begin
  Result := FReservedWords;
end;

procedure TVBProposal.GetMembers(TypeInfo: ITypeInfo; ItemList: TStrings);
var
  I, j: Integer;
  TypeAttr: PTypeAttr;
  BStrList: _PBStrList;
  FuncDesc: PFuncDesc;
  VarDesc: PVarDesc;
  cNames: Integer;
  Str: string;
  tdesc: TTypeDesc;
  TypeInfo1: ITypeInfo;
begin
  if not Assigned(TypeInfo) then
    Exit;

  if TypeInfo = FComponentTypeInfo then
  begin
    for I := 0 to FFKObjects.Count - 1 do
    begin
      if (Trim(FFKObjects[I]) <> '') and (ItemList.IndexOf(FFKObjects[I]) = - 1) then
      begin
        ItemList.Add(cObject + FFKObjects[I]);
      end;
    end;
  end;

  New(BStrList);
  try
    if TypeInfo.GetTypeAttr(TypeAttr) = S_Ok then
    begin
      for I := 0 to TypeAttr.cFuncs - 1 do
      begin
        if (TypeInfo.GetFuncDesc(I, FuncDesc) = S_OK) and
          (TypeInfo.GetNames(FuncDesc.memid, PBStrList(BStrList), MaxFuncParams, cNames) =
          S_OK) and not IsIDispatchMember(BStrList^[0]) then
        begin
          if FuncDesc.invkind = DISPATCH_METHOD then
          begin
            Str := '';
            for J := 1 to cNames - 1 do
            begin
              if Str <> '' then
                Str := Str + ', ';
              if (FuncDesc.cParamsOpt > 0) and (J > FuncDesc.cParams - FuncDesc.cParamsOpt) then
                Str := Str + '[' + BstrList^[J] + ']'
              else
                Str := Str + BStrList^[J];
            end;
            Str := cMethod + string(BStrList^[0]) + #9'(' + Str + ')';
          end else
            Str := cProperty + BStrList^[0] + #9;

          tdesc := FuncDesc.elemdescFunc.tdesc;

          while tdesc.vt = VT_PTR do
            tdesc := tdesc.ptdesc^;

          case tdesc.vt of
            VT_USERDEFINED:
            begin
              Pointer(TypeInfo1) := nil;
              TypeInfo.GetRefTypeInfo(tdesc.hreftype, TypeInfo1);
              if ItemList.IndexOf(Str) = - 1 then
                ItemList.AddObject(Str, Pointer(TypeInfo1));
            end
          else
            if ItemList.IndexOf(Str) = - 1 then
              ItemList.Add(Str);

          end;

          TypeInfo.ReleaseFuncDesc(FuncDesc);
        end
      end;
      for I := 0 to TypeAttr.cVars - 1 do
      begin
        if (TypeInfo.GetVarDesc(I, VarDesc) = S_OK) and
          (TypeInfo.GetNames(VarDesc.memid, PBStrList(BStrList), MaxFuncParams, cNames) =
            S_OK) and not IsIDispatchMember(BStrList^[0]) then
        begin
          if (VarDesc.varkind = VAR_CONST) or (VarDesc.wVarFlags = VARFLAG_FREADONLY) then
            Str := cConst + BStrList^[0] + #9
          else
            Str := cVar + BStrList^[0] + #9;

          if ItemList.IndexOf(Str) = - 1 then
            ItemList.Add(Str);
          TypeInfo.ReleaseVarDesc(VarDesc);
        end;
      end;
    end;
  finally
    Dispose(BStrList);
    TypeInfo.ReleaseTypeAttr(TypeAttr);
  end
end;

procedure TVBProposal.AddFKObject(Name: String; AObject: TObject);
begin
  if FFKObjects.IndexOf(cObject + Name + #9) = -1 then
    FFKObjects.AddObject(cObject + Name + #9, AObject)
  else
    ;
end;

procedure TVBProposal.ClearFKObjects;
begin
  FFKObjects.Clear;
end;

procedure TVBProposal.FillInsertList(SL: TStrings);
var
  I: Integer;
  S: string;
begin
  FInsertList.Clear;
  for I := 0 to Sl.Count - 1 do
  begin
    S := Sl[I];
    S := TrimName(S);
    FInsertList.Add(S);
  end;
end;

function TrimName(S: String): string;
var
  P: Integer;
begin
  Result := S;
  P := Pos(#9, Result);
  if P >  1 then
  begin
    Result := Copy(Result, P + 1, Length(Result) - P);
    P := Pos(#9, Result);
    if P > 1 then
      Result := Copy(Result, 1, P - 1);
  end;

  P := Pos('(', Result);
  if P > 1 then
    Result := Copy(Result, 1, P - 1);
end;

end.
