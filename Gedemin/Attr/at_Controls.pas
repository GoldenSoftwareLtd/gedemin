{++


  Copyright (c) 2000 by Golden Software of Belarus

  Module

    at_Controls

  Abstract

    Comonent that provides methods to edit
    custom fields called attributes.

  Author

    Romanovski Denis

  Revisions history

    < history >


--}


unit at_Controls;

interface

uses
  Windows,          Messages,         SysUtils,         Classes,
  Graphics,         Controls,         Forms,            Dialogs,
  StdCtrls,         DB,               Contnrs,          IBDatabase,
  IBCustomDataSet,  IBQuery,          IBSQL,            IBUpdateSQL,
  at_Classes,       IBHeader;

{
  1. Необходимо разобрать запрос
  2. Получить список таблиц и соответсвующих
  полей по таблицам
  3. Определить, какие из них являются полями пользователя
  4. По полям пользователя (далее атрибутам) необходимо
  определить, каким образом следует их редактировать
  5. В зависимости от вида редактирования (редактирование
  в гриде, редактирование в отдельном окне) сформировать
  список контролов для редактирования.
  ...
}

{
  Типы данных для контролов редактирования:
  1. Поле ввода текста
  2. Поле ввода суммы
  3. Поле ввода даты/времени
  4. Логическое поле: Правда, Ложь
  5. Ссылка на другую таблицу (выбор элемента из списка)
  6. Ссылка на таблицу пересечений (выбор нескольких элементов из списков)
  7. Поле пользователя (возможность создания какого-угодно контрола)
}

const
  OffSetRect: TRect = (Left: 6; Top: 6; Right: 20; Bottom: 20);

  AT_HORZ_BETWEEN = 6;
  AT_VERT_BETWEEN = 6;

  AT_HORZ_LABEL = 6;
  AT_VERT_LABEL = 6;

type
  //////////////////////////////////////////
  //  Состояние компонента редактора
  //  esNone - компонент следует подготовить
  //  esPrepared - компонент подготовлен к
  //  работе;
  //  esError - произошла ошибка

  TatEditorState = (esPrepared, esError, esNone);

  //////////////////////////////////
  //  Вид визуального представления
  //  контролов редактирования
  //  атрибутов:
  //  сpHorzThenVert - контролы размещаются
  //  слева на право, далее производится
  //  переход на следующую строчку
  //  сpOnlyVert - для каждого контрола
  //  отдельная строка
  //  сpInGrid - в виде Object Inpector-а

  TatControlPlacement = (cpHorzThenVert, cpOnlyVert, cpInGrid);

  ///////////////////////////////
  //  Где размещать лейбу:
  //  lbHorz - на одном уровне с
  //  контролом
  //  lbVert - лейба сверху над
  //  контролом

  TatLabelPlacement = (lpHorz, lpVert);

  TatControlState = set of (csControlCreated, csPlugged, csDataSetAssigned);

  ////////////////////////////////////////
  //  Результат вставки контрола
  //  редактирования атрибутов:
  //  prPlugged - контрол вставлен
  //  prNotEnoughWidth - не хватило места
  //  по горизонтали
  //  prNotEnoughHeight - не хватило места
  //  по вертикали
  //  prError - ошибка при вставке

  TatPlugResult = (prPlugged, prNotEnoughWidth, prNotEnoughHeight, prError);


type
  TatEditor = class;


  TatDocForm = class(TCustomDockForm)
  private
    procedure CMVisibleChanged(var Message: TMessage);
      message CM_VISIBLECHANGED;

  end;


  TatControl = class
  private
    FEditor: TatEditor;

    FControl: TControl;
    FControlState: TatControlState;

    FLabel: TLabel;

    FTargetField: TField;

    FatRelation: TatRelation;
    FatRelationField: TatRelationField;

    procedure SetTargetField(Value: TField);
    function GetTargetFieldName: String;
    function GetLabelName: String;

  protected
    function CreateControl(AnOwner: TComponent): TControl; dynamic; abstract;
    function AdjustDataProperties: Boolean; dynamic; abstract;
    procedure AdjustWidth(const AvailableRect: TRect); dynamic; abstract;

    function ShouldSetupLabel: Boolean; dynamic;
    function GetControlFont: TFont;

    procedure Notification(AComponent: TComponent; Operation: TOperation); virtual;


    property Control: TControl read FControl;
    property ControlLabel: TLabel read FLabel;

  public
    constructor Create(AnEditor: TatEditor; AnatRelation: TatRelation;
      AnatRelationField: TatRelationField); virtual;
    destructor Destroy; override;

    procedure PrepareControl;

    property TargetField: TField read FTargetField write SetTargetField;
    property TargetFieldName: String read GetTargetFieldName;
    property DisplayLabel: String read GetLabelName;

  end;


  TatTextControl = class(TatControl)
  protected
    function CreateControl(AnOwner: TComponent): TControl; override;
    function AdjustDataProperties: Boolean; override;
    procedure AdjustWidth(const AvailableRect: TRect); override;

  end;

  TatMemoControl = class(TatControl)
  protected
    function CreateControl(AnOwner: TComponent): TControl; override;
    function AdjustDataProperties: Boolean; override;
    procedure AdjustWidth(const AvailableRect: TRect); override;

  end;

  TatComboBoxControl = class(TatControl)
  private
    FTransaction: TIBTransaction;

  protected
    function CreateControl(AnOwner: TComponent): TControl; override;
    function AdjustDataProperties: Boolean; override;
    procedure AdjustWidth(const AvailableRect: TRect); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

  public
    constructor Create(AnEditor: TatEditor; AnatRelation: TatRelation;
      AnatRelationField: TatRelationField); override;
    destructor Destroy; override;

  end;

  TatCheckBoxControl = class(TatControl)
  protected
    function CreateControl(AnOwner: TComponent): TControl; override;
    function AdjustDataProperties: Boolean; override;
    procedure AdjustWidth(const AvailableRect: TRect); override;
    function ShouldSetupLabel: Boolean; override;

  end;

  TatSetEditorControl = class(TatControl)
  protected
    function CreateControl(AnOwner: TComponent): TControl; override;
    function AdjustDataProperties: Boolean; override;
    procedure AdjustWidth(const AvailableRect: TRect); override;

  end;

  TatDataLink = class(TDataLink)
  private
    FEditor: TatEditor;

    function GetSelectSQL: String;
    function GetInsertSQL: String;
    function GetModifySQL: String;
    function GetIBDataSet: TIBCustomDataSet;

  protected
    procedure ActiveChanged; override;
    procedure DataEvent(Event: TDataEvent; Info: Longint); override;
    procedure EditingChanged; override;

    property SelectSQL: String read GetSelectSQL;
    property InsertSQL: String read GetInsertSQL;
    property ModifySQL: String read GetModifySQL;
    property IBDataSet: TIBCustomDataSet read GetIBDataSet;

  public
    constructor Create(AnEditor: TatEditor);
    destructor Destroy; override;

  end;


  TatPlugger = class(TPersistent)
  private
    FEditor: TatEditor;

    FPlugRect: TRect;
    FMaxLabelWidth: Integer;

    function CountMaximumlabel: Integer;

  protected
    function SitePlugRect: TRect;

    function PlugControl(AControl: TatControl; var PlugRect: TRect): TatPlugResult;

    procedure TryToAdjustScrollBars;
    function TryToIncreaseWidth(var NewWidth: Integer): Boolean;
    function TryToIncreaseHeight(var NewHeight: Integer): Boolean;

    procedure AdjustRightAlignment;

  public
    constructor Create(AnEditor: TatEditor);
    destructor Destroy; override;

    procedure PlugControls;

  end;


  TatArrange = class
  private
    FEditor: TatEditor;
    FArea: TRect;

    function GetStartArea: TRect;

  protected
    function PlugControl(AControl: TatControl; var PlugRect: TRect): TatPlugResult;

  public
    constructor Create(AnEditor: TatEditor);
    destructor Destroy; override;

    procedure PlugControls;

  end;



  TatEditor = class(TComponent)
  private
    FDataLink: TatDataLink;
    FControls: TObjectList;
    FCanvas: TCanvas;

    FSite: TWinControl;

    FEditorState: TatEditorState;

    FControlPlacement: TatControlPlacement;
    FLabelPlacement: TatLabelPlacement;
    FatDatabase: TatDatabase;

    function GetControlCount: Integer;
    function GetControl(AnIndex: Integer): TatControl;
    function GetLastControl: TatControl;

    function GetDataSource: TDataSource;
    procedure SetDataSource(Value: TDataSource);
    procedure SetSite(Value: TWinControl);

    procedure SetControlPlacement(const Value: TatControlPlacement);
    procedure SetLabelPlacement(const Value: TatLabelPlacement);

    procedure SetatDatabase(const Value: TatDatabase);

  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation);  override;

    procedure ActiveChanged; virtual;

    function ArePropertiesValid: Boolean;

    procedure ParseSQL;
    procedure CreateControls;
    procedure AdjustDataProperties;
    procedure PlugControls;

    property DataLink: TatDataLink read FDataLink;

    property ControlCount: Integer read GetControlCount;
    property Control[Index: Integer]: TatControl read GetControl;
    property LastControl: TatControl read GetLastControl;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure PrepareEditor;
    procedure UnPrepareEditor;

    procedure StartDesignMode;
    procedure FinishDesignMode;

    property atDatabase: TatDatabase read FatDatabase
      write SetatDatabase;

  published
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property Site: TWinControl read FSite write SetSite;
    property ControlPlacement: TatControlPlacement read FControlPlacement
      write SetControlPlacement;
    property LabelPlacement: TatLabelPlacement read FLabelPlacement
      write SetLabelPlacement;

  end;

type
  EAttrEditorError = class(Exception);


procedure Register;

implementation

uses TypInfo, DBCtrls, at_sql_parser, gsIBLookupComboBox, {at_SetEditor,} at_SetComboBox;

{
  ---------------------------------------------------
  ----    Additional procedures and functions    ----
  ---------------------------------------------------
}

// Переводит символы в точки на экране (пиксели)
function SymbolsToPixels(const Symbols: Integer; Canvas: TCanvas): Integer;
var
  TM: TTextMetric;
begin
  GetTextMetrics(Canvas.Handle, TM);

  Result := Symbols * (TM.tmAveCharWidth - (TM.tmAveCharWidth div 2) +
    TM.tmOverhang + 3);
end;

// Переводит точки на экране (пиксели) в количество символов
{
function PixelsToSymbols(const Pixels: Integer; Canvas: TCanvas): Integer;
var
  TM: TTextMetric;
begin
  GetTextMetrics(Canvas.Handle, TM);

  Result := Pixels div (TM.tmAveCharWidth - (TM.tmAveCharWidth div 2) +
    TM.tmOverhang + 3);

end;
}

{ TatDocForm }

procedure TatDocForm.CMVisibleChanged(var Message: TMessage);
begin
  inherited;
  if Floating then Visible := True;
end;


{ TatControl }

{
  *********************
  ***  Public Part  ***
  *********************
}

constructor TatControl.Create(AnEditor: TatEditor; AnatRelation: TatRelation;
  AnatRelationField: TatRelationField);
begin
  FEditor := AnEditor;

  FControl := nil;
  FControlState := [];

  FLabel := nil;

  FatRelation := AnatRelation;
  FatRelationField := AnatRelationField;
end;

destructor TatControl.Destroy;
begin
  if Assigned(FControl) then
  begin
    FEditor.FSite.RemoveControl(FControl);
    FreeAndNil(FControl);
  end;

  if Assigned(FLabel) then
  begin
    FEditor.FSite.RemoveControl(FLabel);
    FreeAndNil(FLabel);
  end;

  inherited Destroy;
end;

procedure TatControl.PrepareControl;
begin
  try
    FControl := CreateControl(FEditor);
    FControl.Visible := False;
    FControl.FloatingDockSiteClass := TatDocForm;
    FControl.FreeNotification(FEditor);

    FEditor.FSite.InsertControl(FControl);

    FLabel := TLabel.Create(FEditor);
    FLabel.FloatingDockSiteClass := TatDocForm;
    FLabel.FreeNotification(FEditor);

    if FatRelationField.LName = '' then
      FLabel.Caption := FatRelationField.LShortName
    else
      FLabel.Caption := FatRelationField.LName;

    FLabel.Visible := False;
    FEditor.FSite.InsertControl(FLabel);

    Include(FControlState, csControlCreated);
  except
    raise EAttrEditorError.Create('Can''t prepare control: ' + ClassName);
  end;
end;

{
  ************************
  ***  Protected Part  ***
  ************************
}

function TatControl.ShouldSetupLabel: Boolean;
begin
  Result := True;
end;

function TatControl.GetControlFont: TFont;
var
  PropInfo: PPropInfo;
begin
  PropInfo := GetpropInfo(FControl, 'Font');

  if Assigned(PropInfo) then
    Result := GetObjectProp(FControl, PropInfo) as TFont
  else
    Result := nil;

  if not Assigned(Result) then
    raise EAttrEditorError.Create('Can''t receive control font: ' + Control.ClassName);
end;

procedure TatControl.Notification(AComponent: TComponent; Operation: TOperation);
begin
  if Operation = opRemove then
  begin
    if AComponent = FControl then
      FControl := nil
    else if AComponent = FLabel then
      FLabel := nil;
  end;
end;

{
  **********************
  ***  Private Part  ***
  **********************
}

procedure TatControl.SetTargetField(Value: TField);
begin
  if FTargetField <> Value then
  begin
    FTargetField := Value;
  end;
end;

function TatControl.GetTargetFieldName: String;
begin
  if Assigned(FTargetField) then
    Result := FTargetField.FieldName
  else
    Result := '';
end;

function TatControl.GetLabelName: String;
begin
  if Assigned(FTargetField) then
    Result := FTargetField.DisplayName
  else
    Result := 'Label1';
end;

{ TatTextControl }

{
  ************************
  ***  Protected Part  ***
  ************************
}

function TatTextControl.CreateControl(AnOwner: TComponent): TControl;
begin
  Result := TDBEdit.Create(AnOwner);
end;

function TatTextControl.AdjustDataProperties: Boolean;
begin
  try
    with (Control as TDBEdit) do
    begin
      DataSource := FEditor.FDataLink.DataSource;
      DataField := TargetFieldName;
    end;

    Result := True;
  except
    Result := False;
  end;
end;

procedure TatTextControl.AdjustWidth(const AvailableRect: TRect);
begin
  with (Control as TDBEdit) do
  begin
    if Assigned(TargetField) then
    begin
      Width := SymbolsToPixels(FatRelationField.ColWidth, FEditor.FCanvas);
      Width := Width +
        Integer(BorderStyle = bsSingle) * 4 +
        Integer((BorderStyle = bsSingle) and Ctl3d) * 2;
    end;
  end;
end;

{ TatMemoControl }

{
  ************************
  ***  Protected Part  ***
  ************************
}

function TatMemoControl.CreateControl(AnOwner: TComponent): TControl;
begin
  Result := TDBMemo.Create(AnOwner);
end;

function TatMemoControl.AdjustDataProperties: Boolean;
begin
  try
    with Control as TDBMemo do
    begin
      DataSource := FEditor.FDataLink.DataSource;
      DataField := TargetFieldName;
    end;

    Result := True;
  except
    Result := False;
  end;
end;

procedure TatMemoControl.AdjustWidth(const AvailableRect: TRect);
begin
  with (Control as TDBMemo) do
  begin
    Height := 60;
    Width := 240;

    if Assigned(TargetField) then
    begin
      if TargetField.DisplayWidth > 500 then
      begin
        Height := 80;
        Width := 240;
      end;
    end;
  end;
end;

{ TatComboBoxControl }

constructor TatComboBoxControl.Create(AnEditor: TatEditor; AnatRelation: TatRelation;
  AnatRelationField: TatRelationField);
begin
  inherited Create(AnEditor, AnatRelation, AnatRelationField);

  FTransaction := TIBTransaction.Create(FEditor);
  FTransaction.FreeNotification(FEditor);

  FTransaction.Params.Add('read_committed');
  FTransaction.Params.Add('rec_version');
  FTransaction.Params.Add('nowait');
end;

destructor TatComboBoxControl.Destroy;
begin
  if Assigned(FTransaction) then
    FreeAndNil(FTransaction);

  inherited Destroy;
end;


{
  ************************
  ***  Protected Part  ***
  ************************
}

function TatComboBoxControl.CreateControl(AnOwner: TComponent): TControl;
begin
  Result := TgsIBLookupComboBox.Create(AnOwner);
end;

function TatComboBoxControl.AdjustDataProperties: Boolean;
begin
  try
    with Control as TgsIBLookupComboBox do
    begin
      Database := FEditor.FDataLink.IBDataSet.Database;

      Transaction := FTransaction;
      Transaction.DefaultDatabase := FEditor.FDataLink.IBDataSet.Database;
      Transaction.StartTransaction;

      DataSource := FEditor.FDataLink.DataSource;

      ListTable := FatRelationField.References.RelationName;
      KeyField := FatRelationField.ReferencesField.FieldName;

      ListField := FatRelationField.References.ListField.FieldName;
      Condition := FatRelationField.Field.RefCondition;

      DataField := TargetFieldName;
    end;

    Result := True;
  except
    Result := False;
  end;
end;

procedure TatComboBoxControl.AdjustWidth(const AvailableRect: TRect);
begin
  if Assigned(TargetField) then
  with (Control as TgsIBLookupComboBox) do
  begin
    if FatRelationField.ColWidth > 0 then
      Width := SymbolsToPixels(FatRelationField.ColWidth, FEditor.FCanvas) +
        4 + 2 + 16
   else
     Width := 140;
  end;
end;

procedure TatComboBoxControl.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);

  if Operation = opRemove then
  begin
    if AComponent = FTransaction then
      FTransaction := nil;
  end;
end;

{ TatCheckBoxControl }

{
  ********************
  ***  Public Part ***
  ********************
}

{
  ************************
  ***  Protected Part  ***
  ************************
}


function TatCheckBoxControl.CreateControl(AnOwner: TComponent): TControl;
begin
  Result := TDBCheckBox.Create(AnOwner);
  (Result as TDBCheckBox).Alignment := taLeftJustify;
end;

function TatCheckBoxControl.AdjustDataProperties: Boolean;
begin
  try
    with Control as TDBCheckBox do
    begin
      DataSource := FEditor.FDataLink.DataSource;
      DataField := TargetFieldName;
      ValueChecked := '1';
      ValueUnChecked := '0';

      if FatRelationField.LName = '' then
        Caption := FatRelationField.LShortName
      else
        Caption := FatRelationField.LName;
    end;

    Result := True;
  except
    Result := False;
  end;
end;

procedure TatCheckBoxControl.AdjustWidth(const AvailableRect: TRect);
begin
  with (Control as TDBCheckBox) do
    Width := FEditor.FCanvas.TextWidth(Caption) + 20;
end;

function TatCheckBoxControl.ShouldSetupLabel: Boolean;
begin
  Result := False;
end;

{ TatSetEditorControl }

{
  *********************
  ***  Public Part  ***
  *********************
}

{
  ************************
  ***  Protected Part  ***
  ************************
}

function TatSetEditorControl.CreateControl(AnOwner: TComponent): TControl;
begin
  Result := TatSetLookupComboBox.Create(AnOwner);
  //Result := TatSetEditor.Create(AnOwner);
end;

function TatSetEditorControl.AdjustDataProperties: Boolean;
begin
  try
    //with (Control as TatSetEditor) do
    with (Control as TatSetLookupComboBox) do
    begin
      DataSource := FEditor.FDataLink.DataSource;
      DataField := TargetFieldName;
    end;

    Result := True;
  except
    Result := False;
  end;
end;

procedure TatSetEditorControl.AdjustWidth(const AvailableRect: TRect);
begin
end;



{ TatDataLink }

{
  *********************
  ***  Public Part  ***
  *********************
}

constructor TatDataLink.Create(AnEditor: TatEditor);
begin
  FEditor := AnEditor;
end;

destructor TatDataLink.Destroy;
begin
  inherited Destroy;
end;

{
  ************************
  ***  Protected Part  ***
  ************************
}

procedure TatDataLink.ActiveChanged;
begin
  FEditor.ActiveChanged;
end;

procedure TatDataLink.DataEvent(Event: TDataEvent; Info: Longint);
begin
  inherited DataEvent(Event, Info);
end;

procedure TatDataLink.EditingChanged;
begin
end;

{
  **********************
  ***  Private Part  ***
  **********************
}

function TatDataLink.GetSelectSQL: String;
var
  SQL: TStrings;
  PropInfo: PPropInfo;
begin
  if Active then
  begin
    PropInfo := GetPropInfo(DataSource.DataSet, 'SQL');
    if Assigned(PropInfo) then
      SQL := GetObjectProp(DataSource.DataSet, PropInfo) as TStrings
    else
      SQL := nil;

    if Assigned(SQL) then
      Result := SQL.Text
    else begin
      PropInfo := GetPropInfo(DataSource.DataSet, 'SelectSQL');
      if Assigned(PropInfo) then
        SQL := GetObjectProp(DataSource.DataSet, 'SelectSQL') as TStrings
      else
        SQL := nil;  

      if Assigned(SQL) then
        Result := SQL.Text
      else
        Result := '';
    end;

  end else
    Result := '';
end;

function TatDataLink.GetInsertSQL: String;
var
  SQL: TStrings;
  UpdateObject: TIBDataSetUpdateObject;
  PropInfo: PPropInfo;
begin
  PropInfo := GetPropInfo(DataSource.DataSet, 'UpdateObject');

  if Assigned(PropInfo) then
    UpdateObject := GetObjectProp(DataSource.DataSet, PropInfo)
      as TIBDataSetUpdateObject
  else
    UpdateObject := nil;

  if Assigned(UpdateObject) then
  begin
    if UpdateObject is TIBUpdateSQL then
      Result := (UpdateObject as TIBUpdateSQL).InsertSQL.Text
    else
      Result := '';
  end else begin
    PropInfo := GetPropInfo(DataSource.DataSet, 'InsertSQL');

    if Assigned(PropInfo) then
      SQL := GetObjectProp(DataSource.DataSet, PropInfo) as TStrings
    else
      SQL := nil;

    if Assigned(SQL) then
      Result := SQL.Text
    else
      Result := '';
  end;
end;

function TatDataLink.GetModifySQL: String;
var
  SQL: TStrings;
  UpdateObject: TIBDataSetUpdateObject;
  PropInfo: PPropInfo;
begin
  PropInfo := GetPropInfo(DataSource.DataSet, 'UpdateObject');

  if Assigned(PropInfo) then
    UpdateObject := GetObjectProp(DataSource.DataSet, PropInfo)
      as TIBDataSetUpdateObject
  else
    UpdateObject := nil;

  if Assigned(UpdateObject) then
  begin
    if UpdateObject is TIBUpdateSQL then
      Result := (UpdateObject as TIBUpdateSQL).ModifySQL.Text
    else
      Result := '';
  end else begin
    PropInfo := GetPropInfo(DataSource.DataSet, 'ModifySQL');

    if Assigned(PropInfo) then
      SQL := GetObjectProp(DataSource.DataSet, PropInfo) as TStrings
    else
      SQL := nil;

    if Assigned(SQL) then
      Result := SQL.Text
    else
      Result := '';
  end;
end;

function TatDataLink.GetIBDataSet: TIBCustomDataSet;
begin
  Result := DataSet as TIBCustomDataSet;
end;

{ TatPlugger }


{
  *********************
  ***  Public Part  ***
  *********************
}

constructor TatPlugger.Create(AnEditor: TatEditor);
begin
  FEditor := AnEditor;

  FPlugRect := SitePlugRect;
  FMaxLabelWidth := 0;
end;

destructor TatPlugger.Destroy;
begin
  inherited Destroy;
end;

procedure TatPlugger.PlugControls;
var
  I: Integer;

  ControlRect: TRect;
  RowRect: TRect;

  NewValue: Integer;

  procedure NextRow;
  begin
    RowRect := Rect(
      FPlugRect.Left,
      RowRect.Bottom + AT_VERT_BETWEEN,
      FPlugRect.Right,
      RowRect.Bottom + AT_VERT_BETWEEN + 1
    );

    ControlRect := RowRect;
  end;

begin
  TryToAdjustScrollBars;

  if FEditor.LabelPlacement = lpHorz then
    FMaxLabelWidth := CountMaximumLabel
  else
    FMaxLabelWidth := 0;

  with FPlugRect do
    RowRect := Rect(Left, Top, Right, Top + 1);

  ControlRect := RowRect;
  I := 0;

  with FEditor do
    while I < ControlCount do
    begin
      /////////////////////////////////////////
      // Осуществляем размещение всех контролов
      // в том порядке. в котором они были
      // добавлены

      if csControlCreated in Control[I].FControlState then
      begin
        case PlugControl(Control[I], ControlRect) of

          prPlugged: // предыдущий контрол был размещен
          begin
            // Определяем остаточную площадь
            ControlRect := Rect(
              ControlRect.Right + AT_HORZ_BETWEEN,
              ControlRect.Top,
              FPlugRect.Right,
              ControlRect.Bottom
            );

            // Определяем высоту строки
            if RowRect.Bottom < ControlRect.Bottom then
              RowRect.Bottom := ControlRect.Bottom;
          end;

          prNotEnoughWidth: // контролу не хватило места по горизонтали
          begin
            // Если размер еже был изменен - пробуем увеличить размер места,
            // куда вставляем контролы
            if ControlRect.Right - ControlRect.Left =
              FPlugRect.Right - FPlugRect.Left
            then begin
              NewValue := FPlugRect.Right + 100;
              TryToIncreaseWidth(NewValue);

              FPlugRect.Right := NewValue;
              RowRect.Right := NewValue;
              ControlRect.Right := NewValue;
            end else
              NextRow;

            Continue;
          end;

          prNotEnoughHeight: // контролу не хватило места по вертикали
          begin
            if ControlRect.Bottom = FPlugRect.Bottom then
            begin
              NewValue := FPlugRect.Bottom + 100;
              TryToIncreaseHeight(NewValue);

              FPlugRect.Bottom := NewValue;
              ControlRect.Bottom := NewValue;
            end else
              // Берем всю высоту
              ControlRect := Rect(
                ControlRect.Left,
                ControlRect.Top,
                ControlRect.Right,
                FPlugRect.Bottom
              );

            Continue;
          end;
        end;

      end;

      Inc(I);
    end;
end;

{
  ************************
  ***  Protected Part  ***
  ************************
}

function TatPlugger.SitePlugRect: TRect;
begin
  Assert(FEditor.Site <> nil);

  with FEditor.Site.ClientRect do
    Result := Rect(
      Left + OffSetRect.Left, Top + OffSetRect.Top,
      Right - OffSetRect.Right, Bottom - OffSetRect.Bottom
    );
end;

function TatPlugger.PlugControl(AControl: TatControl; var PlugRect: TRect): TatPlugResult;
var
  ControlWidth, ControlHeight: Integer;
  Offset: TPoint;
  LP: TPoint;
begin
  with PlugRect, AControl do
  try
    if ShouldSetupLabel then
      LP := Point(ControlLabel.Width, ControlLabel.Height)
    else
      LP := Point(0, 0);

    AdjustWidth(PlugRect);

    ///////////////////////////////////////
    // Контрол должен по размерам подходить
    // к предоставленным координатам
    // по горизонтали

    ControlWidth := Control.Width;

    if ShouldSetupLabel then
    begin
      case FEditor.LabelPlacement of
        lpHorz: Inc(ControlWidth, AT_HORZ_LABEL + FMaxLabelWidth);
        lpVert: if ControlWidth < LP.X then
          ControlWidth := LP.X;
      end;
    end;

    if Right - Left < ControlWidth then
    begin
      // не хватило размера по горизонтали
      Result := prNotEnoughWidth;
      Exit;
    end;

    ///////////////////////////////////////
    // Контрол должен по размерам подходить
    // к предоставленным координатам
    // по вертикали

    ControlHeight := Control.Height;

    // если используется ветикальная лейба
    if FEditor.LabelPlacement = lpVert then
      Inc(ControlHeight, AT_VERT_LABEL + LP.Y);

    // Не хватает размера по вертикали
    if Bottom - Top < ControlHeight then
    begin
      Result := prNotEnoughHeight;
      Exit;
    end;

    Bottom := Top + ControlHeight;

    if FEditor.ControlPlacement = cpHorzThenVert then
      Right := Left + ControlWidth;

    ////////////////////////////
    // Осуществляем расположение
    // контрола и лейбы

    case FEditor.LabelPlacement of
      lpHorz: // лейба располагается на одном уровне с контролом
      begin
        Offset := Point(0, LP.Y + AT_VERT_LABEL);

        if ShouldSetupLabel then
        begin
          ControlLabel.SetBounds(
            Left + FMaxLabelWidth - ControlLabel.Width,
            Top + (Bottom - Top) div 2 - ControlLabel.Height div 2,
            FMaxLabelWidth,
            ControlLabel.Height
          );

          Inc(Offset.X, FMaxLabelWidth + AT_HORZ_LABEL);
        end;

        case FEditor.ControlPlacement of
          cpHorzThenVert: // контролы располагаются слева на право и вниз
          begin
            Control.SetBounds(
              Left + Offset.X,
              Top,
              Right - (Left + Offset.X),
              Control.Height
            );
          end;
          cpOnlyVert, cpInGrid: // контролы располагаются сверху вниз
          begin
            Control.SetBounds(
              Right - Control.Width,
              Top,
              Control.Width,
              Control.Height
            );
          end;
        end;
      end;
      lpVert: // лейба располагается выше контрола
      begin
        Offset := Point(0, LP.Y + AT_VERT_LABEL);

        if ShouldSetupLabel then
        begin
          ControlLabel.SetBounds(
            Left,
            Top,
            ControlLabel.Width,
            ControlLabel.Height
          );

          Inc(Offset.X, ControlLabel.Width);
        end;

        case FEditor.ControlPlacement of
          cpHorzThenVert: // контролы располагаются слева на право и вниз
          begin
            Control.SetBounds(
              Left,
              Top + Offset.Y,
              Right - Left,
              Control.Height
            );
          end;
          cpOnlyVert, cpInGrid: // контролы располагаются сверху вниз
          begin
            Control.SetBounds(
              Right - Control.Width,
              Top + Offset.Y,
              Control.Width,
              Control.Height
            );
          end;
        end;
      end;
    end;

    ControlLabel.Visible := ShouldSetupLabel;
    Control.Visible := True;

    Include(FControlState, csPlugged);
    Result := prPlugged;
  except
    Result := prError;
  end;
end;

procedure TatPlugger.TryToAdjustScrollBars;
var
  ScrollBar: TControlScrollBar;
  ScrollBarInfo: PPropInfo;
begin
  ScrollBarInfo := GetPropInfo(FEditor.Site, 'HorzScrollBar');
  if Assigned(ScrollBarInfo) then
  begin
    ScrollBar := GetObjectProp(FEditor.Site, ScrollBarInfo) as TControlScrollBar;
    ScrollBar.Position := 0;
  end;

  ScrollBarInfo := GetPropInfo(FEditor.Site, 'VertScrollBar');
  if Assigned(ScrollBarInfo) then
  begin
    ScrollBar := GetObjectProp(FEditor.Site, ScrollBarInfo) as TControlScrollBar;
    ScrollBar.Position := 0;
  end;
end;

function TatPlugger.TryToIncreaseWidth(var NewWidth: Integer): Boolean;
var
  HorzScrollBar: TControlScrollBar;
  ScrollBarInfo: PPropInfo;
begin
  ScrollBarInfo := GetPropInfo(FEditor.Site, 'HorzScrollBar');
  if Assigned(ScrollBarInfo) then
  begin
    HorzScrollBar := GetObjectProp(FEditor.Site, ScrollBarInfo) as TControlScrollBar;

    if HorzScrollBar.Range = 0 then
      HorzScrollBar.Range := FEditor.Site.Height + 100
    else if HorzScrollBar.Range < NewWidth then
      HorzScrollBar.Range := HorzScrollBar.Range + 100;

    Result := True;
    NewWidth := HorzScrollBar.Range - OffSetRect.Right;
  end else begin
    Result := False;
  end;
end;

function TatPlugger.TryToIncreaseHeight(var NewHeight: Integer): Boolean;
var
  VertScrollBar: TControlScrollBar;
  ScrollBarInfo: PPropInfo;
begin
  ScrollBarInfo := GetPropInfo(FEditor.Site, 'VertScrollBar');
  if Assigned(ScrollBarInfo) then
  begin
    VertScrollBar := GetObjectProp(FEditor.Site, ScrollBarInfo) as TControlScrollBar;

    if VertScrollBar.Range = 0 then
      VertScrollBar.Range := FEditor.Site.Height + 100
    else if VertScrollBar.Range < NewHeight then
      VertScrollBar.Range := VertScrollBar.Range + 100;

    Result := True;
    NewHeight := VertScrollBar.Range - OffSetRect.Bottom;
  end else begin
    Result := False;
  end;
end;

procedure TatPlugger.AdjustRightAlignment;
var
  I: Integer;
begin
  with FEditor do
    for I := 0 to ControlCount - 1 do
    with Control[I] do
    begin
      Control.Left := SitePlugRect.Right - Control.Width;

      if (LabelPlacement = lpVert) and ShouldSetupLabel then
        ControlLabel.Left := SitePlugRect.Right - ControlLabel.Width;
    end;
end;

{
  **********************
  ***  Private Part  ***
  **********************
}

function TatPlugger.CountMaximumlabel: Integer;
var
  I: Integer;
begin
  Result := 0;

  with FEditor do
  for I := 0 to ControlCount - 1 do
  with Control[I] do
  begin
    if Result < ControlLabel.Width then
      Result := ControlLabel.Width;
  end;
end;


{ TatArrange }

{
  *********************
  ***  Public Part  ***
  *********************
}

constructor TatArrange.Create(AnEditor: TatEditor);
begin
  FEditor := AnEditor;
end;

destructor TatArrange.Destroy;
begin
  inherited Destroy;
end;

procedure TatArrange.PlugControls;
var
  I: Integer;
begin
  FArea := GetStartArea;
  I := 0;

  if FArea.Left = 123 then MessageBeep(0);

  while I < FEditor.ControlCount do
  begin
    Inc(I);
  end;
end;

{
  ************************
  ***  Protected Part  ***
  ************************
}

function TatArrange.PlugControl(AControl: TatControl;
  var PlugRect: TRect): TatPlugResult;
begin
  Result := prPlugged;
end;

{
  **********************
  ***  Private Part  ***
  **********************
}

function TatArrange.GetStartArea: TRect;
begin
  with FEditor do
  begin
    with FSite.ClientRect do
      Result := Rect
      (
        Left + OffSetRect.Left,
        Top + OffSetRect.Top,
        Right - OffSetRect.Right,
        Bottom - OffSetRect.Bottom
      );

    if FSite is TScrollingWinControl then
    with FSite as TScrollingWinControl do
    begin
      if HorzScrollBar.Range > Result.Right then
        Result.Right := HorzScrollBar.Range - OffSetRect.Right;

      if VertScrollBar.Range > Result.Bottom then
        Result.Bottom := VertScrollBar.Range - OffSetRect.Bottom;
    end;
  end;
end;


{ TatEditor }


{
  *********************
  ***  Public Part  ***
  *********************
}

constructor TatEditor.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  FDataLink := TatDataLink.Create(Self);
  FControls := TObjectList.Create(True);

  FSite := nil;
  FEditorState := esNone;

  FControlPlacement := cpHorzThenVert;
  FLabelPlacement := lpVert;

  FatDatabase := nil;
end;

destructor TatEditor.Destroy;
begin
  FreeAndNil(FControls);
  FreeAndNil(FDataLink);

  inherited Destroy;
end;

procedure TatEditor.PrepareEditor;
begin
  if (FEditorState = esNone) and not (csDesigning in ComponentState) then
  begin
    FCanvas := TCanvas.Create;
    FCanvas.Handle := GetDC(GetDesktopWindow);

    try
      try
        if not ArePropertiesValid then
          raise EAttrEditorError.Create('Properties are set incorrectly!');

        // Осуществляет разбор SQL и создает набор контролов
        ParseSQL;
        // создаемонтролы
        CreateControls;
        // Подлючаем их к базе данных
        AdjustDataProperties;
        // Устанавливаем на форму
        PlugControls;

        FEditorState := esPrepared;
      except
        FEditorState := esError;
      end;
    finally
      ReleaseDC(GetDesktopWindow, FCanvas.Handle);
      FCanvas.Handle := 0;
      FreeAndNil(FCanvas);
    end;
  end;
end;

procedure TatEditor.UnPrepareEditor;
begin
  if not (csDesigning in ComponentState) then
  begin
    FControls.Clear;
    FEditorState := esNone;
  end;
end;

procedure TatEditor.StartDesignMode;
var
  I: Integer;
  DragProp: PPropInfo;
begin
  DragProp := GetPropInfo(FSite, 'DockSite');
  if Assigned(DragProp) then
    SetVariantProp(FSite, 'DockSite', True);

  for I := 0 to ControlCount - 1 do
  with Control[I] do
  begin
    DragProp := GetPropInfo(Control, 'DragMode');
    if Assigned(DragProp) then
      SetPropValue(Control, 'DragMode', dmAutomatic);

    DragProp := GetPropInfo(Control, 'DragKind');
    if Assigned(DragProp) then
      SetPropValue(Control, 'DragKind', dkDock);

    if ShouldSetupLabel then
    begin
      ControlLabel.DragMode := dmAutomatic;
      ControlLabel.DragKind := dkDock;
    end;  
  end;
end;

procedure TatEditor.FinishDesignMode;
var
  I: Integer;
  DragProp: PPropInfo;
begin
  DragProp := GetPropInfo(FSite, 'DockSite');
  if Assigned(DragProp) then
    SetPropValue(FSite, 'DockSite', False);

  for I := 0 to ControlCount - 1 do
  with Control[I] do
  begin
    DragProp := GetPropInfo(Control, 'DragMode');
    if Assigned(DragProp) then
      SetPropValue(Control, 'DragMode', dmManual);

    DragProp := GetPropInfo(Control, 'DragKind');
    if Assigned(DragProp) then
      SetPropValue(Control, 'DragKind', dkDrag);
  end;
end;

{
  ************************
  ***  Protected Part  ***
  ************************
}

procedure TatEditor.Notification(AComponent: TComponent; Operation: TOperation);
var
  I: Integer;
begin
  inherited Notification(AComponent, Operation);

  if Operation = opRemove then
  begin
    if AComponent = FSite then
      FSite := nil;

    if not (csDesigning in ComponentState) and Assigned(FControls) then
    begin
      for I := 0 to FControls.Count - 1 do
        (FControls[I] as TatControl).Notification(AComponent, Operation);
    end;
  end;
end;

procedure TatEditor.ActiveChanged;
begin
  if not (csDesigning in ComponentState) then
  begin
    if FDataLink.Active and (FEditorState <> esPrepared) then
    begin
      if not Assigned(atDatabase) then
      begin
         if Assigned(at_Classes.atDatabase) then
          FatDatabase := at_Classes.atDatabase;
      end;

      PrepareEditor;
    end else

    if not FDataLink.Active and (FEditorState = esPrepared) then
      UnPrepareEditor;
  end;
end;

function TatEditor.ArePropertiesValid: Boolean;
begin
  Result := Assigned(DataSource) and (FSite <> nil);
end;

procedure TatEditor.ParseSQL;
var
  I: Integer;
  Parser: TsqlParser;
  CurrField: TField;
  atRelation: TatRelation;
  atRelationField: TatRelationField;
begin
  if not Assigned(FatDatabase) then Exit;

  Parser := TsqlParser.Create(FDataLink.InsertSQL);
  try
    Parser.Parse;
    if not (Parser.Statements[0] is TsqlInsert) then Exit;

    with (Parser.Statements[0] as TsqlInsert) do
    begin
      if Assigned(Table) then
        atRelation := FatDatabase.Relations.ByRelationName(Table.TableName)
      else
        atRelation := nil;

      if Assigned(atRelation) then
        for I := 0 to Fields.Count - 1 do
        begin
          if Fields[I] is TsqlField then
          begin
            CurrField := FDataLink.IBDataSet.
              FindField((Fields[I] as TsqlField).FieldName);

            atRelationField := atRelation.RelationFields.
              ByFieldName((Fields[I] as TsqlField).FieldName);
          end else begin
            CurrField := nil;
            atRelationField := nil;
          end;

          if not Assigned(CurrField) or not Assigned(atRelationField) then
            Continue;

          if atRelationField.IsUserDefined then
          begin
            if Assigned(atRelationField.References) then
            begin
              FControls.Add(TatComboBoxControl.Create(Self,
                atRelation, atRelationField));
              LastControl.TargetField := CurrField;
            end else

            if Assigned(atRelationField.CrossRelation) then
            begin
              FControls.Add(TatSetEditorControl.Create(Self,
                atRelation, atRelationField));
              LastControl.TargetField := CurrField;
            end else

            case atRelationField.Field.FieldType of
              ftBoolean:
              begin
                FControls.Add(TatCheckBoxControl.Create(Self,
                  atRelation, atRelationField));
                LastControl.TargetField := CurrField;
              end;
              ftInteger, ftSmallInt, ftFloat, ftString:
              begin
                FControls.Add(TatTextControl.Create(Self,
                  atRelation, atRelationField));
                LastControl.TargetField := CurrField;
              end;
              ftMemo, ftWideString:
              begin
                FControls.Add(TatMemoControl.Create(Self,
                  atRelation, atRelationField));
                LastControl.TargetField := CurrField;
              end;
              ftBlob:
              begin
                case atRelationField.Field.SQLSubType of
                  0, 1:
                  begin
                    FControls.Add(TatMemoControl.Create(Self,
                      atRelation, atRelationField));
                    LastControl.TargetField := CurrField;
                  end;
                  2:
                  begin
                  end;
                end;
              end;
              ftLargeInt:
              begin
                // feature not implemented
              end;
            end;
          end;
        end;
    end;
  finally
    Parser.Free;
  end;
end;

procedure TatEditor.CreateControls;
var
  I: Integer;
begin
  for I := 0 to ControlCount - 1 do
    Control[I].PrepareControl;
end;

procedure TatEditor.AdjustDataProperties;
var
  I: Integer;
begin
  for I := 0 to ControlCount - 1 do
    Control[I].AdjustDataProperties;
end;

procedure TatEditor.PlugControls;
var
  Plugger: TatPlugger;
begin
  Plugger := TatPlugger.Create(Self);

  try
    Plugger.PlugControls;

    if FControlPlacement = cpOnlyVert then
      Plugger.AdjustRightAlignment;

  finally
    Plugger.Free;
  end;
end;

{
  **********************
  ***  Private Part  ***
  **********************
}

function TatEditor.GetControlCount: Integer;
begin
  Result := FControls.Count;
end;

function TatEditor.GetControl(AnIndex: Integer): TatControl;
begin
  Result := FControls[AnIndex] as TatControl;
end;

function TatEditor.GetLastControl: TatControl;
begin
  Result := TatControl(FControls.Last);
end;

function TatEditor.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TatEditor.SetDataSource(Value: TDataSource);
begin
  FDataLink.DataSource := Value;
end;

procedure TatEditor.SetSite(Value: TWinControl);
begin
  if FSite <> Value then
  begin
    if Assigned(FSite) then
      FSite.RemoveFreeNotification(Self);

    FSite := Value;

    if Assigned(FSite) then
      FSite.FreeNotification(Self);
  end;
end;

procedure TatEditor.SetControlPlacement(const Value: TatControlPlacement);
begin
  if FControlPlacement <> Value then
  begin
    FControlPlacement := Value;
  end;
end;

procedure TatEditor.SetLabelPlacement(const Value: TatLabelPlacement);
begin
  if FLabelPlacement <> Value then
  begin
    FLabelPlacement := Value;
  end;
end;

procedure TatEditor.SetatDatabase(const Value: TatDatabase);
begin
  if FatDatabase <> Value then
  begin
    FatDatabase := Value;
  end;
end;

procedure Register;
begin
  RegisterComponents('gsNew', [TatEditor]);
end;

end.

