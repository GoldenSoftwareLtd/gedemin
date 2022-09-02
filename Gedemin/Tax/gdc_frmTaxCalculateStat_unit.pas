// ShlTanya, 12.03.2019

unit gdc_frmTaxCalculateStat_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_Createable_Form, ExtCtrls, StdCtrls;

type
  TfrmTaxCalculateStat = class(TCreateableForm)
    pnlMain: TPanel;
    btnBreak: TButton;
    pnlTax: TPanel;
    pnlFunction: TPanel;
    lblFunction: TLabel;
    pnlDate: TPanel;
    lblDate: TLabel;
    pnlStat: TPanel;
    lblStat: TLabel;
    lblTacName: TLabel;
    pnlActualDate: TPanel;
    Label1: TLabel;
    lblActualValue: TLabel;
    lblFNameValue: TLabel;
    lblActValue: TLabel;
    lblOnDateValue: TLabel;
    lblTaxValue: TLabel;
    procedure btnBreakClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FBreak: Boolean;

    procedure CheckMessage;

    procedure SetFunctionName(const Value: String);
    procedure SetOnDate(const Value: String);
    procedure SetStatus(const Value: String);
    procedure SetTaxName(const Value: String);
    procedure SetActualDate(const Value: String);
    { Private declarations }
  public

    property FunctionName: String write SetFunctionName;
    property OnDate: String write SetOnDate;
    property TaxName: String write SetTaxName;
    property Status: String write SetStatus;
    property ActualDate: String write SetActualDate;
    { Public declarations }
  end;

var
  frmTaxCalculateStat: TfrmTaxCalculateStat;

implementation

uses
  gdc_frmTaxDesignTime_unit;

{$R *.DFM}

{ TfrmTaxCalculateStat }

procedure TfrmTaxCalculateStat.CheckMessage;
var
  Msg: TMsg;
begin
  if Active then
    Refresh;

  if PeekMessage(Msg, Handle, wm_keydown, wm_keydown, PM_REMOVE)
    or PeekMessage(Msg, Handle, WM_LBUTTONDOWN, WM_LBUTTONDBLCLK, PM_REMOVE) then
  begin
    if (Msg.hwnd = btnBreak.Handle) and (gdc_frmTaxDesignTime <> nil) then
    begin
      gdc_frmTaxDesignTime.BreakCalculation;
    end;
  end;
end;

procedure TfrmTaxCalculateStat.SetFunctionName(const Value: String);
begin
  CheckMessage;
  lblFNameValue.Caption := Value;
end;

procedure TfrmTaxCalculateStat.SetOnDate(const Value: String);
begin
  CheckMessage;
  lblOnDateValue.Caption := Value;
end;

procedure TfrmTaxCalculateStat.SetStatus(const Value: String);
begin
  CheckMessage;
  lblActValue.Caption := Value;
end;

procedure TfrmTaxCalculateStat.SetTaxName(const Value: String);
begin
  CheckMessage;
  lblTaxValue.Caption := Value;
end;

procedure TfrmTaxCalculateStat.btnBreakClick(Sender: TObject);
begin
  FBreak := True;
  raise Exception.Create('Расчет прерван');
end;

procedure TfrmTaxCalculateStat.FormShow(Sender: TObject);
begin
  FBreak := False;
end;

procedure TfrmTaxCalculateStat.SetActualDate(const Value: String);
begin
  CheckMessage;
  lblActualValue.Caption := Value;
end;

end.
