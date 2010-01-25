unit gp_dlgRealizatoinOption_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, gsIBLookupComboBox, Grids, DBGrids, gsDBGrid, gsIBGrid, Db,
  IBCustomDataSet, IBDatabase, dmDatabase_unit, gsIBCtrlGrid, DBCtrls, at_Classes,
  gsStorage, ComCtrls, gsDBTreeView, ImgList, dmImages_unit, ActnList,
  IBSQL, ExtCtrls;

type
  TdlgRealizatoinOption = class(TForm)
    bOk: TButton;
    bCancel: TButton;
    pcOption: TPageControl;
    tsMain: TTabSheet;
    Label1: TLabel;
    Label3: TLabel;
    gsiblcValue: TgsIBLookupComboBox;
    cbPriceWithContact: TCheckBox;
    gsdbtvGroup: TgsDBTreeView;
    cbOnlyPriceGood: TCheckBox;
    cbMakeEntryOnSave: TCheckBox;
    cbAutoMakeTransaction: TCheckBox;
    cbCheckNumber: TCheckBox;
    ibdsDocRealPosOption: TIBDataSet;
    ibdsDocRealPosOptionFIELDNAME: TIBStringField;
    ibdsDocRealPosOptionNAME: TIBStringField;
    ibdsDocRealPosOptionINCLUDETAX: TSmallintField;
    ibdsDocRealPosOptionISCURRENCY: TSmallintField;
    ibdsDocRealPosOptionROUNDING: TIBBCDField;
    ibdsDocRealPosOptionEXPRESSION: TIBStringField;
    ibdsDocRealPosOptionTAXKEY: TIntegerField;
    dsDocRealPosOption: TDataSource;
    IBTransaction: TIBTransaction;
    dsGroup: TDataSource;
    ibdsGroup: TIBDataSet;
    tsTax: TTabSheet;
    Label2: TLabel;
    gsibgrDocRealPosOption: TgsIBCtrlGrid;
    gsiblcTax: TgsIBLookupComboBox;
    dbcbIncludeTax: TDBCheckBox;
    dbcbIsCurrency: TDBCheckBox;
    ibdsDocRealPosOptionRELATIONNAME: TIBStringField;
    gsiblcRelationName: TgsIBLookupComboBox;
    gsiblcFieldName: TgsIBLookupComboBox;
    ibdsDocRealPosOptionRATE: TIBBCDField;
    tsPrint: TTabSheet;
    Label4: TLabel;
    sgrGroupSelect: TStringGrid;
    Button1: TButton;
    Button2: TButton;
    ActionList1: TActionList;
    actChooseGroup: TAction;
    actDelete: TAction;
    cbJoinRecord: TCheckBox;
    actChooseVar: TAction;
    Button3: TButton;
    rgDisabledGood: TRadioGroup;
    rgCopy: TRadioGroup;
    TabSheet1: TTabSheet;
    Label5: TLabel;
    sgNaturalLoss: TStringGrid;
    Button4: TButton;
    Button5: TButton;
    actAddGroup: TAction;
    actDelGroup: TAction;
    actAddDist: TAction;
    actDelDist: TAction;
    Button6: TButton;
    Button7: TButton;
    procedure FormCreate(Sender: TObject);
    procedure gsiblcTaxExit(Sender: TObject);
    procedure bOkClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure gsdbtvGroupGetImageIndex(Sender: TObject; Node: TTreeNode);
    procedure gsdbtvGroupGetSelectedIndex(Sender: TObject;
      Node: TTreeNode);
    procedure gsibgrDocRealPosOptionEnter(Sender: TObject);
    procedure ibdsDocRealPosOptionRELATIONNAMEChange(Sender: TField);
    procedure actChooseGroupExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure actChooseVarExecute(Sender: TObject);
    procedure actChooseVarUpdate(Sender: TObject);
    procedure actAddGroupExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actDelGroupExecute(Sender: TObject);
    procedure actAddDistExecute(Sender: TObject);
    procedure actDelDistExecute(Sender: TObject);
  private
    { Private declarations }
    LossGroupList: TStringList;
    procedure SavePrintGroup;
    procedure ReadPrintGroup;
    procedure SaveNaturalLossInfo;
  public
    { Public declarations }
    procedure SetupDialog;
  end;

var
  dlgRealizatoinOption: TdlgRealizatoinOption;

implementation

{$R *.DFM}

uses
  gd_dlgChooseVariable_unit, Storages;

procedure TdlgRealizatoinOption.FormCreate(Sender: TObject);
var
  OldOnExit: TNotifyEvent;
  OldOnKeyDown: TKeyEvent;
begin
  if not IBTransaction.InTransaction then
    IBTransaction.StartTransaction;

  pcOption.ActivePage := tsMain;

  LossGroupList := TStringList.Create;

  OldOnExit := gsiblcRelationName.OnExit;
  OldOnKeyDown := gsiblcRelationName.OnKeyDown;
  gsibgrDocRealPosOption.AddControl('RELATIONNAME', gsiblcRelationName, OldOnExit,
    OldOnKeyDown);
  gsiblcRelationName.OnExit := OldOnExit;
  gsiblcRelationName.OnKeyDown := OldOnKeyDown;

  OldOnExit := gsiblcFieldName.OnExit;
  OldOnKeyDown := gsiblcFieldName.OnKeyDown;
  gsibgrDocRealPosOption.AddControl('FIELDNAME', gsiblcFieldName, OldOnExit,
    OldOnKeyDown);
  gsiblcFieldName.OnExit := OldOnExit;
  gsiblcFieldName.OnKeyDown := OldOnKeyDown;

  OldOnExit := gsiblcTax.OnExit;
  OldOnKeyDown := gsiblcTax.OnKeyDown;
  gsibgrDocRealPosOption.AddControl('NAME', gsiblcTax, OldOnExit,
    OldOnKeyDown);
  gsiblcTax.OnExit := OldOnExit;
  gsiblcTax.OnKeyDown := OldOnKeyDown;

  OldOnExit := dbcbIncludeTax.OnExit;
  OldOnKeyDown := dbcbIncludeTax.OnKeyDown;
  gsibgrDocRealPosOption.AddControl('INCLUDETAX', dbcbIncludeTax, OldOnExit,
    OldOnKeyDown);
  dbcbIncludeTax.OnExit := OldOnExit;
  dbcbIncludeTax.OnKeyDown := OldOnKeyDown;

  OldOnExit := dbcbIsCurrency.OnExit;
  OldOnKeyDown := dbcbIsCurrency.OnKeyDown;
  gsibgrDocRealPosOption.AddControl('ISCURRENCY', dbcbIsCurrency, OldOnExit,
    OldOnKeyDown);
  dbcbIsCurrency.OnExit := OldOnExit;
  dbcbIsCurrency.OnKeyDown := OldOnKeyDown;
end;

procedure TdlgRealizatoinOption.SetupDialog;
var
  GroupKey, i, j: Integer;
  F: TgsStorageFolder;
  GK, LB, RB, Dist: Integer;
  ibsql: TIBSQL;
begin
  ibdsDocRealPosOption.Open;
  ibdsDocRealPosOption.FieldByName('Name').Required := False;
  ibdsGroup.Open;

  sgrGroupSelect.Cells[0, 0] := 'Группа';
  sgrGroupSelect.Cells[1, 0] := '№ п\п';
  sgrGroupSelect.Cells[2, 0] := 'Переменная';

  sgrGroupSelect.ColWidths[0] := 200;
  sgrGroupSelect.ColWidths[1] := 60;
  sgrGroupSelect.ColWidths[2] := 60;
  sgrGroupSelect.ColWidths[3] := 0;

  GroupKey := GlobalStorage.ReadInteger('defaultgood', 'defaultgroup', -1);


  ibsql := TIBSQL.Create(Self);
  try
    ibsql.Transaction := IBTransaction;
    ibsql.SQL.Text := 'SELECT name FROM gd_goodgroup WHERE id = :gk';
    ibsql.Prepare;
    cbOnlyPriceGood.Checked := UserStorage.ReadInteger('realzaitionoption', 'onlypricegood', 0) = 1;
    cbCheckNumber.Checked := UserStorage.ReadInteger('realzaitionoption', 'checknumber', 0) = 1;
    F := GlobalStorage.OpenFolder('realzaitionoption');
    with F do
    try
      gsiblcValue.CurrentKey := IntToStr(ReadInteger('weightkey', 0));
      cbPriceWithContact.Checked := ReadInteger('pricewithcontact', 0) = 1;
      cbMakeEntryOnSave.Checked := ReadInteger('makeentryonsave', 0) = 1;
      cbAutoMakeTransaction.Checked := ReadInteger('automaketransaction', 0) = 1;

      cbJoinRecord.Checked := ReadInteger('joinrecord', 0) = 1;
      rgDisabledGood.ItemIndex := ReadInteger('disabledgoodshow', 0);
      rgCopy.ItemIndex := ReadInteger('typecopybill', 1);

      sgNaturalLoss.ColCount := ReadInteger('lossdistancecount', 3) + 1;
      sgNaturalLoss.RowCount := ReadInteger('lossgroupcount', 0) + 1;
      Dist := 0;
      for i:= 1 to sgNaturalLoss.ColCount - 1 do
      begin
        sgNaturalLoss.Cells[i, 0] := IntToStr(ReadInteger(Format('lostdestvalue%d', [i]), Dist));
        Dist := Dist + 50;
      end;

      for i:= 1 to sgNaturalLoss.RowCount - 1 do
      begin
        GK := ReadInteger(Format('lossgroupkey%d', [i]), 0);
        LB := ReadInteger(Format('losslb%d', [i]), 0);
        RB := ReadInteger(Format('lossrb%d', [i]), 0);
        LossGroupList.Add(Format('%d;%d;%d', [GK, LB, RB]));
        ibsql.ParamByName('gk').AsInteger := GK;
        ibsql.ExecQuery;
        if ibsql.RecordCount > 0 then
          sgNaturalLoss.Cells[0, i] := ibsql.FieldByName('name').AsString;
        ibsql.Close;
      end;

      for i:= 1 to sgNaturalLoss.ColCount - 1 do
        for j:= 1 to sgNaturalLoss.RowCount - 1 do
          sgNaturalLoss.Cells[i, j] := ReadString(Format('lossvalue%d_%d', [i, j]), '');
    finally
      GlobalStorage.CloseFolder(F);
    end;
  finally
    ibsql.Free;
  end;


  if GroupKey <> -1 then
    gsdbtvGroup.GoToID(GroupKey);

  ReadPrintGroup;
end;

procedure TdlgRealizatoinOption.gsiblcTaxExit(Sender: TObject);
begin
  if gsiblcTax.CurrentKey > '' then
    ibdsDocRealPosOption.FieldByName('NAME').AsString := gsiblcTax.Text;
end;

procedure TdlgRealizatoinOption.bOkClick(Sender: TObject);
var
  F: TgsStorageFolder;
begin
  if ibdsDocRealPosOption.State in [dsEdit, dsInsert] then
    ibdsDocRealPosOption.Post;

  ibdsDocRealPosOption.ApplyUpdates;

  if IBTransaction.InTransaction then
    IBTransaction.Commit;
  F := GlobalStorage.OpenFolder('realzaitionoption');
  with F do
  try
    if gsiblcValue.CurrentKey > '' then
      WriteInteger('weightkey', StrToInt(gsiblcValue.CurrentKey))
    else
      WriteInteger('weightkey', 0);
    WriteInteger('pricewithcontact', Integer(cbPriceWithContact.Checked));
    WriteInteger('makeentryonsave', Integer(cbMakeEntryOnSave.Checked));
    WriteInteger('automaketransaction', Integer(cbAutoMakeTransaction.Checked));
    WriteInteger('joinrecord', Integer(cbJoinRecord.Checked));
    WriteInteger('disabledgoodshow', rgDisabledGood.ItemIndex);
    WriteInteger('typecopybill', rgCopy.ItemIndex);
  finally
    GlobalStorage.CloseFolder(F);
  end;

  UserStorage.WriteInteger('realzaitionoption',
    'onlypricegood', Integer(cbOnlyPriceGood.Checked));
  UserStorage.WriteInteger('realzaitionoption',
    'checknumber', Integer(cbCheckNumber.Checked));


  if Assigned(gsdbtvGroup.Selected) and Assigned(gsdbtvGroup.Selected.Data) then
    GlobalStorage.WriteInteger('defaultgood', 'defaultgroup',
      gsdbtvGroup.ID);

  SavePrintGroup;
  SaveNaturalLossInfo;

  ModalResult := mrOk;
end;

procedure TdlgRealizatoinOption.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if ModalResult <> mrOk then
  begin
    if ibdsDocRealPosOption.State in [dsEdit, dsInsert] then
      ibdsDocRealPosOption.Cancel;

    ibdsDocRealPosOption.CancelUpdates;

    if IBTransaction.InTransaction then
      IBTransaction.RollBack;
  end;
end;

procedure TdlgRealizatoinOption.gsdbtvGroupGetImageIndex(Sender: TObject;
  Node: TTreeNode);
begin
  if Node.HasChildren then
  begin
    if Node.Expanded then
      Node.ImageIndex := 1
    else
      Node.ImageIndex := 0;
  end
  else
    Node.ImageIndex := 17;
end;

procedure TdlgRealizatoinOption.gsdbtvGroupGetSelectedIndex(
  Sender: TObject; Node: TTreeNode);
begin
  if Node.HasChildren then
  begin
    if Node.Expanded then
      Node.SelectedIndex := 1
    else
      Node.SelectedIndex := 0;
  end
  else
    Node.SelectedIndex := 17;
end;

procedure TdlgRealizatoinOption.gsibgrDocRealPosOptionEnter(
  Sender: TObject);
begin
  if ibdsDocRealPosOption.FieldByName('RelationName').IsNull then
    gsibgrDocRealPosOption.SelectedField := ibdsDocRealPosOption.FieldByName('RelationName');
end;

procedure TdlgRealizatoinOption.ibdsDocRealPosOptionRELATIONNAMEChange(
  Sender: TField);
begin
  if Sender.IsNull then
    gsiblcFieldName.Condition := ''
  else
    gsiblcFieldName.Condition := Format('RELATIONNAME = ''%s'' AND FIELDNAME LIKE ''%s%%''',
      [Sender.AsString, UserPrefix]);
end;

procedure TdlgRealizatoinOption.actChooseGroupExecute(Sender: TObject);
begin
{  GroupKey := boDirectGood.ChooseGroup;
  if GroupKey > 0 then
  begin
    if sgrGroupSelect.Cells[0, sgrGroupSelect.RowCount - 1] > '' then
      sgrGroupSelect.RowCount := sgrGroupSelect.RowCount + 1;
    sgrGroupSelect.Cells[0, sgrGroupSelect.RowCount - 1] := boDirectGood.GroupName;
    sgrGroupSelect.Cells[3, sgrGroupSelect.RowCount - 1] := IntToStr(GroupKey);
  end;}
end;

procedure TdlgRealizatoinOption.actDeleteExecute(Sender: TObject);
var
  i: Integer;
begin
  if sgrGroupSelect.RowCount > 2 then
  begin
    for i:= sgrGroupSelect.Row to sgrGroupSelect.RowCount - 2 do
    begin
      sgrGroupSelect.Cells[0, i] := sgrGroupSelect.Cells[0, i + 1];
      sgrGroupSelect.Cells[1, i] := sgrGroupSelect.Cells[1, i + 1];
      sgrGroupSelect.Cells[2, i] := sgrGroupSelect.Cells[2, i + 1];
      sgrGroupSelect.Cells[3, i] := sgrGroupSelect.Cells[3, i + 1];
    end;
    sgrGroupSelect.RowCount := sgrGroupSelect.RowCount - 1;
  end
  else
  begin
    sgrGroupSelect.Cells[0, 1] := '';
    sgrGroupSelect.Cells[1, 1] := '';
    sgrGroupSelect.Cells[2, 1] := '';
  end;
end;

procedure TdlgRealizatoinOption.SavePrintGroup;
var
  i, CountRows: Integer;
  F: TgsStorageFolder;
begin
  CountRows := 0;
  F := GlobalStorage.OpenFolder('realizationoption');
  with F do
  try
    for i:= 1 to sgrGroupSelect.RowCount - 1 do
    begin
      if sgrGroupSelect.Cells[0, i] > '' then
      begin

        WriteInteger(Format('printgroupkey%d', [i]), StrToInt(sgrGroupSelect.Cells[3, i]));
        if sgrGroupSelect.Cells[1, i] > '' then
          WriteInteger(Format('printgroupseq%d', [i]), StrToInt(sgrGroupSelect.Cells[1, i]))
        else
          WriteInteger(Format('printgroupseq%d', [i]), 0);
        WriteString(Format('printgroupvariable%d', [i]),  sgrGroupSelect.Cells[2, i]);
        Inc(CountRows);
      end;
    end;
    WriteInteger('countprintgroup', CountRows);
  finally
    GlobalStorage.CloseFolder(F);
  end;
end;

procedure TdlgRealizatoinOption.ReadPrintGroup;
var
  i, CountGroup: Integer;
  GroupKey, Seq: Integer;
  NameGroup, Variable: String;
  ibsql: TIBSQL;
  F: TgsStorageFolder;
begin
  F := GlobalStorage.OpenFolder('realizationoption');
  with F do
  try
    CountGroup := ReadInteger('countprintgroup', 0);
    if CountGroup > 0 then
    begin
      sgrGroupSelect.RowCount := CountGroup + 1;
      ibsql := TIBSQL.Create(Self);
      try
        ibsql.Transaction := IBTransaction;
        ibsql.SQL.Text := 'SELECT name FROM gd_goodgroup WHERE id = :gk';
        ibsql.Prepare;
        for i:= 1 to CountGroup do
        begin
          GroupKey := ReadInteger(Format('printgroupkey%d', [i]), 0);
          Seq := ReadInteger(Format('printgroupseq%d', [i]), 0);
          Variable := ReadString(Format('printgroupvariable%d', [i]), '');

          ibsql.ParamByName('gk').AsInteger := GroupKey;
          ibsql.ExecQuery;
          if ibsql.RecordCount = 1 then
            NameGroup := ibsql.Fields[0].AsString
          else
            NameGroup := '';
          ibsql.Close;
          sgrGroupSelect.Cells[0, i] := NameGroup;
          sgrGroupSelect.Cells[1, i] := IntToStr(Seq);
          sgrGroupSelect.Cells[2, i] := Variable;
          sgrGroupSelect.Cells[3, i] := IntToStr(GroupKey);
        end;
      finally
        ibsql.Free;
      end;
    end;
  finally
    GlobalStorage.CloseFolder(F);
  end;
end;

procedure TdlgRealizatoinOption.actChooseVarExecute(Sender: TObject);
begin
  with TdlgChooseVariable.Create(Self) do
    try
      if Setup(['GD_DOCREALPOS', 'GD_DOCREALIZATION']) then
      begin
        if not (ibdsDocRealPosOption.State in [dsEdit, dsInsert]) then
          ibdsDocRealPosOption.Edit;
        ibdsDocRealPosOption.FieldByName('Expression').AsString :=
          ibdsDocRealPosOption.FieldByName('Expression').AsString +
          Variable; 
      end;
    finally
      Free;
    end;
end;

procedure TdlgRealizatoinOption.actChooseVarUpdate(Sender: TObject);
begin
  actChooseVar.Enabled := (ibdsDocRealPosOption.FieldByName('relationname').AsString > '')
    and (ibdsDocRealPosOption.FieldByName('fieldname').AsString > '')
end;

procedure TdlgRealizatoinOption.actAddGroupExecute(Sender: TObject);
begin
{  if boDirectGood.ChooseGroup > 0 then
  begin
    LossGroupList.Add(Format('%d;%d;%d', [boDirectGood.GroupKey, boDirectGood.LB,
      boDirectGood.RB]));
    sgNaturalLoss.RowCount := sgNaturalLoss.RowCount + 1;
    sgNaturalLoss.Cells[0, sgNaturalLoss.RowCount - 1] :=
      boDirectGood.GroupName;
  end;}
end;

procedure TdlgRealizatoinOption.FormDestroy(Sender: TObject);
begin
  if Assigned(LossGroupList) then
    FreeAndNil(LossGroupList);
end;

procedure TdlgRealizatoinOption.actDelGroupExecute(Sender: TObject);
var
  i, j: Integer;
begin
  if sgNaturalLoss.Row > 0 then
  begin
    if MessageBox(HANDLE, 'Удалить текущую группу?', 'Внимание', mb_YesNo or mb_IconQuestion) = idYes
    then
    begin
      LossGroupList.Delete(sgNaturalLoss.Row - 1);
      for i:= sgNaturalLoss.Row + 1 to sgNaturalLoss.RowCount - 1 do
        for j:= 0 to sgNaturalLoss.ColCount - 1 do
          sgNaturalLoss.Cells[j, i - 1] := sgNaturalLoss.Cells[j, i];
      sgNaturalLoss.RowCount := sgNaturalLoss.RowCount - 1;
    end;
  end;
end;

procedure TdlgRealizatoinOption.actAddDistExecute(Sender: TObject);
begin
  sgNaturalLoss.ColCount := sgNaturalLoss.ColCount + 1;
end;

procedure TdlgRealizatoinOption.actDelDistExecute(Sender: TObject);
var
  i, j: Integer;
begin
  if MessageBox(HANDLE, 'Удалить текущую колонку с расстоянием?', 'Внимание',
    mb_YesNo or mb_IconQuestion) = idYes then
  begin
    for i:= sgNaturalLoss.Col + 1 to sgNaturalLoss.ColCount - 1 do
      for j:= 0 to sgNaturalLoss.RowCount - 1 do
        sgNaturalLoss.Cells[i - 1, j] := sgNaturalLoss.Cells[i, j];

    sgNaturalLoss.ColCount := sgNaturalLoss.ColCount - 1;
  end;
end;

procedure TdlgRealizatoinOption.SaveNaturalLossInfo;
var
  i, j, Dist: Integer;
  RB, LB, GK: Integer;
  S: String;
  F: TgsStorageFolder;
begin
  F := GlobalStorage.OpenFolder('realzaitionoption');
  with F do
  try
    WriteInteger('lossdistancecount', sgNaturalLoss.ColCount - 1);
    WriteInteger('lossgroupcount', sgNaturalLoss.RowCount - 1);
    for i:= 1 to sgNaturalLoss.ColCount - 1 do
    begin
      try
        Dist := StrToInt(sgNaturalLoss.Cells[i, 0]);
      except
        Dist := 0;
      end;
      WriteInteger(Format('lostdestvalue%d', [i]), Dist);
    end;

    for i:= 1 to sgNaturalLoss.RowCount - 1 do
    begin
      S := LossGroupList[i - 1];
      GK := StrToInt(copy(S, 1, Pos(';', S) - 1));
      WriteInteger(Format('lossgroupkey%d', [i]), GK);
      S := copy(S, Pos(';', S) + 1, Length(S));
      LB := StrToInt(copy(S, 1, Pos(';', S) - 1));
      WriteInteger(Format('losslb%d', [i]), LB);
      S := copy(S, Pos(';', S) + 1, Length(S));
      RB := StrToInt(S);
      WriteInteger(Format('lossrb%d', [i]), RB);
    end;

    for i:= 1 to sgNaturalLoss.ColCount - 1 do
      for j:= 1 to sgNaturalLoss.RowCount - 1 do
        WriteString(Format('lossvalue%d_%d', [i, j]), sgNaturalLoss.Cells[i, j]);
  finally
    GlobalStorage.CloseFolder(F);
  end;
end;

end.
