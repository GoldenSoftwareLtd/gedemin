unit gedemin_cc_frmMain_unit;

interface

uses
  Classes, Controls, Forms, SysUtils, FileCtrl, StdCtrls, Windows,
  Menus, ExtCtrls, ComCtrls, Grids, DBGrids, Db, DBCtrls, Messages,
  gedemin_cc_const, Buttons, Dialogs, Graphics, SyncObjs, Gauges, xProgr;

const
  SizeArr = 12;

  StrArr: array[0..SizeArr] of String = (
    'Дата и время',
    'ИП платформы',
    'ИП ОС',
    'Путь к БД',
    'Имя хоста',
    'IP-адрес хоста',
    'Класс объекта',
    'Подтип объекта',
    'Имя объекта',
    'ID объекта',
    'ID операции',
    'Хэш запроса',
    'Сообщение'
  );

type
  Tfrm_gedemin_cc_main = class(TForm)
    pnlTop: TPanel;
    pnlLeft: TPanel;
    pnlRight: TPanel;
    pnlBottom: TPanel;
    pnlCenter: TPanel;
    pnlFilt: TPanel;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    DBGr: TDBGrid;
    SB: TStatusBar;
    PopMenuLB: TPopupMenu;
    DoneClient: TMenuItem;
    lbClients: TListBox;
    mLog: TMemo;
    sbtnLeft: TSpeedButton;
    sbtnRight: TSpeedButton;
    SaveLog1: TMenuItem;
    N1: TMenuItem;
    Exit1: TMenuItem;
    OpenLog1: TMenuItem;
    btnDoneAll: TButton;
    PB: TProgressBar;

    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure lbClientsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DoneClientClick(Sender: TObject);
    procedure sbtnLeftClick(Sender: TObject);
    procedure sbtnRightClick(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure SaveLog1Click(Sender: TObject);
    procedure OpenLog1Click(Sender: TObject);
    procedure DBGrDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure btnDoneAllClick(Sender: TObject);

  private
    FCurrStr: String;
    FCriticalSection: TCriticalSection;

    procedure WMLBRef(var Msg: TMessage);
      message WM_CC_REFRESH_LB;

    procedure WMMemoRef(var Msg: TMessage);
      message WM_CC_REFRESH_MEMO;

    procedure WMGridRef(var Msg: TMessage);
      message WM_CC_REFRESH_GRID;
  end;

var
  frm_gedemin_cc_main: Tfrm_gedemin_cc_main;
  WArr: array of Integer;

implementation

uses
  gedemin_cc_DataModule_unit, gedemin_cc_TCPServer_unit;

{$R *.DFM}

procedure Tfrm_gedemin_cc_main.FormCreate(Sender: TObject);
begin
  FCriticalSection := TCriticalSection.Create;
  SB.Panels[0].Text := DM.IBDB.DatabaseName;
  ccTCPServer.RefGrHandle := Self.Handle;
  ccTCPServer.RefMemoHandle := Self.Handle;
  ccTCPServer.RefLBHandle := Self.Handle;
  ccTCPServer.Update;
end;

procedure Tfrm_gedemin_cc_main.FormClose(Sender: TObject;
  var Action: TCloseAction);
var
  i, c : Integer;
begin
  ccTCPServer.RefLBHandle := 0;
  ccTCPServer.RefMemoHandle := 0;
  ccTCPServer.RefGrHandle := 0;
  c := lbClients.Items.Count;
  if c > 0 then
  begin
    for i := 0 to c - 1 do
      Dispose(TClientP(lbClients.Items.Objects[i]));
  end;
  FCriticalSection.Free;
end;

procedure Tfrm_gedemin_cc_main.WMLBRef(var Msg: TMessage);
var
  i: Integer;
  ClientP: TClientP;
begin
  try
    with ccTCPServer.FClients.LockList do
    begin
      lbClients.Clear;
      if Count > 0 then
      begin
        for i := 0 to Count - 1 do
        begin
          ClientP := TClientP(Items[i]);
          lbClients.Items.AddObject(ClientP.Host, TObject(ClientP));
        end;
      end;
    end;
  finally
    ccTCPServer.FClients.UnlockList;
  end;
end;

procedure Tfrm_gedemin_cc_main.WMMemoRef(var Msg: TMessage);
begin
  FCurrStr := PChar(Msg.LParam);
  mLog.Lines.Add(FCurrStr);
end;

procedure Tfrm_gedemin_cc_main.WMGridRef(var Msg: TMessage);
var
  i, cf, cc, FWidth, CWidth: Integer;
begin
  DBGr.Refresh;
  for i := 0 to SizeArr do
  begin
    DBGr.Columns[i].Title.Caption := StrArr[i];
  end;
  FWidth := 0;
  if DM.IBQ.RecordCount > 0 then
  begin
    cf := DBGr.FieldCount;
    cc := DBGr.Columns.Count;
    if (not Assigned(WArr)) then
    begin
      SetLength(WArr, cf);
      for i := 0 to cf - 1 do
        WArr[i] := 0;
    end;
    for i := 0 to cf - 1 do
    begin
      if (WArr[i] < Length(DBGr.Fields[i].Value)) then
      begin
        WArr[i] := Length(DBGr.Fields[i].Value);
      end;
      DBGr.Fields[i].DisplayWidth := WArr[i];
    end;
    for i := 0 to cc - 1 do
      FWidth := FWidth + DBGr.Columns[i].Width;
    FWidth := FWidth + DBGr.FieldCount;
    CWidth := DBGr.ClientWidth - FWidth;
    if CWidth > 0 then
      DBGr.Columns[cc - 1].Width := DBGr.Columns[cc - 1].Width + CWidth;
  end;
  DBGr.SetFocus;
end;

procedure Tfrm_gedemin_cc_main.lbClientsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  pos: TPoint;
  i: Integer;
begin
  if (Button = mbRight) then
  begin
    pos.X := X;
    pos.Y := Y;
    i := lbClients.ItemAtPos(pos, true);
    if i >= 0 then
    begin
      lbClients.ItemIndex := i;
      lbClients.PopupMenu.AutoPopup := True;
    end
    else
      lbClients.PopupMenu.AutoPopup := False;
  end;
end;

procedure Tfrm_gedemin_cc_main.DoneClientClick(Sender: TObject);
var
  i, id: Integer;
  ClientP: TClientP;
begin
  i := lbClients.ItemIndex;
  ClientP := TClientP(lbClients.Items.Objects[i]);
  id := ClientP.ID;
  mLog.Lines.Add(IntToStr(id));
  FCriticalSection.Enter;
  try
    ccTCPServer.FDone := true;
    ccTCPServer.FID := ClientP.ID;
  finally
    FCriticalSection.Leave;
  end;
  {if FindWindow('TfrmGedeminMain', nil) <> 0 then
    PostMessage(FindWindow('TfrmGedeminMain', nil), WM_QUIT, 0, 0);}
end;

procedure Tfrm_gedemin_cc_main.sbtnLeftClick(Sender: TObject);
begin
  if sbtnLeft.Caption = '<' then
  begin
    sbtnLeft.Caption := '>';
    pnlLeft.Width := 15;
    pnlFilt.Left := 15;
    pnlFilt.Width := pnlFilt.Width + 195;
    pnlCenter.Left := 15;
    pnlCenter.Width := pnlCenter.Width + 195;
  end
  else
  begin
    sbtnLeft.Caption := '<';
    pnlLeft.Width := 210;
    pnlFilt.Left := 210;
    pnlFilt.Width := pnlFilt.Width - 195;
    pnlCenter.Left := 210;
    pnlCenter.Width := pnlCenter.Width - 195;
  end;
end;

procedure Tfrm_gedemin_cc_main.sbtnRightClick(Sender: TObject);
begin
  if sbtnRight.Caption = '>' then
  begin
    sbtnRight.Caption := '<';
    pnlRight.Width := 15;
    pnlFilt.Width := pnlFilt.Width + 195;
    pnlCenter.Width := pnlCenter.Width + 195;
  end
  else
  begin
    sbtnRight.Caption := '>';
    pnlRight.Width := 210;
    pnlFilt.Width := pnlFilt.Width - 195;
    pnlCenter.Width := pnlCenter.Width - 195;
  end;
end;

procedure Tfrm_gedemin_cc_main.Exit1Click(Sender: TObject);
begin
  frm_gedemin_cc_main.Close;
end;

procedure Tfrm_gedemin_cc_main.SaveLog1Click(Sender: TObject);
var
  i: Integer;
  str: String;
  SL: TStrings;
  SD: TSaveDialog;
begin
  SL := TStringList.Create;
  try
    if not DBGr.DataSource.DataSet.Active then
      exit;
    DBGr.DataSource.DataSet.First;
    while not DBGr.DataSource.DataSet.Eof do
    begin
      str := '';
      for i := 0 to DBGr.FieldCount - 1 do
      begin
        str := str + DBGr.Fields[i].AsString + ' || ';
      end;
      SL.Add(str);
      DBGr.DataSource.DataSet.Next;
    end;
    SD := TSaveDialog.Create(Self);
    try
      SD.Title := 'Сохранение лога в файл ';
      SD.DefaultExt := 'txt';
      SD.Filter := 'Текстовые файлы (*.txt)|*.txt|Все файлы (*.*)|*.*';
      SD.FileName := 'log.txt';
      SD.Options := [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofNoReadOnlyReturn, ofEnableSizing];
      if SD.Execute then
        SL.SaveToFile(SD.FileName);
    finally
      SD.Free;
    end;
  finally
    SL.Free;
  end;
end;

procedure Tfrm_gedemin_cc_main.OpenLog1Click(Sender: TObject);
var
  OD: TOpenDialog;
begin
  OD := TOpenDialog.Create(Self);
  try
    OD.Title := 'Открытие лога из файла ';
    OD.DefaultExt := 'txt';
    OD.Filter := 'Текстовые файлы (*.txt)|*.txt|Все файлы (*.*)|*.*';
    OD.Options := [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofNoReadOnlyReturn, ofEnableSizing];
    if OD.Execute then
      mLog.Lines.LoadFromFile(OD.FileName);
  finally
    OD.Free;
  end;
end;

procedure Tfrm_gedemin_cc_main.DBGrDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn;
  State: TGridDrawState);
const
  Black: TColor = $000000;
  RowColors: array[Boolean] of TColor = ($E7E7E7, $FFFFFF);
var
  OddRow: Boolean;
  NewRect : TRect;
  PrevColor: TColor;
begin
  if (Sender is TDBGrid) then
  begin
    NewRect := Rect;
    NewRect.Left := NewRect.Left - 1;
    PrevColor := DBGr.Canvas.Brush.Color;
    DBGr.TitleFont.Style := [fsBold];
    DBGr.Canvas.Brush.Color := Black;
    DBGr.Canvas.FrameRect(NewRect);
    DBGr.Canvas.Brush.Color := PrevColor;
    DBGr.Options := [dgEditing,dgTitles,dgColumnResize,dgColLines,dgTabs,dgConfirmDelete,dgCancelOnExit];
    OddRow := Odd(TDBGrid(Sender).DataSource.DataSet.RecNo);
    TDBGrid(Sender).Canvas.Brush.Color := RowColors[OddRow];
    TDBGrid(Sender).Canvas.Font.Color := Black;
    TDBGrid(Sender).DefaultDrawColumnCell(Rect, DataCol, Column, State);
  end;
end;

procedure Tfrm_gedemin_cc_main.btnDoneAllClick(Sender: TObject);
begin
  FCriticalSection.Enter;
  try
    ccTCPServer.FDoneAll := true;
  finally
    FCriticalSection.Leave;
  end;
end;

end.
