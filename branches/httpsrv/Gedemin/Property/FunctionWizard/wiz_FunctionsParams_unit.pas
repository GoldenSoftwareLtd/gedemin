{++

  Copyright (c) 2001 by Golden Software of Belarus

  Module

    prp_BaseFrame_unit.pas

  Abstract

    Gedemin project.

  Author

    Karpuk Alexander

  Revisions history

    1.00    30.05.03    tiptop        Initial version.
--}

unit wiz_FunctionsParams_unit;

interface

uses
  prm_ParamFunctions_unit, Classes, gd_common_functions;

type
  TwizParamData = class(TgsParamData)
  private
    FReferenceType: string;

    procedure SetReferenceType(const Value: string);

  public
    procedure Assign(const Source: TgsParamData); override;
    procedure SaveToStream(AnStream: TStream); override;
    procedure LoadFromStream(AnStream: TStream); override;

    property ReferenceType: string read FReferenceType write SetReferenceType;
  end;

  TwizParamList = class(TgsParamList)
  private
    function GetParam(const I: Integer): TwizParamData;
    procedure SetParam(const I: Integer; const Value: TwizParamData);

  public
    function AddParam(const AParamName, ADisplayName: String;
      const AParamType: TParamType; const AComment: String): Integer; override;
    function AddLinkParam(const AParamName, ADisplayName: String;
      const AParamType: TParamType; const ATableName, ADisplayField,
      APrimaryField, ALinkConditionFunction, ALinkFunctionLanguage: String;
      const AComment: String): Integer; override;
    function AddSelectParam(const AParamName, ADisplayName: String;
      const AParamType: TParamType; const AComment: String;
      const AValuesList: String): Integer; override;

    property Params[const I: Integer]: TwizParamData read GetParam write SetParam;
  end;

implementation
uses wiz_FunctionBlock_unit;
{ TwizParamData }

procedure TwizParamData.Assign(const Source: TgsParamData);
begin
  inherited;
  if Source is TwizParamData then
    FReferenceType := TwizParamData(Source).FReferenceType;
end;

procedure TwizParamData.LoadFromStream(AnStream: TStream);
begin
  inherited;
  FReferenceType := ReadStringFromStream(AnStream);
end;

procedure TwizParamData.SaveToStream(AnStream: TStream);
begin
  inherited;
  SaveStringToStream(FReferenceType, AnStream);
end;

procedure TwizParamData.SetReferenceType(const Value: string);
begin
  FReferenceType := Value;
end;

{ TwizParamList }

function TwizParamList.AddLinkParam(const AParamName, ADisplayName: String;
  const AParamType: TParamType; const ATableName, ADisplayField, APrimaryField,
  ALinkConditionFunction, ALinkFunctionLanguage: String;
  const AComment: String): Integer;
begin
  Result := Add(TwizParamData.Create(AParamName, ADisplayName, AParamType, ATableName,
    ADisplayField, APrimaryField, ALinkConditionFunction, ALinkFunctionLanguage, AComment));
end;

function TwizParamList.AddParam(const AParamName, ADisplayName: String;
  const AParamType: TParamType; const AComment: String): Integer;
begin
  Result := Add(TwizParamData.Create(AParamName, ADisplayName, AParamType, AComment));
end;

function TwizParamList.AddSelectParam(const AParamName,
  ADisplayName: String; const AParamType: TParamType; const AComment,
  AValuesList: String): Integer;
begin
  Result := Add(TwizParamData.Create(AParamName, ADisplayName, AParamType, AComment, AValuesList));
end;

function TwizParamList.GetParam(const I: Integer): TwizParamData;
begin
  Result := Items[I] as TwizParamData;
end;

procedure TwizParamList.SetParam(const I: Integer;
  const Value: TwizParamData);
begin
  (Items[I] as TwizParamData).Assign(value);
end;

end.
