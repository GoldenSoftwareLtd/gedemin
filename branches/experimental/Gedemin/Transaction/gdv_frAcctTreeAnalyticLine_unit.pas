unit gdv_frAcctTreeAnalyticLine_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, at_classes, IBSQL, gdcBaseInterface, IBDataBase, AcctStrings,
  mdf_MetaData_unit;

type
  Tgdv_frAcctTreeAnalyticLine = class(TFrame)
    lAnaliticName: TLabel;
    eLevel: TEdit;
    procedure eLevelChange(Sender: TObject);
  private
    FField: TatRelationField;
    FLevels: TStrings;
    procedure SetField(const Value: TatRelationField);
    function CheckValue(S: string): Boolean;
    function GetLevels: TStrings;
  public
    destructor Destroy; override;
    function IsEmpty: boolean;

    procedure CheckProcedure;
    function SPName: string;

    property Field: TatRelationField read FField write SetField;
    property Levels: TStrings read GetLevels;
  end;

implementation

{$R *.DFM}

{ Tgdv_frAcctTreeAnalyticLine }

procedure Tgdv_frAcctTreeAnalyticLine.CheckProcedure;
var
  SP: TmdfStoredProcedure;
begin
  if not IsEmpty then
  begin
    SP.ProcedureName := SPName;
    if not ProcedureExist(SP, gdcBaseManager.Database) then
    begin
      SP.Description := Format(cStoredProcedureTemplate, [FField.References.RelationName,
        FField.ReferencesField.FieldName]);
      CreateProcedure(SP, gdcBaseManager.Database);
    end;
  end;
end;

function Tgdv_frAcctTreeAnalyticLine.CheckValue(S: string): Boolean;
var
  Strings: TStrings;
  V: string;
  I: Integer;
begin
  Result := Trim(S) > '';
  if Result then
  begin
    Strings := TStringList.Create;
    try
      Strings.Text := StringReplace(S, ',', #13#10, [rfReplaceAll]);
      for I := 0 to Strings.Count - 1 do
      begin
        V := Trim(Strings[I]);
        try
          StrToInt(V);
        except
          Result := False;
          Exit;
        end;
      end;
    finally
      Strings.Free;
    end;
  end;
end;

function Tgdv_frAcctTreeAnalyticLine.IsEmpty: boolean;
begin
  Result := not CheckValue(eLevel.Text);
end;

procedure Tgdv_frAcctTreeAnalyticLine.SetField(
  const Value: TatRelationField);
begin
  FField := Value;
  if (FField <> nil) and (FField.References <> nil) and
    (FField.References.IsLBRBTreeRelation) then
  begin
    lAnaliticName.Caption := FField.LName + ':';
  end;
end;

function Tgdv_frAcctTreeAnalyticLine.SPName: string;
begin
  Result := Format('AC_LEDGER_%s', [FField.References.RelationName]);
end;

procedure Tgdv_frAcctTreeAnalyticLine.eLevelChange(Sender: TObject);
begin
  if FLevels <> nil then
  begin
    FLevels.Clear;
  end;
end;

destructor Tgdv_frAcctTreeAnalyticLine.Destroy;
begin
  FLevels.Free;
  inherited;
end;

function Tgdv_frAcctTreeAnalyticLine.GetLevels: TStrings;
var
  I: Integer;
begin
  if FLevels = nil then
    FLevels := TStringList.Create;

  if FLevels.Count = 0 then
  begin
    FLevels.Text := StringReplace(eLevel.Text, ',', #13#10, [rfReplaceAll]);
    for I := 0 to Flevels.Count - 1 do
    begin
      FLevels[I] := Trim(FLevels[I]);
    end;
  end;
  Result := FLevels;
end;

end.
