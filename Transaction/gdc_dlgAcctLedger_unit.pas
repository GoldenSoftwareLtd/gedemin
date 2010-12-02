unit gdc_dlgAcctLedger_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgBaseAcctConfig, IBDatabase, Menus, Db, ActnList, StdCtrls, Mask,
  DBCtrls, gdv_frameBaseAnalitic_unit, gdv_frameQuantity_unit, gd_ClassList,
  gdv_frameSum_unit, ComCtrls, gdv_frameAnalyticValue_unit, gdv_AcctConfig_unit,
  gdv_frAcctBaseAnalyticGroup, gdv_dlgfrAcctAnalyticsGroup_unit,
  gsIBLookupComboBox, AcctStrings, gdv_frAcctTreeAnalyticLine_unit,
  contnrs, at_classes, gdv_AvailAnalytics_unit, Math;

type
  TdlgAcctLedgerConfig = class(TdlgBaseAcctConfig)
    cbShowDebit: TCheckBox;
    cbShowCredit: TCheckBox;
    cbShowCorrSubAccounts: TCheckBox;
    frAnalyticsGroup: TdlgfrAcctAnalyticsGroup;
    tsAdditional: TTabSheet;
    gbTreeAnalytic: TGroupBox;
    sbTreeAnalitic: TScrollBox;
    gbAnalyticGroupListField: TGroupBox;
    gbOtherParameters: TGroupBox;
    cbEnchancedSaldo: TCheckBox;
    cbSumNull: TCheckBox;
    sbAnalyticGroupListField: TScrollBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FTreeAnalyticLineList: TObjectList;
    FAnalyticListFieldList: TObjectList;
    function GetTreeAnalitic: string;
    procedure SetTreeAnalitic(const Value: string);
    function GetAnaliticListField: string;
    procedure SetAnaliticListField(const Value: string);
  protected
    class function ConfigClassName: string; override;
    procedure UpdateControls; override;
    procedure UpdateTreeAnalytic(AnalyticsList: TgdvAnalyticsList);
    procedure UpdateAnalyticListField(AnalyticsList: TgdvAnalyticsList);

    procedure DoLoadConfig(const Config: TBaseAcctConfig);override;
    procedure DoSaveConfig(Config: TBaseAcctConfig);override;
    procedure OnAnalyticGroupSelect(Sender: TObject);

    property TreeAnalitic: string read GetTreeAnalitic write SetTreeAnalitic;
    property AnaliticListField: string read GetAnaliticListField write SetAnaliticListField;
  public
    { Public declarations }
    function TestCorrect: Boolean; override;
  end;

var
  dlgAcctLedgerConfig: TdlgAcctLedgerConfig;

implementation

{$R *.DFM}


uses
  {$IFDEF LOCALIZATION}
  {must be placed after Windows unit!}
  gd_localization_stub,
  {$ENDIF}
  gdv_frAcctAnalyticListField_unit;


{ TdlgAcctLedgerConfig }

class function TdlgAcctLedgerConfig.ConfigClassName: string;
begin
  Result := 'TAccLedgerConfig';
end;

procedure TdlgAcctLedgerConfig.DoLoadConfig(const Config: TBaseAcctConfig);
var
  C: TAccLedgerConfig;
begin
  inherited;
  if Config is TAccLedgerConfig then
  begin
    C := Config as TAccLedgerConfig;
    with C do
    begin
      cbShowDebit.Checked := ShowDebit;
      cbShowCredit.Checked := ShowCredit;
      cbShowCorrSubAccounts.Checked := ShowCorrSubAccounts;
      AnalyticsGroup.Position := 0;
      frAnalyticsGroup.LoadFromStream(AnalyticsGroup);
      cbSumNull.Checked := SumNull;
      cbEnchancedSaldo.Checked := EnchancedSaldo;
      Self.TreeAnalitic := TreeAnalytic;
      Self.AnaliticListField := AnalyticListField;
    end;
  end;
end;

procedure TdlgAcctLedgerConfig.DoSaveConfig(Config: TBaseAcctConfig);
var
  C: TAccLedgerConfig;
begin
  inherited;
  if Config is TAccLedgerConfig then
  begin
    C := Config as TAccLedgerConfig;
    with C do
    begin
      ShowDebit := cbShowDebit.Checked;
      ShowCredit := cbShowCredit.Checked;
      ShowCorrSubAccounts := cbShowCorrSubAccounts.Checked;
      AnalyticsGroup.Size := 0;
      frAnalyticsGroup.SaveToStream(AnalyticsGroup);
      SumNull := cbSumNull.Checked;
      EnchancedSaldo := cbEnchancedSaldo.Checked;
      TreeAnalytic := Self.TreeAnalitic;
      AnalyticListField := Self.AnaliticListField;
    end;
  end;
end;

function TdlgAcctLedgerConfig.TestCorrect: Boolean;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_TESTCORRECT('TDLGACCTLEDGERCONFIG', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}Result := True;
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TDLGACCTLEDGERCONFIG', KEYTESTCORRECT);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYTESTCORRECT]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TDLGACCTLEDGERCONFIG') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TDLGACCTLEDGERCONFIG',
  {M}        'TESTCORRECT', KEYTESTCORRECT, Params, LResult) then
  {M}      begin
  {M}        if VarType(LResult) = $000B then
  {M}          Result := LResult;
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TDLGACCTLEDGERCONFIG' then
  {M}      begin
  {M}        Result := Inherited TestCorrect;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}

  Result := inherited TestCorrect;
  if Result then
  begin
    if frAnalyticsGroup.Selected.Count = 0 then
    begin
      MessageBox(0,
        PChar(MSG_INPUTANGROUPANALYTIC),
        'Внимание',
        MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
      Result := False;
    end
  end;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TDLGACCTLEDGERCONFIG', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TDLGACCTLEDGERCONFIG', 'TESTCORRECT', KEYTESTCORRECT);
  {M}end;
  {END MACRO}
end;

procedure TdlgAcctLedgerConfig.UpdateControls;
begin
  inherited;
  frAnalyticsGroup.UpdateAnalyticsList(FAccountIDs);
end;

procedure TdlgAcctLedgerConfig.FormCreate(Sender: TObject);
begin
  inherited;
  frAnalyticsGroup.OnSelect := OnAnalyticGroupSelect;
end;

procedure TdlgAcctLedgerConfig.OnAnalyticGroupSelect(Sender: TObject);
begin
  UpdateTreeAnalytic(frAnalyticsGroup.Selected);
  UpdateAnalyticListField(frAnalyticsGroup.Selected);
end;

procedure TdlgAcctLedgerConfig.UpdateTreeAnalytic(AnalyticsList: TgdvAnalyticsList);
var
  I, Index: Integer;
  F: TatRelationField;
  LList: TObjectList;
  Line: Tgdv_frAcctTreeAnalyticLine;
  H, W: Integer;
  P: Integer;

  function IndexOf(F: TatRelationField): Integer;
  var
    I: Integer;
  begin
    Result := -1;
    for I := 0 to LList.Count - 1 do
    begin
      if Tgdv_frAcctTreeAnalyticLine(LList[I]).Field = F then
      begin
        Result := I;
        Exit;
      end;
    end;
  end;

begin
  P := 0;
  if FTreeAnalyticLineList = nil then
    FTreeAnalyticLineList := TObjectList.Create;

  LList := TObjectList.Create;
  try
    for I := FTreeAnalyticLineList.Count - 1 downto 0 do
    begin
      LList.Add(FTreeAnalyticLineList[I]);
      FTreeAnalyticLineList.Extract(FTreeAnalyticLineList[I]);
    end;

    for I := 0 to AnalyticsList.Count - 1 do
    begin
      F := AnalyticsList[i].Field;
      if F <> nil then
      begin
        if (F.References <> nil) and
          (F.References.IsLBRBTreeRelation) then
        begin
          Index := IndexOf(F);
          if Index > - 1 then
          begin
            Line := Tgdv_frAcctTreeAnalyticLine(LList[Index]);
            LList.Extract(Line);
          end else
          begin
            Line := Tgdv_frAcctTreeAnalyticLine.Create(nil);
            Line.Parent := sbTreeAnalitic;
            Line.Name := 'gdv_frAcctTreeAnalyticLine_' + StringReplace(F.FieldName, '$', '_', [rfReplaceAll]);
            Line.Field := F;
            Line.Color := sbTreeAnalitic.Color;

          end;
          FTreeAnalyticLineList.Add(Line);

          with Line do
          begin
            H := Height;
            Top := P;
          end;
          P := P + H;
        end;
      end;
    end;

  finally
    LList.Free;
  end;

  W := 0;
  for I := 0 to sbTreeAnalitic.ControlCount - 1 do
  begin
    W := Max(Tgdv_frAcctTreeAnalyticLine(sbTreeAnalitic.Controls[i]).lAnaliticName.Left +
      Tgdv_frAcctTreeAnalyticLine(sbTreeAnalitic.Controls[i]).lAnaliticName.Width, W);
  end;
  W := W + 5;

  for I := 0 to sbTreeAnalitic.ControlCount - 1 do
  begin
    Tgdv_frAcctTreeAnalyticLine(sbTreeAnalitic.Controls[i]).eLevel.Left := W;
    Tgdv_frAcctTreeAnalyticLine(sbTreeAnalitic.Controls[i]).eLevel.Width :=
      Tgdv_frAcctTreeAnalyticLine(sbTreeAnalitic.Controls[i]).ClientWidth - 2 - W;
  end;
//  SortLine;
//  UpdateTabOrder;
end;

procedure TdlgAcctLedgerConfig.UpdateAnalyticListField(AnalyticsList: TgdvAnalyticsList);
var
  LList: TObjectList;
  FrameLine: Tgdv_frAcctAnalyticListField;
  FieldCounter, FrameCounter, FrameIndex: Integer;
  F: TatRelationField;
  H, W, P: Integer;

  function IndexOf(F: TatRelationField): Integer;
  var
    I: Integer;
  begin
    Result := -1;
    for I := 0 to LList.Count - 1 do
    begin
      if Tgdv_frAcctAnalyticListField(LList[I]).AnalyticField = F then
      begin
        Result := I;
        Exit;
      end;
    end;
  end;

begin
  P := 0;
  if not Assigned(FAnalyticListFieldList) then
    FAnalyticListFieldList := TObjectList.Create;

  LList := TObjectList.Create;
  try
    // Перекинем все уже существующие фреймы во временный список
    for FrameCounter := FAnalyticListFieldList.Count - 1 downto 0 do
    begin
      LList.Add(FAnalyticListFieldList[FrameCounter]);
      FAnalyticListFieldList.Extract(FAnalyticListFieldList[FrameCounter]);
    end;
    // Пройдем по выбранным группировочным аналитикам
    for FieldCounter := 0 to AnalyticsList.Count - 1 do
    begin
      F := AnalyticsList[FieldCounter].Field;
      // Будем обрабатывать только поля-ссылки
      if Assigned(F) and Assigned(F.References) then
      begin
        FrameIndex := IndexOf(F);
        if FrameIndex > -1 then
        begin
          FrameLine := Tgdv_frAcctAnalyticListField(LList[FrameIndex]);
          LList.Extract(FrameLine);
        end
        else
        begin
          FrameLine := Tgdv_frAcctAnalyticListField.Create(nil);
          FrameLine.Parent := sbAnalyticGroupListField;
          FrameLine.Name := 'gdv_frAcctAnalyticListField_' + StringReplace(F.FieldName, '$', '_', [rfReplaceAll]);
          FrameLine.AnalyticField := F;
          FrameLine.Color := sbAnalyticGroupListField.Color;
        end;
        FAnalyticListFieldList.Add(FrameLine);

        with FrameLine do
        begin
          H := Height;
          Top := P;
        end;
        Inc(P, H);
      end;
    end;
  finally
    FreeAndNil(LList);
  end;

  // Установим ширину созданных контроллов
  W := 0;
  for FrameCounter := 0 to sbAnalyticGroupListField.ControlCount - 1 do
  begin
    W := Max(Tgdv_frAcctAnalyticListField(sbAnalyticGroupListField.Controls[FrameCounter]).lAnaliticName.Left +
      Tgdv_frAcctAnalyticListField(sbAnalyticGroupListField.Controls[FrameCounter]).lAnaliticName.Width, W);
  end;
  W := W + 5;
  for FrameCounter := 0 to sbAnalyticGroupListField.ControlCount - 1 do
  begin
    Tgdv_frAcctAnalyticListField(sbAnalyticGroupListField.Controls[FrameCounter]).cbListFieldName.Left := W;
    Tgdv_frAcctAnalyticListField(sbAnalyticGroupListField.Controls[FrameCounter]).cbListFieldName.Width :=
      Tgdv_frAcctAnalyticListField(sbAnalyticGroupListField.Controls[FrameCounter]).ClientWidth - 2 - W;
  end;    
end;

procedure TdlgAcctLedgerConfig.FormDestroy(Sender: TObject);
begin
  if Assigned(FTreeAnalyticLineList) then
    FreeAndNil(FTreeAnalyticLineList);
  if Assigned(FAnalyticListFieldList) then
    FreeAndNil(FAnalyticListFieldList);
  inherited;
end;

function TdlgAcctLedgerConfig.GetTreeAnalitic: string;
var
  I: Integer;
  Line: Tgdv_frAcctTreeAnalyticLine;
  S: TStrings;
begin
  Result := '';
  if FTreeAnalyticLineList <> nil then
  begin
    S := TStringList.Create;
    try
      for I := 0 to FTreeAnalyticLineList.Count - 1 do
      begin
        Line := Tgdv_frAcctTreeAnalyticLine(FTreeAnalyticLineList[I]);
        if not Line.IsEmpty then
        begin
          S.Add(Line.Field.FieldName + '=' + Line.eLevel.Text);
        end;
      end;
      if S.Count > 0 then
      begin
        Result := S.Text;
      end;
    finally
      S.Free;
    end;
  end;
end;

procedure TdlgAcctLedgerConfig.SetTreeAnalitic(const Value: string);
var
  S: TStrings;
  I: Integer;
  A, V: string;
  J: Integer;
  Line: Tgdv_frAcctTreeAnalyticLine;
begin
  if FTreeAnalyticLineList <> nil then
  begin
    S := TStringList.Create;
    try
      S.Text := Value;
      for I := 0 to S.Count - 1 do
      begin
        A := S.Names[I];
        V := S.Values[A];

        for J := 0 to FTreeAnalyticLineList.Count - 1 do
        begin
          Line := Tgdv_frAcctTreeAnalyticLine(FTreeAnalyticLineList[J]);
          if Line.Field.FieldName = A then
          begin
            Line.eLevel.Text := V;
            Break;
          end;
        end;
      end;
    finally
      S.Free;
    end;
  end;
end;

function TdlgAcctLedgerConfig.GetAnaliticListField: string;
var
  I: Integer;
  Line: Tgdv_frAcctAnalyticListField;
  S: TStrings;
begin
  Result := '';
  if Assigned(FAnalyticListFieldList) then
  begin
    S := TStringList.Create;
    try
      for I := 0 to FAnalyticListFieldList.Count - 1 do
      begin
        Line := Tgdv_frAcctAnalyticListField(FAnalyticListFieldList[I]);
        if not Line.IsEmpty then
          S.Add(Line.AnalyticField.FieldName + '=' + Line.ListField);
      end;
      if S.Count > 0 then
      begin
        Result := S.Text;
      end;
    finally
      S.Free;
    end;
  end;
end;

procedure TdlgAcctLedgerConfig.SetAnaliticListField(const Value: string);
var
  S: TStrings;
  I: Integer;
  A, V: string;
  J: Integer;
  Line: Tgdv_frAcctAnalyticListField;
begin
  if Assigned(FAnalyticListFieldList) then
  begin
    S := TStringList.Create;
    try
      S.Text := Value;
      for I := 0 to S.Count - 1 do
      begin
        A := S.Names[I];
        V := S.Values[A];

        for J := 0 to FAnalyticListFieldList.Count - 1 do
        begin
          Line := Tgdv_frAcctAnalyticListField(FAnalyticListFieldList[J]);
          if AnsiCompareText(Line.AnalyticField.FieldName, A) = 0 then
          begin
            Line.ListField := V;
            Break;
          end;
        end;
      end;
    finally
      S.Free;
    end;
  end;
end;

initialization
  RegisterFrmClass(TdlgAcctLedgerConfig);

finalization
  UnRegisterFrmClass(TdlgAcctLedgerConfig);

end.
