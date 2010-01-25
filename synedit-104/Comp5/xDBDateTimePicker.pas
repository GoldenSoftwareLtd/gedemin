
{++

  Copyright (c) 1996-99 by Golden Software of Belarus

  Module

    xDateTimePicker.pas

  Abstract

    Advances Date Time Picker.

  Author

    Romanovski Denis (29-01-99)

  Contact address

  Revisions history

    Initial  29-01-99  Dennis  Initial version.

    Beta1    29-01-99  Dennis  Beta version. TDateTimePicker is a very bad thing.
                               It was very difficult to go through it.

    Beta1    16-02-99  Dennis  Buggs fixed.
--}

unit xDBDateTimePicker;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, CommCtrl, DB, DBCtrls;

type
  TxDBDateTimePicker = class(TDateTimePicker)
  private
    FDataLink: TFieldDataLink; // Упрощает связь с TField компонентой

    procedure DataChange(Sender: TObject);
    procedure UpdateData(Sender: TObject);

    procedure CMEnter(var Message: TCMEnter);
      message CM_ENTER;
    procedure CMExit(var Message: TCMExit);
      message CM_EXIT;
    procedure CMGetDataLink(var Message: TMessage);
      message CM_GETDATALINK;
    procedure WMCut(var Message: TMessage);
      message WM_CUT;
    procedure WMPaste(var Message: TMessage);
      message WM_PASTE;
    procedure CNNotify(var Message: TWMNotify);
      message CN_NOTIFY;
    procedure CMCANCELMODE(var Message: TMessage);
      message CM_CANCELMODE;  

    function GetField: TField;
    function GetDataField: string;
    function GetDataSource: TDataSource;

    procedure SetDataField(const Value: string);
    procedure SetDataSource(Value: TDataSource);

  protected
    procedure Change; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation);
      override;
    function EditCanModify: Boolean;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    property Field: TField read GetField;

  published
    // Поле для редактирование
    property DataField: string read GetDataField write SetDataField;
    // DataSource таблицы или запроса
    property DataSource: TDataSource read GetDataSource write SetDataSource;

  end;

implementation


{
  ***********************
  ***   Public Part   ***
  ***********************
}


{
  По созданию компоненты производим начальные установки.
}

constructor TxDBDateTimePicker.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  // Создаем и устанавливаен начальные данные FieldDataLink
  FDataLink := TFieldDataLink.Create;
  FDataLink.Control := Self;
  FDataLink.OnDataChange := DataChange;
  FDataLink.OnUpdateData := UpdateData;
end;

{
  В конце работы компоненты производим высвобождение памяти.
}

destructor TxDBDateTimePicker.Destroy;
begin
  FDataLink.Free;
  FDataLink := nil;

  inherited Destroy;
end;


{
  **************************
  ***   Protected Part   ***
  **************************
}


{
  По изменению в тексте производим изменения в данных базы
}

procedure TxDBDateTimePicker.Change;
begin
  FDataLink.Modified;
  inherited Change;
end;

{
  Во время передачи сообщений всем компонентам производим свои
  действия.
}

procedure TxDBDateTimePicker.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (FDataLink <> nil) and
    (AComponent = DataSource) then DataSource := nil;
end;

{
  Возвращает флаг о возможности редактирования
}

function TxDBDateTimePicker.EditCanModify: Boolean;
begin
  Result := FDataLink.Edit;
end;

{
  По нажатию определенных клавиш производим переход в режим
  редактирования данных
}

procedure TxDBDateTimePicker.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if (Key = VK_DELETE) or ((Key = VK_INSERT) and (ssShift in Shift)) then
    FDataLink.Edit;
end;

{
  По нажатию определенных клавиш производим переход в режим
  редактирования данных
}

procedure TxDBDateTimePicker.KeyPress(var Key: Char);
begin
  case Key of
    ^H, ^V, ^X, #32..#255:
    begin
      FDataLink.Edit;
    end;
    #27:
      begin
        FDataLink.Reset;
        Key := #0;
      end;
  end;
  if FDataLink.Editing then inherited KeyPress(Key);
end;

{
  ************************
  ***   Private Part   ***
  ************************
}

{
  По изменению данных производим свои установки
}

procedure TxDBDateTimePicker.DataChange(Sender: TObject);
begin
  if (FDataLink.Field <> nil) then
  begin
    if not FDataLink.Editing then
      if not FDataLink.Field.IsNull then
        Date := FDataLink.Field.AsDateTime
      else
        Date := Now;
  end;
end;

{
  По сохранению данных производим свои установки
}

procedure TxDBDateTimePicker.UpdateData(Sender: TObject);
begin
  if FDataLink.Field <> nil then FDataLink.Field.AsDateTime := Date;
end;

{
  Получение фокуса
}

procedure TxDBDateTimePicker.CMEnter(var Message: TCMEnter);
begin
  inherited;
  FDataLink.Edit;
end;

{
  Потеря Focus-а.
}

procedure TxDBDateTimePicker.CMExit(var Message: TCMExit);
begin
  try
    FDataLink.UpdateRecord;
  except
    SetFocus;
    raise;
  end;
  inherited;
end;

{
  По копиванию из ClipBoard производим переход в режим редактирования
}

procedure TxDBDateTimePicker.WMCut(var Message: TMessage);
begin
  FDataLink.Edit;
  inherited;
end;

{
  Передаем FDataLink по сообщению.
}

procedure TxDBDateTimePicker.CMGetDataLink(var Message: TMessage);
begin
  Message.Result := Integer(FDataLink);
end;

{
  По вырезанию в ClipBoard производим переход в режим редактирования
}

procedure TxDBDateTimePicker.WMPaste(var Message: TMessage);
begin
  FDataLink.Edit;
  inherited;
end;

procedure TxDBDateTimePicker.CNNotify(var Message: TWMNotify);
begin
  if ((Message.NMHdr^.Code = DTN_CLOSEUP) or
    (Message.NMHdr^.Code = DTN_DATETIMECHANGE)) and (FDataLink.Field <> nil) and not
    (FDataLink.DataSet.State in [dsEdit, dsInsert])
  then
    FDataLink.Edit;

  inherited;
end;

procedure TxDBDateTimePicker.CMCANCELMODE(var Message: TMessage);
begin
  inherited;
  SendMessage(Handle, WM_KILLFOCUS, 0, 0);
  SendMessage(Handle, WM_SETFOCUS, 0, 0);
end;

{
  Получаем поле.
}

function TxDBDateTimePicker.GetField: TField;
begin
  Result := FDataLink.Field;
end;

{
  Получаем имя текущего поля
}

function TxDBDateTimePicker.GetDataField: string;
begin
  Result := FDataLink.FieldName;
end;

{
  Получаем новый DataSource.
}

function TxDBDateTimePicker.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

{
  Указываем новое имя поля
}

procedure TxDBDateTimePicker.SetDataField(const Value: string);
begin
  FDataLink.FieldName := Value;
end;

{
  Устанавливаем новый DataSource.
}

procedure TxDBDateTimePicker.SetDataSource(Value: TDataSource);
begin
  FDataLink.DataSource := Value;
end;

end.

