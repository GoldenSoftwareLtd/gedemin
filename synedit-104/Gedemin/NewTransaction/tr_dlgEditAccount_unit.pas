unit tr_dlgEditAccount_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Mask, DBCtrls, ExtCtrls, Db, IBCustomDataSet, Grids, DBGrids,
  gsDBGrid, gsIBGrid, dmDatabase_unit, ActnList, at_sql_setup, IBDatabase,
  gsIBLookupComboBox, IBSQL, gd_createable_form;

type
  TdlgEditAccount = class(TCreateableForm)
    lblAlias: TLabel;
    dbedAlias: TDBEdit;
    lblName: TLabel;
    dbedName: TDBEdit;
    pAccountInfo: TPanel;
    GroupBox1: TGroupBox;
    dbcbCurrAccount: TDBCheckBox;
    dbcbOffBalance: TDBCheckBox;
    dbrgTypeAccount: TDBRadioGroup;
    gsibgrAnalytical: TgsIBGrid;
    Label1: TLabel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    ibdsAccount: TIBDataSet;
    ibdsAnalytical: TIBDataSet;
    dsAccount: TDataSource;
    dsAnalytical: TDataSource;
    ibdsAnalyticalFIELDNAME: TIBStringField;
    ibdsAnalyticalLNAME: TIBStringField;
    ActionList1: TActionList;
    actOk: TAction;
    actCancel: TAction;
    actNext: TAction;
    atSQLSetup: TatSQLSetup;
    IBTransaction: TIBTransaction;
    Label2: TLabel;
    gsiblcGroupAccount: TgsIBLookupComboBox;
    dbcbGrade: TDBCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure actOkExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actNextExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
  private
    FID: Integer;
    FCurrentID: Integer;
    FGrade: Integer;
    FParent: Integer;
    FirstHeight: Integer;
    FisShowDlg: Boolean;
    FIsOk: Boolean;
    FNameAccount: String;

    procedure SetGrade(const aGrade: Integer);
    procedure Prepare;
    procedure MakeFormForGrade;
    function Save: Boolean;
    procedure SetAnalytical;
    procedure GetAnalytical;
    procedure GradeChanged(Sender: TField);
  public
    procedure SetupDialog(const aID, aCurrentID, aParent, aGrade: Integer);

    property ID: Integer read FCurrentID;
    property Grade: Integer read FGrade;
    property IsOK: Boolean read FIsOk;
    property Parent: Integer read FParent;
  end;

var
  dlgEditAccount: TdlgEditAccount;

implementation

{$R *.DFM}

uses tr_dlgChooseGrade_unit;

{ TdlgEditAccount }

procedure TDlgEditAccount.SetAnalytical;
begin
  if FGrade >= 2 then
  begin
    ibdsAnalytical.Open;
    ibdsAnalytical.DisableControls;
    try
      ibdsAnalytical.First;
      while not ibdsAnalytical.EOF do
      begin
        if ibdsAccount.FieldByName(Trim(ibdsAnalytical.FieldByName('fieldname').AsString)).AsInteger = 1
        then
          gsibgrAnalytical.CheckBox.CheckList.Add(ibdsAnalytical.FieldByName('fieldname').AsString);
        ibdsAnalytical.Next;
      end;
    finally
      ibdsAnalytical.EnableControls;
    end;
  end;  
end;

procedure TdlgEditAccount.Prepare;
begin
  if not ibdsAccount.Transaction.InTransaction then
    ibdsAccount.Transaction.StartTransaction;

  if not ibdsAccount.Active then
  begin
    ibdsAccount.Params.ByName('accountkey').AsInteger := FID;
    ibdsAccount.Open;
  end;

  if (FGrade >= 2) then
    SetAnalytical;

  ibdsAccount.FieldByName('lb').Required := False;
  ibdsAccount.FieldByName('rb').Required := False;

  if (FID = -1) then
  begin
    ibdsAccount.Insert;
    ibdsAccount.FieldByName('ID').AsInteger := GenUniqueID;
    FCurrentID := ibdsAccount.FieldByName('ID').AsInteger;
    if FParent <> -1 then
      ibdsAccount.FieldByName('parent').AsInteger := FParent;
    ibdsAccount.FieldByName('grade').AsInteger := FGrade;
    ibdsAccount.FieldByName('afull').AsInteger := -1;
    ibdsAccount.FieldByName('achag').AsInteger := -1;
    ibdsAccount.FieldByName('aview').AsInteger := -1;
    ibdsAccount.FieldByName('multycurr').AsInteger := 0;
    ibdsAccount.FieldByName('offbalance').AsInteger := 0;
    ibdsAccount.FieldByName('typeaccount').AsInteger := 0;
  end
  else
    ibdsAccount.Edit;
end;

procedure TdlgEditAccount.MakeFormForGrade;
begin
  pAccountInfo.Visible := FGrade >= 2;
  gsibgrAnalytical.Visible := FGrade >= 2;
  if FGrade < 2 then
    Height := FirstHeight - pAccountInfo.Height - gsibgrAnalytical.Height
  else
    Height := FirstHeight;
  case FGrade of
  0:
    begin
      FNameAccount := 'Наименование плана';
      lblName.Caption := 'Коментарий';
      Caption := 'Параметры плана счетов';
    end;
  1:
    begin
      FNameAccount := 'Наименование раздела';
      lblName.Caption := 'Описание';
      Caption := 'Параметры раздела';
    end;
  else
  begin
    FNameAccount := 'Номер счета';
    lblName.Caption := 'Наименование счета';
    Caption := 'Параметры счета';
  end;
  end;
  lblAlias.Caption := FNameAccount;
end;

procedure TdlgEditAccount.SetupDialog(const aID, aCurrentID, aParent, aGrade: Integer);
begin
  if not IBTransaction.InTransaction then
    IBTransaction.StartTransaction;
    
  FID := aID;
  FParent := aParent;
  FCurrentID := aCurrentID;

  if (aGrade < 2) and (FID = -1) then
  begin
    if FisShowDlg then
    begin
      FGrade := -1;
      with TdlgChooseGrade.Create(Self) do
        try
          FirstGrade := aGrade;
          if ShowModal = mrOk then
          begin
            FGrade := Grade;
            FisShowDlg := isShow;
          end;
        finally
          Free;
        end;
      if FGrade = -1 then
        abort;
    end;
  end
  else
  begin
    FGrade := aGrade;
    actNext.Enabled := FID = -1;
  end;

  if (FGrade > aGrade) and (FCurrentID <> -1) then
    FParent := FCurrentID;

  if FGrade = 0 then
    FParent := -1;

  SetGrade(FGrade);
  MakeFormForGrade;
  Prepare;

  ibdsAccount.FieldByName('Grade').OnChange := GradeChanged;
end;

procedure TdlgEditAccount.FormCreate(Sender: TObject);
begin
  FirstHeight := Height;
  FisShowDlg := True;
  FisOk := False;
end;

function TdlgEditAccount.Save: Boolean;
var
  ibsql: TIBSQL;
begin
  Result := False;
  dbedName.SetFocus;
  try
    if ibdsAccount.FieldByName('Alias').AsString = '' then
    begin
      MessageBox(HANDLE, Pchar(Format('Необходимо заполнить %s', [FNameAccount])), 'Внимание',
        mb_Ok or mb_IconInformation);
      dbedAlias.SetFocus;   
      exit;
    end;

    if ibdsAccount.FieldByName('Grade').AsInteger > 1 then
    begin
      ibsql := TIBSQL.Create(Self);
      try
        ibsql.Transaction := IBTransaction;
        
        ibsql.SQL.Text :=
          'SELECT id FROM gd_cardaccount c WHERE c.alias = :alias and ' +
          '  c.rb <= ' +
          '  (SELECT c1.rb FROM gd_cardaccount c1 where c1.parent is NULL and ' +
          ' c1.rb >= (SELECT rb FROM gd_cardaccount c2 where id = :parent) and ' +
          ' c1.lb <= (SELECT lb FROM gd_cardaccount c2 where id = :parent)) and ' +
          '  c.lb >= ' +
          '  (SELECT c1.lb FROM gd_cardaccount c1 where c1.parent is NULL and ' +
          ' c1.rb >= (SELECT rb FROM gd_cardaccount c2 where id = :parent) and ' +
          ' c1.lb <= (SELECT lb FROM gd_cardaccount c2 where id = :parent)) and ' +
          ' id <> :id ';

        ibsql.Prepare;
        ibsql.ParamByName('Alias').AsString := ibdsAccount.FieldByName('Alias').AsString;
        ibsql.ParamByName('Parent').AsInteger := FParent;
        ibsql.ParamByName('id').AsInteger := ibdsAccount.FieldByName('id').AsInteger;
        ibsql.ExecQuery;
        try
          if ibsql.RecordCount = 1 then
          begin
            MessageBox(HANDLE, PChar(Format('Счет %s уже есть в текущем плане счетов',
              [ibdsAccount.FieldByName('Alias').AsString])), 'Внимание',
              mb_Ok or mb_IconInformation);
            exit;
          end;
        finally
          ibsql.Close;
        end;

        ibsql.SQL.Text := 'SELECT Grade FROM gd_cardaccount WHERE id = :id';
        ibsql.Prepare;
        ibsql.ParamByName('id').AsInteger := ibdsAccount.FieldByName('Parent').AsInteger;
        ibsql.ExecQuery;
        if (ibsql.RecordCount = 0) or (ibsql.FieldByName('Grade').AsInteger <>
            ibdsAccount.FieldByName('Grade').AsInteger - 1)
        then
        begin
          if ibdsAccount.FieldByName('Grade').AsInteger = 3 then
            MessageBox(HANDLE,
             PChar(Format('Необходимо указать счет, к которому относится субсчет %s',
               [ibdsAccount.FieldByName('Alias').AsString])), 'Внимание',
               mb_Ok or mb_IconInformation)
          else
            MessageBox(HANDLE,
             PChar(Format('Необходимо указать раздел, к которому относится счет %s',
               [ibdsAccount.FieldByName('Alias').AsString])), 'Внимание',
               mb_Ok or mb_IconInformation);
          gsiblcGroupAccount.SetFocus;
          exit;
        end;
      finally
        ibsql.Close;
        ibsql.Free;
      end;
    end;

    GetAnalytical;
    if ibdsAccount.State in [dsEdit, dsInsert] then
      ibdsAccount.Post;

    if ibdsAccount.Transaction.InTransaction then
      ibdsAccount.Transaction.Commit;

    Result := True;
  except
  end;
  
  FisOK := FisOk or Result;
end;

procedure TdlgEditAccount.GetAnalytical;
var
  i: Integer;
begin
  if FGrade >= 2 then
  begin
    ibdsAnalytical.DisableControls;
    try
      if not (ibdsAccount.State in [dsEdit, dsInsert]) then
        ibdsAccount.Edit;

      ibdsAnalytical.First;
      while not ibdsAnalytical.EOF do
      begin
        try
          ibdsAccount.FieldByName(Trim(ibdsAnalytical.FieldByName('fieldname').AsString)).Clear;
        except
        end;
        ibdsAnalytical.Next;
      end;
    finally
      ibdsAnalytical.First;
      ibdsAnalytical.EnableControls;
    end;

    if not (ibdsAccount.State in [dsEdit, dsInsert]) then
      ibdsAccount.Edit;

    for i:= 0 to gsibgrAnalytical.CheckBox.CheckList.Count - 1 do
    begin

      try
        ibdsAccount.FieldByName(Trim(gsibgrAnalytical.CheckBox.StrCheck[i])).AsInteger := 1;
      except
      end;

    end;
  end;
end;

procedure TdlgEditAccount.actOkExecute(Sender: TObject);
begin
  if Save then
    ModalResult := mrOk;
end;

procedure TdlgEditAccount.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if ModalResult <> mrOk then
  begin
    if ibdsAccount.State in [dsEdit, dsInsert] then
      ibdsAccount.Cancel;
    if ibdsAccount.Transaction.InTransaction then
      ibdsAccount.Transaction.Rollback;
  end;
end;

procedure TdlgEditAccount.actNextExecute(Sender: TObject);
begin
  if Save then
  begin
    SetupDialog(-1, FID, FParent, FGrade);
    dbedAlias.SetFocus;
  end;
end;

procedure TdlgEditAccount.actCancelExecute(Sender: TObject);
begin
  Close;
end;

procedure TdlgEditAccount.GradeChanged(Sender: TField);
begin
  SetGrade(Sender.AsInteger);
end;

procedure TdlgEditAccount.SetGrade(const aGrade: Integer);
begin
  if aGrade >= 2 then
  begin
    if FID = -1 then
      gsiblcGroupAccount.Condition := Format('GRADE = %d AND ' +
         'LB >= (SELECT LB FROM gd_cardaccount WHERE id = %d) AND ' +
         'RB <= (SELECT RB FROM gd_cardaccount WHERE id = %d)',
         [aGrade - 1, FParent, FParent])
    else
      if aGrade > FGrade then
        gsiblcGroupAccount.Condition := Format('GRADE = %d AND ' +
           'LB >= (SELECT LB FROM gd_cardaccount WHERE id = %d) AND ' +
           'RB <= (SELECT RB FROM gd_cardaccount WHERE id = %d)',
           [aGrade - 1, FParent, FParent])
      else
        gsiblcGroupAccount.Condition := Format('GRADE = %d AND ' +
           'LB < (SELECT LB FROM gd_cardaccount WHERE id = %d) AND ' +
           'RB > (SELECT RB FROM gd_cardaccount WHERE id = %d)',
           [aGrade - 1, FID, FID]);
  end;
end;

end.
