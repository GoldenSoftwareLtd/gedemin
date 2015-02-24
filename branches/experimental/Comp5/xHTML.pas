
{++

  Copyright (c) 1998 by Golden Software of Belarus

  Module

    xHTML.pas

  Abstract
    Windows HTML-view window. Not descendant from THTML ActiveX component because of full
    destruction of work! So it is descendant from TPanel.
    Allows processing of user actions by pressing HTML HyperLinks and other abilities.

  Author

    Romanovski Denis (06-08-98)

  Revisions history

    Initial  06-08-98  Dennis  Initial version.

    beta1    07-08-98  Dennis  Beta1. HyperLinks are working. Data can be received from
                               HTML page. Connection between two xHTML components
                               is possible.

    beta2    08-08-98  Dennis  Beta2. Data can be received and put into the html page.
                               Buttons and image buttons are also working!!!

    beta3    12-08-98  Dennis  Beta3. Backward and forward moving included.
    
--}

unit xHTML;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OleCtrls, NMHTML, ExtCtrls, ExList;


// Event ��� HyperLink    
type
  TOnHyperLink = procedure (Sender: TObject; Note: String;
    var Jump: Boolean) of object;

type
  TxHTML = class(TPanel)
  private
    FOnHyperLink: TOnHyperLink; // Event �� ������� �� HyperLink
    FStartPath: String; // ������� ��������
    FConnectedHTML: TxHTML; // ��������� xHTML
    HTMLControls: TExList; // ������ control-��
    History: TStringList; // ��� ����, ��������� �� ������ ������
    HistoryIndex: Integer; // ������ � ��������� �����
    IsHistory: Boolean; // �������� �� ������ ����� ��������

    function GetName(S: String): String;

    procedure DoOnRequestDoc(Sender: TObject; const URL: WideString;
      Element: HTMLElement; DocInput: DocInput;
      var EnableDefault: WordBool);

    procedure DoOnRequestSubmit(Sender: TObject;
      const URL: WideString; Form: HTMLForm; DocOutput: DocOutput;
      var EnableDefault: WordBool);

    procedure DoOnEndRetrieval(Sender: TObject);

    procedure SetStartPath(AStartPath: String);
    procedure SetConnectedHTML(AConnectedHTML: TxHTML);

    procedure GetControls;
    function FindControl(ControlName: String): THandle;

  protected
    procedure Loaded; override;

  public
    HTML: THTML; // HTML ActiveX ����������

    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure Start;

    procedure SetText(ControlName, Value: String);
    function GetText(ControlName: String): String;

    procedure SetCheck(ControlName: String; Checked: Boolean);
    function GetCheck(ControlName: String): Boolean;

    procedure AddComboItem(ControlName: String; Item: String; Index: Integer);
    procedure DeleteComboItem(ControlName: String; Index: Integer);
    procedure SelectComboItem(ControlName: String; Index: Integer);
    procedure ClearCombo(ControlName: String);
    procedure SetComboSelected(ControlName, Item: String);

    function GetComboSelected(ControlName: String): String;
    function GetComboSelectedIndex(ControlName: String): Integer;

    procedure GoForward;
    procedure GoBackward;

    function CanGoForward: Boolean;
    function CanGoBackward: Boolean;

    // ��������� control
    property TextControl[ControlName: String]: String read GetText write SetText;

    // Control ������: CheckBox, RadioBox � ��.
    property CheckControl[ControlName: String]: Boolean read GetCheck write SetCheck;

    // ���������� ������� � ComboBox
    property ComboControlSelected[ControlName: String]: String read GetComboSelected write SetComboSelected;

  published
    // Event �� ������� HyperLink
    property OnHyperLink: TOnHyperLink read FOnHyperLink write FOnHyperLink;

    // ���� � ��������� ��������
    property StartPath: String read FStartPath write SetStartPath;
    // ��������� HTML
    property ConnectedHTML: TxHTML read FConnectedHTML write SetConnectedHTML;

  end;

implementation

// ����������� � ���� � HTML ��������
const
  LeftPartStruct = 'file:';

type
  THTMLControl = class
  public
    HTMLControl: THandle;
    ControlName: String;
    constructor Create(AHTMLControl: THandle; AControlName: String);
  end;

{
  ------------------------------
  ---   THTMLControl Class   ---
  ------------------------------
}

{
  ������ ��������� ���������
}

constructor THTMLControl.Create(AHTMLControl: THandle; AControlName: String);
begin
  inherited Create;
  HTMLControl := AHTMLControl;
  ControlName := AControlName;
end;


{
  ------------------------
  ---   TxHTML Class   ---
  ------------------------
}


{
  **********************
  **   Private Part   **
  **********************
}

{
  ���������� ������ ��� �����
}

function TxHTML.GetName(S: String): String;
var
  I: Integer;
  P: Integer;
begin
  Result := '';

  for I := Length(S) downto 1 do
    if (S[I] in ['/', '\']) and (I <> Length(S)) then
    begin
      // �������� ����
      Result := Copy(S, I + 1, Length(S));

      // �������� ����������
      P := Pos('.', Result);
      if P <> 0 then Result := Copy(Result, 1, P - 1);
      Break;
    end;
end;

{
  �� ������� �� �������� ����� ��������� ���������� ��������
  �� ������ ������ Event-� ��� ��������� �� ��������.
}

procedure TxHTML.DoOnRequestDoc(Sender: TObject; const URL: WideString;
  Element: HTMLElement; DocInput: DocInput;
  var EnableDefault: WordBool);
var
  Jump: Boolean;
  S: String;
  I: Integer;
begin
  S := GetName(URL);

  // ���� ����������� ��������� �������� ��, �� ���������� ������� ��������
  if AnsiCompareText(GetName(FStartPath), S) <> 0 then
  begin
    // �������� Event �� HyperLink
    Jump := True;
    if Assigned(FOnHyperLink) then FOnHyperLink(Self, S, Jump);

    if ConnectedHTML = nil then
      EnableDefault := Jump
    else begin
      EnableDefault := False;
      if Jump then
      begin
        ConnectedHTML.StartPath := URL;
        ConnectedHTML.Start;
      end;
    end;
  end;

  // ��������� � ������ ��������� �����
  if EnableDefault and not IsHistory then
  begin
    // ������� �������� ����
    if HistoryIndex < History.Count - 1 then
      for I := HistoryIndex + 1 to History.Count - 1 do
        History.Delete(HistoryIndex + 1);

    History.Add(URL);
    HistoryIndex := History.Count - 1;
  end;

  IsHistory := False;
end;

procedure TxHTML.DoOnRequestSubmit(Sender: TObject;
  const URL: WideString; Form: HTMLForm; DocOutput: DocOutput;
  var EnableDefault: WordBool);
var
  S: String;
  Jump: Boolean;
  I: Integer;
begin
  S := GetName(URL);
  // �������� Event �� HyperLink
  Jump := True;
  if Assigned(FOnHyperLink) then FOnHyperLink(Self, S, Jump);

  if ConnectedHTML = nil then
    EnableDefault := Jump
  else begin
    EnableDefault := False;
    if Jump then ConnectedHTML.StartPath := URL;
  end;

  // ��������� � ������ ��������� �����
  if EnableDefault and not IsHistory then
  begin
    // ������� �������� ����
    if HistoryIndex < History.Count - 1 then
      for I := HistoryIndex + 1 to History.Count - 1 do
        History.Delete(HistoryIndex + 1);

    History.Add(URL);
    HistoryIndex := History.Count - 1;
  end;

  IsHistory := False;
end;

{
  �� ��������� ������ ������ ���������� ���������� ����������
}

procedure TxHTML.DoOnEndRetrieval(Sender: TObject);
begin
  GetControls;
end;

{
  ������������� ���� � ��������� �������� HTML
}

procedure TxHTML.SetStartPath(AStartPath: String);
begin
  FStartPath := AStartPath;
end;

{
  �������� ��������� HTML
}

procedure TxHTML.SetConnectedHTML(AConnectedHTML: TxHTML);
begin
  FConnectedHTML := AConnectedHTML;
end;

{
  �������� ��� control-�
}

procedure TxHTML.GetControls;
var
  ControlHandle: THandle;
  WinText, WinClass: array[0..250] of Char;
  I: Integer;
begin
  ControlHandle := 0;

  // ������� ������ control-��
  for I := 0 to HTMLControls.Count - 1 do
    HTMLControls.DeleteAndFree(0);

  repeat

    if ControlHandle = 0 then
      ControlHandle := GetWindow(HTML.hWnd, GW_CHILD)
    else
      ControlHandle := GetWindow(ControlHandle, GW_HWNDNEXT);

    GetWindowText(ControlHandle, WinText, SizeOf(WinText));
    GetClassName(ControlHandle, WinClass, SizeOf(WinClass));

    if (ControlHandle <> 0) and ((StrPas(WinClass) = 'Edit') or
      (StrPas(WinClass) = 'Button') or (StrPas(WinClass) = 'ComboBox') or (StrPas(WinClass) = 'ListBox'))
    then
      HTMLControls.Add(THTMLControl.Create(ControlHandle, WinText));

  until ControlHandle = 0;
end;

{
  ������� ������ control � ������
}

function TxHTML.FindControl(ControlName: String): THandle;
var
  I: Integer;
begin
  Result := 0;

  for I := 0 to HTMLControls.Count - 1 do
    if AnsiCompareText(ControlName, THTMLControl(HTMLControls[I]).ControlName) = 0 then
    begin
      Result := THTMLControl(HTMLControls[I]).HTMLControl;
      Break;
    end;
end;

{
  ************************
  **   Protected Part   **
  ************************
}

{
  ����� �������� �������� properties ���������� �����������
  Event-��
}

procedure TxHTML.Loaded;
begin
  inherited Loaded;
  if not (csDesigning in ComponentState) then
  begin
    HTML.Left := 0;
    HTML.Top := 0;
    HTML.Width := ClientWidth;
    HTML.Height := ClientHeight;
    HTML.OnDoRequestDoc := DoOnRequestDoc; // ��������� Event-�
    HTML.OnEndRetrieval := DoOnEndRetrieval; // ��������� Event-�
    HTML.OnDoRequestSubmit := DoOnRequestSubmit; // ��������� Event-�
  end;
end;

{
  *********************
  **   Public Part   **
  *********************
}

{
  ���������� ��������� ���������
}

constructor TxHTML.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  if not (csDesigning in ComponentState) then
  begin
    // ��������� ��� HTML
    HTML := THTML.Create(Owner);
    HTML.Parent := Self;
    HTML.Align := alClient;

    HTML.FixedFont.Charset := RUSSIAN_CHARSET;
    HTML.Font.Charset := RUSSIAN_CHARSET;
    HTML.Heading1Font.Charset := RUSSIAN_CHARSET;
    HTML.Heading2Font.Charset := RUSSIAN_CHARSET;
    HTML.Heading3Font.Charset := RUSSIAN_CHARSET;
    HTML.Heading4Font.Charset := RUSSIAN_CHARSET;
    HTML.Heading5Font.Charset := RUSSIAN_CHARSET;
    HTML.Heading6Font.Charset := RUSSIAN_CHARSET;
  end;

  FOnHyperLink := nil;
  FStartPath := '';
  FConnectedHTML := nil;

  HTMLControls := TExList.Create;
  History := TStringList.Create;
  HistoryIndex := 0;
  IsHistory := False;
end;

{
  ������������ ������
}

destructor TxHTML.Destroy;
var
  I: Integer;
begin
  for I := 0 to HTMLControls.Count - 1 do
    HTMLControls.DeleteAndFree(0);

  HTMLControls.Free;
  History.Free;
  
  inherited Destroy;
end;

{
  ������������� ����� � Edit control
}

procedure TxHTML.SetText(ControlName, Value: String);
var
  Temp: array[0..250] of Char;
begin
  StrPCopy(Temp, Value);
  SetWindowText(FindControl(ControlName), Temp);
end;

{
  �������� ����� �� contol-�
}

function TxHTML.GetText(ControlName: String): String;
var
  Temp: array[0..250] of Char;
begin
  GetWindowText(FindControl(ControlName), Temp, SizeOf(Temp));
  Result := StrPas(Temp);
end;

{
  ������������� CHECKED ��� TCheckButton, TRadioButton
}

procedure TxHTML.SetCheck(ControlName: String; Checked: Boolean);
begin
  if Checked then
    SendMessage(FindControl(ControlName), BM_SETCHECK, BST_CHECKED, 0)
  else
    SendMessage(FindControl(ControlName), BM_SETCHECK, BST_UNCHECKED, 0);
end;

{
  ���������� ���� CHECKED ��� TCheckBotton, TRadioButton
}

function TxHTML.GetCheck(ControlName: String): Boolean;
begin
  Result := SendMessage(FindControl(ControlName), BM_GETCHECK, 0, 0) = BST_CHECKED;	
end;

{
  ��������� ������� � ComboBox
}

procedure TxHTML.AddComboItem(ControlName: String; Item: String; Index: Integer);
var
  Temp: array[0..250] of Char;
begin
  StrPCopy(Temp, Item);
  SendMessage(FindControl(ControlName), CB_INSERTSTRING, Index, LongInt(@Temp));
end;

{
  ������� ������� �� ComboBox
}

procedure TxHTML.DeleteComboItem(ControlName: String; Index: Integer);
begin
  SendMessage(FindControl(ControlName), CB_DELETESTRING, Index, 0);
end;

{
  �������� ������� � ComboBox
}

procedure TxHTML.SelectComboItem(ControlName: String; Index: Integer);
begin
  SendMessage(FindControl(ControlName), CB_SETCURSEL, Index, 0);
end;

{
  ������� ��� �������� �� ComboBox-�
}

procedure TxHTML.ClearCombo(ControlName: String);
begin
  SendMessage(FindControl(ControlName), CB_RESETCONTENT, 0, 0);
end;

{
  ���� ������ � ������ �� �������
}

procedure TxHTML.SetComboSelected(ControlName, Item: String);
var
  Temp: array[0..250] of Char;
  Count: Integer;
  I: Integer;
begin
  StrPCopy(Temp, Item);
  Count := SendMessage(FindControl(ControlName), CB_GETCOUNT, 0, 0);

  for I := 0 to Count - 1 do
  begin
    SendMessage(FindControl(ControlName), CB_GETLBTEXT, I, LongInt(@Temp));

    if AnsiCompareText(Item, StrPas(Temp)) = 0 then
    begin
      SendMessage(FindControl(ControlName), CB_SETCURSEL, I, 0);
      Break;
    end;
  end;
end;

{
  �������� ������, ��������� � ������ ������ � ComboBox-�
}

function TxHTML.GetComboSelected(ControlName: String): String;
var
  Temp: array[0..250] of Char;
begin
  GetWindowText(FindControl(ControlName), Temp, SizeOf(Temp));
  Result := StrPas(Temp);
end;

{
  �������� ������ ��������� � ������ ������ ������
}

function TxHTML.GetComboSelectedIndex(ControlName: String): Integer;
begin
  Result := SendMessage(FindControl(ControlName), CB_GETCURSEL, 0, 0);
end;

{
  ������������� ������ �� ��������� �����
}

procedure TxHTML.GoForward;
begin
  if HistoryIndex < History.Count - 1 then
  begin
    Inc(HistoryIndex);
    StartPath := History[HistoryIndex];
    IsHistory := True;
    Start;
  end;
end;

{
  ������������� ����� �� ��������� �����
}

procedure TxHTML.GoBackward;
begin
  if HistoryIndex > 0 then
  begin
    Dec(HistoryIndex);
    StartPath := History[HistoryIndex];
    IsHistory := True;
    Start;
  end;
end;

{
  ����� �� ���� ������ �� ��������� �����
}

function TxHTML.CanGoForward: Boolean;
begin
  Result := HistoryIndex < History.Count - 1;
end;

{
  ����� �� ���� ����� �� ��������� �����
}

function TxHTML.CanGoBackward: Boolean;
begin
  Result := HistoryIndex > 0;
end;

{
  ���������� ��������� ��������
}

procedure TxHTML.Start;
begin
  HTML.ViewSource := False;
  if Pos(LeftPartStruct, FStartPath) = 1 then
    HTML.RequestDoc(FStartPath)
  else
    HTML.RequestDoc(LeftPartStruct + FStartPath);
end;

end.

