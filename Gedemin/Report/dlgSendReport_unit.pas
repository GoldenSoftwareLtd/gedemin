unit dlgSendReport_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, IBDatabase, dmDataBase_unit, StdCtrls, gsIBLookupComboBox, gdcBaseInterface,
  ActnList, frxClass, frxPreview, frxDsgnIntf, gd_WebClientControl_unit,
  gd_messages_const, gd_createable_form, ExtCtrls;

type
  TdlgSendReport = class(TCreateableForm)
    iblkupSMTP: TgsIBLookupComboBox;
    Label1: TLabel;
    edRecipients: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    edSubject: TEdit;
    Label5: TLabel;
    mBodyText: TMemo;
    btnSend: TButton;
    Label6: TLabel;
    alBase: TActionList;
    actSend: TAction;
    btnAdd: TButton;
    actAddContact: TAction;
    rbDoc: TRadioButton;
    rbPDF: TRadioButton;
    rbXLS: TRadioButton;
    rbXML: TRadioButton;
    pnlState: TPanel;
    btnClose: TButton;
    rbTXT: TRadioButton;
    rbHTM: TRadioButton;
    rbODT: TRadioButton;
    rbODS: TRadioButton;
    procedure actSendExecute(Sender: TObject);
    procedure actSendUpdate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actAddContactExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private
    FPDFExport: TfrxCustomExportFilter;
    FRTFExport: TfrxCustomExportFilter;
    FXLSExport: TfrxCustomExportFilter;
    FXMLExport: TfrxCustomExportFilter;
    FTXTExport: TfrxCustomExportFilter;
    FHTMLExport: TfrxCustomExportFilter;
    FODTExport: TfrxCustomExportFilter;
    FODSExport: TfrxCustomExportFilter;

    FPreview: TfrxPreview;
    FEmailID: Word;

    procedure OnWebClientThreadNotify(var Msg : TMessage); message WM_GD_FINISH_SEND_EMAIL;

  public
    procedure Init(const ACaption: String; AfrxPreview: TfrxPreview;
      AfrxExportFilters: TfrxExportFilterCollection);
  end;

implementation

{$R *.DFM}

uses
  gdcContacts;

procedure TdlgSendReport.OnWebClientThreadNotify(var Msg : TMessage);
var
  ES: TgdEmailMessageState;
  ErrorMsg: String;
begin
  if (gdWebClientControl <> nil) and gdWebClientControl.GetEmailState(Msg.WParam, ES, ErrorMsg) then
  begin
    if ES = emsSent then
      pnlState.Caption := '��������� ����������'
    else if ErrorMsg > '' then
      pnlState.Caption := ErrorMsg
    else
      pnlState.Caption := '������ ��� �������� ���������';
    FEmailID := 0;  
  end;
end;

procedure TdlgSendReport.Init(const ACaption: String; AfrxPreview: TfrxPreview;
  AfrxExportFilters: TfrxExportFilterCollection);
var
  I: Integer;
begin
  FPreview := AfrxPreview;

  FPDFExport := nil;
  FRTFExport := nil;
  FXLSExport := nil;
  FXMLExport := nil;
  FTXTExport := nil;
  FHTMLExport := nil;
  FODTExport := nil;
  FODSExport := nil;

  for I := 0 to AfrxExportFilters.Count - 1 do
  begin
    if TfrxCustomExportFilter(frxExportFilters[i].Filter).ClassName = 'TfrxPDFExport' then
      FPDFExport := TfrxCustomExportFilter(frxExportFilters[i].Filter)
    else if TfrxCustomExportFilter(frxExportFilters[i].Filter).ClassName = 'TfrxRTFExport' then
      FRTFExport := TfrxCustomExportFilter(frxExportFilters[i].Filter)
    else if TfrxCustomExportFilter(frxExportFilters[i].Filter).ClassName = 'TfrxXLSExport' then
      FXLSExport := TfrxCustomExportFilter(frxExportFilters[i].Filter)
    else if TfrxCustomExportFilter(frxExportFilters[i].Filter).ClassName = 'TfrxXMLExport' then
      FXMLExport := TfrxCustomExportFilter(frxExportFilters[i].Filter)
    else if TfrxCustomExportFilter(frxExportFilters[i].Filter).ClassName = 'TfrxTXTExport' then
      FTXTExport := TfrxCustomExportFilter(frxExportFilters[i].Filter)
    else if TfrxCustomExportFilter(frxExportFilters[i].Filter).ClassName = 'TfrxHTMLExport' then
      FHTMLExport := TfrxCustomExportFilter(frxExportFilters[i].Filter)
    else if TfrxCustomExportFilter(frxExportFilters[i].Filter).ClassName = 'TfrxODTExport' then
      FODTExport := TfrxCustomExportFilter(frxExportFilters[i].Filter)
    else if TfrxCustomExportFilter(frxExportFilters[i].Filter).ClassName = 'TfrxODSExport' then
      FODSExport := TfrxCustomExportFilter(frxExportFilters[i].Filter);
  end;

  rbPDF.Enabled := FPDFExport <> nil;
  rbDoc.Enabled := FRTFExport <> nil;
  rbXLS.Enabled := FXLSExport <> nil;
  rbXML.Enabled := FXMLExport <> nil;
  rbTXT.Enabled := FTXTExport <> nil;
  rbHTM.Enabled := FHTMLExport <> nil;
  rbODT.Enabled := FODTExport <> nil;
  rbODS.Enabled := FODSExport <> nil;

  edSubject.Text := ACaption;
end;

procedure TdlgSendReport.actSendExecute(Sender: TObject);
var
  CurrExport: TfrxCustomExportFilter;
  FN, FExt: String;
  TempFileName: String;
  TempShowDialog: Boolean;
begin
  if rbPDF.Checked then
  begin
    CurrExport := FPDFExport;
    FExt := 'PDF';
  end
  else if rbDOC.Checked then
  begin
    CurrExport := FRTFExport;
    FExt := 'RTF';
  end
  else if rbXLS.Checked then
  begin
    CurrExport := FXLSExport;
    FExt := 'XLS';
  end
  else if rbXML.Checked then
  begin
    CurrExport := FXMLExport;
    FExt := 'XML';
  end
  else if rbTXT.Checked then
  begin
    CurrExport := FTXTExport;
    FExt := 'TXT';
  end
  else if rbHTM.Checked then
  begin
    CurrExport := FHTMLExport;
    FExt := 'HTM';
  end
  else if rbODT.Checked then
  begin
    CurrExport := FODTExport;
    FExt := 'ODT';
  end
  else if rbODS.Checked then
  begin
    CurrExport := FODSExport;
    FExt := 'ODS';
  end else
    CurrExport := nil;

  if CurrExport = nil then
    raise Exception.Create('����������� ��������� ������ � ��������� ������');

  FN := GetEmailTempFileName(FExt);

  TempFileName := CurrExport.FileName;
  TempShowDialog := CurrExport.ShowDialog;
  try
    CurrExport.FileName := FN;
    CurrExport.ShowDialog := False;
    try
      FPreview.Export(CurrExport);

      if not FileExists(FN) then
        raise Exception.Create('������ ��� ����������� ������. ���� �� ������.');
    except
      DeleteFile(FN);
      RemoveDir(ExtractFileDir(FN));
      raise;
    end;

    pnlState.Caption := '���� �������� ���������...';
    FEmailID := gdWebClientControl.SendEmail(iblkupSMTP.CurrentKeyInt, edRecipients.Text, edSubject.Text,
      mBodyText.Text, FN, True, True, False, Self.Handle);
  finally
    CurrExport.FileName := TempFileName;
    CurrExport.ShowDialog := TempShowDialog;
  end;
end;

procedure TdlgSendReport.actSendUpdate(Sender: TObject);
begin
  actSend.Enabled := (gdWebClientControl <> nil) and (edRecipients.Text > '')
    and (FEmailID = 0);
end;

procedure TdlgSendReport.FormDestroy(Sender: TObject);
begin
  if gdWebClientControl <> nil then
    gdWebClientControl.ClearEmailCallbackHandle(Handle, 0);
end;

procedure TdlgSendReport.actAddContactExecute(Sender: TObject);
var
  R: OleVariant;
begin
  if gdcBaseManager.ExecSingleQueryResult(
    'SELECT '#13#10 +
    '  LIST(email, '','') '#13#10 +
    'FROM '#13#10 +
    '  ( '#13#10 +
    '    SELECT '#13#10 +
    '      c.email '#13#10 +
    '    FROM '#13#10 +
    '      gd_contact c '#13#10 +
    '    WHERE '#13#10 +
    '      c.id = :id '#13#10 +
    '      AND '#13#10 +
    '      c.email > '''' '#13#10 +
    '       '#13#10 +
    '    UNION '#13#10 +
    ' '#13#10 +
    '    SELECT '#13#10 +
    '      c.email '#13#10 +
    '    FROM '#13#10 +
    '      gd_contact c '#13#10 +
    '      JOIN gd_contactlist l ON l.contactkey = c.id '#13#10 +
    '    WHERE '#13#10 +
    '      l.groupkey = :id '#13#10 +
    '      AND '#13#10 +
    '      c.email > '''' '#13#10 +
    '  )',
    TgdcBaseContact.SelectObject('�������� ������� �� �������� �����:'), R)
    and (not VarIsNull(R[0, 0])) then
  begin
    if Trim(edRecipients.Text) > '' then
      edRecipients.Text := edRecipients.Text + ',';
    edRecipients.Text := edRecipients.Text + R[0, 0];
  end;
end;

procedure TdlgSendReport.FormCreate(Sender: TObject);
begin
  Assert(gdcBaseManager <> nil);
  iblkupSMTP.Transaction := gdcBaseManager.ReadTransaction;
end;

end.
