
unit gdcBase_PropEditor;

interface

uses
  Classes, DsgnIntf, gdcBase, gd_ClassList;

type
  TgdcSubSetProperty = class(TPropertyEditor)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure GetValues(Proc: TGetStrProc); override;
    function GetValue: String; override;
    procedure SetValue(const Value: String); override;
  end;

  TgdcClassNameProperty = class(TPropertyEditor)
  private
    function BuildClassTree(ACE: TgdClassEntry; AData: Pointer): Boolean;

  public
    function GetAttributes: TPropertyAttributes; override;
    procedure GetValues(Proc: TGetStrProc); override;
    function GetValue: String; override;
    procedure SetValue(const Value: String); override;

  end;


procedure Register;

implementation

uses
  gsIBLookupComboBox, gdcBaseInterface;

function GetNextSubSet(const S: String; var P: Integer): String;
var
  B: Integer;
begin
  B := P;
  while (P <= Length(S)) and (S[P] <> ';') do Inc(P);
  Result := Copy(S, B, P - B);
  Inc(P);
end;

{ TgdcSubSetProperty }

function TgdcSubSetProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paValueList, paSortList, paRevertable];
end;

function TgdcSubSetProperty.GetValue: String;
begin
  if (PropCount > 0) and (GetComponent(0) is TgdcBase) then
  begin
   // if GetPropInfo.Name = 'SubSet' then
      Result := (GetComponent(0) as TgdcBase).SubSet
   { else
      Result := (GetComponent(0) as TgdcBase).SearchSubSet;}
  end else
    Result := inherited GetValue;
end;

procedure TgdcSubSetProperty.GetValues(Proc: TGetStrProc);
var
  S: String;
  P: Integer;
begin
  if (PropCount > 0) and (GetComponent(0) is TgdcBase) then
  begin
    S := (GetComponent(0) as TgdcBase).GetSubSetList;
    P := 1;
    while P <= Length(S) do
      Proc(GetNextSubSet(S, P));
  end;
end;

procedure TgdcSubSetProperty.SetValue(const Value: String);
begin
  if (PropCount > 0) and (GetComponent(0) is TgdcBase) then
  begin
    {if GetPropInfo.Name = 'SubSet' then}
      (GetComponent(0) as TgdcBase).SubSet := Value;
{    else
      (GetComponent(0) as TgdcBase).SearchSubSet := Value;}
    Modified;
  end else
    inherited;
end;

procedure Register;
begin
  RegisterPropertyEditor(TypeInfo(TgdcSubSet), TgdcBase, 'SubSet', TgdcSubSetProperty);
  //RegisterPropertyEditor(TypeInfo(TgdcSubSet), TgdcBase, 'SearchSubSet', TgdcSubSetProperty);
  RegisterPropertyEditor(TypeInfo(TgdcClassName), TgsIBLookupComboBox, 'gdClassName', TgdcClassNameProperty);
end;

{ TgdcClassNameProperty }

function TgdcClassNameProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paValueList, paSortList, paRevertable];
end;

function TgdcClassNameProperty.GetValue: String;
begin
  if (PropCount > 0) and (GetComponent(0) is TgsIBLookupComboBox) then
  begin
    Result := (GetComponent(0) as TgsIBLookupComboBox).gdClassName;
  end else
    Result := inherited GetValue;
end;

function TgdcClassNameProperty.BuildClassTree(ACE: TgdClassEntry; AData: Pointer): Boolean;
begin
  if (ACE <> nil) then
    TGetStrProc(AData^)(ACE.gdcClass.ClassName);

  Result := True;
end;

procedure TgdcClassNameProperty.GetValues(Proc: TGetStrProc);
begin
  gdClassList.Traverse(TgdcBase, '', BuildClassTree, @Proc);
end;

procedure TgdcClassNameProperty.SetValue(const Value: String);
begin
  if (PropCount > 0) and (GetComponent(0) is TgsIBLookupComboBox) then
  begin
    (GetComponent(0) as TgsIBLookupComboBox).gdClassName := Value;
    Modified;
  end else
    inherited;
end;

end.
