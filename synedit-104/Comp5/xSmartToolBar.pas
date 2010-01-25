
{++

  Copyright (c) 1999 by Golden Software of Belarus

  Module

    xSmartToolBar.pas

  Abstract

    An ordinary tool bar with a list of standart tool buttons.

  Author

    Romanovski Denis (17-02-99)

  Revisions history

    Initial  17-02-99  Dennis  Initial version.
    Beta1    18-02-99  Dennis  Everything works!
    Beta2    22-02-99  Dennis  Bugs fixed.
    Beta3    23-02-99  Dennis  Bugs fixed.
--}

{
  Принципы работы с данной компонентой:
  1. В первую очередь для использования данной компоненты необходимо в Design
     режиме создать ActionList.
  2. В этом списке необходимо создать действия и разбить их на группы в таком
     порядке, в каком необходимо их отображать в Tool Bar-е. Разбиение на группы
     производится при помощи указания в каждом действии названия категории
     (Category - имя категории может быть любым).
  3. Если пользователь хочет, чтобы кнопка в Tool Bar-е имела рисунок предусмотренный
     данной компонентой (т.е. "зашитый" в коде), то индекс такого рисунка необходимо
     указать в свойстве действия Tag. Список индексов рисунков можно просмотреть
     ниже.
  4. Если же рисунок для кнопки не предусмотрен, то его необходимо добавить в
     отдельный ImageList (т.е. ImageList нужно создать в Design режиме), а сам ImageList
     присвоить списку действий (Images). Индекс рисунка нужно присвоить свойству действия
     ImageIndex. Свойство Tag при этом должно быть равно 0.
  5. Также необходимо помнить, что, если пользователь использует стандартные
     "зашитые" в коде рисунки, то использующим эти рисунки кнопкам будет
     также присвоен "зашитый" в коде Hint (при условии, что Hint равен '', иначе -
     будет использоваться Hint действия, присвоенный пользователем).

  ВНИМАНИЕ!

     Если вы собираетесь самолично добавить стандартную кнопку в данную компоненту, то
     Вам необходимо:
       а) открыть файл xSmartToolBar.res
       б) в конец bitmap-а рисунков добавить новый
       в) увеличить счетчик InternalButtonCount
       г) добавить Hint в массив StandartHint
       д) продокументировать индекс рисунка и его краткое описание.
}

unit xSmartToolBar;

interface

uses
  Windows,        Messages,       SysUtils,       Classes,        Graphics,
  Controls,       Forms,          Dialogs,        ToolWin,        ComCtrls,
  ActnList;

type
  TxSmartToolBar = class(TToolBar)
  private
    FActions: TActionList; // Список действий
    FImageList: TImageList; // Список рисунков

    procedure SetActions(const Value: TActionList);
    
    function GetToolButtonByAction(AnAction: TAction): TToolButton;
    
    procedure ScanActionList;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Loaded; override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
    
    procedure ShowCategory(Category: String; ShowIt: Boolean);

    // Кнопка по действию
    property ButtonByAction[AnAction: TAction]: TToolButton read GetToolButtonByAction;
  published
    // Список действий
    property Actions: TActionList read FActions write SetActions;
    
  end;

procedure Register;

implementation

uses ImgList;

// Подключаем ресурс списка рисунков
{$R xSmartToolBar}

// Запись данных по категории действий
type
  TCategory = record
    Name: String; // Наименование группы
    Buttons: set of Byte; // Список кнопок
   end;

const
  // Количество стандартных категорий
  CategoryCount = 9;

  // Общее количество кнопок
  InternalButtonCount = 30;
  // Категория по умолчанию.
  CustomCategory = 8;

  // Хинты для стандартных категорий
  StandartHint: array[1..InternalButtonCount] of String =
    (
    'Добавить',
    'Редактировать',
    'Копировать',
    'Удалить',
    'Удалить все',
    'Найти',
    'Найти следующее',
    'Найти и заменить',
    'Сохранить данные',
    'Отменить',
    'Установить(убрать) фильтр',
    'Выбрать фильтр',
    'Загрузить',
    'Сохранить',
    'Закрыть',
    'Добавить уровень',
    'Добавить подуровень',
    'Удалить уровень',
    'Удалить все подуровни',
    'Обновить дерево',
    'Редактировать дерево',
    'Просмотр',
    'Печать',
    'Помощь',
    'Вырезать',
    'Копировать',
    'Вставить',
    'Выделить все',
    'Отменить',
    'Вернуть'
    );

{
  Индексы рисунков кнопок

  Редактирование:
  1 - добавить               10
  2 - реактировать           11
  3 - копировать             12
  4 - удалить                13
  5 - удалить все            14

  Поиск:
  6 - найти                  20
  7 - найти следующее        21
  8 - найти и заменить       22

  Записать:
  9 - сохранить данные
  10 - отменить (вернуть старые данные)

  Фильтр:
  11 - установить/убрать фильтр
  12 - выбрать фильтр

  Файл:
  13 - загрузить
  14 - сохранить
  15 - закрыть

  Дерево:
  16 - добавить уровень
  17 - добавить подуровень
  18 - удалить уровень
  19 - удалить все подуровни
  20 - обновить дерево
  21 - редактировать дерево

  Печать:
  22 - просмотр
  23 - печать

  Помощь:
  24 - помощь

  Работа с clipboard-ом:
  25 - вырезать
  26 - копировать
  27 - вставить
  28 - выделить все

  Отменить/вернуть:
  29 - отменить
  30 - вернуть
}

{
  Возможна группа букв алфавита!
}

{
  ***********************
  ***   Public Part   ***
  ***********************
}

{
  Производятся начальные установки.
}

constructor TxSmartToolBar.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  FActions := nil;
                            
  ShowHint := True;
  Transparent := True;
  Flat := True;

  // Загружаем рисунки и добавляем их в список.
  if not (csDesigning in ComponentState) then
  begin
    FImageList := TImageList.Create(Owner);
    FImageList.Width := 18;
    FImageList.Height := 17;
    FImageList.GetResource(rtBitmap, 'SMARTBUTTONS', 18, [lrDefaultColor], clSilver);
  end;
end;

{
  Высвобождается память. Конечные установки.
}

destructor TxSmartToolBar.Destroy;
begin
  inherited Destroy;
end;

{
  Делает всю категорию видимой (невидимой) по "флагу" Show.
}

procedure TxSmartToolBar.ShowCategory(Category: String; ShowIt: Boolean);
var
  I: Integer;
  L, F: Integer;
begin
  L := -1;
  F := -1;

  for I := 0 to ButtonCount - 1 do
    if (Buttons[I].Action <> nil) and
      (AnsiCompareText((Buttons[I].Action as TAction).Category, Category) = 0) then
    begin
      Buttons[I].Visible := ShowIt;

      if F = -1 then F := I;
      L := I;
    end;

  if (F > 0) and (Buttons[F - 1].Style = tbsSeparator) then
    Buttons[F - 1].Visible := ShowIt
  else if (L < ButtonCount - 1) and (Buttons[L + 1].Style = tbsSeparator) then
    Buttons[L + 1].Visible := ShowIt;

  // Чтобы избежать внутренней ошибки Borland производим новое создание окна Tool Bar-а.  
  RecreateWnd;
end;

{
  **************************
  ***   Protected Part   ***
  **************************
}

{
  Если пользователь удаляет список действий, то необходимо сделать определенные установки
  в компоненте.
}

procedure TxSmartToolBar.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);

  if (Operation = opRemove) and (AComponent = FActions) then
    Actions := nil;
end;

{
  По загрузке компоненты делаем свои установки.
}

procedure TxSmartToolBar.Loaded;
var
  I: Integer;
begin
  inherited Loaded;

  // Устанавливаем внутренний список вместо списка пользователя
  if not (csDesigning in ComponentState) then
  begin
    Images := FImageList;

    // Удаляем все кнопки, добавленные пользователем в Design режиме.
    for I := 0 to ButtonCount - 1 do Buttons[0].Free;

    // Удаляем старые рисунки
    while FImageList.Count > InternalButtonCount do FImageList.Delete(FImageList.Count - 1);
    if (FActions <> nil) and (FActions.Images <> nil) then FImageList.AddImages(FActions.Images);

    // Создаем собственный список кнопок.
    ScanActionList;
  end;
end;

{
  ************************
  ***   Private Part   ***
  ************************
}

{
  Добавляем список действий.
}

procedure TxSmartToolBar.SetActions(const Value: TActionList);
var
  I: Integer;
begin
  if FActions <> Value then
  begin
    FActions := Value;

    if (FActions <> nil) and not (csDesigning in ComponentState) then
      if not (csLoading in ComponentState) then
      begin
        // Удаляем старые рисунки
        while FImageList.Count > InternalButtonCount do FImageList.Delete(FImageList.Count - 1);

        if FActions.Images <> nil then FImageList.AddImages(FActions.Images);

        // Удаляем все кнопки, добавленные пользователем в Design режиме.
        for I := 0 to ButtonCount - 1 do Buttons[0].Free;

        // Создаем собственный список кнопок.
        ScanActionList;
      end;
  end;
end;

{
  По действию возвращает кнопку из списка.
}

function TxSmartToolBar.GetToolButtonByAction(AnAction: TAction): TToolButton;
var
  I: Integer;
begin
  Result := nil;
  
  for I := 0 to ButtonCount - 1 do
    if Buttons[I].Action = AnAction then
    begin
      Result := Buttons[I];
      Break;
    end;
end;

{
  Сканирует список действий и на основании его формирует Tool Bar.
}

procedure TxSmartToolBar.ScanActionList;
var
  I: Integer;
  CurrCategory: String;
  T: TToolButton;
  SortList: TList;

  // Возвращает индекс рисунка
  function GetImageIndex(AnAction: TContainedAction): Integer;
  begin
    if AnAction.Tag in [1..InternalButtonCount] then
    begin
      Result := AnAction.Tag - 1;

      if TAction(AnAction).Hint = '' then
        TAction(AnAction).Hint := StandartHint[AnAction.Tag];
    end else begin
      if TAction(AnAction).ImageIndex = -1 then
        Result := -1
      else
        Result := InternalButtonCount + TAction(AnAction).ImageIndex;
    end;
  end;

  // Позиция, куда будет добавлена новая кнопка
  function GetStartPosition: Integer;
  begin
    if ButtonCount > 0 then
      Result := Buttons[ButtonCount - 1].Left + Buttons[ButtonCount - 1].Width
    else
      Result := 0;
  end; 

  // Создает сортированный список действий
  procedure MakeSortedActionList;
  var
    K, L: Integer;
    Cat: String;
  begin
    for K := 0 to FActions.ActionCount - 1 do
      // Если новая категория,
      if (K = 0) or (Cat <> FActions[K].Category) then
      begin
        // то присваиваем ее
        Cat := FActions[K].Category;

        // Добавляем все действия по данной категории
        for L := 0 to FActions.ActionCount - 1 do
          if (FActions[L].Category = Cat) and (SortList.IndexOf(FActions[L]) = -1) then
            SortList.Add(FActions[L]);
      end;
  end;

begin
  // Если список действий не добавлен, то не производим никаких установок.
  if FActions = nil then Exit;

  SortList := TList.Create;

  try
    // создаем сортированный список действий
    MakeSortedActionList;

    CurrCategory := '';

    // Добавляем кнопки
    for I := 0 to SortList.Count - 1 do
    begin
      // Если самая первая категория
      if I = 0 then
        CurrCategory := TAction(SortList[I]).Category
      // если новая категория, то добавляем разделитель
      else if CurrCategory <> TAction(SortList[I]).Category then
      begin
        CurrCategory := TAction(SortList[I]).Category;
        T := TToolButton.Create(Owner);
        InsertControl(T);
        T.Style := tbsSeparator;
        T.Left := GetStartPosition;
      end;

      // Добавляем кнопку
      T := TToolButton.Create(Owner);
      InsertControl(T);
      T.Action := TAction(SortList[I]);
      T.ImageIndex := GetImageIndex(TAction(SortList[I]));
      T.Left := GetStartPosition;
    end;
  finally
    SortList.Free;
  end;
end;

{
  **********************************
  ***   Registration Procedure   ***
  **********************************
}

procedure Register;
begin
  RegisterComponents('gsVC', [TxSmartToolBar]);
end;

end.

