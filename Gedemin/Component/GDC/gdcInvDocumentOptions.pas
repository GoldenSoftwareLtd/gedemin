unit gdcInvDocumentOptions;

interface

uses
  Classes, gdcBaseInterface, gdcBase;

type
  TgdcInvDocumentOptions = class(TgdcBase)
  public
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
  end;

procedure Register;

implementation

uses
  gd_ClassList;

procedure Register;
begin
  RegisterComponents('gdc', [TgdcInvDocumentOptions]);
end;

{ TgdcInvDocumentOptions }

class function TgdcInvDocumentOptions.GetListField(
  const ASubType: TgdcSubType): String;
begin
  Result := 'OPTION_NAME';
end;

class function TgdcInvDocumentOptions.GetListTable(
  const ASubType: TgdcSubType): String;
begin
  Result := 'GD_DOCUMENTTYPE_OPTION';
end;

initialization
  RegisterGdcClass(TgdcInvDocumentOptions, 'Параметры складского документа');

finalization
  UnregisterGdcClass(TgdcInvDocumentOptions);
end.
