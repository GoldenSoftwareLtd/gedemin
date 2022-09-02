// ShlTanya, 20.02.2019

unit dp_dlgImportPeriod_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, ExtCtrls;

type
  TdlgImportPeriod = class(TForm)
    btnOk: TButton;
    btnCancel: TButton;
    Bevel1: TBevel;
    Label1: TLabel;
    dtpStart: TDateTimePicker;
    Label2: TLabel;
    dtpEnd: TDateTimePicker;
    procedure FormCreate(Sender: TObject);
  private
  public
  end;

var
  dlgImportPeriod: TdlgImportPeriod;

implementation

{$R *.DFM}

procedure TdlgImportPeriod.FormCreate(Sender: TObject);
begin
  dtpStart.Date := SysUtils.Date;
  dtpEnd.Date := SysUtils.Date;
end;

end.
