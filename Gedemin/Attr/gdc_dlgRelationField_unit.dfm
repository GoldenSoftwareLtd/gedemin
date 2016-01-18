inherited gdc_dlgRelationField: Tgdc_dlgRelationField
  Left = 419
  Top = 196
  HelpContext = 86
  Caption = 'Редактирование поля'
  ClientHeight = 435
  ClientWidth = 471
  Visible = True
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 4
    Top = 407
    TabOrder = 3
  end
  inherited btnNew: TButton
    Left = 76
    Top = 407
    TabOrder = 4
  end
  inherited btnHelp: TButton
    Left = 148
    Top = 407
    TabOrder = 5
  end
  inherited btnOK: TButton
    Left = 326
    Top = 407
    TabOrder = 1
  end
  inherited btnCancel: TButton
    Left = 399
    Top = 407
    TabOrder = 2
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
        Width = 126
        Height = 13
        Caption = 'Название поля таблицы:'
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
        Width = 80
        Height = 14
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
        Width = 183
        Height = 13
        Caption = 'Краткое локализованное название:'
      end
      object Label5: TLabel
        Left = 12
        Top = 161
        Width = 80
        Height = 13
        Caption = 'Описание поля:'
      end
      object Label7: TLabel
        Left = 7
        Top = 10
        Width = 444
        Height = 17
        AutoSize = False
        Caption = '  Наименование поля'
        Color = clHighlight
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindow
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentColor = False
        ParentFont = False
        Layout = tlCenter
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
      object dbedRelationFieldDescription: TDBMemo
        Left = 250
        Top = 156
        Width = 201
        Height = 54
        DataField = 'DESCRIPTION'
        DataSource = dsgdcBase
        TabOrder = 3
      end
      object pnlType: TPanel
        Left = 0
        Top = 232
        Width = 455
        Height = 137
        Align = alBottom
        BevelOuter = bvNone
        BorderWidth = 4
        TabOrder = 4
        object pcType: TPageControl
          Left = 4
          Top = 4
          Width = 447
          Height = 129
          ActivePage = tsType
          Align = alClient
          TabOrder = 0
          object tsType: TTabSheet
            Caption = 'Тип данных'
            object lblDefaultValue: TLabel
              Left = 4
              Top = 64
              Width = 127
              Height = 13
              Caption = 'Значение по умолчанию:'
            end
            object lblRuleDelete: TLabel
              Left = 4
              Top = 39
              Width = 112
              Height = 13
              Caption = 'При удалении записи:'
              Visible = False
            end
            object Label6: TLabel
              Left = 4
              Top = 10
              Width = 49
              Height = 13
              Caption = 'Тип поля:'
            end
            object dbcbNotNull: TDBCheckBox
              Left = 340
              Top = 10
              Width = 57
              Height = 17
              Caption = 'Not Null'
              DataField = 'nullflag'
              DataSource = dsgdcBase
              TabOrder = 0
              ValueChecked = '1'
              ValueUnchecked = '0'
            end
            object luFieldType: TgsIBLookupComboBox
              Left = 128
              Top = 6
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
              TabOrder = 1
              OnChange = luFieldTypeChange
            end
            object edDefaultValue: TDBMemo
              Left = 136
              Top = 60
              Width = 201
              Height = 21
              DataField = 'defsource'
              DataSource = dsgdcBase
              TabOrder = 2
              WordWrap = False
            end
            object cmbRuleDelete: TComboBox
              Left = 128
              Top = 35
              Width = 201
              Height = 21
              Style = csDropDownList
              ItemHeight = 13
              ParentShowHint = False
              ShowHint = True
              TabOrder = 3
              Visible = False
              Items.Strings = (
                'RESTRICT'
                'NO ACTION'
                'CASCADE'
                'SET NULL'
                'SET DEFAULT')
            end
          end
          object tsCalculated: TTabSheet
            BorderWidth = 2
            Caption = 'Вычисляемое поле'
            ImageIndex = 1
            object lComputed: TLabel
              Left = 0
              Top = 0
              Width = 435
              Height = 13
              Align = alTop
              Caption = 'Выражение  для вычисляемого поля на языке SQL:'
              Visible = False
            end
            object dbmComputed: TDBMemo
              Left = 0
              Top = 13
              Width = 435
              Height = 84
              Align = alClient
              DataField = 'COMPUTED_VALUE'
              DataSource = dsgdcBase
              TabOrder = 0
              Visible = False
              OnChange = dbmComputedChange
            end
          end
        end
      end
    end
    object tsVisualSettings: TTabSheet
      Caption = 'Визуальные'
      ImageIndex = 1
      object Label8: TLabel
        Left = 7
        Top = 10
        Width = 443
        Height = 17
        AutoSize = False
        Caption = '  Визуальные настройки'
        Color = clHighlight
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
        Top = 112
        Width = 84
        Height = 13
        Caption = 'Формат вывода:'
      end
      object dbrgAligment: TDBRadioGroup
        Left = 6
        Top = 136
        Width = 444
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
        Left = 10
        Top = 62
        Width = 327
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
        Width = 155
        Height = 21
        DataField = 'FORMAT'
        DataSource = dsgdcBase
        TabOrder = 3
      end
      object dbcbReadOnly: TDBCheckBox
        Left = 10
        Top = 85
        Width = 327
        Height = 17
        Alignment = taLeftJustify
        Caption = 'Запретить редактирование поля'
        DataField = 'READONLY'
        DataSource = dsgdcBase
        TabOrder = 2
        ValueChecked = '1'
        ValueUnchecked = '0'
      end
      object pnlBC: TPanel
        Left = 6
        Top = 189
        Width = 444
        Height = 95
        BevelInner = bvRaised
        BevelOuter = bvLowered
        TabOrder = 5
        object lblBusinessClass: TLabel
          Left = 12
          Top = 11
          Width = 70
          Height = 13
          Caption = 'Бизнес-класс:'
        end
        object Label9: TLabel
          Left = 12
          Top = 40
          Width = 42
          Height = 13
          Caption = 'Подтип:'
        end
        object dbedBusinessClass: TDBEdit
          Left = 170
          Top = 10
          Width = 157
          Height = 21
          DataField = 'GDCLASSNAME'
          DataSource = dsgdcBase
          TabOrder = 0
        end
        object dbedSubType: TDBEdit
          Left = 170
          Top = 37
          Width = 157
          Height = 21
          DataField = 'GDSUBTYPE'
          DataSource = dsgdcBase
          TabOrder = 1
        end
        object btnSelectBC: TButton
          Left = 169
          Top = 64
          Width = 75
          Height = 21
          Action = actSelectBC
          TabOrder = 2
        end
        object btnDelBC: TButton
          Left = 251
          Top = 64
          Width = 75
          Height = 21
          Action = actDelBC
          TabOrder = 3
        end
      end
    end
    object tsObjects: TTabSheet
      Caption = 'Объекты'
      ImageIndex = 2
      object Bevel1: TBevel
        Left = 6
        Top = 6
        Width = 443
        Height = 294
        Shape = bsFrame
      end
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
      object Label10: TLabel
        Left = 0
        Top = 333
        Width = 455
        Height = 18
        Align = alBottom
        AutoSize = False
        Caption = ' Для отображения поля во всех классах оставьте список пустым.'
        Layout = tlCenter
      end
      object btnAddObjects: TButton
        Left = 291
        Top = 304
        Width = 75
        Height = 21
        Action = actAddObject
        TabOrder = 1
      end
      object btnDelObject: TButton
        Left = 373
        Top = 304
        Width = 75
        Height = 21
        Action = actDelObject
        TabOrder = 2
      end
      object lbClasses: TListBox
        Left = 16
        Top = 16
        Width = 422
        Height = 273
        ItemHeight = 13
        TabOrder = 0
      end
    end
  end
  inherited alBase: TActionList
    Left = 82
    Top = 359
    object actAddObject: TAction
      Caption = 'Добавить...'
      OnExecute = actAddObjectExecute
    end
    object actDelObject: TAction
      Caption = 'Удалить...'
      OnExecute = actDelObjectExecute
      OnUpdate = actDelObjectUpdate
    end
    object actSelectBC: TAction
      Caption = 'Выбрать...'
      OnExecute = actSelectBCExecute
      OnUpdate = actSelectBCUpdate
    end
    object actDelBC: TAction
      Caption = 'Очистить'
      OnExecute = actDelBCExecute
      OnUpdate = actDelBCUpdate
    end
  end
  inherited dsgdcBase: TDataSource
    Left = 36
    Top = 359
  end
  inherited pm_dlgG: TPopupMenu
    Left = 120
    Top = 360
  end
  inherited ibtrCommon: TIBTransaction
    Left = 216
    Top = 360
  end
end
