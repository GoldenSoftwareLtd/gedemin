object dlgViewProperty: TdlgViewProperty
  Left = 276
  Top = 172
  Width = 604
  Height = 569
  Caption = 'Макросы'
  Color = clBtnFace
  DragMode = dmAutomatic
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnActivate = FormActivate
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnDeactivate = FormDeactivate
  PixelsPerInch = 96
  TextHeight = 13
  object pnlButtons: TPanel
    Left = 0
    Top = 509
    Width = 596
    Height = 36
    Align = alBottom
    Alignment = taLeftJustify
    BevelOuter = bvNone
    BorderWidth = 5
    TabOrder = 0
    Visible = False
    object Button1: TButton
      Left = 517
      Top = 7
      Width = 75
      Height = 24
      Hint = 'Сохранить изменения в базу данных'
      Anchors = [akRight, akBottom]
      Caption = 'Отмена'
      ModalResult = 2
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 429
      Top = 7
      Width = 75
      Height = 24
      Action = actFuncCommit
      Anchors = [akRight, akBottom]
      Caption = 'Ok'
      ModalResult = 1
      TabOrder = 1
    end
  end
  object pnlParam: TPanel
    Left = 0
    Top = 0
    Width = 596
    Height = 509
    Align = alClient
    TabOrder = 1
    object Splitter1: TSplitter
      Left = 151
      Top = 79
      Width = 4
      Height = 338
      Cursor = crHSplit
      OnCanResize = Splitter1CanResize
      OnMoved = Splitter1Moved
    end
    object spMessages: TSplitter
      Left = 1
      Top = 426
      Width = 594
      Height = 3
      Cursor = crVSplit
      Align = alBottom
      OnCanResize = spMessagesCanResize
      OnMoved = spMessagesMoved
    end
    object Splitter2: TSplitter
      Left = 582
      Top = 79
      Width = 4
      Height = 338
      Cursor = crHSplit
      Align = alRight
      OnCanResize = Splitter1CanResize
      OnMoved = Splitter2Moved
    end
    object pcFuncParam: TPageControl
      Left = 164
      Top = 79
      Width = 409
      Height = 338
      ActivePage = tsFunction
      Align = alClient
      HotTrack = True
      Style = tsFlatButtons
      TabOrder = 0
      OnChanging = pcFuncParamChanging
      object tsReport: TTabSheet
        Caption = 'Отчёт'
        ImageIndex = 2
        TabVisible = False
        object Label2: TLabel
          Left = 8
          Top = 24
          Width = 53
          Height = 13
          Caption = 'Описание:'
        end
        object Label3: TLabel
          Left = 8
          Top = 88
          Width = 60
          Height = 52
          Caption = 'Частота обновления отчета (дней):'
          WordWrap = True
        end
        object Label5: TLabel
          Left = 8
          Top = 116
          Width = 119
          Height = 13
          Caption = 'Выполнять на сервере:'
        end
        object Label4: TLabel
          Left = 8
          Top = 0
          Width = 83
          Height = 13
          Caption = 'Идентификатор:'
        end
        object DBText1: TDBText
          Left = 163
          Top = 0
          Width = 208
          Height = 17
          DataField = 'ID'
          DataSource = dsReport
        end
        object dbeFrqRefresh: TDBEdit
          Left = 163
          Top = 88
          Width = 208
          Height = 21
          DataField = 'FRQREFRESH'
          DataSource = dsReport
          TabOrder = 0
          OnChange = dbmDescriptionChange
        end
        object dbcbSaveResult: TDBCheckBox
          Left = 8
          Top = 184
          Width = 220
          Height = 17
          Caption = 'Перестраивать отчет заново'
          DataField = 'ISREBUILD'
          DataSource = dsReport
          TabOrder = 1
          ValueChecked = '1'
          ValueUnchecked = '0'
          OnClick = ControlChange
        end
        object dbmDescription: TDBMemo
          Left = 163
          Top = 24
          Width = 208
          Height = 62
          DataField = 'DESCRIPTION'
          DataSource = dsReport
          TabOrder = 2
          OnChange = dbmDescriptionChange
        end
        object dbcbIsLocalExecute: TDBCheckBox
          Left = 8
          Top = 200
          Width = 220
          Height = 17
          Caption = 'Выполнять отчет локально'
          DataField = 'ISLOCALEXECUTE'
          DataSource = dsReport
          TabOrder = 3
          ValueChecked = '1'
          ValueUnchecked = '0'
          OnClick = ControlChange
        end
        object dbcbPreview: TDBCheckBox
          Left = 8
          Top = 168
          Width = 220
          Height = 17
          Caption = 'Отображать отчет перед печатью'
          DataField = 'PREVIEW'
          DataSource = dsReport
          TabOrder = 4
          ValueChecked = '1'
          ValueUnchecked = '0'
          OnClick = ControlChange
        end
        object dbcbReportServer: TDBLookupComboBox
          Left = 163
          Top = 112
          Width = 208
          Height = 21
          DataField = 'SERVERKEY'
          DataSource = dsReport
          DropDownRows = 20
          KeyField = 'ID'
          ListField = 'COMPUTERNAME'
          ListSource = dsReportServer
          TabOrder = 5
          OnClick = dbmDescriptionChange
          OnKeyDown = dbcbReportServerKeyDown
        end
      end
      object tsDescription: TTabSheet
        Caption = 'Описание'
        ImageIndex = 3
        TabVisible = False
        object dbmGroupDescription: TDBMemo
          Left = 0
          Top = 0
          Width = 408
          Height = 223
          Align = alClient
          DataField = 'DESCRIPTION'
          DataSource = dsDescription
          TabOrder = 0
          OnChange = dbmDescriptionChange
        end
      end
      object tsFunction: TTabSheet
        Caption = 'Функция'
        ImageIndex = 3
        TabVisible = False
        object pcFunction: TPageControl
          Left = 0
          Top = 0
          Width = 401
          Height = 328
          ActivePage = tsParams
          Align = alClient
          HotTrack = True
          MultiLine = True
          Style = tsFlatButtons
          TabOrder = 0
          OnChange = pcFunctionChange
          OnChanging = pcFunctionChanging
          object tsFuncMain: TTabSheet
            Caption = 'Свойства'
            object pMacrosAddParams: TPanel
              Left = 0
              Top = 177
              Width = 393
              Height = 120
              Align = alClient
              BevelOuter = bvNone
              TabOrder = 0
              object Label1: TLabel
                Left = 8
                Top = 24
                Width = 119
                Height = 13
                Caption = 'Выполнять на сервере:'
                Layout = tlCenter
              end
              object Label7: TLabel
                Left = 8
                Top = 0
                Width = 88
                Height = 13
                Caption = 'Горячая клавиша'
                Layout = tlCenter
              end
              object dblcbMacrosServer: TDBLookupComboBox
                Left = 144
                Top = 24
                Width = 242
                Height = 21
                Anchors = [akLeft, akTop, akRight]
                DataField = 'SERVERKEY'
                DataSource = dsMacros
                DropDownRows = 20
                KeyField = 'ID'
                ListField = 'COMPUTERNAME'
                ListSource = dsReportServer
                TabOrder = 0
                OnClick = dblcbMacrosServerClick
                OnKeyDown = dblcbMacrosServerKeyDown
              end
              object DBCheckBox1: TDBCheckBox
                Left = 8
                Top = 56
                Width = 220
                Height = 17
                Caption = 'Выполнять макрос локально'
                DataField = 'ISLOCALEXECUTE'
                DataSource = dsMacros
                TabOrder = 1
                ValueChecked = '1'
                ValueUnchecked = '0'
                OnClick = FuncControlChanged
              end
              object DBCheckBox2: TDBCheckBox
                Left = 8
                Top = 72
                Width = 220
                Height = 17
                Caption = 'Пересчитать макрос заново'
                DataField = 'ISREBUILD'
                DataSource = dsMacros
                TabOrder = 2
                ValueChecked = '1'
                ValueUnchecked = '0'
                OnClick = FuncControlChanged
              end
              object hkMacros: THotKey
                Left = 144
                Top = 0
                Width = 242
                Height = 19
                Hint = 'Назначение клавиш для бастрого вызова макросов'
                Anchors = [akLeft, akTop, akRight]
                HotKey = 0
                InvalidKeys = []
                Modifiers = []
                ParentShowHint = False
                ShowHint = True
                TabOrder = 3
              end
            end
            object Panel2: TPanel
              Left = 0
              Top = 0
              Width = 393
              Height = 177
              Align = alTop
              BevelOuter = bvNone
              TabOrder = 1
              object Label12: TLabel
                Left = 8
                Top = 152
                Width = 72
                Height = 13
                Caption = 'Язык скрипта'
              end
              object Label11: TLabel
                Left = 8
                Top = 80
                Width = 70
                Height = 13
                Caption = 'Комментарий'
              end
              object Label6: TLabel
                Left = 8
                Top = 32
                Width = 122
                Height = 13
                Caption = 'Наименование функции'
              end
              object lFunctionID: TLabel
                Left = 8
                Top = 8
                Width = 80
                Height = 13
                Caption = 'Идентификатор'
              end
              object dbtFunctionID: TDBText
                Left = 144
                Top = 8
                Width = 209
                Height = 17
                DataField = 'ID'
                DataSource = dsFunction
              end
              object dbtOwner: TDBText
                Left = 144
                Top = 56
                Width = 209
                Height = 17
                DataField = 'Name'
                DataSource = dsOwner
              end
              object Label8: TLabel
                Left = 8
                Top = 56
                Width = 49
                Height = 13
                Caption = 'Владелец'
              end
              object dbeFunctionName: TDBEdit
                Left = 144
                Top = 32
                Width = 242
                Height = 21
                Anchors = [akLeft, akTop, akRight]
                Color = clWhite
                DataField = 'NAME'
                DataSource = dsFunction
                TabOrder = 0
                OnChange = dbeFunctionNameChange
              end
              object DBMemo1: TDBMemo
                Left = 144
                Top = 80
                Width = 242
                Height = 69
                Anchors = [akLeft, akTop, akRight]
                Ctl3D = True
                DataField = 'COMMENT'
                DataSource = dsFunction
                ParentCtl3D = False
                TabOrder = 1
                OnChange = dbeFunctionNameChange
              end
              object dbcbLang: TDBComboBox
                Left = 144
                Top = 152
                Width = 242
                Height = 21
                Style = csDropDownList
                Anchors = [akLeft, akTop, akRight]
                DataField = 'LANGUAGE'
                DataSource = dsFunction
                Enabled = False
                ItemHeight = 13
                Items.Strings = (
                  'JScript'
                  'VBScript')
                TabOrder = 2
                OnChange = dbcbLangChange
              end
            end
          end
          object tsFuncScript: TTabSheet
            Caption = 'Текст функции'
            ImageIndex = 4
            object gsFunctionSynEdit: TgsFunctionSynEdit
              Left = 0
              Top = 0
              Width = 393
              Height = 278
              Cursor = crIBeam
              gdcFunction = gdcFunction
              Align = alClient
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -15
              Font.Name = 'Courier New'
              Font.Style = []
              ParentColor = False
              ParentFont = False
              PopupMenu = pmdbseScript
              TabOrder = 0
              OnKeyUp = gsFunctionSynEditKeyUp
              OnMouseMove = gsFunctionSynEditMouseMove
              BookMarkOptions.BookmarkImages = imSynEdit
              Gutter.Font.Charset = DEFAULT_CHARSET
              Gutter.Font.Color = clWindowText
              Gutter.Font.Height = -11
              Gutter.Font.Name = 'Terminal'
              Gutter.Font.Style = []
              Highlighter = SynVBScriptSyn1
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
                  Command = ecWordLeft
                  ShortCut = 16421
                end
                item
                  Command = ecSelLeft
                  ShortCut = 8229
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
                  Command = ecSelEditorTop
                  ShortCut = 24612
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
                  Command = ecSetMarker7
                  ShortCut = 24631
                end
                item
                  Command = ecSetMarker6
                  ShortCut = 24630
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
                  ShortCut = 49219
                end
                item
                  Command = ecLineSelect
                  ShortCut = 24652
                end
                item
                  Command = ecMatchBracket
                  ShortCut = 24642
                end
                item
                  Command = ecCodeComplite
                  ShortCut = 24643
                end
                item
                  Command = ecSelMoveLeft
                  ShortCut = 16459
                  ShortCut2 = 16469
                end
                item
                  Command = ecSelMoveRight
                  ShortCut = 16459
                  ShortCut2 = 16457
                end
                item
                  Command = ecFind
                  ShortCut = 16465
                  ShortCut2 = 16454
                end>
              SelectedColor.Background = clBlue
              WantTabs = True
              OnCommandProcessed = gsFunctionSynEditCommandProcessed
              OnGutterClick = gsFunctionSynEditGutterClick
              OnPlaceBookmark = gsFunctionSynEditPlaceBookmark
              OnProcessCommand = gsFunctionSynEditProcessCommand
              OnSpecialLineColors = gsFunctionSynEditSpecialLineColors
              UseParser = False
              ShowOnlyColor = clGray
            end
            object sbFuncEdit: TStatusBar
              Left = 0
              Top = 278
              Width = 393
              Height = 19
              Panels = <
                item
                  Width = 200
                end
                item
                  Width = 50
                end>
              SimplePanel = False
            end
          end
          object tsParams: TTabSheet
            Caption = 'Параметры'
            ImageIndex = 2
            object ScrollBox1: TScrollBox
              Left = 0
              Top = 39
              Width = 393
              Height = 258
              VertScrollBar.Style = ssFlat
              Align = alClient
              BorderStyle = bsNone
              TabOrder = 1
              object Label19: TLabel
                Left = 0
                Top = 0
                Width = 393
                Height = 258
                Align = alClient
                Alignment = taCenter
                Caption = 'Нет параметров'
                Layout = tlCenter
              end
            end
            object pnlCaption: TPanel
              Left = 0
              Top = 0
              Width = 393
              Height = 39
              Align = alTop
              BevelInner = bvRaised
              BevelOuter = bvLowered
              TabOrder = 0
              object Label13: TLabel
                Left = 8
                Top = 4
                Width = 51
                Height = 13
                Caption = 'Параметр'
              end
              object Label14: TLabel
                Left = 8
                Top = 20
                Width = 68
                Height = 13
                Caption = 'Имя таблицы'
              end
              object Label15: TLabel
                Left = 160
                Top = 4
                Width = 76
                Height = 13
                Caption = 'Наименование'
              end
              object Label16: TLabel
                Left = 160
                Top = 20
                Width = 72
                Height = 13
                Caption = 'Поле таблицы'
              end
              object Label17: TLabel
                Left = 312
                Top = 4
                Width = 77
                Height = 13
                Caption = 'Тип параметра'
              end
              object Label18: TLabel
                Left = 312
                Top = 20
                Width = 72
                Height = 13
                Caption = 'Ключ таблицы'
              end
            end
          end
        end
      end
      object tsReportTemplate: TTabSheet
        Caption = 'Шаблон'
        ImageIndex = 3
        TabVisible = False
        object Label20: TLabel
          Left = 8
          Top = 32
          Width = 76
          Height = 13
          Caption = 'Наименование'
        end
        object Label21: TLabel
          Left = 8
          Top = 56
          Width = 50
          Height = 13
          Caption = 'Описание'
        end
        object Label22: TLabel
          Left = 8
          Top = 112
          Width = 66
          Height = 13
          Caption = 'Тип шаблона'
        end
        object Label10: TLabel
          Left = 8
          Top = 12
          Width = 78
          Height = 13
          Caption = 'Шаблон отчета:'
        end
        object DBEdit1: TDBEdit
          Left = 147
          Top = 32
          Width = 208
          Height = 21
          DataField = 'NAME'
          DataSource = dsTemplate
          TabOrder = 0
          OnChange = ControlChange
        end
        object dbeDescription: TDBEdit
          Left = 147
          Top = 56
          Width = 208
          Height = 53
          AutoSize = False
          DataField = 'DESCRIPTION'
          DataSource = dsTemplate
          TabOrder = 1
          OnChange = ControlChange
        end
        object dblcbType: TDBLookupComboBox
          Left = 147
          Top = 112
          Width = 186
          Height = 21
          DataField = 'TEMPLATETYPE'
          DataSource = dsTemplate
          KeyField = 'TemplateType'
          ListField = 'DescriptionType'
          ListSource = dsTemplateType
          TabOrder = 2
          OnClick = ControlChange
        end
        object btnEditTemplate: TButton
          Left = 336
          Top = 112
          Width = 19
          Height = 21
          Action = actEditTemplate
          TabOrder = 3
        end
        object dblcbTemplate: TDBLookupComboBox
          Left = 147
          Top = 8
          Width = 209
          Height = 21
          DataField = 'TEMPLATEKEY'
          DataSource = dsReport
          DropDownRows = 20
          KeyField = 'ID'
          ListField = 'NAME'
          ListSource = dsTemplate1
          TabOrder = 4
          OnClick = dblcbTemplateClick
          OnKeyDown = dblcbTemplateKeyDown
        end
      end
    end
    object TBDock1: TTBDock
      Left = 1
      Top = 1
      Width = 594
      Height = 78
      BoundLines = [blBottom]
      OnRequestDock = TBDock1RequestDock
      object TBToolbar2: TTBToolbar
        Left = 312
        Top = 25
        Caption = 'TBToolbar2'
        DockableTo = [dpTop, dpBottom]
        DockPos = 295
        DockRow = 1
        Images = imMainTool
        ShowCaption = False
        TabOrder = 0
        object TBItem20: TTBItem
          Action = actFuncCommit
          Images = imFunction
        end
        object TBItem1: TTBItem
          Action = actFuncRollback
          Images = imFunction
        end
        object TBSeparatorItem10: TTBSeparatorItem
        end
        object TBControlItem1: TTBControlItem
          Control = dblcbSetFunction
        end
        object dblcbSetFunction: TDBLookupComboBox
          Left = 52
          Top = 0
          Width = 220
          Height = 21
          DataField = 'ID'
          DataSource = dsFunction
          KeyField = 'ID'
          ListField = 'NAME'
          ListSource = dsSetFunction
          TabOrder = 0
          OnClick = dblcbSetFunctionClick
          OnKeyDown = dblcbSetFunctionKeyDown
        end
      end
      object TBToolbar3: TTBToolbar
        Left = 0
        Top = 25
        Caption = 'TBToolbar3'
        DockPos = 0
        DockRow = 1
        Images = imTreeView
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        object TBItem25: TTBItem
          Action = actRefresh
        end
        object TBSeparatorItem2: TTBSeparatorItem
        end
        object TBItem5: TTBItem
          Action = actAddFolder
        end
        object TBItem4: TTBItem
          Action = actDeleteFolder
        end
        object TBSeparatorItem13: TTBSeparatorItem
        end
        object TBItem43: TTBItem
          Action = actAddItem
        end
        object TBItem44: TTBItem
          Action = actDeleteItem
        end
        object TBSeparatorItem14: TTBSeparatorItem
        end
        object TBItem26: TTBItem
          Action = actExecReport
          ImageIndex = 2
          Images = imFunction
        end
        object TBSeparatorItem15: TTBSeparatorItem
        end
        object TBItem27: TTBItem
          Action = actFindInTree
          ImageIndex = 4
          Images = imFunction
        end
        object TBSeparatorItem8: TTBSeparatorItem
          Visible = False
        end
        object TBItem13: TTBItem
          Action = actSQLEditor
          Images = imFunction
        end
        object TBSeparatorItem17: TTBSeparatorItem
        end
        object TBItem22: TTBItem
          Action = actCopyTreeItem
        end
        object TBItem21: TTBItem
          Action = actCutTreeItem
        end
        object TBItem19: TTBItem
          Action = actPasteTreeItem
        end
        object TBSeparatorItem16: TTBSeparatorItem
        end
        object biSpeedReturn: TTBItem
          Action = actSpeedReturn
        end
      end
      object TBToolbar4: TTBToolbar
        Left = 0
        Top = 0
        Caption = 'TBToolbar4'
        CloseButton = False
        DockPos = 0
        FullSize = True
        Images = imTreeView
        MenuBar = True
        ShrinkMode = tbsmWrap
        TabOrder = 2
        object N26_OLD_OLD: TTBSubmenuItem
          Caption = 'Создать'
          object N27_OLD_OLD: TTBItem
            Action = actAddFolder
          end
          object N28_OLD_OLD: TTBItem
            Action = actAddItem
          end
        end
        object N31_OLD_OLD: TTBSubmenuItem
          Caption = 'Удалить'
          object N32_OLD_OLD: TTBItem
            Action = actDeleteFolder
          end
          object N33_OLD_OLD: TTBItem
            Action = actDeleteItem
          end
          object TBSeparatorItem12: TTBSeparatorItem
          end
          object TBItem36: TTBItem
            Action = actDeleteUnusedMethods
          end
          object TBItem37: TTBItem
            Action = actDeleteUnUsedEvents
          end
        end
        object TBSubmenuItem3: TTBSubmenuItem
          Caption = 'Поиск'
          object TBItem30: TTBItem
            Action = actFind
            Images = imFunction
          end
          object TBItem28: TTBItem
            Action = actFindInTree
            Images = imFunction
          end
          object TBItem45: TTBItem
            Action = actFindFunction
          end
          object TBSeparatorItem18: TTBSeparatorItem
          end
          object TBItem7: TTBItem
            Action = actReplace
            Images = imFunction
          end
        end
        object TBSubmenuItem2: TTBSubmenuItem
          Caption = 'Выполнение'
          Images = imglActions
          object TBItem41: TTBItem
            Action = actDebugRun
            Images = imglActions
          end
          object TBItem34: TTBItem
            Action = actPrepare
            ImageIndex = 15
            Images = imglActions
          end
          object TBSeparatorItem3: TTBSeparatorItem
          end
          object TBItem40: TTBItem
            Action = actDebugPause
            Images = imglActions
          end
          object TBItem39: TTBItem
            Action = actDebugStepIn
            Images = imglActions
          end
          object TBItem38: TTBItem
            Action = actDebugStepOver
            Images = imglActions
          end
          object TBItem3: TTBItem
            Action = actDebugGotoCursor
            Images = imglActions
          end
          object TBItem35: TTBItem
            Action = actProgramReset
            Images = imglActions
          end
          object TBSeparatorItem19: TTBSeparatorItem
          end
          object TBItem31: TTBItem
            Action = actToggleBreakpoint
            Images = imglActions
          end
          object TBSeparatorItem1: TTBSeparatorItem
          end
          object TBItem6: TTBItem
            Action = actEvaluate
            Images = imglActions
          end
        end
        object TBSubmenuItem1: TTBSubmenuItem
          Caption = 'Сервис'
          object TBItem33: TTBItem
            Action = actSQLEditor
            Images = imFunction
          end
          object TBSeparatorItem20: TTBSeparatorItem
          end
          object TBItem46: TTBItem
            Action = actProperty
          end
        end
        object N26: TTBSubmenuItem
          Caption = 'Настройки'
          object TBItem42: TTBItem
            Action = actSettings
          end
          object TBItem32: TTBItem
            Action = actOptions
            Images = imFunction
          end
          object TBSeparatorItem22: TTBSeparatorItem
          end
          object TBItem50: TTBItem
            Action = actShowTreeWindow
          end
          object TBItem51: TTBItem
            Action = actShowMessagesWindow
          end
        end
      end
      object TBToolbar1: TTBToolbar
        Left = 0
        Top = 51
        Caption = 'TBToolbar1'
        DefaultDock = TBDock1
        DockPos = 0
        DockRow = 2
        Images = imFunction
        ParentShowHint = False
        ShowHint = True
        TabOrder = 3
        object TBItem16: TTBItem
          Action = actLoadFromFile
        end
        object TBItem15: TTBItem
          Action = actSaveToFile
        end
        object TBSeparatorItem9: TTBSeparatorItem
          Visible = False
        end
        object TBItem14: TTBItem
          Action = actCompile
          Visible = False
        end
        object TBItem18: TTBItem
          Action = actPrepare
          Images = imFunction
          Visible = False
        end
        object TBSeparatorItem7: TTBSeparatorItem
          Visible = False
        end
        object TBItem12: TTBItem
          Action = actFind
        end
        object TBItem11: TTBItem
          Action = actReplace
        end
        object TBSeparatorItem6: TTBSeparatorItem
          Visible = False
        end
        object TBItem49: TTBItem
          Action = actEditCopy
        end
        object TBItem48: TTBItem
          Action = actEditCut
        end
        object TBItem47: TTBItem
          Action = actEditPaste
        end
        object TBSeparatorItem21: TTBSeparatorItem
        end
        object TBItem10: TTBItem
          Action = actCopyText
        end
        object TBItem9: TTBItem
          Action = actPaste
        end
        object TBSeparatorItem5: TTBSeparatorItem
        end
        object TBItem8: TTBItem
          Action = actOptions
        end
        object TBSeparatorItem4: TTBSeparatorItem
        end
        object TBItem2: TTBItem
          ImageIndex = 11
        end
      end
      object TBToolbar5: TTBToolbar
        Left = 281
        Top = 51
        Caption = 'TBToolbar5'
        DockPos = 281
        DockRow = 2
        Images = imglActions
        TabOrder = 4
        object TBItem23: TTBItem
          Action = actDebugRun
        end
        object TBItem24: TTBItem
          Action = actDebugPause
        end
        object TBSeparatorItem11: TTBSeparatorItem
        end
        object TBItem17: TTBItem
          Action = actDebugStepIn
        end
        object TBItem29: TTBItem
          Action = actDebugStepOver
        end
      end
      object tbHistory: TTBToolbar
        Left = 389
        Top = 51
        Align = alRight
        Caption = 'tbHistory'
        DockPos = 313
        DockRow = 2
        Images = imFunction
        ParentShowHint = False
        ShowHint = True
        TabOrder = 5
        OnMouseUp = tbHistoryMouseUp
        object tbiPrev: TTBItem
          Action = actPrev
          Options = [tboDropdownArrow]
        end
        object tbiNext: TTBItem
          Action = actNext
          Options = [tboDropdownArrow]
        end
      end
      object tbtbMethods: TTBToolbar
        Left = 445
        Top = 51
        Caption = 'tbtbMethods'
        DockPos = 368
        DockRow = 2
        ParentShowHint = False
        ShowHint = True
        TabOrder = 6
        Visible = False
        object biDisableMethod: TTBItem
          Action = actDisableMethod
          ImageIndex = 31
          Images = imTreeView
        end
      end
      object tbSpeedBottons: TTBToolbar
        Left = 480
        Top = 51
        Caption = 'tbSpeedBottons'
        DockPos = 480
        DockRow = 2
        TabOrder = 7
        object TBItem52: TTBItem
          Caption = 'ghj'
          OnClick = TBItem52Click
        end
      end
      object frToolBar1: TfrToolBar
        Left = 176
        Top = 80
        Width = 13
        Height = 13
        Caption = 'frToolBar1'
        FullRepaint = False
        TabOrder = 8
        Orientation = toAny
      end
    end
    object sbComment: TStatusBar
      Left = 1
      Top = 489
      Width = 594
      Height = 19
      Panels = <
        item
          Style = psOwnerDraw
          Width = 50
        end>
      SimplePanel = False
      OnDrawPanel = sbCommentDrawPanel
    end
    object TBDock2: TTBDock
      Left = 1
      Top = 79
      Width = 150
      Height = 338
      LimitToOneRow = True
      Position = dpLeft
      OnInsertRemoveBar = TBDock2InsertRemoveBar
      OnRequestDock = TBDock2RequestDock
      OnResize = TBDock2Resize
      object tbTree: TTBToolWindow
        Left = 0
        Top = 0
        Align = alClient
        Caption = 'tbTree'
        CloseButtonWhenDocked = True
        ClientAreaHeight = 320
        ClientAreaWidth = 146
        Stretch = True
        TabOrder = 0
        object tvClasses: TTreeView
          Left = 0
          Top = 0
          Width = 146
          Height = 320
          Align = alClient
          Ctl3D = True
          Constraints.MinWidth = 50
          DragMode = dmAutomatic
          HideSelection = False
          Images = imTreeView
          Indent = 19
          ParentCtl3D = False
          PopupMenu = pmtvClasses
          SortType = stText
          TabOrder = 0
          OnAdvancedCustomDrawItem = tvClassesAdvancedCustomDrawItem
          OnChange = tvClassesChange
          OnChanging = tvClassesChanging
          OnCompare = tvClassesCompare
          OnDblClick = tvClassesDblClick
          OnDeletion = tvClassesDeletion
          OnDragOver = tvClassesDragOver
          OnEdited = tvClassesEdited
          OnEditing = tvClassesEditing
          OnEndDrag = tvClassesEndDrag
          OnExpanding = tvClassesExpanding
          OnGetImageIndex = tvClassesGetImageIndex
          OnStartDrag = tvClassesStartDrag
        end
      end
    end
    object TBDock3: TTBDock
      Left = 155
      Top = 79
      Width = 9
      Height = 338
      Position = dpLeft
      OnRequestDock = TBDock1RequestDock
    end
    object TBDock4: TTBDock
      Left = 1
      Top = 429
      Width = 594
      Height = 60
      LimitToOneRow = True
      Position = dpBottom
      OnInsertRemoveBar = TBDock4InsertRemoveBar
      OnRequestDock = TBDock2RequestDock
      OnResize = TBDock4Resize
      object twMessages: TTBToolWindow
        Left = 0
        Top = 0
        Caption = 'twMessages'
        CloseButtonWhenDocked = True
        ClientAreaHeight = 56
        ClientAreaWidth = 576
        Stretch = True
        TabOrder = 0
        object lvMessages: TListView
          Left = 0
          Top = 0
          Width = 576
          Height = 56
          Align = alClient
          Columns = <
            item
              Width = 1000
            end>
          ColumnClick = False
          HideSelection = False
          IconOptions.Arrangement = iaLeft
          OwnerDraw = True
          ReadOnly = True
          RowSelect = True
          PopupMenu = pmMessages
          ShowColumnHeaders = False
          TabOrder = 0
          ViewStyle = vsReport
          OnClick = lvMessagesClick
          OnCustomDrawItem = lvMessagesCustomDrawItem
          OnDeletion = lvMessagesDeletion
          OnExit = lvMessagesExit
          OnSelectItem = lvMessagesSelectItem
        end
      end
    end
    object TBDock5: TTBDock
      Left = 1
      Top = 417
      Width = 594
      Height = 9
      Position = dpBottom
      OnRequestDock = TBDock1RequestDock
    end
    object TBDock6: TTBDock
      Left = 586
      Top = 79
      Width = 9
      Height = 338
      LimitToOneRow = True
      Position = dpRight
      OnInsertRemoveBar = TBDock6InsertRemoveBar
      OnRequestDock = TBDock2RequestDock
      OnResize = TBDock6Resize
    end
    object TBDock7: TTBDock
      Left = 573
      Top = 79
      Width = 9
      Height = 338
      Position = dpRight
      OnRequestDock = TBDock1RequestDock
    end
  end
  object imTreeView: TImageList
    Left = 40
    Top = 208
    Bitmap = {
      494C010125002700040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      000000000000360000002800000040000000A0000000010020000000000000A0
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
      0000000000000000000084828400848284008482840000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008482840084828400000000008482
      8400848284008482840084828400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FFFF0000FFFF0000808000000000008482840000FFFF0000FF
      FF0000FFFF0000FFFF0084828400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000FFFF0000FFFF0000FFFF000080800000000000848284000082000000FF
      FF0000FFFF0000FFFF0084828400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000008482840000FF
      FF0000FFFF0000FFFF00848284000080800000000000000000000000000000FF
      FF0000FFFF0000FFFF0084828400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008482
      840000FFFF00848284008482840000808000008080000080800000FFFF0000FF
      FF0000FFFF0000FFFF0084828400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000848284000000000084828400008080000080800000FFFF0000FFFF0000FF
      FF000000000000FFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000848284000080800000FFFF0000FFFF0000FFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000008482840000FFFF0000FFFF0000FFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000008482840000FFFF0000000000004080000040
      8000004080000040800000408000004080000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000FF000000FF000000
      FF000000FF000000FF000000FF00004080000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000FF000000FF000000
      FF000000FF000000FF000000FF00000000000000000000000000000000000000
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
      00000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF007F7F7F007F7F7F007F7F7F007F7F7F007F7F7F0000000000FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000BFBFBF00BFBFBF007F7F7F007F7F7F007F7F7F00000000000000
      0000000000000000000000000000000000000000000000000000000000007F7F
      7F007F7F7F000000000000000000FFFFFF00FFFFFF00FFFFFF007F7F7F007F7F
      7F0000000000FFFFFF0000000000000000000000000080808000808080008080
      8000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FF000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000BFBF
      BF00BFBFBF007F7F7F000000000000000000000000007F7F7F007F7F7F007F7F
      7F000000000000000000000000000000000000000000000000007F7F7F000000
      000000000000FFFFFF007F7F7F007F7F7F007F7F7F00FFFFFF00FFFFFF00FFFF
      FF007F7F7F0000000000FFFFFF00000000000000000080808000C0C0C0008080
      8000808080000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000BFBFBF00BFBF
      BF0000000000FFFFFF0000FF0000FFFFFF0000FF0000FFFFFF00000000007F7F
      7F007F7F7F00000000000000000000000000000000007F7F7F00FFFFFF000000
      00007F7F7F007F7F7F000000000000000000000000007F7F7F007F7F7F00FFFF
      FF00FFFFFF007F7F7F00FFFFFF0000000000000000000000000080808000C0C0
      C000808080008080800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000FF000000FF000000FF0000000000000000000000
      0000000000000000000000000000000000000000000000000000BFBFBF000000
      0000FFFFFF000000000000000000000000000000000000000000FFFFFF000000
      00007F7F7F00000000000000000000000000000000007F7F7F00000000007F7F
      7F0000000000000000007F7F7F007F7F7F007F7F7F0000000000000000007F7F
      7F00FFFFFF007F7F7F0000000000FFFFFF000000000000000000000000008080
      8000C0C0C0008080800080808000000000008080800080808000808080000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000FF000000FF000000FF0000000000000000000000
      00000000000000000000000000000000000000000000BFBFBF007F7F7F00FFFF
      FF00000000000000000000FF000000800000008000000000000000000000FFFF
      FF007F7F7F007F7F7F0000000000000000007F7F7F00FFFFFF00000000007F7F
      7F00000000007F7F7F000000000000000000000000007F7F7F00000000007F7F
      7F00FFFFFF00FFFFFF007F7F7F00FFFFFF000000000000000000000000000000
      000080808000C0C0C00080808000808080008080800080808000808080008080
      8000808080000000000000000000000000000000000000000000000000000000
      0000000000000000FF000000FF000000FF000000FF000000FF00000000000000
      00000000000000000000000000000000000000000000BFBFBF000000000000FF
      00000000000000FF00000080000000FF000000800000008000000000000000FF
      0000000000007F7F7F0000000000000000007F7F7F00FFFFFF007F7F7F000000
      00007F7F7F00FFFFFF00000000000000000000000000000000007F7F7F000000
      00007F7F7F00FFFFFF007F7F7F00FFFFFF000000000000000000000000000000
      00000000000080808000C0C0C000C0C0C000C0C0C000C0C0C000808080008080
      8000808080000000000000000000000000000000000000000000000000000000
      0000000000000000FF000000FF000000FF000000FF000000FF00000000000000
      00000000000000000000000000000000000000000000FFFFFF0000000000FFFF
      FF000000000000FF000000FF000000FF000000FF00000080000000000000FFFF
      FF00000000007F7F7F0000000000000000007F7F7F00FFFFFF007F7F7F000000
      00007F7F7F00FFFFFF00000000000000000000000000000000007F7F7F000000
      00007F7F7F00FFFFFF007F7F7F00FFFFFF000000000000000000000000000000
      000080808000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C0008080
      8000808080008080800000000000000000000000000000000000000000000000
      00000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      00000000000000000000000000000000000000000000FFFFFF000000000000FF
      000000000000FFFFFF0000FF000000FF00000080000000FF00000000000000FF
      000000000000BFBFBF0000000000000000007F7F7F00FFFFFF007F7F7F000000
      00007F7F7F00FFFFFF00FFFFFF000000000000000000000000007F7F7F000000
      00007F7F7F00000000007F7F7F00FFFFFF000000000000000000000000000000
      000080808000C0C0C00000000000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000808080008080800000000000000000000000000000000000000000000000
      00000000000000000000000000000000FF000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF007F7F7F00FFFF
      FF000000000000000000FFFFFF00FFFFFF0000FF00000000000000000000FFFF
      FF007F7F7F00BFBFBF0000000000000000007F7F7F0000000000FFFFFF007F7F
      7F00000000007F7F7F00FFFFFF00FFFFFF00FFFFFF007F7F7F00000000007F7F
      7F00FFFFFF00000000007F7F7F00000000000000000000000000000000000000
      000080808000C0C0C00000000000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000808080008080800000000000000000000000000000000000000000000000
      00000000000000000000000000000000FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000BFBFBF000000
      0000FFFFFF000000000000000000000000000000000000000000FFFFFF000000
      0000BFBFBF00000000000000000000000000000000007F7F7F00FFFFFF007F7F
      7F0000000000000000007F7F7F007F7F7F007F7F7F0000000000000000007F7F
      7F00000000007F7F7F00FFFFFF00000000000000000000000000000000000000
      00000000000080808000C0C0C00000000000C0C0C000C0C0C000C0C0C000C0C0
      C000808080000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF00BFBF
      BF0000000000FFFFFF0000FF0000FFFFFF0000FF0000FFFFFF0000000000BFBF
      BF00BFBFBF00000000000000000000000000000000007F7F7F0000000000FFFF
      FF007F7F7F007F7F7F000000000000000000000000007F7F7F007F7F7F000000
      0000000000007F7F7F0000000000000000000000000000000000000000000000
      00000000000080808000C0C0C000C0C0C0000000000000000000C0C0C000C0C0
      C000808080000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FF000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00BFBFBF007F7F7F000000000000000000000000007F7F7F00BFBFBF00BFBF
      BF000000000000000000000000000000000000000000000000007F7F7F000000
      0000FFFFFF00FFFFFF007F7F7F007F7F7F007F7F7F000000000000000000FFFF
      FF007F7F7F000000000000000000000000000000000000000000000000000000
      000000000000000000008080800080808000C0C0C000C0C0C000C0C0C0000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FFFFFF00FFFFFF00FFFFFF00BFBFBF00BFBFBF00000000000000
      0000000000000000000000000000000000000000000000000000000000007F7F
      7F007F7F7F0000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF007F7F7F007F7F
      7F00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008080800080808000808080000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000007F7F7F007F7F7F007F7F7F007F7F7F007F7F7F00000000000000
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
      00000000000000000000000000000000000000000000848484000000FF000000
      8400000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000848484000000FF000000
      8400000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000BFBFBF00BFBFBF007F7F7F007F7F7F007F7F7F00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000084848400848484008484840000000000000000000000
      0000000000000000000000000000000000000000000084848400C6C6C6000000
      FF00000084000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000084848400C6C6C6000000
      FF00000084000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000BFBF
      BF00BFBFBF007F7F7F000000000000000000000000007F7F7F007F7F7F007F7F
      7F00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008484840084848400000000008484
      840084848400848484008484840000000000000000000000000084848400C6C6
      C6000000FF000000840000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000084848400C6C6
      C6000000FF000000840000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000BFBFBF00BFBF
      BF0000000000FFFFFF000000FF00FFFFFF000000FF00FFFFFF00000000007F7F
      7F007F7F7F000000000000000000000000000000000000000000000000000000
      00000000000000FF000000FF000000840000000000008484840000FF000000FF
      000000FF000000FF000084848400000000000000000000000000000000008484
      8400C6C6C6000000FF0000008400000000000000840000008400000084000000
      0000000000000000000000000000000000000000000000000000000000008484
      8400C6C6C6000000FF0000008400000000000000840000008400000084000000
      0000000000000000000000000000000000000000000000000000BFBFBF000000
      0000FFFFFF000000000000000000000000000000000000000000FFFFFF000000
      00007F7F7F000000000000000000000000000000000000000000000000000000
      000000FF000000FF000000FF00000084000000000000848484000084000000FF
      000000FF000000FF000084848400000000000000000000000000000000000000
      000084848400C6C6C60000008400000084000000840000008400000084000000
      8400000084000000000000000000000000000000000000000000000000000000
      000084848400C6C6C60000008400000084000000840000008400000084000000
      84000000840000000000000000000000000000000000BFBFBF007F7F7F00FFFF
      FF0000000000000000000000FF0000008000000080000000000000000000FFFF
      FF007F7F7F007F7F7F00000000000000000000000000000000008484840000FF
      000000FF000000FF0000848484000084000000000000000000000000000000FF
      000000FF000000FF000084848400000000000000000000000000000000000000
      000000000000848484000000FF000000FF000000FF000000FF00000084000000
      8400000084000000000000000000000000000000000000000000000000000000
      000000000000848484000000FF000000FF000000FF000000FF00000084000000
      84000000840000000000000000000000000000000000BFBFBF00000000000000
      FF00000000000000FF00000080000000FF000000800000008000000000000000
      FF00000000007F7F7F0000000000000000000000000000000000000000008484
      840000FF0000848484008484840000840000008400000084000000FF000000FF
      000000FF000000FF000084848400000000000000000000000000000000000000
      0000848484000000FF000000FF000000FF000000FF000000FF000000FF000000
      8400000084000000840000000000000000000000000000000000000000000000
      0000848484000000FF000000FF000000FF000000FF000000FF000000FF000000
      84000000840000008400000000000000000000000000FFFFFF0000000000FFFF
      FF00000000000000FF000000FF000000FF000000FF000000800000000000FFFF
      FF00000000007F7F7F0000000000000000000000000000000000000000000000
      0000848484000000000084848400008400000084000000FF000000FF000000FF
      00000000000000FF000000000000000000000000000000000000000000000000
      0000848484000000FF00C6C6C6000000FF000000FF000000FF000000FF000000
      FF00000084000000840000000000000000000000000000000000000000000000
      0000848484000000FF00C6C6C6000000FF000000FF000000FF000000FF000000
      FF000000840000008400000000000000000000000000FFFFFF00000000000000
      FF0000000000FFFFFF000000FF000000FF00000080000000FF00000000000000
      FF0000000000BFBFBF0000000000000000000000000000000000000000000000
      00000000000000000000848484000084000000FF000000FF000000FF00000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000848484000000FF00C6C6C6000000FF000000FF000000FF000000FF000000
      FF00000084000000840000000000000000000000000000000000000000000000
      0000848484000000FF00C6C6C6000000FF000000FF000000FF000000FF000000
      FF000000840000008400000000000000000000000000FFFFFF007F7F7F00FFFF
      FF000000000000000000FFFFFF00FFFFFF000000FF000000000000000000FFFF
      FF007F7F7F00BFBFBF0000000000000000000000000000000000000000000000
      000000000000000000008484840000FF000000FF000000FF0000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000848484000000FF00C6C6C6000000FF000000FF000000FF000000
      FF00000084000000000000000000000000000000000000000000000000000000
      000000000000848484000000FF00C6C6C6000000FF000000FF000000FF000000
      FF00000084000000000000000000000000000000000000000000BFBFBF000000
      0000FFFFFF000000000000000000000000000000000000000000FFFFFF000000
      0000BFBFBF000000000000000000000000000000000000000000000000000000
      00000000000000000000000000008484840000FF000000000000848484008484
      8400848484008484840084848400848484000000000000000000000000000000
      000000000000848484000000FF000000FF00C6C6C6000000FF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000848484000000FF000000FF00C6C6C600C6C6C6000000FF000000
      FF00000084000000000000000000000000000000000000000000FFFFFF00BFBF
      BF0000000000FFFFFF000000FF00FFFFFF000000FF00FFFFFF0000000000BFBF
      BF00BFBFBF000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000FF000000FF000000
      FF000000FF000000FF000000FF00848484000000000000000000000000000000
      0000000000000000000084848400848484000000FF0000FF000000FF000000FF
      000000FF000000FF000000FF0000000000000000000000000000000000000000
      0000000000000000000084848400848484000000FF000000FF000000FF000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00BFBFBF007F7F7F000000000000000000000000007F7F7F00BFBFBF00BFBF
      BF00000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000FF000000FF000000
      FF000000FF000000FF000000FF00000000000000000000000000000000000000
      0000000000000000000000000000000000008484840000FF000000FF000000FF
      000000FF000000FF000000FF0000000000000000000000000000000000000000
      0000000000000000000000000000000000008484840084848400848484000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FFFFFF00FFFFFF00FFFFFF00BFBFBF00BFBFBF00000000000000
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
      000000000000000000000000000000000000000000000000000000000000DEDE
      DE00DEDEDE00BDBDBD00BDBDBD00BDBDBD00BDBDBD00A5A5A500CECECE00DEDE
      DE00DEDEDE00DEDEDE0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000848484008484
      8400848484000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000848484008484
      8400848484000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000DEDEDE00DEDEDE00BDBD
      BD0073737300212121000000000000000000000000005252520094949400A5A5
      A500CECECE00DEDEDE00EFEFEF00EFEFEF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000848484008484840000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000848484008484840000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000DEDEDE00CECECE00848484004242
      4200000000005252520063636300A5A5A500A5A5A500A5A5A500424242005252
      520094949400B5B5B500DEDEDE00EFEFEF000000000000000000000000008484
      8400000000000000000000000000000000008484840000848400008484000084
      8400000000008484840084848400000000000000000000000000000000008484
      8400000000000000000000000000000000008484840000848400008484000084
      8400000000008484840084848400000000000000000000000000000000000000
      0000000000000000000084848400848484008484840000000000000000000000
      000000000000000000000000000000000000BDBDBD0052525200212121008484
      8400A5A58400636363008C8C6B006B6B6B00636363007B7B3900636363006363
      420042424200A5A5A500B5B5B500DEDEDE000000000000000000848484008484
      8400848484000000000000000000000000000084840000848400008484000084
      8400008484000000000084848400000000000000000000000000848484008484
      8400848484000000000000000000000000000084840000848400008484000084
      8400008484000000000084848400000000000000000000000000000000000000
      0000000000000000000000000000000000008484840084848400000000008484
      8400848484008484840084848400000000009C9C9C0063632100949452005252
      31006B6B6B00BDBDBD008C6B31004200000042000000BD9C9C00DEDEDE008C8C
      6B007352520042212100A5A5A500B5B5B5000000FF0000000000000000008484
      8400848484008484840084848400008484000084840000848400008484000084
      8400008484000000000084848400000000000000FF0000000000000000008484
      8400848484008484840084848400008484000084840000848400008484000084
      8400008484000000000084848400000000000000000000000000000000000000
      0000000000000000FF000000FF000000840000000000848484000000FF000000
      FF000000FF000000FF0084848400000000009C9C9C008484630031313100C6C6
      C600B5B5B500BD9C2100DE7B0000FF390000FF0000009C000000CECECE00DEDE
      DE00DEDEDE009473520042212100A5A5A5000000FF000000FF000000FF000000
      00008484840084848400848484000084840000FFFF0000848400008484000084
      8400008484000084840000000000000000000000FF000000FF000000FF000000
      00008484840084848400848484000084840000FFFF0000848400008484000084
      8400008484000084840000000000000000000000000000000000000000000000
      00000000FF000000FF000000FF00000084000000000084848400008400000000
      FF000000FF000000FF0084848400000000004242210063212100A58463009431
      31007B7B4200DEBD0000BD00000000000000BD000000FF000000A5636300CECE
      CE00BDBD9C008463000042210000848484000000FF000000FF000000FF000000
      FF000000000000000000848484000084840000FFFF0000FFFF00008484000084
      8400008484000084840000000000000000000000FF000000FF000000FF000000
      FF000000000000000000848484000084840000FFFF0000FFFF00008484000084
      8400008484000084840000000000000000000000000000000000848484000000
      FF000000FF000000FF0084848400000084000000000000000000000000000000
      FF000000FF000000FF0084848400000000008484210021210000630000008442
      000084422100FF7B0000BD000000000000009C393900DE5A390073523100B5B5
      9400844200006363420031313100BDBDBD000000FF000000FF000000FF000000
      8400000084000000840000000000000000008484840000FFFF0000FFFF000084
      8400008484000000000000000000000000000000FF000000FF000000FF000000
      8400000084000000840000000000000000008484840000FFFF0000FFFF000084
      8400008484000000000000000000000000000000000000000000000000008484
      84000000FF0084848400848484000000840000008400000084000000FF000000
      FF000000FF000000FF008484840000000000A5A5630063634200212100006300
      0000846300009C210000FF000000FF000000FF000000DEDE3900844200008421
      000073737300212121009C9C9C00000000000000FF000000FF00000084000000
      8400000084000000840000000000000000000000000000848400008484000084
      8400000000000000000000000000000000000000FF000000FF00000084000000
      8400000084000000840000000000000000000000000000848400008484000084
      8400000000000000000000000000000000000000000000000000000000000000
      000084848400000000008484840000008400000084000000FF000000FF000000
      FF00000000000000FF00000000000000000094943100A5A58400B5B594002121
      000000000000420000004200000042000000420000004200000021212100A5A5
      8400212121009C9C9C0000000000000000000000FF000000FF00000084000000
      8400000000000000000084848400848484008484840084848400848484008484
      8400848484000000000000000000000000000000FF000000FF00000084000000
      8400000000000000000084848400848484008484840084848400848484008484
      8400848484000000000000000000000000000000000000000000000000000000
      0000000000000000000084848400000084000000FF000000FF000000FF000000
      000000000000000000000000000000000000CECECE00A5A56300A5A58400A5A5
      A500A5A5A500848463006B6B6B006B6B6B008C8C6B00A5A5A500A5A5A5002121
      21009C9C9C000000000000000000000000000000FF0000008400000000000000
      0000000000008484840000000000FF00000084840000FF000000FF00000000FF
      000000FF00008484840000000000000000000000FF0000008400000000000000
      0000000000008484840000000000FF00000084840000FF000000FF0000000000
      0000848484000000000000000000000000000000000000000000000000000000
      00000000000000000000848484000000FF000000FF000000FF00000000000000
      0000000000000000000000000000000000007B7B3900BDBD9C00A5A584009494
      730094947300ADAD8C008484630084848400848463008484630063636300DEDE
      DE000000000000000000DEDEDE00C6C6C6000000000000000000000000000000
      00000000000000000000FFFF000000000000FF000000FF000000FF00000000FF
      000000FF00008484840084848400848484000000000000000000000000000000
      00000000000000000000FFFF000000000000FF000000FF000000FF0000000000
      0000848484000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000848484000000FF0000000000000000000000
      0000000000000000000000000000000000003131310021210000737331009494
      7300A5A5A5009494940094947300A5A56300CECECE00DEDEDE00000000000000
      0000DEDEDE008484630073523100CEADAD000000000000000000000000000000
      0000000000000000000000000000848400008484000000FF000000FF000000FF
      000000FF000000FF000000FF0000848484000000000000000000000000000000
      00000000000000000000000000008484000084840000FF000000FF0000000000
      0000848484000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000EFEFEF0031313100000000002121
      000042422100A5A56300B5B59400DEDEDE00DEDEDE00DEDEDE00BDBD9C006363
      63002121000031313100EFEFEF00000000000000000000000000000000000000
      00000000000000000000FFFF000000000000FF00000000FF000000FF000000FF
      000000FF000000FF000000FF0000848484000000000000000000000000000000
      00000000000000000000FFFF000000000000FF000000FF000000848484008484
      8400848484008484840084848400848484000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000ADADAD003131
      3100000000000000000000000000000000000000000000000000000000003131
      3100ADADAD000000000000000000000000000000000000000000000000000000
      00000000000000000000000000008484000084840000FF000000FF00000000FF
      000000FF00008484840084848400848484000000000000000000000000000000
      000000000000000000000000000084840000848400000000FF000000FF000000
      FF000000FF000000FF000000FF00848484000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000ADADAD007B7B7B007B7B7B007B7B7B007B7B7B007B7B7B00EFEFEF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFF0000FFFF0000FFFF0000FFFF0000FFFF000000FF
      000000FF00008484840000000000000000000000000000000000000000000000
      00000000000000000000FFFF0000FFFF0000FFFF00000000FF000000FF000000
      FF000000FF000000FF000000FF00848484000000000000000000000000000000
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
      0000000000000000000084848400848484008484840000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000084848400848484008484840000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000084848400848484008484840000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000084848400848484008484840000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008484840084848400000000008484
      8400848484008484840084848400000000000000000000000000000000000000
      0000000000000000000000000000000000008484840084848400000000008484
      8400848484008484840084848400000000000000000000000000000000000000
      0000000000000000000000000000000000008484840084848400000000008484
      8400848484008484840084848400000000000000000000000000000000000000
      0000000000000000000000000000000000008484840084848400000000008484
      8400848484008484840084848400000000000000000000000000000000000000
      000000000000FF000000FF000000840000000000000084848400FF000000FF00
      0000FF000000FF00000084848400000000000000000000000000000000000000
      0000000000000000FF000000FF000000840000000000848484000000FF000000
      FF000000FF000000FF0084848400000000000000000000000000000000000000
      0000000000000000FF000000FF000000840000000000848484000000FF000000
      FF000000FF000000FF0084848400000000000000000000000000000000000000
      00000000000000FFFF0000FFFF0000848400000000008484840000FFFF0000FF
      FF0000FFFF0000FFFF0084848400000000000000000000000000000000000000
      0000FF000000FF000000FF00000084000000000000008484840000840000FF00
      0000FF000000FF00000084848400000000000000000000000000000000000000
      00000000FF000000FF000000FF00000084000000000084848400008400000000
      FF000000FF000000FF0084848400000000000000000000000000000000000000
      00000000FF000000FF000000FF00000084000000000084848400008400000000
      FF000000FF000000FF0084848400000000000000000000000000000000000000
      000000FFFF0000FFFF0000FFFF000084840000000000848484000084000000FF
      FF0000FFFF0000FFFF008484840000000000000000000000000084848400FF00
      0000FF000000FF0000008484840084000000000000000000000000000000FF00
      0000FF000000FF00000084848400000000000000000000000000848484000000
      FF000000FF000000FF0084848400000084000000000000000000000000000000
      FF000000FF000000FF0084848400000000000000000000000000848484000000
      FF000000FF000000FF0084848400000084000000000000000000000000000000
      FF000000FF000000FF00848484000000000000000000000000008484840000FF
      FF0000FFFF0000FFFF00848484000084840000000000000000000000000000FF
      FF0000FFFF0000FFFF0084848400000000000000000000000000000000008484
      8400FF0000008484840084848400840000008400000084000000FF000000FF00
      0000FF000000FF00000084848400000000000000000000000000000000008484
      84000000FF0084848400848484000000840000008400000084000000FF000000
      FF000000FF000000FF0084848400000000000000000000000000000000008484
      84000000FF0084848400848484000000840000008400000084000000FF000000
      FF000000FF000000FF0084848400000000000000000000000000000000008484
      840000FFFF00848484008484840000848400008484000084840000FFFF0000FF
      FF0000FFFF0000FFFF0084848400000000000000000000000000000000000000
      00008484840000000000848484008400000084000000FF000000FF000000FF00
      000000000000FF00000000000000000000000000000000000000000000000000
      000084848400000000008484840000008400000084000000FF000000FF0000FF
      000000FF00008484840000000000000000000000000000000000000000000000
      000084848400000000008484840000008400000084000000FF000000FF000000
      FF00000000000000FF0000000000000000000000000000000000000000000000
      0000848484000000000084848400008484000084840000FFFF0000FFFF0000FF
      FF000000000000FFFF0000000000000000000000000000000000000000000000
      000000000000000000008484840084000000FF000000FF000000FF0000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000084848400000084000000FF000000FF000000FF0000FF
      000000FF00008484840084848400848484000000000000000000000000000000
      0000000000000000000084848400000084000000FF000000FF000000FF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000848484000084840000FFFF0000FFFF0000FFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000084848400FF000000FF000000FF000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000848484000000FF000000FF0000FF000000FF000000FF
      000000FF000000FF000000FF0000848484000000000000000000000000000000
      00000000000000000000848484000000FF000000FF000000FF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000008484840000FFFF0000FFFF0000FFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000084848400FF00000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000848484000000FF0000FF000000FF000000FF
      000000FF000000FF000000FF0000848484000000000000000000000000000000
      0000000000000000000000000000848484000000FF0084848400848484008484
      8400848484008484840084848400848484000000000000000000000000000000
      00000000000000000000000000008484840000FFFF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000000000FF
      000000FF00008484840084848400848484000000000000000000000000000000
      000000000000000000000000000000000000000000000000FF000000FF000000
      FF000000FF000000FF000000FF00848484000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000000000FF
      000000FF00008484840000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000FF000000FF000000
      FF000000FF000000FF000000FF00848484000000000000000000000000000000
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
      0000000000008400000084000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000084000000840000008400000084000000840000008400
      0000840000008400000084000000840000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000FFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000840000000000000000000000840000000000000000000000840000008400
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000084000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00840000000000000000000000000000000000
      0000000000000000000084000000840000008400000084000000840000008400
      0000840000008400000084000000000000000000000000000000000000000000
      00000000000000FFFF0000FFFF00C6C6C60000FFFF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000840000000000000000000000840000000000000084000000000000000000
      0000840000000000000000000000000000000000000084848400008484008484
      8400008484008484840084000000FFFFFF008400000084000000840000008400
      00008400000084000000FFFFFF00840000000000000000000000000000000000
      0000000000000000000084000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0084000000000000000000000000000000000000000000
      00000000000000FFFF000000000000FFFF0000FFFF00C6C6C60000FFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000840000000000000000000000840000000000000084000000000000000000
      0000840000000000000000000000000000000000000000848400848484000084
      8400848484000084840084000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00840000000000000000000000000000000000
      0000000000000000000084000000FFFFFF000000000000000000000000000000
      000000000000FFFFFF0084000000000000000000000000000000000000000000
      000000FFFF00C6C6C60000FFFF0000000000C6C6C60000FFFF0000FFFF00C6C6
      C60000FFFF000000000000000000000000000000000000000000000000000000
      0000000000008400000084000000840000000000000084000000000000000000
      0000840000000000000000000000000000000000000084848400008484008484
      8400008484008484840084000000FFFFFF00840000008400000084000000FFFF
      FF00840000008400000084000000840000000000000000000000000000000000
      0000000000000000000084000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0084000000000000000000000000000000000000000000
      000000FFFF000000000000FFFF00C6C6C6000000000000000000C6C6C60000FF
      FF0000FFFF0000FFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000840000000000000084000000840000008400
      0000000000000000000000000000000000000000000000848400848484000084
      8400848484000084840084000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0084000000FFFFFF00840000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0084000000FFFFFF000000000000000000000000000000
      000000000000FFFFFF00840000000000000000000000000000000000000000FF
      FF00C6C6C60000FFFF000000000000FFFF0000FFFF00C6C6C60000000000C6C6
      C60000FFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000840000000000000084000000000000000000
      0000000000000000000000000000000000000000000084848400008484008484
      8400008484008484840084000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF008400000084000000000000000000000000000000FFFFFF00000000000000
      0000000000000000000084000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00840000000000000000000000000000000000000000FF
      FF000000000000FFFF00C6C6C600000000000000000000FFFF0000FFFF00C6C6
      C60000FFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000848400848484000084
      8400848484000084840084000000840000008400000084000000840000008400
      00008400000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0084000000FFFFFF000000000000000000FFFFFF008400
      000084000000840000008400000000000000000000000000000000FFFF00C6C6
      C60000FFFF000000000000FFFF0000FFFF00C6C6C6000000000000FFFF0000FF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000084848400008484008484
      8400008484008484840000848400848484000084840084848400008484008484
      84000084840000000000000000000000000000000000FFFFFF00000000000000
      0000000000000000000084000000FFFFFF00FFFFFF00FFFFFF00FFFFFF008400
      0000FFFFFF0084000000000000000000000000000000000000000000000000FF
      FF0000FFFF00C6C6C600000000000000000000FFFF0000FFFF00C6C6C60000FF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000848400848484000000
      0000000000000000000000000000000000000000000000000000000000008484
      84008484840000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0084000000FFFFFF00FFFFFF00FFFFFF00FFFFFF008400
      0000840000000000000000000000000000000000000000000000000000000000
      00000000000000FFFF0000FFFF00C6C6C6008484840084848400848484008484
      8400848484008484840084848400848484000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000084848400848484000000
      0000000000000000000000000000000000000000000000000000000000008484
      84000084840000000000000000000000000000000000FFFFFF00000000000000
      0000FFFFFF000000000084000000840000008400000084000000840000008400
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000FFFF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF00848484000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000848400848484000084
      84000000000000FFFF00000000000000000000FFFF0000000000848484000084
      84008484840000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF00848484000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000FFFF0000FFFF000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
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
      0000000000000000000000000000000000000000000084848400848484008484
      8400848484008484840084848400848484008484840084848400848484008484
      8400848484008484840084848400000000000000000000000000848484000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000848484000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000FFFF00000000000000000000000000000000000000
      00000000000000000000000000000000000000000000848484000000000000FF
      FF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60000FF
      FF00C6C6C60000FFFF0084848400000000000000000000000000848484008484
      8400848484000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000848484008484
      8400848484000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FFFF0000FFFF00C6C6C60000FFFF0000000000000000000000
      000000000000000000000000000000000000000000008484840000000000C6C6
      C60000FFFF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6
      C60000FFFF00C6C6C60084848400000000000000000000000000848484008400
      0000FF0000008484840084848400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000848484008400
      0000FF0000008484840084848400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FFFF000000000000FFFF0000FFFF00C6C6C60000FFFF000000
      00000000000000000000000000000000000000000000848484000000000000FF
      FF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60000FF
      FF00C6C6C60000FFFF008484840000000000000000000000000084848400FF00
      000084000000FF000000FF000000848484008484840000000000000000000000
      000000000000000000000000000000000000000000000000000084848400FF00
      000084000000FF000000FF000000848484008484840000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000FFFF00C6C6C60000FFFF0000000000C6C6C60000FFFF0000FFFF00C6C6
      C60000FFFF00000000000000000000000000000000008484840000000000C6C6
      C60000FFFF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6
      C60000FFFF00C6C6C60084848400000000000000000000000000848484008400
      0000FF00000084000000FF00000084000000FF00000084848400848484000000
      0000000000000000000000000000000000000000000000000000848484008400
      0000FF00000084000000FF00000084000000FF00000084848400848484000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000FFFF000000000000FFFF00C6C6C6000000000000000000C6C6C60000FF
      FF0000FFFF0000FFFF00000000000000000000000000848484000000000000FF
      FF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60000FF
      FF00C6C6C60000FFFF008484840000000000000000000000000084848400FF00
      000084000000FF00000084000000FF00000084000000FF000000840000008484
      840084848400000000000000000000000000000000000000000084848400FF00
      000084000000FF00000084000000FF00000084000000FF000000840000008484
      84008484840000000000000000000000000000000000000000000000000000FF
      FF00C6C6C60000FFFF000000000000FFFF0000FFFF00C6C6C60000000000C6C6
      C60000FFFF00000000000000000000000000000000008484840000000000C6C6
      C60000FFFF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6
      C60000FFFF00C6C6C60084848400000000000000000000000000848484008400
      0000FF00000084000000FF00000084000000FF00000084000000FF0000008400
      0000FF0000008484840000000000000000000000000000000000848484008400
      0000FF00000084000000FF00000084000000FF00000084000000FF0000008400
      0000FF00000084848400000000000000000000000000000000000000000000FF
      FF000000000000FFFF00C6C6C600000000000000000000FFFF0000FFFF00C6C6
      C60000FFFF0000000000000000000000000000000000848484000000000000FF
      FF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60000FF
      FF00C6C6C60000FFFF008484840000000000000000000000000084848400FF00
      0000FF000000FF00000084000000FF00000084000000FF0000008400000000FF
      000000FF0000848484000000000000000000000000000000000084848400FF00
      0000FF000000FF00000084000000FF00000084000000FF000000840000008484
      840084848400000000000000000000000000000000000000000000FFFF00C6C6
      C60000FFFF000000000000FFFF0000FFFF00C6C6C6000000000000FFFF0000FF
      FF0000FF000000FF000084848400000000000000000084848400000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000008484840000000000000000000000000084848400FF00
      0000FF000000FF000000FF00000084000000FF000000848484008484840000FF
      000000FF0000848484008484840084848400000000000000000084848400FF00
      0000FF000000FF000000FF00000084000000FF00000084848400848484000000
      00000000000000000000000000000000000000000000000000000000000000FF
      FF0000FFFF00C6C6C600000000000000000000FFFF0000FFFF00C6C6C60000FF
      FF0000FF000000FF000084848400848484000000000084848400C6C6C60000FF
      FF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60084848400848484008484
      840084848400848484008484840000000000000000000000000084848400FF00
      0000FF000000FF000000FF000000848484008484840000FF000000FF000000FF
      000000FF000000FF000000FF000084848400000000000000000084848400FF00
      0000FF000000FF000000FF000000848484008484840000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FFFF0000FFFF00C6C6C6000000000000FFFF0000FF000000FF
      000000FF000000FF000000FF000000FF0000000000000000000084848400C6C6
      C60000FFFF00C6C6C60000FFFF00C6C6C6008484840000000000000000000000
      000000000000000000000000000000000000000000000000000084848400FF00
      0000FF0000008484840084848400000000000000000000FF000000FF000000FF
      000000FF000000FF000000FF000084848400000000000000000084848400FF00
      0000FF000000848484008484840000000000000000000000FF000000FF000000
      FF000000FF000000FF000000FF00000000000000000000000000000000000000
      000000000000000000000000000000FFFF0000FFFF00C6C6C60000FF000000FF
      000000FF000000FF000000FF000000FF00000000000000000000000000008484
      840084848400848484008484840084848400000000000021C6000021C6000021
      C6000021C6000021C6000021C600848484000000000000000000848484008484
      84008484840000000000000000000000000000000000000000000000000000FF
      000000FF00008484840084848400848484000000000000000000848484008484
      840084848400000000000000000000000000000000000000FF000000FF000000
      FF000000FF000000FF000000FF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000FFFF00000000000000
      000000FF000000FF000084848400848484000000000000000000000000000000
      000000000000000000000000000000000000000000000000FF000000FF000000
      FF000000FF000000FF000000FF00848484000000000000000000848484000000
      00000000000000000000000000000000000000000000000000000000000000FF
      000000FF00008484840000000000000000000000000000000000848484000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000FF000000FF000084848400000000000000000000000000000000000000
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
      0000000000000000000000000000000000000000000084848400848484008484
      8400848484008484840084848400848484008484840084848400848484008484
      8400848484008484840084848400000000000000000000000000848484008484
      8400848484008484840084848400848484008484840084848400848484008484
      8400848484008484840000000000000000000000000000000000000000000000
      0000000000000000000000FFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000084848400848484008484
      8400848484008484840084848400848484008484840084848400848484008484
      84008484840084848400848484000000000000000000848484000000000000FF
      FF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60000FF
      FF00C6C6C60000FFFF0084848400000000000000000000000000848484000000
      000000FFFF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6
      C60000FFFF008484840000000000000000000000000000000000000000000000
      00000000000000FFFF0000FFFF00C6C6C60000FFFF0000000000000000000000
      00000000000000000000000000000000000000000000848484000000000000FF
      FF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60000FF
      FF00C6C6C60000FFFF008484840000000000000000008484840000000000C6C6
      C60000FFFF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6
      C60000FFFF00C6C6C600848484000000000000000000848484000000000000FF
      FF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60000FF
      FF00C6C6C6000000000084848400000000000000000000000000000000000000
      00000000000000FFFF000000000000FFFF0000FFFF00C6C6C60000FFFF000000
      000000000000000000000000000000000000000000008484840000000000C6C6
      C60000FFFF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6
      C60000FFFF00C6C6C600848484000000000000000000848484000000000000FF
      FF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60000FF
      FF00C6C6C60000FFFF008484840000000000000000008484840000000000C6C6
      C60000FFFF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6
      C600848484000000000084848400000000000000000000000000000000000000
      000000FFFF00C6C6C60000FFFF0000000000C6C6C60000FFFF0000FFFF00C6C6
      C60000FFFF0000000000000000000000000000000000848484000000000000FF
      FF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60000FF
      FF00C6C6C60000FFFF008484840000000000000000008484840000000000C6C6
      C60000FFFF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6
      C60000FFFF00C6C6C60084848400000000008484840000000000C6C6C60000FF
      FF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60000FF
      FF00000000008484840084848400000000000000000000000000000000000000
      000000FFFF000000000000FFFF00C6C6C6000000000000000000C6C6C60000FF
      FF0000FFFF00C6C6C6000000000000000000000000008484840000000000C6C6
      C60000FFFF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6
      C60000FFFF00C6C6C600848484000000000000000000848484000000000000FF
      FF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60000FF
      FF00C6C6C60000FFFF0084848400000000008484840000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008484
      840000000000C6C6C600848484000000000000000000000000000000000000FF
      FF00C6C6C60000FFFF000000000000FFFF0000FFFF00C6C6C60000000000C6C6
      C60000FFFF0000000000000000000000000000000000848484000000000000FF
      FF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60000FF
      FF00C6C6C60000FFFF008484840000000000000000008484840000000000C6C6
      C60000FFFF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6
      C60000FFFF00C6C6C60084848400000000008484840084848400848484008484
      8400848484008484840084848400848484008484840084848400848484008484
      84008484840000FFFF00848484000000000000000000000000000000000000FF
      FF000000000000FFFF00C6C6C600000000000000000000FFFF0000FFFF00C6C6
      C60000FFFF00000000000000000000000000000000008484840000000000C6C6
      C60000FFFF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6
      C60000FFFF00C6C6C600848484000000000000000000848484000000000000FF
      FF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60000FF
      FF00C6C6C60000FFFF008484840000000000000000008484840000000000C6C6
      C60000FFFF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6
      C60000FFFF00C6C6C6008484840000000000000000000000000000FFFF00C6C6
      C60000FFFF000000000000FFFF0000FFFF00C6C6C6000000000000FFFF0000FF
      FF000000000000000000000000000000000000000000848484000000000000FF
      FF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C6008484
      8400848484008484840084848400000000000000000084848400000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000848484000000000000000000848484000000000000FF
      FF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60000000000000000000000
      00000000000000000000848484000000000000000000000000000000000000FF
      FF0000FFFF00C6C6C600000000000000000000FFFF0000FFFF00C6C6C60000FF
      FF00000000000000000000000000000000000000000084848400000000000000
      00000000000000000000000000000000000000000000000000000000000000FF
      000000FF00008484840084848400000000000000000084848400C6C6C60000FF
      FF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60084848400848484008484
      840084848400848484008484840000000000000000008484840000000000C6C6
      C60000FFFF00C6C6C60000FFFF00C6C6C6000000000084848400848484008484
      8400848484008484840084848400000000000000000000000000000000000000
      00000000000000FFFF0000FFFF00C6C6C6000000000000FFFF0000FFFF000000
      0000000000000000000000000000000000000000000084848400C6C6C60000FF
      FF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C600848484008484840000FF
      000000FF0000848484008484840084848400000000000000000084848400C6C6
      C60000FFFF00C6C6C60000FFFF00C6C6C6008484840000000000000000000000
      0000000000000000000000000000000000000000000000000000848484000000
      0000000000000000000000000000000000008484840000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000FFFF0000FFFF00C6C6C60000FFFF000000
      000000000000000000000000000000000000000000000000000084848400C6C6
      C60000FFFF00C6C6C60000FFFF00C6C6C6008484840000FF000000FF000000FF
      000000FF000000FF000000FF0000848484000000000000000000000000008484
      8400848484008484840084848400848484000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008484
      8400848484008484840084848400848484000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000FFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000008484
      8400848484008484840084848400848484000000000000FF000000FF000000FF
      000000FF000000FF000000FF0000848484000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000000000FF
      000000FF00008484840084848400848484000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000000000FF
      000000FF00008484840000000000000000000000000000000000000000000000
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
      0000000000000000000000000000000000000000000000000000848484000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000084848400848484008484840000000000000000000000
      0000000000000000000000000000000000000000000000000000C6C6C6008484
      8400848484000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FF000000FF00
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FF000000FF00
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008484840084848400000000008484
      8400848484008484840084848400000000000000000000000000C6C6C6008400
      0000FF0000008484840084848400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FF000000FF00
      0000FF000000FF00000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FF000000FF00
      0000FF000000FF00000000000000000000000000000000000000000000000000
      00000000000000FF000000FF000000840000000000008484840000FF000000FF
      000000FF000000FF000084848400000000000000000000000000C6C6C600FF00
      000084000000FF000000FF000000848484008484840000000000000000000000
      00000000000000000000000000000000000000000000000000000000000000FF
      FF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000000000FF000000FF00
      00000000000000000000000000000000000000000000000000000000000000FF
      FF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60000000000FF000000FF00
      0000000000000000000000000000000000000000000000000000000000000000
      000000FF000000FF000000FF00000084000000000000848484000084000000FF
      000000FF000000FF000084848400000000000000000000000000C6C6C6008400
      0000FF00000084000000FF00000084000000FF00000084848400848484000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF0000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF000000
      000000FFFF00C6C6C60000FFFF00C6C6C60000FFFF0000000000000000000000
      000000FFFF0000000000000000000000000000000000000000008484840000FF
      000000FF000000FF0000848484000084000000000000000000000000000000FF
      000000FF000000FF000084848400000000000000000000000000C6C6C600FF00
      000084000000FF00000084000000FF00000084000000FF000000840000008484
      84008484840000000000000000000000000000000000000000000000000000FF
      FF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000000000FFFFFF0000FF
      FF0000000000000000000000000000000000000000000000000000FFFF00FFFF
      FF000000000000FFFF00C6C6C60000FFFF00C6C6C60000000000C6C6C60000FF
      FF00C6C6C60000FFFF0000000000000000000000000000000000000000008484
      840000FF0000848484008484840000840000008400000084000000FF000000FF
      000000FF000000FF000084848400000000000000000000000000C6C6C6008400
      0000FF00000084000000FF00000084000000FF00000084000000FF0000008400
      0000FF000000848484000000000000000000000000000000000000000000FFFF
      FF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFF
      FF00000000000000000000000000000000000000000000000000FFFFFF0000FF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000848484000000000084848400008400000084000000FF000000FF000000FF
      00000000000000FF000000000000000000000000000000000000C6C6C600FF00
      0000FF000000FF00000084000000FF00000084000000FF00000084000000C6C6
      C600C6C6C60000000000000000000000000000000000000000000000000000FF
      FF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FF
      FF0000000000000000000000000000000000000000000000000000FFFF00FFFF
      FF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000848484000084000000FF000000FF000000FF00000000
      0000000000000000000000000000000000000000000000000000C6C6C600FF00
      0000FF000000FF000000FF00000084000000FF000000C6C6C600C6C6C6000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFF
      FF00000000000000000000000000000000000000000000000000FFFFFF0000FF
      FF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000008484840000FF000000FF000000FF0000000000000000
      0000000000000000000000000000000000000000000000000000C6C6C600FF00
      0000FF000000FF000000FF000000C6C6C600C6C6C60000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000FFFF00FFFF
      FF0000FFFF00FFFFFF0000FFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000008484840000FF000000000000000000000000
      0000000000000000000000000000000000000000000000000000C6C6C600FF00
      0000FF000000C6C6C600C6C6C600000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF0000FFFF00FFFFFF0000FFFF000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000000000FF
      FF00FFFFFF0000FFFF00FFFFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C6C6C600C6C6
      C600C6C6C6000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008484
      8400000000000000000000000000000000008484840000000000000000000000
      0000000000000000000000000000000000000000000000000000848484000000
      0000000000000000000000000000848484000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C6C6C6000000
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
      0000000000000000000000000000000000000000000000000000000000008484
      8400848484008484840000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000848484008400000084000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008484840084848400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008484840084000000840000008400000084000000840000000000
      0000000000000000000000000000000000000000000084848400848484008484
      8400848484008484840084848400848484008484840084848400848484008484
      8400848484008484840000000000000000000000000000000000000000000000
      0000848484000000000000000000000000000000000084848400008484000084
      8400008484000000000084848400848484000000000080808000000080000080
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000848484008484
      8400840000008400000084000000FF0000008400000084000000840000008400
      0000000000000000000000000000000000008484840000000000000000008484
      8400000000008484840084848400000000000000000084848400848484000000
      0000848484008484840000000000000000000000000000000000000000008484
      8400848484008484840000000000000000000000000000848400008484000084
      8400008484000084840000000000848484000000000080808000C0C0C0000000
      8000008000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000084848400840000008400
      000084000000FF000000FF000000FF0000008400000084000000840000008400
      000084000000840000000000000000000000848484000000000000000000FFFF
      000000000000FFFF0000FFFF000000000000000000000000000000000000FFFF
      000084848400848484000000000000000000000000000000FF00000000000000
      0000848484008484840084848400848484000084840000848400008484000084
      840000848400008484000000000084848400000000000000000080808000C0C0
      C000000080000080000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000008484840084000000FF00
      0000FF000000FF000000FF000000FF0000000000000084000000840000008400
      00008400000084000000840000000000000000000000FFFF0000FFFF00000000
      0000000000000000000000000000FFFF000000000000FFFF0000FFFF00000000
      000000000000848484000000000000000000000000000000FF000000FF000000
      FF00000000008484840084848400848484000084840000FFFF00008484000084
      8400008484000084840000848400000000000000000000000000000000008080
      8000C0C0C0000000800000800000000000000080000000800000008000000000
      000000000000000000000000000000000000000000008484840084000000FF00
      0000FF000000FF0000000000000000000000C6C6C60000000000000000008400
      000084000000840000008400000000000000848484000000000000000000FFFF
      000000000000FFFF0000FFFF000000000000000000000000000000000000FFFF
      000084848400848484000000000000000000000000000000FF000000FF000000
      FF000000FF000000000000000000848484000084840000FFFF0000FFFF000084
      8400008484000084840000848400000000000000000000000000000000000000
      000080808000C0C0C00000008000008000000080000000800000008000000080
      000000800000000000000000000000000000000000008484840084000000FF00
      00000000000000000000FFFF0000FFFF0000FFFF000084848400848484000000
      00000000000084000000840000000000000000000000FFFF0000FFFF00000000
      0000000000000000000000000000FFFF000000000000FFFF0000FFFF00000000
      000000000000848484000000000000000000000000000000FF000000FF000000
      FF0000008400000084000000840000000000000000008484840000FFFF0000FF
      FF00008484000084840000000000000000000000000000000000000000000000
      0000000000008080800000FF000000FF000000FF000000FF0000008000000080
      0000008000000000000000000000000000000000000000000000000000000000
      0000FFFF0000FFFF0000FFFF0000000084000000840000008400C6C6C6008484
      840084848400000000000000000000000000848484000000000000000000FFFF
      000000000000FFFF0000FFFF000000000000000000000000000000000000FFFF
      000084848400848484000000000000000000000000000000FF000000FF000000
      8400000084000000840000008400000000000000000000000000008484000084
      8400008484000000000000000000000000000000000000000000000000000000
      00008080800000FF000000FF000000FF000000FF000000FF000000FF00000080
      0000008000000080000000000000000000000000000084848400FFFF0000FFFF
      0000FFFF00008484840000008400000084000000840000008400000084000000
      00000000000084848400848484000000000000000000FFFF0000FFFF00000000
      0000000000000000000000000000FFFF000000000000FFFF0000FFFF00000000
      000000000000848484000000000000000000000000000000FF000000FF000000
      8400000084000000000000000000848484008484840084848400848484008484
      8400848484008484840000000000000000000000000000000000000000000000
      00008080800000FF00000000000000FF000000FF000000FF000000FF000000FF
      0000008000000080000000000000000000000000000000000000848484008484
      84008484840084848400000084000000FF000000FF0000008400000084000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      000000000000FFFF0000FFFF000000000000000000000000000000000000FFFF
      000000000000848484000000000000000000000000000000FF00000084000000
      000000000000000000008484840000000000FF00000084840000FF000000FF00
      0000000000008484840000000000000000000000000000000000000000000000
      00008080800000FF00000000000000FF000000FF000000FF000000FF000000FF
      0000008000000080000000000000000000000000000000000000000000000000
      000084848400000084000000FF00C6C6C6000000FF000000FF00000084000000
      8400000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008484840000000000000000000000000000000000000000000000
      0000000000000000000000000000FFFF000000000000FF000000FF000000FF00
      0000000000008484840000000000000000000000000000000000000000000000
      0000000000008080800000FF00000000000000FF000000FF000000FF000000FF
      0000008000000000000000000000000000000000000000000000000000000000
      000084848400000084000000FF00C6C6C6000000FF000000FF00000084000000
      8400000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008484000084840000FF000000FF00
      0000000000008484840000000000000000000000000000000000000000000000
      0000000000008080800000FF000000FF0000000000000000000000FF000000FF
      0000008000000000000000000000000000000000000000000000000000000000
      00008484840084848400000084000000FF00C6C6C600C6C6C600000084008484
      8400000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FFFF000000000000FF000000FF000000FF00
      0000000000008484840000000000000000000000000000000000000000000000
      00000000000000000000808080008080800000FF000000FF000000FF00000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008484840000008400000084000000FF000000FF00000084000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008484000084840000FF000000FF00
      0000840000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008080800080808000808080000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000084848400848484000000840000008400000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FFFF0000FFFF0000FFFF0000FFFF0000FFFF
      0000FFFF00000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000A00000000100010000000000000500000000000000000000
      000000000000000000000000FFFFFF00FFFF000000000000FFFF000000000000
      FFFF000000000000FC7F000000000000F821000000000000F001000000000000
      E001000000000000C001000000000000E001000000000000F40B000000000000
      FC1F000000000000FC3F000000000000FE40000000000000FF80000000000000
      FF81000000000000FFFF000000000000FFFFFC1FFFFFFEFFF83FF027CFFFFEFF
      E00FE60B87FFFC7FC007D80583FFFC7F80039381C11FF83F8003AC62E007F83F
      00012BA0F003F01F000113D0F803F01F000113D0F001E00F000111D4F201E00F
      00014825F201FC7F80038C69F903FC7F8003A39BF8C3FC7FC007D067FC07FC7F
      E00FE40FFF1FFC7FF83FF83FFFFFFC7FFFFFFFFFFFFFFFFFFFFFCFFFCFFFF83F
      FFFF87FF87FFE00FFC7F83FF83FFC007F821C11FC11F8003F001E007E0078003
      E001F003F0030001C001F803F8030001E001F001F0010001F40BF001F0010001
      FC1FF001F0010001FC3FF803F8038003FE40F800F8038003FF80FC00FC07C007
      FF81FF01FF1FE00FFFFFFFFFFFFFF83FFFFFE003FFC7FFC7FFFF8000FF83FF83
      FFFF0000EF01EF01FC7F0000C701C701F821000000010001F001000000030003
      E001000000030003C001000001070107E0010001038F038FF40B00030C070C07
      FC1F00073A033A07FC3F000CFD00FD07FE7F0030FE00FE07FFFF0001FD00FD00
      FFFFC007FE00FE00FFFFF01FFC03FC00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFC7FFC7FFC7FFC7FF821F821F821F821F001F001F001F001
      E001E001E001E001C001C001C001C001E001E001E001E001F40BF403F40BF40B
      FC1FFC00FC1FFC1FFC3FFC00FC3FFC3FFE7FFE00FE00FE7FFFFFFFE0FF80FFFF
      FFFFFFE3FF80FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF9FFF9FFFC00FFFF
      F87FF6CF8000FC01F01FF6B70000FC01F007F6B70000FC01E001F8B700000001
      E001FE8F00010001C003FE3F00030001C003FF7F000300018007FE3F00030003
      8007FEBF00030007E000FC9F0FC3000FF800FDDF000300FFFE00FDDF800701FF
      FF9FFDDFF87F03FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC000FFFFFFFFF9FF
      8000DFFFDFFFF87FA000C7FFC7FFF01FA000C1FFC1FFF007A000C07FC07FE001
      A000C01FC01FE001A000C007C007C003A000C003C003C003A000C003C0078001
      BFFCC000C01F80008001C000C07FE000C07FC180C181F800E080C7E0C781FE10
      FF80DFE3DFFFFF91FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC000E000F9FFC000
      8000C000F87F8000A000D000F01FA000A000A000F007A000A000A000E001A000
      A0004000E001A000A0007FE0C003A000A0000000C003A000A000A0008007A000
      BFFCA07C8007BFE08001A081E00F8000C07FDF7FF80FC000E0FFE0FFFE1FE080
      FFFFFFFFFF9FFFE0FFFFFFFFFFFFFFE3FFFFFFFFFFFFFFFFFFFFFFFFFFBFFFBF
      FFFFDFFFFF8FFF8FFC7FC7FFFF83FF83F821C1FFE001C001F001C07FC0038003
      E001C01FC0078003C001C007C0078001E001C003C0078001F40BC007C007800F
      FC1FC01FC007800FFC3FC07FC00F801FFE7FC1FFE07FC0FFFFFFC7FFE07FC0FF
      FFFFDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE3FFFFFE3FFFFFFFC1CFFF
      F80F8003F78087FFC0030003E38083FF800061638000C11F800016138001E007
      800061638001F003800016138083F803C001616381C7F001800016138603F201
      C00161639D03F201F0070003FE83F903F0070007FF03F8C3F007FFFFFE83FC07
      F80FFFFFFF07FF1FFC1FFFFFFE07FFFF00000000000000000000000000000000
      000000000000}
  end
  object SynVBScriptSyn1: TSynVBScriptSyn
    DefaultFilter = 'VBScript files (*.vbs)|*.vbs'
    CommentAttri.Foreground = clRed
    NumberAttri.Style = [fsUnderline]
    StringAttri.Foreground = clBlue
    Left = 80
    Top = 368
  end
  object SynJScriptSyn1: TSynJScriptSyn
    DefaultFilter = 'Javascript files (*.js)|*.js'
    CommentAttri.Foreground = clRed
    NumberAttri.Style = [fsUnderline]
    StringAttri.Foreground = clBlue
    Left = 120
    Top = 368
  end
  object imSynEdit: TImageList
    Left = 72
    Top = 208
    Bitmap = {
      494C01010F001300040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000005000000001002000000000000050
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
      0000000000000000000000000000000000000000000000000000000000000084
      8400008484000084840000848400008484000084840000848400008484000084
      8400008484000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000848400C6C6
      C60000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FF
      FF00C6C6C6000084840000000000000000000000000000000000000000000000
      0000000000000000000000000000840000008400000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000084840000FF
      FF0000FFFF0000FFFF0000FFFF00000000000000000000FFFF0000FFFF0000FF
      FF0000FFFF000084840000000000000000000000000000000000000000000000
      00000000000000000000FFFF0000FF0000008400000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000FF000000FFFF
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000084840000FF
      FF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FF
      FF0000FFFF000084840000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FF0000000000
      0000000000000000000000000000000000000000000000000000FF000000FF00
      0000FFFF00000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000848400C6C6
      C60000FFFF0000FFFF0000FFFF00000000000000000000FFFF0000FFFF0000FF
      FF00C6C6C6000084840000000000000000000000000000000000000000000000
      00000000000000000000FFFF0000FF0000008400000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FF00
      0000000000000000000000000000000000000000000000000000FF000000FF00
      0000FF000000FFFF000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000084
      840000FFFF0000FFFF0000FFFF00000000000000000000FFFF0000FFFF0000FF
      FF00008484000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFF0000FF0000008400000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000FF000000FF000000FFFF0000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008484
      8400C6C6C60000FFFF0000FFFF00000000000000000000FFFF0000FFFF00C6C6
      C600848484000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFF0000FF0000008400000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FF00
      0000000000000000000000000000000000000000000000000000FF000000FF00
      0000FF000000FFFF000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000084840000FFFF0000FFFF00000000000000000000FFFF0000FFFF000084
      8400000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FFFF0000FF00000084000000000000000000
      0000000000000000000000000000000000000000000000000000FF0000000000
      0000000000000000000000000000000000000000000000000000FF000000FF00
      0000FFFF00000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000084848400C6C6C60000FFFF00000000000000000000FFFF00C6C6C6008484
      8400000000000000000000000000000000000000000000000000000000000000
      0000000000008400000084000000C6C6C600FFFF0000FF000000840000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000FF000000FFFF
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000084840000FFFF0000FFFF0000FFFF0000FFFF00008484000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFF0000FF00000084000000C6C6C600FFFF0000FF000000840000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000008484008484840000FFFF0000FFFF0084848400008484000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFF0000FF0000008400000084000000FF000000FF000000840000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000848400008484000084840000848400000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FFFF0000FF000000FF000000FF00000084000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFF0000FFFF0000FFFF000000000000000000000000
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
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000000000
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000C6C6C6008484
      0000008400008484000000840000848400000084000084840000FF000000FF00
      00000000000000000000000000000000000000000000FF000000C6C6C6008484
      0000008400008484000000840000848400000084000084840000FF000000FF00
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000C6C6C6000084
      00008484000000FFFF0000FFFF0000FFFF008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      00008484000000840000848400000084000000FFFF0000840000FF0000008484
      8400FF0000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000C6C6C6008484
      000000FFFF0084840000008400008484000000FFFF0084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      00000084000084840000008400008484000000FFFF0084840000FF0000008484
      8400FF0000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008400000000
      0000000000000000000000840000000000000000000000000000000000000000
      00000000000000840000000000000000000000000000FF000000C6C6C6000084
      000000FFFF0000840000848400000084000000FFFF0000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      00008484000000840000848400000084000000FFFF0000840000FF0000008484
      8400FF0000000000000000000000000000000000000000000000000000000000
      00000000FF000000FF000000FF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000084
      0000000000000084000000840000008400000084000000000000000000000000
      00000084000000000000000000000000000000000000FF000000C6C6C6008484
      000000FFFF0084840000008400008484000000FFFF0084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      00000084000000FFFF0000FFFF008484000000FFFF0084840000FF0000008484
      8400FF00000000000000000000000000000000000000000000000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000FF0000008400000084000000840000000000000000
      00000000000000000000000000000000000000000000FF000000C6C6C6008484
      00008484000000FFFF0000FFFF0000FFFF008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      000000FFFF00008400008484000000FFFF0000FFFF0000840000FF0000008484
      8400FF000000000000000000000000000000000000000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000084000000FF0000848400000084000000840000000000000000
      00000000000000000000000000000000000000000000FF000000C6C6C6008484
      000000FFFF0084840000008400008484000000FFFF0084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      000000FFFF0084840000008400008484000000FFFF0084840000FF0000008484
      8400FF000000000000000000000000000000000000000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF00000000000000
      0000000000000000000000000000000000000000000000000000008400000084
      0000000000000084000000FF000000FF00000084000000840000000000000000
      00000084000000840000000000000000000000000000FF000000C6C6C6000084
      000000FFFF0000840000848400000084000000FFFF0000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      000000FFFF0000840000848400000084000000FFFF0000840000FF0000008484
      8400FF0000000000000000000000000000000000FF000000FF00000000000000
      000000000000000000000000000000000000000000000000FF000000FF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000084000000FF000000FF00000084000000840000000000000000
      00000000000000000000000000000000000000000000FF000000C6C6C6008484
      00000084000000FFFF0000FFFF0000FFFF000084000084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      00000084000000FFFF0000FFFF0000FFFF000084000084840000FF0000008484
      8400FF0000000000000000000000000000000000FF000000FF00000000000000
      000000000000000000000000000000000000000000000000FF000000FF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000084000000FF000000FF00000084000000840000000000000000
      00000000000000000000000000000000000000000000FF000000C6C6C6000084
      0000848400000084000084840000008400008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      0000848400000084000084840000008400008484000000840000FF0000008484
      8400FF0000000000000000000000000000000000FF000000FF00000000000000
      000000000000000000000000000000000000000000000000FF000000FF000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000084000000FF000000FF000000000000000000000000
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000008484
      8400FF000000000000000000000000000000000000000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000840000C6C6C60000840000008400000000000000000000C6C6C6000084
      0000000000000000000000000000000000000000000000000000FF000000C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6008484
      8400FF0000000000000000000000000000000000000000000000FF000000C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6008484
      8400FF000000000000000000000000000000000000000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF00000000000000
      0000000000000000000000000000000000000000000000000000000000000084
      0000000000000000FF00000084000084000000000000000084000000FF000000
      000000840000000000000000000000000000000000000000000000000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      000000000000000000000000000000000000000000000000000000000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      00000000000000000000000000000000000000000000000000000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000840000FF00000084000000008400000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000FF000000FF000000FF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000008400000084000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000000000
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000000000
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000000000
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000000000
      00000000000000000000000000000000000000000000FF000000C6C6C6008484
      0000008400008484000000840000848400000084000084840000FF000000FF00
      00000000000000000000000000000000000000000000FF000000C6C6C6008484
      0000008400008484000000840000848400000084000084840000FF000000FF00
      00000000000000000000000000000000000000000000FF000000C6C6C6008484
      0000008400008484000000840000848400000084000084840000FF000000FF00
      00000000000000000000000000000000000000000000FF000000C6C6C6008484
      0000008400008484000000840000848400000084000084840000FF000000FF00
      00000000000000000000000000000000000000000000FF000000C6C6C6000084
      000084840000008400008484000000FFFF008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      00008484000000FFFF0000FFFF0000FFFF008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      00008484000000FFFF0000FFFF0000FFFF008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      0000848400000084000000FFFF00008400008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      000000840000848400000084000000FFFF000084000084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      000000FFFF0084840000008400008484000000FFFF0084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      000000FFFF0084840000008400008484000000FFFF0084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      0000008400008484000000FFFF00848400000084000084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      000084840000008400008484000000FFFF008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      00008484000000840000848400000084000000FFFF0000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      000000FFFF0000840000848400000084000000FFFF0000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      0000848400000084000000FFFF00008400008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      000000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      00000084000084840000008400008484000000FFFF0084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      000000FFFF0084840000008400008484000000FFFF0084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      000000840000848400000084000000FFFF000084000084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      000000FFFF00008400008484000000FFFF008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      000000FFFF0000FFFF0000FFFF0000FFFF008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      000000FFFF0000FFFF0000FFFF0000FFFF008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      000084840000008400008484000000FFFF008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      000000FFFF00848400000084000000FFFF000084000084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      000000FFFF008484000000840000848400000084000084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      000000FFFF008484000000840000848400000084000084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      00000084000084840000008400008484000000FFFF0084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      000000FFFF00008400008484000000FFFF008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      000000FFFF000084000084840000008400008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      000000FFFF0000840000848400000084000000FFFF0000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      000000FFFF0000840000848400000084000000FFFF0000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      000000FFFF00848400000084000000FFFF000084000084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      000000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      00000084000000FFFF0000FFFF0000FFFF000084000084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      000000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      0000848400000084000084840000008400008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      0000848400000084000084840000008400008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      0000848400000084000084840000008400008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      0000848400000084000084840000008400008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000008484
      8400FF0000000000000000000000000000000000000000000000FF000000C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6008484
      8400FF0000000000000000000000000000000000000000000000FF000000C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6008484
      8400FF0000000000000000000000000000000000000000000000FF000000C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6008484
      8400FF0000000000000000000000000000000000000000000000FF000000C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6008484
      8400FF000000000000000000000000000000000000000000000000000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      000000000000000000000000000000000000000000000000000000000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      000000000000000000000000000000000000000000000000000000000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      000000000000000000000000000000000000000000000000000000000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
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
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000000000
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000000000
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000000000
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000000000
      00000000000000000000000000000000000000000000FF000000C6C6C6008484
      0000008400008484000000840000848400000084000084840000FF000000FF00
      00000000000000000000000000000000000000000000FF000000C6C6C6008484
      0000008400008484000000840000848400000084000084840000FF000000FF00
      00000000000000000000000000000000000000000000FF000000C6C6C6008484
      0000008400008484000000840000848400000084000084840000FF000000FF00
      00000000000000000000000000000000000000000000FF000000C6C6C6008484
      0000008400008484000000840000848400000084000084840000FF000000FF00
      00000000000000000000000000000000000000000000FF000000C6C6C6000084
      00008484000000FFFF0000FFFF0000FFFF008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      000000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      000000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      00008484000000FFFF0000FFFF0000FFFF008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      000000FFFF0084840000008400008484000000FFFF0084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      0000008400008484000000FFFF00848400000084000084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      000000FFFF008484000000840000848400000084000084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      000000FFFF0084840000008400008484000000FFFF0084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      000000FFFF0000840000848400000084000000FFFF0000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      0000848400000084000000FFFF00008400008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      00008484000000FFFF0084840000008400008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      00008484000000840000848400000084000000FFFF0000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      000000FFFF0084840000008400008484000000FFFF0084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      0000008400008484000000FFFF00848400000084000084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      0000008400008484000000FFFF00848400000084000084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      00000084000084840000008400008484000000FFFF0084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      000000FFFF0000840000848400000084000000FFFF0000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      0000848400000084000000FFFF00008400008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      000084840000008400008484000000FFFF008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      0000848400000084000000FFFF0000FFFF008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      000000FFFF0084840000008400008484000000FFFF0084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      000000FFFF008484000000FFFF00848400000084000084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      00000084000084840000008400008484000000FFFF0084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      00000084000084840000008400008484000000FFFF0084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      000000FFFF0000840000848400000084000000FFFF0000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      00008484000000FFFF0000FFFF00008400008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      000000FFFF0000840000848400000084000000FFFF0000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      000000FFFF0000840000848400000084000000FFFF0000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      00000084000000FFFF0000FFFF0000FFFF000084000084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      0000008400008484000000FFFF00848400000084000084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      00000084000000FFFF0000FFFF0000FFFF000084000084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6008484
      00000084000000FFFF0000FFFF0000FFFF000084000084840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      0000848400000084000084840000008400008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      0000848400000084000084840000008400008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      0000848400000084000084840000008400008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000C6C6C6000084
      0000848400000084000084840000008400008484000000840000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000008484
      8400FF00000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000008484
      8400FF0000000000000000000000000000000000000000000000FF000000C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6008484
      8400FF0000000000000000000000000000000000000000000000FF000000C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6008484
      8400FF0000000000000000000000000000000000000000000000FF000000C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6008484
      8400FF0000000000000000000000000000000000000000000000FF000000C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6008484
      8400FF000000000000000000000000000000000000000000000000000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      000000000000000000000000000000000000000000000000000000000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      000000000000000000000000000000000000000000000000000000000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      000000000000000000000000000000000000000000000000000000000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000500000000100010000000000800200000000000000000000
      000000000000000000000000FFFFFF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FFFFFFFFFFFF0000FFFFFFFFFFFF0000
      FFFFFFFFFFFF0000E007FFFFFFFF0000C003FE7FFFFF0000C003FC7FFF8F0000
      C003FFFFDFC70000C003FC7FEFC30000E007FC7FF0010000E007FC7FEFC30000
      F00FFE3FDFC70000F00FF81FFF8F0000F81FF01FFFFF0000F81FF01FFFFF0000
      FC3FF83FFFFF0000FFFFFC7FFFFF0000FFFFFFFFFFFFFFFF801F801FFFFFFFFF
      800F800FFFFFFFFF80078007FFFFFFFF80078007FFFFCC7380078007F1FFE027
      80078007C07FF00F80078007803FF81F80078007803FC81380078007001FE007
      80078007001FF83F80078007001FF00F80078007803FE007C007C007803FE817
      E00FE00FC07FFC3FFFFFFFFFF1FFFA5FFFFFFFFFFFFFFFFF801F801F801F801F
      800F800F800F800F800780078007800780078007800780078007800780078007
      8007800780078007800780078007800780078007800780078007800780078007
      800780078007800780078007800780078007800780078007C007C007C007C007
      E00FE00FE00FE00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF801F801F801F801F
      800F800F800F800F800780078007800780078007800780078007800780078007
      8007800780078007800780078007800780078007800780078007800780078007
      800780078007800780078007800780078007800780078007C007C007C007C007
      E00FE00FE00FE00FFFFFFFFFFFFFFFFF00000000000000000000000000000000
      000000000000}
  end
  object imFunction: TImageList
    Left = 104
    Top = 208
    Bitmap = {
      494C010118001D00040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000008000000001002000000000000080
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
      0000000000000000000000000000000000000000000000000000000000000080
      8000008080008080800080808000808080008080800080808000808080008080
      8000808080008080800080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008080000000
      00000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008000000080000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000080000000800000008000000080000000800000008000
      0000800000008000000080000000800000000000000000808000000000000000
      00000000000000000000FFFFFF00000000000000000000000000000000000000
      0000000000000000000080808000000000000000000000000000000000000000
      0000000000000000000000000000800000008000000080000000800000008000
      0000800000008000000080000000800000000000000000000000000000000000
      0000800000000000000000000000800000000000000000000000800000008000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000080000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00800000000000000000808000000000000000
      000000FFFF0000000000FFFFFF00000000000000000000000000000000000000
      0000000000000000000080808000000000000000000000000000000000000000
      000000000000000000000000000080000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00800000000000000000000000000000000000
      0000800000000000000000000000800000000000000080000000000000000000
      0000800000000000000000000000000000000000000080808000008080008080
      8000008080008080800080000000FFFFFF000000000000000000000000000000
      00000000000000000000FFFFFF00800000000000000000808000000000000000
      00000000000000000000FFFFFF00000000000000000000000000000000000000
      0000000000000000000080808000000000000000000000000000000000000000
      000000000000000000000000000080000000FFFFFF0000000000000000000000
      00000000000000000000FFFFFF00800000000000000000000000000000000000
      0000800000000000000000000000800000000000000080000000000000000000
      0000800000000000000000000000000000000000000000808000808080000080
      8000808080000080800080000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00800000000000000000808000000000000000
      00000000000000000000FFFFFF00FFFFFF00FFFFFF0000000000000000000000
      000000000000FFFFFF0080808000000000000000000000000000000000000000
      000000000000000000000000000080000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00800000000000000000000000000000000000
      0000000000008000000080000000800000000000000080000000000000000000
      0000800000000000000000000000000000000000000080808000008080008080
      8000008080008080800080000000FFFFFF00000000000000000000000000FFFF
      FF0080000000800000008000000080000000000000000080800000000000FFFF
      FF000000000000000000FFFFFF00FFFFFF000000000000000000000000000000
      000000000000FFFFFF0080808000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0080000000FFFFFF0000000000000000000000
      00000000000000000000FFFFFF00800000000000000000000000000000000000
      0000000000000000000000000000800000000000000080000000800000008000
      0000000000000000000000000000000000000000000000808000808080000080
      8000808080000080800080000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0080000000FFFFFF008000000000000000000000000080800000000000FFFF
      FF00FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000080808000000000000000000000000000FFFFFF000000
      000000000000000000000000000080000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00800000000000000000000000000000000000
      0000000000000000000000000000800000000000000080000000000000000000
      0000000000000000000000000000000000000000000080808000008080008080
      8000008080008080800080000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00800000008000000000000000000000000000000000808000FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000008080800080808000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0080000000FFFFFF000000000000000000FFFF
      FF00800000008000000080000000800000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000808000808080000080
      8000808080000080800080000000800000008000000080000000800000008000
      0000800000000000000000000000000000000000000000808000FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000808080008080800000000000000000000000000000000000FFFFFF000000
      000000000000000000000000000080000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0080000000FFFFFF0080000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080808000008080008080
      8000008080008080800000808000808080000080800080808000008080008080
      8000008080000000000000000000000000000000000000808000FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000808080000080800000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0080000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00800000008000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000808000808080000000
      0000000000000000000000000000000000000000000000000000000000008080
      8000808080000000000000000000000000000000000000808000FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000080800000000000000000000000000000000000FFFFFF000000
      000000000000FFFFFF0000000000800000008000000080000000800000008000
      0000800000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080808000808080000000
      0000000000000000000000000000000000000000000000000000000000008080
      8000008080000000000000000000000000000000000000808000FFFFFF00FFFF
      FF0000000000000000000000000000000000000000000000000000000000FFFF
      FF00000000000080800000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000808000808080000080
      80000000000000FFFF00000000000000000000FFFF0000000000808080000080
      8000808080000000000000000000000000000000000000808000FFFFFF000000
      000080808000000000000000000000000000000000000000000080808000FFFF
      FF000000000000808000000000000000FF000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000FFFF0000FFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008080000000
      00008080800000000000FFFFFF00FFFFFF00FFFFFF0000000000808080000000
      000000808000000000000000FF000000FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000080
      8000008080008080800080808000808080008080800080808000008080000080
      8000000000000000FF000000FF000000FF000000000000000000000000000000
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
      000000000000C080600080404000804040008040400080404000804040008040
      4000804040008040400080404000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C0806000FFFFFF00F0FBFF00F0FBFF00F0FBFF00F0FBFF00F0CA
      A600F0FBFF00F0CAA60080404000000000000000000000000000000000000000
      000000000000BFBFBF00BFBFBF007F7F7F007F7F7F007F7F7F00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000BFBFBF00BFBFBF007F7F7F007F7F7F007F7F7F00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C0806000F0FBFF00F0CAA600F0CAA600F0CAA600F0CAA600F0CA
      A600F0CAA600F0CAA6008040400000000000000000000000000000000000BFBF
      BF00BFBFBF007F7F7F000000000000000000000000007F7F7F007F7F7F007F7F
      7F0000000000000000000000000000000000000000000000000000000000BFBF
      BF00BFBFBF007F7F7F000000000000000000000000007F7F7F007F7F7F007F7F
      7F00000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C0806000F0FBFF00F0CAA600F0CAA600F0CAA600F0CAA600F0CA
      A600F0CAA600F0CAA60080404000000000000000000000000000BFBFBF00BFBF
      BF0000000000FFFFFF000000FF00FFFFFF000000FF00FFFFFF00000000007F7F
      7F007F7F7F000000000000000000000000000000000000000000BFBFBF00BFBF
      BF0000000000FFFFFF0000FF0000FFFFFF0000FF0000FFFFFF00000000007F7F
      7F007F7F7F000000000000000000000000000000000000000000000000000000
      000000000000000000000000FF000000FF000000FF0000000000000000000000
      00000000000000000000000000000000000000000000C0806000804040008040
      400080404000C0806000FFFFFF00F0CAA600F0CAA600F0CAA600F0CAA600F0CA
      A600F0CAA600F0CAA60080604000000000000000000000000000BFBFBF000000
      0000FFFFFF000000000000000000000000000000000000000000FFFFFF000000
      00007F7F7F000000000000000000000000000000000000000000BFBFBF000000
      0000FFFFFF000000000000000000000000000000000000000000FFFFFF000000
      00007F7F7F000000000000000000000000000000000000000000000000000000
      000000000000000000000000FF000000FF000000FF0000000000000000000000
      00000000000000000000000000000000000000000000C0806000FFFFFF00F0FB
      FF00F0FBFF00C0806000FFFFFF00F0CAA600F0CAA600F0CAA600F0CAA600F0CA
      A600F0CAA600F0CAA600806040000000000000000000BFBFBF007F7F7F00FFFF
      FF0000000000000000000000FF0000008000000080000000000000000000FFFF
      FF007F7F7F007F7F7F00000000000000000000000000BFBFBF007F7F7F00FFFF
      FF00000000000000000000FF000000800000008000000000000000000000FFFF
      FF007F7F7F007F7F7F0000000000000000000000000000000000000000000000
      0000000000000000FF000000FF000000FF000000FF000000FF00000000000000
      00000000000000000000000000000000000000000000C0806000F0FBFF00F0CA
      A600F0CAA600C0806000FFFFFF00F0CAA600F0CAA600F0CAA600F0CAA600F0CA
      A600F0CAA600F0CAA600806060000000000000000000BFBFBF00000000000000
      FF00000000000000FF00000080000000FF000000800000008000000000000000
      FF00000000007F7F7F00000000000000000000000000BFBFBF000000000000FF
      00000000000000FF00000080000000FF000000800000008000000000000000FF
      0000000000007F7F7F0000000000000000000000000000000000000000000000
      0000000000000000FF000000FF000000FF000000FF000000FF00000000000000
      00000000000000000000000000000000000000000000C0806000F0FBFF00F0CA
      A600F0CAA600C0806000FFFFFF00F0CAA600F0CAA600F0CAA600F0CAA600F0CA
      A600FFFFFF0000000000806060000000000000000000FFFFFF0000000000FFFF
      FF00000000000000FF000000FF000000FF000000FF000000800000000000FFFF
      FF00000000007F7F7F00000000000000000000000000FFFFFF0000000000FFFF
      FF000000000000FF000000FF000000FF000000FF00000080000000000000FFFF
      FF00000000007F7F7F0000000000000000000000000000000000000000000000
      00000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      00000000000000000000000000000000000000000000C0806000FFFFFF00F0CA
      A600F0CAA600C0806000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000C0C0A000A4A0A000806060000000000000000000FFFFFF00000000000000
      FF0000000000FFFFFF000000FF000000FF00000080000000FF00000000000000
      FF0000000000BFBFBF00000000000000000000000000FFFFFF000000000000FF
      000000000000FFFFFF0000FF000000FF00000080000000FF00000000000000FF
      000000000000BFBFBF0000000000000000000000000000000000000000000000
      00000000000000000000000000000000FF000000000000000000000000000000
      00000000000000000000000000000000000000000000C0806000FFFFFF00F0CA
      A600F0CAA600C0806000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C080
      6000C0806000C0806000C08060000000000000000000FFFFFF007F7F7F00FFFF
      FF000000000000000000FFFFFF00FFFFFF000000FF000000000000000000FFFF
      FF007F7F7F00BFBFBF00000000000000000000000000FFFFFF007F7F7F00FFFF
      FF000000000000000000FFFFFF00FFFFFF0000FF00000000000000000000FFFF
      FF007F7F7F00BFBFBF0000000000000000000000000000000000000000000000
      00000000000000000000000000000000FF000000000000000000000000000000
      00000000000000000000000000000000000000000000C0806000FFFFFF00F0CA
      A600F0CAA600C0806000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C080
      6000C0A06000C080600000000000000000000000000000000000BFBFBF000000
      0000FFFFFF000000000000000000000000000000000000000000FFFFFF000000
      0000BFBFBF000000000000000000000000000000000000000000BFBFBF000000
      0000FFFFFF000000000000000000000000000000000000000000FFFFFF000000
      0000BFBFBF000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FF000000000000000000000000000000
      00000000000000000000000000000000000000000000C0806000FFFFFF00F0CA
      A600F0CAA600C0806000C0806000C0806000C0806000C0806000C0806000C080
      6000C06060000000000000000000000000000000000000000000FFFFFF00BFBF
      BF0000000000FFFFFF000000FF00FFFFFF000000FF00FFFFFF0000000000BFBF
      BF00BFBFBF000000000000000000000000000000000000000000FFFFFF00BFBF
      BF0000000000FFFFFF0000FF0000FFFFFF0000FF0000FFFFFF0000000000BFBF
      BF00BFBFBF000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FF000000000000000000000000000000
      00000000000000000000000000000000000000000000C0806000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0000000000C0C0A000A4A0A000806060000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00BFBFBF007F7F7F000000000000000000000000007F7F7F00BFBFBF00BFBF
      BF0000000000000000000000000000000000000000000000000000000000FFFF
      FF00BFBFBF007F7F7F000000000000000000000000007F7F7F00BFBFBF00BFBF
      BF00000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FF000000000000000000000000000000
      00000000000000000000000000000000000000000000C0806000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00C0806000C0806000C0806000C08060000000
      00000000000000000000000000000000FF000000000000000000000000000000
      000000000000FFFFFF00FFFFFF00FFFFFF00BFBFBF00BFBFBF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FFFFFF00FFFFFF00FFFFFF00BFBFBF00BFBFBF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FF000000000000000000000000000000
      00000000000000000000000000000000000000000000C0806000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00C0806000C0A06000C0806000000000000000
      000000000000000000000000FF000000FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000C0806000C0806000C080
      6000C0806000C0806000C0806000C0806000C060600000000000000000000000
      0000000000000000FF000000FF000000FF000000000000000000000000000000
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
      0000000000000000000000000000000000000000000000000000000000008484
      0000840000000000000000000000000000000000000000000000000000008400
      0000840000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000000000FF
      FF00848400008400000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000FF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008400
      000000FFFF008484000084000000000000000000000000000000000000008400
      0000840000000000000000000000000000000000000000000000000000000000
      000000000000000000000000FF000000FF000000FF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000840000008400
      00008400000000FFFF0084840000840000000000000000000000000000008400
      0000840000000000000000000000000000000000000000000000000000000000
      00000000FF000000FF000000FF000000FF000000FF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FF000000FF000000FF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000008400000000FF
      FF0000FFFF0000FFFF0000FFFF00848400000000000000000000000000000000
      00008400000000000000000000000000000000000000000000000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF00000000000000000000000000000000000000
      00000000000000000000000000000000FF000000FF000000FF000000FF000000
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000000000FF
      FF00848400008400000084000000840000000000000084000000840000000000
      0000000000008400000000000000000000000000000000000000000000000000
      00000000FF000000FF000000FF000000FF000000FF0000000000000000000000
      000000000000000000000000000000000000000000000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000FF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000000000FF
      FF0000FFFF008484000084000000000000000000000084000000840000008400
      0000840000008400000000000000000000000000000000000000000000000000
      000000000000000000000000FF000000FF000000FF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FF000000FF000000FF000000FF000000
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000084000000840000008400
      000000FFFF0000FFFF0084840000840000000000000000000000840000008400
      0000840000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000FF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FF000000FF000000FF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000008400000000FFFF0000FF
      FF0000FFFF0000FFFF0000FFFF00848400000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000008400000000FF
      FF0000FFFF0000FFFF0000FFFF0000FFFF008400000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000840000008400
      0000840000008400000084000000840000008400000084000000840000000000
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
      0000000000000000FF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000008484840000000000FFFF000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000FF000000FF000000FF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000FFFF0000FFFF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000084848400FFFF0000000000000000000084848400000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000FF000000FF000000FF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000FFFF0000FFFF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008484840000000000000000000000000000000000FFFF00008484
      8400000000000000000000000000000000000000000000000000000000000000
      FF000000FF000000FF000000FF000000FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000084848400FFFF0000000000000000000084848400000000000000
      00000000000000000000000000000000000000000000000000000000FF000000
      FF000000FF000000FF000000FF000000FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000848484008400
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000FFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FFFF000000000000FFFF0000848484000000
      000000000000000000000000000000000000000000007B7B7B000000FF000000
      FF0000000000000000000000FF000000FF000000FF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008400
      0000840000008400000084000000000000000000000000000000000000008400
      0000848484000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000FFFF000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      000000000000848484000000000000000000FFFF000000000000000000000000
      0000000000000000000000000000000000007B7B7B000000FF00000000000000
      00000000000000000000000000000000FF000000FF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008400
      0000840000000000000000000000000000000000000000000000000000000000
      0000840000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000FFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000084848400FFFF00000000
      0000FFFF00000000000000000000848484008484840084848400000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FF000000FF000000FF00000000000000
      0000000000000000000000000000000000000000000000000000000000008400
      0000000000008400000000000000000000000000000000000000000000000000
      0000840000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000FFFF0000FFFF0000000000000000000000
      0000000000000000000000000000000000008484840084848400000000000000
      000084848400FFFF000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000FF000000FF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000084000000840000000000000000000000000000008400
      0000848484000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF000000000000FFFF0000FFFF00000000000000
      00000000000000000000000000000000000084848400FFFF0000000000000000
      0000000000000000000084848400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000FF000000FF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008400000084000000840000008484
      8400000000000000000000000000000000000000000000000000000000000000
      000000FFFF000000000000000000FFFFFF000000000000FFFF0000FFFF000000
      0000000000000000000000000000000000000000000084848400FFFF00000000
      0000FFFF00000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000007B7B7B000000
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000FFFF000000000000000000FFFFFF00FFFFFF000000000000FFFF000000
      000000000000000000000000000000000000000000008484840000000000FFFF
      0000000000008484840000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000007B7B
      7B000000FF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000FFFF0000FFFF0000000000000000000000000000FFFF0000FFFF000000
      0000000000000000000000000000000000000000000000000000848484008484
      8400848484008484840000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000FF000000FF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FFFF0000FFFF0000FFFF0000FFFF0000FFFF00000000000000
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
      000000000000A5736B0073424200734242007342420073424200734242007342
      420073424200734242007342420000000000000000000000000000000000188C
      CE00188CCE008C5A5A008C5A5A008C5A5A008C5A5A008C5A5A008C5A5A008C5A
      5A008C5A5A008C5A5A008C5A5A00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF00000000000000000000000000000000000000
      000000000000A5736B00FFFFE700F7EFDE00F7EFD600F7EFD600F7EFD600F7E7
      CE00F7EFD600EFDEC60073424200000000000000000000000000188CCE0073C6
      EF0063C6EF00BDB5AD00FFE7D600FFEFDE00F7EFD600F7EFD600F7EFD600F7E7
      D600F7E7CE00F7E7CE008C5A5A00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF00000000000000000000000000000000000000
      000000000000A5736B00F7EFDE00F7DEBD00F7D6BD00F7D6BD00EFD6B500EFD6
      B500EFDEBD00E7D6BD00734242000000000000000000188CCE008CE7F7007BEF
      FF0073EFFF00BDB5AD00F7DECE00F7DEC600F7D6B500F7D6B500F7D6B500F7D6
      AD00EFD6B500EFDEC6008C5A5A000000000000000000FFFFFF00000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000A5736B00FFEFDE00FFC69400FFC69400FFC69400FFC69400FFC6
      9400FFC69400E7D6BD00734242000000000000000000188CCE008CE7F7007BE7
      FF006BE7FF00BDB5AD00F7E7D600F7DEC600F7D6AD00F7D6AD00F7D6AD00F7CE
      A500F7D6B500EFDEC6008C5A5A000000000000000000FFFFFF00000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000A5736B00734242007342
      420073424200A5736B00FFF7E700F7DEBD00F7D6B500F7D6B500F7D6B500F7D6
      AD00F7DEC600E7D6C60084524A000000000000000000188CCE0094E7F7008CEF
      FF007BEFFF00BDB5AD00F7E7DE00F7DEC600F7D6B500F7D6B500F7D6B500F7D6
      AD00F7D6B500EFDECE008C5A5A00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF000000000000000000000000000000000000000000A5736B00FFFFE700F7EF
      DE00F7EFD600A5736B00FFF7EF00FFDEBD00FFDEBD00FFDEB500F7D6B500F7D6
      B500F7DEC600E7D6C60084524A000000000000000000188CCE00A5E7F7009CEF
      FF008CEFFF00BDB5AD00FFEFE700FFE7D600FFDEC600F7DEC600F7DEBD00F7DE
      BD00F7DEC600EFE7D6008C5A5A00000000000000000000000000FFFFFF000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000A5736B00F7EFDE00F7DE
      BD00F7D6BD00A5736B00FFFFF700FFC69400FFC69400FFC69400FFC69400FFC6
      9400FFC69400EFDECE008C5A5A000000000000000000188CCE00ADE7F700ADF7
      FF009CF7FF00BDB5AD00FFF7EF00FFE7C600FFD6AD00FFD6AD00FFD6AD00FFCE
      A500F7DEBD00F7EFDE008C5A5A00000000000000000000000000FFFFFF000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      00000000000000000000000000000000000000000000A5736B00FFEFDE00FFC6
      9400FFC69400A5736B00FFFFFF00FFE7CE00FFE7C600FFDEC600FFDEC600FFE7
      C600FFF7DE00E7D6CE008C5A5A000000000000000000188CCE00B5EFF700BDF7
      FF00ADF7FF00BDB5AD00FFF7F700FFF7EF00FFEFDE00FFEFDE00FFE7D600FFEF
      DE00F7EFDE00E7DED6008C5A5A00000000000000000000000000FFFFFF000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      00000000000000000000000000000000000000000000A5736B00FFF7E700F7DE
      BD00F7D6B500A5736B00FFFFFF00FFFFFF00FFFFFF00FFFFF700FFFFF700E7D6
      D600C6B5AD00A59494009C635A000000000000000000188CCE00C6EFF700D6FF
      FF00BDF7FF00BDB5AD00FFF7F700FFFFFF00FFFFFF00FFFFF700FFFFF700EFE7
      DE00C6ADA500B59C8C008C5A5A00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      00000000000000000000000000000000000000000000A5736B00FFF7EF00FFDE
      BD00FFDEBD00A5736B00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00A573
      6B00A5736B00A5736B00A5736B000000000000000000188CCE00C6EFF700E7FF
      FF00D6FFFF00BDB5AD00FFFFF700FFFFFF00FFFFFF00FFFFFF00FFFFFF00D6BD
      B500D6945200F77B42000000000000000000000000000000000000000000FFFF
      FF000000000000000000000000000000000000000000FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000A5736B00FFFFF700FFC6
      9400FFC69400A5736B00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00A573
      6B00E7A55200B5735A00000000000000000000000000188CCE00CEEFF700F7FF
      FF00E7FFFF00BDB5AD00FFEFE700FFF7EF00FFF7EF00FFEFEF00FFF7EF00DEB5
      A500B59C6B00188CCE0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF000000000000000000000000000000000000000000FFFFFF00000000000000
      00000000000000000000000000000000000000000000A5736B00FFFFFF00FFE7
      CE00FFE7C600A5736B00A5736B00A5736B00A5736B00A5736B00A5736B00A573
      6B00AD6B6B0000000000000000000000000000000000188CCE00D6EFF700FFFF
      FF00F7FFFF00BDB5AD00BDB5AD00BDB5AD00BDB5AD00BDB5AD00BDB5AD00BDB5
      AD006BB5CE00188CCE0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000A5736B00FFFFFF00FFFF
      FF00FFFFFF00FFFFF700FFFFF700E7D6D600C6B5AD00A59494009C635A000000
      00000000000000000000000000000000000000000000188CCE00D6EFF700F7F7
      F7009CB5BD0094B5BD0094B5BD0094B5BD008CB5BD008CB5BD009CC6CE00D6FF
      FF006BCEF700188CCE0000000000000000000000000000000000000000000000
      0000FFFFFF000000000000000000000000000000000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000A5736B00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00A5736B00A5736B00A5736B00A5736B000000
      00000000000000000000000000000000000000000000188CCE00DEF7FF00D6BD
      B500AD8C8400C6B5AD00C6B5AD00C6B5AD00C6B5AD00C6ADA500A5847B00DEE7
      DE007BD6F700188CCE0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF000000000000000000000000000000000000000000FFFFFF000000
      00000000000000000000000000000000000000000000A5736B00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00A5736B00E7A55200B5735A00000000000000
      0000000000000000000000000000000000000000000000000000188CCE00A5C6
      DE007B848C00DECEC600FFF7F700F7F7F700F7F7F700C6B5AD006B848C0073C6
      E700188CCE000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000A5736B00A5736B00A573
      6B00A5736B00A5736B00A5736B00A5736B00AD6B6B0000000000000000000000
      000000000000000000000000000000000000000000000000000000000000188C
      CE00188CCE008C7B6B008C7B6B008C7B6B008C7B6B008C7B6B00188CCE00188C
      CE00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000084848400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000848484000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000084848400FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000084
      8400008484000084840000848400008484000084840000848400008484000084
      8400000000000000000000000000000000000000000000000000008484000084
      8400000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00000000000084840000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008484840000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000084848400FFFFFF00FFFFFF00840000008400000084000000840000008400
      0000FFFFFF00FFFFFF0000000000000000000000000000000000FFFFFF000000
      0000008484000084840000848400008484000084840000848400008484000084
      8400008484000000000000000000000000000000000000000000008484000084
      8400000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00000000000084840000000000000000000000000000000000000000000000
      000000000000000000000000000000FFFF000000000084848400000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000084848400FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000000000000000000000000000000000FFFF00FFFF
      FF00000000000084840000848400008484000084840000848400008484000084
      8400008484000084840000000000000000000000000000000000008484000084
      8400000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00000000000084840000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000FFFF0000000000848484000000
      0000000000000000000000000000000000000000000000000000000000000000
      000084848400FFFFFF00FFFFFF00840000008400000084000000840000008400
      0000FFFFFF00FFFFFF0000000000000000000000000000000000FFFFFF0000FF
      FF00FFFFFF000000000000848400008484000084840000848400008484000084
      8400008484000084840000848400000000000000000000000000008484000084
      8400000000000000000000000000000000000000000000000000000000000000
      0000000000000084840000000000000000000000000000000000000000000000
      00000000000000FFFF0000FFFF00FFFFFF0000FFFF0000FFFF00000000008484
      8400000000000000000000000000000000000000000000000000000000000000
      000084848400FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000000000000000000000000000000000FFFF00FFFF
      FF0000FFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008484000084
      8400008484000084840000848400008484000084840000848400008484000084
      8400008484000084840000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF0000FFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000084848400FFFFFF00FFFFFF00840000008400000084000000840000008400
      0000FFFFFF00FFFFFF0000000000000000000000000000000000FFFFFF0000FF
      FF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000008484000084
      8400000000000000000000000000000000000000000000000000000000000000
      0000008484000084840000000000000000000000000000000000000000000000
      0000000000000000000000FFFF00FFFFFF0000FFFF0000000000848484000000
      0000000000000000000000000000000000000000000000000000000000000000
      000084848400FFFFFF0000FFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000000000000000000000000000000000FFFF00FFFF
      FF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF000000
      0000000000000000000000000000000000000000000000000000008484000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000084840000000000000000000000000000000000000000000000
      000000000000000000000000000000FFFF00FFFFFF0000FFFF00000000008484
      8400000000000000000000000000000000000000000000FFFF00000000000000
      000084848400FFFFFF0000FFFF00840000008400000084000000840000008400
      0000FFFFFF00FFFFFF0000000000000000000000000000000000FFFFFF0000FF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008484000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0000000000008484000000000000000000000000000000000000000000FFFF
      FF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF000000
      0000848484000000000000000000000000000000000084848400000000000000
      00008484840000FFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008484000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000084840000000000000000000000000000000000000000000000
      0000FFFFFF0000FFFF00FFFFFF0000FFFF000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000000000FF
      FF0084848400FFFFFF00FFFFFF00840000008400000084000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008484000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000084840000000000000000000000000000000000000000000000
      000000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF0000000000848484000000
      0000000000000000000000000000000000000000000084848400848484008484
      8400FFFFFF0000FFFF0000FFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008484
      8400FFFFFF008484840000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008484000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      00000000000000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00000000008484
      8400000000000000000000000000000000000000000000FFFF00FFFFFF008484
      840000FFFF00FFFFFF008484840000FFFF00FFFFFF00FFFFFF00FFFFFF008484
      8400848484000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008484000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0000000000FFFFFF0000000000000000000000000000000000000000000000
      000000000000FFFFFF00FFFFFF00FFFFFF0000FFFF00FFFFFF00FFFFFF000000
      00008484840000000000000000000000000000000000000000008484840000FF
      FF008484840000FFFF00000000008484840000FFFF0084848400848484008484
      8400000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF0000FFFF00FFFFFF00FFFFFF0000FFFF00FFFF
      FF0000000000848484000000000000000000000000008484840000FFFF00FFFF
      FF00848484000000000000000000000000008484840000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000FFFF00FFFFFF00FFFF
      FF008484840000FFFF0000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000800000000100010000000000000400000000000000000000
      000000000000000000000000FFFFFF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000E001FFFFFFFFFFFFDC01FFFFF9FFFC00
      BDFDFE00F6CF8000B5FDFE00F6B70000BDFDFE00F6B70000BC798000F8B70000
      ACF98000FE8F0001A4058000FE3F000384098000FF7F000384138001FE3F0003
      84138003FEBF000387FB8007FC9F0FC38FEB807FFDDF000397CA80FFFDDF8007
      D45481FFFDDFF87FE008FFFFFFFFFFFFFFFFFFFFFEFFF801F83FF83FFEFFF801
      E00FE00FFC7FF801C007C007FC7FF80180038003F83F800180038003F83F8001
      00010001F01F800100010001F01F800500010001E00F801100010001E00F8001
      00010001FC7F800380038003FC7F800780038003FC7F811FC007C007FC7F801E
      E00FE00FFC7F803CF83FF83FFC7F8078FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFE7E7FF3FFFFFFFFFE3FFFC3FFCFFFFFFE1E7F03FFC3FFFFF
      C0E7C000FC0FFFFFC0F700000003FFFFE09BC0000000EFFFE183F03F0003C7FF
      80C7FC3FFC0F83FF80FFFF3FFC3FFFFFC07FFFFFFCFFFFFFC01FFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF3FFFFFFFFFFFFF
      FE2FF9FFFFFFFE3FF80FF0FFFFFFFC1FF807F0FFFFFFFC1FF287E07FFFFFFE7F
      F807C07FFFCFFC3FC28F843FE1E7FC3F800F1E3FE7F7FC3F941FFE1FEBF7FC1F
      003FFF1FFCE7F00F14FFFF8FFF0FE00795FFFFC7FFFFE00781FFFFE3FFFFE007
      C3FFFFF8FFFFF00FFFFFFFFFFFFFF81FFFFFFFFFF801E001FFFF0001F801C001
      07C10001F801800107C1FFFFF801800107C107C180018001010107C180018001
      0001010180018001020100018001800102010201800180018003020180018003
      C107800380038003C107C10780078003E38FC107801F8003E38FE38F801F8003
      E38FE38F803FC007FFFFE38F807FE00FFFFFFFFFF9FFF001800FC001F8FFF001
      80078001FC7FF00180038001FC3FF00180018001F01FF00180008001F00FF001
      80008001F80FF001800F8001F81FF001800F8001C00FB001800F8001C007B001
      C7F88001E00FE001FFFC8001E01F8003FFBA8001F00F8007FFC78001F007C20F
      FFFF8001F803877FFFFFFFFFF80383FF00000000000000000000000000000000
      000000000000}
  end
  object ibtrFunction: TIBTransaction
    Active = False
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 232
    Top = 176
  end
  object ActionList1: TActionList
    Images = imFunction
    Left = 232
    Top = 368
    object actFuncCommit: TAction
      Caption = 'Сохранить изменения'
      Hint = 'Сохранить изменения в базу данных'
      ImageIndex = 9
      ShortCut = 113
      OnExecute = actFuncCommitExecute
      OnUpdate = actFuncCommitUpdate
    end
    object actFuncRollback: TAction
      Caption = 'Отменить изменения'
      Hint = 'Отменить изменения'
      ImageIndex = 10
      OnExecute = actFuncRollbackExecute
    end
    object actLoadFromFile: TAction
      Caption = 'Загрузить из файла'
      Hint = 'Загрузить скрипт из файла'
      ImageIndex = 0
      OnExecute = actLoadFromFileExecute
      OnUpdate = actFunctionButtonUpdate
    end
    object actSaveToFile: TAction
      Caption = 'Сохранить в файл'
      Hint = 'Сохранить скрипт в файл'
      ImageIndex = 1
      OnExecute = actSaveToFileExecute
      OnUpdate = actFunctionButtonUpdate
    end
    object actCompile: TAction
      Caption = 'Запуск'
      Hint = 'Запуск'
      ImageIndex = 2
      OnExecute = actCompileExecute
      OnUpdate = actCompileUpdate
    end
    object actSQLEditor: TAction
      Caption = 'SQL редактор'
      Hint = 'Показать SQL редактор'
      ImageIndex = 3
      OnExecute = actSQLEditorExecute
    end
    object actFind: TAction
      Caption = 'Поиск'
      Hint = 'Найти в скрипте '
      ImageIndex = 4
      OnExecute = actFindExecute
      OnUpdate = actFunctionButtonUpdate
    end
    object actReplace: TAction
      Caption = 'Заменить'
      Hint = 'Заменить'
      ImageIndex = 5
      OnExecute = actReplaceExecute
      OnUpdate = actFunctionButtonUpdate
    end
    object actCopyText: TAction
      Category = 'Edit'
      Caption = 'Копировать SQL'
      Hint = 'Копировать SQL'
      ImageIndex = 19
      OnExecute = actCopyTextExecute
      OnUpdate = actCopyTextUpdate
    end
    object actPaste: TAction
      Category = 'Edit'
      Caption = 'Вставить SQL'
      Hint = 'Вставить SQL'
      ImageIndex = 20
      OnExecute = actPasteExecute
      OnUpdate = actPasteUpdate
    end
    object actOptions: TAction
      Caption = 'Настроики редактора...'
      Hint = 'Настройки внешнего вида'
      ImageIndex = 8
      OnExecute = actOptionsExecute
    end
    object actEditTemplate: TAction
      Caption = '...'
      Hint = 'Изменить шаблон'
      OnExecute = actEditTemplateExecute
      OnUpdate = actEditTemplateUpdate
    end
    object actPrev: TAction
      Caption = 'Предыдущий скрипт'
      Hint = 'Перейти к предыдущему скрипту'
      ImageIndex = 13
      ShortCut = 16464
      OnExecute = actPrevExecute
      OnUpdate = actPrevUpdate
    end
    object actNext: TAction
      Caption = 'Следующий скрипт'
      Hint = 'Перейти к следующему скрипту'
      ImageIndex = 14
      ShortCut = 16462
      OnExecute = actNextExecute
      OnUpdate = actNextUpdate
    end
    object actOnlySpecEvent: TAction
      Caption = 'Выводить только перекрытые события'
      Hint = 'Выводить только перекрытые события'
      OnExecute = actOnlySpecEventExecute
    end
    object actPrepare: TAction
      Caption = 'Подготовить'
      Hint = 'Подготовить'
      ImageIndex = 12
      ShortCut = 16504
      OnExecute = actPrepareExecute
      OnUpdate = actPrepareUpdate
    end
    object actSaveHist: TAction
      Caption = 'Сохранить в списке переходов'
      ShortCut = 16456
      OnExecute = actSaveHistExecute
      OnUpdate = actFunctionButtonUpdate
    end
    object actEditCopy: TEditCopy
      Category = 'Edit'
      Caption = 'Копировать'
      Hint = 'Копировать'
      ImageIndex = 6
      ShortCut = 16451
      OnExecute = actEditCopyExecute
      OnUpdate = actCopyTextUpdate
    end
    object actEditCut: TEditCut
      Category = 'Edit'
      Caption = 'Вырезать'
      Hint = 'Вырезать'
      ImageIndex = 22
      ShortCut = 16472
      OnExecute = actEditCutExecute
      OnUpdate = actCopyTextUpdate
    end
    object actEditPaste: TEditPaste
      Category = 'Edit'
      Caption = 'Вставить'
      Hint = 'Вставить'
      ImageIndex = 7
      ShortCut = 16470
      OnExecute = actEditPasteExecute
      OnUpdate = actPasteUpdate
    end
  end
  object ibsqlInsertEvent: TIBSQL
    ParamCheck = True
    SQL.Strings = (
      
        'INSERT INTO EVT_OBJECTEVENT (ID, OBJECTKEY, EVENTNAME, FUNCTIONK' +
        'EY, AFULL, DISABLE)'
      
        'VALUES(:ID, :OBJECTKEY, :EVENTNAME, :FUNCTIONKEY, :AFULL, :DISAB' +
        'LE) ')
    Transaction = ibtrFunction
    Left = 104
    Top = 112
  end
  object ibqrySetFunction: TIBQuery
    Transaction = ibtrFunction
    BufferChunks = 1000
    CachedUpdates = False
    SQL.Strings = (
      'SELECT'
      '  *'
      'FROM'
      '  gd_function'
      'WHERE'
      '  (module = :module)'
      '  AND'
      '  (modulecode = :objectkey)'
      '  OR'
      '  (id  = :functionkey)'
      'ORDER BY'
      '  name')
    Left = 136
    Top = 112
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'module'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'objectkey'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'functionkey'
        ParamType = ptUnknown
      end>
  end
  object dsSetFunction: TDataSource
    DataSet = ibqrySetFunction
    Left = 40
    Top = 272
  end
  object OpenDialog1: TOpenDialog
    Left = 336
    Top = 368
  end
  object SaveDialog1: TSaveDialog
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 368
    Top = 368
  end
  object FindDialog1: TFindDialog
    OnFind = FindDialog1Find
    Left = 264
    Top = 368
  end
  object ReplaceDialog1: TReplaceDialog
    OnFind = FindDialog1Find
    OnReplace = ReplaceDialog1Replace
    Left = 296
    Top = 368
  end
  object pmdbseScript: TPopupMenu
    Images = imFunction
    Left = 200
    Top = 368
    object actCompile1: TMenuItem
      Action = actCompile
    end
    object N7: TMenuItem
      Caption = '-'
    end
    object N8: TMenuItem
      Action = actFind
    end
    object N9: TMenuItem
      Action = actReplace
    end
    object N10: TMenuItem
      Caption = '-'
    end
    object N31: TMenuItem
      Action = actEditCopy
    end
    object N32: TMenuItem
      Action = actEditCut
    end
    object N33: TMenuItem
      Action = actEditPaste
    end
    object N30: TMenuItem
      Caption = '-'
    end
    object N11: TMenuItem
      Action = actCopyText
    end
    object N12: TMenuItem
      Action = actPaste
    end
    object N13: TMenuItem
      Caption = '-'
    end
    object actFuncCommit1: TMenuItem
      Action = actFuncCommit
    end
    object actFuncRollback1: TMenuItem
      Action = actFuncRollback
    end
    object N17: TMenuItem
      Caption = '-'
    end
    object N18: TMenuItem
      Action = actOptions
    end
  end
  object dsFunction: TDataSource
    DataSet = gdcFunction
    Left = 40
    Top = 240
  end
  object gdcDelphiObject: TgdcDelphiObject
    CachedUpdates = False
    ObjectType = otObject
    Left = 72
    Top = 144
  end
  object imMainTool: TImageList
    Left = 144
    Top = 208
    Bitmap = {
      494C010106000900040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
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
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000FF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000FF000000FF000000FF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000FF000000FF000000FF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      FF000000FF000000FF000000FF000000FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000FF000000
      FF000000FF000000FF000000FF000000FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000848484008400
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000007B7B7B000000FF000000
      FF0000000000000000000000FF000000FF000000FF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008400
      0000840000008400000084000000000000000000000000000000000000008400
      0000848484000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000007B7B7B000000FF00000000000000
      00000000000000000000000000000000FF000000FF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008400
      0000840000000000000000000000000000000000000000000000000000000000
      0000840000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FF000000FF000000FF00000000000000
      0000000000000000000000000000000000000000000000000000000000008400
      0000000000008400000000000000000000000000000000000000000000000000
      0000840000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000FF000000FF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000084000000840000000000000000000000000000008400
      0000848484000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000FF000000FF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008400000084000000840000008484
      8400000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000007B7B7B000000
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000007B7B
      7B000000FF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000FF000000FF00000000000000000000000000000000000000
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
      0000000000000000000000000000000000000000000000000000420039007B00
      000021397B007B000000840000007B0039009C000000420000009C0000009C39
      3900630000002100000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000007B000000FF00217B
      BD0000FFFF007B7B7B00633939000039FF000000BD000000000021007B0039BD
      BD00007BFF0000007B0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000BD00007BFF000039
      FF0000FFFF0000FFFF0000FFFF0000BDFF000039FF0000007B0000007B00007B
      FF0000FFFF000039FF000000BD00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008484840084848400848484008484
      8400848484008484840084848400848484008484840084848400848484008484
      8400848484008484840000000000000000000000000000007B00000039000000
      FF0000BDFF0000FFFF000039FF000000FF000039FF000000BD00000039000039
      FF0000FFFF0000FFFF000039FF0000007B00000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0000000000000000000000000000000000848484000000000000FFFF00C6C6
      C60000FFFF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6
      C60000FFFF00848484000000000000000000000000000000FF00000000000000
      FF0000BDFF0000FFFF000000BD00000000000000BD000000BD00000000000000
      FF0000FFFF000000FF000000FF0000007B00000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0000000000000000000000000000000000000000000000000000000000FFFF
      FF000000FF000000FF00FFFFFF00FFFFFF00FFFFFF000000FF000000FF00FFFF
      FF00000000000000000000000000000000008484840000000000C6C6C60000FF
      FF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60000FF
      FF00C6C6C6008484840000000000000000000000000000007B00000000000000
      FF000000FF000039FF0000007B000000FF0000007B00000039000000BD00007B
      FF0000BDFF00000039000000390000007B00000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF000000FF000000FF00FFFFFF000000FF000000FF00FFFFFF00FFFF
      FF0000000000000000000000000000000000848484000000000000FFFF00C6C6
      C60000FFFF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6
      C60000FFFF008484840000000000000000000000000000000000000000000000
      BD0000000000000039000000FF0000007B0000003900000000000000FF00007B
      FF000000FF0000007B0000007B0000003900000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF000000FF000000FF000000FF00FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000008484840000000000C6C6C60000FF
      FF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60000FF
      FF00C6C6C6008484840000000000000000000000000000007B0000007B000000
      390000007B00000039000000BD000000000000003900000000000039FF0000BD
      FF00007BFF0000007B0000007B0000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF000000FF000000FF000000FF00FFFFFF00FFFFFF00FFFF
      FF0000000000000000000000000000000000848484000000000000FFFF00C6C6
      C60000FFFF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6
      C60000FFFF008484840000000000000000000000000000007B00000039000000
      00000039FF0000007B0000003900000039000039FF00000039000000FF000000
      BD0000007B000000FF000000000000003900000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF000000FF000000FF00FFFFFF000000FF000000FF00FFFFFF00FFFF
      FF00000000000000000000000000000000008484840000000000C6C6C60000FF
      FF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60000FF
      FF00C6C6C6008484840000000000000000000000000000007B00000000000000
      00000000FF0000000000000000000000BD0000BDFF0000007B0000007B000000
      0000000000000000BD000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0000000000000000000000000000000000000000000000000000000000FFFF
      FF000000FF000000FF00FFFFFF00FFFFFF00FFFFFF000000FF000000FF00FFFF
      FF0000000000000000000000000000000000848484000000000000FFFF00C6C6
      C60000FFFF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6C60000FFFF00C6C6
      C60000FFFF008484840000000000000000000000000000000000000000000000
      00000000BD0000000000000000000000FF00007BFF000000000000007B000000
      00000000FF00000039000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000008484840000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008484840000000000000000000000000000000000000000000000
      000000007B00000000000000000000007B000000FF0000000000000000000000
      00000000BD00000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000000000000000
      00000000000000000000000000000000000084848400C6C6C60000FFFF00C6C6
      C60000FFFF00C6C6C60000FFFF00C6C6C6008484840084848400848484008484
      8400848484008484840000000000000000000000000000000000000000000000
      00000000000000000000000000000000390000007B0000000000000000000000
      000000007B00000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF000000
      0000000000000000000000000000000000000000000084848400C6C6C60000FF
      FF00C6C6C60000FFFF00C6C6C600848484000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000007B0000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000000000000000
      0000000000000000000000000000000000000000000000000000848484008484
      8400848484008484840084848400000000000000000000000000000000000000
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
      00000000000000000000000000000000FFFFFFFF00000000FFFFFFFF00000000
      F9FFFFFF00000000F0FFFFFF00000000F0FFFFFF00000000E07FFFFF00000000
      C07FFFCF00000000843FE1E7000000001E3FE7F700000000FE1FEBF700000000
      FF1FFCE700000000FF8FFF0F00000000FFC7FFFF00000000FFE3FFFF00000000
      FFF8FFFF00000000FFFFFFFF00000000FFFFC003FFFFFFFFFFFF8003FFFFFFFF
      80018001C007C00700018000C007C0074001A120C007C0074001A000C007C007
      4001E840C007C00740018141C007C00740019002C007C0074001B61BC007C007
      4001F653C007C0077FF9F677C007C0070003FE77C00FC00F80FFFF7FC01FC01F
      C1FFFFFFC03FC03FFFFFFFFFFFFFFFFF00000000000000000000000000000000
      000000000000}
  end
  object gdcFunction: TgdcFunction
    CachedUpdates = False
    Left = 40
    Top = 144
  end
  object gdcEvent: TgdcEvent
    CachedUpdates = False
    QueryFiltered = True
    Left = 104
    Top = 144
  end
  object dsTemplate: TDataSource
    DataSet = gdcTemplate
    Left = 136
    Top = 240
  end
  object cdsTemplateType: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 296
    Top = 240
    object cdsTemplateTypeTemplateType: TStringField
      FieldName = 'TemplateType'
    end
    object cdsTemplateTypeDescriptionType: TStringField
      FieldName = 'DescriptionType'
    end
  end
  object dsTemplateType: TDataSource
    DataSet = cdsTemplateType
    Left = 296
    Top = 208
  end
  object gdcMacros: TgdcMacros
    CachedUpdates = False
    QueryFiltered = True
    Left = 136
    Top = 176
  end
  object ActionList2: TActionList
    Images = imTreeView
    Left = 72
    Top = 112
    object actAddMacros: TAction
      Caption = 'Добавить макрос'
      Hint = 'Добавить макрос'
      ImageIndex = 13
      OnExecute = actAddMacrosExecute
      OnUpdate = actAddMacrosUpdate
    end
    object actAddFolder: TAction
      Caption = 'Добавить папку'
      Hint = 'Добавить папку'
      ImageIndex = 11
      OnExecute = actAddFolderExecute
      OnUpdate = actAddFolderUpdate
    end
    object actDeleteFolder: TAction
      Caption = 'Удалить папку'
      Hint = 'Удалить папку'
      ImageIndex = 12
      OnExecute = actDeleteFolderExecute
      OnUpdate = actDeleteFolderUpdate
    end
    object actDeleteMacros: TAction
      Caption = 'Удалить макрос'
      Hint = 'Удалить макрос'
      ImageIndex = 14
      OnExecute = actDeleteMacrosExecute
      OnUpdate = actDeleteMacrosUpdate
    end
    object actRename: TAction
      Caption = 'Переименовать'
      Hint = 'Переименовать'
      OnExecute = actRenameExecute
      OnUpdate = actRenameUpdate
    end
    object actAddReport: TAction
      Caption = 'Добавить отчёт'
      Hint = 'Добавить отчёт'
      ImageIndex = 15
      ShortCut = 16466
      OnExecute = actAddReportExecute
      OnUpdate = actAddReportUpdate
    end
    object actDeleteReport: TAction
      Caption = 'Удалить отчёт'
      Hint = 'Удалить отчёт'
      ImageIndex = 16
      OnExecute = actDeleteReportExecute
      OnUpdate = actDeleteReportUpdate
    end
    object actCutTreeItem: TAction
      Caption = 'Вырезать'
      Hint = 'Вырезать в буфер обмена'
      ImageIndex = 17
      OnExecute = actCutTreeItemExecute
      OnUpdate = actCutTreeItemUpdate
    end
    object actPasteTreeItem: TAction
      Caption = 'Вставить'
      Hint = 'Вставить из буфера обмена'
      ImageIndex = 18
      OnExecute = actPasteFromClipBoardExecute
      OnUpdate = actPasteFromClipBoardUpdate
    end
    object actCopyTreeItem: TAction
      Caption = 'Копировать'
      Hint = 'Копировать в буфер'
      ImageIndex = 19
      OnExecute = actCopyTreeItemExecute
      OnUpdate = actCopyTreeItemUpdate
    end
    object actAddScriptFunction: TAction
      Caption = 'Добавить функцию'
      Hint = 'Добавить отдельную скрипт-функцию'
      ImageIndex = 21
      OnExecute = actAddScriptFunctionExecute
      OnUpdate = actAddScriptFunctionUpdate
    end
    object actDeleteScriptFunction: TAction
      Caption = 'Удалить функцию'
      Hint = 'Удалить отдельную скрипт-функцию'
      ImageIndex = 22
      OnExecute = actDeleteScriptFunctionExecute
      OnUpdate = actDeleteScriptFunctionUpdate
    end
    object actRefresh: TAction
      Caption = 'Обновить'
      Hint = 'Обновить дерево'
      ImageIndex = 25
      OnExecute = actRefreshExecute
      OnUpdate = actRefreshUpdate
    end
    object actExecReport: TAction
      Caption = 'Выполнить отчёт'
      Hint = 'Выполнить отчет'
      OnExecute = actExecReportExecute
      OnUpdate = actExecReportUpdate
    end
    object actFindInTree: TAction
      Caption = 'Поиск в дереве'
      Hint = 'Поиск в дереве'
      OnExecute = actFindInTreeExecute
    end
    object actFindFunction: TAction
      Caption = 'Поиск функции'
      OnExecute = actFindFunctionExecute
    end
    object actExpand: TAction
      Caption = 'Развернуть дерево'
      Hint = 'Развернуть дерево'
      OnExecute = actExpandExecute
    end
    object actUnExpand: TAction
      Caption = 'Свернуть дерево'
      Hint = 'Свернуть дерево'
      OnExecute = actUnExpandExecute
    end
    object actAutoSave: TAction
      Caption = 'Автосохранение изменений'
      Hint = 'Сохранять изменения без выдачи запроса на подтверждение'
      OnExecute = actAutoSaveExecute
    end
    object actAddVBClass: TAction
      Caption = 'Добавить класс'
      ImageIndex = 26
      OnExecute = actAddVBClassExecute
      OnUpdate = actAddVBClassUpdate
    end
    object actDeleteVBClass: TAction
      Caption = 'Удалить класс'
      ImageIndex = 27
      OnExecute = actDeleteScriptFunctionExecute
      OnUpdate = actDeleteVBClassUpdate
    end
    object actDeleteEvent: TAction
      Caption = 'Удалить событие/метод'
      ImageIndex = 28
      OnExecute = actDeleteEventExecute
      OnUpdate = actDeleteEventUpdate
    end
    object actDeleteUnusedMethods: TAction
      Caption = 'Удалить неиспользуемые методы'
      OnExecute = actDeleteUnusedMethodsExecute
    end
    object actDeleteUnUsedEvents: TAction
      Caption = 'Удалить неиспользуемые события'
      OnExecute = actDeleteUnUsedEventsExecute
    end
    object actSettings: TAction
      Caption = 'Настройки окна ...'
      OnExecute = actSettingsExecute
    end
    object actAddItem: TAction
      Caption = 'Добавить ...'
      ImageIndex = 13
      OnExecute = actAddItemExecute
      OnUpdate = actAddItemUpdate
    end
    object actDeleteItem: TAction
      Caption = 'Удалить...'
      ImageIndex = 14
      ShortCut = 16430
      OnExecute = actDeleteItemExecute
      OnUpdate = actDeleteItemUpdate
    end
    object actAddConst: TAction
      Caption = 'Добавить описание констант'
      OnExecute = actAddConstExecute
    end
    object actAddGlobalObject: TAction
      Caption = 'Добавить глобальный объект'
      OnExecute = actAddGlobalObjectExecute
    end
    object actDisableMethod: TAction
      Caption = 'Отключить метод'
      ShortCut = 49220
      OnExecute = actDisableMethodExecute
    end
    object actSpeedReturn: TAction
      Caption = 'Перейти'
      Hint = 'Перейти к предыдущей скрипт-функции'
      ImageIndex = 35
      OnExecute = actSpeedReturnExecute
    end
    object actDeleteReportFunction: TAction
      Caption = 'Удалить функцию отчета'
      ImageIndex = 36
      OnExecute = actDeleteReportFunctionExecute
      OnUpdate = actDeleteReportFunctionUpdate
    end
    object actProperty: TAction
      Caption = 'Доступ'
      OnExecute = actPropertyExecute
      OnUpdate = actPropertyUpdate
    end
    object actShowTreeWindow: TAction
      Caption = 'Показать дерево'
      OnExecute = actShowTreeWindowExecute
      OnUpdate = actShowTreeWindowUpdate
    end
    object actShowMessagesWindow: TAction
      Caption = 'Показать окно сообщений'
      OnExecute = actShowMessagesWindowExecute
      OnUpdate = actShowMessagesWindowUpdate
    end
  end
  object pmtvClasses: TPopupMenu
    Images = imTreeView
    Left = 40
    Top = 112
    object actAddFolder1: TMenuItem
      Action = actAddFolder
    end
    object N1: TMenuItem
      Action = actDeleteFolder
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object N3: TMenuItem
      Action = actAddItem
    end
    object N4: TMenuItem
      Action = actDeleteItem
    end
    object N28: TMenuItem
      Caption = '-'
    end
    object N19: TMenuItem
      Action = actCopyTreeItem
    end
    object N20: TMenuItem
      Action = actCutTreeItem
    end
    object N21: TMenuItem
      Action = actPasteTreeItem
    end
    object N22: TMenuItem
      Caption = '-'
    end
    object N6: TMenuItem
      Action = actRename
    end
    object N25: TMenuItem
      Caption = '-'
    end
    object N23: TMenuItem
      Action = actExpand
    end
    object N24: TMenuItem
      Action = actUnExpand
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object N14: TMenuItem
      Action = actDisableMethod
      ImageIndex = 32
    end
    object N27: TMenuItem
      Caption = '-'
    end
    object N29: TMenuItem
      Action = actProperty
    end
  end
  object gdcMacrosGroup: TgdcMacrosGroup
    CachedUpdates = False
    QueryFiltered = True
    Left = 104
    Top = 176
  end
  object gdcReport: TgdcReport
    CachedUpdates = False
    QueryFiltered = True
    Left = 72
    Top = 176
  end
  object gdcReportGroup: TgdcReportGroup
    CachedUpdates = False
    QueryFiltered = True
    Left = 40
    Top = 176
  end
  object gdcTemplate: TgdcTemplate
    CachedUpdates = False
    QueryFiltered = True
    Left = 136
    Top = 144
  end
  object dsReport: TDataSource
    DataSet = gdcReport
    Left = 72
    Top = 240
  end
  object dsMacros: TDataSource
    DataSet = gdcMacros
    Left = 104
    Top = 240
  end
  object dsTemplate1: TDataSource
    DataSet = ibqryTemplate
    Left = 232
    Top = 208
  end
  object dsReportServer: TDataSource
    DataSet = ibqryReportServer
    Left = 264
    Top = 208
  end
  object ibqryReportServer: TIBQuery
    Transaction = ibtrFunction
    BufferChunks = 1000
    CachedUpdates = False
    SQL.Strings = (
      'SELECT'
      '  *'
      'FROM'
      '  rp_reportserver'
      'ORDER BY '
      '  usedorder')
    Left = 264
    Top = 240
  end
  object ibqryTemplate: TIBQuery
    Transaction = ibtrFunction
    BufferChunks = 1000
    CachedUpdates = False
    SQL.Strings = (
      'SELECT'
      '  *'
      'FROM'
      '  rp_reporttemplate'
      'ORDER BY '
      '  name')
    Left = 232
    Top = 240
  end
  object dsDescription: TDataSource
    Left = 72
    Top = 272
  end
  object SynCompletionProposal: TSynCompletionProposal
    DefaultType = ctCode
    OnExecute = SynCompletionProposalExecute
    ItemList.Strings = (
      'Active'
      'ActiveWindow'
      'Add(QueryName, MemQuery)'
      'AddField'
      
        'AddMasterDetail(MasterTable, MasterField, DetailTable, DetailFie' +
        'ld)'
      'Append'
      'AsInteger'
      'AsString'
      'AsVariant'
      'BaseQuery'
      'Bof'
      'Cancel'
      'Clear'
      'ClearFields'
      'Close'
      'Commit'
      'Company'
      'Contact'
      'Count'
      'Delete'
      'Delete(Index: Integer)'
      'DeleteByName(AName)'
      'Edit'
      'Eof'
      'ExecSQL'
      'FetchBlob'
      'FieldByName(FieldName)'
      'FieldCount'
      'FieldName'
      'Fields(Index)'
      'FieldSize'
      'FieldType'
      'First'
      'GedeminPath'
      'GetCompany(Folder, Name)'
      'GetGlobal(Folder, Name)'
      'GetNewParamWindow(WindowKey)'
      'GetUser(Folder, Name)'
      'GetValue(Name)'
      'GetValueByID(AnID)'
      'ID'
      'IndexFields'
      'InGroup'
      'Insert'
      'IsResult'
      'IsWindowExit(WindowName)'
      'Last'
      'MainInitialize'
      'Name'
      'Next'
      'Open'
      'ParamByName(ParamName)'
      'ParamCount'
      'Params(Index)'
      'Post'
      'Prior'
      'Query(Index)'
      'QueryByName(Name)'
      'RecordCount'
      'ReportSystem'
      'Required'
      'ResultStream'
      'ShowSQL(S)'
      'ShowString(S)'
      'SQL'
      'SubSystem'
      'System'
      'User'
      'WindowByName(WindowName)'
      'WindowExists(WindowName)')
    Position = 0
    NbLinesInWindow = 6
    ClSelect = clBlue
    ClText = clWindowText
    ClSelectedText = clHighlightText
    ClBackground = clWindow
    AnsiStrings = True
    CaseSensitive = False
    ShrinkList = True
    Width = 262
    BiggestWord = 'CONSTRUCTOR'
    UsePrettyText = True
    UseInsertList = True
    EndOfTokenChr = '()[].'
    LimitToMatchedText = False
    ShortCut = 16416
    Editor = gsFunctionSynEdit
    Left = 160
    Top = 368
  end
  object ibtrObject: TIBTransaction
    Active = False
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 264
    Top = 176
  end
  object pmHistory: TPopupMenu
    AutoLineReduction = maManual
    Left = 328
    Top = 240
  end
  object imglGutterGlyphs: TImageList
    Height = 14
    Width = 11
    Left = 40
    Top = 304
    Bitmap = {
      494C01010600090004000B000E00FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      00000000000036000000280000002C0000002A0000000100200000000000E01C
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
      00000000000000000000000000000000FF000000FF000000FF000000FF000000
      FF0000000000000000000000000000000000000000000000000084848400C6C6
      C60084848400C6C6C60084848400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000FF0000FF
      FF000000FF000000FF000000FF0000FFFF000000FF0000000000000000000000
      00000000000084848400C6C6C60084848400C6C6C60084848400C6C6C6008484
      8400000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000FF0000FFFF0000FFFF000000FF0000FFFF0000FF
      FF000000FF0000000000000000000000000000000000C6C6C60084848400C6C6
      C60084848400C6C6C60084848400C6C6C6000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000FF000000
      FF0000FFFF0000FFFF0000FFFF000000FF000000FF0000000000000000000000
      00000000000084848400C6C6C60084848400C6C6C60084848400C6C6C6008484
      8400000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000FF0000FFFF0000FFFF000000FF0000FFFF0000FF
      FF000000FF0000000000000000000000000000000000C6C6C60084848400C6C6
      C60084848400C6C6C60084848400C6C6C6000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000FF0000FF
      FF000000FF000000FF000000FF0000FFFF000000FF0000000000000000000000
      00000000000084848400C6C6C60084848400C6C6C60084848400C6C6C6008484
      8400000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FF000000FF000000FF000000FF000000
      FF0000000000000000000000000000000000000000000000000084848400C6C6
      C60084848400C6C6C60084848400000000000000000000000000000000000000
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
      0000000000000000000000000000000000000000000000000000000000008400
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000084000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000840000008400000000000000000000000000
      0000000000000000000000000000000000000000000084848400840000008400
      0000848484008484840000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008400
      0000FF0000008400000000000000000000000000000000000000000000000000
      0000848484000000FF0084000000FF000000840000000000FF00848484000000
      0000000000000000000000000000000000000000FF0000FF00000000FF000000
      FF000000FF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000084000000840000008400000084000000FF000000FF000000840000000000
      000000000000000000000000000084000000840000008400000084000000FF00
      0000FF000000840000000000FF00848484000000000000000000000000000000
      FF0000FF000000FF000000FF00000000FF000000FF000000FF00000000000000
      0000000000000000000000000000000000000000000084000000840000000000
      00000000000000000000000000000000000084000000FF000000FF000000FF00
      0000FF000000FF000000FF000000840000000000000000000000000000008400
      0000FF000000FF000000FF000000FF000000FF000000FF000000840000008484
      840000000000000000000000000000FF000000FF00000000FF0000FF00000000
      FF000000FF000000FF0000000000000000000000000000000000000000000000
      000084000000FF000000FF000000840000000000000000000000000000000000
      000084000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      000084000000000000000000000084000000FF000000FF000000FF000000FF00
      0000FF000000FF000000FF000000840000000000000000000000000000000000
      FF000000FF000000FF0000FF000000FF00000000FF000000FF00000000000000
      000000000000000000000000000000000000FFFF0000FF000000FF0000008400
      0000000000000000000000000000000000008400000084840000FFFF00008484
      0000FFFF0000FF000000FF000000840000000000000000000000000000008400
      000084840000FFFF000084840000FFFF0000FF000000FF000000840000008484
      84000000000000000000000000000000FF000000FF000000FF000000FF0000FF
      00000000FF000000FF0000000000000000000000000000000000000000000000
      000000000000FFFF000084000000000000000000000000000000000000000000
      00008400000084000000840000008400000084840000FFFF0000840000000000
      0000000000000000000000000000840000008400000084000000840000008484
      0000FFFF0000840000000000FF00848484000000000000000000000000000000
      FF000000FF000000FF000000FF0000FF000000FF00000000FF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008400
      0000FFFF00008400000000000000000000000000000000000000000000000000
      0000848484000000FF0084000000FFFF0000840000000000FF00848484000000
      0000000000000000000000000000000000000000FF000000FF000000FF000000
      FF0000FF00000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000840000008400000000000000000000000000
      0000000000000000000000000000000000000000000084848400840000008400
      0000848484008484840000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000FF000000FF0000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008400
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000084000000000000000000000000000000000000000000
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
      280000002C0000002A0000000100010000000000500100000000000000000000
      000000000000000000000000FFFFFF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      FFFFFC0000000000FFFFFC0000000000E0FC1C0000000000C0780C0000000000
      8030040000000000803004000000000080300400000000008030040000000000
      8030040000000000C0780C0000000000E0FC1C0000000000FFFFFC0000000000
      FFFFFC0000000000FFFFFC0000000000FFFFFFFFFFF00000FFFEFFDFFFF00000
      FFFE7F83F0700000FFFE3F01E0300000FFF01E00C0100000F9F00E00C0100000
      F0F00600C0100000F0F00E00C0100000F9F01E00C0100000FFFE3F01E0300000
      FFFE7F83F0100000FFFEFFDFFF300000FFFFFFFFFFF00000FFFFFFFFFFF00000
      00000000000000000000000000000000000000000000}
  end
  object imglActions: TImageList
    Left = 72
    Top = 304
    Bitmap = {
      494C010112001300040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000005000000001002000000000000050
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080808000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000080808000000000000000000000000000000000000000
      0000000000000000000000000000000000008080800080808000000000000000
      0000000000008080800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C0C0C000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C000C0C0C00000000000000000000000000080808000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C0C0C000C0C0
      C0000000000000000000C0C0C0000000000000000000C0C0C000000000000000
      0000C0C0C000C0C0C00000000000000000000000000000000000000000000000
      000000000000FFFFFF00FFFFFF00000000000000000000000000FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C0C0C000C0C0
      C0000000000000000000C0C0C0000000000000000000C0C0C000000000000000
      0000C0C0C000C0C0C00000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF0000000000000000000000000000000000FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C0C0C000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C000C0C0C00000000000000000000000000000000000000000000000
      0000808080000000000000000000000000000000000080808000000000000000
      0000000000008080800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C0C0C000C0C0
      C0000000000000000000C0C0C0000000000000000000C0C0C000000000000000
      0000C0C0C000C0C0C00000000000000000000000000080808000000000008080
      8000000000000000000000000000000000000000000000000000000000008080
      8000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C0C0C000C0C0
      C0000000000000000000C0C0C0000000000000000000C0C0C000000000000000
      0000C0C0C000C0C0C00000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C0C0C000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C000C0C0C00000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C0C0C0008000
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000FF000000C0C0C00000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C0C0C0008000
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000FF000000C0C0C00000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008000
      0000800000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C0C0C0008000
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000FF000000C0C0C00000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008000
      0000800000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C0C0C0008000
      0000800000008000000080000000800000008000000080000000800000008000
      000080000000C0C0C00000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080000000800000008000
      0000800000008000000080000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C0C0C000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C000C0C0C00000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080000000800000008000
      0000800000008000000080000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080808000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008000
      0000800000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008000
      0000800000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000080808000808080008080800080808000808080008080
      8000808080000000000000000000000000000000000000000000000000000000
      0000000000008080800080808000808080008080800080808000808080008080
      8000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008000000080000000800000008000000080000000800000008000
      0000808080000000000000000000000000000000000000000000000000000000
      0000800000008000000080000000800000008000000080000000800000008080
      8000000000000000000000000000000000000000000000000000000000008080
      8000808080008080800080808000000000000000000000000000808080008080
      8000808080008080800000000000000000008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000080000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008000
      0000808080000000000000000000000000000000000000000000000000000000
      000080000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00800000008080
      8000000000000000000000000000000000000000000000000000800000008000
      0000800000008000000080808000000000000000000080000000800000008000
      00008000000080808000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000080000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008000
      0000808080000000000000000000000000000000000000000000000000000000
      000080000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00800000008080
      8000000000000000000000000000000000000000000000000000800000008080
      8000800000008000000080808000000000000000000080000000808080008000
      00008000000080808000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000080000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008000
      0000808080000000000000000000000000000000000000000000000000000000
      000080000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00800000008080
      8000000000000000000000000000000000000000000000000000808080008000
      0000808080008000000080808000000000000000000080808000800000008080
      80008000000080808000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00C0C0C0000000000000000000FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000080000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008000
      0000808080000000000000000000000000000000000000000000000000000000
      000080000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00800000008080
      8000000000000000000000000000000000000000000000000000800000008080
      8000800000008000000080808000000000000000000080000000808080008000
      00008000000080808000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0080808000000000000000000000000000FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000080000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008000
      0000808080000000000000000000000000000000000000000000000000000000
      000080000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00800000008080
      8000000000000000000000000000000000000000000000000000808080008000
      0000808080008000000080808000000000000000000080808000800000008080
      80008000000080808000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00808080000000000000000000000000000000000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008000000080000000800000008000000080000000800000008000
      0000000000000000000000000000000000000000000000000000000000000000
      0000800000008000000080000000800000008000000080000000800000000000
      0000000000000000000000000000000000000000000000000000800000008080
      8000800000008000000080808000000000000000000080000000808080008000
      00008000000080808000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000FFFFFF000000000000000000FFFFFF008080
      8000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000808080008000
      0000808080008000000080808000000000000000000080808000800000008080
      80008000000080808000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF000000000000000000FFFFFF00FFFFFF00FFFFFF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000800000008080
      8000800000008000000080808000000000000000000080000000808080008000
      00008000000080808000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000808080008000
      0000808080008000000080808000000000000000000080808000800000008080
      80008000000080808000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000800000008080
      8000800000008000000080808000000000000000000080000000808080008000
      00008000000080808000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080800080808000C0C0C0000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000808080008000
      0000808080008000000080808000000000000000000080808000800000008080
      80008000000080808000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0080808000FFFFFF00808080000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000800000008080
      8000800000008000000080808000000000000000000080000000808080008000
      00008000000080808000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080800080808000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000808080008000
      0000808080008000000080808000000000000000000080808000800000008080
      8000800000008080800000000000000000008080800080808000808080008080
      8000808080008080800080808000808080008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000800000008080
      8000800000008000000000000000000000000000000080000000808080008000
      0000800000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000808080008080800080808000808080008080800080808000808080008080
      8000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008080
      8000000000000000000000000000000000000000000000000000000000000000
      0000808080000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000C0C0C000C0C0C000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C000C0C0C000C0C0C000000000000000000000000000000000000000
      00000000000000FF0000C0C0C000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008080
      8000000000000000FF000000FF000000FF000000000000000000000000000000
      000080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF000000000000000000C0C0C00080808000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00C0C0C000000000000000000000000000000000000000
      000000000000C0C0C00000FF0000C0C0C0000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008000000080000000000000008000000080000000000000008080
      8000000000000000000000000000000000000000000000000000000000000000
      000080808000FFFFFF0080808000808080008080800080808000808080008080
      80008080800080808000FFFFFF000000000000000000C0C0C000808080000000
      0000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C000FFFFFF00C0C0C000000000000000000000000000000000000000
      00000000000000FF0000C0C0C00000FF0000C0C0C00000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000800000000000000000000000000000008080
      800000000000000000000000FF00000000008000000000000000000000000000
      000080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF000000000000000000C0C0C000808080000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00C0C0C000FFFFFF00C0C0C000000000000000000000000000000000000000
      000000000000C0C0C00000FF0000C0C0C00000FF0000C0C0C000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000800000000000000000000000000000008080
      8000000000000000FF000000FF000000FF008000000080000000000000000000
      000080808000FFFFFF0080808000808080008080800080808000808080008080
      80008080800080808000FFFFFF000000000000000000C0C0C000808080000000
      0000FFFFFF00FFFFFF00FFFFFF00FF000000FF000000FFFFFF00FFFFFF00FFFF
      FF00C0C0C000FFFFFF00C0C0C000000000000000000000000000000000000000
      00000000000000FF0000C0C0C00000FF0000C0C0C00000FF0000C0C0C0000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000800000000000000000000000000000008080
      800000000000000000000000FF00000000008000000080000000800000000000
      000080808000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000FF000000FF000000FF0000000000000000000000C0C0C000808080000000
      0000FFFFFF00FFFFFF00FF000000FFFFFF00FFFFFF00FF000000FFFFFF00FFFF
      FF00C0C0C000FFFFFF00C0C0C000000000000000000000000000000000000000
      000000000000C0C0C00000FF0000C0C0C00000FF0000C0C0C00000FF0000C0C0
      C000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000800000000000000000000000000000008080
      800000000000000000000000FF00000000008000000080000000800000000000
      000080808000FF000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FF0000000000000000000000C0C0C000808080000000
      0000FFFFFF00FFFFFF00FF000000FFFFFF00FFFFFF00FF000000FFFFFF00FFFF
      FF00C0C0C000FFFFFF00C0C0C000000000000000000000000000000000000000
      00000000000000FF0000C0C0C00000FF0000C0C0C00000FF0000C0C0C00000FF
      0000C0C0C0000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000800000000000000000000000000000008080
      8000000000000000000000000000000000008000000080000000000000000000
      000080808000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000FF000000FF000000FF0000000000000000000000C0C0C000808080000000
      0000FFFFFF00FFFFFF00FF000000FFFFFF00FFFFFF00FF000000FFFFFF00FFFF
      FF00C0C0C000FFFFFF00C0C0C000000000000000000000000000000000000000
      000000000000C0C0C00000FF0000C0C0C00000FF0000C0C0C00000FF0000C0C0
      C000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000800000000000000000000000000000008080
      800000000000000000000000FF00000000008000000000000000000000000000
      000080808000FFFFFF0080808000808080008080800080808000808080008080
      80008080800080808000FFFFFF000000000000000000C0C0C000808080000000
      0000FFFFFF00FFFFFF00FFFFFF00FF000000FF000000FFFFFF00FFFFFF00FFFF
      FF00C0C0C000FFFFFF00C0C0C000000000000000000000000000000000000000
      00000000000000FF0000C0C0C00000FF0000C0C0C00000FF0000C0C0C0000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008000000080000000000000008000000080000000000000008080
      8000000000000000000000000000000000000000000000000000000000000000
      000080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF000000000000000000C0C0C000808080000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00C0C0C000FFFFFF00C0C0C000000000000000000000000000000000000000
      000000000000C0C0C00000FF0000C0C0C00000FF0000C0C0C000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008080
      800000000000000000000000FF00000000000000000000000000000000000000
      000080808000FFFFFF0080808000808080008080800080808000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF000000000000000000C0C0C000808080000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FFFFFF00C0C0C000000000000000000000000000000000000000
      00000000000000FF0000C0C0C00000FF0000C0C0C00000000000000000000000
      0000000000000000000000000000000000008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF000000000000000000000000000000000000000000C0C0C000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      80008080800080808000C0C0C000000000000000000000000000000000000000
      000000000000C0C0C00000FF0000C0C0C0000000000000000000000000000000
      0000000000000000000000000000000000008000000080808000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000FF00000000000000000000000000000000000000
      000080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0000000000FFFFFF00000000000000000000000000C0C0C000C0C0C000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C000C0C0C000C0C0C000000000000000000000000000000000000000
      00000000000000FF0000C0C0C000000000000000000000000000000000000000
      0000000000000000000000000000000000008080800080000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000808080008080800080808000808080008080800080808000808080008080
      8000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008080
      8000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00808080000000
      0000000000008000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      8000808080000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00808080000000
      0000800000008000000080000000000000000000000000000000000000000000
      00000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      8000000080000000000000000000FFFFFF00FFFFFF008080800000008000FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FF00
      0000FF000000FF000000FF000000FF000000FF000000FFFFFF00808080008000
      0000800000008000000080000000800000000000000000000000000000000000
      000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      80000000800080808000FFFFFF00FFFFFF00808080000000800080808000FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00000080008080800080808000FFFFFF00808080000000
      0000000000008000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00000000000000000000000000000000000000000000000000FFFF
      FF00000080000000800080808000FFFFFF000000800000008000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FF000000FF00000000008000000080008080800080808000808080000000
      0000000000008000000000008000808080000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000FFFFFF00FFFF
      FF008080800000008000000080000000800000008000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000800000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000000080000000800080808000808080000000
      000000000000800000000000800080808000000000000000000000000000FFFF
      FF00FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF000000000000008000000080000000800000000000FFFFFF0000000000FFFF
      FF0000000000FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000080000000800000008000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FF00
      0000FF000000FF000000FF000000000080000000800080808000808080000000
      0000000080000000800080808000000000000000000000000000FFFFFF00FFFF
      FF000000000000000000FFFFFF0000000000FFFFFF0000000000FFFFFF000000
      0000FFFFFF0000000000000000000000000000000000FFFFFF00000000008080
      80000000800000008000000080000000800080808000FFFFFF0000000000FFFF
      FF0000000000FFFFFF0000000000000000000000000000000000000000000000
      0000000000008000000080000000800000008000000080000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00808080000000800000008000808080008080
      8000000080000000800000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF0000000000FFFFFF0000000000FFFFFF000000
      0000FFFFFF0000000000000000000000000000000000FFFFFF00000080000000
      800000008000808080000000000000008000000080008080800000000000FFFF
      FF0000000000FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000800000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FF00
      0000FF000000FF000000FF000000FF0000000000800000008000000080000000
      8000000080008000000000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF0000000000FFFFFF0000000000FFFFFF000000
      0000FFFFFF00000000000000000000000000000000000000000000000000FFFF
      FF0000000000FFFFFF0000000000FFFFFF00000080000000800080808000FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000800000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080800000008000000080000000
      8000808080008000000000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF0000000000FFFFFF0000000000FFFFFF000000
      0000FFFFFF00000000000000000000000000000000000000000000000000FFFF
      FF0000000000FFFFFF0000000000FFFFFF000000000000008000000080008080
      8000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000800000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FF000000FF00
      0000FF000000FFFFFF0080808000808080000000800000008000000080000000
      8000808080008000000000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF0000000000FFFFFF0000000000FFFFFF000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF0000000000FFFFFF00000000000000000000000000FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000800000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000800000008000FFFFFF00FFFFFF00808080000000
      8000000080008080800080808000000000000000000000000000000000000000
      00000000000000000000FFFFFF0000000000FFFFFF0000000000FFFFFF000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF0000000000FFFFFF0000000000FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000008000000000000000000000000000
      0000000000000000000080000000808080000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00808080008080
      8000000080000000800080808000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008080800080000000800000008000
      0000800000008000000080808000000000000000000000000000000000000000
      0000000000000000000000000000000000008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080000000
      0000000000000000800000008000808080000000000000000000000000000000
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
      0000000000000000000000000000000000008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00808080000000
      0000000000008000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00808080000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00808080000000
      0000800000008000000080000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00808080008000
      0000FF0000000000000080000000FF00000080808000FFFFFF00FFFFFF00FF00
      0000FF000000FF000000FF000000FF000000FF000000FFFFFF00808080008000
      0000800000008000000080000000800000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FF00
      0000FF000000FF000000FF000000FF000000FF000000FFFFFF0080808000FF00
      00008000000000000000FF0000008000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00808080000000
      0000000000008000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00808080008000
      0000FF0000000000000080000000FF00000080808000FFFFFF00FFFFFF00FFFF
      FF00FF000000FF000000FF000000FF000000FFFFFF00FFFFFF00808080000000
      0000000000008000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FF000000FF000000FF000000FF000000FFFFFF00FFFFFF0080808000FF00
      00008000000000000000FF0000008000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00808080000000
      0000000000008000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00808080008000
      0000FF0000000000000080000000FF00000080808000FFFFFF00FFFFFF00FF00
      0000FF000000FF000000FF000000FF000000FF000000FFFFFF00808080000000
      0000000000008000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000800000008000000080000000000000000000000000000000000000008000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FF00
      0000FF000000FF000000FF000000FF000000FF000000FFFFFF0080808000FF00
      00008000000000000000FF0000008000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00808080000000
      0000000000008000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008000
      0000800000008000000080000000800000000000000000000000000000008000
      0000800000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00808080008000
      0000FF0000000000000080000000FF00000080808000FFFFFF00FFFFFF00FF00
      0000FF000000FF000000FF000000FF000000FF000000FFFFFF00808080000000
      0000000000008000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008000000000000000000000008000000080000000800000008000
      0000800000008000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FF00
      0000FF000000FF000000FF000000FF000000FF000000FFFFFF00808080000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00808080000000
      0000000000008000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008000000000000000000000000000000000000000000000008000
      0000800000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00808080000000
      00000000000000000000000000000000000080808000FFFFFF00FF000000FF00
      0000FF000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00808080000000
      0000000000008000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008000000000000000000000000000000000000000000000008000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FF000000FF00
      0000FF000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00808080000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00808080000000
      0000000000008000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00808080000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00808080000000
      0000000000000000000000000000000000000000000080000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000800000008080800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00808080000000
      0000000000000000000000000000000000008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080000000
      0000000000000000000000000000000000000000000080808000800000008000
      0000800000008000000080000000800000008000000080000000800000008000
      0000808080000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000500000000100010000000000800200000000000000000000
      000000000000000000000000FFFFFF00FFFFFFFF000000008001F80300000000
      8001973B000000008001B10B000000008001B52B000000008001A00300000000
      80018FE7000000008001FFFF000000008001FFFF000000008001FFFF00000000
      8001FFE7000000008001FFE7000000008001FF81000000008001FF8100000000
      8001FFE700000000FFFFFFE700000000FC07F80FFFFFFFFFF807F00FE1C3000F
      F807F00FC183000FF807F00FC183000FF807F00FC183000FF807F00FC183000F
      F807F00FC183000FF80FF01FC183000FFF7FFFFBC183001FFE3FFFF1C183001F
      FC1FFFE0C183000FFFFFFFFFC1830007FEFF7FFBC1830013FFFFFFFFC183003F
      FDFFDFEFC183007F6FFFFB7FC387FFFFFFFFFFFFE00FFFFFFFFFF9FFEFEFF000
      8001F8FFEFE8F0008001F87FE92FF0008001F83FEEED70008001F81FEEE83000
      8001F80FEEED10008001F807EEED10008001F807EEEF30008001F80FEEED7000
      8001F81FE92FF0008001F83F6FEDF0008001F87F200FF0008001F8FF1FFDF001
      8001F9FF3FFFF003FFFFFFFF7FFFF007FFFFFFFFFFFFFFFF001FFFFFEFFFE7CF
      001BF807E403CFE70011F807E403CFE70000F003C001CFE7001BE003C001CFE7
      0018E00380019EF30018C0030001CC67001180030001C827000388030001CEE7
      0003F8038003CEE70003F803C007E6CF0003F807C00FFEFF0001F80FC03F7CFF
      0001FC1FE0FF01FF0018FE7FF3FFFFFFFFFFFFFFFFFFFFFF001FFFFFFFFF001F
      001BF27FFE73001F0011E73FFCF900040000E73FFCF90004001BE73FFCF90004
      001BE73FFCF90004001BCF9BF9FC0004001BE731ECF90004001BE720E4F90004
      001BE73B00F9001F001BE73BE4F9001F001BF27BEE73001F001BFFFBFFFF001F
      001FBFF3FFFF001F001F8007FFFF001F00000000000000000000000000000000
      000000000000}
  end
  object actlDebug: TActionList
    Images = imglActions
    Left = 432
    Top = 368
    object actDebugRun: TAction
      Category = 'Debug'
      Caption = 'Запустить'
      ImageIndex = 9
      ShortCut = 120
      OnExecute = actDebugRunExecute
      OnUpdate = actDebugRunUpdate
    end
    object actDebugStepIn: TAction
      Category = 'Debug'
      Caption = 'Шаг в'
      ImageIndex = 12
      ShortCut = 118
      OnExecute = actDebugStepInExecute
      OnUpdate = actDebugStepInUpdate
    end
    object actDebugStepOver: TAction
      Category = 'Debug'
      Caption = 'Шаг через'
      ImageIndex = 13
      ShortCut = 119
      OnExecute = actDebugStepOverExecute
      OnUpdate = actDebugStepInUpdate
    end
    object actDebugGotoCursor: TAction
      Category = 'Debug'
      Caption = 'Перейти к курсору'
      ImageIndex = 10
      ShortCut = 115
      OnExecute = actDebugGotoCursorExecute
      OnUpdate = actDebugStepInUpdate
    end
    object actDebugPause: TAction
      Category = 'Debug'
      Caption = 'Пауза'
      ImageIndex = 14
      OnExecute = actDebugPauseExecute
      OnUpdate = actDebugPauseUpdate
    end
    object actProgramReset: TAction
      Category = 'Debug'
      Caption = 'Сброс программы'
      ImageIndex = 8
      ShortCut = 16497
      OnExecute = actProgramResetExecute
      OnUpdate = actProgramResetUpdate
    end
    object actToggleBreakpoint: TAction
      Category = 'Debug'
      Caption = 'Toggle Breakpoint'
      ImageIndex = 5
      ShortCut = 116
      OnExecute = actToggleBreakpointExecute
      OnUpdate = actFunctionButtonUpdate
    end
    object actEvaluate: TAction
      Caption = 'Вычислить'
      Hint = 'Вычислить выражение'
      ImageIndex = 16
      ShortCut = 16499
      OnExecute = actEvaluateExecute
      OnUpdate = actFunctionButtonUpdate
    end
  end
  object pmSpeedReturn: TPopupMenu
    AutoHotkeys = maManual
    Left = 328
    Top = 208
  end
  object Timer: TTimer
    Enabled = False
    OnTimer = TimerTimer
    Left = 528
    Top = 368
  end
  object PopupEval: TSynCompletionProposal
    DefaultType = ctHint
    Position = 0
    NbLinesInWindow = 8
    ClSelect = clHighlight
    ClText = clWindowText
    ClSelectedText = clHighlightText
    ClBackground = clWindow
    AnsiStrings = False
    CaseSensitive = False
    ShrinkList = True
    Width = 262
    BiggestWord = 'CONSTRUCTOR'
    UsePrettyText = True
    EndOfTokenChr = '()[].'
    LimitToMatchedText = False
    ShortCut = 0
    Editor = gsFunctionSynEdit
    Left = 464
    Top = 368
  end
  object FindInTreeDialog: TFindDialog
    Options = [frDown, frDisableMatchCase, frDisableUpDown, frDisableWholeWord]
    OnFind = FindInTreeDialogFind
    Left = 496
    Top = 368
  end
  object pmMessages: TPopupMenu
    Left = 16
    Top = 353
    object N15: TMenuItem
      Action = actClearSearchResult
    end
    object N16: TMenuItem
      Action = actClearErrorResult
    end
  end
  object ActionList3: TActionList
    Left = 16
    Top = 385
    object actClearSearchResult: TAction
      Caption = 'Удальть результаты поиска'
      OnExecute = actClearSearchResultExecute
    end
    object actClearErrorResult: TAction
      Caption = 'Удалить сообщения об ошибках'
      OnExecute = actClearErrorResultExecute
    end
  end
  object dsOwner: TDataSource
    DataSet = ibqOwner
    Left = 104
    Top = 272
  end
  object ibqOwner: TIBQuery
    Transaction = ibtrFunction
    BufferChunks = 1
    CachedUpdates = False
    SQL.Strings = (
      'SELECT'
      '  o.name'
      'FROM'
      '  evt_object o,'
      '  gd_function g'
      'WHERE'
      '  g.id = :id and'
      '  o.id = g.modulecode')
    Left = 168
    Top = 112
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'id'
        ParamType = ptUnknown
      end>
  end
end
