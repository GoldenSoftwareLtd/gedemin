
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


// Event для HyperLink    
type
  TOnHyperLink = procedure (Sender: TObject; Note: String;
    var Jump: Boolean) of object;

type
  TxHTML = class(TPanel)
  private
    FOnHyperLink: TOnHyperLink; // Event по нажатию на HyperLink
    FStartPath: String; // Главная страница
    FConnectedHTML: TxHTML; // Связанный xHTML
    HTMLControls: TExList; // Список control-ов
    History: TStringList; // Все пути, выбранные за период работы
    HistoryIndex: Integer; // Индекс в выбранных путях
    IsHistory: Boolean; // Является ли данный адрес историей

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
    HTML: THTML; // HTML ActiveX компонента

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

    // Текстовой control
    property TextControl[ControlName: String]: String read GetText write SetText;

    // Control выбора: CheckBox, RadioBox и др.
    property CheckControl[ControlName: String]: Boolean read GetCheck write SetCheck;

    // Выделенный элемент в ComboBox
    property ComboControlSelected[ControlName: String]: String read GetComboSelected write SetComboSelected;

  published
    // Event По нажатию HyperLink
    property OnHyperLink: TOnHyperLink read FOnHyperLink write FOnHyperLink;

    // Путь к начальной странице
    property StartPath: String read FStartPath write SetStartPath;
    // Связанный HTML
    property ConnectedHTML: TxHTML read FConnectedHTML write SetConnectedHTML;

  end;

implementation

// Подстановки в путь к HTML странице
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
  Делаем начальные установки
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
  Возвращает только имя файла
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
      // Отсекаем путь
      Result := Copy(S, I + 1, Length(S));

      // Отсекаем расширение
      P := Pos('.', Result);
      if P <> 0 then Result := Copy(Result, 1, P - 1);
      Break;
    end;
end;

{
  По запросу на открытие новой странички производим действия
  по вызову своего Event-а или позволяем ее открытие.
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

  // Если загружается стартовая страница то, не производим никаких действий
  if AnsiCompareText(GetName(FStartPath), S) <> 0 then
  begin
    // Вызываем Event по HyperLink
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

  // Добавляем в список выбранных путей
  if EnableDefault and not IsHistory then
  begin
    // Удаляем ненужные пути
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
  // Вызываем Event по HyperLink
  Jump := True;
  if Assigned(FOnHyperLink) then FOnHyperLink(Self, S, Jump);

  if ConnectedHTML = nil then
    EnableDefault := Jump
  else begin
    EnableDefault := False;
    if Jump then ConnectedHTML.StartPath := URL;
  end;

  // Добавляем в список выбранных путей
  if EnableDefault and not IsHistory then
  begin
    // Удаляем ненужные пути
    if HistoryIndex < History.Count - 1 then
      for I := HistoryIndex + 1 to History.Count - 1 do
        History.Delete(HistoryIndex + 1);

    History.Add(URL);
    HistoryIndex := History.Count - 1;
  end;

  IsHistory := False;
end;

{
  По окончанию приема данных производим считывание переменных
}

procedure TxHTML.DoOnEndRetrieval(Sender: TObject);
begin
  GetControls;
end;

{
  Устанавливает путь к начальной странице HTML
}

procedure TxHTML.SetStartPath(AStartPath: String);
begin
  FStartPath := AStartPath;
end;

{
  Получаем связанный HTML
}

procedure TxHTML.SetConnectedHTML(AConnectedHTML: TxHTML);
begin
  FConnectedHTML := AConnectedHTML;
end;

{
  Собираем все control-ы
}

procedure TxHTML.GetControls;
var
  ControlHandle: THandle;
  WinText, WinClass: array[0..250] of Char;
  I: Integer;
begin
  ControlHandle := 0;

  // Очищаем список control-ов
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
  Находит нужный control в списке
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
  После загрузки значений properties производим подстановку
  Event-ов
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
    HTML.OnDoRequestDoc := DoOnRequestDoc; // Установка Event-а
    HTML.OnEndRetrieval := DoOnEndRetrieval; // Установка Event-а
    HTML.OnDoRequestSubmit := DoOnRequestSubmit; // Установка Event-а
  end;
end;

{
  *********************
  **   Public Part   **
  *********************
}

{
  Производим начальные установки
}

constructor TxHTML.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  if not (csDesigning in ComponentState) then
  begin
    // Установки для HTML
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
  Высвобаждаем память
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
  Устанавливает текст в Edit control
}

procedure TxHTML.SetText(ControlName, Value: String);
var
  Temp: array[0..250] of Char;
begin
  StrPCopy(Temp, Value);
  SetWindowText(FindControl(ControlName), Temp);
end;

{
  Получает текст из contol-а
}

function TxHTML.GetText(ControlName: String): String;
var
  Temp: array[0..250] of Char;
begin
  GetWindowText(FindControl(ControlName), Temp, SizeOf(Temp));
  Result := StrPas(Temp);
end;

{
  Устанавливает CHECKED для TCheckButton, TRadioButton
}

procedure TxHTML.SetCheck(ControlName: String; Checked: Boolean);
begin
  if Checked then
    SendMessage(FindControl(ControlName), BM_SETCHECK, BST_CHECKED, 0)
  else
    SendMessage(FindControl(ControlName), BM_SETCHECK, BST_UNCHECKED, 0);
end;

{
  Возвращает флаг CHECKED для TCheckBotton, TRadioButton
}

function TxHTML.GetCheck(ControlName: String): Boolean;
begin
  Result := SendMessage(FindControl(ControlName), BM_GETCHECK, 0, 0) = BST_CHECKED;	
end;

{
  Добавляет элемент в ComboBox
}

procedure TxHTML.AddComboItem(ControlName: String; Item: String; Index: Integer);
var
  Temp: array[0..250] of Char;
begin
  StrPCopy(Temp, Item);
  SendMessage(FindControl(ControlName), CB_INSERTSTRING, Index, LongInt(@Temp));
end;

{
  Удаляет элемент из ComboBox
}

procedure TxHTML.DeleteComboItem(ControlName: String; Index: Integer);
begin
  SendMessage(FindControl(ControlName), CB_DELETESTRING, Index, 0);
end;

{
  Выделяет позицию в ComboBox
}

procedure TxHTML.SelectComboItem(ControlName: String; Index: Integer);
begin
  SendMessage(FindControl(ControlName), CB_SETCURSEL, Index, 0);
end;

{
  Убирает все элементы из ComboBox-а
}

procedure TxHTML.ClearCombo(ControlName: String);
begin
  SendMessage(FindControl(ControlName), CB_RESETCONTENT, 0, 0);
end;

{
  Ищет строку и делает ее текущей
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
  Получает строку, выбранную в данный момент в ComboBox-е
}

function TxHTML.GetComboSelected(ControlName: String): String;
var
  Temp: array[0..250] of Char;
begin
  GetWindowText(FindControl(ControlName), Temp, SizeOf(Temp));
  Result := StrPas(Temp);
end;

{
  Получает индекс выбранной в данный момент строки
}

function TxHTML.GetComboSelectedIndex(ControlName: String): Integer;
begin
  Result := SendMessage(FindControl(ControlName), CB_GETCURSEL, 0, 0);
end;

{
  Передвигаемся вперед по выбранным путям
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
  Передвигаемся назад по выбранным путям
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
  Можно ли идти вперед по выбранным путям
}

function TxHTML.CanGoForward: Boolean;
begin
  Result := HistoryIndex < History.Count - 1;
end;

{
  Можно ли идти назад по выбранным путям
}

function TxHTML.CanGoBackward: Boolean;
begin
  Result := HistoryIndex > 0;
end;

{
  Установить начальную страницу
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

