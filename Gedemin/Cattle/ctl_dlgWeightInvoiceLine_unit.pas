{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    ctl_dlgWeightInvoiceLine_unit.pas

  Abstract

    Dialog window.

  Author

    Denis Romanosvki  (01.04.2001)

  Revisions history

    1.0    01.04.2001    Denis    Initial version.


--}

unit ctl_dlgWeightInvoiceLine_unit;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, Mask, DBCtrls, gsIBLookupComboBox, ComCtrls,
  gsIBLargeTreeView, Db, IBCustomDataSet, IBDatabase, Grids, DBGrids,
  IBSQL, gsDBGrid, gsIBGrid, ctl_CattleConstants_unit, gsIBCtrlGrid,
  at_sql_setup, gd_createable_form;

type
  Tctl_dlgWeightInvoiceLine = class(TCreateableForm)
    Panel1: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    Panel2: TPanel;
    Bevel1: TBevel;
    lblDestination: TLabel;
    luDestination: TgsIBLookupComboBox;
    dbeQuantity: TDBEdit;
    Label3: TLabel;
    lblMeatWeight: TLabel;
    dbeMeatWeight: TDBEdit;
    dsInvoiceLine: TDataSource;
    ibdsInvoiceLine: TIBDataSet;
    dbeLiveWeight: TDBEdit;
    lblLiveWeight: TLabel;
    ibtrInvoiceLine: TIBTransaction;
    pnlTree: TPanel;
    Splitter1: TSplitter;
    dbeRealWeight: TDBEdit;
    lblRealWeight: TLabel;
    Splitter2: TSplitter;
    Label1: TLabel;
    luGood: TgsIBLookupComboBox;
    lblGoodName: TLabel;
    Bevel2: TBevel;
    grdBranch3: TgsIBGrid;
    grdBranch2: TgsIBGrid;
    grdBranch1: TgsIBGrid;
    btnNext: TButton;
    ibdsBranch1: TIBDataSet;
    dsBranch1: TDataSource;
    ibdsBranch2: TIBDataSet;
    dsBranch2: TDataSource;
    ibdsBranch3: TIBDataSet;
    dsBranch3: TDataSource;
    ibsqlWeight: TIBSQL;
    atSQLSetup: TatSQLSetup;
    q: TIBSQL;
    IBSQL: TIBSQL;
    Button1: TButton;

    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnNextClick(Sender: TObject);
    procedure ibdsBranch1AfterScroll(DataSet: TDataSet);
    procedure ibdsBranch2AfterScroll(DataSet: TDataSet);
    procedure ibdsBranch3AfterScroll(DataSet: TDataSet);
    procedure ibdsBranch1AfterInsert(DataSet: TDataSet);
    procedure ibdsBranch1AfterOpen(DataSet: TDataSet);
    procedure luGoodEnter(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure dbeQuantityExit(Sender: TObject);

  private
    FInvoiceID: Integer;
    FInvoiceLineID: Integer;

    FDataSet: TIBDataSet;
    FTransaction: TIBTransaction;
    FCanCommit: Boolean;
    FInvoiceKind: String;
    FBranchID: String;

    FCoefficientField: String;
    FDestinationKey: Integer;

    FAllQuantity: Double;
    FCurrQuantity: Double;

    function GetDataSet: TIBDataSet;
    function GetIsOwnDataSet: Boolean;
    function GetTransaction: TIBTransaction;

    procedure KillRequired;

    procedure MakeStartingSettings;
    procedure MakeFinishingSettings;

    procedure FindGood(S: String);
    procedure CalculateCoefficient;

  protected
    procedure CheckConsistency;

    property Transaction: TIBTransaction read GetTransaction;
    property IsOwnDataSet: Boolean read GetIsOwnDataSet;
    property DataSet: TIBDataSet read GetDataSet;

  public
    procedure LoadSettings; override;
    procedure SaveSettings; override;

    function AddInvoiceLine: Boolean; overload;
    function AddInvoiceLine(ADataSet: TIBDataSet; AnAllQuantity: Double): Boolean; overload;

    function EditInvoiceLine: Boolean; overload;
    function EditInvoiceLine(ADataSet: TIBDataSet; AnAllQuantity: Double): Boolean; overload;

    property InvoiceID: Integer read FInvoiceID write FInvoiceID;
    property InvoiceLineID: Integer read FInvoiceLineID write FInvoiceLineID;
    property InvoiceKind: String read FInvoiceKind write FInvoiceKind;
    property CanCommit: Boolean read FCanCommit write FCanCommit;
    property DestinationKey: Integer read FDestinationKey write FDestinationKey;
  end;

  EWeightInvoiceLineError = class(Exception);

var
  ctl_dlgWeightInvoiceLine: Tctl_dlgWeightInvoiceLine;

implementation

uses
  dmDataBase_unit, Storages, gsStorage, ctl_ChooseCattleBranch_unit,
  ctl_dlgSetupPrice_unit, gdcBaseInterface;

{$R *.DFM}

type
  TWinControlCracker = class(TWinControl);

const
  cst_small = 0.00000000001;

{ TdlgWeightInvoiceLine }

function Tctl_dlgWeightInvoiceLine.AddInvoiceLine(
  ADataSet: TIBDataSet; AnAllQuantity: Double): Boolean;
begin
  FDataSet := ADataSet;
  FTransaction := FDataSet.Transaction;

  dsInvoiceLine.DataSet := FDataSet;

  ibdsBranch1.Transaction := FTransaction;
  ibdsBranch2.Transaction := FTransaction;
  ibdsBranch3.Transaction := FTransaction;

  ibsqlWeight.Transaction := FTransaction;

  luGood.Transaction := FTransaction;
  luDestination.Transaction := FTransaction;

  FAllQuantity := AnAllQuantity;

  Result := AddInvoiceLine;

  if Result then
  begin
    if FCanCommit then
      Transaction.CommitRetaining;
  end else begin
    if FCanCommit then
      Transaction.RollbackRetaining;
  end;
end;

function Tctl_dlgWeightInvoiceLine.AddInvoiceLine: Boolean;
begin
  if IsOwnDataSet then
    DataSet.Close;

  if not Transaction.Active then
    Transaction.StartTransaction;

  FInvoiceLineID := gdcBaseManager.GetNextID;

  if IsOwnDataSet then
  begin
    DataSet.Params.ByName('INVOICEKEY').AsInteger := FInvoiceID;
    DataSet.Open;
  end;

  KillRequired;

  with DataSet do
  begin
    Insert;
    FieldByName('INVOICEKEY').AsInteger := FInvoiceID;
    FieldByName('ID').AsInteger := FInvoiceLineID;

    FieldByName('quantity').AsInteger := 1;

    FieldByName('AFULL').AsInteger := -1;
    FieldByName('ACHAG').AsInteger := -1;
    FieldByName('AVIEW').AsInteger := -1;
    if FDestinationKey <> -1 then
      FieldByName('DESTKEY').AsInteger := FDestinationKey;
  end;

  MakeStartingSettings;

  FCurrQuantity := 1;

  Result := ShowModal = mrOk;

  if Result then
  begin
    MakeFinishingSettings;
    DataSet.Post;

    if IsOwnDataSet then
      Transaction.Commit;
  end else begin
    DataSet.Cancel;

    if IsOwnDataSet then
      Transaction.Rollback;
  end;
end;

function Tctl_dlgWeightInvoiceLine.EditInvoiceLine(
  ADataSet: TIBDataSet; AnAllQuantity: Double): Boolean;
begin
  FDataSet := ADataSet;
  FTransaction := FDataSet.Transaction;

  dsInvoiceLine.DataSet := FDataSet;

  ibdsBranch1.Transaction := FTransaction;
  ibdsBranch2.Transaction := FTransaction;
  ibdsBranch3.Transaction := FTransaction;

  ibsqlWeight.Transaction := FTransaction;

  FInvoiceID := FDataSet.FieldByName('INVOICEKEY').AsInteger;

  FAllQuantity := AnAllQuantity;

  Result := EditInvoiceLine;

  if Result then
  begin
    if FCanCommit then
      Transaction.CommitRetaining;
  end else begin
    if FCanCommit then
      Transaction.RollbackRetaining;
  end;
end;

function Tctl_dlgWeightInvoiceLine.EditInvoiceLine: Boolean;
begin
  if IsOwnDataSet then
    DataSet.Close;

  if not Transaction.Active then
    Transaction.StartTransaction;

  if IsOwnDataSet then
  begin
    DataSet.Params.ByName('DOCUMENTKEY').AsInteger := FInvoiceLineID;
    DataSet.Open;
  end;

  if DataSet.IsEmpty then
    raise EWeightInvoiceLineError.Create('Can''t find record by identifier!');

  KillRequired;

  DataSet.Edit;

  MakeStartingSettings;

  FCurrQuantity := DataSet.FieldByName('Quantity').AsFloat;

  Result := ShowModal = mrOk;

  if Result then
  begin
    MakeFinishingSettings;
    DataSet.Post;

    if IsOwnDataSet then
      Transaction.Commit;
  end else begin
    DataSet.Cancel;

    if IsOwnDataSet then
      Transaction.Rollback;
  end;
end;

function Tctl_dlgWeightInvoiceLine.GetDataSet: TIBDataSet;
begin
  if Assigned(FDataSet) then
    Result := FDataSet
  else
    Result := ibdsInvoiceLine;
end;

function Tctl_dlgWeightInvoiceLine.GetIsOwnDataSet: Boolean;
begin
  Result := FDataSet = ibdsInvoiceLine;
end;

function Tctl_dlgWeightInvoiceLine.GetTransaction: TIBTransaction;
begin
  if Assigned(FTransaction) then
    Result := FTransaction
  else
    Result := ibtrInvoiceLine;
end;

procedure Tctl_dlgWeightInvoiceLine.KillRequired;
var
  I: Integer;
begin
  for I := 0 to DataSet.FieldCount - 1 do
    DataSet.Fields[I].Required := False;
end;

procedure Tctl_dlgWeightInvoiceLine.MakeFinishingSettings;
var
  Coefficient: Currency;
begin
  if Assigned(DataSet.FindField('GOODNAME')) then
    DataSet.FieldByName('GOODNAME').AsString := luGood.Text;

  if Assigned(DataSet.FindField('DESTNAME')) then
    DataSet.FieldByName('DESTNAME').AsString := luDestination.Text;

  q.Transaction := DataSet.Transaction;
  q.Close;
  q.SQL.Text := 'SELECT ctld.coeff FROM ctl_discount ctld WHERE ctld.goodkey=:GK';
  q.Prepare;
  q.ParamByName('GK').AsInteger := luGood.CurrentKeyInt;
  q.ExecQuery;
  if q.EOF then Coefficient := 0 else
    Coefficient := q.Fields[0].AsCurrency;
  q.Close;

  //
  //  Осуществляем расчет скидки
  if Coefficient = 0 then
    MessageBox(Handle, PChar('У товара ' + luGood.Text + ' отсутвует коэффициент выхода мяса'),
      'Внмание!', MB_OK)
  else
    if InvoiceKind = 'M' then
      DataSet.FieldByName('REALWEIGHT').AsCurrency :=
        Round(DataSet.FieldByName('MEATWEIGHT').AsCurrency / Coefficient + cst_small)
    else
      if (Coefficient > 0) and (Coefficient < 1) then
        DataSet.FieldByName('MEATWEIGHT').AsCurrency :=
          Round(DataSet.FieldByName('REALWEIGHT').AsCurrency * Coefficient + cst_small)
      else
        DataSet.FieldByName('MEATWEIGHT').Clear;
end;

procedure Tctl_dlgWeightInvoiceLine.MakeStartingSettings;
begin
  dbeMeatWeight.Enabled := InvoiceKind = 'M';
  lblMeatWeight.Enabled := InvoiceKind = 'M';

  dbeLiveWeight.Enabled := InvoiceKind = 'C';
  lblLiveWeight.Enabled := InvoiceKind = 'C';

  dbeRealWeight.Enabled := InvoiceKind = 'C';
  lblRealWeight.Enabled := InvoiceKind = 'C';

  if (InvoiceKind <> 'M') and (InvoiceKind <> 'C') then
    raise EWeightInvoiceLineError.Create('Неверный тип накладной!');

  if not ibdsBranch1.Active then
    ibdsBranch1.ParamByName('PARENTKEY').AsString := FBranchID;

  ibdsBranch3.Open;
  ibdsBranch2.Open;
  ibdsBranch1.Open;

  FDestinationKey := Dataset.FieldByName('DESTKEY').AsInteger;
end;

procedure Tctl_dlgWeightInvoiceLine.FormCreate(Sender: TObject);
var
  F: TgsStorageFolder;
begin
  FCanCommit := True;
  FInvoiceKind := #0;
  FDestinationKey := -1;

  F := GlobalStorage.OpenFolder(FOLDER_CATTLE_SETTINGS, True, False);
  try
    FBranchID := F.ReadString(VALUE_CATTLEBRANCH, '');;
    FCoefficientField := F.ReadString(VALUE_GOODGROUP_COEFFICIENT, '');;

    if FCoefficientField = '' then
      raise EWeightInvoiceLineError.Create('Необходимо установить поле ' +
        '"Коэффициент пересчета" для групп скота (мяса)');
  finally
    GlobalStorage.CloseFolder(F, False);
  end;
end;

procedure Tctl_dlgWeightInvoiceLine.CheckConsistency;
begin
  try
    if luGood.CurrentKey = '' then
    begin
      luGood.SetFocus;
      raise EWeightInvoiceLineError.Create('Выберите наименование животного/мяса!');
    end else

    if DataSet.FieldByName('QUANTITY').AsInteger = 0 then
    begin
      dbeQuantity.SetFocus;
      raise EWeightInvoiceLineError.Create('Укажите количество голов!');
    end else

    if
      (InvoiceKind = 'C') and
      (DataSet.FieldByName('LIVEWEIGHT').AsCurrency = 0)
    then begin
      dbeLiveWeight.SetFocus;

      raise EWeightInvoiceLineError.
        Create('Необходимо указать общий вес скота без скидки!');
    end else

    if
      (InvoiceKind = 'C') and
      (DataSet.FieldByName('REALWEIGHT').AsCurrency = 0)
    then begin
      dbeRealWeight.SetFocus;

      raise EWeightInvoiceLineError.
        Create('Необходимо указать общий вес скота со скидкой!');
    end else

    if
      (InvoiceKind = 'M') and
      (DataSet.FieldByName('MEATWEIGHT').AsCurrency = 0)
    then begin
      dbeMeatWeight.SetFocus;

      raise EWeightInvoiceLineError.
        Create('Необходимо указать общий вес мяса!');
    end else

    if DataSet.FieldByName('DESTKEY').IsNull and luDestination.Visible then
    begin
      luDestination.SetFocus;
      raise EWeightInvoiceLineError.Create('Укажите вид назначения!');
    end;
  except
    ModalResult := mrNone;
    raise;
  end;
end;

procedure Tctl_dlgWeightInvoiceLine.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if ModalResult = mrOk then
    CheckConsistency;
end;

procedure Tctl_dlgWeightInvoiceLine.btnNextClick(Sender: TObject);
begin
  //
  // Сохраняем старое

  CheckConsistency;


  MakeFinishingSettings;
  DataSet.Post;

  if IsOwnDataSet then
    Transaction.CommitRetaining;

  //
  //  Создаем новое

  if IsOwnDataSet then
    DataSet.Close;

  FInvoiceLineID := gdcBaseManager.GetNextID;

  if IsOwnDataSet then
  begin
    DataSet.Params.ByName('INVOICEKEY').AsInteger := FInvoiceID;
    DataSet.Open;
  end;

  KillRequired;

  with DataSet do
  begin
    Insert;
    FieldByName('INVOICEKEY').AsInteger := FInvoiceID;
    FieldByName('ID').AsInteger := FInvoiceLineID;
    FieldByName('quantity').AsInteger := 1;
    if FDestinationKey <> -1 then
      FieldByName('DESTKEY').AsInteger := FDestinationKey;

    FieldByName('AFULL').AsInteger := -1;
    FieldByName('ACHAG').AsInteger := -1;
    FieldByName('AVIEW').AsInteger := -1;
  end;

  MakeStartingSettings;

  FCurrQuantity := 1;

  grdBranch1.SetFocus;
end;

procedure Tctl_dlgWeightInvoiceLine.ibdsBranch1AfterScroll(
  DataSet: TDataSet);
begin
{  grdBranch2.Enabled := not ibdsBranch2.IsEmpty;
  grdBranch3.Enabled := not ibdsBranch3.IsEmpty;

  if not grdBranch2.Enabled then
  begin
    luGood.Condition := Format(
      'GROUPKEY IN (SELECT GG.ID FROM GD_GOODGROUP GG WHERE (GG.LB >= %s) AND (GG.RB <= %s))',
      [ibdsBranch1.FieldByName('LB').AsString, ibdsBranch1.FieldByName('RB').AsString]);
  end;}
end;

procedure Tctl_dlgWeightInvoiceLine.ibdsBranch2AfterScroll(
  DataSet: TDataSet);
begin
{  grdBranch3.Enabled := not ibdsBranch3.IsEmpty;

  if not grdBranch3.Enabled then
  begin
    luGood.Condition := Format(
      'GROUPKEY IN (SELECT GG.ID FROM GD_GOODGROUP GG WHERE (GG.LB >= %s) AND (GG.RB <= %s))',
      [ibdsBranch2.FieldByName('LB').AsString, ibdsBranch2.FieldByName('RB').AsString]);
  end;}
end;

procedure Tctl_dlgWeightInvoiceLine.ibdsBranch3AfterScroll(
  DataSet: TDataSet);
begin
{  if ibdsBranch3.RecordCount > 0 then
    luGood.Condition := Format(
      'GROUPKEY IN (SELECT GG.ID FROM GD_GOODGROUP GG WHERE (GG.LB >= %s) AND (GG.RB <= %s))',
      [ibdsBranch3.FieldByName('LB').AsString, ibdsBranch3.FieldByName('RB').AsString])
  else
    if ibdsBranch2.RecordCount > 0 then
      luGood.Condition := Format(
        'GROUPKEY IN (SELECT GG.ID FROM GD_GOODGROUP GG WHERE (GG.LB >= %s) AND (GG.RB <= %s))',
        [ibdsBranch2.FieldByName('LB').AsString, ibdsBranch2.FieldByName('RB').AsString])
    else
      if ibdsBranch1.RecordCount > 0 then
        luGood.Condition := Format(
          'GROUPKEY IN (SELECT GG.ID FROM GD_GOODGROUP GG WHERE (GG.LB >= %s) AND (GG.RB <= %s))',
          [ibdsBranch1.FieldByName('LB').AsString, ibdsBranch1.FieldByName('RB').AsString]);}
end;

procedure Tctl_dlgWeightInvoiceLine.FindGood(S: String);
var
  Weigth: Currency;
begin

  Weigth :=
    DataSet.FieldByName('REALWEIGHT').AsFloat /
    DataSet.FieldByName('QUANTITY').AsInteger;

  ibsqlWeight.Close;

  ibsqlWeight.ParamByName('WEIGHT').AsFloat := Weigth;

  if grdBranch3.Enabled then
  begin
    ibsqlWeight.ParamByName('LB').AsInteger :=
      ibdsBranch3.FieldByName('LB').AsInteger;

    ibsqlWeight.ParamByName('RB').AsInteger :=
      ibdsBranch3.FieldByName('RB').AsInteger;
  end else

  if grdBranch2.Enabled then
  begin
    ibsqlWeight.ParamByName('LB').AsInteger :=
      ibdsBranch2.FieldByName('LB').AsInteger;

    ibsqlWeight.ParamByName('RB').AsInteger :=
      ibdsBranch2.FieldByName('RB').AsInteger;
  end else

  if grdBranch1.Enabled then
  begin
    ibsqlWeight.ParamByName('LB').AsInteger :=
      ibdsBranch1.FieldByName('LB').AsInteger;

    ibsqlWeight.ParamByName('RB').AsInteger :=
      ibdsBranch1.FieldByName('RB').AsInteger;
  end;

  ibsqlWeight.ExecQuery;

  if ibsqlWeight.RecordCount > 0 then
    luGood.CurrentKey := ibsqlWeight.FieldByName('GOODKEY').AsString;

  if luGood.CurrentKey = '' then
  begin
    IBSQl.Transaction := FTransaction;
    IBSQl.Close;
    IBSQl.SQL.Text := 'SELECT COUNT(*) as C FROM GD_GOOD WHERE ' + S;
    IBSQl.ExecQuery;
    if IBSQl.FieldByName('C').AsInteger = 1 then
    begin
      IBSQl.Close;
      IBSQl.SQL.Text := 'SELECT max(id) as id FROM GD_GOOD WHERE ' + S;
      IBSQl.ExecQuery;
      luGood.CurrentKeyInt := IBSQl.FieldByName('id').AsInteger;
    end;
  end;

  ibsqlWeight.Close;
end;

procedure Tctl_dlgWeightInvoiceLine.CalculateCoefficient;
var
  Coefficient: Currency;
begin
  if grdBranch3.Enabled then
    Coefficient := ibdsBranch3.FieldByName(FCoefficientField).AsFloat else
  if grdBranch2.Enabled then
    Coefficient := ibdsBranch2.FieldByName(FCoefficientField).AsFloat
  else
    Coefficient := ibdsBranch1.FieldByName(FCoefficientField).AsFloat;

  if Coefficient = 0 then
    DataSet.FieldByName('REALWEIGHT').AsCurrency :=
      DataSet.FieldByName('MEATWEIGHT').AsCurrency
  else
    DataSet.FieldByName('REALWEIGHT').AsCurrency :=
      Round(DataSet.FieldByName('MEATWEIGHT').AsCurrency
       /
      Coefficient + cst_small);
end;

procedure Tctl_dlgWeightInvoiceLine.ibdsBranch1AfterInsert(
  DataSet: TDataSet);
begin
  DataSet.Cancel;
end;

procedure Tctl_dlgWeightInvoiceLine.ibdsBranch1AfterOpen(
  DataSet: TDataSet);
var
  I: Integer;  
begin
  for I := 0 to DataSet.FieldCount - 1 do
    DataSet.Fields[I].ReadOnly := True;

  DataSet.FieldByName(FCoefficientField).ReadOnly := False;
end;

procedure Tctl_dlgWeightInvoiceLine.luGoodEnter(Sender: TObject);
var
  S: String;
begin
  if ibdsBranch3.RecordCount > 0 then
    S := Format(
      'GROUPKEY IN (SELECT GG.ID FROM GD_GOODGROUP GG WHERE (GG.LB >= %s) AND (GG.RB <= %s))',
      [ibdsBranch3.FieldByName('LB').AsString, ibdsBranch3.FieldByName('RB').AsString])
  else
    if ibdsBranch2.RecordCount > 0 then
      S := Format(
        'GROUPKEY IN (SELECT GG.ID FROM GD_GOODGROUP GG WHERE (GG.LB >= %s) AND (GG.RB <= %s))',
        [ibdsBranch2.FieldByName('LB').AsString, ibdsBranch2.FieldByName('RB').AsString])
    else
      if ibdsBranch1.RecordCount > 0 then
        S := Format(
          'GROUPKEY IN (SELECT GG.ID FROM GD_GOODGROUP GG WHERE (GG.LB >= %s) AND (GG.RB <= %s))',
          [ibdsBranch1.FieldByName('LB').AsString, ibdsBranch1.FieldByName('RB').AsString]);
  luGood.Condition := S;

  if
    (InvoiceKind = 'M') and
    not DataSet.FieldByName('MEATWEIGHT').IsNull and
    not DataSet.FieldByName('QUANTITY').IsNull
  then begin
    CalculateCoefficient;
    FindGood(S);
  end else

  if
    (InvoiceKind = 'C') and
    not DataSet.FieldByName('LIVEWEIGHT').IsNull and
    not DataSet.FieldByName('REALWEIGHT').IsNull and
    not DataSet.FieldByName('QUANTITY').IsNull
  then begin
    FindGood(S);
  end;
end;

procedure Tctl_dlgWeightInvoiceLine.LoadSettings;
begin
  inherited;
  UserStorage.LoadComponent(grdBranch1, grdBranch1.LoadFromStream);
  UserStorage.LoadComponent(grdBranch2, grdBranch2.LoadFromStream);
  UserStorage.LoadComponent(grdBranch3, grdBranch3.LoadFromStream);
end;

procedure Tctl_dlgWeightInvoiceLine.SaveSettings;
begin
  inherited;
  UserStorage.SaveComponent(grdBranch1, grdBranch1.SaveToStream);
  UserStorage.SaveComponent(grdBranch2, grdBranch2.SaveToStream);
  UserStorage.SaveComponent(grdBranch3, grdBranch3.SaveToStream);
end;

procedure Tctl_dlgWeightInvoiceLine.Button1Click(Sender: TObject);
var
  WC: TWinControl;
  L: TList;
  I: Integer;
begin
  if (Screen.ActiveControl <> nil) and (Screen.ActiveControl.Parent <> nil) then
  begin
    L := TList.Create;
    try
      Screen.ActiveControl.Parent.GetTabOrderList(L);
      for I := L.Count - 1 downto 0 do
        if not TWinControl(L[I]).TabStop then L.Delete(I);
      if ((L.Count = 0) or (Screen.ActiveControl = L[L.Count - 1])) and (Screen.ActiveControl.Parent.Parent <> nil) then
      begin
        if Screen.ActiveControl.Parent.Parent is TPageControl then
        begin
          if (Screen.ActiveControl.Parent.Parent as TPageControl).ActivePageIndex =
            (Screen.ActiveControl.Parent.Parent as TPageControl).PageCount - 1 then
          begin
            if Screen.ActiveControl.Parent.Parent.Parent <> nil then
            TWinControlCracker(Screen.ActiveControl.Parent.Parent.Parent).SelectNext(Screen.ActiveControl.Parent.Parent, True, False);
          end else
          begin
            WC := Screen.ActiveControl.Parent.Parent;
            (Screen.ActiveControl.Parent.Parent as TPageControl).SelectNextPage(True);
            Application.ProcessMessages;
            (WC as TPageControl).ActivePage.GetTabOrderList(L);
            for I := 0 to L.Count - 1 do
              if TWinControl(L[I]).TabStop then
                break;
  //          SetFocusedControl(TWinControl(L[I]));
  //          ActiveControl := TWinControl(L[I]);
          end;
        end else
        begin
          TWinControlCracker(Screen.ActiveControl.Parent.Parent).SelectNext(Screen.ActiveControl, True, True);
        end;
      end else
      begin
        TWinControlCracker(Screen.ActiveControl.Parent).SelectNext(Screen.ActiveControl, True, True);
      end;
    finally
      L.Free;
    end;
  end;
end;

procedure Tctl_dlgWeightInvoiceLine.dbeQuantityExit(Sender: TObject);
var
  WasTabOrder: TTabOrder;
begin
  try
    FAllQuantity := FAllQuantity - StrToFloat(dbeQuantity.Text){ + FCurrQuantity};
    FCurrQuantity := StrToFloat(dbeQuantity.Text);
  except
    dbeQuantity.SetFocus;
    raise Exception.Create('Неправильно введено количество!');
  end;

  if (FAllQuantity <= 0) and (btnOk.TabOrder > btnNext.TabOrder) then
  begin
    WasTabOrder := btnOk.TabOrder;
    btnOk.TabOrder := btnNext.TabOrder;
    btnNext.TabOrder := WasTabOrder;
  end;
end;

end.

