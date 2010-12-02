
{******************************************}
{                                          }
{             FastReport v2.53             }
{           Insert Band dialog             }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FR_BTyp;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, FR_Class, FR_Const;

type
  TfrBandTypesForm = class(TForm)
    Button1: TButton;
    GB1: TGroupBox;
    Button2: TButton;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    procedure bClick(Sender: TObject);
  public
    { Public declarations }
    SelectedTyp: TfrBandType;
    IsSubreport: Boolean;
  end;


implementation

uses FR_Desgn, FR_Utils;

{$R *.DFM}

procedure TfrBandTypesForm.FormShow(Sender: TObject);
var
  b: TRadioButton;
  bt: Integer;
  First: Boolean;
  ItemMaxLen: Integer;

  function FindMaxLen: Integer;
  var
    i: Integer;
  begin
    Result := 0;
    for i := Ord(btReportTitle) to Ord(btNone) - 1 do
      if Canvas.TextWidth(frBandNames[i]) > Result then
        Result := Canvas.TextWidth(frBandNames[i]);
    Result := Result + 20;
  end;

begin
  First := True;
  ItemMaxLen := FindMaxLen;
  GB1.ClientWidth := ItemMaxLen * 2 + 12 * 2 + 30;
  ClientWidth := GB1.Width + GB1.Left * 2;
  Button1.Left := ClientWidth - Button1.Width - Button2.Width - 10;
  Button2.Left := ClientWidth - Button1.Width - 5;
  for bt := Ord(btReportTitle) to Ord(btNone) - 1 do
  begin
    b := TRadioButton.Create(GB1);
    b.Parent := GB1;
    if bt > 10 then
    begin
      b.Left := ItemMaxLen + 12 + 30;
      b.Top := (bt - 11) * 20 + 20;
    end
    else
    begin
      b.Left := 12;
      b.Top := bt * 20 + 20;
    end;
    b.Width := Canvas.TextWidth(frBandNames[bt]) + 20;
    b.Tag := bt;
    b.Caption := frBandNames[bt];
    b.OnClick := bClick;
    b.Enabled := (TfrBandType(bt) in [btMasterHeader..btSubDetailFooter,
      btGroupHeader, btGroupFooter, btChild]) or not frCheckBand(TfrBandType(bt));
    if IsSubreport and (TfrBandType(bt) in
      [btReportTitle, btReportSummary, btPageHeader, btPageFooter,
       btGroupHeader, btGroupFooter, btColumnHeader, btColumnFooter]) then
      b.Enabled := False;

    if b.Enabled and First then
    begin
      b.Checked := True;
      SelectedTyp := TfrBandType(bt);
      First := False;
    end;
  end;
  Caption := frLoadStr(frRes + 510);
  GB1.Caption := frLoadStr(frRes + 511);
  Button1.Caption := frLoadStr(SOk);
  Button2.Caption := frLoadStr(SCancel);
end;

procedure TfrBandTypesForm.bClick(Sender: TObject);
begin
  SelectedTyp := TfrBandType((Sender as TComponent).Tag);
end;

end.

