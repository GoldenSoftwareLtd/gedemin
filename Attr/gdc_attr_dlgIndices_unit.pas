unit gdc_attr_dlgIndices_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgGMetaData_unit, Menus, Db, ActnList, StdCtrls, Buttons, Mask, DBCtrls,
  IBCustomDataSet, gdcBase, gdcMetaData, gdc_dlgG_unit;

type
  Tgdc_dlgIndices = class(Tgdc_dlgGMetaData)
    lbFields: TListBox;
    lbIndexFields: TListBox;
    dbeIndexName: TDBEdit;
    btnRight: TBitBtn;                             
    btnLeft: TBitBtn;
    Label1: TLabel;
    cmbOrder: TComboBox;
    Label2: TLabel;
    dbcUnique: TDBCheckBox;
    actAddToIndex: TAction;
    actRemoveFromIndex: TAction;
    dbcActive: TDBCheckBox;
    procedure actAddToIndexExecute(Sender: TObject);
    procedure actRemoveFromIndexExecute(Sender: TObject);
    procedure lbFieldsDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure lbFieldsDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure lbIndexFieldsDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure lbIndexFieldsDragDrop(Sender, Source: TObject; X,
      Y: Integer);
    procedure lbFieldsStartDrag(Sender: TObject;
      var DragObject: TDragObject);
    procedure lbIndexFieldsStartDrag(Sender: TObject;
      var DragObject: TDragObject);

  private
    gdcTableField: TgdcRelationField;
    TableFieldWasCreate: Boolean;
    FFromDrag: TListBox;

  protected
    procedure BeforePost; override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure SetupRecord; override;
    procedure SetupDialog; override;
  end;

var
  gdc_dlgIndices: Tgdc_dlgIndices;

implementation
uses
  at_classes, gd_ClassList;

const
  System_Prefix = 'RDB$';

{$R *.DFM}

{ Tgdc_dlgIndices_unit }

procedure Tgdc_dlgIndices.SetupDialog;
var
  {@UNFOLD MACRO INH_CRFORM_PARAMS()}
  {M}
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
  I: Integer;
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGINDICES', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGINDICES', KEYSETUPDIALOG);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPDIALOG]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGINDICES') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGINDICES',
  {M}          'SETUPDIALOG', KEYSETUPDIALOG, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGINDICES' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  gdcTableField := nil;
  if Assigned(gdcObject.MasterSource) and Assigned(gdcObject.MasterSource.DataSet) then
  with gdcObject.MasterSource.DataSet as TgdcBase do
    for i := 0 to DetailLinksCount - 1 do
      if (DetailLinks[i] is TgdcRelationField) then
      begin
        gdcTableField := DetailLinks[i] as TgdcRelationField;
        Break;
      end;

  if not Assigned(gdcTableField) then
  begin
    gdcTableField := TgdcTableField.Create(Self);
    gdcTableField.Database := gdcObject.Database;
    gdcTableField.ReadTransaction := gdcObject.Transaction;
    gdcTableField.Transaction := gdcObject.Transaction;
    gdcTableField.SubSet := 'ByRelation';
    gdcTableField.ParamByName('relationkey').AsInteger := gdcObject.FieldByName('relationkey').AsInteger;
    gdcTableField.Open;
    TableFieldWasCreate := True;
  end;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGINDICES', 'SETUPDIALOG', KEYSETUPDIALOG)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGINDICES', 'SETUPDIALOG', KEYSETUPDIALOG);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgIndices.SetupRecord;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGINDICES', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGINDICES', KEYSETUPRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSETUPRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGINDICES') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGINDICES',
  {M}          'SETUPRECORD', KEYSETUPRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGINDICES' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  lbFields.Clear;
  lbIndexFields.Clear;
  lbIndexFields.Items.CommaText := FgdcObject.FieldByName('fieldslist').AsString;
  gdcTableField.DisableControls;
  gdcTableField.First;

  while not gdcTableField.Eof do
  begin
    if lbIndexFields.Items.IndexOf(gdcTableField.FieldByName('fieldname').AsString) = -1 then
      lbFields.Items.Add(gdcTableField.FieldByName('fieldname').AsString);
    gdcTableField.Next;
  end;
  gdcTableField.EnableControls;
  cmbOrder.ItemIndex := FgdcObject.FieldByName('rdb$index_type').AsInteger;

  if AnsiPos(System_Prefix, AnsiUpperCase(gdcObject.FieldByName('indexname').AsString)) = 1 then
  //если это системный индекс, то не позвол€ем его измен€ть
  begin
    dbeIndexName.Enabled := False;
    lbFields.Enabled := False;
    lbIndexFields.Enabled := False;
    btnRight.Enabled := False;
    btnLeft.Enabled := False;
    dbcActive.Enabled := False;
    dbcUnique.Enabled := False;
    cmbOrder.Enabled := False;
  end

  else if gdcObject.State = dsInsert then
  begin
  //≈сли режим вставки, то нельз€ изменить активность
    dbeIndexName.Enabled := True;
    lbFields.Enabled := True;
    lbIndexFields.Enabled := True;
    btnRight.Enabled := True;
    btnLeft.Enabled := True;
    dbcActive.Enabled := False;
    dbcUnique.Enabled := True;
    cmbOrder.Enabled := True;
  end

  else
  begin
  //≈сли режим редактировани€, то нельз€ изменить наименование
    dbeIndexName.Enabled := False;
    lbFields.Enabled := True;
    lbIndexFields.Enabled := True;
    btnRight.Enabled := True;
    btnLeft.Enabled := True;
    dbcActive.Enabled := True;
    dbcUnique.Enabled := True;
    cmbOrder.Enabled := True;
  end;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGINDICES', 'SETUPRECORD', KEYSETUPRECORD)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGINDICES', 'SETUPRECORD', KEYSETUPRECORD);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgIndices.actAddToIndexExecute(Sender: TObject);
begin
  if lbFields.Items.Count = 0 then Exit;
  if lbFields.ItemIndex = -1 then
    lbFields.ItemIndex := 0;
  lbIndexFields.Items.Add(lbFields.Items[lbFields.ItemIndex]);
  lbFields.Items.Delete(lbFields.ItemIndex);
end;

procedure Tgdc_dlgIndices.actRemoveFromIndexExecute(Sender: TObject);
begin
  if lbIndexFields.Items.Count = 0 then Exit;
  if lbIndexFields.ItemIndex = -1 then
    lbIndexFields.ItemIndex := 0;
  lbFields.Items.Add(lbIndexFields.Items[lbIndexFields.ItemIndex]);
  lbIndexFields.Items.Delete(lbIndexFields.ItemIndex);
end;

procedure Tgdc_dlgIndices.BeforePost;
  function FieldValue(Value: Variant): Integer;
  begin
    if (VarType(Value) <> varInteger) or Value = Null then
      Result := 0
    else
      Result := Value;
  end;

  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGINDICES', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGINDICES', KEYBEFOREPOST);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYBEFOREPOST]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGINDICES') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGINDICES',
  {M}          'BEFOREPOST', KEYBEFOREPOST, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGINDICES' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
//  ≈сли индекс не имеет префикса индекса-атрибута,
//  добавл€ем указанный префикс;

  if (gdcObject.State = dsInsert) and
    (AnsiPos(UserPrefix, AnsiUpperCase(gdcObject.FieldByName('indexname').AsString)) <> 1)
  then
    gdcObject.FieldByName('indexname').AsString :=
      UserPrefix + gdcObject.FieldByName('indexname').AsString;

  if (gdcObject.State = dsInsert) and (gdcObject is TgdcIndex) and
    (not (gdcObject as TgdcIndex).CheckIndexName)
  then
  begin
    ActiveControl := dbeIndexName;
    raise Exception.Create('Ќаименование индекса дублируетс€ с уже существующим!');
  end;

  gdcObject.FieldByName('fieldslist').AsString := lbIndexFields.Items.CommaText;
  gdcObject.FieldByName('rdb$index_type').AsInteger := cmbOrder.ItemIndex;


  if (gdcObject.FieldByName('fieldslist').OldValue =
    gdcObject.FieldByName('fieldslist').Value) and
    (FieldValue(gdcObject.FieldByName('rdb$index_type').OldValue) =
    gdcObject.FieldByName('rdb$index_type').AsInteger) and
    (FieldValue(gdcObject.FieldByName('unique_flag').OldValue) =
    gdcObject.FieldByName('unique_flag').AsInteger) then
  begin
  //≈сли мы мен€ли только активность индекса
    if (FieldValue(gdcObject.FieldByName('index_inactive').OldValue) <>
       gdcObject.FieldByName('index_inactive').AsInteger)
    then
      gdcObject.FieldByName('changeactive').AsInteger := 1;
  end else
    gdcObject.FieldByName('changedata').AsInteger := 1;


  //    (gdcObject as TgdcIndex).ChangeActive := True;
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGINDICES', 'BEFOREPOST', KEYBEFOREPOST)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGINDICES', 'BEFOREPOST', KEYBEFOREPOST);
  {M}end;
  {END MACRO}
end;

constructor Tgdc_dlgIndices.Create(AnOwner: TComponent);
begin
  inherited;
  TableFieldWasCreate := False;
  FFromDrag := nil;
end;

destructor Tgdc_dlgIndices.Destroy;
begin
  if TableFieldWasCreate then
    gdcTableField.Free;
  inherited;
end;

procedure Tgdc_dlgIndices.lbFieldsDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  if (Sender is TListBox) and
    (lbFields.ItemAtPos(Point(X, Y), False) <> lbFields.ItemIndex)
  then
    Accept := True
  else
    Accept := False;

end;

procedure Tgdc_dlgIndices.lbFieldsDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  I: Integer;
  OldItemIndex: Integer;
begin
  if (Sender is TListBox) and (FFromDrag = lbFields) then
  begin
    I := lbFields.ItemAtPos(Point(X, Y), False);
    if I = lbFields.Items.Count then
      Dec(I);
    if I <> lbFields.ItemIndex then
    begin
      lbFields.Items.Move(lbFields.ItemIndex, I);
      lbFields.ItemIndex := I
    end;
  end
  else if (Sender is TListBox) and (FFromDrag = lbIndexFields) then
  begin
    I := lbFields.ItemAtPos(Point(X, Y), False);
 {   if I = lbFields.Items.Count then
      Dec(I);}
      

    OldItemIndex := lbIndexFields.ItemIndex;
    lbFields.Items.Insert(I, lbIndexFields.Items[OldItemIndex]);
    lbIndexFields.Items.Delete(OldItemIndex);
    if OldItemIndex = lbIndexFields.Items.Count then
      Dec(OldItemIndex);
    lbIndexFields.ItemIndex := OldItemIndex;
    lbFields.ItemIndex := I
  end;
end;

procedure Tgdc_dlgIndices.lbIndexFieldsDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  if (Sender is TListBox) and
    (lbIndexFields.ItemAtPos(Point(X, Y), False) <> lbIndexFields.ItemIndex)
  then
    Accept := True
  else
    Accept := False;

end;

procedure Tgdc_dlgIndices.lbIndexFieldsDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  I: Integer;
  OldItemIndex: Integer;
begin
  if (Sender is TListBox) and (FFromDrag = lbIndexFields) then
  begin
    I := lbIndexFields.ItemAtPos(Point(X, Y), False);
    if I = lbIndexFields.Items.Count then
      Dec(I);
    if I <> lbIndexFields.ItemIndex then
    begin
      lbIndexFields.Items.Move(lbIndexFields.ItemIndex, I);
      lbIndexFields.ItemIndex := I
    end;
  end
  else if (Sender is TListBox) and (FFromDrag = lbFields) then
  begin
    I := lbIndexFields.ItemAtPos(Point(X, Y), False);
{    if I = lbIndexFields.Items.Count then
      Dec(I);   }

    OldItemIndex := lbFields.ItemIndex;
    lbIndexFields.Items.Insert(I, lbFields.Items[OldItemIndex]);
    lbFields.Items.Delete(OldItemIndex);
    if OldItemIndex = lbFields.Items.Count then
      Dec(OldItemIndex);
    lbFields.ItemIndex := OldItemIndex;
    lbIndexFields.ItemIndex := I
  end;
end;

procedure Tgdc_dlgIndices.lbFieldsStartDrag(Sender: TObject;
  var DragObject: TDragObject);
begin
  FFromDrag := lbFields;
end;

procedure Tgdc_dlgIndices.lbIndexFieldsStartDrag(Sender: TObject;
  var DragObject: TDragObject);
begin
  FFromDrag := lbIndexFields;
end;

initialization
  RegisterFrmClass(Tgdc_dlgIndices);

finalization
  UnRegisterFrmClass(Tgdc_dlgIndices);

end.
