
{******************************************}
{                                          }
{             FastReport v2.53             }
{            Variables editor              }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FR_Vared;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, ComCtrls, FR_Class, FR_Pars;

type
  TfrVaredForm = class(TForm)
    Button4: TButton;
    Button5: TButton;
    Memo1: TMemo;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
  private
    { Private declarations }
    procedure Localize;
  public
    { Public declarations }
    Variables: TfrVariables;
  end;


implementation

uses FR_Const, FR_Utils;

{$R *.DFM}

procedure TfrVaredForm.FormShow(Sender: TObject);
var
  i: Integer;
  s: String;
begin
  for i := 0 to Variables.Count - 1 do
  begin
    s := Variables.Name[i];
    if s <> '' then
      if s[1] = ' ' then
        s := Copy(s, 2, 255) else
        s := ' ' + s;
    Memo1.Lines.Add(s);
  end;
end;

procedure TfrVaredForm.Localize;
begin
  Caption := frLoadStr(frRes + 360);
  Label1.Caption := frLoadStr(frRes + 361);
  Button4.Caption := frLoadStr(SOk);
  Button5.Caption := frLoadStr(SCancel);
end;

procedure TfrVaredForm.FormCreate(Sender: TObject);
begin
  Localize;
end;

procedure TfrVaredForm.FormHide(Sender: TObject);
var
  i: Integer;
  v: TfrVariables;
  s: String;
begin
  if ModalResult = mrOk then
  begin
    v := TfrVariables.Create;
    for i := 0 to Memo1.Lines.Count - 1 do
    begin
      s := Memo1.Lines[i];
      if Trim(s) <> '' then
      begin
        if s[1] = ' ' then
          s := Copy(s, 2, 255) else
          s := ' ' + s;
        if Variables.IndexOf(s) <> -1 then
          v[s] := Variables[s] else
          v[s] := '';
      end;
    end;
    Variables.Clear;
    for i := 0 to v.Count - 1 do
      Variables[v.Name[i]] := v.Value[i];
    v.Free;
  end;
end;

end.

