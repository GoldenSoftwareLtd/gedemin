
{++

  Copyright (c) 1999 by Golden Software of Belarus

  Module

    mmJumpController.pas

  Abstract

    A non visual component wich provides jump from dbgrid to
    any other edit control in edition area.   

  Author

    Romanovski Denis (01-02-99)

  Revisions history

    Initial  01-02-99  Dennis  Initial version.

    Beta1    02-02-99  Dennis  Beta Version. Everything works.

    Beta2    06-02-99  Dennis  Beta Version. Some bugs fixed.
--}

unit mmJumpController;

interface

uses
  Windows,          Messages,         SysUtils,         Classes,
  Graphics,         Controls,         Forms,            Dialogs,
  DBGrids,          mBitButton,       DB,               DBCtrls,
  ExList;

const
  DefNameAdd = 'Add';
  DefNameEdit = 'Edit';
  DefNameSave = 'Save';
  DefNameCancel = 'Cancel';

type
  TmmJumpController = class(TComponent)
  private
    FGridControl: TDBGrid; // Связываемая табличка
    FEditArea: TWinControl; // Связываемая область редактирования

    FNameAdd: String; // Содержимое кнопки добавить
    FNameEdit: String; // Срдержимое кнопки удалить
    FNameSave: String; // Содержимое кнопки сохранить
    FNameCancel: String; // Содержимое кнопки отменить

    FEventsList: TExList; // Список событий для каждого контрола редактирования

    // События, происходящие в связываемой таблице
    OldOnDblClickGrid, OldOnEnterGrid: TNotifyEvent;

    // Кнопки области редактирования соответственно:
    // добавить, удалить, сохранить, отменить
    FAdd, FEdit, FSave, FCancel: TmBitButton;

    // События, происходящие в области редактирвания, связанные с нажатием кнопок
    // соответственно: добавить, удалить, сохранить, отменить
    OldAddClick, OldEditClick, OldSaveClick, OldCancelClick: TNotifyEvent;

    procedure SetGridControl(const Value: TDBGrid);
    procedure SetEditArea(const Value: TWinControl);
    procedure SetNameAdd(const Value: String);
    procedure SetNameCancel(const Value: String);
    procedure SetNameEdit(const Value: String);
    procedure SetNameSave(const Value: String);

    procedure DoOnDblClickGrid(Sender: TObject);
    procedure DoOnEnterGrid(Sender: TObject);

    procedure DoOnAddClick(Sender: TObject);
    procedure DoOnEditClick(Sender: TObject);
    procedure DoOnSaveClick(Sender: TObject);
    procedure DoOnCancelClick(Sender: TObject);

    function FindEvent(C: TControl): TObject;

    procedure DoOnControlEnter(Sender: TObject);

    function FindAndSelectDBEdit(CheckArea: TWinControl; F: TField): Boolean;
  protected

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

  published
    // Таблица, связываемая с областью редактирвания
    property GridControl: TDBGrid read FGridControl write SetGridControl;
    // Область редактирования, связываемая с таблицей
    property EditArea: TWinControl read FEditArea write SetEditArea;
    // Содержимое названия кнопи добавить
    property NameAdd: String read FNameAdd write SetNameAdd;
    // Содержимое названия кнопи удалить
    property NameEdit: String read FNameEdit write SetNameEdit;
    // Содержимое названия кнопи сохранить
    property NameSave: String read FNameSave write SetNameSave;
    // Содержимое названия кнопи отменить
    property NameCancel: String read FNameCancel write SetNameCancel;
  end;

implementation

uses xCalculatorEdit, xDBDateTimePicker;

var
  IsComponentDestroying: Boolean = False;

// Производит сравнение классов и, если они совпадают, то получает оттуда поле.
function GetField(CheckObject: TObject): TField;
begin
  if CheckObject is TDBEdit then
    Result := (CheckObject as TDBEdit).Field
  else if CheckObject is TDBMemo then
    Result := (CheckObject as TDBMemo).Field
  else if CheckObject is TDBListBox then
    Result := (CheckObject as TDBListBox).Field
  else if CheckObject is TDBComboBox then
    Result := (CheckObject as TDBComboBox).Field
  else if CheckObject is TDBCheckBox then
    Result := (CheckObject as TDBCheckBox).Field
  else if CheckObject is TDBRadioGroup then
    Result := (CheckObject as TDBRadioGroup).Field
  else if CheckObject is TDBLookupListBox then
    Result := (CheckObject as TDBLookupListBox).Field
  else if CheckObject is TDBLookupComboBox then
    Result := (CheckObject as TDBLookupComboBox).Field
  else if CheckObject is TDBRichEdit then
    Result := (CheckObject as TDBRichEdit).Field
  else if CheckObject is TxDBCalculatorEdit then
    Result := (CheckObject as TxDBCalculatorEdit).Field
  else if CheckObject is TxDBDateTimePicker then
    Result := (CheckObject as TxDBDateTimePicker).Field
  else
    Result := nil;
end;

// Производит сравнение классов и, если они совпадают, то получает оттуда события
function PrepeareEvents(CheckObject: TObject; NewOnEnter: TNotifyEvent;
  var AOnEnter: TNotifyEvent): Boolean;
begin
  if CheckObject is TDBEdit then
  begin
    Result := True;
    AOnEnter := (CheckObject as TDBEdit).OnEnter;
    (CheckObject as TDBEdit).OnEnter := NewOnEnter;
  end else if CheckObject is TDBMemo then
  begin
    Result := True;
    AOnEnter := (CheckObject as TDBMemo).OnEnter;
    (CheckObject as TDBMemo).OnEnter := NewOnEnter;
  end else if CheckObject is TDBListBox then
  begin
    Result := True;
    AOnEnter := (CheckObject as TDBListBox).OnEnter;
    (CheckObject as TDBListBox).OnEnter := NewOnEnter;
  end else if CheckObject is TDBComboBox then
  begin
    Result := True;
    AOnEnter := (CheckObject as TDBComboBox).OnEnter;
    (CheckObject as TDBComboBox).OnEnter := NewOnEnter;
  end else if CheckObject is TDBCheckBox then
  begin
    Result := True;
    AOnEnter := (CheckObject as TDBCheckBox).OnEnter;
    (CheckObject as TDBCheckBox).OnEnter := NewOnEnter;
  end else if CheckObject is TDBRadioGroup then
  begin
    Result := True;
    AOnEnter := (CheckObject as TDBRadioGroup).OnEnter;
    (CheckObject as TDBRadioGroup).OnEnter := NewOnEnter;
  end else if CheckObject is TDBLookupListBox then
  begin
    Result := True;
    AOnEnter := (CheckObject as TDBLookupListBox).OnEnter;
    (CheckObject as TDBLookupListBox).OnEnter := NewOnEnter;
  end else if CheckObject is TDBLookupComboBox then
  begin
    Result := True;
    AOnEnter := (CheckObject as TDBLookupComboBox).OnEnter;
    (CheckObject as TDBLookupComboBox).OnEnter := NewOnEnter;
  end else if CheckObject is TDBRichEdit then
  begin
    Result := True;
    AOnEnter := (CheckObject as TDBRichEdit).OnEnter;
    (CheckObject as TDBRichEdit).OnEnter := NewOnEnter;
  end else if CheckObject is TxDBCalculatorEdit then
  begin
    Result := True;
    AOnEnter := (CheckObject as TxDBCalculatorEdit).OnEnter;
    (CheckObject as TxDBCalculatorEdit).OnEnter := NewOnEnter;
  end else if CheckObject is TxDBDateTimePicker then
  begin
    Result := True;
    AOnEnter := (CheckObject as TxDBDateTimePicker).OnEnter;
    (CheckObject as TxDBDateTimePicker).OnEnter := NewOnEnter;
  end else
    Result := False;
end;

type
  TEventItem = class
  public
    OldOnEnter: TNotifyEvent; // Сохраненные события пользователя
    C: TControl; // Контрол, из которого взяты события пользователя

    constructor Create(AC: TControl; NewOnEnter: TNotifyEvent);
    destructor Destroy; override;
  end;

{
  --------------------------------
  ----    TEventItem Class    ----
  --------------------------------
}

{
  ***********************
  ***   Public Part   ***
  ***********************
}

{
  Делаем первоначальные установки.
}

constructor TEventItem.Create(AC: TControl; NewOnEnter: TNotifyEvent);
begin
  OldOnEnter := nil;

  C := AC;

  PrepeareEvents(C, NewOnEnter, OldOnEnter);
end;

{
  Высвобождаем памятью
}

destructor TEventItem.Destroy;
var
  AOnEnter: TNotifyEvent;
begin
  if not IsComponentDestroying and Assigned(C) then
    PrepeareEvents(C, OldOnEnter, AOnEnter);

  OldOnEnter := nil;

  inherited Destroy;
end;

{
  ---------------------------------------
  ----    TmmJumpController Class    ----
  ---------------------------------------
}

{
  ***********************
  ***   Public Part   ***
  ***********************
}

{
  Делаем начальные установки и создаем компоненту.
}

constructor TmmJumpController.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  FGridControl := nil;
  FEditArea := nil;

  FNameAdd := DefNameAdd;
  FNameEdit := DefNameEdit;
  FNameSave := DefNameSave;
  FNameCancel := DefNameCancel;

  FAdd := nil;
  FEdit := nil;
  FSave := nil;
  FCancel := nil;

  OldOnDblClickGrid := nil;
  OldOnEnterGrid := nil;

  OldAddClick := nil;
  OldEditClick := nil;
  OldSaveClick := nil;
  OldCancelClick := nil;

  FEventsList := TExList.Create;
end;

{
  Высвобождаем память.
}

destructor TmmJumpController.Destroy;
begin
  IsComponentDestroying := True;
  FEventsList.Free;
  IsComponentDestroying := False;

  inherited Destroy;
end;

{
  **************************
  ***   Protected Part   ***
  **************************
}


{
  ************************
  ***   Private Part   ***
  ************************
}

{
  Устанавливает таблицу, связываемую с другими компонентами.
}

procedure TmmJumpController.SetGridControl(const Value: TDBGrid);
begin
  if FGridControl <> Value then
  begin
    // Только в рабочем режиме!
    if Assigned(FGridControl) and not (csDesigning in ComponentState) then
    begin
//      if Assigned(OldOnDblClickGrid) then FGridControl.OnDblClick := OldOnDblClickGrid;
//      if Assigned(OldOnEnterGrid) then FGridControl.OnEnter := OldOnEnterGrid;
      FGridControl.OnDblClick := OldOnDblClickGrid;
      FGridControl.OnEnter := OldOnEnterGrid;
    end;

    FGridControl := Value;

    // Только в рабочем режиме!
    if Assigned(FGridControl) and not (csDesigning in ComponentState) then
    begin
      OldOnDblClickGrid := FGridControl.OnDblClick;
      FGridControl.OnDblClick := DoOnDblClickGrid;

      OldOnEnterGrid := FGridControl.OnEnter;
      FGridControl.OnEnter := DoOnEnterGrid;
    end;
  end;
end;

{
  Устанавливает связываемую область редактирования.
}

procedure TmmJumpController.SetEditArea(const Value: TWinControl);
var
  I: Integer;

  // Производит поиск кнопки, содержащей следующую подстроку в названии
  function FindButton(BtnName: String): TmBitButton;
  var
    K: Integer;
  begin
    Result := nil;

    for K := 0 to FEditArea.ControlCount - 1 do
      if (FEditArea.Controls[K] is TmBitButton) and
        (Pos(BtnName, FEditArea.Controls[K].Name) > 0) then
      begin
        Result := FEditArea.Controls[K] as TmBitButton;
        Break;
      end;
  end;

  // Состваляет список событий контролов.
  procedure MakeEventsList(CheckArea: TWinControl);
  var
    K: Integer;
    C: TControl;
    F: TField;
  begin
    for K := 0 to CheckArea.ControlCount - 1 do
    begin
      C := CheckArea.Controls[K];
      F := GetField(C);

      // Если объект содержит поле
      if F <> nil then
        FEventsList.Add(TEventItem.Create(C, DoOnControlEnter))
      // Проверяем входящие в контрол контролы.
      else if C is TWinControl then
        MakeEventsList(C as TWinControl);
    end;
  end;

begin
  if FEditArea <> Value then
  begin
    // Только в рабочем режиме!
    if not (csDesigning in ComponentState) then
    begin
      if Assigned(FAdd) then FAdd.OnClick := OldAddClick;
      FAdd := nil;
      if Assigned(FEdit) then FEdit.OnClick := OldEditClick;
      FEdit := nil;
      if Assigned(FSave) then FSave.OnClick := OldSaveClick;
      FSave := nil;
      if Assigned(FCancel) then FCancel.OnClick := OldCancelClick;
      FCancel := nil;
    end;

    FEditArea := Value;

    // Только в рабочем режиме!
    if not (csDesigning in ComponentState) and Assigned(FEditArea) then
    begin
      FAdd := FindButton(NameAdd);
      if Assigned(FAdd) then
      begin
        OldAddClick := FAdd.OnClick;
        FAdd.OnClick := DoOnAddClick;
      end;

      FEdit := FindButton(NameEdit);
      if Assigned(FEdit) then
      begin
        OldEditClick := FEdit.OnClick;
        FEdit.OnClick := DoOnEditClick;
      end;

      FSave := FindButton(NameSave);
      if Assigned(FSave) then
      begin
        OldSaveClick := FSave.OnClick;
        FSave.OnClick := DoOnSaveClick;
      end;

      FCancel := FindButton(NameCancel);
      if Assigned(FCancel) then
      begin
        OldCancelClick := FCancel.OnClick;
        FCancel.OnClick := DoOnCancelClick;
      end;

      for I := 0 to FEventsList.Count - 1 do FEventsList.DeleteAndFree(0);
      MakeEventsList(FEditArea);
    end;
  end;
end;

{
  Устанавливаем содержимое названия кнопки добавить.
}

procedure TmmJumpController.SetNameAdd(const Value: String);
begin
  if FNameAdd <> Value then
    FNameAdd := Value;
end;

{
  Устанавливаем содержимое названия кнопки удалить.
}

procedure TmmJumpController.SetNameEdit(const Value: String);
begin
  if FNameEdit <> Value then
    FNameEdit := Value;
end;

{
  Устанавливаем содержимое названия кнопки сохранить.
}

procedure TmmJumpController.SetNameSave(const Value: String);
begin
  if FNameSave <> Value then
    FNameSave := Value;
end;

{
  Устанавливаем содержимое названия кнопки отменить.
}

procedure TmmJumpController.SetNameCancel(const Value: String);
begin
  if FNameCancel <> Value then
    FNameCancel := Value;
end;

{
  По двойному щелчку в таблице производим активацию области редактирования.
}

procedure TmmJumpController.DoOnDblClickGrid(Sender: TObject);
begin
  if Assigned(OldOnDblClickGrid) then OldOnDblClickGrid(Sender);
  FindAndSelectDBEdit(FEditArea, FGridControl.SelectedField);

  if FAdd <> nil then FAdd.Enabled := False;
  if FEdit <> nil then FEdit.Enabled := False;

  if FSave <> nil then
  begin
    FSave.Enabled := True;
    FSave.Default := True;
  end;
  if FCancel <> nil then FCancel.Enabled := True;
end;

{
  По активации таблицы производим свои установки.
}

procedure TmmJumpController.DoOnEnterGrid(Sender: TObject);
begin
  if Assigned(OldOnEnterGrid) then OldOnEnterGrid(Sender);

  if FAdd <> nil then FAdd.Enabled := True;
  if FEdit <> nil then FEdit.Enabled := True;

  if Assigned(FGridControl.DataSource) and Assigned(FGridControl.DataSource.DataSet) and
    (FGridControl.DataSource.DataSet.RecordCount > 0)
  then
    FEdit.Default := True
  else
    FAdd.Default := True;

  if FSave <> nil then FSave.Enabled := False;
  if FCancel <> nil then FCancel.Enabled := False;
end;

{
  По нажатию кнопки добавить делаем свои действия.
}

procedure TmmJumpController.DoOnAddClick(Sender: TObject);
begin
  if Assigned(OldAddClick) then OldAddClick(Sender);
  FindAndSelectDBEdit(FEditArea, nil);

  if FAdd <> nil then FAdd.Enabled := False;
  if FEdit <> nil then FEdit.Enabled := False;

  if FSave <> nil then
  begin
    FSave.Enabled := True;
    FSave.Default := True;
  end;
  if FCancel <> nil then FCancel.Enabled := True;
end;

{
  По нажатию кнопки удалить делаем свои действия.
}

procedure TmmJumpController.DoOnEditClick(Sender: TObject);
begin
  if Assigned(OldEditClick) then OldEditClick(Sender);
  FindAndSelectDBEdit(FEditArea, FGridControl.SelectedField);

  if FAdd <> nil then FAdd.Enabled := False;
  if FEdit <> nil then FEdit.Enabled := False;
  if FSave <> nil then FSave.Enabled := True;
  if FCancel <> nil then FCancel.Enabled := True;
end;

{
  По нажатию кнопки сохранить делаем свои действия.
}

procedure TmmJumpController.DoOnSaveClick(Sender: TObject);
begin
  if Assigned(OldSaveClick) then OldSaveClick(Sender);
  FGridControl.SetFocus;
  if not FGridControl.Focused then Exit;

  if FAdd <> nil then FAdd.Enabled := True;
  if FEdit <> nil then FEdit.Enabled := True;
  if FSave <> nil then FSave.Enabled := False;
  if FCancel <> nil then FCancel.Enabled := False;
end;

{
  По нажатию кнопки отменить делаем свои действия.
}

procedure TmmJumpController.DoOnCancelClick(Sender: TObject);
begin
  if Assigned(OldCancelClick) then OldCancelClick(Sender);
  FGridControl.SetFocus;
  if not FGridControl.Focused then Exit;

  if FAdd <> nil then FAdd.Enabled := True;
  if FEdit <> nil then FEdit.Enabled := True;
  if FSave <> nil then FSave.Enabled := False;
  if FCancel <> nil then FCancel.Enabled := False;
end;

{
  Производит поиск необходимого контрола в списке событий для них.
}

function TmmJumpController.FindEvent(C: TControl): TObject;
var
  I: Integer;
begin
  Result := nil; 
  for I := 0 to FEventsList.Count - 1 do
    if TEventItem(FEventsList[I]).C = C then
    begin
      Result := FEventsList[I];
      Break;
    end;
end;

{
  При получении контролом активности производим свои действия.
}

procedure TmmJumpController.DoOnControlEnter(Sender: TObject);
var
  EventItem: TEventItem;
begin
  EventItem := TEventItem(FindEvent(Sender as TControl));

  if (EventItem <> nil) and Assigned(EventItem.OldOnEnter) then
    EventItem.OldOnEnter(Sender);

  if FAdd <> nil then FAdd.Enabled := False;
  if FEdit <> nil then FEdit.Enabled := False;
  if FSave <> nil then
  begin
    FSave.Enabled := True;
    FSave.Default := True;
  end;
  if FCancel <> nil then FCancel.Enabled := True;
end;

{
  Производит поиск контрола по полю таблицы и активирует его.
}

function TmmJumpController.FindAndSelectDBEdit(CheckArea: TWinControl; F: TField): Boolean;
var
  I: Integer;
  C: TControl;
  CheckField: TField;
  SelectControl: TControl;
begin
  Result := False;
  SelectControl := nil;

  for I := 0 to CheckArea.ControlCount - 1 do
  begin
    C := CheckArea.Controls[I];
    CheckField := GetField(C);

    // Если объект содержит поле
    if CheckField <> nil then
    begin
      // Сохраняем первый объект, содержащий поле.
      if SelectControl = nil then
      begin
        SelectControl := C;
        // Если нет необходимости в поиске специального поля, то активируем первое
        if F = nil then Break;
      end;

      // Если поле совпадает с необходимым, то прерываемся
      if CheckField = F then
      begin
        SelectControl := C;
        Break;
      end;
    // Проверяем входящие в контрол контролы.
    end else if C is TWinControl then
      Result := FindAndSelectDBEdit(C as TWinControl, F);
  end;

  if SelectControl <> nil then
    if SelectControl is TDBRadioGroup then
    begin
      ((SelectControl as TDBRadioGroup).
        Controls[(SelectControl as TDBRadioGroup).ItemIndex] as TWinControl).SetFocus;
    end else
      (SelectControl as TWinControl).SetFocus;
end;

end.

