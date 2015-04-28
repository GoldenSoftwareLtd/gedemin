
unit gdc_framSetControl_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, gsIBLookupComboBox, Db, Grids, DBGrids, gsDBGrid, gsIBGrid,
  ExtCtrls, ActnList, TB2Dock, TB2Toolbar, dmImages_unit, TB2Item, gdcBaseInterface,
  IBDatabase;

type
  Tgdc_framSetControl = class(TFrame)
    Pnl: TPanel;
    lk: TgsIBLookupComboBox;
    Gr: TgsIBGrid;
    DS: TDataSource;
    Tb: TTBToolbar;
    Al: TActionList;
    tbiRemoveFromSet: TTBItem;
    tbiAddToSet: TTBItem;
    actAddToSet: TAction;
    actRemoveFromSet: TAction;
    actAddToSetMany: TAction;
    tbiAddToSetMany: TTBItem;
    procedure actAddToSetUpdate(Sender: TObject);
    procedure actAddToSetExecute(Sender: TObject);
    procedure actRemoveFromSetUpdate(Sender: TObject);
    procedure actRemoveFromSetExecute(Sender: TObject);
    procedure actAddToSetManyUpdate(Sender: TObject);
    procedure actAddToSetManyExecute(Sender: TObject);
    procedure lkChange(Sender: TObject);

  private
    FChooseSubSet: String;
    FChooseComponentName: String;
    FChooseSubType: TgdcSubType;
    FgdcClass: String;
    FTransction: TIBTransaction;

    procedure SetChooseComponentName(const Value: String);
    procedure SetChooseSubSet(const Value: String);
    procedure SetChooseSubType(const Value: TgdcSubType);
    procedure SetgdcClass(const Value: String);
    procedure SetTransaction(const Value: TIBTransaction);

  public
    constructor Create(AnOwner: TComponent); override;

    property gdcClass: String read FgdcClass write SetgdcClass;
    property ChooseComponentName: String read FChooseComponentName write SetChooseComponentName;
    property ChooseSubSet: String read FChooseSubSet write SetChooseSubSet;
    property ChooseSubType: TgdcSubType read FChooseSubType write SetChooseSubType;
    property Transaction: TIBTransaction read FTransction write SetTransaction;

    procedure SaveSettings;
    procedure LoadSettings;

    //Настраивает грид для работы со ссылками
    //Должен вызываться только после инициализации DS.Dataset
    procedure SetupGrid;
  end;


implementation

{$R *.DFM}

uses
  gdcBase, gd_KeyAssoc, Storages, at_classes, at_sql_setup;

procedure Tgdc_framSetControl.actAddToSetUpdate(Sender: TObject);
begin
  actAddToSet.Enabled := (DS.DataSet is TgdcBase)
    and (DS.DataSet.Active)
    and (lk.CurrentKey > '');
end;

procedure Tgdc_framSetControl.actAddToSetExecute(Sender: TObject);
begin
  (DS.DataSet as TgdcBase).SetInclude(lk.CurrentKeyInt);
end;

procedure Tgdc_framSetControl.actRemoveFromSetUpdate(Sender: TObject);
begin
  actRemoveFromSet.Enabled := (DS.DataSet is TgdcBase)
    and (DS.DataSet.Active)
    and (not DS.DataSet.IsEmpty);
end;

procedure Tgdc_framSetControl.actRemoveFromSetExecute(Sender: TObject);
var
  I: Integer;
begin
  if (Gr.SelectedRows <> nil) and (Gr.SelectedRows.Count > 1) then
    with DS.DataSet as TgdcBase do
    begin
      DisableControls;
      for I := 0 to Gr.SelectedRows.Count - 1 do
      begin
        Bookmark := Gr.SelectedRows[I];
        SetExclude(False);
      end;
      EnableControls;
      CloseOpen;
    end
  else
    with DS.DataSet as TgdcBase do
      SetExclude(True);
end;

procedure Tgdc_framSetControl.actAddToSetManyUpdate(Sender: TObject);
begin
  actAddToSet.Enabled := (DS.DataSet is TgdcBase)
    and (DS.DataSet.Active)
    and (lk.gdClassName > '');
end;

procedure Tgdc_framSetControl.actAddToSetManyExecute(Sender: TObject);
var
  KA: TgdKeyArray;
  I: Integer;
  V: OleVariant;
begin
  KA := TgdKeyArray.Create;
  try
    with DS.Dataset as TgdcBase do
    begin
      if ChooseItems(CgdcBase(GetClass(FgdcClass)), KA, V, FChooseComponentName,
        FChooseSubSet, FChooseSubType, '') then
        for I := 0 to KA.Count - 1 do
        begin
          SetInclude(KA[I]);
        end;
    end;
  finally
    KA.Free;
  end;
end;

procedure Tgdc_framSetControl.SetChooseComponentName(const Value: String);
begin
  FChooseComponentName := Value;
end;

procedure Tgdc_framSetControl.SetChooseSubSet(const Value: String);
begin
  FChooseSubSet := Value;
end;

procedure Tgdc_framSetControl.SetChooseSubType(const Value: TgdcSubType);
begin
  FChooseSubType := Value;
end;

procedure Tgdc_framSetControl.SetgdcClass(const Value: String);
begin
  FgdcClass := Value;
end;

constructor Tgdc_framSetControl.Create(AnOwner: TComponent);
begin
  inherited;
  FChooseSubSet := '';
  FChooseComponentName := '';
  FChooseSubType := '';
  FgdcClass := '';
end;

procedure Tgdc_framSetControl.LoadSettings;
begin
  if Assigned(UserStorage) then
    UserStorage.LoadComponent(Gr, Gr.LoadFromStream);
end;

procedure Tgdc_framSetControl.SaveSettings;
begin
  if Gr.SettingsModified and Assigned(UserStorage) then
    UserStorage.SaveComponent(Gr, Gr.SaveToStream);
end;

procedure Tgdc_framSetControl.SetupGrid;
var
  P: TatPrimaryKey;
  I: Integer;
  C: TgsIBColumnEditor;
begin
  Assert(DS.DataSet is TgdcBase);
  Assert(Assigned(atDatabase));

  if ((DS.Dataset as TgdcBase).SetTable > '') and
    Assigned(atDatabase.Relations.ByRelationName((DS.Dataset as TgdcBase).SetTable))
  then
  begin
    P := atDatabase.Relations.ByRelationName((DS.Dataset as TgdcBase).SetTable).PrimaryKey;
    for I := 0 to P.ConstraintFields.Count - 1 do
    begin
      if Assigned(P.ConstraintFields[I].References) and
        (AnsiCompareText(P.ConstraintFields[I].References.RelationName,
         TgdcBase(DS.DataSet).GetListTable(TgdcBase(DS.DataSet).SubType)) = 0)
      then
      begin
        C := Gr.ColumnEditors.Add;
        try
          C.EditorStyle := cesLookup;
          C.DisplayField := TgdcBase(DS.DataSet).GetListField(TgdcBase(DS.DataSet).SubType);
          C.FieldName := cstSetPrefix + P.ConstraintFields[I].FieldName;
          C.Lookup.LookupListField := TgdcBase(DS.DataSet).GetListField(TgdcBase(DS.DataSet).SubType);
          C.Lookup.LookupKeyField := TgdcBase(DS.DataSet).GetKeyField(TgdcBase(DS.DataSet).SubType);
          C.Lookup.LookupTable := TgdcBase(DS.DataSet).GetListTable(TgdcBase(DS.DataSet).SubType);
          C.Lookup.gdClassName := TgdcBase(DS.DataSet).ClassName;
          C.Lookup.Transaction := Transaction;
        except
          Gr.ColumnEditors.Delete(C.Index);
        end;
        Break;
      end;
    end;

    if not Gr.SettingsLoaded then
    begin
      for I := 0 to Gr.Columns.Count - 1 do
      begin
        if AnsiCompareText(Gr.Columns[I].Field.FieldName,
          (DS.DataSet as TgdcBase).GetListField((DS.DataSet as TgdcBase).SubType)) <> 0 then
        begin
          Gr.Columns[I].Visible := False;
        end;
      end;
    end;
  end;
end;

procedure Tgdc_framSetControl.SetTransaction(const Value: TIBTransaction);
begin
  FTransction := Value;
end;

procedure Tgdc_framSetControl.lkChange(Sender: TObject);
begin
  if lk.CurrentKey > '' then
    actAddToSet.Execute;
end;

end.
