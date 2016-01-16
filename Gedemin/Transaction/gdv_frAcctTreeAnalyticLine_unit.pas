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

function Tgdv_frAcctTreeAnalyticLine.CheckValue(S: String): Boolean;
var
  Strings: TStrings;
  I: Integer;
begin
  S := StringReplace(S, ' ', '', [rfReplaceAll]);

  Result := S > '';

  if Result then
  begin
    Strings := TStringList.Create;
    try
      Strings.CommaText := S;
      for I := 0 to Strings.Count - 1 do
      begin
        try
          if StrToInt(Strings[I]) < 0 then
          begin
            Result := False;
            break;
          end;
        except
          Result := False;
          break;
        end;
      end;
    finally
      Strings.Free;
    end;
  end;
end;

function Tgdv_frAcctTreeAnalyticLine.IsEmpty: Boolean;
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

function Tgdv_frAcctTreeAnalyticLine.SPName: String;
begin
  Assert(FField <> nil);
  Assert(FField.References <> nil);
  Result := Format('AC_LEDGER_%s', [FField.References.RelationName]);
end;

procedure Tgdv_frAcctTreeAnalyticLine.eLevelChange(Sender: TObject);
begin
  if FLevels <> nil then
    FLevels.Clear;
end;

destructor Tgdv_frAcctTreeAnalyticLine.Destroy;
begin
  FLevels.Free;
  inherited;
end;

function Tgdv_frAcctTreeAnalyticLine.GetLevels: TStrings;
begin
  if not CheckValue(eLevel.Text) then
    raise Exception.Create('Уровни аналитики должны быть заданы одним или несколькими ' +
      'последовательными целочисленными значениями, через запятую.'#13#10#13#10 +
      'Например: 1 или 1,2,3 и т.п.');

  if FLevels = nil then
    FLevels := TStringList.Create;

  if FLevels.Count = 0 then
    FLevels.CommaText := StringReplace(eLevel.Text, ' ', '', [rfReplaceAll]);

  Result := FLevels;
end;

end.
