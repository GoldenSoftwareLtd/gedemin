
{******************************************}
{                                          }
{             FastReport v2.53             }
{           Restrictions editor            }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FR_Restr;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TfrRestrictionsForm = class(TForm)
    GroupBox1: TGroupBox;
    CB1: TCheckBox;
    CB2: TCheckBox;
    Cb3: TCheckBox;
    CB4: TCheckBox;
    CB5: TCheckBox;
    CB6: TCheckBox;
    CB7: TCheckBox;
    Button1: TButton;
    Button2: TButton;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure Localize;
  public
    { Public declarations }
  end;


implementation

uses FR_Const, FR_Utils;

{$R *.DFM}


procedure TfrRestrictionsForm.Localize;
begin
  Caption := frLoadStr(frRes + 260);
  CB1.Caption := frLoadStr(frRes + 261);
  CB2.Caption := frLoadStr(frRes + 262);
  CB3.Caption := frLoadStr(frRes + 263);
  CB4.Caption := frLoadStr(frRes + 264);
  CB5.Caption := frLoadStr(frRes + 265);
  CB6.Caption := frLoadStr(frRes + 266);
  CB7.Caption := frLoadStr(frRes + 267);
  Button1.Caption := frLoadStr(SOk);
  Button2.Caption := frLoadStr(SCancel);
end;

procedure TfrRestrictionsForm.FormCreate(Sender: TObject);
begin
  Localize;
end;

end.
