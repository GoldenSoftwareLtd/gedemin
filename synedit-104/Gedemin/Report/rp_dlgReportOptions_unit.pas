unit rp_dlgReportOptions_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, Mask, DBCtrls, StdCtrls, Db, ExtCtrls, IBCustomDataSet;

type
  TdlgReportOptions = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    Label2: TLabel;
    dtpStart: TDateTimePicker;
    DBEdit2: TDBEdit;
    dtpFinish: TDateTimePicker;
    Label3: TLabel;
    Label4: TLabel;
    dtpRefresh: TDateTimePicker;
    Label5: TLabel;
    pnlExternal: TPanel;
    dbePath: TDBEdit;
    Button3: TButton;
    pnlInterbase: TPanel;
    Label6: TLabel;
    DBMemo1: TDBMemo;
    dsReportServer: TDataSource;
    dbcbLocal: TDBCheckBox;
    Label7: TLabel;
    dbeActual: TDBEdit;
    Label8: TLabel;
    dbeUnactual: TDBEdit;
    SaveDialog1: TSaveDialog;
    ibdsReportServer: TIBDataSet;
    Label9: TLabel;
    dbePort: TDBEdit;
    Label10: TLabel;
    procedure Button3Click(Sender: TObject);
    procedure dbePathChange(Sender: TObject);
    procedure dbcbLocalClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    procedure CheckGDB;
    procedure SetEnabledChild(const AnControl: TWinControl; const AnEnabled: Boolean);
  public
    function ViewOptions(const AnReportKey: Integer): Boolean;
  end;

function CheckGDBFile(const AnFileName: String): Boolean;

var
  dlgReportOptions: TdlgReportOptions;

implementation

uses
  rp_report_const
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{$R *.DFM}

function CheckGDBFile(const AnFileName: String): Boolean;
const
  ExtGDB = '.GDB';
var
  I: Integer;
begin
  I := Pos(ExtGDB, UpperCase(AnFileName));
  Result := (I > 0) and (I = Length(AnFileName) - Length(ExtGDB) + 1);
end;

procedure TdlgReportOptions.Button3Click(Sender: TObject);
begin
  if SaveDialog1.Execute then
    ibdsReportServer.FieldByName('resultpath').AsString := SaveDialog1.FileName;
end;

procedure TdlgReportOptions.CheckGDB;
begin
  SetEnabledChild(pnlInterbase, CheckGDBFile(dbePath.Text));
end;

procedure TdlgReportOptions.SetEnabledChild(const AnControl: TWinControl; const AnEnabled: Boolean);
var
  I: Integer;
begin
  AnControl.Enabled := AnEnabled;
  for I := 0 to AnControl.ControlCount - 1 do
  begin
    if AnControl.Controls[I] is TWinControl then
      SetEnabledChild((AnControl.Controls[I] as TWinControl), AnEnabled)
    else
      AnControl.Controls[I].Enabled := AnEnabled;
  end;
end;

function TdlgReportOptions.ViewOptions(const AnReportKey: Integer): Boolean;
begin
  Result := False;
  ibdsReportServer.Close;
  ibdsReportServer.Params[0].AsInteger := AnReportKey;
  ibdsReportServer.Open;
  if ibdsReportServer.Eof then
  begin
    MessageBox(Self.Handle, '������ �������� ������� ������� �� ������� � ���� ������.',
     '��������', MB_OK or MB_ICONWARNING);
    Exit;
  end;
  ibdsReportServer.Edit;
  dtpStart.Time := ibdsReportServer.FieldByName('starttime').AsDateTime;
  dtpFinish.Time := ibdsReportServer.FieldByName('endtime').AsDateTime;
  dtpRefresh.Time := ibdsReportServer.FieldByName('frqdataread').AsDateTime;
  if ibdsReportServer.FieldByName('localstorage').IsNull then
    ibdsReportServer.FieldByName('localstorage').AsInteger := 1;
  if ShowModal = mrOK then
  try
    ibdsReportServer.FieldByName('starttime').AsDateTime := dtpStart.Time;
    ibdsReportServer.FieldByName('endtime').AsDateTime := dtpFinish.Time;
    ibdsReportServer.FieldByName('frqdataread').AsDateTime := dtpRefresh.Time;
    ibdsReportServer.Post;
    Result := True;
  except
    on E: Exception do
    begin
      MessageBox(Self.Handle, PChar('��������� ������ ��� ���������� ���������� �������:'
       + #13#10 + E.Message), '������', MB_OK or MB_ICONERROR);
      ibdsReportServer.Cancel;
    end;
  end else
    ibdsReportServer.Cancel;
end;

procedure TdlgReportOptions.dbePathChange(Sender: TObject);
begin
  if dbePath.Enabled then
    CheckGDB;
end;

procedure TdlgReportOptions.dbcbLocalClick(Sender: TObject);
begin
  SetEnabledChild(pnlExternal, not dbcbLocal.Checked);
  if not dbcbLocal.Checked then
    CheckGDB;
end;

procedure TdlgReportOptions.Button1Click(Sender: TObject);
begin
  if dtpStart.Time >= dtpFinish.Time then
  begin
    MessageBox(Self.Handle, '��������� ���������� ���������� ������� '#13#10 +
     '������ ������������ ����� ������.', '��������', MB_OK or MB_ICONWARNING);
    dtpStart.SetFocus;
    Exit;
  end;

  if dbeActual.Text = '' then
  begin
    MessageBox(Self.Handle, '�� ������ ���������� ���� ������������ ������',
     '��������', MB_OK or MB_ICONWARNING);
    dbeActual.SetFocus;
    Exit;
  end;

  if dbeUnActual.Text = '' then
  begin
    MessageBox(Self.Handle, '�� ������ ���������� ���� �������������� ������',
     '��������', MB_OK or MB_ICONWARNING);
    dbeUnActual.SetFocus;
    Exit;
  end;

  if dbePort.Text = '' then
  begin
    MessageBox(Self.Handle, '�� ����� ���� ������� ��� ����������.',
     '��������', MB_OK or MB_ICONWARNING);
    dbePort.SetFocus;
    Exit;
  end;

  if StrToInt(dbeActual.Text) > StrToInt(dbeUnActual.Text) then
  begin
    MessageBox(Self.Handle, '������ ������������ ������ ������ ����'#13#10 +
     '������ ������� ��������������.', '��������', MB_OK or MB_ICONWARNING);
    dbeUnActual.SetFocus;
    Exit;
  end;

  if DateTimeToTimeStamp(dtpRefresh.Time).Time < MinFrqRefresh then
  begin
    MessageBox(Self.Handle, '������� ���������� ������ ������ ���� �� ������ 1 ����.',
     '��������', MB_OK or MB_ICONWARNING);
    dtpRefresh.SetFocus;
    Exit;
  end;

  if (dtpFinish.Time - dtpStart.Time) <= Frac(dtpRefresh.Time) then
  begin
    MessageBox(Self.Handle, '������� ���������� ������ ������ ���� ������ '#13#10 +
     '���������� ���������� ����������.', '��������', MB_OK or MB_ICONWARNING);
    dtpFinish.SetFocus;
    Exit;
  end;

  if DBMemo1.Enabled and (Trim(DBMemo1.Lines.Text) = '') then
  begin
    MessageBox(Self.Handle, '�� ������� ��������� ����������� � ���� ������',
     '��������', MB_OK or MB_ICONWARNING);
    if DBMemo1.CanFocus then
      DBMemo1.SetFocus;
    Exit;
  end;

  if dbePath.Enabled and (Trim(dbePath.Text) = '') then
  begin
    MessageBox(Self.Handle, '�� ������� ������������ ����� ��� �������� ��������� �����������',
     '��������', MB_OK or MB_ICONWARNING);
    if dbePath.CanFocus then
      dbePath.SetFocus;
    Exit;
  end;

  ModalResult := mrOK;
end;

end.
