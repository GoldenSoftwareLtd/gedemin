
unit dlgRecordFetch_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TdlgRecordFetch = class(TForm)
    btnCancel: TButton;
    lblCount: TLabel;
    Label1: TLabel;
    procedure btnCancelClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

  private
    FCanceled: Boolean;

  public
    property Canceled: Boolean read FCanceled write FCanceled;
  end;

var
  dlgRecordFetch: TdlgRecordFetch;

implementation

{$R *.DFM}

procedure TdlgRecordFetch.btnCancelClick(Sender: TObject);
begin
  FCanceled := True;
end;

procedure TdlgRecordFetch.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  FCanceled := True;
end;

end.
