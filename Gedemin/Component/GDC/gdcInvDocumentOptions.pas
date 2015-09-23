unit gdcInvDocumentOptions;

interface

uses
  Classes, gdcBaseInterface, gdcBase;

type
  TgdcInvDocumentTypeOptions = class(TgdcBase)
  protected
    procedure GetWhereClauseConditions(S: TStrings); override;
    
  public
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetSubSetList: String; override;
  end;

procedure Register;

implementation

uses
  gd_ClassList;

procedure Register;
begin
  RegisterComponents('gdc', [TgdcInvDocumentTypeOptions]);
end;

{ TgdcInvDocumentTypeOptions }

class function TgdcInvDocumentTypeOptions.GetListField(
  const ASubType: TgdcSubType): String;
begin
  Result := 'OPTION_NAME';
end;

class function TgdcInvDocumentTypeOptions.GetListTable(
  const ASubType: TgdcSubType): String;
begin
  Result := 'GD_DOCUMENTTYPE_OPTION';
end;

class function TgdcInvDocumentTypeOptions.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + 'ByDocumentType;';
end;

procedure TgdcInvDocumentTypeOptions.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  if HasSubSet('ByDocumentType') then
    S.Add('z.dtkey = :DocumentTypeKey');
end;

initialization
  RegisterGdcClass(TgdcInvDocumentTypeOptions, 'Параметры типа складского документа');

finalization
  UnregisterGdcClass(TgdcInvDocumentTypeOptions);
end.
