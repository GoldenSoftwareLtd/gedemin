
unit gd_localization_stub;

interface

uses
  Windows, Dialogs;

function MessageBox(hWnd: HWND; lpText, lpCaption: PChar; uType: UINT): Integer;
function MessageDlg(const Msg: string; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons; HelpCtx: Longint): Word;
procedure ShowMessage(const Msg: String);

implementation

uses
  gd_localization;

function MessageBox(hWnd: HWND; lpText, lpCaption: PChar; uType: UINT): Integer;
begin
  Result := Windows.MessageBox(hWnd,
    PChar(Translate(lpText, nil, True)),
    PChar(Translate(lpCaption, nil, True)),
    uType);
end;

function MessageDlg(const Msg: string; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons; HelpCtx: Longint): Word;
begin
  Result := Dialogs.MessageDlg(Translate(Msg, nil, True), DlgType, Buttons, HelpCtx);
end;

procedure ShowMessage(const Msg: String);
begin
  Dialogs.ShowMessage(Translate(Msg, nil, True));
end;

end.
