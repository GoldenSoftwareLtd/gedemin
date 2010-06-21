 {++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    at_Container.pas

  Abstract

    Delphi visual component - part of Gedemin project.
    To prepare and set visual controls for viewing and editing of attributes.

  Author

    Romanovski Denis    (31.12.2001)

  Revisions history

    1.0    Denis    31.12.2001    Initial version.
    1.1    Julie    06.05.2002    Added TatEnumComboBox

--}


unit at_Container;

interface

uses
  Windows,          Messages,         SysUtils,         Classes,
  Graphics,         Controls,         Forms,            Dialogs,
  StdCtrls,         DB,               Contnrs,          IBDatabase,
  IBCustomDataSet,  IBQuery,          IBSQL,            IBUpdateSQL,
  ExtCtrls,         at_Classes,       IBHeader,
  DBCtrls,          menus,            gsIBLookupComboBox,
  at_SetComboBox,   xDateEdits,       gsResizerInterface, evt_i_base,
  gdEnumComboBox, xCalculatorEdit;

const
  AT_START_X = 5;
  AT_START_Y = 5;

  AT_BETWEEN_X = 10;
  AT_BETWEEN_Y = 2;

  AT_CONTAINER_VERSION = 'AT_CONTAINER_VERSION';

type
  TatContainer = class;
//  TatPanel = class;

  TatControl = class
  private
    FPanel: TatContainer;
    FRelationField: TatRelationField;
    FFieldName: String;

    FControl: TControl;
    FLabel: TLabel;

    function GetField: TField;
    function GetLabelWidth: Integer;

    function GetName: TComponentName;
  protected
    function CreateControl: TControl; virtual; abstract;
    function AcquireLabel: Boolean; dynamic;

    procedure AdjustData; virtual; abstract;
    procedure AdjustSize; virtual; abstract;
    procedure AdjustDefaultValue; dynamic;


    property Control: TControl read FControl;
    property Field: TField read GetField;

    property ControlLabel: TLabel read FLabel;
    property LabelWidth: Integer read GetLabelWidth;
    procedure KillControls;
  public
    constructor Create(APanel: TatContainer; AFieldName: String;
      ARelationField: TatRelationField); virtual;
    destructor Destroy; override;

    procedure PrepareToPlug;
    property Name: TComponentName read GetName;
  end;


  TatStringControl = class(TatControl)
  private
    function GetStringEdit: TDBEdit;

  protected
    function CreateControl: TControl; override;

    procedure AdjustData; override;
    procedure AdjustSize; override;

  public
    property StringEdit: TDBEdit read GetStringEdit;

  end;


  TatIntegerControl = class(TatControl)
  private
    function GetIntegerEdit: TxDBCalculatorEdit;//TDBEdit;

  protected
    function CreateControl: TControl; override;

    procedure AdjustData; override;
    procedure AdjustSize; override;

  public
    property IntegerEdit: TxDBCalculatorEdit{TDBEdit} read GetIntegerEdit;

  end;


  TatDateTimeControl = class(TatControl)
  private
    function GetDateTimeEdit: TxDateDBEdit;

  protected
    function CreateControl: TControl; override;

    procedure AdjustData; override;
    procedure AdjustSize; override;

  public
    property DateTimeEdit: TxDateDBEdit read GetDateTimeEdit;

  end;


  TatCheckBoxControl = class(TatControl)
  private
    function GetCheckBoxEdit: TDBCheckBox;

  protected
    function CreateControl: TControl; override;
    function AcquireLabel: Boolean; override;

    procedure AdjustData; override;
    procedure AdjustSize; override;

  public
    property CheckBoxEdit: TDBCheckBox read GetCheckBoxEdit;
  end;


  TatMemoControl = class(TatControl)
  private
    {FSaveButton: TButton;
    FLoadButton: TButton;}

    function GetMemoEdit: TDBMemo;

  protected
    function CreateControl: TControl; override;

    procedure AdjustData; override;
    procedure AdjustSize; override;

  public
    property MemoEdit: TDBMemo read GetMemoEdit;

  end;


  TatSetControl = class(TatControl)
  private
    function GetSetEdit: TatSetLookupComboBox;

  protected
    function CreateControl: TControl; override;

    procedure AdjustData; override;
    procedure AdjustSize; override;

  public
    property SetEdit: TatSetLookupComboBox read GetSetEdit;

  end;


  TatLookupControl = class(TatControl)
  private
    FTransaction: TIBTransaction;

    function GetLookupEdit: TgsIBLookupComboBox;

  protected
    function CreateControl: TControl; override;

    procedure AdjustData; override;
    procedure AdjustSize; override;

  public
    constructor Create(APanel: TatContainer; AFieldName: String;
      ARelationField: TatRelationField); override;
    destructor Destroy; override;

    property LookupEdit: TgsIBLookupComboBox read GetLookupEdit;

  end;


  TatImageControl = class(TatControl)
  private
    function GetImageEdit: TDBImage;

  protected
    function CreateControl: TControl; override;

    procedure AdjustData; override;
    procedure AdjustSize; override;

  public
    property ImageEdit: TDBImage read GetImageEdit;

  end;

  TatEnumComboBox = class(TatControl)
  private
    function GetEnumComboBox: TgdEnumComboBox;

  protected
    function CreateControl: TControl; override;

    procedure AdjustData; override;
    procedure AdjustSize; override;

  public
    property EnumComboBox: TgdEnumComboBox read GetEnumComboBox;

  end;

  TatDataLink = class(TDataLink)
  private
    FContainer: TatContainer;

    function GetIBDataSet: TIBCustomDataSet;

  protected
    procedure ActiveChanged; override;
//    procedure GetRelationData(out RelationName: String; RelationFields: TStringList);
    procedure EditingChanged; override;

    property IBDataSet: TIBCustomDataSet read GetIBDataSet;

  public
    constructor Create(AContainer: TatContainer);
    destructor Destroy; override;

  end;


{  TatPanel = class(TPanel)
  private
    FContainer: TatContainer;
    FCategory: String;
    FControls: TObjectList;

    function GetLabelIndent: Integer;

  protected
    function ColWidthToPixels(const Width: Integer): Integer;

    procedure AdjustDefaultValues;
    procedure PlugControls; dynamic;

    property LabelIndent: Integer read GetLabelIndent;

  public
    constructor Create(AnOwner: TComponent; AContainer: TatContainer); reintroduce;
    destructor Destroy; override;

    property Category: String read FCategory write FCategory;

  end;}


  TCategoryList = class(TStringList)
  private
    FCategory: String;

  public
    constructor Create(const ACategory: String);
    property Category: String read FCategory;

    function FindByRelationFieldName(AName: String): Integer;

  end;

  TatOnRelationNames = procedure (Sender: TObject; Relations,
    FieldAliases: TStringList) of object;

  TatOnAdjustControl = procedure (Sender: TObject; Control: TControl) of object;


  TatContainer = class(TScrollingWinControl)
  private
    FDataLink: TatDataLink;
    FBorderStyle: TBorderStyle;
    FControls: TObjectList;

    FStoredCategories: TObjectList;

    FCurrRelation: String;

    FOnRelationNames: TatOnRelationNames;
    FOnAdjustControl: TatOnAdjustControl;
    FReloading: Boolean;

    function GetDataSource: TDataSource;
    procedure SetDataSource(const Value: TDataSource);
    procedure SetBorderStyle(const Value: TBorderStyle);

    procedure WMNCHitTest(var Message: TMessage); message WM_NCHITTEST;
    procedure CMCtl3DChanged(var Message: TMessage); message CM_CTL3DCHANGED;

    function GetControlByFieldName(AFieldName: String): TControl;

    function GetLabelIndent: Integer;
  protected
    procedure ActiveChanged; dynamic;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure AdjustDefaultValues;

    function FindStoredCategory(const ACategory: String): TCategoryList;
    function FindStoredField(const AFieldName: String; out
      Category: TCategoryList): Boolean;

    function CreateControl(AFieldName: String;
      ARelationField: TatRelationField): TatControl;

    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
      MousePos: TPoint): Boolean; override;

    procedure PlugControls;
    procedure PlugControls2;

    procedure KillControls;

    function ColWidthToPixels(const Width: Integer): Integer;
  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;


//    procedure LoadFromStream(Stream: TStream);
//    procedure SaveToStream(Stream: TStream);

    property ControlByFieldName[AFieldName: String]: TControl read
      GetControlByFieldName;

    property LabelIndent: Integer read GetLabelIndent;

  published
    property DataSource: TDataSource read GetDataSource write SetDataSource;

    property Align;
    property Anchors;
    property AutoScroll;
    property AutoSize;
    property BiDiMode;
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle default bsSingle;
    property Constraints;
    property DockSite;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Color nodefault;
    property Ctl3D;
    property Font;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property ShowHint;
    property TabOrder;
    property Visible;

    property OnRelationNames: TatOnRelationNames read FOnRelationNames write
      FOnRelationNames;
    property OnAdjustControl: TatOnAdjustControl read FOnAdjustControl write
      FOnAdjustControl;

    property OnCanResize;
    property OnClick;
    property OnConstrainedResize;
    property OnContextPopup;
    property OnDblClick;
    property OnDockDrop;
    property OnDockOver;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnGetSiteInfo;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnResize;
    property OnStartDock;
    property OnStartDrag;
    property OnUnDock;
  end;

  EatContainerError = class(Exception);

  TIBDataSetCracker = class(TIBCustomDataSet);

procedure Register;

implementation

uses
  at_sql_parser, gd_createable_form, gd_security, gdc_dlgTR_unit;

{ TCategoryList }

type
  TIBCustomDataSetCracker = class(TIBCustomDataSet);

constructor TCategoryList.Create(const ACategory: String);
begin
  FCategory := ACategory;
end;


function TCategoryList.FindByRelationFieldName(AName: String): Integer;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    if AnsiCompareText(
      (Objects[I] as TatRelationField).FieldName, AName) = 0
    then begin
      Result := I;
      Exit;
    end;

  Result := -1;
end;

{ TatContainer }

procedure TatContainer.ActiveChanged;
begin
  if (not (csDesigning in ComponentState)) and  (not (csLoading in ComponentState))
    and (not (csLoading in Owner.ComponentState)) and (not FReloading) and
    not ((Owner is TCreateableForm) and (cfsLoading in TCreateableForm(Owner).CreateableFormState))then
  begin
    if FDatalink.Active then
      PlugControls
    else
      KillControls;
  end;
end;

constructor TatContainer.Create(AnOwner: TComponent);
{var
  I: TMenuItem;}
begin
  inherited;

  Width := 185;
  Height := 41;

  ControlStyle := [csAcceptsControls, csCaptureMouse, csClickEvents, csDoubleClicks];
  FBorderStyle := bsSingle;

  FDataLink := TatDataLink.Create(Self);

  FControls := TObjectList.Create;

  FCurrRelation := '';

  FStoredCategories := TObjectList.Create(True);

end;

destructor TatContainer.Destroy;
begin
  FDataLink.Free;

  FControls.Free;

  FStoredCategories.Free;

  inherited;
end;

function TatContainer.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TatContainer.PlugControls;
var
  I, J, K: Integer;

  Relations, RelationFields, ForCategorization: TStringList;

  atRelation: TatRelation;
  atRelationField: TatRelationField;

  F: TatRelationField;
  C: TCategoryList;

  ibsql: TIBSQL;


  // сортировка по наименованию таблиц и наименованию полей.
  function SortFields(List: TStringList; Index1, Index2: Integer): Integer;
  var
    F1, F2: TatRelationField;
  begin
    F1 := TatRelationField(List.Objects[Index1]);
    F2 := TatRelationField(List.Objects[Index2]);

    if Assigned(F1) and Assigned(F2) then
    begin
      Result := AnsiCompareText(F1.Relation.RelationName,
        F2.Relation.RelationName);

      if Result = 0 then
        Result := F1.FieldPosition - F2.FieldPosition;
    end else
      Result := 0;
  end;

begin
  Assert(Assigned(FDataLink.DataSet));

  //////////////////////////////////////////////////////////////////////////////
  // Создаем контролы и распределяем их по панелям
  // в зависимости от категорий
  //////////////////////////////////////////////////////////////////////////////
  RelationFields := TStringList.Create;
  Relations := TStringList.Create;
  ForCategorization := TStringList.Create;

  try
//    PopupMenu := FMenu;

    if Assigned(FOnRelationNames) then
      FOnRelationNames(Self, Relations, RelationFields);

    if (Relations.Count = 0) and (RelationFields.Count = 0) then
    begin
      ibsql := TIBDataSetCracker(FDataLink.DataSet).QSelect;

      //
      //  Просто берем все атрибуты

      for I := 0 to FDataLink.DataSet.FieldCount - 1 do
      begin
        atRelation := atDatabase.Relations.
          ByRelationName(ibsql.Fields[I].AsXSQLVAR.relname);

        if Assigned(atRelation) then
        begin
          F := atRelation.RelationFields.ByFieldName(
            ibsql.Fields[I].AsXSQLVAR.sqlname);

          if Assigned(F) and F.IsUserDefined and (((F.aView  and IBLogin.Ingroup) <> 0) or (IBLogin.IsIBUserAdmin)) then
          begin
            RelationFields.AddObject(ibsql.Fields[I].Name, F);
          end;
        end;
      end;
    end else begin
      ibsql := TIBDataSetCracker(FDataLink.DataSet).QSelect;

      for I := 0 to FDataLink.DataSet.FieldCount - 1 do
      begin
        J := RelationFields.IndexOf(FDataLink.DataSet.Fields[I].FieldName);

        if (RelationFields.Count > 0) and (J = -1) then
          Continue;

        atRelation := atDatabase.Relations.
          ByRelationName(ibsql.Fields[I].AsXSQLVAR.relname);

        if Assigned(atRelation) then
        begin
          F := atRelation.RelationFields.ByFieldName(
            ibsql.Fields[I].AsXSQLVAR.sqlname);

          if Assigned(F) then
          begin
            if RelationFields.Count > 0 then
              RelationFields.Objects[J] := F else
            if F.IsUserDefined and (((F.aView  and IBLogin.Ingroup) <> 0) or (IBLogin.IsIBUserAdmin)) then
              RelationFields.AddObject(ibsql.Fields[I].Name, F);
          end
          else
            if J >= 0 then
              RelationFields.Delete(J);
        end
        else
          if J >= 0 then
            RelationFields.Delete(J);
      end;
    end;

    ////////////////////////////////////////////////////////////////////////////
    // Сортировка атрибутов
    ////////////////////////////////////////////////////////////////////////////

    RelationFields.CustomSort(@SortFields);


    ////////////////////////////////////////////////////////////////////////////
    // Восстанавливаем объекты структуры at_classes
    ////////////////////////////////////////////////////////////////////////////

    ibsql := TIBDataSetCracker(FDataLink.DataSet).QSelect;

    for I := 0 to FStoredCategories.Count - 1 do
    begin
      C := FStoredCategories[I] as TCategoryList;

      for K := C.Count - 1 downto 0 do
        if FDataLink.DataSet.FindField(C[K]) <> nil then
          C.Objects[K] := atDatabase.FindRelationField(
            ibsql.FieldByName(C[K]).AsXSQLVAR.relname,
            ibsql.FieldByName(C[K]).AsXSQLVAR.sqlname)
        else
          C.Delete(K);
    end;

    ////////////////////////////////////////////////////////////////////////////
    // Добавление недостающий атрибутов в список сохраненных
    ////////////////////////////////////////////////////////////////////////////

    //
    // Получаем список для категоризации

    for I := 0 to RelationFields.Count - 1 do
    begin
      if not FindStoredField(RelationFields[I], C) then
        ForCategorization.AddObject(RelationFields[I], RelationFields.Objects[I])
      else

      if AnsiCompareText(C.FCategory, 'Без категории') = 0 then
      begin
        ForCategorization.AddObject(RelationFields[I], RelationFields.Objects[I]);
        C.Delete(C.IndexOf(RelationFields[I]));
      end;
    end;

    //
    //  Сортируем

    for I := 0 to ForCategorization.Count - 1 do
    begin
      F := ForCategorization.Objects[I] as TatRelationField;
      C := FindStoredCategory(F.Relation.LName);
      J := 1;

      repeat
        K := C.FindByRelationFieldName(F.FieldName);

        if K = -1 then
          C.AddObject(ForCategorization[I], ForCategorization.Objects[I])
        else
          C := FindStoredCategory(F.Relation.LName + IntToStr(J));

        Inc(J);
      until K = -1;
    end;

    ////////////////////////////////////////////////////////////////////////////
    // Создание панелей и распределение контролов
    ////////////////////////////////////////////////////////////////////////////

    for I := 0 to FStoredCategories.Count - 1 do
    begin
      C := FStoredCategories[I] as TCategoryList;
      if C.Count = 0 then Continue;
//      CurrPanel := FindPanel(C.Category);

      for K := C.Count - 1 downto 0 do
      begin
        J := RelationFields.IndexOf(C[K]);

        if J <> -1 then
          atRelationField := RelationFields.Objects[J] as TatRelationField
        else
          atRelationField := nil;

        if Assigned(atRelationField) then
          FControls.Insert(0, CreateControl(RelationFields[J], atRelationField))
        else
          C.Delete(K);
      end;
    end;

    for I := FStoredCategories.Count - 1 downto 0 do
      if (FStoredCategories[I] as TCategoryList).Count = 0 then
        FStoredCategories.Delete(I);

  finally
    Relations.Free;
    RelationFields.Free;
    ForCategorization.Free;
  end;


  //////////////////////////////////////////////////////////////////////////////
  // Осуществляем расстановку контролов в панелях
  //////////////////////////////////////////////////////////////////////////////

  PlugControls2;

  if (Owner is TCreateableForm) and not (csloading in Owner.ComponentState) then
  begin
    if Assigned(TCreateableForm(Owner).Resizer) then
    begin
      FReloading := True;
      try
        TCreateableForm(Owner).Resizer.ReloadComponent(True);
        for I := 0 to FControls.Count - 1 do
          if TatControl(FControls[I]).Control.InheritsFrom(TgsIBLookupComboBox) then
            (TatControl(FControls[I]).Control as TgsIBLookupComboBox).SyncWithDataSource;
      finally
        FReloading := False;
      end
    end;
    if Assigned(EventControl) then
      EventControl.SafeCallSetEvents(Owner);
  end;
end;

procedure TatContainer.KillControls;
var
  I: Integer;
begin
  // если грохнулось соединение, то не удаляем
  // контролы. все равно окно и контейнер погибнут
  if (not Assigned(IBLogin))
    or (not Assigned(IBLogin.Database))
    or (IBLogin.Database.Connected) then
  begin
    for I := 0 to FControls.Count - 1 do
      TatControl(FControls[I]).KillControls;
    FControls.Clear;

    FCurrRelation := '';
    PopupMenu := nil;
  end;
end;

procedure TatContainer.SetDataSource(const Value: TDataSource);
begin
  if Value <> FDataLink.DataSource then
  begin
    FDataLink.DataSource := Value;
  end;
end;


function TatContainer.CreateControl(AFieldName: String;
  ARelationField: TatRelationField): TatControl;
begin
  Assert(ARelationField <> nil, 'RelationField not assigned');

  if Assigned(ARelationField.References) then
    // Если ссылка
    Result := TatLookupControl.Create(Self, AFieldName, ARelationField)
  else

  if Assigned(ARelationField.Field.SetTable) then
  begin
    // Если множество
    Result := TatSetControl.Create(Self, AFieldName, ARelationField);
    //(Result as TatSetControl).SetEdit.Enabled := FDataLink.DataSet.State <> dsInsert;
  end else

  if Length(ARelationField.Field.Numerations) > 0 then
  begin
    // Если перечисление
    Result := TatEnumComboBox.Create(Self, AFieldName, ARelationField);
    //(Result as TatSetControl).SetEdit.Enabled := FDataLink.DataSet.State <> dsInsert;
  end else

  // Если обычное поле
  case ARelationField.Field.FieldType of
    ftString:
      Result := TatStringControl.Create(Self, AFieldName, ARelationField);
    ftBoolean:
      Result := TatCheckBoxControl.Create(Self, AFieldName, ARelationField);
    ftSmallint, ftInteger, ftFloat, ftBCD:
      Result := TatIntegerControl.Create(Self, AFieldName, ARelationField);
//    ftInteger:
//      Result := TatIntegerControl.Create(Self, AFieldName, ARelationField);
//    ftFloat, ftBCD:
//      Result := TatStringControl.Create(Self, AFieldName, ARelationField);
    ftDateTime:
      Result := TatDateTimeControl.Create(Self, AFieldName, ARelationField);
    ftMemo:
    begin
      Result := TatMemoControl.Create(Self, AFieldName, ARelationField);
    end;
    ftBlob:
    begin
      if ARelationField.Field.SQLSubType = 1 then
        Result := TatMemoControl.Create(Self, AFieldName, ARelationField)
      else
        Result := TatMemoControl.Create(Self, AFieldName, ARelationField);
        //Result := TatImageControl.Create(AnOwner, ARelationField)
    end;
    ftDate:
      Result := TatDateTimeControl.Create(Self, AFieldName, ARelationField);
    ftTime:
      Result := TatDateTimeControl.Create(Self, AFieldName, ARelationField);
    ftLargeInt:
      Result := TatIntegerControl.Create(Self, AFieldName, ARelationField);
  else
    raise EatContainerError.Create('Unsupported field type!');
  end;
end;

procedure TatContainer.SetBorderStyle(const Value: TBorderStyle);
begin
  if Value <> FBorderStyle then
  begin
    FBorderStyle := Value;
    RecreateWnd;
  end;
end;

procedure TatContainer.CreateParams(var Params: TCreateParams);
const
  BorderStyles: array[TBorderStyle] of DWORD = (0, WS_BORDER);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := Style or BorderStyles[FBorderStyle];
    if NewStyleControls and Ctl3D and (FBorderStyle = bsSingle) then
    begin
      Style := Style and not WS_BORDER;
      ExStyle := ExStyle or WS_EX_CLIENTEDGE;
    end;
  end;
end;

procedure TatContainer.CMCtl3DChanged(var Message: TMessage);
begin
  if NewStyleControls and (FBorderStyle = bsSingle) then RecreateWnd;
  inherited;
end;

procedure TatContainer.WMNCHitTest(var Message: TMessage);
begin
  DefaultHandler(Message);
end;

procedure TatContainer.AdjustDefaultValues;
var
  I: Integer;
begin
  for I := 0 to FControls.Count - 1 do
    (FControls[I] as TatControl).AdjustDefaultValue;
end;


{procedure TatContainer.LoadFromStream(Stream: TStream);
begin
end;

procedure TatContainer.SaveToStream(Stream: TStream);
begin
end;}

function TatContainer.FindStoredCategory(
  const ACategory: String): TCategoryList;
var
  I: Integer;
begin
  for I := 0 to FStoredCategories.Count - 1 do
    if AnsiCompareText(
      (FStoredCategories[I] as TCategoryList).Category,
      ACategory) = 0 then
    begin
      Result := FStoredCategories[I] as TCategoryList;
      Exit;
    end;

  Result := TCategoryList.Create(ACategory);
  FStoredCategories.Add(Result);
end;

function TatContainer.FindStoredField(const AFieldName: String;
  out Category: TCategoryList): Boolean;
var
  I: Integer;
  C: TCategoryList;
begin
  for I := 0 to FStoredCategories.Count - 1 do
  begin
    C := FStoredCategories[I] as TCategoryList;

    if C.IndexOf(AFieldName) <> -1 then
    begin
      Category := C;
      Result := True;
      Exit;
    end;
  end;

  Result := False;
end;

function TatContainer.GetControlByFieldName(AFieldName: String): TControl;
var
  K: Integer;
begin
  for K := 0 to FControls.Count - 1 do
  with FControls[K] as TatControl do
    if AnsiCompareText(FFieldName, AFieldName) = 0 then
    begin
      Result := FControl;
      Exit;
    end;

  Result := nil;
end;


function TatContainer.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
  MousePos: TPoint): Boolean;
begin
    Result := False;
end;


function TatContainer.GetLabelIndent: Integer;
var
  I: Integer;
begin
  Result := 0;

  for I := 0 to FControls.Count - 1 do
  with (FControls[I] as TatControl) do
    if LabelWidth > Result then
      Result := LabelWidth;
end;

procedure TatContainer.PlugControls2;
var
  CurrX, CurrY: Integer;
  I: Integer;
  Indent: Integer;
begin
  CurrX := AT_START_X;
  CurrY := AT_START_Y;

  for I := 0 to FControls.Count - 1 do
    (FControls[I] as TatControl).PrepareToPlug;

  Indent := LabelIndent;

  for I := 0 to FControls.Count - 1 do
  with FControls[I] as TatControl do
  begin
    if AcquireLabel then
    begin
      ControlLabel.Left := CurrX;
      ControlLabel.Top := CurrY + 4;
      if Control is TWinControl then
        ControlLabel.FocusControl := (Control as TWinControl);

      Control.Left := CurrX + AT_BETWEEN_X + Indent;
      Control.Top := CurrY;

      ControlLabel.Parent := Self;
    end else begin
      Control.Left := CurrX;
      Control.Top := CurrY;
    end;

    Control.Parent := Self;

    AdjustData;
    AdjustSize;

    if Assigned(FOnAdjustControl) then
      FOnAdjustControl(Self, Control);

    Inc(CurrY, AT_BETWEEN_Y + Control.Height);
  end;

//  Height := CurrY;
end;

function TatContainer.ColWidthToPixels(const Width: Integer): Integer;
var
  TM: TTextMetric;
  H: HDC;
begin
  H := GETDC(Self.Handle);
  try
    GetTextMetrics(H, TM);
  finally
    ReleaseDC(Self.Handle, H);
  end;

  Result := Width * (TM.tmAveCharWidth - (TM.tmAveCharWidth div 2) +
    TM.tmOverhang + 3);
end;

{ TatDataLink }

procedure TatDataLink.ActiveChanged;
begin
  FContainer.ActiveChanged;
end;

constructor TatDataLink.Create(AContainer: TatContainer);
begin
  FContainer := AContainer;
end;

destructor TatDataLink.Destroy;
begin
  inherited;
end;

procedure TatDataLink.EditingChanged;
begin
  if
    not (csDesigning in FContainer.ComponentState)
      and
    Active
      and
    (DataSet.State in [dsInsert, dsEdit])
  then
    FContainer.AdjustDefaultValues;
end;

function TatDataLink.GetIBDataSet: TIBCustomDataSet;
begin
  Result := DataSet as TIBCustomDataSet;
end;

{procedure TatDataLink.GetRelationData(out RelationName: String;
  RelationFields: TStringList);
var
  Text: String;
  Parser: TsqlParser;
  I: Integer;
  DS: TIBCustomDataSetCracker;
begin
  Assert(Active);

  if not (DataSet is TIBCustomDataSet) then
    raise EatContainerError.Create('Base dataset class must be TIBCustomDataset!');

  with DataSet as TIBCustomDataSet do
  begin
    if Assigned(UpdateObject) and (UpdateObject is TIBUpdateSQL) then
    begin
      with UpdateObject as TIBUpdateSQL do
      begin
        Text := InsertSQL.Text;
      end;
    end else

    if DataSet is TIBCustomDataSet then
    begin
      DS := TIBCustomDataSetCracker(DataSet);
      Text := DS.InsertSQL.Text;
    end else
      raise EatContainerError.Create('Make make attributes! Update sql not provided.');
  end;

  Parser := TsqlParser.Create(Text);
  try
    Parser.Parse;

    if not (Parser.Statements[0] is TsqlInsert) then
      raise EatContainerError.Create('Incorrect insert sql!');

    with Parser.Statements[0] as TsqlInsert do
    begin
      RelationName := Table.TableName;

      for I := 0 to Fields.Count - 1 do
        if Fields[I] is TsqlField then
        begin
          with Fields[I] as TsqlField do
            RelationFields.Add(FieldName);
        end;
    end;
  finally
    Parser.Free;
  end;
end;}

{ TatControl }

function TatControl.AcquireLabel: Boolean;
begin
  Result := True;
end;

procedure TatControl.AdjustDefaultValue;
begin
// should be overriden in descendants
end;

constructor TatControl.Create(APanel: TatContainer; AFieldName: String;
  ARelationField: TatRelationField);
begin
  FPanel := APanel;
  FRelationField := ARelationField;
  FLabel := nil;
  FFieldName := AFieldName;
end;

destructor TatControl.Destroy;
begin
  inherited;
end;

function TatControl.GetField: TField;
begin
  Assert(Assigned(FPanel.FDataLink.DataSet));

  Result := FPanel.FDataLink.DataSet.FindField(FFieldName);

  if not Assigned(Result) then
    raise EatContainerError.CreateFmt(
      'Attribute field %s not found in dataset', [FRelationField.FieldName]);
end;

function TatControl.GetLabelWidth: Integer;
begin
  if Assigned(FLabel) then
    Result := FLabel.Width
  else
    Result := 0;
end;

function TatControl.GetName: TComponentName;
begin
  if Assigned(FControl) then
    Result := FControl.Name;
end;

procedure TatControl.KillControls;
begin
  FreeAndNil(FControl);
  FreeAndNil(FLabel);
end;

procedure TatControl.PrepareToPlug;
  procedure GetComponentName(Control: TComponent; var Count: Integer; const Prefix: String);
  var
    J: Integer;
  begin
    if Count = 0 then
    begin
      for J := 0 to Control.ComponentCount - 1 do
      begin
        if UpperCase(Control.Components[J].Name) = UpperCase(Prefix) then
        begin
          Inc(Count);
          GetComponentName(Control, Count, Prefix);
          Exit;
        end;
      end;
    end;
    for J := 0 to Control.ComponentCount - 1 do
    begin
      if UpperCase(Control.Components[J].Name) = UpperCase(Prefix + IntToStr(Count)) then
      begin
        Inc(Count);
        GetComponentName(Control, Count, Prefix);
        Exit;
      end;
    end;
  end;
var

  S, S1: String;
  I, Count: Integer;
begin
  FControl := CreateControl;
  try
    S1 := FControl.ClassName;
    if S1 = 'TxDBCalculatorEdit' then
      S1 := 'TDBEdit';
    S := ATCOMPONENT_PREFIX + Copy(S1, 2, Length(S1))  + '_' +
      StringReplace(FFieldName, '$', '_', [rfReplaceAll]);
    Count := 0;
    GetComponentName(FPanel.Owner, Count, S);

    if Count = 0 then
      FControl.Name := S
    else
      FControl.Name := S + IntToStr(Count);

  except
    FControl.Free;
    for I := 0 to FPanel.Owner.ComponentCount - 1 do
      if FPanel.Owner.Components[I].Name = S then
      begin
        if FPanel.Owner.Components[I] is TControl then
          FControl := TControl(FPanel.Owner.Components[I]);
        Break;
      end;
  end;

  if AcquireLabel then
  begin

    FLabel := TLabel.Create(FPanel.Owner);
    try
      S := FControl.Name + '_Label';
      Count := 0;
      GetComponentName(FPanel.Owner, Count, S);

      if Count = 0 then
        FLabel.Name := S
      else
        FLabel.Name := S + IntToStr(Count);

      FLabel.Transparent := True;

      if FRelationField.LName > '' then
        FLabel.Caption := FRelationField.LName + ':'
      else
        FLabel.Caption := FRelationField.FieldName + ':';
    except
      FLabel.Free;
      for I := 0 to FPanel.Owner.ComponentCount - 1 do
        if FPanel.Owner.Components[I].Name = S then
        begin
          if FPanel.Owner.Components[I] is TLabel then
            FLabel := TLabel(FPanel.Owner.Components[I]);
          Break;
        end;
    end;
  end;
end;

{ TatStringControl }

procedure TatStringControl.AdjustData;
begin
  StringEdit.DataSource := FPanel.DataSource;
  StringEdit.DataField := Field.FieldName;
end;

procedure TatStringControl.AdjustSize;
begin
  if FRelationField.ColWidth > 0 then
    StringEdit.Width := FPanel.ColWidthToPixels(FRelationField.ColWidth)
  else
    StringEdit.Width := FPanel.ColWidthToPixels(FRelationField.Field.FieldLength);
end;

function TatStringControl.CreateControl: TControl;
begin
  Result := TDBEdit.Create(FPanel.Owner);
end;

function TatStringControl.GetStringEdit: TDBEdit;
begin
  Result := FControl as TDBEdit;
end;

{ TatIntegerControl }

procedure TatIntegerControl.AdjustData;
begin
  IntegerEdit.DataSource := FPanel.DataSource;
  IntegerEdit.DataField := Field.FieldName;
end;

procedure TatIntegerControl.AdjustSize;
begin
  if FRelationField.ColWidth > 0 then
    IntegerEdit.Width := FPanel.ColWidthToPixels(FRelationField.ColWidth)
  else
    IntegerEdit.Width := FPanel.ColWidthToPixels(FRelationField.Field.FieldLength);
end;

function TatIntegerControl.CreateControl: TControl;
begin
//  Result := TDBEdit.Create(FPanel.Owner);
  Result := TxDBCalculatorEdit.Create(FPanel.Owner);
end;

function TatIntegerControl.GetIntegerEdit: TxDBCalculatorEdit; // TDBEdit;
begin
//  Result := FControl as TDBEdit;
  Result := FControl as TxDBCalculatorEdit
end;

{ TatDateTimeControl }

procedure TatDateTimeControl.AdjustData;
begin
  DateTimeEdit.DataSource := FPanel.DataSource;
  DateTimeEdit.DataField := Field.FieldName;
end;

procedure TatDateTimeControl.AdjustSize;
begin
  if FRelationField.ColWidth > 0 then
    DateTimeEdit.Width := FPanel.ColWidthToPixels(FRelationField.ColWidth)
  else begin
    case FRelationField.Field.FieldType of
      ftDateTime: DateTimeEdit.Width := FPanel.ColWidthToPixels(20);
      ftDate: DateTimeEdit.Width := FPanel.ColWidthToPixels(10);
      ftTime: DateTimeEdit.Width := FPanel.ColWidthToPixels(10);
    end;
  end;
end;

function TatDateTimeControl.CreateControl: TControl;
begin
  Result := TxDateDBEdit.Create(FPanel.Owner);

  case FRelationField.Field.FieldType of
    ftDateTime: (Result as TxDateDBEdit).Kind := kDateTime;
    ftDate: (Result as TxDateDBEdit).Kind := kDate;
    ftTime: (Result as TxDateDBEdit).Kind := kTime;
  end;
end;

function TatDateTimeControl.GetDateTimeEdit: TxDateDBEdit;
begin
  Result := FControl as TxDateDBEdit;
end;

{ TatCheckBoxControl }

function TatCheckBoxControl.AcquireLabel: Boolean;
begin
  Result := False;
end;

procedure TatCheckBoxControl.AdjustData;
begin
  CheckBoxEdit.DataSource := FPanel.DataSource;
  CheckBoxEdit.DataField := Field.FieldName;
  CheckBoxEdit.ValueChecked := '1';
  CheckBoxEdit.ValueUnchecked := '0';

  if FRelationField.LName > '' then
    CheckBoxEdit.Caption := FRelationField.LName
  else
    CheckBoxEdit.Caption := FRelationField.FieldName;

  CheckBoxEdit.AllowGrayed := False;
end;

procedure TatCheckBoxControl.AdjustSize;
begin
  CheckBoxEdit.Width := FPanel.ColWidthToPixels(Length(CheckBoxEdit.Caption)) + 25;
end;

function TatCheckBoxControl.CreateControl: TControl;
begin
  Result := TDBCheckBox.Create(FPanel.Owner);
end;

function TatCheckBoxControl.GetCheckBoxEdit: TDBCheckBox;
begin
  Result := FControl as TDBCheckBox;
end;

{ TatMemoControl }

procedure TatMemoControl.AdjustData;
begin
  MemoEdit.DataSource := FPanel.DataSource;
  MemoEdit.DataField := Field.FieldName;
end;

procedure TatMemoControl.AdjustSize;
begin
  MemoEdit.Width := 240;
  MemoEdit.Height := 60;
end;

function TatMemoControl.CreateControl: TControl;
begin
  Result := TDBMemo.Create(FPanel.Owner);
end;

function TatMemoControl.GetMemoEdit: TDBMemo;
begin
  Result := FControl as TDBMemo;
end;

{ TatSetControl }

procedure TatSetControl.AdjustData;
begin
  SetEdit.DataSource := FPanel.DataSource;
  SetEdit.DataField := Field.FieldName;
end;

procedure TatSetControl.AdjustSize;
begin
  SetEdit.Height := 21;
  SetEdit.Width := 240;
end;

function TatSetControl.CreateControl: TControl;
begin
  Result := TatSetLookupComboBox.Create(FPanel.Owner);
  //Может быть доступен только, если объект в состоянии редактирования
  //т.к. он работает со множествами
//  Result.Enabled := FPanel.DataSource.DataSet.State = dsEdit;
end;

function TatSetControl.GetSetEdit: TatSetLookupComboBox;
begin
  Result := FControl as TatSetLookupComboBox;
end;

{ TatLookupControl }

procedure TatLookupControl.AdjustData;
begin
  with LookupEdit do
  begin
    Database := FPanel.FDataLink.IBDataSet.Database;

    if FPanel.Owner is Tgdc_dlgTR then
    begin
      Transaction := (FPanel.Owner as Tgdc_dlgTR).ibtrCommon;
    end else
    begin
      if FTransaction = nil then
      begin
        FTransaction := TIBTransaction.Create(nil);
        FTransaction.Params.Text := 'read_committed'#13#10'rec_version'#13#10'nowait';
      end;

      FTransaction.DefaultDatabase := Database;
      Transaction := FTransaction;
    end;

    DataSource := FPanel.FDataLink.DataSource;

    Condition := FRelationField.Field.RefCondition;
    DataField := Field.FieldName;

    ListTable := FRelationField.References.RelationName;
    if Assigned(FRelationField.Field.RefListField) then
      ListField := FRelationField.Field.RefListField.FieldName
    else
      ListField := FRelationField.References.ListField.FieldName;

    KeyField := FRelationField.ReferencesField.FieldName;
    if FRelationField.gdClassName > '' then
    begin
      SubType := FRelationField.gdSubType;
      gdClassName := FRelationField.gdClassName;
    end;

    if not FRelationField.Relation.HasSecurityDescriptors then
      CheckUserRights := False;
  end;
end;

procedure TatLookupControl.AdjustSize;
begin
  if FRelationField.ColWidth > 0 then
    LookupEdit.Width := FPanel.ColWidthToPixels(FRelationField.ColWidth)
  else
    LookupEdit.Width := FPanel.ColWidthToPixels(FRelationField.Field.FieldLength);
end;

constructor TatLookupControl.Create(APanel: TatContainer; AFieldName: String;
  ARelationField: TatRelationField);
begin
  inherited;
  FTransaction := nil;
end;

function TatLookupControl.CreateControl: TControl;
begin
  Result := TgsIBLookupComboBox.Create(FPanel.Owner);
end;

destructor TatLookupControl.Destroy;
begin
  FTransaction.Free;
  inherited;
end;

function TatLookupControl.GetLookupEdit: TgsIBLookupComboBox;
begin
  Result := FControl as TgsIBLookupComboBox;
end;

{ TatImageControl }

procedure TatImageControl.AdjustData;
begin
  ImageEdit.DataSource := FPanel.DataSource;
  ImageEdit.DataField := Field.FieldName;
end;

procedure TatImageControl.AdjustSize;
begin
  ImageEdit.Width := 200;
  ImageEdit.Height := 200;
end;

function TatImageControl.CreateControl: TControl;
begin
  Result := TDBImage.Create(FPanel.Owner);
end;

function TatImageControl.GetImageEdit: TDBImage;
begin
  Result := FControl as TDBImage;
end;

procedure Register;
begin
  RegisterComponents('gsNew', [TatContainer]);
end;

{ TatEnumComboBox }

procedure TatEnumComboBox.AdjustData;
begin
  EnumComboBox.DataSource := FPanel.DataSource;
  EnumComboBox.DataField := Field.FieldName;
end;

procedure TatEnumComboBox.AdjustSize;
begin
  if FRelationField.ColWidth > 0 then
    EnumComboBox.Width := FPanel.ColWidthToPixels(FRelationField.ColWidth)
  else
    EnumComboBox.Width := FPanel.ColWidthToPixels(FRelationField.Field.FieldLength);
end;

function TatEnumComboBox.CreateControl: TControl;
begin
  Result := TgdEnumComboBox.Create(FPanel.Owner);
end;

function TatEnumComboBox.GetEnumComboBox: TgdEnumComboBox;
begin
  Result := FControl as TgdEnumComboBox;
end;

end.

