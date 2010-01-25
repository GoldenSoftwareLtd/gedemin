unit dlgEnterInterval;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, mBitButton, FrmPlSvr, xLabel, mmOptions, ExtCtrls;

type
  TfrmEnterInterval = class(TForm)
    Label2: TLabel;
    mBitButton1: TmBitButton;
    mBitButton2: TmBitButton;
    xlbContract: TxLabel;
    FormPlaceSaver1: TFormPlaceSaver;
    Panel1: TPanel;
    Label1: TLabel;
    Label3: TLabel;
    dtpDateBegin: TDateTimePicker;
    dtpDateEnd: TDateTimePicker;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    function GetDateBegin: TDate;
    function GetDateEnd: TDate;
    { Private declarations }
  public
    { Public declarations }
    property DateBegin_int: TDate read GetDateBegin;
    property DateEnd_int: TDate read GetDateEnd;
  end;

var
  frmEnterInterval: TfrmEnterInterval;

implementation

{$R *.DFM}

{ TfrmEnterInterval }


{ TfrmEnterInterval }

function TfrmEnterInterval.GetDateBegin: TDate;
begin
  Result := dtpDateBegin.Date;
end;

function TfrmEnterInterval.GetDateEnd: TDate;
begin
  Result := dtpDateEnd.Date;
end;

procedure TfrmEnterInterval.FormCreate(Sender: TObject);
var
  D: TDate;
begin
  if Options <> nil then
  begin
    if Options.GetDate('enterintervaldatebegin', D) then
      dtpDateBegin.Date := D
    else
      dtpDateBegin.Date := SysUtils.Date;
    if Options.GetDate('enterintervaldateend', D) then
      dtpDateEnd.Date := D
    else
      dtpDateEnd.Date := SysUtils.Date;
  end;
end;

procedure TfrmEnterInterval.FormDestroy(Sender: TObject);
begin
  if Options <> nil then
  begin
    Options.SetDate('enterintervaldatebegin', False, dtpDateBegin.Date);
    Options.SetDate('enterintervaldateend', False, dtpDateEnd.Date);
  end;
end;

end.
