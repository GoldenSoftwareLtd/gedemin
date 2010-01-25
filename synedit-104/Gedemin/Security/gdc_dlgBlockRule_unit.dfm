inherited gdc_dlgBlockRule: Tgdc_dlgBlockRule
  Left = 284
  Top = 0
  Caption = 'Правило блокировки'
  ClientHeight = 701
  ClientWidth = 618
  Font.Charset = DEFAULT_CHARSET
  OldCreateOrder = False
  OnActivate = FormActivate
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 5
    Top = 672
  end
  inherited btnNew: TButton
    Left = 78
    Top = 672
  end
  inherited btnHelp: TButton
    Left = 152
    Top = 672
  end
  inherited btnOK: TButton
    Left = 465
    Top = 672
  end
  inherited btnCancel: TButton
    Left = 543
    Top = 672
  end
  inherited pgcMain: TPageControl
    Left = 5
    Width = 607
    Height = 660
    inherited tbsMain: TTabSheet
      inherited labelID: TLabel
        Left = 408
      end
      inherited dbtxtID: TDBText
        Left = 496
      end
      object lblName: TLabel
        Left = 8
        Top = 8
        Width = 122
        Height = 13
        Caption = 'Наименование правила:'
      end
      object dbeName: TDBEdit
        Left = 134
        Top = 4
        Width = 268
        Height = 21
        DataField = 'name'
        DataSource = dsgdcBase
        TabOrder = 0
      end
      object dbcbDisabled: TDBCheckBox
        Left = 6
        Top = 599
        Width = 145
        Height = 17
        Caption = 'Правило отключено'
        DataField = 'disabled'
        DataSource = dsgdcBase
        TabOrder = 1
        ValueChecked = '1'
        ValueUnchecked = '0'
      end
      object GroupBox1: TGroupBox
        Left = 7
        Top = 175
        Width = 586
        Height = 105
        Caption = ' Запретить изменение '
        TabOrder = 2
        object Label2: TLabel
          Left = 11
          Top = 72
          Width = 566
          Height = 24
          AutoSize = False
          Caption = 'Пример: contacttype = 2'
          WordWrap = True
        end
        object RadioButton1: TRadioButton
          Left = 9
          Top = 16
          Width = 113
          Height = 17
          Caption = 'Всех записей'
          Checked = True
          TabOrder = 0
          TabStop = True
          OnClick = RadioButton1Click
        end
        object dbmCondition: TDBMemo
          Left = 10
          Top = 36
          Width = 567
          Height = 22
          DataField = 'selectcondition'
          DataSource = dsgdcBase
          TabOrder = 1
        end
        object RadioButton2: TRadioButton
          Left = 103
          Top = 16
          Width = 257
          Height = 17
          Caption = 'Только записей, удовлетворяющих условию:'
          TabOrder = 2
          OnClick = RadioButton2Click
        end
      end
      object GroupBox2: TGroupBox
        Left = 7
        Top = 283
        Width = 586
        Height = 157
        Caption = ' В зависимости от даты создания/изменения '
        TabOrder = 3
        object lblDateField: TLabel
          Left = 12
          Top = 40
          Width = 103
          Height = 13
          Caption = 'Брать дату из поля:'
        end
        object Label3: TLabel
          Left = 79
          Top = 111
          Width = 37
          Height = 13
          Caption = '-го дня'
        end
        object Label1: TLabel
          Left = 375
          Top = 132
          Width = 62
          Height = 13
          Caption = 'дней назад.'
        end
        object RadioButton3: TRadioButton
          Left = 10
          Top = 16
          Width = 113
          Height = 17
          Caption = 'Для любой даты'
          Checked = True
          TabOrder = 0
          TabStop = True
          OnClick = RadioButton3Click
        end
        object RadioButton4: TRadioButton
          Left = 128
          Top = 16
          Width = 361
          Height = 17
          Caption = 'Созданных или измененных до указанной даты '
          TabOrder = 1
          OnClick = RadioButton4Click
        end
        object gsiblcDateField: TgsIBLookupComboBox
          Left = 119
          Top = 38
          Width = 276
          Height = 21
          HelpContext = 1
          DataSource = dsgdcBase
          ListTable = 'AT_RELATION_FIELDS'
          ListField = 'FIELDNAME'
          KeyField = 'id'
          ItemHeight = 13
          TabOrder = 2
          OnChange = gsiblcDateFieldChange
          OnEnter = gsiblcDateFieldEnter
        end
        object RadioButton5: TRadioButton
          Left = 10
          Top = 66
          Width = 327
          Height = 17
          Caption = 'Запрещать изменение записей созданных/измененных до: '
          TabOrder = 3
          OnClick = RadioButton5Click
        end
        object dbeDateBlock: TxDateDBEdit
          Left = 330
          Top = 64
          Width = 65
          Height = 21
          DataField = 'blockdate'
          DataSource = dsgdcBase
          Kind = kDate
          EditMask = '!99\.99\.9999;1;_'
          MaxLength = 10
          TabOrder = 4
        end
        object RadioButton6: TRadioButton
          Left = 10
          Top = 88
          Width = 321
          Height = 17
          Caption = 'Запрещать изменение записей созданных/измененных до:'
          TabOrder = 5
          OnClick = RadioButton6Click
        end
        object dbeDayNumber: TDBEdit
          Left = 47
          Top = 107
          Width = 30
          Height = 21
          DataField = 'daynumber'
          DataSource = dsgdcBase
          TabOrder = 6
        end
        object ComboBox1: TComboBox
          Left = 119
          Top = 107
          Width = 170
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 7
          Items.Strings = (
            'текущей недели'
            'текущего месяца'
            'текущего квартала'
            'текущего года'
            'предыдущей недели'
            'предыдущего месяца'
            'предыдущего квартала'
            'предыдущего года')
        end
        object RadioButton13: TRadioButton
          Left = 10
          Top = 131
          Width = 335
          Height = 17
          Caption = 'Запрещать изменение записей созданных/измененных более '
          TabOrder = 8
          OnClick = RadioButton13Click
        end
        object Edit1: TEdit
          Left = 344
          Top = 129
          Width = 26
          Height = 21
          TabOrder = 9
        end
      end
      object GroupBox3: TGroupBox
        Left = 7
        Top = 444
        Width = 586
        Height = 150
        Caption = ' Для групп пользователей '
        TabOrder = 4
        object rbAllGroups: TRadioButton
          Left = 10
          Top = 17
          Width = 49
          Height = 17
          Caption = 'Всех'
          Checked = True
          TabOrder = 0
          TabStop = True
          OnClick = rbAllGroupsClick
        end
        object RadioButton8: TRadioButton
          Left = 65
          Top = 17
          Width = 145
          Height = 17
          Caption = 'Только для указанных'
          TabOrder = 1
          OnClick = RadioButton8Click
        end
        object RadioButton9: TRadioButton
          Left = 209
          Top = 17
          Width = 161
          Height = 17
          Caption = 'Всех, кроме указанных'
          TabOrder = 2
          OnClick = RadioButton9Click
        end
        object chbxGroups: TCheckListBox
          Left = 10
          Top = 39
          Width = 569
          Height = 105
          BorderStyle = bsNone
          Columns = 4
          ItemHeight = 13
          Items.Strings = (
            'Пользователи'
            'Опытные пользователи'
            'Администраторы'
            'Операторы архива'
            'Операторы печати'
            'Гости')
          ParentColor = True
          TabOrder = 3
        end
      end
      object PageControl1: TPageControl
        Left = 7
        Top = 33
        Width = 591
        Height = 143
        ActivePage = tsForTable
        Style = tsButtons
        TabHeight = 19
        TabOrder = 5
        OnChange = PageControl1Change
        object tsForDocs: TTabSheet
          Caption = 'Для документов'
          object RadioButton10: TRadioButton
            Left = 5
            Top = 2
            Width = 49
            Height = 17
            Caption = 'Всех'
            Checked = True
            TabOrder = 0
            TabStop = True
            OnClick = RadioButton10Click
          end
          object RadioButton11: TRadioButton
            Left = 61
            Top = 2
            Width = 185
            Height = 17
            Caption = 'Только для указанных типов'
            TabOrder = 1
            OnClick = RadioButton11Click
          end
          object RadioButton12: TRadioButton
            Left = 253
            Top = 2
            Width = 185
            Height = 17
            Caption = 'Всех, кроме указанных типов'
            TabOrder = 2
            OnClick = RadioButton12Click
          end
          object mDocumentTypes: TMemo
            Left = 6
            Top = 21
            Width = 576
            Height = 68
            TabStop = False
            ParentColor = True
            ReadOnly = True
            ScrollBars = ssVertical
            TabOrder = 3
          end
          object Button2: TButton
            Left = 506
            Top = 93
            Width = 75
            Height = 21
            Caption = 'Изменить...'
            TabOrder = 4
            OnClick = Button2Click
          end
        end
        object tsForTable: TTabSheet
          Caption = 'Для таблицы'
          ImageIndex = 1
          object lblTableName: TLabel
            Left = 5
            Top = 7
            Width = 46
            Height = 13
            Caption = 'Таблица:'
          end
          object gsiblcTableName: TgsIBLookupComboBox
            Left = 54
            Top = 3
            Width = 268
            Height = 21
            HelpContext = 1
            DataSource = dsgdcBase
            ListTable = 'AT_RELATIONS'
            ListField = 'RELATIONNAME'
            KeyField = 'id'
            StrictOnExit = False
            ItemHeight = 13
            TabOrder = 0
            OnChange = gsiblcTableNameChange
            OnEnter = gsiblcTableNameEnter
          end
          object GroupBox4: TGroupBox
            Left = 5
            Top = 28
            Width = 577
            Height = 85
            Caption = ' Для иерархических структур рассматривать записи  '
            TabOrder = 1
            object Label4: TLabel
              Left = 12
              Top = 65
              Width = 149
              Height = 13
              Caption = 'Включая вложенные уровни.'
            end
            object RadioButton14: TRadioButton
              Left = 10
              Top = 17
              Width = 49
              Height = 17
              Caption = 'Все'
              Checked = True
              TabOrder = 0
              TabStop = True
              OnClick = RadioButton14Click
            end
            object RadioButton15: TRadioButton
              Left = 65
              Top = 17
              Width = 160
              Height = 17
              Caption = 'Только из указанной ветви'
              TabOrder = 1
              OnClick = RadioButton15Click
            end
            object RadioButton16: TRadioButton
              Left = 233
              Top = 17
              Width = 192
              Height = 17
              Caption = 'Только не из указанной ветви'
              TabOrder = 2
              OnClick = RadioButton16Click
            end
            object gsIBLookupComboBox1: TgsIBLookupComboBox
              Left = 11
              Top = 41
              Width = 303
              Height = 21
              HelpContext = 1
              DataSource = dsgdcBase
              DataField = 'rootkey'
              ListTable = 'AT_RELATIONS'
              ListField = 'RELATIONNAME'
              KeyField = 'id'
              StrictOnExit = False
              ItemHeight = 13
              TabOrder = 3
            end
          end
        end
      end
    end
    object tsTriggers: TTabSheet [1]
      Caption = 'Исходный код триггеров'
      ImageIndex = 2
      object Splitter1: TSplitter
        Left = 0
        Top = 169
        Width = 599
        Height = 4
        Cursor = crVSplit
        Align = alTop
      end
      object tvTriggers: TTreeView
        Left = 0
        Top = 0
        Width = 599
        Height = 169
        Align = alTop
        Images = dmImages.ilToolBarSmall
        Indent = 19
        ReadOnly = True
        TabOrder = 0
        OnChange = tvTriggersChange
        OnCustomDrawItem = tvTriggersCustomDrawItem
        Items.Data = {
          06000000260000001C0000001C000000FFFFFFFFFFFFFFFF0000000000000000
          0D4265666F726520496E73657274250000001C0000001C000000FFFFFFFFFFFF
          FFFF00000000000000000C416674657220496E73657274260000001C0000001C
          000000FFFFFFFFFFFFFFFF00000000000000000D4265666F7265205570646174
          65250000001C0000001C000000FFFFFFFFFFFFFFFF00000000000000000C4166
          74657220557064617465260000001C0000001C000000FFFFFFFFFFFFFFFF0000
          0000000000000D4265666F72652044656C657465250000001C0000001C000000
          FFFFFFFFFFFFFFFF00000000000000000C41667465722044656C657465}
      end
      object smTriggerBody: TSynMemo
        Left = 0
        Top = 173
        Width = 599
        Height = 459
        Cursor = crIBeam
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Style = []
        ParentColor = False
        ParentFont = False
        TabOrder = 1
        Gutter.Font.Charset = DEFAULT_CHARSET
        Gutter.Font.Color = clWindowText
        Gutter.Font.Height = -11
        Gutter.Font.Name = 'Terminal'
        Gutter.Font.Style = []
        Highlighter = SynSQLSyn
        Keystrokes = <
          item
            Command = ecUp
            ShortCut = 38
          end
          item
            Command = ecSelUp
            ShortCut = 8230
          end
          item
            Command = ecScrollUp
            ShortCut = 16422
          end
          item
            Command = ecDown
            ShortCut = 40
          end
          item
            Command = ecSelDown
            ShortCut = 8232
          end
          item
            Command = ecScrollDown
            ShortCut = 16424
          end
          item
            Command = ecLeft
            ShortCut = 37
          end
          item
            Command = ecSelLeft
            ShortCut = 8229
          end
          item
            Command = ecWordLeft
            ShortCut = 16421
          end
          item
            Command = ecSelWordLeft
            ShortCut = 24613
          end
          item
            Command = ecRight
            ShortCut = 39
          end
          item
            Command = ecSelRight
            ShortCut = 8231
          end
          item
            Command = ecWordRight
            ShortCut = 16423
          end
          item
            Command = ecSelWordRight
            ShortCut = 24615
          end
          item
            Command = ecPageDown
            ShortCut = 34
          end
          item
            Command = ecSelPageDown
            ShortCut = 8226
          end
          item
            Command = ecPageBottom
            ShortCut = 16418
          end
          item
            Command = ecSelPageBottom
            ShortCut = 24610
          end
          item
            Command = ecPageUp
            ShortCut = 33
          end
          item
            Command = ecSelPageUp
            ShortCut = 8225
          end
          item
            Command = ecPageTop
            ShortCut = 16417
          end
          item
            Command = ecSelPageTop
            ShortCut = 24609
          end
          item
            Command = ecLineStart
            ShortCut = 36
          end
          item
            Command = ecSelLineStart
            ShortCut = 8228
          end
          item
            Command = ecEditorTop
            ShortCut = 16420
          end
          item
            Command = ecSelEditorTop
            ShortCut = 24612
          end
          item
            Command = ecLineEnd
            ShortCut = 35
          end
          item
            Command = ecSelLineEnd
            ShortCut = 8227
          end
          item
            Command = ecEditorBottom
            ShortCut = 16419
          end
          item
            Command = ecSelEditorBottom
            ShortCut = 24611
          end
          item
            Command = ecToggleMode
            ShortCut = 45
          end
          item
            Command = ecCopy
            ShortCut = 16429
          end
          item
            Command = ecPaste
            ShortCut = 8237
          end
          item
            Command = ecDeleteChar
            ShortCut = 46
          end
          item
            Command = ecCut
            ShortCut = 8238
          end
          item
            Command = ecDeleteLastChar
            ShortCut = 8
          end
          item
            Command = ecDeleteLastChar
            ShortCut = 8200
          end
          item
            Command = ecDeleteLastWord
            ShortCut = 16392
          end
          item
            Command = ecUndo
            ShortCut = 32776
          end
          item
            Command = ecRedo
            ShortCut = 40968
          end
          item
            Command = ecLineBreak
            ShortCut = 13
          end
          item
            Command = ecSelectAll
            ShortCut = 16449
          end
          item
            Command = ecCopy
            ShortCut = 16451
          end
          item
            Command = ecBlockIndent
            ShortCut = 24649
          end
          item
            Command = ecLineBreak
            ShortCut = 16461
          end
          item
            Command = ecInsertLine
            ShortCut = 16462
          end
          item
            Command = ecDeleteWord
            ShortCut = 16468
          end
          item
            Command = ecBlockUnindent
            ShortCut = 24661
          end
          item
            Command = ecPaste
            ShortCut = 16470
          end
          item
            Command = ecCut
            ShortCut = 16472
          end
          item
            Command = ecDeleteLine
            ShortCut = 16473
          end
          item
            Command = ecDeleteEOL
            ShortCut = 24665
          end
          item
            Command = ecUndo
            ShortCut = 16474
          end
          item
            Command = ecRedo
            ShortCut = 24666
          end
          item
            Command = ecGotoMarker0
            ShortCut = 16432
          end
          item
            Command = ecGotoMarker1
            ShortCut = 16433
          end
          item
            Command = ecGotoMarker2
            ShortCut = 16434
          end
          item
            Command = ecGotoMarker3
            ShortCut = 16435
          end
          item
            Command = ecGotoMarker4
            ShortCut = 16436
          end
          item
            Command = ecGotoMarker5
            ShortCut = 16437
          end
          item
            Command = ecGotoMarker6
            ShortCut = 16438
          end
          item
            Command = ecGotoMarker7
            ShortCut = 16439
          end
          item
            Command = ecGotoMarker8
            ShortCut = 16440
          end
          item
            Command = ecGotoMarker9
            ShortCut = 16441
          end
          item
            Command = ecSetMarker0
            ShortCut = 24624
          end
          item
            Command = ecSetMarker1
            ShortCut = 24625
          end
          item
            Command = ecSetMarker2
            ShortCut = 24626
          end
          item
            Command = ecSetMarker3
            ShortCut = 24627
          end
          item
            Command = ecSetMarker4
            ShortCut = 24628
          end
          item
            Command = ecSetMarker5
            ShortCut = 24629
          end
          item
            Command = ecSetMarker6
            ShortCut = 24630
          end
          item
            Command = ecSetMarker7
            ShortCut = 24631
          end
          item
            Command = ecSetMarker8
            ShortCut = 24632
          end
          item
            Command = ecSetMarker9
            ShortCut = 24633
          end
          item
            Command = ecNormalSelect
            ShortCut = 24654
          end
          item
            Command = ecColumnSelect
            ShortCut = 24643
          end
          item
            Command = ecLineSelect
            ShortCut = 24652
          end
          item
            Command = ecTab
            ShortCut = 9
          end
          item
            Command = ecShiftTab
            ShortCut = 8201
          end
          item
            Command = ecMatchBracket
            ShortCut = 24642
          end>
        Lines.Strings = (
          '')
        ReadOnly = True
      end
    end
    inherited tbsAttr: TTabSheet
      inherited atcMain: TatContainer
        Width = 599
        Height = 632
      end
    end
  end
  inherited alBase: TActionList
    Left = 510
    Top = 210
  end
  inherited dsgdcBase: TDataSource
    Left = 472
    Top = 210
  end
  inherited pm_dlgG: TPopupMenu
    Left = 560
    Top = 251
  end
  inherited ibtrCommon: TIBTransaction
    Left = 560
    Top = 211
  end
  object SynSQLSyn: TSynSQLSyn
    DefaultFilter = 'SQL files (*.sql)|*.sql'
    CommentAttri.Foreground = clBlue
    SQLDialect = sqlInterbase6
    Left = 508
    Top = 264
  end
end
