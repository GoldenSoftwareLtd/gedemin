unit gdcStyle;

interface

uses
  Windows, Classes, gdcBase, gdcBaseInterface, gd_ClassList;
type
  TgdcStyleObject = class(TgdcBase)
  public
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
  end;

  TgdcStyle = class(TgdcBase)
  protected
    procedure GetWhereClauseConditions(S: TStrings); override;

  public
    class function GetSubSetList: String; override;
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('gdc', [TgdcStyleObject, TgdcStyle]);
end;

{ TgdcStyleObject }

class function TgdcStyleObject.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmStyleObject';
end;

class function TgdcStyleObject.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'AT_STYLE_OBJECT';
end;

class function TgdcStyleObject.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'OBJNAME';
end;

{ TgdcStyle }

class function TgdcStyle.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'AT_STYLE';
end;

class function TgdcStyle.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'ID';
end;

class function TgdcStyle.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + 'ByStyleObject;';
end;

procedure TgdcStyle.GetWhereClauseConditions(S: TStrings);
begin
  inherited;

  if HasSubSet('ByStyleObject') then
    S.Add('Z.OBJECTKEY = :OBJECTKEY');
end;

initialization
  RegisterGDCClass(TgdcStyleObject);
  RegisterGDCClass(TgdcStyle);

finalization
  UnregisterGdcClass(TgdcStyleObject);
  UnRegisterGDCClass(TgdcStyle);

end.
