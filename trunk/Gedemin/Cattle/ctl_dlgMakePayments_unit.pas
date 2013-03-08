{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    ctl_dlgMakePayments_unit.pas

  Abstract

    Dialog window.

  Author

    Denis Romanosvki  (01.04.2001)

  Revisions history

    1.0    01.04.2001    Denis    Initial version.


--}

unit ctl_dlgMakePayments_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IBDatabase, Db, IBCustomDataSet, Grids, DBGrids, gsDBGrid, gsIBGrid,
  ActnList, StdCtrls, Menus, flt_sqlFilter, ctl_CattleConstants_unit, IBSQL,
  gsDocNumerator;

type
  Tctl_dlgMakePayments = class(TForm)
    btnCancel: TButton;
    btnCreate: TButton;
    alPayments: TActionList;
    actOk: TAction;
    actCancel: TAction;
    ibgrdReceipts: TgsIBGrid;
    btnSetup: TButton;
    btnFilter: TButton;
    actSetup: TAction;
    actFilter: TAction;
    ibdsReceipt: TIBDataSet;
    dsReceipts: TDataSource;
    ibtrPayments: TIBTransaction;
    qfPayments: TgsQueryFilter;
    pmPayments: TPopupMenu;
    pmReceipts: TPopupMenu;
    actChooseAll: TAction;
    actInverse: TAction;
    N1: TMenuItem;
    N2: TMenuItem;
    ibdsPayment: TIBDataSet;
    ibdsDocumentLink: TIBDataSet;
    ibdsDocument: TIBDataSet;
    ibsqlCompany: TIBSQL;
    ibsqlBank: TIBSQL;
    ibsqlDestName: TIBSQL;
    dnPayment: TgsDocNumerator;
    dsDocument: TDataSource;

    procedure actOkExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure actSetupExecute(Sender: TObject);
    procedure actFilterExecute(Sender: TObject);

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

    procedure actChooseAllExecute(Sender: TObject);
    procedure actInverseExecute(Sender: TObject);

  private
    FTemplate: TReceiptPaymentTemplate;
    FNewPayments: TStringList;
    FDestinationArray: TDestinationArray;

    function FindFieldValue(const FieldName: String): String;

    procedure CreatePayments;

    procedure AssignCurrentPayment;

  public
    function Execute: Boolean;

  end;

  Ectl_dlgMakePayments = class(Exception);

var
  ctl_dlgMakePayments: Tctl_dlgMakePayments;

implementation

uses
  dmDataBase_unit, gd_security_OperationConst, ctl_dlgPaymentTemplate_unit,
  gd_security, gsStorage, gdc_frmPaymentOrder_unit{, ctl_frmReceiptPayments_unit},
  Storages, gdcBaseInterface;

{$R *.DFM}

procedure Tctl_dlgMakePayments.actOkExecute(Sender: TObject);
begin
  CreatePayments;
  with Tgdc_frmPaymentOrder.Create(Self) do
  try
    gdcPaymentOrder.ExtraConditions.Text := ' ID in (' + Self.FNewPayments.CommaText + ')';
    //gdcPaymentOrder.FindWhereSQL := ' ID in (' + Self.FNewPayments.CommaText + ')';
  finally
    Free;
  end;
{  with Tctl_frmReceiptPayments.Create(Self) do
  try
    NewPayments.Assign(Self.FNewPayments);
    ShowPayment(-1);
    ShowModal;
  finally
    Free;
  end;}
end;

procedure Tctl_dlgMakePayments.actCancelExecute(Sender: TObject);
begin
//
end;

procedure Tctl_dlgMakePayments.actSetupExecute(Sender: TObject);
var
  F: TgsStorageFolder;
  ReadStream: TStream;
begin
  with Tctl_dlgPaymentTemplate.Create(Self) do
  try
    if Execute then
    begin
      //
      //  Загружаем шаблон

      ReadStream := TMemoryStream.Create;
      try
        F := GlobalStorage.OpenFolder(FOLDER_CATTLE_SETTINGS, True, False);
        try

          F.ReadStream(VALUE_PAYMENT_FORMAT, ReadStream);
        finally
          GlobalStorage.CloseFolder(F);
        end;

        if Assigned(ReadStream) then
        begin
          LoadTemplate(ReadStream, FTemplate);
          ParseDestination(FTemplate.Destination, FDestinationArray);
        end;
      finally
        ReadStream.Free;
      end;
    end;
  finally
    Free;
  end;
end;

procedure Tctl_dlgMakePayments.actFilterExecute(Sender: TObject);
var
  P: TPoint;
begin
  P := btnFilter.ClientToScreen(Point(0, btnFilter.Height));
  pmPayments.Popup(P.X, P.Y);
end;

procedure Tctl_dlgMakePayments.FormCreate(Sender: TObject);
var
  F: TgsStorageFolder;
  ReadStream: TStream;
begin
  FNewPayments := TStringList.Create;
  SetLength(FDestinationArray, 0);

  if Assigned(UserStorage) then
    UserStorage.LoadComponent(ibgrdReceipts, ibgrdReceipts.LoadFromStream);

  //
  //  Загружаем шаблон

  ReadStream := TMemoryStream.Create;
  try
    F := GlobalStorage.OpenFolder(FOLDER_CATTLE_SETTINGS, True, False);
    try
      F.ReadStream(VALUE_PAYMENT_FORMAT, ReadStream);
    finally
      GlobalStorage.CloseFolder(F);
    end;

    if Assigned(ReadStream) then
    begin
      LoadTemplate(ReadStream, FTemplate);
      ParseDestination(FTemplate.Destination, FDestinationArray);
    end;
  finally
    ReadStream.Free;
  end;
  //
  //  Загружаем датасеты

  if not ibtrPayments.Active then
    ibtrPayments.StartTransaction;

  ibdsReceipt.Open;
end;

procedure Tctl_dlgMakePayments.FormDestroy(Sender: TObject);
begin
  if Assigned(UserStorage) then
    UserStorage.SaveComponent(ibgrdReceipts, ibgrdReceipts.SaveToStream);
  FNewPayments.Free;
  SetLength(FDestinationArray, 0);
end;

function Tctl_dlgMakePayments.Execute: Boolean;
begin
  Result := ShowModal = mrOk;
end;

procedure Tctl_dlgMakePayments.actChooseAllExecute(Sender: TObject);
begin
  ibgrdReceipts.CheckBox.BeginUpdate;
  ibdsReceipt.DisableControls;

  try
    ibgrdReceipts.CheckBox.Clear;

    ibdsReceipt.First;

    while not ibdsReceipt.EOF do
    begin
      ibgrdReceipts.CheckBox.AddCheck(
        ibdsReceipt.FieldByName(ibgrdReceipts.CheckBox.FieldName).AsString);

      if (ibgrdReceipts.CheckBox.CheckCount > 0) and
        (ibgrdReceipts.CheckBox.CheckCount mod 200 = 0) then
      begin
        if
          (MessageBox(Handle, 'Выбрано 200 записей. Продолжить?', 'Внимание!',
            MB_ICONQUESTION or MB_YESNO) = ID_NO)
        then
          Break;
      end;

      ibdsReceipt.Next;
    end;

  finally
    ibdsReceipt.EnableControls;
    ibgrdReceipts.CheckBox.EndUpdate;
  end;
end;

procedure Tctl_dlgMakePayments.actInverseExecute(Sender: TObject);
var
  List: TStringList;
begin
  List := TStringList.Create;

  ibgrdReceipts.CheckBox.BeginUpdate;
  ibdsReceipt.DisableControls;

  try
    List.Text := ibgrdReceipts.CheckBox.CheckList.Text;
    ibgrdReceipts.CheckBox.Clear;

    ibdsReceipt.First;

    while not ibdsReceipt.EOF do
    begin
      if List.IndexOf(ibdsReceipt.FieldByName(
        ibgrdReceipts.CheckBox.FieldName).AsString) = -1
      then
        ibgrdReceipts.CheckBox.AddCheck(
          ibdsReceipt.FieldByName(ibgrdReceipts.CheckBox.FieldName).AsString);

      if (ibgrdReceipts.CheckBox.CheckCount > 0) and
        (ibgrdReceipts.CheckBox.CheckCount mod 200 = 0) then
      begin
        if
          (MessageBox(Handle, 'Выбрано 200 записей. Продолжить?', 'Внимание!',
            MB_ICONQUESTION or MB_YESNO) = ID_NO)
        then
          Break;
      end;

      ibdsReceipt.Next;
    end;
  finally
    List.Free;
    ibdsReceipt.EnableControls;
    ibgrdReceipts.CheckBox.EndUpdate;
  end;
end;

procedure Tctl_dlgMakePayments.CreatePayments;
begin
  ibdsReceipt.DisableControls;

  ibdsDocument.CachedUpdates := True;
  ibdsDocument.Open;

  ibdsPayment.CachedUpdates := True;
  ibdsPayment.Open;

  ibdsDocumentLink.CachedUpdates := True;
  ibdsDocumentLink.Open;

  try
    ibdsReceipt.First;

    while not ibdsReceipt.EOF do
    begin
      if ibgrdReceipts.CheckBox.CheckList.IndexOf(
        ibdsReceipt.FieldByName('DOCUMENTKEY').AsString) <> -1 then
      begin
        //
        //  Добаляем запись таблицу документов

        ibdsDocument.Insert;

        ibdsDocument.FieldByName('ID').AsInteger := gdcBaseManager.GetNextID;
        ibdsDocument.FieldByName('DOCUMENTTYPEKEY').AsInteger := BN_DOC_PAYMENTORDER;
        ibdsDocument.FieldByName('COMPANYKEY').AsInteger := IBLogin.CompanyKey;
        ibdsDocument.FieldByName('CREATORKEY').AsInteger := IBLogin.ContactKey;
        ibdsDocument.FieldByName('CREATIONDATE').AsDateTime := Now;
        ibdsDocument.FieldByName('EDITORKEY').AsInteger := IBLogin.ContactKey;
        ibdsDocument.FieldByName('EDITIONDATE').AsDateTime := Now;
        
        if ibdsDocument.FieldByName('NUMBER').IsNull then
          ibdsDocument.FieldByName('NUMBER').AsString := 'б/н';

        ibdsDocument.FieldByName('AFULL').AsInteger := -1;
        ibdsDocument.FieldByName('ACHAG').AsInteger := -1;
        ibdsDocument.FieldByName('AVIEW').AsInteger := -1;

        if FTemplate.TransactionKey > '' then
          ibdsDocument.FieldByName('trtypekey').AsString := FTemplate.TransactionKey;

        //
        //  Добавляем платежное поручение

        ibdsPayment.Insert;

        ibdsPayment.FieldByName('DOCUMENTKEY').AsInteger :=
          ibdsDocument.FieldByName('ID').AsInteger;

        AssignCurrentPayment;

        //
        //  Добавляем запись в таблицу
        //  связанных документов

        ibdsDocumentLink.Insert;

        ibdsDocumentLink.FieldByName('SOURCEDOCKEY').AsInteger :=
          ibdsReceipt.FieldByName('ID').AsInteger;

        ibdsDocumentLink.FieldByName('DESTDOCKEY').AsInteger :=
          ibdsPayment.FieldByName('DOCUMENTKEY').AsInteger;


        ibdsDocument.Post;
        ibdsPayment.Post;
        ibdsDocumentLink.Post;

        FNewPayments.Add(ibdsDocument.FieldByName('ID').AsString);
      end;

      ibdsReceipt.Next;
    end;

    dmDatabase.ibdbGAdmin.ApplyUpdates([ibdsDocument, ibdsPayment, ibdsDocumentLink]);

    ibtrPayments.Commit;
  finally
    ibdsReceipt.EnableControls;
  end;
end;

procedure Tctl_dlgMakePayments.AssignCurrentPayment;
var
  I: Integer;
  V: String;
begin
  //
  //  Собственные реквизиты

  ibsqlCompany.Close;
  ibsqlCompany.ParamByName('CONTACTKEY').AsInteger := IBLogin.CompanyKey;
  ibsqlCompany.ExecQuery;

  // расчетный счет
  ibdsPayment.FieldByName('ACCOUNTKEY').AsString := FTemplate.Account;

  // наименование компании
  ibdsPayment.FieldByName('OWNCOMPTEXT').AsString :=
    ibsqlCompany.FieldByName('FULLNAME').AsString;

  // УНН
  ibdsPayment.FieldByName('OWNTAXID').AsString :=
    ibsqlCompany.FieldByName('TAXID').AsString;

  // Страна
  ibdsPayment.FieldByName('OWNCOUNTRY').AsString :=
    ibsqlCompany.FieldByName('COUNTRY').AsString;

  // наименвоание счета
  ibdsPayment.FieldByName('OWNACCOUNT').AsString :=
    ibsqlCompany.FieldByName('ACCOUNT').AsString;

  ibsqlCompany.Close;


  ibsqlBank.Close;
  ibsqlBank.ParamByName('ACCOUNTKEY').AsString := FTemplate.Account;
  ibsqlBank.ExecQuery;

  // наименвоание банка
  ibdsPayment.FieldByName('OWNBANKTEXT').AsString :=
    ibsqlBank.FieldByName('FULLNAME').AsString;

  // город банка
  ibdsPayment.FieldByName('OWNBANKCITY').AsString :=
    ibsqlBank.FieldByName('CITY').AsString;

  // Код банка
  ibdsPayment.FieldByName('OWNACCOUNTCODE').AsString :=
    ibsqlBank.FieldByName('BANKCODE').AsString;

  //
  //  Реквизиты корреспондирующей компании

  ibsqlCompany.Close;
  ibsqlCompany.ParamByName('CONTACTKEY').AsInteger :=
    ibdsReceipt.FieldByName('SUPPLIERKEY').AsInteger;
  ibsqlCompany.ExecQuery;

  // корр. компания
  ibdsPayment.FieldByName('CORRCOMPANYKEY').AsInteger :=
    ibdsReceipt.FieldByName('SUPPLIERKEY').AsInteger;

  {
    TODO 1 -oденис -cсделать :
    Нужно будет сделать выбор корр. счета по типу счета
    FTemplate.ReceiverAccountType
  }

  // счет корр компании
  ibdsPayment.FieldByName('CORRACCOUNTKEY').AsInteger :=
    ibsqlCompany.FieldByName('COMPANYACCOUNTKEY').AsInteger;

  // наименование корр. компании
  ibdsPayment.FieldByName('CORRCOMPTEXT').AsString :=
    ibsqlCompany.FieldByName('FULLNAME').AsString;

  // УНН корр. компании
  ibdsPayment.FieldByName('CORRTAXID').AsInteger :=
    ibsqlCompany.FieldByName('TAXID').AsInteger;

  // страна корр. компании
  ibdsPayment.FieldByName('CORRCOUNTRY').AsString :=
    ibsqlCompany.FieldByName('COUNTRY').AsString;

  // счет корр. компании
  ibdsPayment.FieldByName('CORRACCOUNT').AsString :=
    ibsqlCompany.FieldByName('ACCOUNT').AsString;

  ibsqlCompany.Close;

  ibsqlBank.Close;
  ibsqlBank.ParamByName('ACCOUNTKEY').AsInteger :=
    ibsqlCompany.FieldByName('COMPANYACCOUNTKEY').AsInteger;
  ibsqlBank.ExecQuery;

  // наименование банка корр. компании
  ibdsPayment.FieldByName('CORRBANKTEXT').AsString :=
    ibsqlBank.FieldByName('FULLNAME').AsString;

  // город банка корр. компании
  ibdsPayment.FieldByName('CORRBANKCITY').AsString :=
    ibsqlBank.FieldByName('CITY').AsString;

  // код банка корр. компании
  ibdsPayment.FieldByName('CORRACCOUNTCODE').AsString :=
    ibsqlBank.FieldByName('BANKCODE').AsString;

  ibsqlBank.Close;

  // Дата платежа
  case FTemplate.PaymentDate of
    0: // текущая дата
      ibdsDocument.FieldByName('DOCUMENTDATE').AsDateTime := Now;
    1: // дата из квитанции
      ibdsDocument.FieldByName('DOCUMENTDATE').AsDateTime :=
        ibdsReceipt.FieldByName('DOCUMENTDATE').AsDateTime;
    2: // дата из накладной
      ibdsDocument.FieldByName('DOCUMENTDATE').AsDateTime :=
        ibdsReceipt.FieldByName('INVOICEDATE').AsDateTime;
  end;

  // Вид обработки
  ibdsPayment.FieldByName('PROC').AsString := FTemplate.Oper;

  // Вид операции
  ibdsPayment.FieldByName('OPER').AsString := FTemplate.OperKind;

  // Назначение платежа
  ibsqlDestName.Close;
  ibsqlDestName.ParamByName('ID').AsString := FTemplate.Dest;
  ibsqlDestName.ExecQuery;

  ibdsPayment.FieldByName('DESTCODEKEY').AsString := FTemplate.Dest;
  ibdsPayment.FieldByName('DESTCODE').AsString :=
    ibsqlDestName.FieldByName('CODE').AsString;

  ibsqlDestName.Close;

  // Очередность платежа
  ibdsPayment.FieldByName('QUEUE').AsString := FTemplate.Queue;

  // Срок платежа
  case FTemplate.Term of
    0: // текущая дата
      ibdsPayment.FieldByName('TERM').AsDateTime := Now;
    1: // дата из квитанции
      ibdsPayment.FieldByName('TERM').AsDateTime :=
        ibdsReceipt.FieldByName('DOCUMENTDATE').AsDateTime;
    2: // дата из накладной
      ibdsPayment.FieldByName('TERM').AsDateTime :=
        ibdsReceipt.FieldByName('INVOICEDATE').AsDateTime;
  end;

  // Дата товара, услуги
  case FTemplate.GoodDate of
    0: // текущая дата
      ibdsPayment.FieldByName('ENTERDATE').AsDateTime := Now;
    1: // дата из квитанции
      ibdsPayment.FieldByName('ENTERDATE').AsDateTime :=
        ibdsReceipt.FieldByName('DOCUMENTDATE').AsDateTime;
    2: // дата из накладной
      ibdsPayment.FieldByName('ENTERDATE').AsDateTime :=
        ibdsReceipt.FieldByName('INVOICEDATE').AsDateTime;
  end;

  // Уточнение платежа
  ibdsPayment.FieldByName('SPECIFICATION').AsString := FTemplate.Specification;

  // Сумма по платежке
  ibdsPayment.FieldByName('AMOUNT').AsCurrency :=
    ibdsReceipt.FieldByName('SUMNCU').AsCurrency;

  // Сумма по платежке в документе
  ibdsDocument.FieldByName('SUMNCU').AsCurrency :=
    ibdsReceipt.FieldByName('SUMNCU').AsCurrency;

  V := '';

  for I := 0 to Length(FDestinationArray) - 1 do
  begin
    case FDestinationArray[I].Kind of
    tkText:
      V := V + FDestinationArray[I].Text;
    tkField:
      V := V + FindFieldValue(FDestinationArray[I].Text);
    end;
  end;

  // Назначение платежа
  ibdsPayment.FieldByName('DESTINATION').AsString := V;
end;

function Tctl_dlgMakePayments.FindFieldValue(const FieldName: String): String;
begin
  if AnsiCompareText(FieldName, 'Текущая_дата') = 0 then
    Result := DateToStr(Now) else
  if AnsiCompareText(FieldName, 'Дата_из_квитании') = 0 then
    Result := ibdsReceipt.FieldByName('DOCUMENTDATE').AsString else
  if AnsiCompareText(FieldName, 'Дата_из_накладной') = 0 then
    Result := ibdsReceipt.FieldByName('INVOICEDATE').AsString else
  if AnsiCompareText(FieldName, '№_из_квитанции') = 0 then
    Result := ibdsReceipt.FieldByName('NUMBER').AsString else
  if AnsiCompareText(FieldName, '№_из_накладной') = 0 then
    Result := ibdsReceipt.FieldByName('INVOICENUMBER').AsString else
  if AnsiCompareText(FieldName, '№_из_ТТН') = 0 then
    Result := ibdsReceipt.FieldByName('TTNNUMBER').AsString else
  if AnsiCompareText(FieldName, 'Поставщик') = 0 then
    Result := ibdsReceipt.FieldByName('SUPPLIER').AsString
  else
    Result := '';
end;

end.
