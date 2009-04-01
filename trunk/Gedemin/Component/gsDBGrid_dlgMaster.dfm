object dlgMaster: TdlgMaster
  Left = 547
  Top = 274
  Width = 591
  Height = 442
  HelpContext = 4
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Мастер установок'
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 583
    Height = 378
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 2
    TabOrder = 0
    object pcOptions: TPageControl
      Left = 2
      Top = 2
      Width = 579
      Height = 374
      ActivePage = tsTable
      Align = alClient
      TabHeight = 16
      TabOrder = 0
      OnChange = pcOptionsChange
      object tsTable: TTabSheet
        Caption = 'Таблица'
        object Label7: TLabel
          Left = 190
          Top = 134
          Width = 117
          Height = 13
          Caption = 'Внешний вид таблицы:'
        end
        object sgTableExample: TStringGrid
          Left = 190
          Top = 150
          Width = 261
          Height = 91
          TabStop = False
          ColCount = 3
          Ctl3D = True
          DefaultColWidth = 84
          DefaultRowHeight = 20
          FixedCols = 0
          RowCount = 4
          Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine]
          ParentCtl3D = False
          ScrollBars = ssNone
          TabOrder = 2
          OnDrawCell = sgTableExampleDrawCell
        end
        object GroupBox1: TGroupBox
          Left = 190
          Top = 8
          Width = 261
          Height = 120
          Caption = ' Режим отображения полос '
          TabOrder = 1
          object Label4: TLabel
            Left = 110
            Top = 50
            Width = 96
            Height = 13
            Caption = '- нечетная  полоса'
          end
          object Label5: TLabel
            Left = 110
            Top = 84
            Width = 81
            Height = 13
            Caption = '- четная полоса'
          end
          object cbStriped: TCheckBox
            Left = 19
            Top = 21
            Width = 222
            Height = 17
            Action = actStriped
            Alignment = taLeftJustify
            TabOrder = 0
          end
          object btnStripeOddColor: TButton
            Left = 20
            Top = 81
            Width = 75
            Height = 21
            Action = actStipe2Color
            TabOrder = 2
          end
          object btnStripeEvenColor: TButton
            Left = 20
            Top = 48
            Width = 75
            Height = 21
            Action = actStipe1Color
            TabOrder = 1
          end
        end
        object cbScaleColumns: TCheckBox
          Left = 190
          Top = 271
          Width = 261
          Height = 17
          Alignment = taLeftJustify
          Caption = 'Растягивать колонки по ширине таблицы'
          TabOrder = 4
        end
        object GroupBox2: TGroupBox
          Left = 14
          Top = 8
          Width = 151
          Height = 297
          Caption = ' Шрифт и цвет '
          TabOrder = 0
          object Label1: TLabel
            Left = 21
            Top = 113
            Width = 101
            Height = 13
            Caption = 'Выделенный текст:'
          end
          object Shape1: TShape
            Left = 21
            Top = 128
            Width = 101
            Height = 2
          end
          object Label2: TLabel
            Left = 21
            Top = 23
            Width = 46
            Height = 13
            Caption = 'Таблица:'
          end
          object Shape2: TShape
            Left = 21
            Top = 38
            Width = 101
            Height = 2
          end
          object Label3: TLabel
            Left = 21
            Top = 203
            Width = 96
            Height = 13
            Caption = 'Заглавия колонок:'
          end
          object Shape3: TShape
            Left = 21
            Top = 218
            Width = 101
            Height = 2
          end
          object btnTableFont: TButton
            Left = 21
            Top = 46
            Width = 75
            Height = 21
            Action = actTableFont
            TabOrder = 0
          end
          object btnTableColor: TButton
            Left = 21
            Top = 75
            Width = 75
            Height = 21
            Action = actTableColor
            TabOrder = 1
          end
          object btnSelectedFont: TButton
            Left = 21
            Top = 136
            Width = 75
            Height = 21
            Action = actSelectedFont
            TabOrder = 2
          end
          object btnSelectedColor: TButton
            Left = 21
            Top = 165
            Width = 75
            Height = 21
            Action = actSelectedColor
            TabOrder = 3
          end
          object btnTitleFont: TButton
            Left = 21
            Top = 226
            Width = 75
            Height = 21
            Action = actTitleFont
            TabOrder = 4
          end
          object btnTitleColor: TButton
            Left = 21
            Top = 255
            Width = 75
            Height = 21
            Action = actTitleColor
            TabOrder = 5
          end
        end
        object cbHorizLines: TCheckBox
          Left = 190
          Top = 253
          Width = 261
          Height = 17
          Alignment = taLeftJustify
          Caption = 'Горизонтальные линии таблицы'
          TabOrder = 3
          OnClick = cbHorizLinesClick
        end
        object cbShowTotals: TCheckBox
          Left = 190
          Top = 289
          Width = 261
          Height = 17
          Alignment = taLeftJustify
          Caption = 'Показывать строку итого:'
          TabOrder = 5
        end
        object cbShowFooter: TCheckBox
          Left = 190
          Top = 307
          Width = 261
          Height = 17
          Alignment = taLeftJustify
          Caption = 'Показывать подножие таблицы:'
          TabOrder = 6
        end
      end
      object tsColumn: TTabSheet
        Caption = 'Колонки'
        ImageIndex = 1
        object Panel4: TPanel
          Left = 262
          Top = 0
          Width = 309
          Height = 348
          Align = alRight
          BevelOuter = bvNone
          BorderWidth = 4
          TabOrder = 1
          object pcColumns: TPageControl
            Left = 4
            Top = 4
            Width = 301
            Height = 340
            ActivePage = TabSheet1
            Align = alClient
            TabHeight = 23
            TabOrder = 0
            object TabSheet5: TTabSheet
              Caption = 'Свойства колонки'
              ImageIndex = 1
              object lblExpands: TLabel
                Left = 17
                Top = 191
                Width = 141
                Height = 27
                AutoSize = False
                Caption = 'Расширенное отображение для колонки:'
                WordWrap = True
              end
              object lbExpandedLines: TListBox
                Left = 16
                Top = 224
                Width = 181
                Height = 76
                ItemHeight = 13
                TabOrder = 1
                OnClick = lbExpandedLinesClick
              end
              object btnAddExp: TButton
                Left = 216
                Top = 192
                Width = 75
                Height = 19
                Action = actColumnAddExp
                TabOrder = 2
              end
              object btnDeleteExp: TButton
                Left = 216
                Top = 214
                Width = 75
                Height = 19
                Action = actColumnDeleteExp
                TabOrder = 3
              end
              object btnUpExp: TButton
                Left = 216
                Top = 259
                Width = 75
                Height = 19
                Action = actColumnUpExp
                TabOrder = 5
              end
              object btnDownExp: TButton
                Left = 216
                Top = 281
                Width = 75
                Height = 19
                Action = actColumnDownExp
                TabOrder = 6
              end
              object btnEditExp: TButton
                Left = 216
                Top = 237
                Width = 75
                Height = 19
                Action = actColumnEditExp
                TabOrder = 4
              end
              object GroupBox5: TGroupBox
                Left = 16
                Top = 8
                Width = 275
                Height = 177
                Caption = ' Свойства колонки: '
                TabOrder = 0
                object Label12: TLabel
                  Left = 14
                  Top = 20
                  Width = 96
                  Height = 13
                  Caption = 'Заглавие колонки:'
                end
                object lblColumnWidth: TLabel
                  Left = 14
                  Top = 152
                  Width = 89
                  Height = 13
                  Caption = 'Ширина колонки:'
                end
                object Label15: TLabel
                  Left = 205
                  Top = 154
                  Width = 54
                  Height = 13
                  Caption = '- символов'
                end
                object btnChooseColumnFormat: TButton
                  Left = 236
                  Top = 98
                  Width = 26
                  Height = 22
                  Action = actChooseColumnFormat
                  TabOrder = 6
                end
                object editColumnFormat: TEdit
                  Left = 140
                  Top = 98
                  Width = 91
                  Height = 21
                  TabOrder = 5
                  Text = 'editColumnFormat'
                  OnExit = editColumnFormatExit
                end
                object cbColumnFormat: TCheckBox
                  Left = 14
                  Top = 102
                  Width = 97
                  Height = 17
                  Action = actColumnFormat
                  Caption = 'Формат'
                  TabOrder = 4
                end
                object cbColumnLineCount: TCheckBox
                  Left = 14
                  Top = 123
                  Width = 107
                  Height = 17
                  Action = actColumnLineCount
                  TabOrder = 7
                end
                object editColumnLineCount: TxSpinEdit
                  Left = 140
                  Top = 124
                  Width = 61
                  Height = 21
                  Value = 1
                  IntValue = 1
                  MaxValue = 10
                  MinValue = 1
                  Increment = 1
                  SpinGap = 1
                  SpinStep = 50
                  DecDigits = 0
                  SpinCursor = 17555
                  TabOrder = 8
                  OnChange = editColumnLineCountChange
                end
                object editColumnTitle: TEdit
                  Left = 140
                  Top = 16
                  Width = 122
                  Height = 21
                  TabOrder = 0
                  Text = 'Edit1'
                  OnChange = editColumnTitleChange
                end
                object cbColumnVisible: TCheckBox
                  Left = 14
                  Top = 40
                  Width = 141
                  Height = 17
                  Action = actVisible
                  Caption = 'Колонка отображается'
                  TabOrder = 1
                end
                object editColumnWidth: TxSpinEdit
                  Left = 140
                  Top = 150
                  Width = 61
                  Height = 21
                  Value = 1
                  IntValue = 1
                  MaxValue = 600
                  MinValue = 1
                  Increment = 1
                  SpinGap = 1
                  SpinStep = 50
                  DecDigits = 0
                  SpinCursor = 17555
                  TabOrder = 9
                  OnChange = editColumnWidthChange
                end
                object cbColReadOnly: TCheckBox
                  Left = 14
                  Top = 82
                  Width = 97
                  Height = 17
                  Caption = 'Только чтение'
                  TabOrder = 3
                  OnClick = actVisibleExecute
                end
                object cbTotal: TCheckBox
                  Left = 14
                  Top = 61
                  Width = 211
                  Height = 17
                  Caption = 'Подсчитывать итоговое значение'
                  TabOrder = 2
                  OnClick = actVisibleExecute
                end
              end
            end
            object TabSheet1: TTabSheet
              Caption = 'Визуальные'
              object Label10: TLabel
                Left = 16
                Top = 153
                Width = 54
                Height = 46
                AutoSize = False
                Caption = 'Внешний вид колонки:'
                WordWrap = True
              end
              object sgColumn: TStringGrid
                Left = 80
                Top = 153
                Width = 210
                Height = 91
                TabStop = False
                ColCount = 1
                DefaultColWidth = 204
                DefaultRowHeight = 20
                FixedCols = 0
                RowCount = 4
                Font.Charset = RUSSIAN_CHARSET
                Font.Color = clWindowText
                Font.Height = -11
                Font.Name = 'Tahoma'
                Font.Style = []
                ParentFont = False
                ScrollBars = ssNone
                TabOrder = 4
                OnDrawCell = sgColumnDrawCell
              end
              object GroupBox3: TGroupBox
                Left = 16
                Top = 8
                Width = 131
                Height = 81
                Caption = ' Колонка: '
                TabOrder = 0
                object btnColumnFont: TButton
                  Left = 28
                  Top = 20
                  Width = 75
                  Height = 24
                  Action = actColumnFont
                  TabOrder = 0
                end
                object btnColumnColor: TButton
                  Left = 28
                  Top = 47
                  Width = 75
                  Height = 24
                  Action = actColumnColor
                  TabOrder = 1
                end
              end
              object rgColumnAlign: TRadioGroup
                Left = 16
                Top = 98
                Width = 131
                Height = 40
                Caption = ' Выравнивание: '
                Columns = 3
                Items.Strings = (
                  '<-'
                  '<->'
                  '->')
                TabOrder = 1
                OnClick = rgColumnAlignClick
              end
              object rgColumnTitleAlign: TRadioGroup
                Left = 161
                Top = 97
                Width = 131
                Height = 40
                Caption = ' Выравнивание: '
                Columns = 3
                Items.Strings = (
                  '<-'
                  '<->'
                  '->')
                TabOrder = 3
                OnClick = rgColumnTitleAlignClick
              end
              object GroupBox4: TGroupBox
                Left = 160
                Top = 8
                Width = 131
                Height = 81
                Caption = ' Заглавие: '
                TabOrder = 2
                object btnColumnTitleFont: TButton
                  Left = 28
                  Top = 20
                  Width = 75
                  Height = 24
                  Action = actColumnTitleFont
                  TabOrder = 0
                end
                object btnColumnTitleColor: TButton
                  Left = 28
                  Top = 47
                  Width = 75
                  Height = 24
                  Action = actColumnTitleColor
                  TabOrder = 1
                end
              end
            end
          end
        end
        object Panel5: TPanel
          Left = 0
          Top = 0
          Width = 262
          Height = 348
          Align = alClient
          BevelOuter = bvNone
          BorderWidth = 6
          TabOrder = 0
          object lvColumns: TListView
            Left = 6
            Top = 6
            Width = 250
            Height = 249
            Align = alClient
            Columns = <
              item
                Caption = 'Колонка'
                Width = 150
              end
              item
                Caption = 'Поле таблицы'
                Width = 140
              end>
            DragMode = dmAutomatic
            HideSelection = False
            MultiSelect = True
            ReadOnly = True
            RowSelect = True
            PopupMenu = pmFields
            TabOrder = 0
            ViewStyle = vsReport
            OnCustomDrawItem = lvColumnsCustomDrawItem
            OnDragDrop = lvColumnsDragDrop
            OnDragOver = lvColumnsDragOver
            OnSelectItem = lvColumnsSelectItem
          end
          object Panel7: TPanel
            Left = 6
            Top = 255
            Width = 250
            Height = 87
            Align = alBottom
            BevelOuter = bvNone
            TabOrder = 1
            object cbColumnsChooseAll: TCheckBox
              Left = 11
              Top = 3
              Width = 218
              Height = 17
              Alignment = taLeftJustify
              Anchors = [akLeft, akTop, akRight]
              BiDiMode = bdLeftToRight
              Caption = 'Выбрать все колонки'
              ParentBiDiMode = False
              TabOrder = 0
              OnClick = cbColumnsChooseAllClick
            end
            object GroupBox9: TGroupBox
              Left = 0
              Top = 19
              Width = 250
              Height = 68
              Align = alBottom
              Caption = ' Расширенное отображение '
              TabOrder = 1
              object cbColumnExpanded: TCheckBox
                Left = 11
                Top = 13
                Width = 218
                Height = 17
                Action = actColumnExpaneded
                Alignment = taLeftJustify
                Anchors = [akLeft, akTop, akRight]
                Caption = 'Использовать'
                TabOrder = 0
              end
              object cbColumnSeparateExp: TCheckBox
                Left = 11
                Top = 30
                Width = 218
                Height = 17
                Action = actColumnSeparateExp
                Alignment = taLeftJustify
                Anchors = [akLeft, akTop, akRight]
                TabOrder = 1
              end
              object cbColumnTitleExp: TCheckBox
                Left = 11
                Top = 47
                Width = 218
                Height = 17
                Action = actColumnTitleExp
                Alignment = taLeftJustify
                Anchors = [akLeft, akTop, akRight]
                TabOrder = 2
              end
            end
          end
        end
      end
      object tsCondition: TTabSheet
        Caption = 'Условия'
        ImageIndex = 2
        object Panel6: TPanel
          Left = 258
          Top = 0
          Width = 313
          Height = 348
          Align = alRight
          BevelOuter = bvNone
          BorderWidth = 4
          TabOrder = 1
          object pcConditions: TPageControl
            Left = 4
            Top = 4
            Width = 305
            Height = 340
            ActivePage = TabSheet6
            Align = alClient
            Anchors = [akTop, akRight, akBottom]
            TabHeight = 23
            TabOrder = 0
            object TabSheet6: TTabSheet
              Caption = 'Формат условия'
              object Label8: TLabel
                Left = 16
                Top = 228
                Width = 274
                Height = 41
                AutoSize = False
                Caption = 
                  'Расчет формул необходим, если задается сложный формат. Например,' +
                  ' <Колонка_1> больше <Колонка_2> * <Колонка_3>.'
                WordWrap = True
              end
              object GroupBox6: TGroupBox
                Left = 16
                Top = 8
                Width = 275
                Height = 87
                Caption = ' Название и колонка условия '
                TabOrder = 0
                object Label16: TLabel
                  Left = 14
                  Top = 25
                  Width = 52
                  Height = 13
                  Caption = 'Название:'
                end
                object Label13: TLabel
                  Left = 14
                  Top = 56
                  Width = 47
                  Height = 13
                  Caption = 'Колонка:'
                end
                object editConditionName: TEdit
                  Left = 71
                  Top = 22
                  Width = 190
                  Height = 21
                  TabOrder = 0
                  Text = 'editConditionName'
                  OnChange = editConditionNameChange
                end
                object editConditionColumn: TComboBox
                  Left = 71
                  Top = 52
                  Width = 190
                  Height = 21
                  Style = csDropDownList
                  ItemHeight = 13
                  TabOrder = 1
                  OnClick = editConditionColumnClick
                end
              end
              object GroupBox7: TGroupBox
                Left = 16
                Top = 99
                Width = 276
                Height = 102
                Caption = ' Операция и содержание условия '
                TabOrder = 1
                object Label14: TLabel
                  Left = 14
                  Top = 25
                  Width = 54
                  Height = 13
                  Caption = 'Операция:'
                end
                object lblAnd: TLabel
                  Left = 134
                  Top = 70
                  Width = 6
                  Height = 13
                  Caption = 'и'
                end
                object Label19: TLabel
                  Left = 14
                  Top = 48
                  Width = 112
                  Height = 13
                  Caption = 'Содержание условия:'
                end
                object editConditionKind: TComboBox
                  Left = 79
                  Top = 22
                  Width = 182
                  Height = 21
                  Style = csDropDownList
                  DropDownCount = 12
                  ItemHeight = 13
                  TabOrder = 0
                  OnClick = editConditionKindClick
                end
                object editConditionText1: TEdit
                  Left = 14
                  Top = 66
                  Width = 110
                  Height = 21
                  TabOrder = 1
                  Text = 'editConditionText1'
                  OnChange = editConditionText1Change
                end
                object editConditionText2: TEdit
                  Left = 150
                  Top = 66
                  Width = 110
                  Height = 21
                  TabOrder = 2
                  Text = 'editConditionText2'
                  OnChange = editConditionText2Change
                end
              end
              object cbEvaluateExpression: TCheckBox
                Left = 16
                Top = 208
                Width = 143
                Height = 17
                Caption = 'Рассчитывать формулы'
                TabOrder = 2
                OnClick = cbEvaluateExpressionClick
              end
            end
            object TabSheet7: TTabSheet
              Caption = 'Шрифт и цвет, колонки'
              ImageIndex = 1
              object Label20: TLabel
                Left = 16
                Top = 163
                Width = 172
                Height = 13
                Caption = 'Отображать условие в колонках:'
              end
              object Label9: TLabel
                Left = 16
                Top = 105
                Width = 70
                Height = 13
                Caption = 'Внешний вид:'
              end
              object pnlConditionPreview: TPanel
                Left = 16
                Top = 121
                Width = 275
                Height = 36
                BevelInner = bvLowered
                Caption = 'AaBbБбЯя'
                TabOrder = 3
              end
              object lbConditionColumns: TListBox
                Left = 16
                Top = 179
                Width = 181
                Height = 116
                ItemHeight = 13
                TabOrder = 1
              end
              object btnConditionColumns: TButton
                Left = 215
                Top = 178
                Width = 75
                Height = 21
                Action = actConditionColumns
                TabOrder = 2
              end
              object GroupBox8: TGroupBox
                Left = 16
                Top = 8
                Width = 275
                Height = 91
                Caption = ' Шрифт и цвет условия '
                TabOrder = 0
                object btnConditionFont: TButton
                  Left = 20
                  Top = 24
                  Width = 75
                  Height = 21
                  Action = actConditionFont
                  TabOrder = 0
                end
                object btnConditionColor: TButton
                  Left = 20
                  Top = 56
                  Width = 75
                  Height = 21
                  Action = actConditionColor
                  TabOrder = 2
                end
                object cbConditionFontUse: TCheckBox
                  Left = 100
                  Top = 26
                  Width = 111
                  Height = 17
                  Action = actConditionFontUse
                  Alignment = taLeftJustify
                  TabOrder = 1
                end
                object cbConditionColorUse: TCheckBox
                  Left = 100
                  Top = 58
                  Width = 111
                  Height = 17
                  Action = actConditionColorUse
                  Alignment = taLeftJustify
                  TabOrder = 3
                end
              end
            end
          end
        end
        object Panel8: TPanel
          Left = 0
          Top = 0
          Width = 258
          Height = 348
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 0
          object lbConditions: TListBox
            Left = 6
            Top = 25
            Width = 246
            Height = 162
            Anchors = [akLeft, akTop, akRight, akBottom]
            ItemHeight = 13
            TabOrder = 1
            OnClick = lbConditionsClick
          end
          object btnConditonAdd: TButton
            Left = 6
            Top = 199
            Width = 75
            Height = 21
            Action = actConditionAdd
            Anchors = [akLeft, akBottom]
            TabOrder = 2
          end
          object btnConditionDelete: TButton
            Left = 6
            Top = 223
            Width = 75
            Height = 21
            Action = actConditionDelete
            Anchors = [akLeft, akBottom]
            TabOrder = 3
          end
          object btnConditionUp: TButton
            Left = 6
            Top = 247
            Width = 75
            Height = 21
            Action = actConditionUp
            Anchors = [akLeft, akBottom]
            TabOrder = 4
          end
          object btnConditionDown: TButton
            Left = 6
            Top = 271
            Width = 75
            Height = 21
            Action = actConditionDown
            Anchors = [akLeft, akBottom]
            TabOrder = 5
          end
          object cbConditionActive: TCheckBox
            Left = 6
            Top = 6
            Width = 141
            Height = 17
            Action = actConditionsActive
            TabOrder = 0
          end
        end
      end
      object TabSheet2: TTabSheet
        Caption = 'Шаблоны'
        ImageIndex = 3
        object Label6: TLabel
          Left = 6
          Top = 6
          Width = 214
          Height = 13
          Caption = 'Список стандартных шаблонов настроек:'
        end
        object Label11: TLabel
          Left = 8
          Top = 221
          Width = 373
          Height = 61
          Anchors = [akLeft, akBottom]
          AutoSize = False
          Caption = 
            'Стандартный шаблон содержит набор установок для таблицы. Для при' +
            'своения настроек шаблона нажмите Установить шаблон. Шаблон можно' +
            ' сохранить в файл (Сохранить шаблон) и восстановить, загрузив ег' +
            'о из файла (Загрузить шаблон).'
          WordWrap = True
        end
        object lblDefaults: TLabel
          Left = 132
          Top = 282
          Width = 233
          Height = 50
          Anchors = [akLeft, akBottom]
          AutoSize = False
          Caption = 
            '- устанавливает первоначальные значения для колонок: видимость, ' +
            'ширина, наименование.'
          Visible = False
          WordWrap = True
        end
        object lbTemplate: TListBox
          Left = 6
          Top = 26
          Width = 560
          Height = 151
          Anchors = [akLeft, akTop, akRight, akBottom]
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ItemHeight = 13
          Items.Strings = (
            'Стандартная таблица (таблица белого цвета, стандартный шрифт)'
            'Полосатая таблица (Полосатая таблица, стандартный шрифт)'
            'Изысканный вид (Полосатая таблица, изысканный шрифт)'
            
              '----------------------------------------------------------------' +
              '----------------------------------------'
            'Разделители в числах (Например число: 100 254 123.32 )'
            'Числа без дробной части (Например число: 100 254 123 )'
            
              '----------------------------------------------------------------' +
              '----------------------------------------'
            'Только строковые колонки (Скрыты все нестроковые)'
            'Только числовые колонки (Скрыты все нечисловые)')
          ParentFont = False
          TabOrder = 0
        end
        object btnSetTemplate: TButton
          Left = 6
          Top = 185
          Width = 117
          Height = 21
          Action = actTemplate
          Anchors = [akLeft, akBottom]
          TabOrder = 1
        end
        object btnSaveTemplate: TButton
          Left = 266
          Top = 185
          Width = 117
          Height = 21
          Action = actSaveTemplate
          Anchors = [akLeft, akBottom]
          TabOrder = 2
        end
        object btnLoadTemplate: TButton
          Left = 136
          Top = 185
          Width = 117
          Height = 21
          Action = actLoadTemplate
          Anchors = [akLeft, akBottom]
          TabOrder = 3
        end
        object btnDefaults: TButton
          Left = 6
          Top = 285
          Width = 117
          Height = 21
          Hint = 'Установить шаблон'
          Anchors = [akLeft, akBottom]
          Caption = 'По умолчанию'
          TabOrder = 4
          Visible = False
        end
      end
      object tsQuery: TTabSheet
        Caption = 'Запрос'
        ImageIndex = 4
        PopupMenu = pmQuery
        TabVisible = False
        object cbQuery: TControlBar
          Left = 5
          Top = 5
          Width = 441
          Height = 36
          AutoDrag = False
          BevelEdges = []
          PopupMenu = pmQuery
          RowSize = 34
          TabOrder = 0
          object tbQuery: TToolBar
            Left = 11
            Top = 2
            Width = 186
            Height = 30
            Align = alNone
            BorderWidth = 2
            Caption = 'Операции над запросом'
            DragKind = dkDock
            EdgeBorders = []
            Flat = True
            Images = ilQuery
            ParentShowHint = False
            PopupMenu = pmQuery
            ShowHint = True
            TabOrder = 0
            object tbLoad: TToolButton
              Left = 0
              Top = 0
              Action = actLoadQuery
            end
            object tbSave: TToolButton
              Left = 23
              Top = 0
              Action = actSaveQuery
            end
            object ToolButton3: TToolButton
              Left = 46
              Top = 0
              Width = 8
              Caption = 'ToolButton3'
              ImageIndex = 2
              Style = tbsSeparator
            end
            object tbApplyWithPlan: TToolButton
              Left = 54
              Top = 0
              Action = actApplyQueryWithPlan
            end
            object tbApplyWithoutPlan: TToolButton
              Left = 77
              Top = 0
              Action = actApplyQuery
            end
            object ToolButton6: TToolButton
              Left = 100
              Top = 0
              Width = 8
              Caption = 'ToolButton6'
              ImageIndex = 4
              Style = tbsSeparator
            end
            object tbCut: TToolButton
              Left = 108
              Top = 0
              Action = actCutQuery
            end
            object tbCopy: TToolButton
              Left = 131
              Top = 0
              Action = actCopyQuery
            end
            object tbPaste: TToolButton
              Left = 154
              Top = 0
              Action = actPasteQuery
            end
          end
        end
        object seQuery: TSynEdit
          Left = 5
          Top = 44
          Width = 559
          Height = 298
          Cursor = crIBeam
          Anchors = [akLeft, akTop, akRight, akBottom]
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Courier New Cyr'
          Font.Style = []
          ParentColor = False
          ParentFont = False
          TabOrder = 1
          Gutter.Font.Charset = DEFAULT_CHARSET
          Gutter.Font.Color = clWindowText
          Gutter.Font.Height = -11
          Gutter.Font.Name = 'Terminal'
          Gutter.Font.Style = []
          Gutter.Visible = False
          Gutter.Width = 24
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
              Command = ecCut
              ShortCut = 8238
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
              Command = ecLineBreak
              ShortCut = 8205
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
              Command = ecContextHelp
              ShortCut = 16496
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
              Command = ecPaste
              ShortCut = 16470
            end
            item
              Command = ecCut
              ShortCut = 16472
            end
            item
              Command = ecBlockIndent
              ShortCut = 24649
            end
            item
              Command = ecBlockUnindent
              ShortCut = 24661
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
              Command = ecMatchBracket
              ShortCut = 24642
            end>
          Lines.Strings = (
            '')
        end
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 378
    Width = 583
    Height = 37
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object Panel3: TPanel
      Left = 319
      Top = 0
      Width = 264
      Height = 37
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
      object btnCancel: TButton
        Left = 98
        Top = 7
        Width = 75
        Height = 21
        Action = actCancel
        Cancel = True
        ModalResult = 2
        TabOrder = 1
      end
      object btnOk: TButton
        Left = 9
        Top = 7
        Width = 75
        Height = 21
        Action = actOk
        Default = True
        TabOrder = 0
      end
      object btnHelp: TButton
        Left = 186
        Top = 7
        Width = 75
        Height = 21
        Action = actHelp
        TabOrder = 2
      end
    end
    object btnApply: TButton
      Left = 2
      Top = 7
      Width = 75
      Height = 21
      Action = actApply
      TabOrder = 1
    end
    object btnReset: TButton
      Left = 89
      Top = 7
      Width = 75
      Height = 21
      Action = actReset
      TabOrder = 2
    end
  end
  object alMaster: TActionList
    Left = 186
    Top = 380
    object actTableFont: TAction
      Category = 'Table'
      Caption = 'Шрифт'
      Enabled = False
      OnExecute = actTableFontExecute
    end
    object actTableColor: TAction
      Category = 'Table'
      Caption = 'Цвет'
      Enabled = False
      OnExecute = actTableColorExecute
    end
    object actTitleFont: TAction
      Category = 'Table'
      Caption = 'Шрифт'
      Enabled = False
      OnExecute = actTitleFontExecute
    end
    object actTitleColor: TAction
      Category = 'Table'
      Caption = 'Цвет'
      Enabled = False
      OnExecute = actTitleColorExecute
    end
    object actSelectedFont: TAction
      Category = 'Table'
      Caption = 'Шрифт'
      Enabled = False
      OnExecute = actSelectedFontExecute
    end
    object actSelectedColor: TAction
      Category = 'Table'
      Caption = 'Цвет'
      Enabled = False
      OnExecute = actSelectedColorExecute
    end
    object actStriped: TAction
      Category = 'Table'
      Caption = 'Использовать'
      Enabled = False
      OnExecute = actStripedExecute
    end
    object actStipe1Color: TAction
      Category = 'Table'
      Caption = 'Цвет'
      Enabled = False
      OnExecute = actStipe1ColorExecute
    end
    object actStipe2Color: TAction
      Category = 'Table'
      Caption = 'Цвет'
      Enabled = False
      OnExecute = actStipe2ColorExecute
    end
    object actVisible: TAction
      Category = 'Column'
      Caption = 'Видимая'
      OnExecute = actVisibleExecute
    end
    object actColumnFont: TAction
      Category = 'Column'
      Caption = 'Шрифт'
      Enabled = False
      OnExecute = actColumnFontExecute
    end
    object actColumnColor: TAction
      Category = 'Column'
      Caption = 'Цвет'
      Enabled = False
      OnExecute = actColumnColorExecute
    end
    object actColumnTitleFont: TAction
      Category = 'Column'
      Caption = 'Шрифт'
      Enabled = False
      OnExecute = actColumnTitleFontExecute
    end
    object actColumnTitleColor: TAction
      Category = 'Column'
      Caption = 'Цвет'
      Enabled = False
      OnExecute = actColumnTitleColorExecute
    end
    object actColumnFormat: TAction
      Category = 'Column'
      Caption = 'Формат отображения:'
      Enabled = False
      OnExecute = actColumnFormatExecute
    end
    object actColumnLineCount: TAction
      Category = 'Column'
      Caption = 'Кол-во строчек'
      Enabled = False
      OnExecute = actColumnLineCountExecute
    end
    object actColumnExpaneded: TAction
      Category = 'Column'
      Caption = 'Расширенное отображение'
      Enabled = False
      OnExecute = actColumnExpanededExecute
    end
    object actColumnAddExp: TAction
      Category = 'Column'
      Caption = 'Добавить'
      Enabled = False
      OnExecute = actColumnAddExpExecute
    end
    object actColumnDeleteExp: TAction
      Category = 'Column'
      Caption = 'Удалить'
      Enabled = False
      OnExecute = actColumnDeleteExpExecute
    end
    object actColumnEditExp: TAction
      Category = 'Column'
      Caption = 'Изменить'
      Enabled = False
      OnExecute = actColumnEditExpExecute
    end
    object actColumnUpExp: TAction
      Category = 'Column'
      Caption = 'Вверх'
      Enabled = False
      OnExecute = actColumnUpExpExecute
    end
    object actColumnDownExp: TAction
      Category = 'Column'
      Caption = 'Вниз'
      Enabled = False
      OnExecute = actColumnDownExpExecute
    end
    object actConditionAdd: TAction
      Category = 'Condition'
      Caption = 'Добавить'
      Enabled = False
      OnExecute = actConditionAddExecute
    end
    object actConditionDelete: TAction
      Category = 'Condition'
      Caption = 'Удалить'
      Enabled = False
      OnExecute = actConditionDeleteExecute
      OnUpdate = actConditionDeleteUpdate
    end
    object actConditionUp: TAction
      Category = 'Condition'
      Caption = 'Вверх'
      Enabled = False
      OnExecute = actConditionUpExecute
      OnUpdate = actConditionUpUpdate
    end
    object actConditionDown: TAction
      Category = 'Condition'
      Caption = 'Вниз'
      Enabled = False
      OnExecute = actConditionDownExecute
      OnUpdate = actConditionDownUpdate
    end
    object actConditionsActive: TAction
      Category = 'Condition'
      Caption = 'Использовать условия'
      Enabled = False
      OnExecute = actConditionsActiveExecute
    end
    object actConditionFont: TAction
      Category = 'Condition'
      Caption = 'Шрифт'
      Enabled = False
      OnExecute = actConditionFontExecute
      OnUpdate = actConditionDeleteUpdate
    end
    object actConditionColor: TAction
      Category = 'Condition'
      Caption = 'Цвет'
      Enabled = False
      OnExecute = actConditionColorExecute
      OnUpdate = actConditionDeleteUpdate
    end
    object actConditionFontUse: TAction
      Category = 'Condition'
      Caption = '- использовать'
      Enabled = False
      OnExecute = btnConditionFontUseClick
    end
    object actConditionColorUse: TAction
      Category = 'Condition'
      Caption = '- использовать'
      Enabled = False
      OnExecute = btnConditionColorUseClick
    end
    object actConditionColumns: TAction
      Category = 'Condition'
      Caption = 'Выбрать'
      Enabled = False
      OnExecute = actConditionColumnsExecute
      OnUpdate = actConditionDeleteUpdate
    end
    object actOk: TAction
      Category = 'Result'
      Caption = 'OK'
      Enabled = False
      OnExecute = actOkExecute
    end
    object actCancel: TAction
      Category = 'Result'
      Caption = 'Отменить'
      Enabled = False
      OnExecute = actCancelExecute
    end
    object actHelp: TAction
      Category = 'Result'
      Caption = 'Помощь'
      Enabled = False
      OnExecute = actHelpExecute
    end
    object actColumnSeparateExp: TAction
      Category = 'Column'
      Caption = 'Рисовать разделитель'
      OnExecute = actColumnSeparateExpExecute
    end
    object actApply: TAction
      Category = 'Result'
      Caption = 'Применить'
    end
    object actColumnTitleExp: TAction
      Category = 'Column'
      Caption = 'Расширенное заглавие колонки'
      OnExecute = actColumnTitleExpExecute
    end
    object actChooseColumnFormat: TAction
      Category = 'Column'
      Caption = '...'
      OnExecute = actChooseColumnFormatExecute
    end
    object actTemplate: TAction
      Category = 'Table'
      Caption = 'Установить шаблон'
      Hint = 'Установить шаблон'
      OnExecute = actTemplateExecute
    end
    object actLoadQuery: TAction
      Category = 'Query'
      Caption = 'Загрузить'
      Hint = 'Загрузить'
      ImageIndex = 1
      OnExecute = actLoadQueryExecute
    end
    object actSaveQuery: TAction
      Category = 'Query'
      Caption = 'Сохранить'
      Hint = 'Сохранить'
      ImageIndex = 0
      OnExecute = actSaveQueryExecute
    end
    object actApplyQuery: TAction
      Category = 'Query'
      Caption = 'Применить без плана'
      Hint = 'Применить без плана'
      ImageIndex = 2
      OnExecute = actApplyQueryExecute
    end
    object actApplyQueryWithPlan: TAction
      Category = 'Query'
      Caption = 'Применить с планом'
      Hint = 'Применить с планом'
      ImageIndex = 3
      OnExecute = actApplyQueryWithPlanExecute
    end
    object actLoadTemplate: TAction
      Category = 'Table'
      Caption = 'Загрузить шаблон'
      Hint = 'Загрузить шаблон'
      OnExecute = actLoadTemplateExecute
    end
    object actSaveTemplate: TAction
      Category = 'Table'
      Caption = 'Сохранить шаблон'
      Hint = 'Сохранить шаблон'
      OnExecute = actSaveTemplateExecute
    end
    object actCutQuery: TAction
      Category = 'Query'
      Caption = 'Вырезать'
      Hint = 'Вырезать'
      ImageIndex = 4
      OnExecute = actCutQueryExecute
    end
    object actCopyQuery: TAction
      Category = 'Query'
      Caption = 'Скопировать'
      Hint = 'Скопировать'
      ImageIndex = 5
      OnExecute = actCopyQueryExecute
    end
    object actPasteQuery: TAction
      Category = 'Query'
      Caption = 'Вставить'
      Hint = 'Вставить'
      ImageIndex = 6
      OnExecute = actPasteQueryExecute
    end
    object actReset: TAction
      Caption = 'Сбросить'
      OnExecute = actResetExecute
    end
  end
  object ilQuery: TImageList
    Left = 246
    Top = 380
    Bitmap = {
      494C010107000900040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000003000000001002000000000000030
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000840000008400000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000084000000840000008400000084000000840000008400
      0000840000008400000084000000840000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008400
      0000C6C6C600C6C6C60084000000000000000000000084000000840000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000084000000840000008400000084000000840000008400
      0000840000008400000084000000000000000000000000000000000000000000
      0000000000000000000084000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00840000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008400
      0000C6C6C600C6C6C600840000000000000084000000C6C6C600C6C6C6008400
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000084000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0084000000000000000000000084848400000000008484
      8400000000008484840084000000FFFFFF008400000084000000840000008400
      00008400000084000000FFFFFF00840000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008400
      0000C6C6C600C6C6C600840000000000000084000000C6C6C600C6C6C6008400
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000084000000FFFFFF000000000000000000000000000000
      000000000000FFFFFF0084000000000000000000000000000000848484000000
      0000848484000000000084000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00840000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00008400000084000000840000000000000084000000C6C6C600C6C6C6008400
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000084000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0084000000000000000000000084848400000000008484
      8400000000008484840084000000FFFFFF00840000008400000084000000FFFF
      FF00840000008400000084000000840000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000084000000000000008400000084000000840000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0084000000FFFFFF000000000000000000000000000000
      000000000000FFFFFF0084000000000000000000000000000000848484000000
      0000848484000000000084000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0084000000FFFFFF0084000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000084000000000000008400000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      0000000000000000000084000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0084000000000000000000000084848400000000008484
      8400000000008484840084000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00840000008400000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0084000000FFFFFF000000000000000000FFFFFF008400
      0000840000008400000084000000000000000000000000000000848484000000
      0000848484000000000084000000840000008400000084000000840000008400
      0000840000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      0000000000000000000084000000FFFFFF00FFFFFF00FFFFFF00FFFFFF008400
      0000FFFFFF008400000000000000000000000000000084848400000000008484
      8400000000008484840000000000848484000000000084848400000000008484
      8400000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000C6C6C6000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0084000000FFFFFF00FFFFFF00FFFFFF00FFFFFF008400
      0000840000000000000000000000000000000000000000000000848484000000
      0000000000000000000000000000000000000000000000000000000000008484
      8400848484000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000C6C6C6000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      0000FFFFFF000000000084000000840000008400000084000000840000008400
      0000000000000000000000000000000000000000000084848400848484000000
      0000C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600000000008484
      8400000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000848484000000
      00000000000000FFFF00000000000000000000FFFF0000000000848484000000
      0000848484000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000FFFF0000FFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000840000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000C6C6C60084848400848484008484
      8400848484008484840084848400000000000000000000000000008484000084
      8400008484000084840000848400008484000084840000848400008484000084
      8400000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000840000008400000084000000
      0000000000000000840000000000000084000000840000008400000084000000
      0000000084000000000000000000000084000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C60084848400000000000000000000FFFF00000000000084
      8400008484000000000000848400000000000084840000848400008484000084
      8400008484000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000840000000000000000000000
      8400000000000000840000000000000084000000840000000000000084000000
      0000000084000000000000000000000084000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF000000FF000000FF00C6C6
      C600C6C6C600C6C6C600848484000000000000000000FFFFFF0000FFFF000000
      0000008484000084840000000000008484000000000000848400008484000084
      8400008484000084840000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000840000000000000000000000
      8400000000000000840000000000000000000000000000008400000084000000
      0000000084000000000000000000000084000000000000FFFF00FFFFFF0000FF
      FF00FFFFFF00000000000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00C6C6C600000000000000000000FFFF00FFFFFF0000FF
      FF00000000000084840000848400008484000084840000848400008484000084
      8400008484000084840000848400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000840000008400000084000000
      0000000000000000840000000000000084000000840000008400000084000000
      00000000840000008400000084000000840000000000FFFFFF00000000000000
      000000FFFF000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF0000FFFF00FFFF
      FF0000FFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000840000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000FFFF00FFFFFF0000FF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000FFFF00FFFFFF0000FF
      FF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000840000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      000000FFFF000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF0000FFFF00FFFF
      FF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000FFFF00FFFFFF0000FF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000FFFF00FFFFFF0000FF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      000000FFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000FFFF00FFFFFF0000FF
      FF00FFFFFF000000000000000000000000000000000000000000000000008484
      8400000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF0000FFFF00FFFF
      FF00000000000000000000000000000000000000000000000000848484000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000300000000100010000000000800100000000000000000000
      000000000000000000000000FFFFFF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FFFFFFFFFFFF0000F3FFFFFFFC000000
      E19FFC0180000000E10FFC0128000000E10FFC0154000000F10F000128000000
      FD1F000154010000FC7F000128030000FEFF000154030000FC7F00032AAB0000
      FC7F000740030000F83F000F000B0000FBBF00FF50130000FBBF01FF80070000
      FBBF03FFF87F0000FFFFFFFFFFFF0000FFFFFFFFFFFFFFFFFE00800FFFFF7FFF
      FE008007FFFF1A16FE008003FFF76A5602008001FFF76B9602000000E3950210
      02000000DD65D96503FF000FFB75FB7503F3000FE775E77503E10008DD65DD65
      03F38FF9E395E39503E3FFFAFFFDFFFD06C7FFBEFFFDFFFD0C0FFFDEFFFFFFFF
      FE1FFFE1FFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000000000000
      000000000000}
  end
  object pmQuery: TPopupMenu
    Images = ilQuery
    Left = 216
    Top = 380
    object N5: TMenuItem
      Action = actLoadQuery
    end
    object N6: TMenuItem
      Action = actSaveQuery
    end
    object N7: TMenuItem
      Caption = '-'
    end
    object N8: TMenuItem
      Action = actApplyQueryWithPlan
    end
    object N9: TMenuItem
      Action = actApplyQuery
    end
    object N10: TMenuItem
      Caption = '-'
    end
    object N11: TMenuItem
      Action = actCutQuery
    end
    object N12: TMenuItem
      Action = actCopyQuery
    end
    object N13: TMenuItem
      Action = actPasteQuery
    end
  end
  object SynSQLSyn: TSynSQLSyn
    DefaultFilter = 'SQL Files (*.sql)|*.sql'
    CommentAttri.Foreground = clGreen
    CommentAttri.Style = []
    NumberAttri.Foreground = clBlue
    StringAttri.Foreground = clRed
    SQLDialect = sqlInterbase6
    Left = 276
    Top = 380
  end
  object pmFields: TPopupMenu
    Images = dmImages.il16x16
    Left = 46
    Top = 106
    object N2: TMenuItem
      Action = actFind
    end
    object N3: TMenuItem
      Action = actFindNext
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object actFieldNameCopy1: TMenuItem
      Action = actFieldNameCopy
    end
    object N1: TMenuItem
      Action = actUpperVisible
    end
  end
  object alFields: TActionList
    Images = dmImages.il16x16
    Left = 86
    Top = 106
    object actFieldNameCopy: TAction
      Caption = 'Копировать имя поля'
      ImageIndex = 10
      ShortCut = 16451
      OnExecute = actFieldNameCopyExecute
      OnUpdate = actFieldNameCopyUpdate
    end
    object actUpperVisible: TAction
      Caption = 'Переместить видимые колонки вверх'
      ImageIndex = 47
      OnExecute = actUpperVisibleExecute
    end
    object actFind: TAction
      Caption = 'Найти...'
      ShortCut = 16454
      OnExecute = actFindExecute
      OnUpdate = actFindUpdate
    end
    object actFindNext: TAction
      Caption = 'Найти далее'
      ShortCut = 114
      OnExecute = actFindNextExecute
      OnUpdate = actFindNextUpdate
    end
  end
end
