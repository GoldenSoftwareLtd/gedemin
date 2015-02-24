unit gd_dlgReg_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, ActnList;

type
  Tgd_dlgReg = class(TForm)
    eCipher: TEdit;
    Label2: TLabel;                   
    btnClose: TButton;
    btnReg: TButton;
    Bevel1: TBevel;
    pc: TPageControl;
    tsReg: TTabSheet;
    tsUnReg: TTabSheet;
    mUnreg: TMemo;
    lblRegNumber: TLabel;
    lblRegNumber2: TLabel;
    mUnreg2: TMemo;
    mReg: TMemo;
    mReg2: TMemo;
    ActionList: TActionList;
    actReg: TAction;
    procedure FormCreate(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure actRegExecute(Sender: TObject);
    procedure actRegUpdate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gd_dlgReg: Tgd_dlgReg;
                    
implementation

uses
  gd_registration, Clipbrd
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{$R *.DFM}

procedure Tgd_dlgReg.FormCreate(Sender: TObject);
var
  S1, S2: String;
begin
  lblRegNumber.Caption := RegParams.GetControlNumber;

  if RegParams.ValidUntil > 0 then
    S1 := '����������� ��: ' + FormatDateTime('dd.mm.yy', RegParams.ValidUntil)
  else
    S1 := '';

  if RegParams.MaxUserCount > 0 then
    S2 := '������������ ���������� �������������: ' + IntToStr(RegParams.MaxUserCount) + '.'
  else
    S2 := '';

  mReg.Lines.Text := Format(mReg.Lines.Text, [S2, S1]);
  lblRegNumber2.Caption := RegParams.GetControlNumber;

  if RegParams.CheckRegistration(False) then
    pc.ActivePage := tsReg
  else
    pc.ActivePage := tsUnReg;
end;

procedure Tgd_dlgReg.btnCloseClick(Sender: TObject);
begin
  actReg.Execute;
end;

procedure Tgd_dlgReg.actRegExecute(Sender: TObject);
begin
  if
    (
      not RegParams.CheckRegistration(False)
    )
    or
    (
      RegParams.CheckRegistration(False)
      and
      (
        MessageBox(Handle,
          '���� ����� ��������� ��� ����������������.'#13#10 +
          '��������� ��������� �����������?',
          '��������', mb_YesNo or MB_ICONQUESTION) = mrYes
        )
    ) then
  try
    RegParams.RegisterProgram(StrToInt64(eCipher.Text));

    if RegParams.CheckRegistration(True) then
    begin
      MessageBox(Handle,
        '����������� ��������� ������ �������.',
        '�����������',
        MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);
    end;

    Close;
  except
    on Exception do
    begin
      MessageBox(Handle,
        '�������� ������ ��� ��������� ���� �������������.'#13#10 +
        '����������, ��������� ��������� ��������.',
        '��������',
        MB_OK or MB_ICONHAND or MB_TASKMODAL);
    end;
  end;
end;

procedure Tgd_dlgReg.actRegUpdate(Sender: TObject);
begin
  actReg.Enabled := StrToInt64Def(eCipher.Text, -1) >= 0;
end;

end.
