unit gdcAcctConfig;

interface

uses
  gdcBaseInterface, gdcBase;

type
  TgdcBaseAcctConfig = class(TgdcBase)
  public
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function IsAbstractClass: Boolean; override;

    function GetCurrRecordClass: TgdcFullClass; override;
  end;

implementation

uses
  gd_ClassList, gdcLedger, gdcInvMovement;

function TgdcBaseAcctConfig.GetCurrRecordClass: TgdcFullClass;
begin
  Result.gdClass := CgdcBase(Self.ClassType);
  Result.SubType := SubType;

  if not IsEmpty then
  begin
    if FieldByName('classname').AsString = 'TAccLedgerConfig' then
      Result.gdClass := TgdcAcctLedgerConfig
    else if FieldByName('classname').AsString = 'TAccCardConfig' then
      Result.gdClass := TgdcAcctAccConfig
    else if FieldByName('classname').AsString = 'TAccCirculationListConfig' then
      Result.gdClass := TgdcAcctCicrilationListConfig
    else if FieldByName('classname').AsString = 'TAccGeneralLedgerConfig' then
      Result.gdClass := TgdcAcctGeneralLedgerConfig
    else if FieldByName('classname').AsString = 'TAccReviewConfig' then
      Result.gdClass := TgdcAcctAccReviewConfig
    else if FieldByName('classname').AsString = 'TInvCardConfig' then
      Result.gdClass := TgdcInvCardConfig
    else
      raise EgdcException.CreateObj('Invalid acct config class', Self);
  end;

  FindInheritedSubType(Result);
end;

class function TgdcBaseAcctConfig.GetListField(
  const ASubType: TgdcSubType): String;
begin
  Result := 'NAME'
end;

class function TgdcBaseAcctConfig.GetListTable(
  const ASubType: TgdcSubType): String;
begin
  Result := 'AC_ACCT_CONFIG'
end;

class function TgdcBaseAcctConfig.IsAbstractClass: Boolean;
begin
  Result := Self.ClassName = 'TgdcBaseAcctConfig';
end;

initialization
  RegisterGdcClass(TgdcBaseAcctConfig);

finalization
  UnregisterGdcClass(TgdcBaseAcctConfig);
end.