unit tmp_dlgEditTemplate_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Mask, DBCtrls, IBDatabase, Db, IBCustomDataSet, DBClient,
  ActnList, rp_BaseReport_unit, ExtCtrls;

type
  TdlgEditTemplate = class(TForm)
    ibdsTemplate: TIBDataSet;
    ibtrTemplate: TIBTransaction;
    dbeName: TDBEdit;
    dbeDescription: TDBEdit;
    Label1: TLabel;
    Label2: TLabel;
    cdsTemplateType: TClientDataSet;
    cdsTemplateTypeTemplateType: TStringField;
    cdsTemplateTypeDescriptionType: TStringField;
    dblcbType: TDBLookupComboBox;
    dsTemplateType: TDataSource;
    dsTemplate: TDataSource;
    Label3: TLabel;
    btnOk: TButton;
    btnCancel: TButton;
    btnEditTemplate: TButton;
    ActionList1: TActionList;
    actEditTemplate: TAction;
    btnHelp: TButton;
    btnRigth: TButton;
    actHelp: TAction;
    actRight: TAction;
    procedure FormCreate(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure dsTemplateDataChange(Sender: TObject; Field: TField);
    procedure actEditTemplateExecute(Sender: TObject);
    procedure actEditTemplateUpdate(Sender: TObject);
  private
    FOldTemplateType: Variant;
    FTestReportResult: TReportResult;
  public
    function AddTemplate(out AnTemplateKey: Integer; const AnReportResult: TReportResult = nil): Boolean;
    function EditTemplate(const AnTemplateKey: Integer; const AnReportResult: TReportResult = nil): Boolean;
    function DeleteTemplate(const AnTemplateKey: Integer): Boolean;
  end;

var
  dlgEditTemplate: TdlgEditTemplate;

implementation

uses
  rp_report_const, gd_SetDatabase, rp_StreamFR, rtf_TemplateBuilder,
  xfr_TemplateBuilder, rp_dlgViewResultEx_unit;

{$R *.DFM}

function TdlgEditTemplate.AddTemplate(out AnTemplateKey: Integer;
 const AnReportResult: TReportResult = nil): Boolean;
begin
  Result := False;

  FTestReportResult := AnReportResult;

  if not ibtrTemplate.InTransaction then
    ibtrTemplate.StartTransaction;

  ibdsTemplate.Close;
  ibdsTemplate.Params[0].AsInteger := AnTemplateKey;
  ibdsTemplate.Open;
  ibdsTemplate.Insert;
  FOldTemplateType := ibdsTemplate.FieldByName('templatetype').AsVariant;
  ibdsTemplate.FieldByName('afull').AsInteger := -1;
  ibdsTemplate.FieldByName('achag').AsInteger := -1;
  ibdsTemplate.FieldByName('aview').AsInteger := -1;

  if ShowModal = mrOk then
  try
    ibdsTemplate.FieldByName('id').AsInteger :=
     GetUniqueKey(ibtrTemplate.DefaultDatabase, ibtrTemplate);
    ibdsTemplate.Post;
    Result := True;
    AnTemplateKey := ibdsTemplate.FieldByName('id').AsInteger;
  except
    on E: Exception do
    begin
      MessageBox(Handle, PChar('��������� ������ ��� ���������� �������.'#13#10 +
       E.Message), '������', MB_OK or MB_ICONERROR);
      ibdsTemplate.Cancel;
    end;
  end else
    ibdsTemplate.Cancel;

  if ibtrTemplate.InTransaction then
    ibtrTemplate.Commit;
end;

function TdlgEditTemplate.EditTemplate(const AnTemplateKey: Integer;
 const AnReportResult: TReportResult = nil): Boolean;
begin
  Result := False;

  FTestReportResult := AnReportResult;

  if not ibtrTemplate.InTransaction then
    ibtrTemplate.StartTransaction;

  ibdsTemplate.Close;
  ibdsTemplate.Params[0].AsInteger := AnTemplateKey;
  ibdsTemplate.Open;
  ibdsTemplate.Edit;

  if ibdsTemplate.Eof then
  begin
    MessageBox(Handle, '������ �� ������.', '��������', MB_OK or MB_ICONWARNING);
    Exit;
  end;

  FOldTemplateType := ibdsTemplate.FieldByName('templatetype').AsVariant;

  if ShowModal = mrOk then
  try
    ibdsTemplate.Post;
    Result := True;
  except
    on E: Exception do
    begin
      MessageBox(Handle, PChar('��������� ������ ��� �������������� �������.'#13#10 +
       E.Message), '������', MB_OK or MB_ICONERROR);
      ibdsTemplate.Cancel;
    end;
  end else
    ibdsTemplate.Cancel;

  if ibtrTemplate.InTransaction then
    ibtrTemplate.Commit;
end;

function TdlgEditTemplate.DeleteTemplate(const AnTemplateKey: Integer): Boolean;
begin
  Result := False;
  if not ibtrTemplate.InTransaction then
    ibtrTemplate.StartTransaction;

  if MessageBox(Handle, '�� ������������� ������ ������� ������?', '������',
   MB_YESNO or MB_ICONQUESTION) = IDNO then
    Exit;

  {gs} // �������� ����
  ibdsTemplate.Close;
  ibdsTemplate.Params[0].AsInteger := AnTemplateKey;
  ibdsTemplate.Open;

  if ibdsTemplate.Eof then
  begin
    MessageBox(Handle, '������ �� ������.', '��������', MB_OK or MB_ICONWARNING);
    Exit;
  end;

  try
    ibdsTemplate.Delete;
    Result := True;
  except
    on E: Exception do
      MessageBox(Handle, PChar('��������� ������ ��� �������� �������.'#13#10 +
       E.Message), '������', MB_OK or MB_ICONERROR);
  end;

  if ibtrTemplate.InTransaction then
    ibtrTemplate.Commit;
end;

procedure TdlgEditTemplate.FormCreate(Sender: TObject);
begin
  cdsTemplateType.CreateDataSet;
{RTF deleted}
//  cdsTemplateType.AppendRecord([ReportRTF, '������ RTF']);
  cdsTemplateType.AppendRecord([ReportFR, '������ FastReport']);
  cdsTemplateType.AppendRecord([ReportXFR, '������ xFastReport']);
  cdsTemplateType.AppendRecord([ReportGRD, '������ Grid']);
end;

procedure TdlgEditTemplate.btnOkClick(Sender: TObject);
begin
  if Trim(dbeName.Text) = '' then
  begin
    MessageBox(Handle, '�� ������ ������������ �������.', '��������',
     MB_OK or MB_ICONWARNING);
    if dbeName.CanFocus then
      dbeName.SetFocus;
    Exit;
  end;

  if dblcbType.KeyValue = NULL then
  begin
    MessageBox(Handle, '�� ����� ��� �������.', '��������',
     MB_OK or MB_ICONWARNING);
    if dblcbType.CanFocus then
      dblcbType.SetFocus;
    Exit;
  end;

{  if ibdsTemplate.FieldByName('templatedata').IsNull then
  begin
    MessageBox(Handle, '������ ����.', '��������',
     MB_OK or MB_ICONWARNING);
    if btnEditTemplate.CanFocus then
      btnEditTemplate.SetFocus;
    Exit;
  end;}

  ModalResult := mrOk;
end;

procedure TdlgEditTemplate.dsTemplateDataChange(Sender: TObject;
  Field: TField);
begin
  if (Field <> nil) and (AnsiUpperCase(Field.FieldName) = 'TEMPLATETYPE') then
  begin
    if (FOldTemplateType <> NULL) and (FOldTemplateType <> Field.Value)
     and not ibdsTemplate.FieldByName('templatedata').IsNull then
      if MessageBox(Handle, '����� ��������� ���� �������, ������ ������ ����� ������.'#13#10 +
       '�������� ��� �������?', '������', MB_YESNO or MB_ICONQUESTION) = IDYES then
        ibdsTemplate.FieldByName('templatedata').Value := NULL
      else
        Field.Value := FOldTemplateType;
    FOldTemplateType := Field.Value
  end;
end;

procedure TdlgEditTemplate.actEditTemplateExecute(Sender: TObject);
var
  LfrReport: Tgs_frSingleReport;
  RTFStr: TStream;
//  FStr: TFileStream;
begin

// ������� �� ����. ���� ��������
(*  if dblcbType.KeyValue = ReportRTF then
  begin
    RTFStr := ibdsTemplate.CreateBlobStream(ibdsTemplate.FieldByName('templatedata'),
     bmReadWrite);
    try
      try
        with TgsWord97.Create(Self) do
        try
          Execute(RTFStr);
          Show;
        finally
          Free;
        end;

      except
        on E: Exception do
        begin
          if MessageBox(Handle, PChar('��������� ������ ��� ������� ����������� � Word 97:'#13#10 +
           E.Message + #13#10 + '��������� ������ �� �����?'), '������', MB_YESNO or MB_ICONQUESTION) = IDYES then
            with TOpenDialog.Create(Self) do
            try
              if Execute then
              begin
                FStr := TFileStream.Create(FileName, fmOpenRead);
                try
                  RTFStr.Position := 0;
                  RTFStr.Size := 0;
                  RTFStr.CopyFrom(FStr, FStr.Size);
                finally
                  FStr.Free;
                end;
              end;
            finally
              Free;
            end;
        end;
      end;
    finally
      RTFStr.Free;
    end;
  end else                       *)
    if dblcbType.KeyValue = ReportFR then
    begin
      LfrReport := Tgs_frSingleReport.Create(Application);
      try
        if FTestReportResult <> nil then
          LfrReport.UpdateDictionary.ReportResult.Assign(FTestReportResult);
        RTFStr := ibdsTemplate.CreateBlobStream(ibdsTemplate.FieldByName('templatedata'), bmReadWrite);
        try
          LfrReport.LoadFromStream(RTFStr);//BlobField(ibdsTemplate.FieldByName('templatedata'));
//          DesignerRestrictions := [frdrDontSaveReport];
          LfrReport.DesignReport;
          if (LfrReport.Modified or LfrReport.ComponentModified) and (MessageBox(Handle,
           '������ ��� �������. ��������� ���������?', '������', MB_YESNO or MB_ICONQUESTION) = IDYES) then
          begin
            RTFStr.Position := 0;
            RTFStr.Size := 0;
            LfrReport.SaveToStream(RTFStr);
          end else
            ModalResult := mrOk;
//            LfrReport.SaveToBlobField(ibdsTemplate.FieldByName('templatedata'));
        finally
          RTFStr.Free;
        end;
      finally
        LfrReport.Free;
      end;
    end else
      if dblcbType.KeyValue = ReportXFR then
      begin
        RTFStr := ibdsTemplate.CreateBlobStream(ibdsTemplate.FieldByName('templatedata'),
         bmReadWrite);
        try
          with Txfr_dlgTemplateBuilder.Create(Self) do
          try
            Execute(RTFStr);
          finally
            Free;
          end;
        finally
          RTFStr.Free;
        end;
      end else
        if dblcbType.KeyValue = ReportGRD then
        begin
          RTFStr := ibdsTemplate.CreateBlobStream(ibdsTemplate.FieldByName('templatedata'), bmReadWrite);
          try
            with TdlgViewResultEx.Create(nil) do
            try
              ExecuteDialog(FTestReportResult, RTFStr);
            finally
              Free;
            end;
          finally
            RTFStr.Free;
          end;
        end else
          raise Exception.Create(Format('Template type %s not supported', [dblcbType.KeyValue]));
end;

procedure TdlgEditTemplate.actEditTemplateUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := dblcbType.KeyValue <> NULL;
end;

end.
