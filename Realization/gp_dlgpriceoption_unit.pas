unit gp_dlgpriceoption_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DBCtrls, gsIBLookupComboBox, Db, IBDatabase, IBCustomDataSet, ActnList,
  Grids, DBGrids, gsDBGrid, gsIBGrid, dmDatabase_unit,
  gsIBCtrlGrid, ExtCtrls, ComCtrls;

type
  TdlgPriceOption = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    gsiblcFieldName: TgsIBLookupComboBox;
    gsiblcCurr: TgsIBLookupComboBox;
    dbmExpression: TDBMemo;
    dbcbDisabled: TDBCheckBox;
    Button3: TButton;
    dsPPosOption: TDataSource;
    ActionList1: TActionList;
    actOk: TAction;
    actCancel: TAction;
    actVariable: TAction;
    actChoose: TAction;
    actDel: TAction;
    Button1: TButton;
    Button2: TButton;
    Label4: TLabel;
    gsibgrPriceFieldRel: TgsIBGrid;
    Button4: TButton;
    Button5: TButton;
    ibdsPriceFieldRel: TIBDataSet;
    ibdsPriceFieldRelFIELDNAME: TIBStringField;
    ibdsPriceFieldRelCONTACTKEY: TIntegerField;
    ibdsPriceFieldRelNAME: TIBStringField;
    ibdsPriceFieldRelISSUBLEVEL: TSmallintField;
    dsPriceFieldRel: TDataSource;
    gsibgrPriceDocRel: TgsIBCtrlGrid;
    ibdsPriceDocRel: TIBDataSet;
    dsPriceDocRel: TDataSource;
    ibdsPriceDocRelFIELDNAME: TIBStringField;
    ibdsPriceDocRelDOCUMENTTYPEKEY: TIntegerField;
    ibdsPriceDocRelRELATIONNAME: TIBStringField;
    ibdsPriceDocRelDOCFIELDNAME: TIBStringField;
    ibdsPriceDocRelVALUETEXT: TIBStringField;
    ibdsPriceDocRelRESERVED: TIntegerField;
    ibdsPriceDocRelNAME: TIBStringField;
    gsiblcDocumentType: TgsIBLookupComboBox;
    gsiblcRelationName: TgsIBLookupComboBox;
    ibdsPriceDocRelLNAME: TIBStringField;
    gsiblcRelFieldName: TgsIBLookupComboBox;
    procedure actOkExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actVariableExecute(Sender: TObject);
    procedure actChooseExecute(Sender: TObject);
    procedure actChooseUpdate(Sender: TObject);
    procedure actDelExecute(Sender: TObject);
    procedure actDelUpdate(Sender: TObject);
    procedure ibdsPriceDocRelAfterInsert(DataSet: TDataSet);
    procedure ibdsPriceDocRelDOCFIELDNAMEChange(Sender: TField);
    procedure ibdsPriceDocRelDOCUMENTTYPEKEYChange(Sender: TField);
    procedure FormCreate(Sender: TObject);
    procedure gsiblcDocumentTypeChange(Sender: TObject);
    procedure gsiblcRelationNameChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function SetupDialog(DataSet: TDataSet; const isAppend: Boolean): Boolean;
  end;

var
  dlgPriceOption: TdlgPriceOption;

implementation

{$R *.DFM}

uses gp_dlgchoosepricevar_unit;

procedure TdlgPriceOption.actOkExecute(Sender: TObject);
begin
  if dsPPosOption.DataSet.State in [dsEdit, dsInsert] then
    dsPPosOption.DataSet.Post;

  if ibdsPriceFieldRel.State in [dsEdit, dsInsert] then
    ibdsPriceFieldRel.Post;

  if ibdsPriceDocRel.State in [dsEdit, dsInsert] then
    ibdsPriceDocRel.Post;

  ibdsPriceDocRel.ApplyUpdates;  

  if (dsPPosOption.DataSet as TIBDataSet).Transaction.InTransaction then
    (dsPPosOption.DataSet as TIBDataSet).Transaction.CommitRetaining;

  ModalResult := mrOk;  
end;

procedure TdlgPriceOption.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TdlgPriceOption.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if ModalResult <> mrOk then
  begin
    if dsPPosOption.DataSet.State in [dsEdit, dsInsert] then
      dsPPosOption.DataSet.Cancel;

    if ibdsPriceFieldRel.State in [dsEdit, dsInsert] then
      ibdsPriceFieldRel.Cancel;

    if ibdsPriceDocRel.State in [dsEdit, dsInsert] then
      ibdsPriceDocRel.Cancel;

    ibdsPriceDocRel.CancelUpdates;

    if (dsPPosOption.DataSet as TIBDataSet).Transaction.InTransaction then
      (dsPPosOption.DataSet as TIBDataSet).Transaction.RollBackRetaining;
  end;
end;

function TdlgPriceOption.SetupDialog(DataSet: TDataSet; const isAppend: Boolean): Boolean;
begin
  gsiblcFieldName.Transaction := (DataSet as TIBDataSet).Transaction;
  gsiblcCurr.Transaction := (DataSet as TIBDataSet).Transaction;
  gsiblcRelFieldName.Transaction := (DataSet as TIBDataSet).Transaction;
  gsiblcRelationName.Transaction := (DataSet as TIBDataSet).Transaction;
  gsiblcDocumentType.Transaction := (DataSet as TIBDataSet).Transaction;

  ibdsPriceFieldRel.Transaction := (DataSet as TIBDataSet).Transaction;
  ibdsPriceDocRel.Transaction := (DataSet as TIBDataSet).Transaction;

  dsPPosOption.DataSet := DataSet;

  if isAppend then
    dsPPosOption.DataSet.Append
  else
  begin
    dsPPosOption.DataSet.Edit;
    ibdsPriceFieldRel.ParamByName('fn').AsString :=
      dsPPosOption.DataSet.FieldByName('fieldname').AsString;
    ibdsPriceDocRel.ParamByName('fn').AsString :=
      dsPPosOption.DataSet.FieldByName('fieldname').AsString;
  end;
  ibdsPriceFieldRel.Open;
  ibdsPriceDocRel.Open;

  Result := ShowModal = mrOK;
end;

procedure TdlgPriceOption.actVariableExecute(Sender: TObject);
begin
  with TdlgChoosePriceVar.Create(Self) do
    try
      if SetupDialog(dsPPosOption.DataSet.FieldByName('FieldName').AsString) then
      begin
        if not (dsPPosOption.DataSet.State in [dsEdit, dsInsert]) then
          dsPPosOption.DataSet.Edit;
        dbmExpression.Field.Text := dbmExpression.Field.Text + Variable;
      end;
    finally
      Free;
    end;
end;

procedure TdlgPriceOption.actChooseExecute(Sender: TObject);
var
//  i: Integer;
  FieldName: String;
begin

  dsPPosOption.DataSet.Post;
  FieldName := dsPPosOption.DataSet.FieldByName('fieldname').AsString;
{  with TdlgFind.Create(Self) do
    try
      if ShowModal = mrOk then
      begin
        for i:= 0 to dbgFind.SelectedRows.Count - 1 do
        begin
          qryFind.GotoBookmark(Pointer(dbgFind.SelectedRows.Items[i]));
          ibdsPriceFieldRelName.Required := False;
          ibdsPriceFieldRel.Insert;
          try
            ibdsPriceFieldRel.FieldByName('FieldName').AsString := FieldName;
            ibdsPriceFieldRel.FieldByName('ContactKey').AsInteger :=
              qryFind.FieldByName('id').AsInteger;
            ibdsPriceFieldRel.Post;
          except
            ibdsPriceFieldRel.Cancel;
          end;
        end;
        ibdsPriceFieldRel.Close;
        ibdsPriceFieldRel.ParamByName('fn').AsString := FieldName;
        ibdsPriceFieldRel.Open;
      end;
    finally
      Free;
    end;}
end;

procedure TdlgPriceOption.actChooseUpdate(Sender: TObject);
begin
  actChoose.Enabled := not dsPPosOption.DataSet.FieldByName('fieldname').IsNull;
end;

procedure TdlgPriceOption.actDelExecute(Sender: TObject);
begin
  if ibdsPriceFieldRel.FieldByName('fieldname').AsString > '' then
    ibdsPriceFieldRel.Delete;
end;

procedure TdlgPriceOption.actDelUpdate(Sender: TObject);
begin
  actDel.Enabled := not dsPPosOption.DataSet.FieldByName('fieldname').IsNull and
    not ibdsPriceFieldRel.FieldByName('fieldname').IsNull;
end;

procedure TdlgPriceOption.ibdsPriceDocRelAfterInsert(DataSet: TDataSet);
begin
  ibdsPriceDocRel.FieldByName('FieldName').AsString :=
    dsPPosOption.DataSet.FieldByName('fieldname').AsString;
end;

procedure TdlgPriceOption.ibdsPriceDocRelDOCFIELDNAMEChange(
  Sender: TField);
begin
  ibdsPriceDocRel.FieldByName('lname').AsString :=
    gsiblcRelFieldName.Text;
end;

procedure TdlgPriceOption.ibdsPriceDocRelDOCUMENTTYPEKEYChange(
  Sender: TField);
begin
  ibdsPriceDocRel.FieldByName('NAME').AsString :=
    gsiblcDocumentType.Text;
end;

procedure TdlgPriceOption.FormCreate(Sender: TObject);
var
  OldOnExit: TNotifyEvent;
  OldOnKeyDown: TKeyEvent;
begin
  OldOnExit := gsiblcRelFieldName.OnExit;
  OldOnKeyDown := gsiblcRelFieldName.OnKeyDown;
  gsibgrPriceDocRel.AddControl('LNAME', gsiblcRelFieldName, OldOnExit,
    OldOnKeyDown);
  gsiblcRelFieldName.OnExit := OldOnExit;
  gsiblcRelFieldName.OnKeyDown := OldOnKeyDown;

  OldOnExit := gsiblcRelationName.OnExit;
  OldOnKeyDown := gsiblcRelationName.OnKeyDown;
  gsibgrPriceDocRel.AddControl('RELATIONNAME', gsiblcRelationName, OldOnExit,
    OldOnKeyDown);
  gsiblcRelationName.OnExit := OldOnExit;
  gsiblcRelationName.OnKeyDown := OldOnKeyDown;

  OldOnExit := gsiblcDocumentType.OnExit;
  OldOnKeyDown := gsiblcDocumentType.OnKeyDown;
  gsibgrPriceDocRel.AddControl('NAME', gsiblcDocumentType, OldOnExit,
    OldOnKeyDown);
  gsiblcDocumentType.OnExit := OldOnExit;
  gsiblcDocumentType.OnKeyDown := OldOnKeyDown;
end;

procedure TdlgPriceOption.gsiblcDocumentTypeChange(Sender: TObject);
begin
  if Assigned(gsiblcRelationName) then
    gsiblcRelationName.Condition := Format('doctypekey = %s',
      [gsiblcDocumentType.CurrentKey]);
end;

procedure TdlgPriceOption.gsiblcRelationNameChange(Sender: TObject);
begin
  if Assigned(gsiblcRelFieldName) then
    gsiblcRelFieldName.Condition := Format('relationname = ''%s''',
      [gsiblcRelationName.CurrentKey]);
end;

end.
