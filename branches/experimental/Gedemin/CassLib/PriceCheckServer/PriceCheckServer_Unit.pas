unit PriceCheckServer_Unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, IBDatabase, DB,
  PriceDrv_TLB, IBCustomDataSet, IBQuery, IBSQL, IniFiles, ShellApi,
  ActnList, Menus, ImgList, Buttons;

type
  TFormMain = class(TForm)
    IBDB: TIBDatabase;
    Transaction: TIBTransaction;
    IBQuery: TIBSQL;
    Popup: TPopupMenu;
    ActionList: TActionList;
    actRestore: TAction;
    actClose: TAction;
    btnRestore: TMenuItem;
    btnClose: TMenuItem;
    ImageList: TImageList;
    actSelectDatabase: TAction;
    gbDataBase: TGroupBox;
    edDB: TEdit;
    spbSelectDB: TSpeedButton;
    gbPriceChecker: TGroupBox;
    edBarCode: TEdit;
    MemoInfo: TMemo;
    spbProperties: TSpeedButton;
    actDriverProperties: TAction;
    actConnect: TAction;
    spbConnect: TSpeedButton;
    actDriverReconnect: TAction;
    spbReconnect: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnOpenClick(Sender: TObject);
    procedure actRestoreExecute(Sender: TObject);
    procedure actCloseExecute(Sender: TObject);
    procedure actSelectDatabaseExecute(Sender: TObject);
    procedure actDriverPropertiesExecute(Sender: TObject);
    procedure actConnectExecute(Sender: TObject);
    procedure actDriverReconnectExecute(Sender: TObject);
  private
    FDriver: TPriceChecker;

    procedure DataEvent(Sender: TObject; const Data: WideString; SenderID: Integer);
    procedure LoadDBName;
    procedure SaveDBName;
    function Connect: boolean;
    procedure ActionIcon(Act: Integer; Icon: TIcon);
    property Driver: TPriceChecker read FDriver;
  protected
    procedure WindowMessage(var Msg: TMessage); message WM_SYSCOMMAND;
    procedure OnMinimizeProc(Sender:TObject);
    procedure MouseClick(var Msg: TMessage); message WM_USER + 1;
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

//ловит ШК от Price Checker'a
procedure TFormMain.DataEvent(Sender: TObject; const Data: WideString;
  SenderID: Integer);
  
  function GetBarcode(const Data: string): string;
  var
    i: Integer;
  begin
    Result := '';
    for i := 1 to Length(Data) do
    begin
      if Ord(Data[i]) >= $20 then Result := Result + Data[i]
      else Break;
    end;
  end;
var
  Barcode: string;
begin
  Driver.SenderID := SenderID;
  Barcode := GetBarcode(Data);

  edBarCode.Text := Barcode;
  MemoInfo.Clear;

  if not Transaction.InTransaction then Connect;
  IBQuery.Close;
  IBQuery.ParamByName('BARCODE').AsString := Barcode;
  IBQuery.ExecQuery;
  if not IBQuery.Eof then
  begin
    Driver.Line1 := IBQuery.FieldByName('NAME').AsString;
    Driver.Line2 := IBQuery.FieldByName('PRICE').AsString;
    while not IBQuery.Eof do
    begin
      MemoInfo.Lines.Add(IBQuery.FieldByName('NAME').AsString);
      MemoInfo.Lines.Add(IBQuery.FieldByName('PRICE').AsString);
      MemoInfo.Lines.Add('');
      IBQuery.Next;
    end;

  end
  else
  begin
    Driver.Line1 := 'не найден';
    Driver.Line2 := '';
  end;
  IBQuery.Close;
  Driver.SendAnswer;
end;


procedure TFormMain.FormCreate(Sender: TObject);
begin
  FDriver := TPriceChecker.Create(Self);
  FDriver.OnDataEvent := DataEvent;
  edBarCode.Text := '';
  MemoInfo.Clear;
  Driver.OpenServer;
  LoadDBName;
  //actConnect.Enabled := (not Connect);
  Connect;
  Application.OnMinimize := OnMinimizeProc;
end;

procedure TFormMain.SaveDBName;
var IniFile: TIniFile;
begin
  IniFile := TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini'));
  try
    IniFile.WriteString('Params', 'DB', edDB.Text);
  finally
    IniFile.Free;
  end;
end;

procedure TFormMain.LoadDBName;
var IniFile: TIniFile;
begin
  IniFile := TIniFile.Create(ChangeFileExt(ParamStr(0), '.ini'));
  try
    edDB.Text := IniFile.ReadString('Params', 'DB', '');
  finally
    IniFile.Free;
  end;
end;


procedure TFormMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Transaction.InTransaction then Transaction.Rollback;
  SaveDBName;
end;

procedure TFormMain.btnOpenClick(Sender: TObject);

begin
end;

// подключиться к БД
function TFormMain.Connect: boolean;
var M: string;
begin
  if Transaction.InTransaction then Transaction.Rollback;
  IBDB.Close;
  IBDB.DatabaseName := edDB.Text;
  try
    IBDB.Open;
    Transaction.StartTransaction;
  except
    on E: Exception do
    begin
      M := 'Ошибка подключения к БД: ' + #13 + E.Message;
      Application.MessageBox(PChar(M), 'Внимание',
        4096 {SystemModal} + MB_ICONERROR);
    end
  end;
  Result := Transaction.InTransaction;
end;


//Act - действие которое нужно выполнить
//Icon - иконка, которую нужно загрузить
procedure TFormMain.ActionIcon(Act: Integer; Icon: TIcon);
var Nim: TNotifyIconData;
begin
  with Nim do // Заполняем структуру Nim….
  begin
    cbSize := SizeOf(Nim); // Размер
    Wnd := Self.Handle; // Хендл нашего приложения(окна)
    uID := 1;
    uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP;
    hicon := Icon.Handle; // Хендл передаваемой в процедуру иконки
    uCallbackMessage := wm_user + 1;
    szTip := 'Сервер инфокиоска';//Сообщение появляющееся при наведении
  end;
  case Act of // Действия выполняемые процедурой
    1: Shell_NotifyIcon(Nim_Add, @Nim); // добавить иконку в трей
    2: Shell_NotifyIcon(Nim_Delete, @Nim); // удалить из трея
    3: Shell_NotifyIcon(Nim_Modify, @Nim);
  end;
end;

//перекрыть сообщения о свёртывании\закрытии окна
procedure TFormMain.WindowMessage(var Msg: TMessage);
begin
  // если в главном окне нажать Закрыть, Свернуть
  if (Msg.WParam = SC_MINIMIZE) or (Msg.WParam = SC_CLOSE) then
  begin
    ActionIcon(1, Application.Icon); // Добавляем значок в трей
    ShowWindow(Handle, SW_HIDE); // Скрываем программу
    ShowWindow(Application.Handle, SW_HIDE); // Скрываем кнопку с TaskBar'а
  end
  else
    inherited;
end;
// сообщение о минимизации
procedure TFormMain.OnMinimizeProc(Sender:TObject);
begin
  PostMessage(Handle, WM_SYSCOMMAND, SC_MINIMIZE, 0);
end;

procedure TFormMain.MouseClick(var Msg:TMessage);
var p: TPoint;
begin
  GetCursorPos(p); // Запоминаем координаты курсора мыши(
  case Msg.LParam of // Проверяем какая кнопка была нажата
    //по одинарному или двойному щелчку
    //левой кнопки мыши на значке в трее:
    // восстановить окно
    WM_LBUTTONUP, WM_LBUTTONDBLCLK:
    begin

      ActionIcon (2, Application.Icon); // Удаляем значок из трея
      ShowWindow(Application.Handle, SW_SHOW); // Восстанавливаем кнопку программы
      ShowWindow(Handle, SW_SHOW); // Восстанавливаем окно программы
    end;
    // по щелчку правой кнопкой: вызвать выпадающее меню  
    WM_RBUTTONUP:
    begin
      SetForegroundWindow(Handle); // Восстанавливаем программу в качестве переднего окна
      Popup.Popup(p.X,p.Y); // Заставляем всплыть TPopUp
      PostMessage(Handle,WM_NULL,0,0);
    end;
  end;
end;


procedure TFormMain.actRestoreExecute(Sender: TObject);
begin
  // восстановить окно
  ActionIcon (2, Application.Icon); // Удаляем значок из трея
  ShowWindow(Application.Handle, SW_SHOW); // Восстанавливаем кнопку программы
  ShowWindow(Handle, SW_SHOW); // Восстанавливаем окно программы
end;

procedure TFormMain.actCloseExecute(Sender: TObject);
begin
  if Application.MessageBox('Выйти из программы?', 'Внимание',
     4096 {SystemModal} + 4 {YesNo} + MB_ICONWARNING + MB_DEFBUTTON2 {активно "Нет"}) = 6 {Yes} then
    Close;
end;

procedure TFormMain.actSelectDatabaseExecute(Sender: TObject);
var Dialog: TOpenDialog;
begin
  Dialog := TOpenDialog.Create(Self);
  if Dialog.Execute then
  begin
    edDB.Text := Dialog.FileName;
    SaveDBName;
    if Transaction.InTransaction then Transaction.Rollback;
  end
end;

procedure TFormMain.actDriverPropertiesExecute(Sender: TObject);
begin
  Driver.ShowProperties;
end;

procedure TFormMain.actConnectExecute(Sender: TObject);
begin
  if Connect then
    Application.MessageBox('Подключение установлено!', 'Внимание',
     4096 {SystemModal} + MB_ICONINFORMATION);
end;

procedure TFormMain.actDriverReconnectExecute(Sender: TObject);
begin
  Driver.OpenServer;
end;

end.
