unit flt_frFilterLine_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, DBCtrls, flt_sqlfilter_condition_type, IBDatabase,
  gd_AttrComboBox, ImgList, Buttons, IBSQL, gsComboTreeBox,
  flt_EnumComboBox;

const
  WM_CLOSEFILTERLINE = 1200;

type
  TfrFilterLine = class(TFrame)
    pnlFilter: TPanel;
    cbCondition: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    pcEdits: TPageControl;
    tsOnes: TTabSheet;
    tsTwise: TTabSheet;
    tsCombo: TTabSheet;
    tsEmpty: TTabSheet;
    edCondition: TEdit;
    edFrom: TEdit;
    edTo: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    tsElementSet: TTabSheet;
    tsFilter: TTabSheet;
    cbFilter: TComboBox;
    gscbElementSet: TgsComboBoxAttr;
    gscbSet: TgsComboBoxAttrSet;
    tsFormula: TTabSheet;
    cbFormula: TComboBox;
    bbtnClose: TBitBtn;
    tsSelDay: TTabSheet;
    dtpSelDay: TDateTimePicker;
    tsScript: TTabSheet;
    cbLanguage: TComboBox;
    edScript: TEdit;
    SpeedButton1: TSpeedButton;
    tsEnterData: TTabSheet;
    cbSign: TComboBox;
    edDataName: TEdit;
    Label5: TLabel;
    Label6: TLabel;
    ctbFields: TComboTreeBox;
    tsEnumElement: TTabSheet;
    tsEnumSet: TTabSheet;
    ecbEnum: TfltDBEnumComboBox;
    escbEnumSet: TfltDBEnumSetComboBox;
    procedure cbFieldsChange(Sender: TObject);
    procedure cbFieldsExit(Sender: TObject);
    procedure cbConditionChange(Sender: TObject);
    procedure cbConditionExit(Sender: TObject);
    procedure cbFilterDropDown(Sender: TObject);
    procedure edConditionExit(Sender: TObject);
    procedure cbFormulaDropDown(Sender: TObject);
    procedure bbtnCloseClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    function CheckFormula(FormulaType: Boolean): Boolean;
    function GetUserKey: Integer;
  public
    // Все эти поля присваиваются при после создания фрэйма
    ConditionList: TFilterConditionList;
    NoVisibleList: TStringList;
    SortFieldList: TStrings;
    FunctionList: TStrings;
    FTableList: TfltStringList;
    FComponentKey: Integer;
    SQLText: String;

    IBDatabase: TIBDatabase;
    IBTransaction: TIBTransaction;

    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure SetValues;
    function CheckTypeValue: Boolean;
  end;

implementation

uses
  flt_dlgShowFilter_unit,
  {$IFDEF SYNEDIT}
  flt_dlgInputFormulaSyn_unit,
  {$ELSE}
  flt_dlgInputFormula_unit,
  {$ENDIF}
  gd_security,
  gd_directories_const,
  flt_ScriptInterface
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{$R *.DFM}

// Действия при изменении выбранного поля
procedure TfrFilterLine.cbFieldsChange(Sender: TObject);
begin
  // Обнуляем все значения
  edCondition.Text := '';
  edFrom.Text := '';
  edTo.Text := '';
  gscbSet.ValueID.Clear;
  ConditionList.Clear;
  // Заполняем список условий
  if ctbFields.SelectedNode <> nil then
  begin
    // В принципе можно условие убрать. Оставить текст после THEN   {gs}
    if TfltFieldData(ctbFields.SelectedNode.Data).FieldType <> GD_DT_UNKNOWN_SET then
      FillComboCond(TfltFieldData(ctbFields.SelectedNode.Data).FieldType, cbCondition,
       TfltFieldData(ctbFields.SelectedNode.Data).IsTree)
    else
      FillComboCond(TfltFieldData(ctbFields.SelectedNode.Data).LinkTargetFieldType,
       cbCondition, TfltFieldData(ctbFields.SelectedNode.Data).IsTree);
    if TfltFieldData(ctbFields.SelectedNode.Data).FieldType = GD_DT_FORMULA then
      cbCondition.ItemIndex := 0;
  end else
    cbCondition.Items.Clear;
  cbConditionChange(Self);
end;

procedure TfrFilterLine.cbFieldsExit(Sender: TObject);
begin
  if ctbFields.SelectedNode = nil then
  begin
    cbCondition.Items.Clear;
    cbConditionChange(Self);           
  end;
end;

// Действия выполняемые после выбора условия
procedure TfrFilterLine.SetValues;
var
  DataType: Integer;
begin
  // Проверка на выбор поля.
  if ctbFields.SelectedNode = nil then
  begin
    pcEdits.ActivePage := tsEmpty;
    Exit;
  end;
  // Опять же условие можно убрать оставить только первую строку {gs}
  if TfltFieldData(ctbFields.SelectedNode.Data).FieldType <>
   GD_DT_UNKNOWN_SET then
    DataType := TfltFieldData(ctbFields.SelectedNode.Data).FieldType
  else
    DataType := TfltFieldData(ctbFields.SelectedNode.Data).LinkTargetFieldType;
  // В зависимости от типа условия делаем активной соответствующую страницу
  case ExtractCondition(cbCondition.ItemIndex, DataType) of
    GD_FC_EQUAL_TO, GD_FC_GREATER_THAN, GD_FC_LESS_THAN, GD_FC_NOT_EQUAL_TO,
    GD_FC_GREATER_OR_EQUAL_TO, GD_FC_LESS_OR_EQUAL_TO, GD_FC_BEGINS_WITH,
    GD_FC_ENDS_WITH, GD_FC_CONTAINS, GD_FC_DOESNT_CONTAIN, GD_FC_LAST_N_DAYS:
      case DataType of
        GD_DT_ENUMERATION:
        begin
          pcEdits.ActivePage := tsEnumElement;
          ecbEnum.TableName := TfltFieldData(ctbFields.SelectedNode.Data).TableName;
          ecbEnum.FieldName := TfltFieldData(ctbFields.SelectedNode.Data).FieldName;
        end;
      else
        pcEdits.ActivePage := tsOnes;
      end;
    GD_FC_SELDAY:
      pcEdits.ActivePage := tsSelDay;
    GD_FC_BETWEEN, GD_FC_BETWEEN_LIMIT, GD_FC_OUT, GD_FC_OUT_LIMIT:
    begin
      pcEdits.ActivePage := tsTwise;
    end;
    GD_FC_SCRIPT:
    begin
      if cbLanguage.Items.Count > 0 then
        cbLanguage.ItemIndex := 0;
      pcEdits.ActivePage := tsScript;
    end;
    GD_FC_ENTER_PARAM:
    begin
      edDataName.Text := TfltFieldData(ctbFields.SelectedNode.Data).LocalTable +
       TfltFieldData(ctbFields.SelectedNode.Data).LocalField;
      pcEdits.ActivePage := tsEnterData;
      cbSign.Items.Clear;
      cbSign.Items.Add('=');
      cbSign.Items.Add('<>');
      case DataType of
        GD_DT_REF_SET_ELEMENT,
        GD_DT_CHILD_SET, GD_DT_REF_SET:
        begin
          cbSign.Items.Add(GD_FC2_ACTUATES_ALIAS);
          cbSign.Items.Add(GD_FC2_NOT_ACTUATES_ALIAS);
          if DataType <> GD_DT_REF_SET_ELEMENT then
            cbSign.Items.Add(GD_FC2_INCLUDE_ALIAS);
        end;
        GD_DT_ENUMERATION:
        begin
          cbSign.Items.Add(GD_FC2_ACTUATES_ALIAS);
          cbSign.Items.Add(GD_FC2_NOT_ACTUATES_ALIAS);
        end;
      else
        cbSign.Items.Add('>');
        cbSign.Items.Add('>=');
        cbSign.Items.Add('<');
        cbSign.Items.Add('<=');
      end;

      if DataType = GD_DT_CHAR then
      begin
        cbSign.Items.Add('LIKE');
        cbSign.Items.Add('NOT LIKE');
      end;

      if cbSign.Items.Count > 0 then
        cbSign.ItemIndex := 0;
    end;
    GD_FC_CUSTOM_FILTER, GD_FC_COMPLEXFIELD:
    begin
      pcEdits.ActivePage := tsFilter;
      cbFilter.Items.Clear;
      if ConditionList.Count = 0 then
        cbFilter.Items.Add('Задано 0 условия для фильтрации')
      else
        cbFilter.Items.Add(ConditionList.FilterText);
      cbFilter.ItemIndex := 0;
    end;
    GD_FC_QUERY_WHERE:
    begin
      pcEdits.ActivePage := tsFormula;
      cbFormula.Enabled := True;
    end;
    GD_FC_QUERY_ALL:
    begin
      // Создавать новый запрос имеет право только Administrator
      pcEdits.ActivePage := tsFormula;
      cbFormula.Enabled := GetUserKey and 1 = 1;
    end;
    GD_FC_ACTUATES, GD_FC_ACTUATES_TREE, GD_FC_NOT_ACTUATES, GD_FC_NOT_ACTUATES_TREE,
    GD_FC_INCLUDES:
    begin

      // В зависимости от типа данных настраиваем этот компонент
      case DataType of
        GD_DT_REF_SET_ELEMENT, GD_DT_REF_SET:
        begin
          pcEdits.ActivePage := tsCombo;
          gscbSet.DialogType :=
           TfltFieldData(ctbFields.SelectedNode.Data).IsReference;
          gscbSet.FieldName :=
           TfltFieldData(ctbFields.SelectedNode.Data).DisplayName;
          gscbSet.UserAttr := False;
          gscbSet.TableName :=
           TfltFieldData(ctbFields.SelectedNode.Data).RefTable;
          gscbSet.PrimaryName :=
           TfltFieldData(ctbFields.SelectedNode.Data).RefField;
          gscbSet.ValueIDChange(Self);
        end;

        GD_DT_CHILD_SET:
        begin
          pcEdits.ActivePage := tsCombo;
          gscbSet.DialogType :=
           TfltFieldData(ctbFields.SelectedNode.Data).IsReference;
          gscbSet.FieldName :=
           TfltFieldData(ctbFields.SelectedNode.Data).DisplayName;
          gscbSet.UserAttr := False;
          gscbSet.TableName :=
           TfltFieldData(ctbFields.SelectedNode.Data).LinkTable;
          gscbSet.PrimaryName :=
           TfltFieldData(ctbFields.SelectedNode.Data).LinkTargetField;
          gscbSet.ValueIDChange(Self);
        end;

        GD_DT_ATTR_SET_ELEMENT, GD_DT_ATTR_SET:
        begin
          pcEdits.ActivePage := tsCombo;
          gscbSet.DialogType :=
           TfltFieldData(ctbFields.SelectedNode.Data).IsReference;
          gscbSet.FieldName :=
           TfltFieldData(ctbFields.SelectedNode.Data).DisplayName;
          gscbSet.UserAttr := True;
          gscbSet.DialogType :=
           TfltFieldData(ctbFields.SelectedNode.Data).IsReference;
          gscbSet.AttrKey :=
           TfltFieldData(ctbFields.SelectedNode.Data).AttrKey;
          gscbSet.ValueIDChange(Self);
        end;

        GD_DT_ENUMERATION:
        begin
          pcEdits.ActivePage := tsEnumSet;
          escbEnumSet.TableName := TfltFieldData(ctbFields.SelectedNode.Data).TableName;
          escbEnumSet.FieldName := TfltFieldData(ctbFields.SelectedNode.Data).FieldName;
        end;
      end;
    end;
  else
    pcEdits.ActivePage := tsEmpty;
  end;
end;

procedure TfrFilterLine.cbConditionChange(Sender: TObject);
begin
  SetValues;
end;

procedure TfrFilterLine.cbConditionExit(Sender: TObject);
begin
  if cbCondition.ItemIndex = -1 then
    pcEdits.ActivePage := tsEmpty;
end;

// Действия по выбору условия фильтрация
procedure TfrFilterLine.cbFilterDropDown(Sender: TObject);
var
  TableList: TfltStringList;
begin
  with TdlgShowFilter.Create(Self) do
  try
    // Необходимые установки
    Database := IBDatabase;
    Transaction := IBTransaction;
    if ExtractCondition(cbCondition.ItemIndex,
     TfltFieldData(ctbFields.SelectedNode.Data).FieldType) = GD_FC_COMPLEXFIELD then
    begin
      // Если задана дополнительная фильтрация вызывается другая процедура
      if ShowLinkTableFilter(ConditionList, TfltFieldData(ctbFields.SelectedNode.Data).LinkTable,
       TfltFieldData(ctbFields.SelectedNode.Data).LinkSourceField) then
      begin
        cbFilter.Items.Clear;
        if ConditionList.Count = 0 then
          cbFilter.Items.Add('Задано 0 условия для фильтрации')
        else
          cbFilter.Items.Add(ConditionList.FilterText);
        cbFilter.ItemIndex := 0;
      end;
    end else
    begin
      // Создаем окно фильтра, вызываем стандартный метод
      TableList := TfltStringList.Create;
      try
        TableList.Clear;
        // Используемые ячейки для хранения данных для типов "многий ко многим" и "один ко многим" разные
        // Это было необходимо вроде для удобства построения запроса
        if TfltFieldData(ctbFields.SelectedNode.Data).FieldType = GD_DT_CHILD_SET then
          TableList.Add(TfltFieldData(ctbFields.SelectedNode.Data).LinkTable + '=0')
        else
          TableList.Add(TfltFieldData(ctbFields.SelectedNode.Data).RefTable + '=0');
        if ShowFilter(ConditionList, nil, NoVisibleList, TableList, nil, True) then
        begin
          cbFilter.Items.Clear;
          if ConditionList.Count = 0 then
            cbFilter.Items.Add('Задано 0 условий для фильтрации')
          else
            cbFilter.Items.Add(ConditionList.FilterText);
          cbFilter.ItemIndex := 0;
        end;
      finally
        TableList.Free;
      end;
    end;
  finally
    Free;
    cbFilter.Refresh;
  end;
end;

procedure TfrFilterLine.edConditionExit(Sender: TObject);
begin
{  if not CheckTypeValue then
    (Sender as TEdit).SetFocus;}
end;

// Чисто проверка на совместимость типов и правильность ввода данных
function TfrFilterLine.CheckTypeValue: Boolean;
var
  I: Integer;
  FSign: String;
begin
  Result := True;
  if ctbFields.SelectedNode = nil then
    Exit;

  // В зависимости от типа данных
  case TfltFieldData(ctbFields.SelectedNode.Data).FieldType of
    // Проверяем правильность ввода формулы
    GD_DT_FORMULA:
      Result := CheckFormula(cbCondition.ItemIndex = 0);
    // Пытаемся перевести строку в число
    GD_DT_DIGITAL:
    try
      case ExtractCondition(cbCondition.ItemIndex, GD_DT_DIGITAL) of
        GD_FC_SCRIPT:
        begin
        {  if (edScript.Text > '') and (cbLanguage.Text > '') then
            for I := 0 to LanguageCount - 1 do
              if Trim(UpperCase(LanguageList[I])) = Trim(UpperCase(cbLanguage.Text)) then
                StrToFloat(FilterScript.GetScriptResult(edScript.Text, cbLanguage.Text, FSign));}
        end;
      else
        if edCondition.Text > '' then
          StrToFloat(edCondition.Text);
        if edFrom.Text > '' then
          StrToFloat(edFrom.Text);
        if edTo.Text > '' then
          StrToFloat(edTo.Text);
      end;
    except
      Result := False;
    end;

    // Пытаемся перевести строку в дату или число в зав-ти от условия
    GD_DT_DATE, GD_DT_TIMESTAMP:
    try
      case ExtractCondition(cbCondition.ItemIndex, GD_DT_DATE) of
        GD_FC_LAST_N_DAYS:
          if edCondition.Text > '' then
            StrToInt(edCondition.Text);
        GD_FC_BETWEEN, GD_FC_BETWEEN_LIMIT, GD_FC_OUT, GD_FC_OUT_LIMIT:
        begin
          if (edTo.Text > '') then
            StrToDateTime(edTo.Text);
          if (edFrom.Text > '') then
            StrToDateTime(edFrom.Text);
        end;
        GD_FC_SCRIPT:
        begin
          if (edScript.Text > '') and (cbLanguage.Text > '') then
            for I := 0 to LanguageCount - 1 do
              if Trim(UpperCase(LanguageList[I])) = Trim(UpperCase(cbLanguage.Text)) then
                StrToDateTime(FilterScript.GetScriptResult(edScript.Text, cbLanguage.Text, FSign));
        end;
        GD_FC_TODAY, GD_FC_SELDAY:;
        else
          if edCondition.Text > '' then
            StrToDateTime(edCondition.Text);
      end;
    except
      Result := False;
    end;

    // Пытаемся перевести строку во время
    GD_DT_TIME:
    try
      case ExtractCondition(cbCondition.ItemIndex, GD_DT_TIME) of
        GD_FC_SCRIPT:
        begin
          if (edScript.Text > '') and (cbLanguage.Text > '') then
            for I := 0 to LanguageCount - 1 do
              if Trim(UpperCase(LanguageList[I])) = Trim(UpperCase(cbLanguage.Text)) then
                StrToTime(FilterScript.GetScriptResult(edScript.Text, cbLanguage.Text, FSign));
        end;
      else
        if edCondition.Text > '' then
          StrToTime(edCondition.Text);
      end;
    except
      Result := False;
    end;

    // По большому счету лишняя проверка. Устарело. {gs}
    GD_DT_UNKNOWN_SET:
    case TfltFieldData(ctbFields.SelectedNode.Data).LinkTargetFieldType of
      GD_DT_DIGITAL:
      try
        if edCondition.Text > '' then
          StrToFloat(edCondition.Text);
        if edFrom.Text > '' then
          StrToFloat(edFrom.Text);
        if edFrom.Text > '' then
          StrToFloat(edTo.Text);
      except
        Result := False;
      end;

      GD_DT_DATE, GD_DT_TIMESTAMP:
      try
        case ExtractCondition(cbCondition.ItemIndex, GD_DT_DATE) of
          GD_FC_LAST_N_DAYS:
            if edCondition.Text > '' then
              StrToInt(edCondition.Text);
          GD_FC_BETWEEN, GD_FC_BETWEEN_LIMIT, GD_FC_OUT, GD_FC_OUT_LIMIT:
            if (edTo.Text > '') and (edFrom.Text > '') then
            begin
              StrToDateTime(edTo.Text);
              StrToDateTime(edFrom.Text);
            end;
          GD_FC_TODAY, GD_FC_SELDAY:;
          else
            if edCondition.Text > '' then
              StrToDateTime(edCondition.Text);
        end;
      except
        Result := False;
      end;

      GD_DT_TIME:
      try
        if edCondition.Text > '' then
          StrToTime(edCondition.Text);
      except
        Result := False;
      end;

    end
  else
    if ExtractCondition(cbCondition.ItemIndex,
     TfltFieldData(ctbFields.SelectedNode.Data).FieldType) = GD_FC_SCRIPT then
    try
      FilterScript.GetScriptResult(edScript.Text, cbLanguage.Text, FSign);
    except
      Result := False;
    end;
  end;

  if not Result then
    MessageBox(Self.Handle, 'Неверно задано значение поля.', 'Внимание',
     MB_OK or MB_ICONWARNING);
end;

destructor TfrFilterLine.Destroy;
begin
  ConditionList.Free;
  NoVisibleList.Free;
  FTableList.Free;
  SortFieldList.Free;
  FunctionList.Free;

  inherited;
end;

constructor TfrFilterLine.Create(AnOwner: TComponent);
var
  I: Integer;
begin
  inherited;

  ConditionList := TFilterConditionList.Create;
  NoVisibleList := TStringList.Create;
  FTableList := TfltStringList.Create;
  SortFieldList := TStringList.Create;
  FunctionList := TStringList.Create;
  pcEdits.ActivePage := tsEmpty;
  // Здесь происходит заполнения доступных языков для скриптов
  cbLanguage.Items.Clear;
  for I := 0 to LanguageCount - 1 do
    cbLanguage.Items.Add(Trim(LanguageList[I]));
end;

// Действия по вводу формулы
procedure TfrFilterLine.cbFormulaDropDown(Sender: TObject);
var
  {$IFDEF SYNEDIT}
  F: TdlgInputFormulaSyn;
  {$ELSE}
  F: TdlgInputFormula;
  {$ENDIF}
  S: String;
begin
  // Создаем окно для ввода формулы
  {$IFDEF SYNEDIT}
  F := TdlgInputFormulaSyn.Create(Self);
  {$ELSE}
  F := TdlgInputFormula.Create(Self);
  {$ENDIF}
  try
    // Если формула уже введена то присваиваем ее
    if Trim(cbFormula.Text) > '' then
      S := cbFormula.Text
    else
      // Если создается запрос и не введен текст, то присваиваем текущий
      if ExtractCondition(cbCondition.ItemIndex, GD_DT_FORMULA) = GD_FC_QUERY_ALL then
        S := SQLText;

    // Возможность создания процедур только, если создается свой запрос
    F.btnProcedure.Visible := ExtractCondition(cbCondition.ItemIndex, GD_DT_FORMULA) = GD_FC_QUERY_ALL;
    // Необходимые установки
    F.PIBDatabase := IBDatabase;
    F.PIBTransaction := IBTransaction;

    // Вызов функции для ввода формулы
    if F.InputFormula(S, SortFieldList, FunctionList, FComponentKey) then
      cbFormula.Text := S;
  finally
    F.Free;
    cbFormula.Refresh;
  end;
end;

procedure TfrFilterLine.bbtnCloseClick(Sender: TObject);
var
  I: Integer;
begin
  // Если нажата кнопка закрыть посылаем родителю соответствующее сообщение
  I := Integer(Self);
  PostMessage(Parent.Parent.Parent.Parent.Handle, WM_USER, WM_CLOSEFILTERLINE, I);
end;

// Функция проверки формулы
function TfrFilterLine.GetUserKey: Integer;
begin
  if IBLogin <> nil then
    Result := IBLogin.Ingroup
  else
    Result := 1;
end;

function TfrFilterLine.CheckFormula(FormulaType: Boolean): Boolean;
var
  ibsqlTemp: TIBSQL;
  I: Integer;
begin
  Result := True;
  // Если формула не введена то выходим
  if Trim(cbFormula.Text) = '' then
    Exit;
  ibsqlTemp := TIBSQL.Create(Self);
  try
    ibsqlTemp.Database := IBDatabase;
    ibsqlTemp.Transaction := IBTransaction;
    if FormulaType then
    begin
      // Если вводятся условия, то создаем запрос
      ibsqlTemp.SQL.Text := 'SELECT * FROM ';
      for I := 0 to FTableList.Count - 1 do
      begin
        ibsqlTemp.SQL.Add(FTableList.Names[I] + ' ' + Copy(FTableList.ValuesOfIndex[I], 1, Length(FTableList.ValuesOfIndex[I]) - 1));
        ibsqlTemp.SQL.Add(',');
      end;
      ibsqlTemp.SQL.Strings[ibsqlTemp.SQL.Count - 1] := 'WHERE ' + cbFormula.Text;
    end else
      // иначе просто присваиваем текст
      ibsqlTemp.SQL.Text := cbFormula.Text;
    try
      // Посылаем запрос на сервер для проверки его корректности
      ibsqlTemp.Prepare;
    except
      // Обработка ошибки
      on E: Exception do
      begin
        if FormulaType then
          Result := MessageBox(Handle, PChar('Условие задано не верно.'#13#10 + E.Message +
           #13#10 + 'Отменить сохранение?'), 'Внимание', MB_YESNO or MB_ICONSTOP) = IDNO
        else
        begin
          MessageBox(Handle, PChar('Формула написана неверно.'#13#10 + E.Message), 'Внимание',
           MB_OK or MB_ICONSTOP);
          Result := False;
        end;
        if not Result then
          cbFormula.SetFocus;
      end;
    end;
  finally
    ibsqlTemp.Free;
  end;
end;

procedure TfrFilterLine.SpeedButton1Click(Sender: TObject);
var
  TempStr: String;
  FSign: String;
begin
  if Trim(edScript.Text) > '' then
  begin
    try
      TempStr := FilterScript.GetScriptResult(edScript.Text, cbLanguage.Text, FSign);
      MessageBox(0, PChar(FSign + TempStr), 'Результат выполнения скрипта',
        MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);
    except
      on E: Exception do
        MessageBox(0, PChar(E.Message), 'Ошибка при выполнении скрипта',
        MB_OK or MB_ICONERROR or MB_TASKMODAL);
    end;
  end;  
end;

end.
