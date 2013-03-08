{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    ctl_dlgPaymentTemplate_unit.pas

  Abstract

    Dialog window.

  Author

    Denis Romanosvki  (01.04.2001)

  Revisions history

    1.0    01.04.2001    Denis    Initial version.


--}

unit ctl_dlgPaymentTemplate_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Mask, xDateEdits, DBCtrls, StdCtrls, gsIBLookupComboBox, ExtCtrls,
  ComCtrls, Db, IBCustomDataSet, at_sql_setup, IBDatabase, IBSQL, ActnList,
  gsDocNumerator, xCalculatorEdit, at_Container;

type
  Tctl_dlgPaymentTemplate = class(TForm)
    pnlButtons: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    PageControl1: TPageControl;
    tsMain: TTabSheet;
    pnlMain: TPanel;
    Bevel3: TBevel;
    Label17: TLabel;
    Label19: TLabel;
    Label4: TLabel;
    Label10: TLabel;
    Label16: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    dbeOper: TEdit;
    dbeQueue: TEdit;
    dbeDest: TgsIBLookupComboBox;
    dbeOperKind: TEdit;
    Label11: TLabel;
    Label14: TLabel;
    gsibluOwnAccount: TgsIBLookupComboBox;
    ibtrPaymentTemplate: TIBTransaction;
    Label2: TLabel;
    cbDate: TComboBox;
    Label3: TLabel;
    cbReceiverAccount: TComboBox;
    Bevel1: TBevel;
    cbGoodDate: TComboBox;
    cbSpecification: TComboBox;
    edPaymentDestination: TMemo;
    cbTerm: TComboBox;
    ibsqlAccount: TIBSQL;
    ActionList1: TActionList;
    actOk: TAction;
    actCancel: TAction;
    btnVariables: TButton;
    Label1: TLabel;
    iblcTransaction: TgsIBLookupComboBox;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actOkExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure btnVariablesClick(Sender: TObject);

  private

  protected
    procedure CheckConsistency;

  public
    function Execute: Boolean;

    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream);

  end;

  Ectl_PaymentTemplateError = class(Exception);

var
  ctl_dlgPaymentTemplate: Tctl_dlgPaymentTemplate;

implementation

{$R *.DFM}

uses
  dmDataBase_unit, gd_security, gsStorage, ctl_CattleConstants_unit,
  ctl_dlgVariablesList_unit, Storages;

const
  PAYMENT_FORMAT_VERSION = 'PAYMENY_FORMAT_VERSION';

procedure Tctl_dlgPaymentTemplate.CheckConsistency;
var
  T: TDestinationArray;
begin
  if cbDate.ItemIndex < 0 then
  begin
    ModalResult := mrNone;
    cbDate.SetFocus;
    raise Ectl_PaymentTemplateError.Create('������� ��������� ����!');
  end else

  if gsibluOwnAccount.CurrentKey = '' then
  begin
    ModalResult := mrNone;
    gsibluOwnAccount.SetFocus;
    raise Ectl_PaymentTemplateError.Create('������� ��������� ������ �� �����!');
  end else

  if cbReceiverAccount.ItemIndex < 0 then
  begin
    ModalResult := mrNone;
    cbReceiverAccount.SetFocus;
    raise Ectl_PaymentTemplateError.Create('������� ��������� ����� ����������!');
  end else

  if
    (edPaymentDestination.Text = '') and
    (MessageBox(Handle,
      '�� ������� ���������� �������. ����������?', '��������!',
      MB_YESNO or MB_ICONQUESTION) = ID_NO)
  then begin
    ModalResult := mrNone;
    edPaymentDestination.SetFocus;
  end;

  // ����������� ������ ������
  ParseDestination(edPaymentDestination.Text, T);
end;

function Tctl_dlgPaymentTemplate.Execute: Boolean;
var
  F: TgsStorageFolder;
  ReadStream: TStream;
  WriteStream: TMemoryStream;
begin

  //
  //  ��������� ���������

  ReadStream := TMemoryStream.Create;
  F := GlobalStorage.OpenFolder(FOLDER_CATTLE_SETTINGS, True, False);
  try
    F.ReadStream(VALUE_PAYMENT_FORMAT, ReadStream);
    LoadFromStream(ReadStream);
  finally
    GlobalStorage.CloseFolder(F, False);
    ReadStream.Free;
  end;

  //
  //  ��������� ���������� ����

  Result := ShowModal = mrOk;

  //
  //  ��������� ���������

  if Result then
  begin
    F := GlobalStorage.OpenFolder(FOLDER_CATTLE_SETTINGS, True, True);
    try
      WriteStream := TMemoryStream.Create;

      try
        SaveToStream(WriteStream);
        F.WriteStream(VALUE_PAYMENT_FORMAT, WriteStream);
      finally
        WriteStream.Free;
      end;
    finally
      GlobalStorage.CloseFolder(F, True);
    end;
  end;
end;

procedure Tctl_dlgPaymentTemplate.FormCreate(Sender: TObject);
begin
  if not ibtrPaymentTemplate.Active then
    ibtrPaymentTemplate.StartTransaction;

  //
  //  ������������� ��������� �� ���������

  // ����
  cbDate.ItemIndex := 0;

  // ������ �� �����
  ibsqlAccount.Close;
  ibsqlAccount.ParamByName('COMPANYKEY').AsInteger := IBLogin.CompanyKey;
  ibsqlAccount.ExecQuery;

  if ibsqlAccount.RecordCount > 0 then
    gsibluOwnAccount.CurrentKey := ibsqlAccount.Fields[0].AsString
  else
    gsibluOwnAccount.CurrentKey := '';

  ibsqlAccount.FreeHandle;

  // ��� ����� ����������
  cbReceiverAccount.ItemIndex := 0;

  // ��� ���������
  dbeOper.Text := '';

  // ��� ��������
  dbeOperKind.Text := '';

  // ���������� �������
  dbeDest.CurrentKey := '';

  // ����������� �������
  dbeQueue.Text := '';

  // ���� �������
  cbTerm.ItemIndex := 0;

  // ���� ������, ������
  cbGoodDate.ItemIndex := 0;

  // ��������� �������
  cbSpecification.Text := '';

  // ���������� �������
  edPaymentDestination.Text := '';
end;

procedure Tctl_dlgPaymentTemplate.FormDestroy(Sender: TObject);
begin
//
end;

procedure Tctl_dlgPaymentTemplate.LoadFromStream(Stream: TStream);
var
  Reader: TReader;
begin
  //  ������ ����� ����������
  if not Assigned(Stream) or (Stream.Size = 0) then Exit;

  Reader := TReader.Create(Stream, 1024);

  try
    // ��������� ������
    Reader.ReadString;

    // ����
    cbDate.ItemIndex := Reader.ReadInteger;

    // ������ �� �����
    gsibluOwnAccount.CurrentKey := Reader.ReadString;

    // ��� ����� ����������
    cbReceiverAccount.ItemIndex := Reader.ReadInteger;

    // ��� ���������
    dbeOper.Text := Reader.ReadString;

    // ��� ��������
    dbeOperKind.Text := Reader.ReadString;

    // ���������� �������
    dbeDest.CurrentKey := Reader.ReadString;

    // ����������� �������
    dbeQueue.Text := Reader.ReadString;

    // ���� �������
    cbTerm.ItemIndex := Reader.ReadInteger;

    // ���� ������, ������
    cbGoodDate.ItemIndex := Reader.ReadInteger;

    // ��������� �������
    cbSpecification.Text := Reader.ReadString;

    // ���������� �������
    edPaymentDestination.Text := Reader.ReadString;
    try
      iblcTransaction.CurrentKey := Reader.ReadString;
    except
    end;  
  finally
    Reader.Free;
  end;
end;

procedure Tctl_dlgPaymentTemplate.SaveToStream(Stream: TStream);
var
  Writer: TWriter;
begin
  Writer := TWriter.Create(Stream, 1024);
  
  try
    // ��������� ������
    Writer.WriteString(PAYMENT_FORMAT_VERSION);

    // ����
    Writer.WriteInteger(cbDate.ItemIndex);

    // ������ �� �����
    Writer.WriteString(gsibluOwnAccount.CurrentKey);

    // ��� ����� ����������
    Writer.WriteInteger(cbReceiverAccount.ItemIndex);

    // ��� ���������
    Writer.WriteString(dbeOper.Text);

    // ��� ��������
    Writer.WriteString(dbeOperKind.Text);

    // ���������� �������
    Writer.WriteString(dbeDest.CurrentKey);

    // ����������� �������
    Writer.WriteString(dbeQueue.Text);

    // ���� �������
    Writer.WriteInteger(cbTerm.ItemIndex);

    // ���� ������, ������
    Writer.WriteInteger(cbGoodDate.ItemIndex);

    // ��������� �������
    Writer.WriteString(cbSpecification.Text);

    // ���������� �������
    Writer.WriteString(edPaymentDestination.Text);

    Writer.WriteString(iblcTransaction.CurrentKey);
  finally
    Writer.Free;
  end;
end;

procedure Tctl_dlgPaymentTemplate.actOkExecute(Sender: TObject);
begin
  CheckConsistency;
end;

procedure Tctl_dlgPaymentTemplate.actCancelExecute(Sender: TObject);
begin
//
end;

procedure Tctl_dlgPaymentTemplate.btnVariablesClick(Sender: TObject);
var
  I: Integer;
begin
  with Tctl_dlgVariablesList.Create(Self) do
  try
    if ShowModal = mrOk then
    begin
      for I := 0 to cblVariables.Items.Count - 1 do
        if
          cblVariables.Checked[I] and
          (AnsiPos('---', cblVariables.Items[I]) = 0)
        then
          edPaymentDestination.Text := edPaymentDestination.Text +
            '[' + cblVariables.Items[I] + ']';
    end;
  finally
    Free;
  end;
end;

end.

