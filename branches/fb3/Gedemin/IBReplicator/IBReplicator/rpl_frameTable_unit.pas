unit rpl_frameTable_unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, SuperPageControl, TB2Dock, TB2Toolbar, ComCtrls, ExtCtrls,
  ImgList, Grids, DBGrids, TB2Item, ActnList, XPListView, StdCtrls, XPEdit,
  rpl_frameTableData_unit, IBDataBase, rplDBGrid, xpDBGrid, DB,
  IBCustomDataSet, rpl_BaseTypes_unit, rpl_const, rpl_ReplicationManager_unit,
  rpl_mnRelations_unit, rpl_ResourceString_unit;

type
  TframeTable = class(TFrame)
    PageControl: TSuperPageControl;
    tsFields: TSuperTabSheet;
    tsConstraints: TSuperTabSheet;
    tsIndices: TSuperTabSheet;
    tsDependencies: TSuperTabSheet;
    tsData: TSuperTabSheet;
    tsPrimaryKey: TSuperTabSheet;
    tsForeignKey: TSuperTabSheet;
    tsChecks: TSuperTabSheet;
    tsUniques: TSuperTabSheet;
    frameTableData: TframeTableData;
    pcConstraints: TSuperPageControl;
    pCaption: TPanel;
    Panel1: TPanel;
    gFields: TxpDBGrid;
    dsFields: TDataSource;
    dFields: TIBDataSet;
    Panel2: TPanel;
    gPrimeKeys: TxpDBGrid;
    dsPrimeKeys: TDataSource;
    dPrimeKeys: TIBDataSet;
    Panel3: TPanel;
    gForeignKeys: TxpDBGrid;
    dsForeignKeys: TDataSource;
    dForeignKey: TIBDataSet;
    Panel4: TPanel;
    gChecks: TxpDBGrid;
    dsChecks: TDataSource;
    dChecks: TIBDataSet;
    Panel5: TPanel;
    gUnique: TxpDBGrid;
    dsUniques: TDataSource;
    dUnique: TIBDataSet;
    Panel6: TPanel;
    gIndices: TxpDBGrid;
    pDepend: TPanel;
    sDepend: TSplitter;
    Panel8: TPanel;
    Panel9: TPanel;
    Splitter3: TSplitter;
    Panel10: TPanel;
    pDependOn: TPanel;
    pDependsOn: TPanel;
    dFieldsFIELDNAME: TIBStringField;
    dFieldsFIELDPOSITION: TSmallintField;
    dFieldsDESCRIPTION: TMemoField;
    dFieldsDEFAULTVALUE: TBlobField;
    dFieldsSYSTEMFLAG: TSmallintField;
    dFieldsNULLFLAG: TSmallintField;
    dFieldsDEFAULTSOURCE: TMemoField;
    dFieldsCOMPUTEDSOURCE: TMemoField;
    dFieldsFIELDLENGTH: TSmallintField;
    dFieldsDOMANENAME: TIBStringField;
    dFieldsFIELDPRECISION: TSmallintField;
    dFieldsFIELDTYPE: TSmallintField;
    dFieldsFIELDSUBTYPE: TSmallintField;
    dFieldsCHARSET: TIBStringField;
    dFieldsCOLLATENAME: TIBStringField;
    dFieldsFIELDTYPE_CALC: TStringField;
    dFieldsFIELDSUBTYPE_CALC: TStringField;
    dFieldsFIELDNULLFLAG: TSmallintField;
    dFieldsNOTNULL: TStringField;
    dFieldsCOMPETEDSOURCE_CALC: TStringField;
    dFieldsDEFAULTSOURCE_CALC: TStringField;
    dFieldsDOMANEDEFAULTSOURCE: TMemoField;
    dFieldsPK: TStringField;
    dFieldsFK: TStringField;
    dFieldsDESCRIPTION_CALC: TStringField;
    dPrimeKeysCONSTAINTNAME: TIBStringField;
    dPrimeKeysFIELDNAME: TIBStringField;
    dForeignKeyRELATIONNAME: TIBStringField;
    dForeignKeyFIELDNAME: TIBStringField;
    dForeignKeyREFRELATIONNAME: TIBStringField;
    dForeignKeyREFFIELDNAME: TIBStringField;
    dForeignKeyCONSTRAINTNAME: TIBStringField;
    dForeignKeyUPDATERULE: TIBStringField;
    dForeignKeyDELETERULE: TIBStringField;
    dChecksCONSTAINTNAME: TIBStringField;
    dChecksCHECKCLAUSE: TMemoField;
    dChecksCHECKCLAUSE_CALC: TStringField;
    dUniqueCONSTAINTNAME: TIBStringField;
    dUniqueFIELDNAME: TIBStringField;
    dIndices: TIBDataSet;
    dsIndices: TDataSource;
    dIndicesINDEXNAME: TIBStringField;
    dIndicesFIELDNAME: TIBStringField;
    dIndicesUNIQUEFLAG: TSmallintField;
    dIndicesEXPRESSIONSOURCE: TMemoField;
    dIndicesINDEXINACTIVE: TSmallintField;
    dIndicesEXPRESSIONSOURCE_CALC: TStringField;
    dIndicesUNIQUEFLAG_CALC: TStringField;
    dIndicesINDEXINACTIVE_CALC: TStringField;
    lbDependOn: TListBox;
    lbDependsOn: TListBox;
    DataSet: TIBDataSet;
    procedure PageControlChange(Sender: TObject);
    procedure dFieldsCalcFields(DataSet: TDataSet);
    procedure dFieldsAfterScroll(DataSet: TDataSet);
    procedure pcConstraintsChange(Sender: TObject);
    procedure dChecksCalcFields(DataSet: TDataSet);
    procedure dIndicesCalcFields(DataSet: TDataSet);
    procedure lbDependOnClick(Sender: TObject);

  private
    FRelationName: string;
    FTransaction: TIBTransaction;
    FReopen: Boolean;

    FRelation: TmnRelation;
    FDepend: TframeTable;
    FSQLInited: Boolean;
    FDidActivate: Boolean;

    procedure SetRelationName(const Value: string);
    procedure SetTransaction(const Value: TIBTransaction);

    procedure ReOpenDataSets;
    procedure ReBuildDependences;
    procedure ShowDepend(Show: Boolean);

    procedure SelectSQL(DataSet: TIBDataSet);
    procedure DeleteSQL(DataSet: TIBDataSet);
    procedure ModefySQL(DataSet: TIBDataSet);
    procedure InsertSQL(DataSet: TIBDataSet);

    procedure InitSQL(ADataSet: TIBDataSet);
    procedure CheckTransaction;
  public
    constructor Create(AOwner: TComponent); override;


    procedure UpdateVisible;
    property RelationName: string read FRelationName write SetRelationName;
    property Transaction: TIBTransaction read FTransaction write SetTransaction;
  end;

implementation

{$R *.dfm}

{ TframeTable }

procedure TframeTable.SetRelationName(const Value: string);
begin
  FRelationName := Value;
  frameTableData.RelationName := Value;
  FReopen := True;
  FSQLInited := False;
  FRelation := ReplicationManager.Relations.FindRelation(FRelationName);
  if Frelation = nil then
    raise Exception.Create(Format(InvalidRelationName, [FRelation]));
end;

procedure TframeTable.SetTransaction(const Value: TIBTransaction);
begin
  FTransaction := Value;
  frameTableData.Transaction := Value;
  dFields.Transaction := Value;
  dPrimeKeys.Transaction := Value;
  dForeignKey.Transaction := Value;
  dChecks.Transaction := Value;
  dUnique.Transaction := Value;
  dIndices.Transaction := Value;
  DataSet.Transaction := Value;
  
  FReopen := True;
end;

procedure TframeTable.PageControlChange(Sender: TObject);
begin
  if (FRelation <> nil) and (Transaction <> nil) then
  begin
    if PageControl.ActivePage = tsData then
    begin
      InitSQL(DataSet);
      DataSet.Open;
    end else
    if PageControl.ActivePage = tsFields then
    begin
      ReOpenDataSets;
      dFields.Open;
    end else
    if PageControl.ActivePage = tsConstraints then
    begin
      pcConstraints.ActivePage := tsPrimaryKey;
    end else
    if PageControl.ActivePage = tsIndices then
    begin
      ReOpenDataSets;
      dIndices.Open;
    end
  end;  
end;

constructor TframeTable.Create(AOwner: TComponent);
begin
  inherited;

  PageControl.ActivePage := tsData;
end;

procedure TframeTable.ReOpenDataSets;
begin
  if FReopen then
  begin
    CheckTransaction;
    
    if dFields.Active then
      dFields.Close;

    dFields.SelectSQL.Text := SELECT_RELATION_FIELDS;
    dFields.ParamByName(fnRelationName).AsString := FRelationName;

    if dPrimeKeys.Active then
      dPrimeKeys.Close;

    dPrimeKeys.ParamByName(fnrelationName).AsString := FRelationName;

    if dForeignKey.Active then
      dForeignKey.Close;

    dForeignKey.ParamByName(fnRelationName).AsString := FRelationName;

    if dChecks.Active then
      dChecks.Close;

    dChecks.ParamByName(fnRelationName).AsString := FRelationName;

    if dUnique.Active then
      dUnique.Close;

    dUnique.ParamByName(fnRelationName).AsString := FRelationName;

    if dIndices.Active then
      dIndices.Close;

    dIndices.ParamByName(fnRelationName).AsString := FRelationName;

    ReBuildDependences;

    FReopen := False;
  end;
end;

procedure TframeTable.dFieldsCalcFields(DataSet: TDataSet);
var
  Index: Integer;
  F: TmnField;
begin
  DataSet.FieldByName(fnFieldtype_calc).AsString := FieldTypeStr(DataSet.FieldByName(fnFieldType).AsInteger);
  DataSet.FieldByName(fnFieldsubtype_calc).AsString := FieldSubTypeStr(
    DataSet.FieldByName(fnFieldType).AsInteger,
    DataSet.FieldByName(fnFieldSubType).AsInteger);
  if (DataSet.FieldByName(fnDomanenullflag).AsInteger = 1) or
    (DataSet.FieldByName(fnFieldnullflag).AsInteger = 1) then
  begin
    DataSet.FieldByName(fnNotnull).AsString := 'x';
  end else
    DataSet.FieldByName(fnNotnull).AsString := 'p';
  DataSet.FieldByName(fnComputedsource_calc).AsString :=
    DataSet.FieldByName(fnComputedsource).AsString;
  if DataSet.FieldByName(fnFielddefaultsource).AsString <>  '' then
    DataSet.FieldByName(fnDefaultsource_calc).AsString :=
      DataSet.FieldByName(fnFielddefaultsource).AsString
  else
    DataSet.FieldByName(fnDefaultsource_calc).AsString :=
      DataSet.FieldByName(fnDomanedefaultsource).AsString;

  DataSet.FieldByName(fnDescription_calc).AsString :=
    DataSet.FieldByName(fnDescription).AsString;
  if FRelation <> nil then
  begin
    Index := FRelation.Fields.IndexOfField(Trim(DataSet.FieldByName(fnFieldName).AsString));
    if Index > - 1 then
    begin
      F :=  TmnField(FRelation.Fields[Index]);
      if F.IsPrimeKey then
        DataSet.FieldByName(fnpk).AsString := 'x';
      if F.IsForeign then
        DataSet.FieldByName(fnfk).AsString := 'x';
    end;
  end;
end;

procedure TframeTable.dFieldsAfterScroll(DataSet: TDataSet);
begin
  if (DataSet.FieldByName(fndomanenullflag).AsInteger = 1) or
    (DataSet.FieldByName(fnfieldnullflag).AsInteger = 1) then
    pCaption.Caption := Format(' %s %s %s', [
      Trim(DataSet.FieldByName(fnFieldName).AsString),
      Trim(DataSet.FieldByName(fnDomaneName).AsString),
      'NOT NULL'])
  else
    pCaption.Caption := Format(' %s %s', [
      Trim(DataSet.FieldByName(fnFieldName).AsString),
      Trim(DataSet.FieldByName(fnDomaneName).AsString)])
end;

procedure TframeTable.pcConstraintsChange(Sender: TObject);
begin
  if pcConstraints.ActivePage = tsPrimaryKey then
  begin
    ReOpenDataSets;
    dPrimeKeys.Open;
  end else
  if pcConstraints.ActivePage = tsForeignKey then
  begin
    ReOpenDataSets;
    dForeignKey.Open;
  end else
  if pcConstraints.ActivePage = tsChecks then
  begin
    ReOpenDataSets;
    dChecks.Open;
  end else
  if pcConstraints.ActivePage = tsUniques then
  begin
    ReOpenDataSets;
    dForeignKey.Open;
  end
end;

procedure TframeTable.dChecksCalcFields(DataSet: TDataSet);
begin
  DataSet.FieldByName('CHECKCLAUSE_CALC').AsString :=
    DataSet.FieldByName('CHECKCLAUSE').AsString
end;

procedure TframeTable.dIndicesCalcFields(DataSet: TDataSet);
begin
  DataSet.FieldByName('expressionsource_calc').AsString :=
    DataSet.FieldByName('expressionsource').AsString;

  if DataSet.FieldByName('indexinactive').AsInteger = 0 then
    DataSet.FieldByName('indexinactive_calc').AsString := 'x'
  else
    DataSet.FieldByName('indexinactive_calc').AsString := 'p';
  if DataSet.FieldByName('uniqueflag').AsInteger = 1 then
    DataSet.FieldByName('uniqueflag_calc').AsString := 'x'
  else
    DataSet.FieldByName('uniqueflag_calc').AsString := 'p'
end;

procedure TframeTable.ReBuildDependences;
var
  I, J: Integer;
  R: TmnRelation;
  F: TmnField;
begin
  if FDepend <> nil then
  begin
    FreeandNil(FDepend);
    ShowDepend(False);
  end;

  pDependOn.Caption := Format(CAPTION_DEPEND_ON, [FrelationName]);
  pDependsOn.Caption := Format(CAPTION_DEPENDS_ON, [FrelationName]);
  
  if FRelation <> nil then
  begin
    lbDependOn.Items.BeginUpdate;
    try
      lbDependOn.Items.Clear;
      for I := 0 to ReplicationManager.Relations.Count - 1 do
      begin
        R := TmnRelation(ReplicationManager.Relations[I]);
        if R <> FRelation then
        begin
          for J := 0 to R.Fields.Count -  1 do
          begin
            F := TmnField(R.Fields[J]);
            if (F.IsForeign) and (F.ReferenceField.Relation = FRelation) and
              (lbDependOn.Items.IndexOfObject(R) = - 1) then
            begin
              lbDependOn.Items.AddObject(R.RelationName, R);
              Break;
            end;
          end;
        end;
      end;
    finally
      lbDependOn.Items.EndUpdate;
    end;

    lbDependsOn.Items.BeginUpdate;
    try
      lbDependsOn.Items.Clear;
      for I := 0 to FRelation.Fields.Count - 1 do
      begin
        F := TmnField(FRelation.Fields[i]);
        if (F.IsForeign) and (F.ReferenceField.Relation <> FRelation) and
          (lbDependsOn.Items.IndexOfObject(F.ReferenceField.Relation) = - 1) then
        begin
         lbDependsOn.Items.AddObject(F.ReferenceField.Relation.RelationName,
           F.ReferenceField.Relation);
        end;
      end;
    finally
      lbDependsOn.Items.EndUpdate;
    end;
  end;
end;

procedure TframeTable.lbDependOnClick(Sender: TObject);
var
  lb: TListBox;
  R: TmnRelation;
begin
  lb := TListBox(Sender);
  if lb.ItemIndex  > - 1 then
  begin
    if FDepend = nil then
    begin
      FDepend := TframeTable.Create(Self);
      FDepend.Parent := pDepend;
      FDepend.Align := alClient;
      FDepend.Transaction := Transaction;
    end;

    R := TmnRelation(lb.Items.Objects[lb.ItemIndex]);
    FDepend.RelationName := R.RelationName;
    FDepend.UpdateVisible;
  end;

  ShowDepend(lb.ItemIndex  > - 1);
end;

procedure TframeTable.ShowDepend(Show: Boolean);
begin
  sDepend.Visible := Show;
  pDepend.Visible := Show;
  sDepend.Top := pDepend.Top + sDepend.Height;
  
end;

procedure TframeTable.UpdateVisible;
begin
  PageControlChange(PageControl);
  pcConstraintsChange(pcConstraints);
  frameTableData.pcData.ActivePage := frameTableData.tsGrid; 
  frameTableData.CancelFilter;
end;

procedure TframeTable.DeleteSQL(DataSet: TIBDataSet);
var
  S: TStrings;
  R: TmnRelation;
  I: Integer;
  Keys: TrpFields;
begin
  S := DataSet.DeleteSQL;
  S.Clear;

  R := ReplicationManager.Relations.FindRelation(FRelationName);
  if R <> nil then
  begin
    S.Add('DELETE');
    S.Add('FROM');
    S.Add(FRelationName);
    S.Add('WHERE');

    Keys := TrpFields.Create;
    try
      Keys.OwnObjects := False;
      for I := 0 to R.Fields.Count - 1 do
      begin
        if TmnField(R.Fields[I]).IsPrimeKey then
          Keys.Add(R.Fields[I]);
      end;

      for I := 0 to Keys.Count - 2 do
        S.Add(Keys[I].FieldName + ' = :OLD_' + Keys[I].FieldName + ' AND ');

      if Keys.Count > 0 then
        S.Add(Keys[Keys.Count - 1].FieldName + ' = :OLD_' +
          Keys[Keys.Count - 1].FieldName);
    finally
      Keys.Free;
    end;
  end else
    raise Exception.Create(Format(InvalidRelationName, [FRelationName]));
end;

procedure TframeTable.InitSQL(ADataSet: TIBDataSet);
begin
  if not FSQLInited then
  begin
    ADataSet.Close;
    SelectSQL(ADataSet);
    DeleteSQL(ADataSet);
    ModefySQL(ADataSet);
    InsertSQL(ADataSet);
  end;
end;

procedure TframeTable.InsertSQL(DataSet: TIBDataSet);
var
  S: TStrings;
  R: TmnRelation;
  I: Integer;
  Str: string;
begin
  S := DataSet.InsertSQL;
  S.Clear;

  R := ReplicationManager.Relations.FindRelation(FRelationName);
  if R <> nil then
  begin
    S.Add('INSERT INTO ' + FRelationName + '(');

    Str := '';
    for I := 0 to R.Fields.Count - 1 do
    begin
      if not TmnField(R.Fields[i]).IsComputed then
      begin
        if Str > '' then Str := Str + ', ';
        Str := Str + R.Fields[i].FieldName ;
      end;
    end;

    S.Add(Str);
    S.Add(') VALUES (');

    Str := '';
    for I := 0 to R.Fields.Count - 1 do
    begin
      if not TmnField(R.Fields[i]).IsComputed then
      begin
        if Str > '' then Str := Str + ', ';
        Str := Str + ':NEW_' + R.Fields[i].FieldName;
      end;
    end;

    S.Add(Str);

    S.Add(')');
  end else
    raise Exception.Create(Format(InvalidRelationName, [FRelationName]));
end;

procedure TframeTable.ModefySQL(DataSet: TIBDataSet);
var
  S: TStrings;
  R: TmnRelation;
  I: Integer;
  Keys: TrpFields;
  Str: string;
begin
  S := DataSet.ModifySQL;
  S.Clear;

  R := ReplicationManager.Relations.FindRelation(FRelationName);
  if R <> nil then
  begin
    S.Add('UPDATE ' + FRelationName + ' SET');

    Str := '';
    for I := 0 to R.Fields.Count - 1 do
    begin
      if not TmnField(R.Fields[i]).IsComputed then
      begin
        if Str > '' then Str := Str + ', ';
        Str := Str + R.Fields[i].FieldName + ' = :NEW_' + R.Fields[i].FieldName;
      end;
    end;

    S.Add(Str);

    S.Add('WHERE');

    Keys := TrpFields.Create;
    try
      Keys.OwnObjects := False;
      for I := 0 to R.Fields.Count - 1 do
      begin
        if TmnField(R.Fields[I]).IsPrimeKey then
          Keys.Add(R.Fields[I]);
      end;

     for I := 0 to Keys.Count - 2 do
       S.Add(Keys[i].FieldName + ' = :OLD_' + Keys[i].FieldName + ' AND ');

     if Keys.Count > 0 then
       S.Add(Keys[Keys.Count - 1].FieldName + ' = :OLD_' +
         Keys[Keys.Count - 1].FieldName);
    finally
      Keys.Free;
    end;
  end else
    raise Exception.Create(Format(InvalidRelationName, [FRelationName]));
end;

procedure TframeTable.SelectSQL(DataSet: TIBDataSet);
var
  S: TStrings;
  R: TmnRelation;
begin
  S := DataSet.SelectSQL;
  S.Clear;

  R := ReplicationManager.Relations.FindRelation(FRelationName);
  if R <> nil then
  begin
    S.Add('SELECT');
    S.Add('*');
    S.Add('FROM');
    S.Add(FRelationName);
  end else
    raise Exception.Create(Format(InvalidRelationName, [FRelationName]));
end;

procedure TframeTable.CheckTransaction;
begin
  if FTransaction = nil then
    raise Exception.Create('Транзакция не присвоена');
  FDidActivate := not FTransaction.InTransaction;
  if FDidActivate then
    FTransaction.StartTransaction;
end;

end.
