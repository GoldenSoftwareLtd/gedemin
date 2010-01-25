
{++

  Copyright (c) 2001 by Golden Software of Belarus

  Module

    obj_dlgParamWindow_unit.pas

  Abstract

    Gedemin project. COM-object. ParamWindow.

  Author

    Andrey Shadevsky

  Revisions history

    1.00    20.10.01    JKL        Initial version.

--}

unit obj_dlgParamWindow;

interface

uses
  ComObj, ActiveX, AxCtrls, Gedemin_TLB, IBDatabase, SysUtils,
  prm_ParamFunctions_unit;

type
  TgsParamWindow = class(TAutoObject, IgsParamWindow)
  private
    FParamList: TgsParamList;
    FExternalKey: Integer;

    function  VariantIsArray(const Value: OleVariant): Boolean;
  protected
    function  Get_ParamList: IgsParamList; safecall;

    procedure AddParam(const ParamName: WideString; const ParamType: WideString;
                       const Comment: WideString); safecall;
    procedure AddLinkParam(const ParamName: WideString; const ParamType: WideString;
     const TableName: WideString; const PrimaryName: WideString;
     const DisplayName: WideString; const LinkCondition: WideString;
     const LinkLanguage: WideString; const Comment: WideString); safecall;
    function  Execute: OleVariant; safecall;
    function  ExecuteWithParam(const ParamName: WideString; const ParamType: WideString;
                               const Comment: WideString): OleVariant; safecall;
    function  ExecuteWithLinkParam(const ParamName: WideString; const ParamType: WideString;
                                   const TableName: WideString; const PrimaryName: WideString;
                                   const DisplayName: WideString; const LinkCondition: WideString;
                                   const LinkLanguage: WideString; const Comment: WideString): OleVariant; safecall;
    function ExecuteWithParamList(const AParamList: IgsParamList): OleVariant; safecall;
  public
    constructor Create(const AnExternalKey: Integer);
    destructor Destroy; override;
  end;

implementation

uses
  ComServ, flt_ScriptInterface, prp_methods, gdcOLEClassList;

{ TgsParamWindow }

procedure TgsParamWindow.AddLinkParam(const ParamName: WideString; const ParamType: WideString;
  const TableName: WideString; const PrimaryName: WideString;
  const DisplayName: WideString; const LinkCondition: WideString;
  const LinkLanguage: WideString; const Comment: WideString); safecall;
begin
  FParamList.AddLinkParam(ParamName, ParamName, StringToParamType(ParamType), TableName,
   DisplayName, PrimaryName, LinkCondition, LinkLanguage, Comment);
end;

procedure TgsParamWindow.AddParam(const ParamName: WideString; const ParamType: WideString;
  const Comment: WideString); safecall;
begin
  FParamList.AddParam(ParamName, ParamName, StringToParamType(ParamType), Comment);
end;

constructor TgsParamWindow.Create(const AnExternalKey: Integer);
begin
  inherited Create;

  FParamList := TgsParamList.Create;
  FExternalKey := AnExternalKey;
end;

destructor TgsParamWindow.Destroy;
begin
  FreeAndNil(FParamList);

  inherited;
end;

function TgsParamWindow.Execute: OleVariant;
var
  TempResult: Boolean;
begin
  Result := Unassigned;
  if Assigned(ParamGlobalDlg) and ParamGlobalDlg.IsEventAssigned then
  begin
    ParamGlobalDlg.QueryParams(GD_PRM_SCRIPT_DLG, FExternalKey, FParamList, TempResult);
    if TempResult then
      Result := FParamList.GetVariantArray
    else
      Result := Unassigned;
  end else
    raise Exception.Create('Класс ParamGlobalDlg не создан');
end;

function TgsParamWindow.ExecuteWithLinkParam(const ParamName, ParamType,
  TableName, PrimaryName, DisplayName, LinkCondition, LinkLanguage,
  Comment: WideString): OleVariant;
begin
  AddLinkParam(ParamName, ParamType, TableName, PrimaryName, DisplayName,
   LinkCondition, LinkLanguage, Comment);
  Result := Execute[0];
end;

function TgsParamWindow.ExecuteWithParam(const ParamName, ParamType,
  Comment: WideString): OleVariant;
var
  TmpResultArray: OleVariant;
begin
  AddParam(ParamName, ParamType, Comment);
  TmpResultArray := Execute;
  if VariantIsArray(TmpResultArray) then
    Result := TmpResultArray[0]
  else
    Result := TmpResultArray;
end;

function TgsParamWindow.ExecuteWithParamList(const AParamList: IgsParamList): OleVariant;
begin
  FParamList.Assign(InterfaceToObject(AParamList) as TgsParamList);
  Result := Execute;
end;

function TgsParamWindow.Get_ParamList: IgsParamList;
begin
  Result := GetGdcOLEObject(FParamList) as IgsParamList;
end;

function TgsParamWindow.VariantIsArray(const Value: OleVariant): Boolean;
begin
  Result := (VarType(Value) and (not (VarType(Value) xor VarArray))) = VarArray;
end;

initialization
  TAutoObjectFactory.Create(ComServer, TgsParamWindow, CLASS_gsParamWindow,
    ciSingleInstance, tmApartment);
end.
