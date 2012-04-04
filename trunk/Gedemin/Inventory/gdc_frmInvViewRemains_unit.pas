unit gdc_frmInvViewRemains_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_frmInvBaseRemains_unit, Db, IBCustomDataSet, gdcBase, gdcGood, Menus,
  ActnList, Grids, DBGrids, gsDBGrid, gsIBGrid, ComCtrls, gsDBTreeView,
  ToolWin, ExtCtrls, TB2Item, TB2Dock, TB2Toolbar, gdcInvMovement,
  StdCtrls, gsIBLookupComboBox, gdcTree, gd_MacrosMenu, Mask, xDateEdits,
  Buttons, gdcMetaData, IBDatabase;

type
  Tgdc_frmInvViewRemains = class(Tgdc_frmInvBaseRemains)
    TBControlItem1: TTBControlItem;
    Label1: TLabel;
    gsiblcCompany: TgsIBLookupComboBox;
    TBControlItem2: TTBControlItem;
    gdcInvRemains: TgdcInvRemains;
    TBControlItem3: TTBControlItem;
    lDate: TLabel;
    deDateRemains: TxDateEdit;
    TBControlItem4: TTBControlItem;
    TBControlItem5: TTBControlItem;
    SpeedButton1: TSpeedButton;
    actExecRemains: TAction;
    cbCurrentRemains: TCheckBox;
    TBControlItem6: TTBControlItem;
    actOptions: TAction;
    TBItem3: TTBItem;
    gdcTable: TgdcTable;
    gdcChooseTableField: TgdcTableField;
    dsTable: TDataSource;
    actSumFields: TAction;
    TBItem4: TTBItem;
    actGoodOptions: TAction;
    actGoodSumFields: TAction;
    TBSubmenuItem1: TTBSubmenuItem;
    TBSubmenuItem2: TTBSubmenuItem;
    TBItem5: TTBItem;
    TBItem6: TTBItem;
    ibtrCommon: TIBTransaction;
    cbSubDepartment: TCheckBox;
    TBControlItem7: TTBControlItem;

    procedure FormCreate(Sender: TObject);
    procedure cbCurrentRemainsClick(Sender: TObject);
    procedure actExecRemainsExecute(Sender: TObject);
    procedure actExecRemainsUpdate(Sender: TObject);
    procedure actOptionsExecute(Sender: TObject);
    procedure actSumFieldsExecute(Sender: TObject);
    procedure actGoodOptionsExecute(Sender: TObject);
    procedure actGoodSumFieldsExecute(Sender: TObject);
    procedure gsiblcCompanyChange(Sender: TObject);
    procedure cbAllRemainsClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure gdcInvRemainsAfterOpen(DataSet: TDataSet);
    procedure cbSubDepartmentClick(Sender: TObject);
  private
    { Private declarations }
    FCurrentCompany: Integer;
    FCurrentDate: TDateTime;
    isCreate: Boolean;
    isHolding: Boolean;
    isFirst: Boolean;
    isModify: Boolean;

  protected
    procedure DoDestroy; override;
    function CheckHolding: Boolean; override;
  public
    { Public declarations }
    property CurrentCompany: Integer read FCurrentCompany;
  end;

var
  gdc_frmInvViewRemains: Tgdc_frmInvViewRemains;

implementation

{$R *.DFM}

uses
  Storages, gd_security,  gd_ClassList, gd_KeyAssoc, gdc_attr_frmRelationField_unit, at_classes, dlg_InputDateRemains_unit, IBSQL;

procedure Tgdc_frmInvViewRemains.FormCreate(Sender: TObject);
var
  FCurrentRemains: Boolean;
begin
  isCreate := True;
  try
    if Assigned(gdcObject) and gdcObject.Active then
      exit;

    if Assigned(UserStorage) and Assigned(IBLogin) then
      FCurrentCompany := UserStorage.ReadInteger(Name + SubType + '\Remains', 'CurrentCompany', IBLogin.CompanyKey)
    else
      FCurrentCompany := -1;

    FCurrentRemains := UserStorage.ReadBoolean(Name + SubType + '\Remains', 'CurrentRemains', True);

    ibtrCommon.DefaultDatabase := gdcInvRemains.Database;
    ibtrCommon.StartTransaction;


    gsiblcCompany.CurrentKey := IntToStr(CurrentCompany);
    if gsiblcCompany.CurrentKey = '' then
      gsiblcCompany.CurrentKeyInt := IBLogin.CompanyKey;

    gdcInvRemains.SubType := FSubType;
    gdcInvRemains.SetSubDepartmentKeys([-1]);
    //gdcInvRemains.SetDepartmentKeys([-1]);
    gdcInvRemains.RemainsDate := Date;
    gdcInvRemains.SubSet := cst_ByGroupKey;

    Caption := gdcInvRemains.GetRemainsName;

    cbCurrentRemains.Checked := FCurrentRemains;

    gdcInvRemains.CurrentRemains := FCurrentRemains;

    deDateRemains.Date := Date;
    FCurrentDate := Date;

    gdcInvRemains.ParamByName('LB').AsInteger := 0;
    gdcInvRemains.ParamByName('RB').AsInteger := MaxInt;
    
    isModify := False;

    dsMain.DataSet := nil;

    gdcGoodGroup.Open;

    inherited;

    gdcObject := gdcInvRemains;
    SetupInvRemains(gdcInvRemains);
    dsMain.DataSet := gdcObject;

    isFirst := True;

//    gdcInvRemains.MasterSource := dsDetail;

//    gdcObject.Open;


  finally
    isCreate := False;
  end;

end;

procedure Tgdc_frmInvViewRemains.cbCurrentRemainsClick(Sender: TObject);
begin
  if isCreate then
    exit;
  if not cbCurrentRemains.Checked then
  begin
    with Tdlg_InputDateRemains.Create(Self) do
      try
        xdeDateRemains.Date := deDateRemains.date;
        if ShowModal = mrOk then
          deDateRemains.date := xdeDateRemains.Date
        else
          exit;  
      finally
        Free;
      end
  end;
  gdcInvRemains.Close;
  gdcInvRemains.CurrentRemains := cbCurrentRemains.Checked;

  if cbSubDepartment.Checked then
  begin
    if isModify then
    begin
      gdcInvRemains.UnPrepare;
      gdcInvRemains.SetDepartmentKeys([gsiblcCompany.CurrentKeyInt]);
      gdcInvRemains.SetSubDepartmentKeys([]);
      gdcInvRemains.Prepare;
      isModify := False;
    end
    else
      gdcInvRemains.SetDepartmentKeys([gsiblcCompany.CurrentKeyInt]);
  end else
  begin
    if isModify then
    begin
      gdcInvRemains.UnPrepare;
      gdcInvRemains.SetSubDepartmentKeys([gsiblcCompany.CurrentKeyInt]);
      gdcInvRemains.SetDepartmentKeys([]);
      gdcInvRemains.Prepare;
      isModify := False;
    end
    else
      gdcInvRemains.SetSubDepartmentKeys([gsiblcCompany.CurrentKeyInt]);
  end;
  
  gdcInvRemains.RemainsDate := deDateRemains.Date;
  if CheckHolding then
    gdcObject.AddSubSet(cst_Holding)
  else
    gdcObject.RemoveSubSet(cst_Holding);  
//  gdcInvRemains.SubSet := 'ByID';
//  gdcInvRemains.SubSet := 'All';
  if not Assigned(gdcInvRemains.MasterSource) and not gdcInvRemains.HasSubSet('All') then
    gdcInvRemains.MasterSource := dsDetail;
  gdcInvRemains.Open;
  ibgrDetail.Visible := True;
end;

procedure Tgdc_frmInvViewRemains.actExecRemainsExecute(Sender: TObject);
begin
  FCurrentCompany := gsiblcCompany.CurrentKeyInt;
  FCurrentDate := deDateRemains.Date;
  gdcObject.Close;

  if cbSubDepartment.Checked then
  begin
    if isModify then
    begin
      gdcInvRemains.UnPrepare;
      gdcInvRemains.SetDepartmentKeys([gsiblcCompany.CurrentKeyInt]);
      gdcInvRemains.SetSubDepartmentKeys([]);
      gdcInvRemains.Prepare;
      isModify := False;
    end
    else
      gdcInvRemains.SetDepartmentKeys([gsiblcCompany.CurrentKeyInt]);
  end else
  begin
    if isModify then
    begin
      gdcInvRemains.UnPrepare;
      gdcInvRemains.SetSubDepartmentKeys([gsiblcCompany.CurrentKeyInt]);
      gdcInvRemains.SetDepartmentKeys([]);
      gdcInvRemains.Prepare;
      isModify := False;
    end
    else
      gdcInvRemains.SetSubDepartmentKeys([gsiblcCompany.CurrentKeyInt]);
  end;

  gdcInvRemains.RemainsDate := deDateRemains.Date;
  if CheckHolding then
    gdcObject.AddSubSet(cst_Holding)
  else
    gdcObject.RemoveSubSet(cst_Holding);
  if not Assigned(gdcInvRemains.MasterSource) and not gdcInvRemains.HasSubSet('All') then
    gdcInvRemains.MasterSource := dsDetail;
      
  gdcInvRemains.Open;
  ibgrDetail.Visible := True;
end;

procedure Tgdc_frmInvViewRemains.actExecRemainsUpdate(Sender: TObject);
begin
//  actExecRemains.Enabled := not cbCurrentRemains.Checked;
  deDateRemains.Enabled := not cbCurrentRemains.Checked;
  lDate.Enabled := not cbCurrentRemains.Checked;
end;

procedure Tgdc_frmInvViewRemains.actOptionsExecute(Sender: TObject);
var
  R: TatRelation;
  F: TatRelationField;
  i: Integer;
  OldSubSet: String;
begin
   with Tgdc_attr_frmRelationField.Create(Self) do
     try
       gdcTableField.ExtraConditions.Clear;
       gdcTableField.ExtraConditions.Add('z.relationname = ''INV_CARD'' AND z.fieldname LIKE ''USR$%''');
       SetChoose(gdcTableField);
       gdcTableField.SelectedID.Clear;

       for i:= 0 to gdcInvRemains.ViewFeatures.Count - 1 do
       begin
         R := atDatabase.Relations.ByRelationName('INV_CARD');
         if Assigned(R) then
         begin
           F := R.RelationFields.ByFieldName(gdcInvRemains.ViewFeatures[i]);
           if Assigned(F) then
           begin
             gdcTableField.SelectedID.Add(F.ID);
             ibgrMain.CheckBox.AddCheck(F.ID);
           end;
         end;
       end;

       gdcTableField.SubSet := 'All';
       gdcTableField.Open;
       if ShowModal = mrOk then
       begin
         gdcTableField.SubSet := 'OnlySelected';
         gdcTableField.Open;
         gdcTableField.First;
         gdcInvRemains.Close;
         gdcInvRemains.ViewFeatures.Clear;
         while not gdcTableField.EOF do
         begin
           gdcInvRemains.ViewFeatures.Add(gdcTableField.FieldByName('fieldname').AsString);
           gdcTableField.Next;
         end;
         gdcTableField.Close;
         OldSubSet := gdcInvRemains.SubSet;
         gdcInvRemains.SubSet := 'ByID';
         gdcInvRemains.SubSet := OldSubSet;
         if not Assigned(gdcInvRemains.MasterSource) and not gdcInvRemains.HasSubSet('All') then
           gdcInvRemains.MasterSource := dsDetail;

         gdcInvRemains.Open;
       end;
     finally
       Free;
     end;
end;

procedure Tgdc_frmInvViewRemains.actSumFieldsExecute(Sender: TObject);
var
  KeyArray: TgdKeyArray;
  R: TatRelation;
  F: TatRelationField;
  i: Integer;
  OldSubSet: String;
begin
  KeyArray := TgdKeyArray.Create;
  try
     with Tgdc_attr_frmRelationField.Create(Self) do
       try
         gdcTableField.ExtraConditions.Clear;
         gdcTableField.ExtraConditions.Add('z.relationname = ''INV_CARD'' AND z.fieldname LIKE ''USR$%''');
         SetChoose(gdcTableField);
         gdcTableField.SelectedID.Clear;

         for i:= 0 to gdcInvRemains.SumFeatures.Count - 1 do
         begin
           R := atDatabase.Relations.ByRelationName('INV_CARD');
           if Assigned(R) then
           begin
             F := R.RelationFields.ByFieldName(gdcInvRemains.SumFeatures[i]);
             if Assigned(F) then
             begin
               gdcTableField.SelectedID.Add(F.ID);
               ibgrMain.CheckBox.AddCheck(F.ID);
             end;
           end;
         end;

         gdcTableField.SubSet := 'All';
         gdcTableField.Open;
         if ShowModal = mrOk then
         begin
           gdcTableField.SubSet := 'OnlySelected';
           gdcTableField.Open;
           gdcTableField.First;
           gdcInvRemains.Close;
           gdcInvRemains.SumFeatures.Clear;
           while not gdcTableField.EOF do
           begin
             gdcInvRemains.SumFeatures.Add(gdcTableField.FieldByName('fieldname').AsString);
             gdcTableField.Next;
           end;
           gdcTableField.Close;
           OldSubSet := gdcInvRemains.SubSet;
           gdcInvRemains.SubSet := 'ByID';
           gdcInvRemains.SubSet := OldSubSet;
           if not Assigned(gdcInvRemains.MasterSource) and not gdcInvRemains.HasSubSet('All') then
             gdcInvRemains.MasterSource := dsDetail;

           gdcInvRemains.Open;
         end;
       finally
         Free;
       end;
  finally
    KeyArray.Free;
  end;
end;

procedure Tgdc_frmInvViewRemains.actGoodOptionsExecute(Sender: TObject);
 var
  R: TatRelation;
  F: TatRelationField;
  i: Integer;
  OldSubSet: String;
begin
   with Tgdc_attr_frmRelationField.Create(Self) do
     try
       gdcTableField.ExtraConditions.Clear;
       gdcTableField.ExtraConditions.Add('z.relationname = ''GD_GOOD'' AND z.fieldname LIKE ''USR$%''');
       SetChoose(gdcTableField);
       gdcTableField.SelectedID.Clear;

       for i:= 0 to gdcInvRemains.GoodViewFeatures.Count - 1 do
       begin
         R := atDatabase.Relations.ByRelationName('GD_GOOD');
         if Assigned(R) then
         begin
           F := R.RelationFields.ByFieldName(gdcInvRemains.GoodViewFeatures[i]);
           if Assigned(F) then
           begin
             gdcTableField.SelectedID.Add(F.ID);
             ibgrMain.CheckBox.AddCheck(F.ID);
           end;
         end;
       end;

       gdcTableField.SubSet := 'All';
       gdcTableField.Open;
       if ShowModal = mrOk then
       begin
         gdcTableField.SubSet := 'OnlySelected';
         gdcTableField.Open;
         gdcTableField.First;
         gdcInvRemains.Close;
         gdcInvRemains.GoodViewFeatures.Clear;
         while not gdcTableField.EOF do
         begin
           gdcInvRemains.GoodViewFeatures.Add(gdcTableField.FieldByName('fieldname').AsString);
           gdcTableField.Next;
         end;
         gdcTableField.Close;
         OldSubSet := gdcInvRemains.SubSet;
         gdcInvRemains.SubSet := 'ByID';
         gdcInvRemains.SubSet := OldSubSet;
         if not Assigned(gdcInvRemains.MasterSource) and not gdcInvRemains.HasSubSet('All') then
           gdcInvRemains.MasterSource := dsDetail;

         gdcInvRemains.Open;
       end;
     finally
       Free;
     end;
end;

procedure Tgdc_frmInvViewRemains.actGoodSumFieldsExecute(Sender: TObject);
var
  KeyArray: TgdKeyArray;
  R: TatRelation;
  F: TatRelationField;
  i: Integer;
  OldSubSet: String;
begin
  KeyArray := TgdKeyArray.Create;
  try
     with Tgdc_attr_frmRelationField.Create(Self) do
       try
         gdcTableField.ExtraConditions.Clear;
         gdcTableField.ExtraConditions.Add('z.relationname = ''GD_GOOD'' AND z.fieldname LIKE ''USR$%''');
         SetChoose(gdcTableField);
         gdcTableField.SelectedID.Clear;

         for i:= 0 to gdcInvRemains.GoodSumFeatures.Count - 1 do
         begin
           R := atDatabase.Relations.ByRelationName('GD_GOOD');
           if Assigned(R) then
           begin
             F := R.RelationFields.ByFieldName(gdcInvRemains.GoodSumFeatures[i]);
             if Assigned(F) then
             begin
               gdcTableField.SelectedID.Add(F.ID);
               ibgrMain.CheckBox.AddCheck(F.ID);
             end;
           end;
         end;

         gdcTableField.SubSet := 'All';
         gdcTableField.Open;
         if ShowModal = mrOk then
         begin
           gdcTableField.SubSet := 'OnlySelected';
           gdcTableField.Open;
           gdcTableField.First;
           gdcInvRemains.Close;
           gdcInvRemains.GoodSumFeatures.Clear;
           while not gdcTableField.EOF do
           begin
             gdcInvRemains.GoodSumFeatures.Add(gdcTableField.FieldByName('fieldname').AsString);
             gdcTableField.Next;
           end;
           gdcTableField.Close;
           OldSubSet := gdcInvRemains.SubSet;
           gdcInvRemains.SubSet := 'ByID';
           gdcInvRemains.SubSet := OldSubSet;
           if not Assigned(gdcInvRemains.MasterSource) and not gdcInvRemains.HasSubSet('All') then
             gdcInvRemains.MasterSource := dsDetail;
           gdcInvRemains.Open;
         end;
       finally
         Free;
       end;
  finally
    KeyArray.Free;
  end;
end;

procedure Tgdc_frmInvViewRemains.gsiblcCompanyChange(Sender: TObject);
var
  ibsql: TIBSQL;
begin
//  if Application.MessageBox('Изменилось подразделение. Перестроить остатки?', 'Остатки',
//    MB_YESNO or MB_ICONQUESTION	or MB_APPLMODAL	or MB_TOPMOST) = IDYES then actExecRemains.Execute;
  if gsiblcCompany.CurrentKeyInt > 0 then
  begin
    ibsql := TIBSQL.Create(Self);
    try
      ibsql.SQL.Text := 'SELECT holdingkey FROM gd_holding WHERE holdingkey = ' +
        gsiblcCompany.CurrentKey;
      ibsql.Transaction := gdcInvRemains.ReadTransaction;
      ibsql.ExecQuery;
      isHolding := ibsql.FieldByName('holdingkey').AsInteger > 0;
    finally
      ibsql.Free;
    end;
  end
  else
    IsHolding := False;
end;

procedure Tgdc_frmInvViewRemains.cbAllRemainsClick(Sender: TObject);
begin
  gdcInvRemains.CurrentRemains := cbCurrentRemains.Checked;

  if cbSubDepartment.Checked then
  begin
    gdcInvRemains.SetSubDepartmentKeys([]);
    gdcInvRemains.SetDepartmentKeys([gsiblcCompany.CurrentKeyInt]);
    isModify := False;
  end else
  begin
    gdcInvRemains.SetDepartmentKeys([]);
    gdcInvRemains.SetSubDepartmentKeys([gsiblcCompany.CurrentKeyInt]);
    isModify := False;
  end;

  gdcInvRemains.RemainsDate := deDateRemains.Date;
  inherited; 
  ibgrDetail.Visible := True;
end;

procedure Tgdc_frmInvViewRemains.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;
  if ibtrCommon.InTransaction then ibtrCommon.Commit;
end;

procedure Tgdc_frmInvViewRemains.DoDestroy;
begin
  inherited;
  try
    if Assigned(UserStorage) then
    begin
      UserStorage.WriteInteger(Name + SubType + '\Remains', 'CurrentCompany', CurrentCompany);
      UserStorage.WriteBoolean(Name + SubType + '\Remains', 'CurrentRemains', cbCurrentRemains.Checked);
    end;
  except
    Application.HandleException(Self);
  end;
end;

function Tgdc_frmInvViewRemains.CheckHolding: Boolean;
begin
  Result := IsHolding;
end;

procedure Tgdc_frmInvViewRemains.gdcInvRemainsAfterOpen(DataSet: TDataSet);
begin
  inherited;
  if isFirst and (UserStorage <> nil) then
    UserStorage.LoadComponent(ibgrDetail, ibgrDetail.LoadFromStream,
        gdcObject.SubType);
  isFirst := False;         
end;

procedure Tgdc_frmInvViewRemains.cbSubDepartmentClick(Sender: TObject);
begin
  inherited;
  isModify := True;
end;

initialization
  RegisterFrmClass(Tgdc_frmInvViewRemains);

finalization
  UnRegisterFrmClass(Tgdc_frmInvViewRemains);

end.
