unit gsPropertyEditor;

interface

uses
  Contnrs, Classes, SysUtils, Controls, Windows, ImgList, gsResizerInterface,
  dlg_gsProperty_ColectEdit_unit, dlg_gsProperty_TVItemsEdit_unit;

type
  TDisplayTypes = (dtDefault, dtHex, dtShortCut, dtColor, dtCursor, dtCharSet);
  TButtonType = (btNone, btDefault, btDown, btMore, btBoth);

  CgsPropertyEditor = class of TgsPropertyEditor;
  TgsPropertyEditor = class(TPersistent)
  private
    FButtonType: TButtonType;
    FDisplayType: TDisplayTypes;
    FValues: TStringlist;
    FLength: Integer;
    FCurrentComponent: TComponent;
    FStatic: Boolean;
    FOwnerDrawCombo: Boolean;
    FItemHeight: Integer;
    FgsObjectInspector: IgsObjectInspectorForm;

    procedure SetgsObjectInspector(
      const Value: IgsObjectInspectorForm);

  protected
    function GetValues: TStringList; virtual;
    procedure SetCurrentComponent(const Value: TComponent); virtual;

  public
    class function PropertyType: String; virtual; abstract;
    class function PropertyName: String; virtual;
    class function PropertyClass: TClass; virtual;

    constructor Create; virtual;
    destructor Destroy; override;

    procedure OnComboDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState); virtual;

    function ShowExternalEditor(var Value: String): boolean; overload; virtual;
    function ShowExternalEditor(Value: TObject): boolean; overload; virtual;
    property ButtonType: TButtonType read FButtonType;
    property DisplayType: TDisplayTypes read FDisplayType;
    property Values: TStringList read GetValues;
    property Length: Integer read FLength;
    property ItemHeight: Integer read FItemHeight;
    property CurrentComponent: TComponent read FCurrentComponent write SetCurrentComponent;
    property Static: Boolean read FStatic;
    property ObjectInspector: IgsObjectInspectorForm read FgsObjectInspector write SetgsObjectInspector;
    property OwnerDrawCombo: Boolean read FOwnerDrawCombo;
  end;

  TgsPropertyEditor_TColor = class(TgsPropertyEditor)
  protected
    function GetValues: TStringList; override;

  public
    procedure OnComboDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState); override;
    class function PropertyType: String; override;
    constructor Create; override;
    function ShowExternalEditor(var Value: string): boolean; override;
  end;

  TgsPropertyEditor_TCursor = class(TgsPropertyEditor)
  protected
    function GetValues: TStringList; override;
    procedure FillCursors(const AName: string);

  public
    class function PropertyType: String; override;
    constructor Create; override;
  end;

  TgsPropertyEditor_TFontCharSet = class(TgsPropertyEditor)
  protected
    function GetValues: TStringList; override;
    procedure FillCharSets(const AName: string);
  public
    class function PropertyType: String; override;
    constructor Create; override;
  end;

  TgsPropertyEditor_TFontName = class(TgsPropertyEditor)
  protected
    function GetValues: TStringList; override;
  public
    procedure OnComboDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState); override;
    class function PropertyType: String; override;
    constructor Create; override;
  end;

  TgsPropertyEditor_TFont = class(TgsPropertyEditor)
  public
    class function PropertyType: String; override;
    constructor Create; override;
    function ShowExternalEditor(Value: TObject): Boolean; override;
  end;

  TgsPropertyEditor_TImageIndex = class(TgsPropertyEditor)
  private
    FImageList: TCustomImageList;
  protected

    procedure SetCurrentComponent(const Value: TComponent); override;
    function GetValues: TStringList; override;
  public
    procedure OnComboDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState); override;
    class function PropertyType: String; override;
    constructor Create; override;
  end;

  TgsPropertyEditor_TShortCut = class(TgsPropertyEditor)
  protected
    function GetValues: TStringList; override;
  public
    class function PropertyType: String; override;
    constructor Create; override;
  end;

  TgsPropertyEditor_TStrings = class(TgsPropertyEditor)
  public
    class function PropertyType: String; override;
    constructor Create; override;
    function ShowExternalEditor(Value: TObject): Boolean; override;
  end;

  TgsPropertyEditor_TTreeNodes = class(TgsPropertyEditor)
  public
    class function PropertyType: String; override;
    class function PropertyClass: TClass; override;
    constructor Create; override;
    function ShowExternalEditor(Value: TObject): Boolean; override;
  end;

  TgsPropertyEditor_TStringList = class(TgsPropertyEditor_TStrings)
  public
    class function PropertyType: String; override;
    constructor Create; override;
  end;

  TgsPropertyEditor_TBitmap = class(TgsPropertyEditor)
  public
    class function PropertyType: String; override;
    constructor Create; override;
    function ShowExternalEditor(Value: TObject): Boolean; override;
  end;

  TgsPropertyEditor_TIcon = class(TgsPropertyEditor)
  public
    class function PropertyType: String; override;
    constructor Create; override;
    function ShowExternalEditor(Value: TObject): Boolean; override;
  end;

  TgsPropertyEditor_TPicture = class(TgsPropertyEditor_TBitmap)
  public
    class function PropertyType: String; override;
    function ShowExternalEditor(Value: TObject): Boolean; override;
  end;

  TgsPropertyEditor_TCollection = class(TgsPropertyEditor)
  public
    class function PropertyType: String; override;
    class function PropertyClass: TClass; override;
    constructor Create; override;
    function ShowExternalEditor(Value: TObject): Boolean; override;
  end;

  TgsPropertyEditor_TTBCustomItem = class(TgsPropertyEditor)
  public
    class function PropertyType: String; override;
    class function PropertyClass: TClass; override;
    constructor Create; override;
    function ShowExternalEditor(Value: TObject): Boolean; override;
  end;

  TgsPropertyEditor_TMenuItem = class(TgsPropertyEditor)
  public
    class function PropertyType: String; override;
    class function PropertyClass: TClass; override;
    constructor Create; override;
    function ShowExternalEditor(Value: TObject): Boolean; override;
  end;

  TgsPropertyEditor_TgdcClassName = class(TgsPropertyEditor)
  public
    constructor Create; override;

    class function PropertyType: String; override;
    class function PropertyName: String; override;
  end;

  TgsPropertyEditor_DataField = class(TgsPropertyEditor)
  protected
    function GetValues: TStringList; override;
  public
    class function PropertyType: String; override;
    class function PropertyName: String; override;
    constructor Create; override;
  end;

  TgsPropertyEditor_TIBDatabase = class(TgsPropertyEditor)
  protected
    function GetValues: TStringList; override;
  public
    class function PropertyType: String; override;
    class function PropertyName: String; override;
    constructor Create; override;
  end;

  TgsPropertyEditor_TCustomImageList = class(TgsPropertyEditor)
  protected
    function GetValues: TStringList; override;
  public
    class function PropertyType: String; override;
    class function PropertyName: String; override;
    constructor Create; override;
  end;

  TgsPropertyEditor_TImageList = class(TgsPropertyEditor)
  public
    class function PropertyType: String; override;
  end;

  TgsPropertyEditor_SubSet = class(TgsPropertyEditor)
  protected
    function GetValues: TStringList; override;
  public
    class function PropertyType: String; override;
    class function PropertyName: String; override;
    constructor Create; override;
  end;

  function GetGsPropertyEditor(const AClassName, APropertyName: String; const AClass: TClass; AgsObjectInspector: IgsObjectInspectorForm): TgsPropertyEditor;
  function ConvertGsPropertyToString(const AValue: String; AnEditor: TgsPropertyEditor): String;
  function ConvertGsStringToProperty(const AValue: String; AnEditor: TgsPropertyEditor): String;
  procedure KillEditors;

implementation

uses
  dlg_gsProperty_StrEdit_unit, DB, TypInfo, gdcBase, dlgPictureDialog_unit,
  graphics, dlgTB2kEdit_unit, tb2item, dlgMenuEditor_unit, menus, IBDataBase,
  Forms, dialogs, stdctrls, ActnList, comctrls, extctrls, gd_ClassList;

type
  PPropEditRec = ^TPropEditRec;
  TPropEditRec = record
    PropertyType: String;
    PropertyName: String;
    PropertyClass: TClass;
    PropertyEditor: TgsPropertyEditor;
    PropertyEditorClass: CgsPropertyEditor;
  end;

  TPropertyEditorsList = class(TList)
  private
    function GetPropertyType(const Index: Integer): String;
    function GetPropertyEditor(const Index: Integer): TgsPropertyEditor;
    function GetPropertyClass(const Index: Integer): TClass;
  public
    destructor Destroy; override;

    function Add(ApropertyEditorClass: TClass): Integer;
    procedure Delete(const Index: Integer);
    procedure Clear; override;

    function IndexOfClassName(const AName: String): Integer;
    function IndexOfPropertyName(const AName: String): Integer;
    function IndexOfClass(const AClass: TClass): Integer;

    property PropertyType[const Index: Integer]: String read GetPropertyType;
    property PropertyEditor[const Index: Integer]: TgsPropertyEditor read GetPropertyEditor;
    property PropertyClass[const Index: Integer]: TClass read GetPropertyClass;
  end;

var
  gsPropertyEditors: TPropertyEditorsList;


  procedure KillEditors;
  var
    I: Integer;
  begin
    if Assigned(gsPropertyEditors) then
    begin
      KillCollections;
      KillTb2kEditors;
      KillMenuEditors;
      for I := 0 to gsPropertyEditors.Count - 1  do
      if Assigned(TPropEditRec(gsPropertyEditors.Items[I]^).PropertyEditor) then
      begin
        TPropEditRec(gsPropertyEditors.Items[I]^).PropertyEditor.Free;
        TPropEditRec(gsPropertyEditors.Items[I]^).PropertyEditor := nil;
      end;
    end;
  end;

  function GetPropertyValue(Instance: TPersistent; const PropName: string): TPersistent;
  var
    PropInfo: PPropInfo;
  begin
    Result := nil;
    PropInfo := TypInfo.GetPropInfo(Instance.ClassInfo, PropName);
    if (PropInfo <> nil) and (PropInfo^.PropType^.Kind = tkClass) then
      Result := TObject(GetOrdProp(Instance, PropInfo)) as TPersistent;
  end;

  procedure RegisterGsPropertyEditors(ClassArray: Array of TClass);
  var
    I: Integer;
  begin
    if not Assigned(gsPropertyEditors) then
      gsPropertyEditors := TPropertyEditorsList.Create;
    for I := Low(ClassArray) to High(ClassArray) do
    begin
      gsPropertyEditors.Add(ClassArray[I]);
    end;
  end;

  function GetGsPropertyEditor(const AClassName, APropertyName: String; const AClass: TClass; AgsObjectInspector: IgsObjectInspectorForm): TgsPropertyEditor;
  var
    I: Integer;
  begin
    I := -1;
    if AClassName <> '' then
      I := gsPropertyEditors.IndexOfClassName(AClassName);
    if (I = -1) and (APropertyName <> '') then
      I := gsPropertyEditors.IndexOfPropertyName(APropertyName);
    if (I = -1) and (AClass <> nil) then
      I := gsPropertyEditors.IndexOfClass(AClass);
    if I > -1 then
    begin
      Result := gsPropertyEditors.PropertyEditor[I];
      Result.FgsObjectInspector := AgsObjectInspector;
    end
    else
      Result := nil;
  end;

  function ConvertGsPropertyToString(const AValue: String; AnEditor: TgsPropertyEditor): String;
  var
    i: integer;
  begin
    if AnEditor = nil then
      Result := AValue
    else
    begin
      case AnEditor.DisplayType of
        dtHEX:
          Result := '$' + IntToHex(StrToInt(AValue), AnEditor.FLength);
        dtShortCut:
          Result := ShortCutToText(StrToInt(AValue));
        dtColor: begin
          i:= StringToColor(AValue);
          if not ColorToIdent(i, Result) then
            Result:= '$' + IntToHex(i, AnEditor.FLength);
        end;
        dtCursor: begin
          Result:= CursorToString(StringToCursor(AValue));
        end;
        dtCharSet: begin
          try
            if not CharSetToIdent(StrToInt(AValue), Result) then
              Result:= AValue;
          except
            Result:= AValue;
          end;
        end;
        else
          Result := AValue;
      end;
    end;
  end;

  function ConvertGsStringToProperty(const AValue: String; AnEditor: TgsPropertyEditor): String;
  var
    I, C: Integer;
    CL: TColor;
  begin
    if AnEditor = nil then
      Result := AValue
    else
    begin
      case AnEditor.DisplayType of
        dtShortCut:
        begin
          Val(AValue, I, C);
          if C > 0 then
            Result := IntToStr(TextToShortCut(AValue))
          else
            Result := IntToStr(I);
        end;
        dtColor: begin
          CL:= StringToColor(AValue);
          Result:= IntToStr(CL);
        end;
        dtCharSet: begin
          if IdentToCharSet(AValue, i) then
            Result:= IntToStr(i)
          else
            Result:= AValue;
        end;
        else
          Result := AValue;
      end;
    end;
  end;

{ TgsPropertyEditor }

constructor TgsPropertyEditor.Create;
begin
  FDisplayType := dtDefault;
  FButtonType := btDefault;
  FValues := nil;
  FItemHeight := 14;
  FOwnerDrawCombo := False;
  FLength := 0;
  FStatic := True;
end;

function TgsPropertyEditor.ShowExternalEditor(var Value: String): boolean;
begin
  Result := False;
end;

destructor TgsPropertyEditor.Destroy;
begin
  FValues.Free;
  inherited;
end;

function TgsPropertyEditor.ShowExternalEditor(Value: TObject): boolean;
begin
  Result := False;
end;

class function TgsPropertyEditor.PropertyName: String;
begin
  Result := '';
end;

function TgsPropertyEditor.GetValues: TStringList;
begin
  Result := FValues;
end;

class function TgsPropertyEditor.PropertyClass: TClass;
begin
  Result := nil;
end;

procedure TgsPropertyEditor.SetgsObjectInspector(
  const Value: IgsObjectInspectorForm);
begin
  if Value  <> FgsObjectInspector then
    FgsObjectInspector := Value;
end;

procedure TgsPropertyEditor.OnComboDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
//
end;

procedure TgsPropertyEditor.SetCurrentComponent(const Value: TComponent);
begin
  FCurrentComponent := Value;
end;

{ TgsPropertyEditor_TColor }

constructor TgsPropertyEditor_TColor.Create;
begin
  inherited;
//  FDisplayType := dtHex;
  FDisplayType := dtColor;
  FLength := 8;

  FButtonType := btDown;
  FValues := TStringList.Create;
  FOwnerDrawCombo := True;
end;

function TgsPropertyEditor_TColor.GetValues: TStringList;
begin
  FValues.Clear;
  ///
{    clScrollBar = TColor(COLOR_SCROLLBAR or $80000000);
  clBackground = TColor(COLOR_BACKGROUND or $80000000);
  clActiveCaption = TColor(COLOR_ACTIVECAPTION or $80000000);
  clInactiveCaption = TColor(COLOR_INACTIVECAPTION or $80000000);
  clMenu = TColor(COLOR_MENU or $80000000);
  clWindow = TColor(COLOR_WINDOW or $80000000);
  clWindowFrame = TColor(COLOR_WINDOWFRAME or $80000000);
  clMenuText = TColor(COLOR_MENUTEXT or $80000000);
  clWindowText = TColor(COLOR_WINDOWTEXT or $80000000);
  clCaptionText = TColor(COLOR_CAPTIONTEXT or $80000000);
  clActiveBorder = TColor(COLOR_ACTIVEBORDER or $80000000);
  clInactiveBorder = TColor(COLOR_INACTIVEBORDER or $80000000);
  clAppWorkSpace = TColor(COLOR_APPWORKSPACE or $80000000);
  clHighlight = TColor(COLOR_HIGHLIGHT or $80000000);
  clHighlightText = TColor(COLOR_HIGHLIGHTTEXT or $80000000);
  clBtnFace = TColor(COLOR_BTNFACE or $80000000);
  clBtnShadow = TColor(COLOR_BTNSHADOW or $80000000);
  clGrayText = TColor(COLOR_GRAYTEXT or $80000000);
  clBtnText = TColor(COLOR_BTNTEXT or $80000000);
  clInactiveCaptionText = TColor(COLOR_INACTIVECAPTIONTEXT or $80000000);
  clBtnHighlight = TColor(COLOR_BTNHIGHLIGHT or $80000000);
  cl3DDkShadow = TColor(COLOR_3DDKSHADOW or $80000000);
  cl3DLight = TColor(COLOR_3DLIGHT or $80000000);
  clInfoText = TColor(COLOR_INFOTEXT or $80000000);
  clInfoBk = TColor(COLOR_INFOBK or $80000000);

  clBlack = TColor($000000);
  clMaroon = TColor($000080);
  clGreen = TColor($008000);
  clOlive = TColor($008080);
  clNavy = TColor($800000);
  clPurple = TColor($800080);
  clTeal = TColor($808000);
  clGray = TColor($808080);
  clSilver = TColor($C0C0C0);
  clRed = TColor($0000FF);
  clLime = TColor($00FF00);
  clYellow = TColor($00FFFF);
  clBlue = TColor($FF0000);
  clFuchsia = TColor($FF00FF);
  clAqua = TColor($FFFF00);
  clLtGray = TColor($C0C0C0);
  clDkGray = TColor($808080);
  clWhite = TColor($FFFFFF);
  clNone = TColor($1FFFFFFF);
  clDefault = TColor($20000000);}
  ///
  FValues.CommaText := 'clScrollBar, clBackground, clActiveCaption, ' +
                       'clInactiveCaption, clMenu, clWindow, clWindowFrame, ' +
                       'clMenuText, clWindowText, clCaptionText, clActiveBorder, ' +
                       'clInactiveBorder, clAppWorkSpace, clHighlight, clHighlightText, ' +
                       'clBtnFace, clBtnShadow, clGrayText, clBtnText, clInactiveCaptionText, ' +
                       'clBtnHighlight, cl3DDkShadow, cl3DLight, clInfoText, clInfoBk, ' +
                       'clBlack, clMaroon, clGreen, clOlive, clNavy, clPurple, clTeal, ' +
                       'clGray, clSilver, clRed, clLime, clYellow, clBlue, clFuchsia, ' +
                       'clAqua, clWhite, clNone';
  Result := FValues;
end;

procedure TgsPropertyEditor_TColor.OnComboDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  LRect: TRect;
  V: Longint;
begin
  with TCustomListBox(Control).Canvas do
  begin
    Brush.Color := clWindow;
    FillRect(Rect);

    LRect := Rect;
    LRect.Right := LRect.Bottom - LRect.Top + LRect.Left + 5;
    InflateRect(LRect, -2, -2);
    Rectangle(LRect);
    InflateRect(LRect, -1, -1);

    IdentToColor(TCustomListBox(Control).Items[Index], V);

    Brush.Color := V;

    FillRect(LRect);

    if odSelected in State then
      Brush.Color := clHighlight
    else
      Brush.Color := clWhite;
    LRect := Rect;
    LRect.Left := LRect.Left + LRect.Bottom - LRect.Top + 7;
    TextRect(LRect, LRect.Left,
      LRect.Top + (LRect.Bottom - LRect.Top - TextHeight(TCustomListBox(Control).Items[Index])) div 2,
      TCustomListBox(Control).Items[Index]);
  end;
end;

class function TgsPropertyEditor_TColor.PropertyType: String;
begin
  Result := 'TColor';
end;

function TgsPropertyEditor_TColor.ShowExternalEditor(var Value: string): boolean;
var
  dlgColor: TColorDialog;
begin
  Result:= False;
  dlgColor:= TColorDialog.Create(nil);
  try
    dlgColor.Color:= StringToColor(Value);
    if dlgColor.Execute then begin
      if not ColorToIdent(dlgColor.Color, Value) then
        Value:= '$' + IntToHex(dlgColor.Color, FLength);
      Result:= True;
    end;
  finally
    dlgColor.Free
  end;
end;

{ TPropertyEditorsList }

function TPropertyEditorsList.Add(APropertyEditorClass: TClass): Integer;
var
  P: PPropEditRec;
begin
  New(P);
  P^.PropertyEditorClass := CgsPropertyEditor(APropertyEditorClass);
  P^.PropertyEditor := nil;
  P^.PropertyType := AnsiUpperCase(P^.PropertyEditorClass.PropertyType);
  P^.PropertyName := AnsiUpperCase(P^.PropertyEditorClass.PropertyName);
  P^.PropertyClass := P^.PropertyEditorClass.PropertyClass;
  Result := inherited Add(P);
end;

function TPropertyEditorsList.IndexOfClassName(const AName: String): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
  begin
    if AnsiUppercase(AName) = TPropEditRec(Items[I]^).PropertyType then
    begin
      Result := I;
      Break;
    end;
  end;
end;

procedure TPropertyEditorsList.Delete(const Index: Integer);
var
  P: PPropEditRec;
begin
  P := Items[Index];
  if Assigned(TPropEditRec(Items[Index]^).PropertyEditor) then
    TPropEditRec(Items[Index]^).PropertyEditor.Free;
  Dispose(P);
  inherited Delete(Index);
end;

function TPropertyEditorsList.GetPropertyEditor(
  const Index: Integer): TgsPropertyEditor;
begin
  if not Assigned(TPropEditRec(Items[Index]^).PropertyEditor) then
    TPropEditRec(Items[Index]^).PropertyEditor := TPropEditRec(Items[Index]^).PropertyEditorClass.Create;
  Result := TPropEditRec(Items[Index]^).PropertyEditor;
end;

function TPropertyEditorsList.GetPropertyType(
  const Index: Integer): String;
begin
  Result := TPropEditRec(Items[Index]^).PropertyType;
end;

function TPropertyEditorsList.IndexOfPropertyName(
  const AName: String): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
  begin
    if AnsiUppercase(AName) = TPropEditRec(Items[I]^).PropertyName then
    begin
      Result := I;
      Break;
    end;
  end;
end;

function TPropertyEditorsList.IndexOfClass(const AClass: TClass): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
  begin
    if AClass.InheritsFrom(TPropEditRec(Items[I]^).PropertyClass) then
    begin
      Result := I;
      Break;
    end;
  end;
end;

function TPropertyEditorsList.GetPropertyClass(
  const Index: Integer): TClass;
begin
  Result := TPropEditRec(Items[Index]^).PropertyClass;
end;

procedure TPropertyEditorsList.Clear;
begin
  while Count > 0 do
    Delete(0);

  inherited Clear;
end;

destructor TPropertyEditorsList.Destroy;
begin
  Clear;

  inherited;
end;

{ TgsPropertyEditor_TStrings }

constructor TgsPropertyEditor_TStrings.Create;
begin
  inherited;
  FButtonType := btMore;
end;

class function TgsPropertyEditor_TStrings.PropertyType: String;
begin
  Result := 'TStrings';
end;

function TgsPropertyEditor_TStrings.ShowExternalEditor(
  Value: TObject): Boolean;
begin
  Result := False;
  if Value is TStrings then
  begin
    with TdlgPropertyStrEdit.Create(nil) do
    try
      Result := Edit(TStrings(Value));
    finally
      Free;
    end;
  end;
end;

{ TgsPropertyEditor_TgdcClassName }

function BuildTree(ACE: TgdClassEntry; AData: Pointer): Boolean;
begin
  if ACE.SubType = '' then
    TStringList(AData).Add(ACE.gdcClass.ClassName);
  Result := True;
end;

constructor TgsPropertyEditor_TgdcClassName.Create;
begin
  inherited;
  FButtonType := btDown;
  FValues := TStringList.Create;
  gdClassList.Traverse(TgdcBase, '', BuildTree, FValues, True, False);
end;

class function TgsPropertyEditor_TgdcClassName.PropertyName: String;
begin
  Result := 'gdClassName'
end;

class function TgsPropertyEditor_TgdcClassName.PropertyType: String;
begin
  Result := 'TgdcClassName'
end;

{ TgsPropertyEditor_DataField }

constructor TgsPropertyEditor_DataField.Create;
begin
  inherited;
  FStatic := False;
  FButtonType := btDown;
  FValues := TStringList.Create;
end;

function TgsPropertyEditor_DataField.GetValues: TStringList;
var
  DataSource: TDataSource;
begin
  FValues.Clear;
  try
    if Assigned(FCurrentComponent) then
    begin
      DataSource := GetPropertyValue(FCurrentComponent, 'DataSource') as TDataSource;
      if (DataSource <> nil) and (DataSource.DataSet <> nil) then
        DataSource.DataSet.GetFieldNames(FValues);
    end;
  except
 //   on E: Exception do
 //     ShowMessage(E.Message);
  end;  
  Result := FValues;
end;

class function TgsPropertyEditor_DataField.PropertyName: String;
begin
  Result := 'DataField'
end;

class function TgsPropertyEditor_DataField.PropertyType: String;
begin
  Result := '';
end;

{ TgsPropertyEditor_TCollection }

constructor TgsPropertyEditor_TCollection.Create;
begin
  inherited;
  FButtonType := btMore;
end;

class function TgsPropertyEditor_TCollection.PropertyClass: TClass;
begin
  Result := TCollection;
end;

class function TgsPropertyEditor_TCollection.PropertyType: String;
begin
  Result := 'TCollection';
end;

function TgsPropertyEditor_TCollection.ShowExternalEditor(
  Value: TObject): Boolean;
begin
  if Value is TCollection then
    gsShowCollectionEditor(FgsObjectInspector, FCurrentComponent, TCollection(Value), '');
  Result := False;
end;

{ TgsPropertyEditor_TPicture }


class function TgsPropertyEditor_TPicture.PropertyType: String;
begin
  Result := 'TPicture';
end;

function TgsPropertyEditor_TPicture.ShowExternalEditor(
  Value: TObject): Boolean;
begin
  Result := False;
  if Value is TPicture then
  begin
    with TdlgPictureDialog.Create(nil) do
    try
      Result := EditPicture(TPicture(Value));
    finally
      Free;
    end;
  end;
end;

{ TgsPropertyEditor_TBitmap }

constructor TgsPropertyEditor_TBitmap.Create;
begin
  inherited;
  FButtonType := btMore;
end;

class function TgsPropertyEditor_TBitmap.PropertyType: String;
begin
  Result := 'TBitmap';
end;

function TgsPropertyEditor_TBitmap.ShowExternalEditor(
  Value: TObject): Boolean;
begin
  Result := False;
  if Value is graphics.TBitmap then
  begin
    with TdlgPictureDialog.Create(nil) do
    try
      Result := Edit(graphics.TBitmap(Value));
    finally
      Free;
    end;
  end;
end;

{ TgsPropertyEditor_TTBItem }

constructor TgsPropertyEditor_TTBCustomItem.Create;
begin
  inherited;
  FButtonType := btMore;
end;

class function TgsPropertyEditor_TTBCustomItem.PropertyClass: TClass;
begin
  Result := TTBCustomItem;
end;

class function TgsPropertyEditor_TTBCustomItem.PropertyType: String;
begin
  Result := 'TTBCustomItem';
end;

function TgsPropertyEditor_TTBCustomItem.ShowExternalEditor(
  Value: TObject): Boolean;
begin
  if Value is TTBCustomItem then
    ShowTB2kEditForm(FgsObjectInspector, FCurrentComponent, TTBCustomItem(Value));
  Result := False;
end;

{ TgsPropertyEditor_TMenuItem }

constructor TgsPropertyEditor_TMenuItem.Create;
begin
  inherited;
  FButtonType := btMore;
end;

class function TgsPropertyEditor_TMenuItem.PropertyClass: TClass;
begin
  Result := TMenuItem;
end;

class function TgsPropertyEditor_TMenuItem.PropertyType: String;
begin
  Result := 'TMenuItem';
end;

function TgsPropertyEditor_TMenuItem.ShowExternalEditor(
  Value: TObject): Boolean;
begin
  if Value is TMenuItem then
    ShowMenuEditForm(FgsObjectInspector, FCurrentComponent, TMenuItem(Value));
  Result := False;
end;

{ TgsPropertyEditor_SubSet }

constructor TgsPropertyEditor_SubSet.Create;
begin
  inherited;
  FStatic := False;
  FButtonType := btDown;
  FValues := TStringList.Create;
end;

function TgsPropertyEditor_SubSet.GetValues: TStringList;
begin
  FValues.Clear;
  if Assigned(FCurrentComponent) and (FCurrentComponent is TgdcBase) then
  begin
    FValues.CommaText := StringReplace(TgdcBase(FCurrentComponent).GetSubsetList, ';', ',', [rfReplaceAll]);
  end;
  Result := FValues;
end;

class function TgsPropertyEditor_SubSet.PropertyName: String;
begin
  Result := 'SubSet';
end;

class function TgsPropertyEditor_SubSet.PropertyType: String;
begin
  Result := '';
end;

{ TgsPropertyEditor_IBDatabase }

constructor TgsPropertyEditor_TIBDatabase.Create;
begin
  inherited;
  FStatic := False;
  FButtonType := btDown;
  FValues := TStringList.Create;
end;

function TgsPropertyEditor_TIBDatabase.GetValues: TStringList;
var
  C: TComponent;
  I, J: Integer;
begin
  C := ObjectInspector.Manager.EditForm;

  FValues.Clear;

  for I := 0 to C.ComponentCount - 1 do
  begin
    if C.Components[I] is TIbDatabase then
      FValues.Add(C.Components[I].Name);
  end;

  for J := 0 to Screen.DataModuleCount - 1 do
  begin
    C := Screen.DataModules[J];
      for I := 0 to C.ComponentCount - 1 do
      begin
        if C.Components[I] is TIbDatabase then
          FValues.Add(C.Name + '.' + C.Components[I].Name);
      end;
  end;
  Result := FValues;
end;

class function TgsPropertyEditor_TIBDatabase.PropertyName: String;
begin
  Result := '';
end;

class function TgsPropertyEditor_TIBDatabase.PropertyType: String;
begin
  Result := 'TIBDatabase';
end;

{ TgsPropertyEditor_TShortCut }
const
  ShortCuts: array[0..108] of TShortCut = (
    scNone,
    Byte('A') or scCtrl,
    Byte('B') or scCtrl,
    Byte('C') or scCtrl,
    Byte('D') or scCtrl,
    Byte('E') or scCtrl,
    Byte('F') or scCtrl,
    Byte('G') or scCtrl,
    Byte('H') or scCtrl,
    Byte('I') or scCtrl,
    Byte('J') or scCtrl,
    Byte('K') or scCtrl,
    Byte('L') or scCtrl,
    Byte('M') or scCtrl,
    Byte('N') or scCtrl,
    Byte('O') or scCtrl,
    Byte('P') or scCtrl,
    Byte('Q') or scCtrl,
    Byte('R') or scCtrl,
    Byte('S') or scCtrl,
    Byte('T') or scCtrl,
    Byte('U') or scCtrl,
    Byte('V') or scCtrl,
    Byte('W') or scCtrl,
    Byte('X') or scCtrl,
    Byte('Y') or scCtrl,
    Byte('Z') or scCtrl,
    Byte('A') or scCtrl or scAlt,
    Byte('B') or scCtrl or scAlt,
    Byte('C') or scCtrl or scAlt,
    Byte('D') or scCtrl or scAlt,
    Byte('E') or scCtrl or scAlt,
    Byte('F') or scCtrl or scAlt,
    Byte('G') or scCtrl or scAlt,
    Byte('H') or scCtrl or scAlt,
    Byte('I') or scCtrl or scAlt,
    Byte('J') or scCtrl or scAlt,
    Byte('K') or scCtrl or scAlt,
    Byte('L') or scCtrl or scAlt,
    Byte('M') or scCtrl or scAlt,
    Byte('N') or scCtrl or scAlt,
    Byte('O') or scCtrl or scAlt,
    Byte('P') or scCtrl or scAlt,
    Byte('Q') or scCtrl or scAlt,
    Byte('R') or scCtrl or scAlt,
    Byte('S') or scCtrl or scAlt,
    Byte('T') or scCtrl or scAlt,
    Byte('U') or scCtrl or scAlt,
    Byte('V') or scCtrl or scAlt,
    Byte('W') or scCtrl or scAlt,
    Byte('X') or scCtrl or scAlt,
    Byte('Y') or scCtrl or scAlt,
    Byte('Z') or scCtrl or scAlt,
    VK_F1,
    VK_F2,
    VK_F3,
    VK_F4,
    VK_F5,
    VK_F6,
    VK_F7,
    VK_F8,
    VK_F9,
    VK_F10,
    VK_F11,
    VK_F12,
    VK_F1 or scCtrl,
    VK_F2 or scCtrl,
    VK_F3 or scCtrl,
    VK_F4 or scCtrl,
    VK_F5 or scCtrl,
    VK_F6 or scCtrl,
    VK_F7 or scCtrl,
    VK_F8 or scCtrl,
    VK_F9 or scCtrl,
    VK_F10 or scCtrl,
    VK_F11 or scCtrl,
    VK_F12 or scCtrl,
    VK_F1 or scShift,
    VK_F2 or scShift,
    VK_F3 or scShift,
    VK_F4 or scShift,
    VK_F5 or scShift,
    VK_F6 or scShift,
    VK_F7 or scShift,
    VK_F8 or scShift,
    VK_F9 or scShift,
    VK_F10 or scShift,
    VK_F11 or scShift,
    VK_F12 or scShift,
    VK_F1 or scShift or scCtrl,
    VK_F2 or scShift or scCtrl,
    VK_F3 or scShift or scCtrl,
    VK_F4 or scShift or scCtrl,
    VK_F5 or scShift or scCtrl,
    VK_F6 or scShift or scCtrl,
    VK_F7 or scShift or scCtrl,
    VK_F8 or scShift or scCtrl,
    VK_F9 or scShift or scCtrl,
    VK_F10 or scShift or scCtrl,
    VK_F11 or scShift or scCtrl,
    VK_F12 or scShift or scCtrl,
    VK_INSERT,
    VK_INSERT or scShift,
    VK_INSERT or scCtrl,
    VK_DELETE,
    VK_DELETE or scShift,
    VK_DELETE or scCtrl,
    VK_BACK or scAlt,
    VK_BACK or scShift or scAlt);

constructor TgsPropertyEditor_TShortCut.Create;
begin
  inherited;
  FDisplayType := dtShortCut;

  FButtonType := btDown;
  FValues := TStringList.Create;
end;

function TgsPropertyEditor_TShortCut.GetValues: TStringList;
var
  I: Integer;
begin
  FValues.Clear;
  for I := 1 to High(ShortCuts) do FValues.Add(ShortCutToText(ShortCuts[I]));
  Result := FValues;
end;

class function TgsPropertyEditor_TShortCut.PropertyType: String;
begin
  Result := 'TShortCut';
end;

{ TgsPropertyEditor_TStringList }

constructor TgsPropertyEditor_TStringList.Create;
begin
  inherited;
  FButtonType := btMore;
end;

class function TgsPropertyEditor_TStringList.PropertyType: String;
begin
  Result := 'TStringList';
end;


{ TgsPropertyEditor_TImageList }

constructor TgsPropertyEditor_TCustomImageList.Create;
begin
  inherited;
  FStatic := False;
  FButtonType := btDown;
  FValues := TStringList.Create;
end;

function TgsPropertyEditor_TCustomImageList.GetValues: TStringList;
var
  C: TComponent;
  I, J: Integer;
begin
  C := ObjectInspector.Manager.EditForm;

  FValues.Clear;

  for I := 0 to C.ComponentCount - 1 do
  begin
    if C.Components[I] is TCustomImageList then
      FValues.Add(C.Components[I].Name);
  end;

  for J := 0 to Screen.DataModuleCount - 1 do
  begin
    C := Screen.DataModules[J];
      for I := 0 to C.ComponentCount - 1 do
      begin
        if C.Components[I] is TCustomImageList then
          FValues.Add(C.Name + '.' + C.Components[I].Name);
      end;
  end;
  Result := FValues;
end;

class function TgsPropertyEditor_TCustomImageList.PropertyName: String;
begin
  Result := ''
end;

class function TgsPropertyEditor_TCustomImageList.PropertyType: String;
begin
  Result := 'TCustomImageList';
end;

{ TgsPropertyEditor_TImageList }

class function TgsPropertyEditor_TImageList.PropertyType: String;
begin
  Result := 'TImageList';
end;

{ TgsPropertyEditor_TImageIndex }

constructor TgsPropertyEditor_TImageIndex.Create;
begin
  inherited;

  FLength := 8;
  FButtonType := btDown;
  FValues := TStringList.Create;
  FOwnerDrawCombo := True;
  FImageList := nil;

end;

function TgsPropertyEditor_TImageIndex.GetValues: TStringList;
var
  I: Integer;
begin
  FValues.Clear;
  if Assigned(FImageList) then
  begin
    for I := 0 to FImageList.Count - 1 do
      FValues.Add(IntToStr(I));
  end;
  Result := FValues;
end;

procedure TgsPropertyEditor_TImageIndex.OnComboDrawItem(
  Control: TWinControl; Index: Integer; Rect: TRect;
  State: TOwnerDrawState);
var
  LRect: TRect;
  B: TBitmap;
begin
  inherited;
  with TCustomListBox(Control).Canvas do
  begin
    if Assigned(FImageList) then
    begin
      LRect := Rect;
      LRect.Right := LRect.Left + FImageList.Height;
      B := TBitmap.Create;
      try
        FImageList.GetBitmap(Index, B);
        Draw(LRect.Left, LRect.Top, B);
      finally
        B.Free;
      end;    
      LRect := Rect;
      LRect.Left := LRect.Left + FImageList.Height + 2;
      TextRect(LRect, LRect.Left,
        LRect.Top + (LRect.Bottom - LRect.Top - TextHeight(TCustomListBox(Control).Items[Index])) div 2,
        TCustomListBox(Control).Items[Index]);
    end
    else
      TextRect(Rect, Rect.Left,
        Rect.Top + (Rect.Bottom - Rect.Top - TextHeight(TCustomListBox(Control).Items[Index])) div 2,
        TCustomListBox(Control).Items[Index]);
  end;
end;

class function TgsPropertyEditor_TImageIndex.PropertyType: String;
begin
  Result := 'TImageIndex';
end;

procedure TgsPropertyEditor_TImageIndex.SetCurrentComponent(
  const Value: TComponent);
begin
  inherited;
  if FCurrentComponent is TCustomAction then
    FImageList := TCustomAction(FCurrentComponent).ActionList.Images
  else if FCurrentComponent is TTabSheet then
    FImageList := TTabSheet(FCurrentComponent).PageControl.Images
  else
    FImageList := nil;
  if Assigned(FImageList) then
    FItemHeight := FImageList.Height + 2
  else
    FItemHeight := 11;
end;

{ TgsPropertyEditor_TTreeNodes }

constructor TgsPropertyEditor_TTreeNodes.Create;
begin
  inherited;
  FButtonType := btMore;
end;

class function TgsPropertyEditor_TTreeNodes.PropertyClass: TClass;
begin
  Result:= TTreeNodes;
end;

class function TgsPropertyEditor_TTreeNodes.PropertyType: String;
begin
  Result := 'TTreeNodes';
end;

function TgsPropertyEditor_TTreeNodes.ShowExternalEditor(
  Value: TObject): Boolean;
begin
  Result := False;
  if Value is TTreeNodes then
  begin
    with TdlgPropertyTVItemsEdit.Create(nil) do
    try
      tvShow.Images:= TTreeView(FCurrentComponent).Images;
      Result := Edit(TTreeNodes(Value));
    finally
      Free;
    end;
  end;
end;

{ TgsPropertyEditor_TIcon }

constructor TgsPropertyEditor_TIcon.Create;
begin
  inherited;
  FButtonType := btMore;
end;

class function TgsPropertyEditor_TIcon.PropertyType: String;
begin
  Result := 'TIcon';
end;

function TgsPropertyEditor_TIcon.ShowExternalEditor(
  Value: TObject): Boolean;
begin
  Result := False;
  if Value is graphics.TIcon then
  begin
    with TdlgPictureDialog.Create(nil) do
    try
      Result := EditIcon(graphics.TIcon(Value));
    finally
      Free;
    end;
  end;
end;

{ TgsPropertyEditor_TFontName }

constructor TgsPropertyEditor_TFontName.Create;
begin
  inherited;
  FButtonType := btDown;
  FValues := TStringList.Create;
  FOwnerDrawCombo := True;
end;

function TgsPropertyEditor_TFontName.GetValues: TStringList;
begin
  FValues.Assign(Screen.Fonts);
  Result:= FValues;
end;

procedure TgsPropertyEditor_TFontName.OnComboDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
  with TCustomListBox(Control).Canvas do
  begin
    Font.Name:= FValues[Index];
    if odSelected in State then
      Brush.Color := clHighlight
    else
      Brush.Color := clWhite;
    TextRect(Rect, Rect.Left,
      Rect.Top + (Rect.Bottom - Rect.Top - TextHeight(FValues[Index])) div 2,
      FValues[Index]);
  end;
end;

class function TgsPropertyEditor_TFontName.PropertyType: String;
begin
  Result:= 'TFontName';
end;

{ TgsPropertyEditor_TFont }

constructor TgsPropertyEditor_TFont.Create;
begin
  inherited;
  FButtonType := btMore;
end;

class function TgsPropertyEditor_TFont.PropertyType: String;
begin
  Result:= 'TFont';
end;

function TgsPropertyEditor_TFont.ShowExternalEditor(
  Value: TObject): Boolean;
var
  dlgFont: TFontDialog;
begin
  Result:= False;
  dlgFont:= TFontDialog.Create(nil);
  try
    dlgFont.Font.Assign(TFont(Value));
    if dlgFont.Execute then begin
      TFont(Value).Assign(dlgFont.Font);
      Result:= True;
    end;
  finally
    dlgFont.Free;
  end;
end;

{ TgsPropertyEditor_TCursor }

constructor TgsPropertyEditor_TCursor.Create;
begin
  inherited;
  FDisplayType:= dtCursor;

  FButtonType := btDown;
  FValues := TStringList.Create;
end;

procedure TgsPropertyEditor_TCursor.FillCursors(const AName: string);
begin
  FValues.Add(AName);
end;

function TgsPropertyEditor_TCursor.GetValues: TStringList;
begin
  FValues.Clear;
  GetCursorValues(FillCursors);
  Result:= FValues;
end;

class function TgsPropertyEditor_TCursor.PropertyType: String;
begin
  Result:= 'TCursor';
end;

{ TgsPropertyEditor_TFontCharSet }

constructor TgsPropertyEditor_TFontCharSet.Create;
begin
  inherited;
  FDisplayType:= dtCharSet;

  FButtonType := btDown;
  FValues := TStringList.Create;
end;

procedure TgsPropertyEditor_TFontCharSet.FillCharSets(const AName: string);
begin
  FValues.Add(AName);
end;

function TgsPropertyEditor_TFontCharSet.GetValues: TStringList;
begin
  FValues.Clear;
  GetCharSetValues(FillCharSets);
  Result:= FValues;
end;

class function TgsPropertyEditor_TFontCharSet.PropertyType: String;
begin
  Result:= 'TFontCharSet';
end;

initialization
  RegisterGsPropertyEditors([TgsPropertyEditor_TColor, TgsPropertyEditor_TStrings,
     TgsPropertyEditor_TgdcClassName, TgsPropertyEditor_DataField, TgsPropertyEditor_TCollection,
     TgsPropertyEditor_TBitmap, TgsPropertyEditor_TPicture,
     TgsPropertyEditor_TTBCustomItem, TgsPropertyEditor_TMenuItem, TgsPropertyEditor_SubSet,
     TgsPropertyEditor_TIBDatabase, TgsPropertyEditor_TShortCut, TgsPropertyEditor_TStringList,
     TgsPropertyEditor_TCustomImageList, TgsPropertyEditor_TImageList, TgsPropertyEditor_TImageIndex,
     TgsPropertyEditor_TTreeNodes, TgsPropertyEditor_TIcon, TgsPropertyEditor_TFontName,
     TgsPropertyEditor_TFont, TgsPropertyEditor_TCursor, TgsPropertyEditor_TFontCharSet]);

finalization
  gsPropertyEditors.Free;
end.
