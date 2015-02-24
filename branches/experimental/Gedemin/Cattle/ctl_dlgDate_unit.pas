unit ctl_dlgDate_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Mask, xDateEdits, ComCtrls;

type
  Tctl_dlgDate = class(TForm)
    Button1: TButton;
    Button2: TButton;
    MonthCalendar: TMonthCalendar;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
  private
  public
  end;

var
  ctl_dlgDate: Tctl_dlgDate;

implementation

{$R *.DFM}

procedure Tctl_dlgDate.FormCreate(Sender: TObject);
begin
  MonthCalendar.Date := Now;
end;

end.
