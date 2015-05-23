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
      //  ��������� ������

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
  //  ��������� ������

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
  //  ��������� ��������

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
          (MessageBox(Handle, '������� 200 �������. ����������?', '��������!',
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
          (MessageBox(Handle, '������� 200 �������. ����������?', '��������!',
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
        //  �������� ������ ������� ����������

        ibdsDocument.Insert;

        ibdsDocument.FieldByName('ID').AsInteger := gdcBaseManager.GetNextID;
        ibdsDocument.FieldByName('DOCUMENTTYPEKEY').AsInteger := BN_DOC_PAYMENTORDER;
        ibdsDocument.FieldByName('COMPANYKEY').AsInteger := IBLogin.CompanyKey;
        ibdsDocument.FieldByName('CREATORKEY').AsInteger := IBLogin.ContactKey;
        ibdsDocument.FieldByName('CREATIONDATE').AsDateTime := Now;
        ibdsDocument.FieldByName('EDITORKEY').AsInteger := IBLogin.ContactKey;
        ibdsDocument.FieldByName('EDITIONDATE').AsDateTime := Now;
        
        if ibdsDocument.FieldByName('NUMBER').IsNull then
          ibdsDocument.FieldByName('NUMBER').AsString := '�/�';

        ibdsDocument.FieldByName('AFULL').AsInteger := -1;
        ibdsDocument.FieldByName('ACHAG').AsInteger := -1;
        ibdsDocument.FieldByName('AVIEW').AsInteger := -1;

        if FTemplate.TransactionKey > '' then
          ibdsDocument.FieldByName('trtypekey').AsString := FTemplate.TransactionKey;

        //
        //  ��������� ��������� ���������

        ibdsPayment.Insert;

        ibdsPayment.FieldByName('DOCUMENTKEY').AsInteger :=
          ibdsDocument.FieldByName('ID').AsInteger;

        AssignCurrentPayment;

        //
        //  ��������� ������ � �������
        //  ��������� ����������

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
  //  ����������� ���������

  ibsqlCompany.Close;
  ibsqlCompany.ParamByName('CONTACTKEY').AsInteger := IBLogin.CompanyKey;
  ibsqlCompany.ExecQuery;

  // ��������� ����
  ibdsPayment.FieldByName('ACCOUNTKEY').AsString := FTemplate.Account;

  // ������������ ��������
  ibdsPayment.FieldByName('OWNCOMPTEXT').AsString :=
    ibsqlCompany.FieldByName('FULLNAME').AsString;

  // ���
  ibdsPayment.FieldByName('OWNTAXID').AsString :=
    ibsqlCompany.FieldByName('TAXID').AsString;

  // ������
  ibdsPayment.FieldByName('OWNCOUNTRY').AsString :=
    ibsqlCompany.FieldByName('COUNTRY').AsString;

  // ������������ �����
  ibdsPayment.FieldByName('OWNACCOUNT').AsString :=
    ibsqlCompany.FieldByName('ACCOUNT').AsString;

  ibsqlCompany.Close;


  ibsqlBank.Close;
  ibsqlBank.ParamByName('ACCOUNTKEY').AsString := FTemplate.Account;
  ibsqlBank.ExecQuery;

  // ������������ �����
  ibdsPayment.FieldByName('OWNBANKTEXT').AsString :=
    ibsqlBank.FieldByName('FULLNAME').AsString;

  // ����� �����
  ibdsPayment.FieldByName('OWNBANKCITY').AsString :=
    ibsqlBank.FieldByName('CITY').AsString;

  // ��� �����
  ibdsPayment.FieldByName('OWNACCOUNTCODE').AsString :=
    ibsqlBank.FieldByName('BANKCODE').AsString;

  //
  //  ��������� ����������������� ��������

  ibsqlCompany.Close;
  ibsqlCompany.ParamByName('CONTACTKEY').AsInteger :=
    ibdsReceipt.FieldByName('SUPPLIERKEY').AsInteger;
  ibsqlCompany.ExecQuery;

  // ����. ��������
  ibdsPayment.FieldByName('CORRCOMPANYKEY').AsInteger :=
    ibdsReceipt.FieldByName('SUPPLIERKEY').AsInteger;

  {
    TODO 1 -o����� -c������� :
    ����� ����� ������� ����� ����. ����� �� ���� �����
    FTemplate.ReceiverAccountType
  }

  // ���� ���� ��������
  ibdsPayment.FieldByName('CORRACCOUNTKEY').AsInteger :=
    ibsqlCompany.FieldByName('COMPANYACCOUNTKEY').AsInteger;

  // ������������ ����. ��������
  ibdsPayment.FieldByName('CORRCOMPTEXT').AsString :=
    ibsqlCompany.FieldByName('FULLNAME').AsString;

  // ��� ����. ��������
  ibdsPayment.FieldByName('CORRTAXID').AsInteger :=
    ibsqlCompany.FieldByName('TAXID').AsInteger;

  // ������ ����. ��������
  ibdsPayment.FieldByName('CORRCOUNTRY').AsString :=
    ibsqlCompany.FieldByName('COUNTRY').AsString;

  // ���� ����. ��������
  ibdsPayment.FieldByName('CORRACCOUNT').AsString :=
    ibsqlCompany.FieldByName('ACCOUNT').AsString;

  ibsqlCompany.Close;

  ibsqlBank.Close;
  ibsqlBank.ParamByName('ACCOUNTKEY').AsInteger :=
    ibsqlCompany.FieldByName('COMPANYACCOUNTKEY').AsInteger;
  ibsqlBank.ExecQuery;

  // ������������ ����� ����. ��������
  ibdsPayment.FieldByName('CORRBANKTEXT').AsString :=
    ibsqlBank.FieldByName('FULLNAME').AsString;

  // ����� ����� ����. ��������
  ibdsPayment.FieldByName('CORRBANKCITY').AsString :=
    ibsqlBank.FieldByName('CITY').AsString;

  // ��� ����� ����. ��������
  ibdsPayment.FieldByName('CORRACCOUNTCODE').AsString :=
    ibsqlBank.FieldByName('BANKCODE').AsString;

  ibsqlBank.Close;

  // ���� �������
  case FTemplate.PaymentDate of
    0: // ������� ����
      ibdsDocument.FieldByName('DOCUMENTDATE').AsDateTime := Now;
    1: // ���� �� ���������
      ibdsDocument.FieldByName('DOCUMENTDATE').AsDateTime :=
        ibdsReceipt.FieldByName('DOCUMENTDATE').AsDateTime;
    2: // ���� �� ���������
      ibdsDocument.FieldByName('DOCUMENTDATE').AsDateTime :=
        ibdsReceipt.FieldByName('INVOICEDATE').AsDateTime;
  end;

  // ��� ���������
  ibdsPayment.FieldByName('PROC').AsString := FTemplate.Oper;

  // ��� ��������
  ibdsPayment.FieldByName('OPER').AsString := FTemplate.OperKind;

  // ���������� �������
  ibsqlDestName.Close;
  ibsqlDestName.ParamByName('ID').AsString := FTemplate.Dest;
  ibsqlDestName.ExecQuery;

  ibdsPayment.FieldByName('DESTCODEKEY').AsString := FTemplate.Dest;
  ibdsPayment.FieldByName('DESTCODE').AsString :=
    ibsqlDestName.FieldByName('CODE').AsString;

  ibsqlDestName.Close;

  // ����������� �������
  ibdsPayment.FieldByName('QUEUE').AsString := FTemplate.Queue;

  // ���� �������
  case FTemplate.Term of
    0: // ������� ����
      ibdsPayment.FieldByName('TERM').AsDateTime := Now;
    1: // ���� �� ���������
      ibdsPayment.FieldByName('TERM').AsDateTime :=
        ibdsReceipt.FieldByName('DOCUMENTDATE').AsDateTime;
    2: // ���� �� ���������
      ibdsPayment.FieldByName('TERM').AsDateTime :=
        ibdsReceipt.FieldByName('INVOICEDATE').AsDateTime;
  end;

  // ���� ������, ������
  case FTemplate.GoodDate of
    0: // ������� ����
      ibdsPayment.FieldByName('ENTERDATE').AsDateTime := Now;
    1: // ���� �� ���������
      ibdsPayment.FieldByName('ENTERDATE').AsDateTime :=
        ibdsReceipt.FieldByName('DOCUMENTDATE').AsDateTime;
    2: // ���� �� ���������
      ibdsPayment.FieldByName('ENTERDATE').AsDateTime :=
        ibdsReceipt.FieldByName('INVOICEDATE').AsDateTime;
  end;

  // ��������� �������
  ibdsPayment.FieldByName('SPECIFICATION').AsString := FTemplate.Specification;

  // ����� �� ��������
  ibdsPayment.FieldByName('AMOUNT').AsCurrency :=
    ibdsReceipt.FieldByName('SUMNCU').AsCurrency;

  // ����� �� �������� � ���������
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

  // ���������� �������
  ibdsPayment.FieldByName('DESTINATION').AsString := V;
end;

function Tctl_dlgMakePayments.FindFieldValue(const FieldName: String): String;
begin
  if AnsiCompareText(FieldName, '�������_����') = 0 then
    Result := DateToStr(Now) else
  if AnsiCompareText(FieldName, '����_��_��������') = 0 then
    Result := ibdsReceipt.FieldByName('DOCUMENTDATE').AsString else
  if AnsiCompareText(FieldName, '����_��_���������') = 0 then
    Result := ibdsReceipt.FieldByName('INVOICEDATE').AsString else
  if AnsiCompareText(FieldName, '�_��_���������') = 0 then
    Result := ibdsReceipt.FieldByName('NUMBER').AsString else
  if AnsiCompareText(FieldName, '�_��_���������') = 0 then
    Result := ibdsReceipt.FieldByName('INVOICENUMBER').AsString else
  if AnsiCompareText(FieldName, '�_��_���') = 0 then
    Result := ibdsReceipt.FieldByName('TTNNUMBER').AsString else
  if AnsiCompareText(FieldName, '���������') = 0 then
    Result := ibdsReceipt.FieldByName('SUPPLIER').AsString
  else
    Result := '';
end;

end.
