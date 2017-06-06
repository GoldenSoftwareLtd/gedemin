unit gdc_dlgInvRemainsOption_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgG_unit, Menus, Db, ActnList, StdCtrls, gdc_dlgTR_unit, IBDatabase,
  Mask, DBCtrls, ComCtrls, gsIBLookupComboBox, at_Classes;

type
  Tgdc_dlgInvRemainsOption = class(Tgdc_dlgTR)
    pcMain: TPageControl;
    tsCommon: TTabSheet;
    tsViewFeatures: TTabSheet;
    tsSumFeatures: TTabSheet;
    Label1: TLabel;
    dbedName: TDBEdit;
    Label2: TLabel;
    gsIBLookupComboBox1: TgsIBLookupComboBox;
    actAddViewFeatures: TAction;
    actDelViewFeatures: TAction;
    actAddAllViewFeatures: TAction;
    actDelAllViewFeatures: TAction;
    actAddSumFeatures: TAction;
    actDelSumFeatures: TAction;
    actAddAllSumFeatures: TAction;
    actDelAllSumFeatures: TAction;
    pcViewFeatures: TPageControl;
    tsViewCard: TTabSheet;
    lvFeatures: TListView;
    btnAdd: TButton;
    btnAddAll: TButton;
    btnRemove: TButton;
    btnRemoveAll: TButton;
    lvUsedFeatures: TListView;
    tsViewGood: TTabSheet;
    lvGoodFeatures: TListView;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    lvUsedGoodFeatures: TListView;
    actAddGoodViewFeatures: TAction;
    actDelGoodViewFeatures: TAction;
    actAddAllGoodViewFeatures: TAction;
    actDelAllGoodViewFeatures: TAction;
    pcSumFeatures: TPageControl;
    TabSheet1: TTabSheet;
    lvSumFeatures: TListView;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    lvUsedSumFeatures: TListView;
    TabSheet2: TTabSheet;
    lvGoodSumFeatures: TListView;
    Button9: TButton;
    Button10: TButton;
    Button11: TButton;
    Button12: TButton;
    lvUsedGoodSumFeatures: TListView;
    actAddGoodSumFeatures: TAction;
    actDelGoodSumFeatures: TAction;
    actAddAllGoodSumFeatures: TAction;
    actDelAllGoodSumFeatures: TAction;
    DBCheckBox1: TDBCheckBox;
    lblRestrictBy: TLabel;
    luRestrictBy: TComboBox;
    procedure actAddViewFeaturesExecute(Sender: TObject);
    procedure actDelViewFeaturesExecute(Sender: TObject);
    procedure actAddAllViewFeaturesExecute(Sender: TObject);
    procedure actDelAllViewFeaturesExecute(Sender: TObject);
    procedure actAddSumFeaturesExecute(Sender: TObject);
    procedure actDelSumFeaturesExecute(Sender: TObject);
    procedure actAddAllSumFeaturesExecute(Sender: TObject);
    procedure actDelAllSumFeaturesExecute(Sender: TObject);
    procedure actAddGoodViewFeaturesExecute(Sender: TObject);
    procedure actDelGoodViewFeaturesExecute(Sender: TObject);
    procedure actAddAllGoodViewFeaturesExecute(Sender: TObject);
    procedure actDelAllGoodViewFeaturesExecute(Sender: TObject);
    procedure actAddGoodSumFeaturesExecute(Sender: TObject);
    procedure actDelGoodSumFeaturesExecute(Sender: TObject);
    procedure actAddAllGoodSumFeaturesExecute(Sender: TObject);
    procedure actDelAllGoodSumFeaturesExecute(Sender: TObject);
  private
    { Private declarations }
    FViewFeatures, FSumFeatures, FViewGoodFeatures, FGoodSumFeatures: TStringList;
    procedure UpdateViewFeatureList;
    procedure UpdateGoodViewFeatureList;
    procedure UpdateSumFeatureList;
    procedure UpdateGoodSumFeatureList;

    procedure AddFeature(UsedFeatures, Features: TListView);
    procedure RemoveFeature(UsedFeatures, Features: TListView);
    procedure PrepareDialog;
    procedure SetupFeaturesTab;
    function FindFeature(FeatureName: String;
      const FindUsedFeature: Boolean = False;
      const isView: Boolean = True; const isGood: Boolean = False): TListItem;

    procedure ReadOptions;
    procedure WriteOptions;
        
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure SetupDialog; override;
    procedure SetupRecord; override;
    function TestCorrect: Boolean; override;
    
  end;

var
  gdc_dlgInvRemainsOption: Tgdc_dlgInvRemainsOption;

implementation

{$R *.DFM}

uses
  gd_ClassList, IBHeader, gdcBaseInterface, IBSQL;

{ Tgdc_dlgInvRemainsOption }

{Находит последнее вхождение символа в строку. Необходимо для поиска "(" и ")",
т.к. эти символы могут быть использованы в локализованном наименовании поля}  
function LastCharPos(const Ch: Char; const S: String): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := Length(S) downto 1 do
  begin
    if Ch = S[I] then
    begin
      Result := I;
      break;
    end;
  end;
end;

procedure Tgdc_dlgInvRemainsOption.AddFeature(UsedFeatures,
  Features: TListView);
var
  Item: TListItem;
  Index: Integer;
begin
  if Features.Items.Count = 0 then
    Exit;
  if not Assigned(Features.Selected) then
    Exit;

  Item := UsedFeatures.Items.Add;
  Item.Caption := Features.Selected.Caption;
  Item.Data := Features.Selected.Data;

  Index := Features.Selected.Index;
  Features.Selected.Delete;

  if Index < Features.Items.Count then
    Features.Selected := Features.Items[Index] else
  if Features.Items.Count > 0 then
    Features.Selected := Features.Items[Features.Items.Count - 1];

end;

constructor Tgdc_dlgInvRemainsOption.Create(AOwner: TComponent);
begin
  inherited;
  FViewFeatures := TStringList.Create;
  FSumFeatures := TStringList.Create;
  FViewGoodFeatures := TStringList.Create;
  FGoodSumFeatures := TStringList.Create;
end;

destructor Tgdc_dlgInvRemainsOption.Destroy;
begin
  FViewFeatures.Free;
  FSumFeatures.Free;
  FViewGoodFeatures.Free;
  FGoodSumFeatures.Free;
  
  inherited;
end;

function Tgdc_dlgInvRemainsOption.FindFeature(FeatureName: String;
  const FindUsedFeature, isView, isGood: Boolean): TListItem;
var
  I: Integer;
  List: TListView;
begin
  if isView then
  begin
    if isGood then
    begin
      if FindUsedFeature then
        List := lvUsedGoodFeatures
      else
        List := lvGoodFeatures
    end
    else
    begin
      if FindUsedFeature then
        List := lvUsedFeatures
      else
        List := lvFeatures
    end
  end
  else
  begin
    if isGood then
    begin
      if FindUsedFeature then
        List := lvUsedGoodSumFeatures
      else
        List := lvGoodSumFeatures
    end
    else
    begin
      if FindUsedFeature then
        List := lvUsedSumFeatures
      else
        List := lvSumFeatures
    end
  end;

  for I := 0 to List.Items.Count - 1 do
    if AnsiCompareText(TatRelationField(List.Items[I].Data).FieldName, FeatureName) = 0 then
    begin
      Result := List.Items[I];
      Exit;
    end;

  Result := nil;
end;

procedure Tgdc_dlgInvRemainsOption.PrepareDialog;
var
  I: Integer;
  Item: TListItem;
  Relation: TatRelation;
  RestrictBy: string;
  ibsql: TIBSQL;
begin
  { TODO : Ограничить поля для суммирования }
  pcMain.ActivePage := tsCommon;
  pcViewFeatures.ActivePageIndex := 0;
  pcSumFeatures.ActivePageIndex := 0;

  // Общая страница

  lvFeatures.Items.Clear;
  lvSumFeatures.Items.Clear;
  lvGoodFeatures.Items.Clear;
  lvGoodSumFeatures.Items.Clear;
  luRestrictBy.Items.Clear;

  Relation := atDatabase.Relations.ByRelationName('INV_CARD');
  Assert(Relation <> nil);

  ibsql := TIBSQL.Create(nil);
  try
    ibsql.Transaction := gdcBaseManager.ReadTransaction;
    ibsql.SQL.Text := 'SELECT ind.RDB$INDEX_NAME ' +
      'FROM RDB$INDICES ind ' +
      'JOIN RDB$INDEX_SEGMENTS inds ON ind.RDB$INDEX_NAME = inds.RDB$INDEX_NAME ' +
      'WHERE ind.RDB$RELATION_NAME = :RELATION_NAME ' +
      'and inds.RDB$FIELD_NAME = :FIELD_NAME ';

    for I := 0 to Relation.RelationFields.Count - 1 do
    begin
      ibsql.ParamByName('RELATION_NAME').Value := 'INV_CARD';
      ibsql.ParamByName('FIELD_NAME').Value := Relation.RelationFields[I].FieldName;
      ibsql.ExecQuery;
      if (Relation.RelationFields[I].Field.FieldType in [ftSmallint, ftInteger, ftWord, ftFloat, ftCurrency, ftBCD, ftLargeint])
        and (ibsql.RecordCount > 0) then
        luRestrictBy.Items.Add(Relation.RelationFields[I].LShortName +
          '('+Relation.RelationFields[I].FieldName+')');

      ibsql.Close;
     end;

  finally
    ibsql.free;
  end;

  for I := 0 to Relation.RelationFields.Count - 1 do
  begin
    if not Relation.RelationFields[I].IsUserDefined then
      Continue;

    Item := lvFeatures.Items.Add;

    if Relation.RelationFields[I].LShortName > '' then
      Item.Caption := Relation.RelationFields[I].LShortName
    else
      Item.Caption := Relation.RelationFields[I].FieldName;

    Item.Data := Relation.RelationFields[I];

    Item := lvSumFeatures.Items.Add;

    if Relation.RelationFields[I].LShortName > '' then
      Item.Caption := Relation.RelationFields[I].LShortName
    else
      Item.Caption := Relation.RelationFields[I].FieldName;

    Item.Data := Relation.RelationFields[I];

  end;

  Relation := atDatabase.Relations.ByRelationName('GD_GOOD');
  Assert(Relation <> nil);

  for I := 0 to Relation.RelationFields.Count - 1 do
  begin
//    if not Relation.RelationFields[I].IsUserDefined then
//      Continue;

    Item := lvGoodFeatures.Items.Add;

    if Relation.RelationFields[I].LShortName > '' then
      Item.Caption := Relation.RelationFields[I].LShortName
    else
      Item.Caption := Relation.RelationFields[I].FieldName;

    Item.Data := Relation.RelationFields[I];

    Item := lvGoodSumFeatures.Items.Add;

    if Relation.RelationFields[I].LShortName > '' then
      Item.Caption := Relation.RelationFields[I].LShortName
    else
      Item.Caption := Relation.RelationFields[I].FieldName;

    Item.Data := Relation.RelationFields[I];

  end;

  lvUsedFeatures.Items.Clear;
  lvUsedSumFeatures.Items.Clear;
  lvUsedGoodFeatures.Items.Clear;
  lvUsedGoodSumFeatures.Items.Clear;

  RestrictBy := dsgdcBase.DataSet.FieldByName('restrictremainsby').AsString;

  if RestrictBy > '' then
  begin
    for I := 0 to luRestrictBy.Items.Count - 1 do
      if Pos('(' + RestrictBy + ')', luRestrictBy.Items[I]) > 0 then
      begin
        luRestrictBy.ItemIndex := I;
        break;
      end;
  end;
end;

procedure Tgdc_dlgInvRemainsOption.ReadOptions;
var
  F: TatRelationField;
  Stream: TStringStream;
begin
  Stream := TStringStream.Create(dsgdcBase.DataSet.FieldByName('viewfields').AsString);
  try
    with TReader.Create(Stream, 1024) do
    try
      ReadListBegin;
      while not EndOfList do
      begin
        F := atDatabase.FindRelationField('INV_CARD', ReadString);
        if not Assigned(F) then Continue;
        FViewFeatures.AddObject(F.FieldName, F);
      end;
      ReadListEnd;
    finally
      Free;
    end;
  finally
    Stream.Free;
  end;

  Stream := TStringStream.Create(dsgdcBase.DataSet.FieldByName('goodviewfields').AsString);
  try
    with TReader.Create(Stream, 1024) do
    try
      if Stream.Size > 0 then
      begin
        ReadListBegin;
        while not EndOfList do
        begin
          F := atDatabase.FindRelationField('GD_GOOD', ReadString);
          if not Assigned(F) then Continue;
          FViewGoodFeatures.AddObject(F.FieldName, F);
        end;
        ReadListEnd;
      end
    finally
      Free;
    end;
  finally
    Stream.Free;
  end;

  Stream := TStringStream.Create(dsgdcBase.DataSet.FieldByName('sumfields').AsString);
  try
    with TReader.Create(Stream, 1024) do
    try
      ReadListBegin;
      while not EndOfList do
      begin
        F := atDatabase.FindRelationField('INV_CARD', ReadString);
        if not Assigned(F) then Continue;
        FSumFeatures.AddObject(F.FieldName, F);
      end;
      ReadListEnd;
    finally
      Free;
    end;
  finally
    Stream.Free;
  end;

  Stream := TStringStream.Create(dsgdcBase.DataSet.FieldByName('goodsumfields').AsString);
  try
    with TReader.Create(Stream, 1024) do
    try
      if Stream.Size > 0 then
      begin
        ReadListBegin;
        while not EndOfList do
        begin
          F := atDatabase.FindRelationField('GD_GOOD', ReadString);
          if not Assigned(F) then Continue;
          FGoodSumFeatures.AddObject(F.FieldName, F);
        end;
        ReadListEnd;
      end
    finally
      Free;
    end;
  finally
    Stream.Free;
  end;

  SetupFeaturesTab;
end;

procedure Tgdc_dlgInvRemainsOption.RemoveFeature(UsedFeatures,
  Features: TListView);
var
  Item: TListItem;
  Index: Integer;
begin
  if UsedFeatures.Items.Count = 0 then
    Exit;
  if not Assigned(UsedFeatures.Selected) then
    Exit;
  Item := Features.Items.Add;
  Item.Caption := UsedFeatures.Selected.Caption;
  Item.Data := UsedFeatures.Selected.Data;

  Index := UsedFeatures.Selected.Index;
  UsedFeatures.Selected.Delete;

  if Index < UsedFeatures.Items.Count then
    UsedFeatures.Selected := UsedFeatures.Items[Index] else
  if UsedFeatures.Items.Count > 0 then
    UsedFeatures.Selected := UsedFeatures.Items[UsedFeatures.Items.Count - 1];

end;

procedure Tgdc_dlgInvRemainsOption.SetupDialog;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGINVREMAINSOPTION', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGINVREMAINSOPTION', KEYSETUPDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGINVREMAINSOPTION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGINVREMAINSOPTION',
  {M}          'SETUPDIALOG', KEYSETUPDIALOG, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGINVREMAINSOPTION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;

  PrepareDialog;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGINVREMAINSOPTION', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGINVREMAINSOPTION', 'SETUPDIALOG', KEYSETUPDIALOG);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgInvRemainsOption.SetupFeaturesTab;
var
  I: Integer;
  Item, UsedItem: TListItem;
  R: TatRelation;
begin
  lvFeatures.Items.Clear;
  lvUsedFeatures.Items.Clear;

  R := atDatabase.Relations.ByRelationName('INV_CARD');
  Assert(Assigned(R));

  with R do
  begin
    for I := 0 to RelationFields.Count - 1 do
    begin
      if not RelationFields[I].IsUserDefined then Continue;
      Item := lvFeatures.Items.Add;
      Item.Caption := RelationFields[I].LName;
      Item.Data := RelationFields[I];
    end;
  end;

  for I := 0 to FViewFeatures.Count - 1 do
  begin
    Item := FindFeature(FViewFeatures[I]);
    if not Assigned(Item) then Continue;

    UsedItem := lvUsedFeatures.Items.Add;
    UsedItem.Caption := Item.Caption;
    UsedItem.Data := Item.Data;
    Item.Delete;
  end;

  lvSumFeatures.Items.Clear;
  lvUsedSumFeatures.Items.Clear;

  with R do
  begin
    for I := 0 to RelationFields.Count - 1 do
    begin
      if not RelationFields[I].IsUserDefined then Continue;
      if not Assigned(RelationFields[I].References) and
        not (RelationFields[i].Field.SQLType in [blr_timestamp, blr_date, blr_sql_date, blr_sql_time])
      then
      begin
        Item := lvSumFeatures.Items.Add;
        Item.Caption := RelationFields[I].LName;
        Item.Data := RelationFields[I];
      end
    end;
  end;

  for I := 0 to FSumFeatures.Count - 1 do
  begin
    Item := FindFeature(FSumFeatures[I], False, False);
    if not Assigned(Item) then Continue;

    UsedItem := lvUsedSumFeatures.Items.Add;
    UsedItem.Caption := Item.Caption;
    UsedItem.Data := Item.Data;
    Item.Delete;
  end;

///
  lvGoodFeatures.Items.Clear;
  lvUsedGoodFeatures.Items.Clear;

  R := atDatabase.Relations.ByRelationName('GD_GOOD');
  Assert(Assigned(R));

  with R do
  begin
    for I := 0 to RelationFields.Count - 1 do
    begin
//      if not RelationFields[I].IsUserDefined then Continue;
      Item := lvGoodFeatures.Items.Add;
      Item.Caption := RelationFields[I].LName;
      Item.Data := RelationFields[I];
    end;
  end;

  for I := 0 to FViewGoodFeatures.Count - 1 do
  begin
    Item := FindFeature(FViewGoodFeatures[I], False, True, True);
    if not Assigned(Item) then Continue;

    UsedItem := lvUsedGoodFeatures.Items.Add;
    UsedItem.Caption := Item.Caption;
    UsedItem.Data := Item.Data;
    Item.Delete;
  end;

  lvGoodSumFeatures.Items.Clear;
  lvUsedGoodSumFeatures.Items.Clear;

  with R do
  begin
    for I := 0 to RelationFields.Count - 1 do
    begin
//      if not RelationFields[I].IsUserDefined then Continue;
      if not Assigned(RelationFields[I].References) and
        not (RelationFields[i].Field.SQLType in [blr_timestamp, blr_date, blr_sql_date, blr_sql_time])
      then
      begin
        Item := lvGoodSumFeatures.Items.Add;
        Item.Caption := RelationFields[I].LName;
        Item.Data := RelationFields[I];
      end
    end;
  end;

  for I := 0 to FGoodSumFeatures.Count - 1 do
  begin
    Item := FindFeature(FGoodSumFeatures[I], False, False, True);
    if not Assigned(Item) then Continue;
    UsedItem := lvUsedGoodSumFeatures.Items.Add;
    UsedItem.Caption := Item.Caption;
    UsedItem.Data := Item.Data;
    Item.Delete;
  end;

end;

procedure Tgdc_dlgInvRemainsOption.SetupRecord;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGINVREMAINSOPTION', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGINVREMAINSOPTION', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGINVREMAINSOPTION') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGINVREMAINSOPTION',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGINVREMAINSOPTION' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  if dsgdcBase.DataSet.State = dsEdit then
    ReadOptions;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGINVREMAINSOPTION', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGINVREMAINSOPTION', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgInvRemainsOption.UpdateSumFeatureList;
var
  i: Integer;
begin

  FSumFeatures.Clear;

  for I := 0 to lvUsedSumFeatures.Items.Count - 1 do
  with lvUsedSumFeatures.Items[I] do
    FSumFeatures.AddObject(TatRelationField(Data).FieldName, TatRelationField(Data));

end;

procedure Tgdc_dlgInvRemainsOption.UpdateViewFeatureList;
var
  i: Integer;
begin

  FViewFeatures.Clear;

  for I := 0 to lvUsedFeatures.Items.Count - 1 do
  with lvUsedFeatures.Items[I] do
    FViewFeatures.AddObject(TatRelationField(Data).FieldName, TatRelationField(Data));

end;

procedure Tgdc_dlgInvRemainsOption.actAddViewFeaturesExecute(
  Sender: TObject);
begin
  inherited;
  AddFeature(lvUsedFeatures, lvFeatures);
  UpdateViewFeatureList;
end;

procedure Tgdc_dlgInvRemainsOption.actDelViewFeaturesExecute(
  Sender: TObject);
begin
  RemoveFeature(lvUsedFeatures, lvFeatures);
  UpdateViewFeatureList;
end;

procedure Tgdc_dlgInvRemainsOption.actAddAllViewFeaturesExecute(
  Sender: TObject);
var
  Item: TListItem;
  I: Integer;
begin
  for I := 0 to lvFeatures.Items.Count - 1 do
  begin
    Item := lvUsedFeatures.Items.Add;
    Item.Caption := lvFeatures.Items[I].Caption;
    Item.Data := lvFeatures.Items[I].Data;
  end;

  lvFeatures.Items.Clear;

  UpdateViewFeatureList;
end;

procedure Tgdc_dlgInvRemainsOption.actDelAllViewFeaturesExecute(
  Sender: TObject);
var
  Item: TListItem;
  I: Integer;
begin
  for I := 0 to lvUsedFeatures.Items.Count - 1 do
  begin
    Item := lvFeatures.Items.Add;
    Item.Caption := lvUsedFeatures.Items[I].Caption;
    Item.Data := lvUsedFeatures.Items[I].Data;
  end;

  lvUsedFeatures.Items.Clear;

  UpdateViewFeatureList;
end;

procedure Tgdc_dlgInvRemainsOption.actAddSumFeaturesExecute(
  Sender: TObject);
begin
  AddFeature(lvUsedSumFeatures, lvSumFeatures);
  UpdateSumFeatureList;
end;

procedure Tgdc_dlgInvRemainsOption.actDelSumFeaturesExecute(
  Sender: TObject);
begin
  RemoveFeature(lvUsedSumFeatures, lvSumFeatures);
  UpdateSumFeatureList;
end;

procedure Tgdc_dlgInvRemainsOption.actAddAllSumFeaturesExecute(
  Sender: TObject);
var
  Item: TListItem;
  I: Integer;
begin
  for I := 0 to lvSumFeatures.Items.Count - 1 do
  begin
    Item := lvUsedSumFeatures.Items.Add;
    Item.Caption := lvSumFeatures.Items[I].Caption;
    Item.Data := lvSumFeatures.Items[I].Data;
  end;

  lvSumFeatures.Items.Clear;

  UpdateSumFeatureList;
end;

procedure Tgdc_dlgInvRemainsOption.actDelAllSumFeaturesExecute(
  Sender: TObject);
var
  Item: TListItem;
  I: Integer;
begin
  for I := 0 to lvUsedSumFeatures.Items.Count - 1 do
  begin
    Item := lvSumFeatures.Items.Add;
    Item.Caption := lvUsedSumFeatures.Items[I].Caption;
    Item.Data := lvUsedSumFeatures.Items[I].Data;
  end;

  lvUsedSumFeatures.Items.Clear;

  UpdateSumFeatureList;
end;

procedure Tgdc_dlgInvRemainsOption.WriteOptions;
var
  Stream: TStringStream;
  i: Integer;
  S, F: Integer;
begin
 if luRestrictBy.ItemIndex <> -1 then
    begin
      S := LastCharPos('(', luRestrictBy.Items[luRestrictBy.ItemIndex]);
      F := LastCharPos(')', luRestrictBy.Items[luRestrictBy.ItemIndex]);
      dsgdcBase.DataSet.FieldByName('restrictremainsby').AsString := Copy(luRestrictBy.Items[luRestrictBy.ItemIndex], S + 1, F - S - 1);
    end
 else
  dsgdcBase.DataSet.FieldByName('restrictremainsby').AsString := '';

  Stream := TStringStream.Create('');
  try
    with TWriter.Create(Stream, 1024) do
    try
      WriteListBegin;

      for I := 0 to FViewFeatures.Count - 1 do
        WriteString(FViewFeatures[I]);

      WriteListEnd;

    finally
      Free;
    end;
    dsgdcBase.DataSet.FieldByName('viewfields').AsString := Stream.DataString;
  finally
    Stream.Free;
  end;

  Stream := TStringStream.Create('');
  try
    with TWriter.Create(Stream, 1024) do
    try
      WriteListBegin;

      for I := 0 to FViewGoodFeatures.Count - 1 do
        WriteString(FViewGoodFeatures[I]);

      WriteListEnd;

    finally
      Free;
    end;
    dsgdcBase.DataSet.FieldByName('goodviewfields').AsString := Stream.DataString;
  finally
    Stream.Free;
  end;


  Stream := TStringStream.Create('');
  try
    with TWriter.Create(Stream, 1024) do
    try
      WriteListBegin;

      for I := 0 to FSumFeatures.Count - 1 do
        WriteString(FSumFeatures[I]);

      WriteListEnd;

    finally
      Free;
    end;
    dsgdcBase.DataSet.FieldByName('sumfields').AsString := Stream.DataString;
  finally
    Stream.Free;
  end;

  Stream := TStringStream.Create('');
  try
    with TWriter.Create(Stream, 1024) do
    try
      WriteListBegin;

      for I := 0 to FGoodSumFeatures.Count - 1 do
        WriteString(FGoodSumFeatures[I]);

      WriteListEnd;

    finally
      Free;
    end;
    dsgdcBase.DataSet.FieldByName('goodsumfields').AsString := Stream.DataString;
  finally
    Stream.Free;
  end;

end;

function Tgdc_dlgInvRemainsOption.TestCorrect: Boolean;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_TESTCORRECT('TGDC_DLGINVREMAINSOPTION', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}Result := True;
  {M}try
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}  begin
  {M}    SetFirstMethodAssoc('TGDC_DLGINVREMAINSOPTION', KEYTESTCORRECT);
  {M}    tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYTESTCORRECT]);
  {M}    if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGINVREMAINSOPTION') = -1) then
  {M}    begin
  {M}      Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}      if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGINVREMAINSOPTION',
  {M}        'TESTCORRECT', KEYTESTCORRECT, Params, LResult) then
  {M}      begin
  {M}        if VarType(LResult) = $000B then
  {M}          Result := LResult;
  {M}        exit;
  {M}      end;
  {M}    end else
  {M}      if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGINVREMAINSOPTION' then
  {M}      begin
  {M}        Result := Inherited TestCorrect;
  {M}        Exit;
  {M}      end;
  {M}  end;
  {END MACRO}
  Result := True;
  if not (dsgdcBase.DataSet.State in [dsEdit, dsInsert]) then
    dsgdcBase.DataSet.Edit;
    
  WriteOptions;

  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGINVREMAINSOPTION', 'TESTCORRECT', KEYTESTCORRECT)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGINVREMAINSOPTION', 'TESTCORRECT', KEYTESTCORRECT);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgInvRemainsOption.actAddGoodViewFeaturesExecute(
  Sender: TObject);
begin
  inherited;
  AddFeature(lvUsedGoodFeatures, lvGoodFeatures);
  UpdateGoodViewFeatureList;
end;

procedure Tgdc_dlgInvRemainsOption.UpdateGoodSumFeatureList;
var
  i: Integer;
begin
  FGoodSumFeatures.Clear;
  for I := 0 to lvUsedGoodSumFeatures.Items.Count - 1 do
  with lvUsedGoodSumFeatures.Items[I] do
    FGoodSumFeatures.AddObject(TatRelationField(Data).FieldName, TatRelationField(Data));
end;

procedure Tgdc_dlgInvRemainsOption.UpdateGoodViewFeatureList;
var
  i: Integer;
begin
  FViewGoodFeatures.Clear;

  for I := 0 to lvUsedGoodFeatures.Items.Count - 1 do
  with lvUsedGoodFeatures.Items[I] do
    FViewGoodFeatures.AddObject(TatRelationField(Data).FieldName, TatRelationField(Data));
end;

procedure Tgdc_dlgInvRemainsOption.actDelGoodViewFeaturesExecute(
  Sender: TObject);
begin
  inherited;
  RemoveFeature(lvUsedGoodFeatures, lvGoodFeatures);
  UpdateGoodViewFeatureList;
end;

procedure Tgdc_dlgInvRemainsOption.actAddAllGoodViewFeaturesExecute(
  Sender: TObject);
var
  Item: TListItem;
  I: Integer;
begin
  for I := 0 to lvGoodFeatures.Items.Count - 1 do
  begin
    Item := lvUsedGoodFeatures.Items.Add;
    Item.Caption := lvGoodFeatures.Items[I].Caption;
    Item.Data := lvGoodFeatures.Items[I].Data;
  end;

  lvGoodFeatures.Items.Clear;

  UpdateGoodViewFeatureList;

end;

procedure Tgdc_dlgInvRemainsOption.actDelAllGoodViewFeaturesExecute(
  Sender: TObject);
var
  Item: TListItem;
  I: Integer;
begin
  for I := 0 to lvUsedGoodFeatures.Items.Count - 1 do
  begin
    Item := lvGoodFeatures.Items.Add;
    Item.Caption := lvUsedGoodFeatures.Items[I].Caption;
    Item.Data := lvUsedGoodFeatures.Items[I].Data;
  end;

  lvUsedGoodFeatures.Items.Clear;

  UpdateGoodViewFeatureList;

end;

procedure Tgdc_dlgInvRemainsOption.actAddGoodSumFeaturesExecute(
  Sender: TObject);
begin
  inherited;
  AddFeature(lvUsedGoodSumFeatures, lvGoodSumFeatures);
  UpdateGoodSumFeatureList;

end;

procedure Tgdc_dlgInvRemainsOption.actDelGoodSumFeaturesExecute(
  Sender: TObject);
begin
  inherited;
  RemoveFeature(lvUsedGoodSumFeatures, lvGoodSumFeatures);
  UpdateGoodSumFeatureList;

end;

procedure Tgdc_dlgInvRemainsOption.actAddAllGoodSumFeaturesExecute(
  Sender: TObject);
var
  Item: TListItem;
  I: Integer;
begin
  for I := 0 to lvGoodSumFeatures.Items.Count - 1 do
  begin
    Item := lvUsedGoodSumFeatures.Items.Add;
    Item.Caption := lvGoodSumFeatures.Items[I].Caption;
    Item.Data := lvGoodSumFeatures.Items[I].Data;
  end;

  lvGoodSumFeatures.Items.Clear;

  UpdateGoodSumFeatureList;

end;

procedure Tgdc_dlgInvRemainsOption.actDelAllGoodSumFeaturesExecute(
  Sender: TObject);
var
  Item: TListItem;
  I: Integer;
begin
  for I := 0 to lvUsedGoodSumFeatures.Items.Count - 1 do
  begin
    Item := lvGoodSumFeatures.Items.Add;
    Item.Caption := lvUsedGoodSumFeatures.Items[I].Caption;
    Item.Data := lvUsedGoodSumFeatures.Items[I].Data;
  end;

  lvUsedGoodSumFeatures.Items.Clear;

  UpdateGoodSumFeatureList;
end;

initialization
  RegisterFrmClass(Tgdc_dlgInvRemainsOption);

finalization
  UnRegisterFrmClass(Tgdc_dlgInvRemainsOption);


end.
