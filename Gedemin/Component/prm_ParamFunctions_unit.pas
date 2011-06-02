
{++

  Copyright (c) 2001-2010 by Golden Software of Belarus

  Module

    prm_ParamFunctions_unit.pas

  Abstract

    Gedemin project. Basic unit for Global Param variable.

  Author

    Andrey Shadevsky

  Revisions history

    1.00    29.10.01    JKL        Initial version.
    1.01    02.01.03    DAlex      Support "no query" parameters.

--}

unit prm_ParamFunctions_unit;

interface

uses
  SysUtils, Contnrs, Classes;

type
  TParamType = (
    prmInteger,
    prmFloat,
    prmDate,
    prmDateTime,
    prmTime,
    prmString,
    prmBoolean,
    prmLinkElement,
    prmLinkSet,
    prmEnumElement,
    prmEnumSet,
    prmNoQuery,       // ������������ ��� ����������, ���. �� ������������� � � �������
    prmPeriod,
    prmList,
    prmRadioButtons,
    prmCheckBoxs);

  TSortOrder = 0..2;

  TgsParamData = class
  private
    FRealName, FDisplayName, FValuesList: String;
    FParamType: TParamType;
    FComment: String;
    FLinkTableName, FLinkDisplayField, FLinkPrimaryField: String;
    FResultValue: Variant;
    FLinkConditionFunction, FLinkFunctionLanguage: String;
    FRequired: Boolean;
    FSortOrder: TSortOrder;
    FSortField: String;

    function GetParamType: TParamType;
    procedure SetLinkPrimaryField(const Value: String);
    procedure SetDisplayName(const Value: String);
    function GetLinkTableName: String;

  public
    constructor Create(const ARealName, ADisplayName: String;
      AParamType: TParamType; const AComment: String); overload; virtual;
    constructor Create(const ARealName, ADisplayName: String;
      const AParamType: TParamType; const ALinkTable, ALinkDisplay,
      ALinkPrimary, ALinkConditionFunction, ALinkFunctionLanguage: String;
      const AComment: String); overload; virtual;
    constructor Create(const ARealName, ADisplayName: String;
      AParamType: TParamType; const AComment: String;
      const AValuesList: String); overload; virtual;
    constructor Create(const ASource: TgsParamData); overload; virtual;

    procedure Assign(const Source: TgsParamData); virtual;
    procedure SaveToStream(AnStream: TStream); virtual;
    procedure LoadFromStream(AnStream: TStream); virtual;

    property ValuesList: String read FValuesList write FValuesList;
    property RealName: String read FRealName write FRealName;
    property DisplayName: String read FDisplayName write SetDisplayName;
    property ParamType: TParamType read GetParamType write FParamType;
    property Comment: String read FComment write FComment;
    property LinkTableName: String read GetLinkTableName write FLinkTableName;
    property LinkDisplayField: String read FLinkDisplayField write FLinkDisplayField;
    property LinkPrimaryField: String read FLinkPrimaryField write SetLinkPrimaryField;
    property ResultValue: Variant read FResultValue write FResultValue;
    property LinkConditionFunction: String read FLinkConditionFunction write FLinkConditionFunction;
    property LinkFunctionLanguage: String read FLinkFunctionLanguage write FLinkFunctionLanguage;
    property Required: Boolean read FRequired write FRequired;
    property SortOrder: TSortOrder read FSortOrder write FSortOrder;
    property SortField: String read FSortField write FSortField;
  end;

type
  TgsParamList = class(TObjectList)
  private
    function GetParam(const I: Integer): TgsParamData;
    procedure SetParam(const I: Integer; const AnParam: TgsParamData);

  public
    function AddParam(const AParamName, ADisplayName: String;
      const AParamType: TParamType; const AComment: String): Integer; virtual;
    function AddLinkParam(const AParamName, ADisplayName: String;
      const AParamType: TParamType; const ATableName, ADisplayField,
      APrimaryField, ALinkConditionFunction, ALinkFunctionLanguage: String;
      const AComment: String): Integer; virtual;
    function AddSelectParam(const AParamName, ADisplayName: String;
      const AParamType: TParamType; const AComment: String; const AValuesList: String): Integer; virtual;

    procedure SaveToStream(AnStream: TStream); virtual;
    procedure LoadFromStream(AnStream: TStream); virtual;

    procedure Assign(const Source: TgsParamList); virtual;
    function GetVariantArray: Variant;
    procedure SetVariantArray(AnVarArray: Variant);

    function Find(const AParam: TgsParamData): Integer;

    property Params[const I: Integer]: TgsParamData read GetParam write SetParam;
  end;

  function GetParamsFromText(const AnParamList: TgsParamList;
    const AnFunctionName, AnText: String): Boolean;
  function StringToParamType(const AParamTypeStr: String): TParamType;
  function ParamTypeToString(const AParamType: TParamType): String;

implementation

uses
{$IFDEF VER140}
  Variants,
{$ENDIF}
  prp_MessageConst, TypInfo;

const
  StartParam          = 'PRST';
  FinishParam         = 'FNST';
  StartListParam      = 'SLPR';
  FinishListParam     = 'FLPR';
  RequiredLabel       = '^R';
  SortAscLabel        = '^A';
  SortDescLabel       = '^D';
  StartSortField      = '^SF';
  FinishSortField     = '^FF';
  ValuesListDelimiter = '^V';

function GetParamsFromText(const AnParamList: TgsParamList;
 const AnFunctionName, AnText: String): Boolean;
const
  TextLimit = [#13, #10, ' ', '(', ')', ';', ''''];
  LeftBound = '(';
  RightBound = ')';
  LocSeparator = ',';
var
  TempName, TempFuncName, TempText: String;
  PosFN: Integer;
  J, I: Integer;
  TempScript: TStrings;
  PosFNDecl, FNDeclLength, P: Integer;
begin
  Result := False;
  TempFuncName := AnsiUpperCase(Trim(AnFunctionName));
  TempScript := TStringList.Create;
  PosFN := 0;
  try
    TempScript.Text := AnsiUpperCase(Trim(AnText));
    for I := 0 to TempScript.Count - 1 do
    begin
      PosFNDecl := Pos('SUB ', TempScript[I]);
      FNDeclLength := 4;
      if PosFNDecl = 0 then
      begin
        PosFNDecl := Pos('FUNCTION ', TempScript[I]);
        FNDeclLength := 9;
      end;
      if PosFNDecl > 0 then
      begin
        P := Pos('''', TempScript[I]);
        if (P > 0) and (P < PosFnDecl) then Continue;
        P := Pos('"', TempScript[I]);
        if (P > 0) and (P < PosFnDecl) then Continue;
        PosFn := PosFnDecl + FNDeclLength;
        while (PosFn < Length(TempScript[I])) and (TempScript[I][PosFn] in [' ', #13, #10, '_']) do
          Inc(PosFn);
        if PosFn >= Length(TempScript[I]) then
        begin
          PosFN := 0;
          Continue;
        end;
        if (PosFN = Pos(TempFuncName, TempScript[I])) and
          ( (PosFn + Length(TempFuncName) > Length(TempScript[I]))
             or
            (TempScript[I][PosFn + Length(TempFuncName)] in TextLimit)
          ) then
        begin
          for J := 0 to I - 1 do
            PosFN := PosFN + Length(TempScript[J]) + 2;
          Break;
        end else
          PosFn := 0;
      end;
    end;
    TempText := TempScript.Text;
  finally
    TempScript.Free;
  end;

  if PosFn = 0 then Exit;

  PosFN := PosFN + Length(TempFuncName);

  while (PosFN < Length(TempText)) and (TempText[PosFN] <> LeftBound) and
   (TempText[PosFN] in TextLimit) do
  begin
    if TempText[PosFN] = '''' then
      exit;              
    Inc(PosFN);
  end;

  if TempText[PosFN] = LeftBound then
    while (PosFN < Length(TempText)) and (TempText[PosFN] <> RightBound) do
    begin
      Inc(PosFN);
      TempName := '';
      while (PosFN < Length(TempText)) and (TempText[PosFN] <> RightBound) and
         not (TempText[PosFN] in [LocSeparator, ' ', #13, #10]) do
      begin
        TempName := TempName + TempText[PosFN];
        Inc(PosFN);
      end;
      if (Trim(TempName) > '') and (Trim(TempName) <> BYREF) and (Trim(TempName) <> BYVAL) and
        (Trim(TempName) <> '_' )then
      begin
        // ��� ���-�� OwnerForm  �� ��������� ��� "prmNoQuery",
        // �.�. �� ������������ ��� �������� ����� � ������ � �����
        if AnsiUpperCase(Trim(TempName)) = VB_OWNERFORM then
          AnParamList.AddParam(Trim(TempName), Trim(TempName), prmNoQuery, '')
        else
          AnParamList.AddParam(Trim(TempName), Trim(TempName), prmInteger, '');
      end;
    end;
end;

function StringToParamType(const AParamTypeStr: String): TParamType;
var
  I: Integer;
begin
  if AParamTypeStr > '' then
  begin
    I := GetEnumValue(TypeInfo(TParamType), AParamTypeStr);
    if I <> -1 then
    begin
      Result := TParamType(I);
      Exit;
    end;
  end;

  raise Exception.Create('����������� ��� ���������: ' + AParamTypeStr);
end;

function ParamTypeToString(const AParamType: TParamType): String;
begin
  Result := GetEnumName(TypeInfo(TParamType), Integer(AParamType));
end;

{ TgsParamData }

constructor TgsParamData.Create(const ARealName, ADisplayName: String;
  AParamType: TParamType; const AComment: String);
begin
  inherited Create;

  FRealName := ARealName;
  FDisplayName := ADisplayName;
  FParamType := AParamType;
  FComment := AComment;
end;

procedure TgsParamData.Assign(const Source: TgsParamData);
begin
  FRealName := Source.RealName;
  FDisplayName := Source.DisplayName;
  FParamType := Source.ParamType;
  FComment := Source.Comment;
  FRequired := Source.Required;
  FSortOrder := Source.SortOrder;
  FSortField := Source.SortField;
  FLinkTableName := Source.LinkTableName;
  FLinkDisplayField := Source.LinkDisplayField;
  FLinkPrimaryField := Source.LinkPrimaryField;
  FResultValue := Source.ResultValue;
  FLinkConditionFunction := Source.LinkConditionFunction;
  FLinkFunctionLanguage := Source.LinkFunctionLanguage;
  FValuesList := Source.ValuesList;
end;

constructor TgsParamData.Create(const ARealName, ADisplayName: String;
  const AParamType: TParamType; const ALinkTable, ALinkDisplay,
  ALinkPrimary, ALinkConditionFunction, ALinkFunctionLanguage: String;
  const AComment: String);
begin
  Create(ARealName, ADisplayName, AParamType, AComment);
  FLinkTableName := ALinkTable;
  FLinkDisplayField := ALinkDisplay;
  FLinkPrimaryField := ALinkPrimary;
  FLinkConditionFunction := ALinkConditionFunction;
  FLinkFunctionLanguage := ALinkFunctionLanguage;
end;

constructor TgsParamData.Create(const ARealName, ADisplayName: String;
  AParamType: TParamType; const AComment: String;
  const AValuesList: String);
begin
  Create(ARealName, ADisplayName, AParamType, AComment);
  FValuesList := AValuesList;
end;

procedure TgsParamData.LoadFromStream(AnStream: TStream);
var
  TestLabel: array[0..SizeOf(StartParam)] of Char;
  I, SFS, SFF: Integer;
begin
  Assert(Length(StartParam) = Length(FinishParam));
  AnStream.ReadBuffer(TestLabel[0], Length(StartParam));
  TestLabel[Length(StartParam)] := #0;
  if StartParam <> TestLabel  then
    raise Exception.Create('�������� ������ ������ ����������');

  AnStream.ReadBuffer(I, SizeOf(I));
  SetLength(FRealName, I);
  if I > 0 then
    AnStream.ReadBuffer(FRealName[1], I);

  AnStream.ReadBuffer(I, SizeOf(I));
  SetLength(FDisplayName, I);
  if I > 0 then
    AnStream.ReadBuffer(FDisplayName[1], I);

  AnStream.ReadBuffer(I, SizeOf(I));
  SetLength(FLinkTableName, I);
  if I > 0 then
    AnStream.ReadBuffer(FLinkTableName[1], I);

  AnStream.ReadBuffer(I, SizeOf(I));
  SetLength(FLinkDisplayField, I);
  if I > 0 then
    AnStream.ReadBuffer(FLinkDisplayField[1], I);

  AnStream.ReadBuffer(I, SizeOf(I));
  SetLength(FLinkPrimaryField, I);
  if I > 0 then
    AnStream.ReadBuffer(FLinkPrimaryField[1], I);

  AnStream.ReadBuffer(FParamType, SizeOf(FParamType));

  AnStream.ReadBuffer(I, SizeOf(I));
  SetLength(FLinkConditionFunction, I);
  if I > 0 then
    AnStream.ReadBuffer(FLinkConditionFunction[1], I);

  AnStream.ReadBuffer(I, SizeOf(I));
  SetLength(FLinkFunctionLanguage, I);
  if I > 0 then
    AnStream.ReadBuffer(FLinkFunctionLanguage[1], I);

  AnStream.ReadBuffer(I, SizeOf(I));
  SetLength(FComment, I);
  if I > 0 then
  begin
    AnStream.ReadBuffer(FComment[1], I);
    I := Pos(RequiredLabel, FComment);
  end;
  FRequired := I > 0;
  if FRequired then
    Delete(FComment, I, Length(RequiredLabel));
  FSortOrder := 0;

  I := Pos(SortAscLabel, FComment);
  if I > 0 then
  begin
    Delete(FComment, I, Length(SortAscLabel));
    FSortOrder := 1;
  end;

  I := Pos(SortDescLabel, FComment);
  if I > 0 then
  begin
    Delete(FComment, I, Length(SortDescLabel));
    FSortOrder := 2;
  end;

  SFS := Pos(StartSortField, FComment);
  SFF := Pos(FinishSortField, FComment);
  if (SFS > 0) and (SFF > SFS) then
  begin
    FSortField := Copy(FComment, SFS + Length(StartSortField), SFF - SFS - Length(StartSortField));
    FSortOrder := 0;
    Delete(FComment, SFS, SFF - SFS + Length(FinishSortField));
  end else
    FSortField := '';

  I := Pos(ValuesListDelimiter, FComment);
  if I > 0 then
  begin
    FValuesList := Copy(FComment, I + Length(ValuesListDelimiter), 4096);
    SetLength(FComment, I - 1);
  end else
    FValuesList := '';

  AnStream.ReadBuffer(TestLabel[0], Length(StartParam));
  TestLabel[Length(StartParam)] := #0;
  if FinishParam <> TestLabel then
    raise Exception.Create('�������� ������ ������ ����������');
end;

procedure TgsParamData.SaveToStream(AnStream: TStream);
var
  I: Integer;
  S: String;
begin
  AnStream.Write(StartParam, SizeOf(StartParam));

  I := Length(FRealName);
  AnStream.Write(I, SizeOf(I));
  if I > 0 then
    AnStream.Write(FRealName[1], I);

  I := Length(FDisplayName);
  AnStream.Write(I, SizeOf(I));
  if I > 0 then
    AnStream.Write(FDisplayName[1], I);

  I := Length(FLinkTableName);
  AnStream.Write(I, SizeOf(I));
  if I > 0 then
    AnStream.Write(FLinkTableName[1], I);

  I := Length(FLinkDisplayField);
  AnStream.Write(I, SizeOf(I));
  if I > 0 then
    AnStream.Write(FLinkDisplayField[1], I);

  I := Length(FLinkPrimaryField);
  AnStream.Write(I, SizeOf(I));
  if I > 0 then
    AnStream.Write(FLinkPrimaryField[1], I);

  AnStream.Write(FParamType, SizeOf(FParamType));

  I := Length(FLinkConditionFunction);
  AnStream.Write(I, SizeOf(I));
  if I > 0 then
    AnStream.Write(FLinkConditionFunction[1], I);

  I := Length(FLinkFunctionLanguage);
  AnStream.Write(I, SizeOf(I));
  if I > 0 then
    AnStream.Write(FLinkFunctionLanguage[1], I);

  if FValuesList > '' then
    S := FComment + ValuesListDelimiter + FValuesList;

  if FRequired then
    S := S + RequiredLabel;

  if FSortField > '' then
    S := S + StartSortField + FSortField + FinishSortField
  else
    case FSortOrder of
      1: S := S + SortAscLabel;
      2: S := S + SortDescLabel;
    end;

  I := Length(S);
  AnStream.Write(I, SizeOf(I));
  if I > 0 then
    AnStream.Write(S[1], I);

  AnStream.Write(FinishParam, SizeOf(FinishParam));
end;


function TgsParamData.GetParamType: TParamType;
begin
  Result := FParamType;
end;

procedure TgsParamData.SetLinkPrimaryField(const Value: String);
begin
  FLinkPrimaryField := Value;
end;

procedure TgsParamData.SetDisplayName(const Value: String);
begin
  FDisplayName := Value;
end;

function TgsParamData.GetLinkTableName: String;
begin
  Result := FLinkTableName;
end;

constructor TgsParamData.Create(const ASource: TgsParamData);
begin
  inherited Create;
  Assign(ASource);
end;

{ TgsParamList }

function TgsParamList.AddLinkParam(const AParamName, ADisplayName: String;
  const AParamType: TParamType; const ATableName, ADisplayField,
  APrimaryField, ALinkConditionFunction, ALinkFunctionLanguage: String;
  const AComment: String): Integer;
begin
  Result := Add(TgsParamData.Create(AParamName, ADisplayName, AParamType, ATableName,
    ADisplayField, APrimaryField, ALinkConditionFunction, ALinkFunctionLanguage, AComment));
end;

function TgsParamList.AddParam(const AParamName, ADisplayName: String;
  const AParamType: TParamType; const AComment: String): Integer;
begin
  Result := Add(TgsParamData.Create(AParamName, ADisplayName, AParamType, AComment));
end;

function TgsParamList.AddSelectParam(const AParamName, ADisplayName: String;
  const AParamType: TParamType; const AComment: String; const AValuesList: String): Integer;
begin
  Result := Add(TgsParamData.Create(AParamName, ADisplayName, AParamType, AComment, AValuesList));
end;

procedure TgsParamList.Assign(const Source: TgsParamList);
var
  I: Integer;
begin
  // ��������, �� �������� �� � ����� ���� ��
  if Self <> Source then
  begin
    Clear;
    if Source <> nil then
    begin
      for I := 0 to Source.Count - 1 do
      begin
        AddParam('', '', prmInteger, '');
        Params[I].Assign(Source.Params[I]);
      end;
    end;
  end;
end;

function TgsParamList.Find(const AParam: TgsParamData): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
  begin
    if (AnsiCompareText(AParam.LinkTableName, Params[I].LinkTableName) = 0)
      and (AParam.LinkFunctionLanguage = Params[I].LinkFunctionLanguage)
      and (AnsiCompareText(AParam.LinkConditionFunction, Params[I].LinkConditionFunction) = 0)
      and (AnsiCompareText(AParam.LinkPrimaryField, Params[I].LinkPrimaryField) = 0)
      and (AnsiCompareText(AParam.LinkDisplayField, Params[I].LinkDisplayField) = 0)
      and (AParam.SortOrder = Params[I].SortOrder) then
    begin
      Result := I;
      break;
    end;
  end;
end;

function TgsParamList.GetParam(const I: Integer): TgsParamData;
begin
  Assert((I >= 0) and (I < Count), 'Range check error');
  Result := Items[I] as TgsParamData;
end;

function TgsParamList.GetVariantArray: Variant;
var
  I: Integer;
begin
  Result := VarArrayCreate([0, Count - 1], varVariant);
  for I := 0 to Count - 1 do
    Result[I] := Params[I].ResultValue;
end;

procedure TgsParamList.LoadFromStream(AnStream: TStream);
var
  TestLabel: array[0..Length(StartListParam) - 1 ] of Char;
begin
  Clear;
  if AnStream.Size = 0 then
    Exit;
  Assert(Length(StartListParam) = Length(FinishListParam));
  AnStream.ReadBuffer(TestLabel[0], Length(StartListParam));
  if TestLabel <> StartListParam then
    raise Exception.Create('�������� ������ ������ ����������');
  AnStream.ReadBuffer(TestLabel[0], Length(FinishListParam));
  while (AnStream.Position < AnStream.Size) and (TestLabel <> FinishListParam) do
  begin
    AnStream.Position := AnStream.Position - Length(FinishListParam);
    AddParam('', '', prmInteger, '');
    Params[Count - 1].LoadFromStream(AnStream);
    AnStream.ReadBuffer(TestLabel[0], Length(FinishListParam));
  end;
end;

procedure TgsParamList.SaveToStream(AnStream: TStream);
var
  I: Integer;
begin
  AnStream.Write(StartListParam, SizeOf(StartListParam));

  for I := 0 to Count - 1 do
    Params[I].SaveToStream(AnStream);

  AnStream.Write(FinishListParam, SizeOf(FinishListParam));
end;

procedure TgsParamList.SetParam(const I: Integer;
  const AnParam: TgsParamData);
begin
  Assert((I >= 0) and (I < Count), 'Range check error');
  (Items[I] as TgsParamData).Assign(AnParam);
end;

procedure TgsParamList.SetVariantArray(AnVarArray: Variant);
var
  I: Integer;
  MaxBound, MinBound: Integer;
begin
  if VarIsArray(AnVarArray) then
  begin
    MinBound := VarArrayLowBound(AnVarArray, 1);
    MaxBound := VarArrayHighBound(AnVarArray, 1);
    for I := 0 to Count - 1 do
      // �������� �� ������� ��������� � ������������� ��������
      if (MinBound <= I) and (MaxBound >= I) and (VarIsEmpty(Params[I].ResultValue)) then
        Params[I].ResultValue := AnVarArray[I];
  end;
end;

end.
