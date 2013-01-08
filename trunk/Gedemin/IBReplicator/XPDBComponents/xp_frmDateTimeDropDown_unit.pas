unit xp_frmDateTimeDropDown_unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, xp_frmDropDown_unit, ActnList, Grids, Calendar, ComCtrls;

type
  TfrmDateTimeDropDown = class(TfrmDropDown)
    MonthCalendar: TMonthCalendar;
    procedure MonthCalendarDblClick(Sender: TObject);
    procedure MonthCalendarKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  protected
    function GetInitBounds(ALeft, ATop, AWidth, AHeight: Integer; FirstTime:Boolean): TRect; override;
    function GetValue: Variant; override;
    procedure SetValue(const Value: Variant); override;
  public
    { Public declarations }
  end;

var
  frmDateTimeDropDown: TfrmDateTimeDropDown;

implementation

uses DateUtils;

{$R *.dfm}

{ TfrmDateTimeDropDown }

function TfrmDateTimeDropDown.GetInitBounds(ALeft, ATop, AWidth,
  AHeight: Integer; FirstTime:Boolean): TRect;
begin
  Result := Rect(0, 0, 190, 153)
end;

function TfrmDateTimeDropDown.GetValue: Variant;
begin
  With MonthCalendar do
    Result := Date;
end;

procedure TfrmDateTimeDropDown.MonthCalendarDblClick(Sender: TObject);
begin
  ModalResult := mrOk

end;

procedure TfrmDateTimeDropDown.MonthCalendarKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_RETURN) and (Shift = []) then
  begin
    Key := 0;
    ModalResult := mrOk;
  end else
    inherited;
end;

procedure TfrmDateTimeDropDown.SetValue(const Value: Variant);
begin
  if VarIsNull(Value) then
    MonthCalendar.Date := Now
  else
    MonthCalendar.Date := Value;
end;

end.
