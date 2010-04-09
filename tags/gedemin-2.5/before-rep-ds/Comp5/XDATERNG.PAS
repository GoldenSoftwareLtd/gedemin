
{++

  Copyright (c) 1996-97 by Golden Software of Belarus

  Module

    xdaterng.pas

  Abstract

    Date range.

  Author

    Anton Smirnov (27-sep-97)

  Contact address

  Known bugs

    Remove FMinDateStr, MaxDateStr fields.

  Revisions history

    1.00     27-sep-97    sai       Initial version.
    1.01     10-nov-97    sai       Caption property added.
    1.02     11-nov-97    sai       FxxxStr to GetxxxStr.
    1.03     17-apr-98    sai       Убрана проверка на сравнения DateBegin и DateEnd
    1.04     02-aug-98    andreik   Ошибки с проверками на диапазоны дат ликвидированы.

--}

unit xDateRng;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, xCalend;

type
  TxDateRange = class(TWinControl)
  private
    FCaption: String;
    FStartDate, FEndDate, FMinDate, FMaxDate: TDateTime;
    FOnDateChanged: TNotifyEvent;
    FSave: Boolean;

    Panel: TGroupBox;
    LabelBegin, LabelEnd: TLabel;
    CalStart, CalEnd: TxCalendarCombo;

    procedure SetStartDateStr(AStartDateStr: String);
    procedure SetEndDateStr(AnEndDateStr: String);
    procedure SetMinDateStr(AMinDateStr: String);
    procedure SetMaxDateStr(AMaxDateStr: String);
    procedure SetStartDate(AStartDate: TDateTime);
    procedure SetEndDate(AnEndDate: TDateTime);
    procedure SetMinDate(AMinDate: TDateTime);
    procedure SetMaxDate(AMaxDate: TDateTime);
    procedure SetCaption(ACaption: String);
    function GetStartDateStr: String;
    function GetEndDateStr: String;
    function GetMinDateStr: String;
    function GetMaxDateStr: String;

    procedure StartOnDateChanged(Sender: TObject);
    procedure EndOnDateChanged(Sender: TObject);

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    property StartDate: TDateTime read FStartDate write SetStartDate;
    property EndDate: TDateTime read FEndDate write SetEndDate;
    property MinDate: TDateTime read FMinDate write SetMinDate;
    property MaxDate: TDateTime read FMaxDate write SetMaxDate;

  published
    property StartDateStr: String read GetStartDateStr write SetStartDateStr;
    property EndDateStr: String read GetEndDateStr write SetEndDateStr;
    property MinDateStr: String read GetMinDateStr write SetMinDateStr;
    property MaxDateStr: String read GetMaxDateStr write SetMaxDateStr;
    property OnDateChanged: TNotifyEvent read FOnDateChanged
      write FOnDateChanged;
    property Save: Boolean read FSave write FSave;
    property Caption: String read FCaption write SetCaption;

    property Font;
    property ParentFont;
    property Visible;
  end;

procedure Register;

implementation

uses xAppReg;

const
  DefWidth = 329;
  DefHeight = 51;

{TxDateRange ---------------------------------------------}

constructor TxDateRange.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  Width := DefWidth;
  Height := DefHeight;

  FCaption := 'Диапазон';
  Panel := TGroupBox.Create(Self);
  Panel.Parent := Self;
  Panel.ParentFont := True;
  Panel.Align := alClient;
  Panel.Caption := FCaption;

  LabelBegin := TLabel.Create(Panel);
  LabelBegin.Parent := Panel;
  LabelBegin.ParentFont := True;
  LabelBegin.Caption := 'Начало';
  LabelBegin.Left := 12;
  LabelBegin.Top := 22;

  LabelEnd := TLabel.Create(Panel);
  LabelEnd.Parent := Panel;
  LabelEnd.ParentFont := True;
  LabelEnd.Caption := 'Окончание';
  LabelEnd.Left := 159;
  LabelEnd.Top := 22;

  FStartDate := SysUtils.Date;
  FEndDate := SysUtils.Date;
  FMinDate := SysUtils.Date;
  FMaxDate := SysUtils.Date;

  CalStart := TxCalendarCombo.Create(Panel);
  CalStart.Parent := Panel;
  CalStart.ParentFont := True;
  CalStart.Width := 96;
  CalStart.Left := 55;
  CalStart.Top := 19;
  CalStart.OnDateChanged := StartOnDateChanged;

  CalEnd := TxCalendarCombo.Create(Panel);
  CalEnd.Parent := Panel;
  CalEnd.ParentFont := True;
  CalEnd.Width := 96;
  CalEnd.Top := 19;
  CalEnd.Left := 221;
  CalEnd.OnDateChanged := EndOnDateChanged;
  CalStart.Date := FStartDate;
  CalEnd.Date := FEndDate;

  FSave := True;
end;

destructor TxDateRange.Destroy;
begin
  LabelBegin.Free;
  LabelEnd.Free;
  CalStart.Free;
  CalEnd.Free;
  Panel.Free;
  inherited Destroy;
end;

procedure TxDateRange.SetStartDateStr(AStartDateStr: String);
var
  D: TDateTime;
begin
  D := StrToDate(AStartDateStr);
  if (D >= FMinDate) and (D <= FMaxDate) {and (D <= FEndDate)} then
  begin
    StartDate := D;
    CalStart.Date := D;
  end;
end;

procedure TxDateRange.SetEndDateStr(AnEndDateStr: String);
var
  D: TDateTime;
begin
  D := StrToDate(AnEndDateStr);
  if (D >= FMinDate) and (D <= FMaxDate) {and (D >= FStartDate)} then
  begin
    EndDate := D;
    CalEnd.Date := D;
  end;
end;

procedure TxDateRange.SetMinDateStr(AMinDateStr: String);
var
  D: TDateTime;
begin
  D := StrToDate(AMinDateStr);
{  if (D <= FStartDate) then }
    FMinDate := D;
end;

procedure TxDateRange.SetCaption(ACaption: String);
begin
  Panel.Caption := ACaption;
  FCaption := ACaption;
end;

procedure TxDateRange.SetMaxDateStr(AMaxDateStr: String);
var
  D: TDateTime;
begin
  D := StrToDate(AMaxDateStr);
{  if (D >= FEndDate) then }
    FMaxDate := D;
end;

procedure TxDateRange.SetStartDate(AStartDate: TDateTime);
begin
  if (AStartDate >= FMinDate) and (AStartDate <= FMaxDate) {and (AStartDate <= FEndDate)} then
  begin
    FStartDate := AStartDate;
    CalStart.Date := FStartDate;
  end;
end;

procedure TxDateRange.SetEndDate(AnEndDate: TDateTime);
begin
  if (AnEndDate >= FMinDate) and (AnEndDate <= FMaxDate) {and (AnEndDate >= FStartDate)} then
  begin
    FEndDate := AnEndDate;
    CalEnd.Date := FEndDate;
  end;
end;

procedure TxDateRange.SetMinDate(AMinDate: TDateTime);
begin
{  if (FMinDate <= FStartDate) then }
    FMinDate := AMinDate;
end;

procedure TxDateRange.SetMaxDate(AMaxDate: TDateTime);
begin
{  if (AMaxDate >= FEndDate) then }
    FMaxDate := AMaxDate;
end;

procedure TxDateRange.StartOnDateChanged(Sender: TObject);
begin
{  if CalStart.Date > CalEnd.Date then
    CalStart.Date := CalEnd.Date;}
  if CalStart.Date > MaxDate then
    CalStart.Date := MaxDate;
  if CalStart.Date < MinDate then
    CalStart.Date := MinDate;
  StartDate := CalStart.Date;
  if Assigned(FOnDateChanged) then
    FOnDateChanged(Self);
end;

procedure TxDateRange.EndOnDateChanged(Sender: TObject);
begin
{  if CalStart.Date > CalEnd.Date then
    CalEnd.Date := CalStart.Date;}
  if CalEnd.Date > MaxDate then
    CalEnd.Date := MaxDate;
  if CalEnd.Date < MinDate then
    CalEnd.Date := MinDate;
  EndDate := CalEnd.Date;
  if Assigned(FOnDateChanged) then
    FOnDateChanged(Self);
end;

function TxDateRange.GetStartDateStr: String;
begin
  Result := FormatDateTime('dd.mm.yyyy', FStartDate);
end;

function TxDateRange.GetEndDateStr: String;
begin
  Result := FormatDateTime('dd.mm.yyyy', FEndDate);
end;

function TxDateRange.GetMinDateStr: String;
begin
  Result := FormatDateTime('dd.mm.yyyy', FMinDate);
end;

function TxDateRange.GetMaxDateStr: String;
begin
  Result := FormatDateTime('dd.mm.yyyy', FMaxDate);
end;

{Registration --------------------------------------------}

procedure Register;
begin
  RegisterComponents('xTool-3', [TxDateRange]);
end;

end.
