inherited gdc_dlgRelationField: Tgdc_dlgRelationField
  Left = 260
  Top = 151
  HelpContext = 86
  ActiveControl = dbedRelationFieldName
  Caption = 'Редактирование поля'
  ClientHeight = 435
  ClientWidth = 471
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Top = 406
    Anchors = [akLeft, akBottom]
    TabOrder = 3
  end
  inherited btnNew: TButton
    Top = 406
    Anchors = [akLeft, akBottom]
    TabOrder = 4
  end
  inherited btnOK: TButton
    Left = 311
    Top = 406
    Anchors = [akRight, akBottom]
    TabOrder = 1
  end
  inherited btnCancel: TButton
    Left = 391
    Top = 406
    Anchors = [akRight, akBottom]
    TabOrder = 2
  end
  inherited btnHelp: TButton
    Top = 406
    Anchors = [akLeft, akBottom]
    TabOrder = 5
  end
  object pcRelationField: TPageControl [5]
    Left = 4
    Top = 4
    Width = 463
    Height = 397
    ActivePage = tsCommon
    TabOrder = 0
    OnChange = pcRelationFieldChange
    object tsCommon: TTabSheet
      Caption = 'Общие'
      object Label1: TLabel
        Left = 12
        Top = 69
        Width = 189
        Height = 13
        Caption = 'Название поля на английском языке:'
      end
      object lblTableName: TLabel
        Left = 12
        Top = 39
        Width = 46
        Height = 13
        Caption = 'Таблица:'
      end
      object dbtRelationName: TDBText
        Left = 250
        Top = 39
        Width = 82
        Height = 13
        AutoSize = True
        DataField = 'RELATIONNAME'
        DataSource = dsgdcBase
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsUnderline]
        ParentFont = False
      end
      object Label3: TLabel
        Left = 12
        Top = 99
        Width = 138
        Height = 13
        Caption = 'Локализованное название:'
      end
      object Label4: TLabel
        Left = 12
        Top = 129
        Width = 97
        Height = 13
        Caption = 'Краткое название:'
      end
      object Label5: TLabel
        Left = 12
        Top = 169
        Width = 80
        Height = 13
        Caption = 'Описание поля:'
      end
      object Label6: TLabel
        Left = 12
        Top = 225
        Width = 49
        Height = 13
        Caption = 'Тип поля:'
      end
      object Label7: TLabel
        Left = 12
        Top = 10
        Width = 439
        Height = 17
        AutoSize = False
        Caption = '  Наименование поля'
        Color = clBlack
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindow
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentColor = False
        ParentFont = False
        Layout = tlCenter
      end
      object lblDefaultValue: TLabel
        Left = 12
        Top = 255
        Width = 127
        Height = 13
        Caption = 'Значение по умолчанию:'
      end
      object lComputed: TLabel
        Left = 16
        Top = 312
        Width = 256
        Height = 13
        Caption = 'Выражение  для вычисляемого поля на языке SQL'
        Visible = False
      end
      object lblRuleDelete: TLabel
        Left = 12
        Top = 287
        Width = 99
        Height = 13
        Caption = 'Правило удаления:'
        Visible = False
      end
      object dbedRelationFieldName: TDBEdit
        Left = 250
        Top = 65
        Width = 201
        Height = 21
        CharCase = ecUpperCase
        DataField = 'FIELDNAME'
        DataSource = dsgdcBase
        MaxLength = 31
        TabOrder = 0
        OnEnter = dbedRelationFieldNameEnter
        OnKeyDown = dbedRelationFieldNameKeyDown
        OnKeyPress = dbedRelationFieldNameKeyPress
      end
      object dbedRelationFieldLName: TDBEdit
        Left = 250
        Top = 95
        Width = 201
        Height = 21
        DataField = 'LNAME'
        DataSource = dsgdcBase
        TabOrder = 1
      end
      object dbedRelationFieldShortLName: TDBEdit
        Left = 250
        Top = 125
        Width = 201
        Height = 21
        DataField = 'LSHORTNAME'
        DataSource = dsgdcBase
        TabOrder = 2
      end
      object luFieldType: TgsIBLookupComboBox
        Left = 250
        Top = 221
        Width = 201
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = ibtrCommon
        DataSource = dsgdcBase
        DataField = 'FIELDSOURCEKEY'
        Fields = 'fieldname'
        ListTable = 'at_fields'
        ListField = 'lname'
        KeyField = 'id'
        SortOrder = soAsc
        gdClassName = 'TgdcField'
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 6
        OnChange = luFieldTypeChange
      end
      object edDefaultValue: TDBMemo
        Left = 250
        Top = 251
        Width = 201
        Height = 21
        DataField = 'defsource'
        DataSource = dsgdcBase
        TabOrder = 7
        WordWrap = False
      end
      object dbedRelationFieldDescription: TDBMemo
        Left = 250
        Top = 157
        Width = 201
        Height = 54
        DataField = 'DESCRIPTION'
        DataSource = dsgdcBase
        TabOrder = 3
      end
      object dbmComputed: TDBMemo
        Left = 16
        Top = 328
        Width = 433
        Height = 38
        DataField = 'COMPUTED_VALUE'
        DataSource = dsgdcBase
        TabOrder = 8
        Visible = False
        OnChange = dbmComputedChange
      end
      object cbCalculated: TCheckBox
        Left = 149
        Top = 224
        Width = 97
        Height = 17
        Caption = 'Вычисляемое'
        TabOrder = 5
        OnClick = cbCalculatedClick
      end
      object cmbRuleDelete: TComboBox
        Left = 250
        Top = 283
        Width = 201
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 9
        Visible = False
        OnChange = cmbRuleDeleteChange
        Items.Strings = (
          'Запрещать удаление при удалении главной записи'
          'Удалять, если удаляется главная запись'
          'Устанавливать значение NULL'
          'Устанавливать значение по умолчанию')
      end
      object dbcbNotNull: TDBCheckBox
        Left = 76
        Top = 225
        Width = 57
        Height = 17
        Caption = 'Not Null'
        DataField = 'nullflag'
        DataSource = dsgdcBase
        TabOrder = 4
        ValueChecked = '1'
        ValueUnchecked = '0'
      end
    end
    object tsVisualSettings: TTabSheet
      Caption = 'Визуальные'
      ImageIndex = 1
      object Label8: TLabel
        Left = 12
        Top = 10
        Width = 439
        Height = 17
        AutoSize = False
        Caption = '  Визуальные настройки'
        Color = clBlack
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindow
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentColor = False
        ParentFont = False
        Layout = tlCenter
      end
      object Label14: TLabel
        Left = 12
        Top = 37
        Width = 163
        Height = 13
        Caption = 'Ширина поля при отображении:'
      end
      object lblFormat: TLabel
        Left = 12
        Top = 113
        Width = 84
        Height = 13
        Caption = 'Формат вывода:'
      end
      object lblBusinessClass: TLabel
        Left = 12
        Top = 207
        Width = 70
        Height = 13
        Caption = 'Бизнес-класс:'
      end
      object lblClassSubType: TLabel
        Left = 12
        Top = 235
        Width = 79
        Height = 13
        Caption = 'Подтип класса:'
      end
      object dbrgAligment: TDBRadioGroup
        Left = 12
        Top = 144
        Width = 439
        Height = 45
        Caption = ' Выравнивание: '
        Columns = 3
        DataField = 'ALIGNMENT'
        DataSource = dsgdcBase
        Items.Strings = (
          'По левому краю'
          'По правому краю'
          'По центру')
        TabOrder = 4
        Values.Strings = (
          'L'
          'R'
          'C')
      end
      object dbedColWidth: TDBEdit
        Left = 182
        Top = 34
        Width = 155
        Height = 21
        DataField = 'COLWIDTH'
        DataSource = dsgdcBase
        TabOrder = 0
      end
      object dbcbVisible: TDBCheckBox
        Left = 12
        Top = 62
        Width = 326
        Height = 17
        Alignment = taLeftJustify
        Caption = 'Поле является видимым по умолчанию'
        DataField = 'VISIBLE'
        DataSource = dsgdcBase
        TabOrder = 1
        ValueChecked = '1'
        ValueUnchecked = '0'
      end
      object dbedFormat: TDBEdit
        Left = 182
        Top = 109
        Width = 156
        Height = 21
        DataField = 'FORMAT'
        DataSource = dsgdcBase
        TabOrder = 3
      end
      object dbcbReadOnly: TDBCheckBox
        Left = 12
        Top = 85
        Width = 326
        Height = 17
        Alignment = taLeftJustify
        Caption = 'Запретить редактирование поля'
        DataField = 'READONLY'
        DataSource = dsgdcBase
        TabOrder = 2
        ValueChecked = '1'
        ValueUnchecked = '0'
      end
      object comboBusinessClass: TComboBox
        Left = 182
        Top = 203
        Width = 270
        Height = 21
        Style = csDropDownList
        ItemHeight = 0
        Sorted = True
        TabOrder = 5
        OnChange = comboBusinessClassChange
        OnClick = comboBusinessClassClick
      end
      object comboClassSubType: TComboBox
        Left = 182
        Top = 231
        Width = 270
        Height = 21
        Style = csDropDownList
        ItemHeight = 0
        Sorted = True
        TabOrder = 6
      end
    end
    object tsObjects: TTabSheet
      Caption = 'Объекты'
      ImageIndex = 2
      object Label2: TLabel
        Left = 0
        Top = 351
        Width = 455
        Height = 18
        Align = alBottom
        AutoSize = False
        Caption = ' Изменения вступят в силу после перезагрузки Гедымина.'
        Layout = tlCenter
      end
      object tvObjects: TgsTreeView
        Left = 0
        Top = 0
        Width = 455
        Height = 351
        Align = alClient
        Indent = 19
        ReadOnly = True
        RightClickSelect = True
        TabOrder = 0
        WithCheckBox = True
      end
    end
  end
  inherited alBase: TActionList
    Left = 50
  end
  inherited dsgdcBase: TDataSource
    Left = 20
  end
  inherited ibtrCommon: TIBTransaction
    Left = 408
    Top = 240
  end
end
