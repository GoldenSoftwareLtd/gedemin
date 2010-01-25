unit FR_passw;

interface

uses
  Windows, Messages, SysUtils
{$IFDEF Delphi6}
, Variants
{$ENDIF},
  Classes, Graphics, Controls, Forms, Dialogs, StdCtrls;

type
  TfrPasswForm = class(TForm)
    OK: TButton;
    Cancel: TButton;
    E1: TEdit;
    L1: TLabel;
    L2: TLabel;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure Localize;
  public
    { Public declarations }
  end;

var
  frPasswForm: TfrPasswForm;

implementation

uses FR_Const, FR_Utils;
                      
{$R *.dfm}

procedure TfrPasswForm.FormShow(Sender: TObject);
begin
  E1.SetFocus;
end;

procedure TfrPasswForm.FormCreate(Sender: TObject);
begin
  Localize;
end;

procedure TfrPasswForm.Localize;
begin
  Caption := frLoadStr(frRes + 2653);
  L1.Caption := frLoadStr(frRes + 2654);
  L2.Caption := frLoadStr(frRes + 2655);
  OK.Caption := frLoadStr(SOK);
  Cancel.Caption := frLoadStr(SCancel);
end;


end.
