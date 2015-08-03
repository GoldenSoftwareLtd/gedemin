unit dlg_EmailSend_Unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, IBDatabase, dmDataBase_unit, StdCtrls, gsIBLookupComboBox, gdcBaseInterface,
  ActnList, frxClass, frxPreview, frxDsgnIntf, gd_WebClientControl_unit;

type
  Tdlg_EmailSend = class(TForm)
    iblkupSMTP: TgsIBLookupComboBox;
    Label1: TLabel;
    iblkupContact: TgsIBLookupComboBox;
    edRecipients: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    cbExportType: TComboBox;
    Label4: TLabel;
    edSubject: TEdit;
    Label5: TLabel;
    mBodyText: TMemo;
    Button1: TButton;
    Label6: TLabel;
    alBase: TActionList;
    actSend: TAction;
    procedure FormCreate(Sender: TObject);
    procedure actSendExecute(Sender: TObject);
    procedure actSendUpdate(Sender: TObject);
    procedure iblkupContactChange(Sender: TObject);
    
  private
    FForbidSend: Boolean;

    FPDFExport: TfrxCustomExportFilter;
    FRTFExport: TfrxCustomExportFilter;
    FXLSExport: TfrxCustomExportFilter;
    FXMLExport: TfrxCustomExportFilter;

    FPreview: TfrxPreview;

    FReadTransaction: TIBTransaction;

    procedure SetupTabs;

    procedure OnWebClientThreadNotify(var Msg : TMessage); message WM_GD_FINISH_SEND_EMAIL;

  public
    procedure Init(AfrxPreview: TfrxPreview;
      AfrxExportFilters: TfrxExportFilterCollection);

    property ReadTransaction: TIBTransaction read FReadTransaction;
  end;

var
  dlg_EmailSend: Tdlg_EmailSend;

implementation

{$R *.DFM}

uses
  IBSQL;

procedure Tdlg_EmailSend.OnWebClientThreadNotify(var Msg : TMessage);
begin
  FForbidSend := False;

  if Msg.WParam = 1 then
    MessageDlg('Сообщение отправлено.',
      mtInformation,
      [mbOk],
      0)
  else
    MessageDlg('Сбой при отправке сообщения: ' +
      String(PChar(Pointer(Msg.LParam))),
      mtError,
      [mbOk],
      0);
end;

procedure Tdlg_EmailSend.Init(AfrxPreview: TfrxPreview;
  AfrxExportFilters: TfrxExportFilterCollection);
var
  I: Integer;
begin
  FPreview := AfrxPreview;

  for I := 0 to AfrxExportFilters.Count - 1 do
  begin
    if TfrxCustomExportFilter(frxExportFilters[i].Filter).ClassName = 'TfrxPDFExport' then
      FPDFExport := TfrxCustomExportFilter(frxExportFilters[i].Filter)
    else if TfrxCustomExportFilter(frxExportFilters[i].Filter).ClassName = 'TfrxRTFExport' then
      FRTFExport := TfrxCustomExportFilter(frxExportFilters[i].Filter)
    else if TfrxCustomExportFilter(frxExportFilters[i].Filter).ClassName = 'TfrxXLSExport' then
      FXLSExport := TfrxCustomExportFilter(frxExportFilters[i].Filter)
    else if TfrxCustomExportFilter(frxExportFilters[i].Filter).ClassName = 'TfrxXMLExport' then
      FXMLExport := TfrxCustomExportFilter(frxExportFilters[i].Filter);
  end;
end;

procedure Tdlg_EmailSend.SetupTabs;
var
  q: TIBSQL;
begin
  iblkupSMTP.Transaction := gdcBaseManager.ReadTransaction;
  iblkupContact.Transaction := gdcBaseManager.ReadTransaction;

  q := TIBSQL.Create(nil);
  try
    q.Transaction := gdcBaseManager.ReadTransaction;

    q.SQL.Text :=
      'SELECT * FROM gd_smtp s WHERE s.principal = 1';
    q.ExecQuery;

    if not q.EOF then
      iblkupSMTP.CurrentKeyInt := q.FieldByName('id').AsInteger;
  finally
    q.Free;
  end;
end;

procedure Tdlg_EmailSend.FormCreate(Sender: TObject);
begin
  inherited;

  Assert(gdcBaseManager <> nil);

  FReadTransaction := gdcBaseManager.ReadTransaction;

  SetupTabs;
end;

procedure Tdlg_EmailSend.actSendExecute(Sender: TObject);
var
  CurrExport: TfrxCustomExportFilter;
  FN: String;
  TempFileName: String;
  TempShowDialog: Boolean;
begin
  FForbidSend := True;
  try
    if cbExportType.Text = 'PDF' then
      CurrExport := FPDFExport
    else if cbExportType.Text = 'DOC' then
      CurrExport := FRTFExport
    else if cbExportType.Text = 'XLS' then
      CurrExport := FXLSExport
    else if cbExportType.Text = 'XML' then
      CurrExport := FXMLExport
    else
      raise Exception.Create('Неверный формат отчета: ' + cbExportType.Text);

    if CurrExport = nil then
      raise Exception.Create('Отсуствует фильтр');

    FN := GetTempFileName(cbExportType.Text);

    TempFileName := CurrExport.FileName;
    TempShowDialog := CurrExport.ShowDialog;
    try
      CurrExport.FileName := FN;
      CurrExport.ShowDialog := False;
      try
        FPreview.Export(CurrExport);
      except
        DeleteFile(FN);
        RemoveDir(ExtractFileDir(FN));
        raise;
      end;
      gdWebClientThread.SendReport(edRecipients.Text, edSubject.Text,
        mBodyText.Text, iblkupSMTP.CurrentKeyInt, FN, Self.Handle);
    finally
      CurrExport.FileName := TempFileName;
      CurrExport.ShowDialog := TempShowDialog;
    end;
  except
    on E: Exception do
    begin
      FForbidSend := False;
      raise;
    end;
  end;
end;

procedure Tdlg_EmailSend.actSendUpdate(Sender: TObject);
begin
  actSend.Enabled := (edRecipients.Text > '')
    and (iblkupSMTP.CurrentKeyInt > 0)
    and (cbExportType.Text > '')
    and (not FForbidSend);
end;

procedure Tdlg_EmailSend.iblkupContactChange(Sender: TObject);
var
  q: TIBSQL;
begin
  if iblkupContact.CurrentKeyInt > 0 then
  begin
    q := TIBSQL.Create(nil);
    try
      q.Transaction := gdcBaseManager.ReadTransaction;

      q.SQL.Text :=
        'SELECT * FROM gd_contact g WHERE g.id = :id';
      q.ParamByName('id').AsInteger := iblkupContact.CurrentKeyInt;
      q.ExecQuery;

      if not q.EOF then
      begin
        if q.FieldByName('contacttype').AsInteger in [2..5] then
        begin
          if q.FieldByName('email').AsString > '' then
          begin
            if edRecipients.Text > '' then
              edRecipients.Text := edRecipients.Text + ',';
            edRecipients.Text := edRecipients.Text + q.FieldByName('email').AsString;
          end
        end
        else if q.FieldByName('contacttype').AsInteger = 1 then
        begin
          q.Close;

          q.SQL.Text :=
            'SELECT '#13#10 +
            '  c.email '#13#10 +
            'FROM '#13#10 +
            '  gd_contact c '#13#10 +
            '    JOIN '#13#10 +
            '      gd_contactlist g '#13#10 +
            '    ON '#13#10 +
            '      g.contactkey  =  c.id '#13#10 +
            'WHERE '#13#10 +
            '  (g.groupkey  =  :gk) '#13#10 +
            '    AND (c.email IS NOT NULL) '#13#10 +
            '    AND (c.email <> '''')';
          q.ParamByName('gk').AsInteger := iblkupContact.CurrentKeyInt;

          q.ExecQuery;

          while not q.EOF do
          begin
            if q.FieldByName('email').AsString > '' then
            begin
              if edRecipients.Text > '' then
                edRecipients.Text := edRecipients.Text + ',';

              edRecipients.Text := edRecipients.Text + q.FieldByName('email').AsString;
            end;
            q.Next;
          end;
        end;

      end;
    finally
      q.Free;
    end;
  end;
end;

end.
