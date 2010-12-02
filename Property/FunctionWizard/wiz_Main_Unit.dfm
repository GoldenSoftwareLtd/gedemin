object dlgFunctionWisard: TdlgFunctionWisard
  Left = 222
  Top = 172
  Width = 668
  Height = 462
  HelpContext = 204
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Конструктор функции'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  WindowState = wsMaximized
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object TBDock1: TTBDock
    Left = 0
    Top = 0
    Width = 652
    Height = 79
    object TBToolWindow1: TTBToolWindow
      Left = 0
      Top = 25
      Caption = 'TBToolWindow1'
      ClientAreaHeight = 50
      ClientAreaWidth = 642
      DockMode = dmCannotFloat
      DockPos = 560
      DockRow = 1
      FullSize = True
      Stretch = True
      TabOrder = 0
      object PageControl: TSuperPageControl
        Left = 0
        Top = 0
        Width = 642
        Height = 50
        BorderStyle = bsNone
        TabsVisible = True
        ActivePage = tsStandart
        Align = alClient
        TabHeight = 23
        TabOrder = 0
        OnChange = PageControlChange
        object tsStandart: TSuperTabSheet
          BorderWidth = 2
          Caption = 'Стандартные'
          object tbtStandart: TTBToolbar
            Left = 0
            Top = 0
            Width = 638
            Height = 22
            Align = alTop
            Caption = 'tbtStandart'
            DockPos = 0
            DockRow = 1
            FullSize = True
            Images = dmImages.il16x16
            ParentShowHint = False
            ShowHint = True
            TabOrder = 0
            object TBItem1: TTBItem
              Action = actArrow
            end
            object TBItem3: TTBItem
              Action = actSub
              AutoCheck = True
              DisplayMode = nbdmTextOnly
            end
            object TBItem6: TTBItem
              Action = actVar
              AutoCheck = True
            end
            object TBItem5: TTBItem
              Action = actIf
              AutoCheck = True
            end
            object TBItem7: TTBItem
              Action = actElse
              AutoCheck = True
            end
            object TBItem22: TTBItem
              Action = actWhileCycle
            end
            object TBItem23: TTBItem
              Action = actForCycle
            end
            object TBItem24: TTBItem
              Action = actSelect
            end
            object TBItem25: TTBItem
              Action = actCase
            end
            object TBItem44: TTBItem
              Action = actCaseElse
            end
          end
        end
        object tsAdditional: TSuperTabSheet
          BorderWidth = 2
          Caption = 'Дополнительные'
          ImageIndex = 1
          object tbtAdditional: TTBToolbar
            Left = 0
            Top = 0
            Width = 638
            Height = 22
            Align = alTop
            Caption = 'tbtAdditional'
            Images = dmImages.il16x16
            TabOrder = 0
            object TBItem2: TTBItem
              Action = actArrow
            end
            object TBItem9: TTBItem
              Action = actAccountCicle
              AutoCheck = True
              DisplayMode = nbdmTextOnly
            end
            object TBItem11: TTBItem
              Action = actEntryCycle
            end
            object TBItem27: TTBItem
              Action = actSQLCycle
            end
            object TBItem29: TTBItem
              Action = actSQL
            end
            object TBItem10: TTBItem
              Action = actEntry
              AutoCheck = True
              DisplayMode = nbdmTextOnly
            end
            object TBItem4: TTBItem
              Action = actUser
              AutoCheck = True
              DisplayMode = nbdmTextOnly
            end
            object TBItem21: TTBItem
              Action = actTaxExpr
              Visible = False
            end
            object TBItem13: TTBItem
              Action = actTrEntry
              Visible = False
            end
            object TBItem12: TTBItem
              Action = actTrEntryPosition
              Visible = False
            end
            object TBItem28: TTBItem
              Action = actBalanceOffTrPos
              Visible = False
            end
            object TBItem26: TTBItem
              Action = actTransaction
              Visible = False
            end
          end
        end
      end
    end
    object TBToolbar1: TTBToolbar
      Left = 0
      Top = 0
      Caption = 'TBToolbar1'
      CloseButton = False
      FullSize = True
      Images = dmImages.il16x16
      MenuBar = True
      ProcessShortCuts = True
      ShrinkMode = tbsmWrap
      TabOrder = 1
      object TBSubmenuItem1: TTBSubmenuItem
        Caption = 'Редактировать'
        object TBItem41: TTBItem
          Action = actProperty
        end
        object TBSeparatorItem10: TTBSeparatorItem
        end
        object TBItem42: TTBItem
          Action = actDelete
        end
        object TBSeparatorItem9: TTBSeparatorItem
        end
        object TBItem40: TTBItem
          Action = actCopy
        end
        object TBItem38: TTBItem
          Action = actCut
        end
        object TBItem39: TTBItem
          Action = actPast
        end
      end
      object TBSubmenuItem2: TTBSubmenuItem
        Caption = 'Выполнение'
        Images = dmImages.imglActions
        object TBItem32: TTBItem
          Action = actRun
          ImageIndex = 9
          Images = dmImages.imglActions
        end
        object TBItem31: TTBItem
          Action = actStep
          ImageIndex = 12
          Images = dmImages.imglActions
        end
        object TBItem35: TTBItem
          Action = actStepOver
          ImageIndex = 13
          Images = dmImages.imglActions
        end
        object TBItem34: TTBItem
          Action = actRunToCursor
          ImageIndex = 10
          Images = dmImages.imglActions
        end
        object TBSeparatorItem5: TTBSeparatorItem
        end
        object TBItem33: TTBItem
          Action = actToggleBreakPoint
          ImageIndex = 5
          Images = dmImages.imglActions
        end
        object TBSeparatorItem7: TTBSeparatorItem
        end
        object TBItem30: TTBItem
          Action = actEval
          ImageIndex = 16
          Images = dmImages.imglActions
        end
        object TBSeparatorItem6: TTBSeparatorItem
        end
        object TBItem36: TTBItem
          Action = actReset
          ImageIndex = 8
          Images = dmImages.imglActions
        end
      end
      object TBSubmenuItem3: TTBSubmenuItem
        Caption = 'Справка'
        object TBItem37: TTBItem
          Action = actHelp
          ImageIndex = 13
        end
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 392
    Width = 652
    Height = 32
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object Panel4: TPanel
      Left = 467
      Top = 0
      Width = 185
      Height = 32
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
      object Button2: TButton
        Left = 26
        Top = 6
        Width = 75
        Height = 21
        Action = actOk
        Anchors = [akRight, akBottom]
        TabOrder = 0
      end
      object Button1: TButton
        Left = 107
        Top = 6
        Width = 75
        Height = 21
        Action = actCancel
        Anchors = [akRight, akBottom]
        TabOrder = 1
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 79
    Width = 652
    Height = 313
    Align = alClient
    BevelOuter = bvNone
    Caption = 'Panel2'
    TabOrder = 2
    object Splitter1: TSplitter
      Left = 297
      Top = 0
      Width = 3
      Height = 313
      Cursor = crHSplit
    end
    object Panel3: TPanel
      Left = 300
      Top = 0
      Width = 352
      Height = 313
      Align = alClient
      BevelOuter = bvLowered
      Caption = 'Panel3'
      TabOrder = 0
      object TBDock2: TTBDock
        Left = 1
        Top = 1
        Width = 350
        Height = 26
        object TBToolbar2: TTBToolbar
          Left = 0
          Top = 0
          Caption = 'TBToolbar2'
          DockMode = dmCannotFloat
          DockPos = 0
          DockRow = 1
          FullSize = True
          Images = dmImages.il16x16
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
          object TBItem8: TTBItem
            Action = actGenerate
          end
          object TBSeparatorItem8: TTBSeparatorItem
          end
          object TBItem43: TTBItem
            Action = actFind
          end
          object TBSeparatorItem1: TTBSeparatorItem
          end
          object TBItem14: TTBItem
            Action = actRun
            ImageIndex = 9
            Images = dmImages.imglActions
          end
          object TBItem15: TTBItem
            Action = actStep
            ImageIndex = 12
            Images = dmImages.imglActions
          end
          object TBItem16: TTBItem
            Action = actStepOver
            ImageIndex = 13
            Images = dmImages.imglActions
          end
          object TBItem17: TTBItem
            Action = actRunToCursor
            ImageIndex = 10
            Images = dmImages.imglActions
          end
          object TBSeparatorItem4: TTBSeparatorItem
          end
          object TBItem20: TTBItem
            Action = actToggleBreakPoint
            ImageIndex = 5
            Images = dmImages.imglActions
            ShortCut = 32884
          end
          object TBSeparatorItem2: TTBSeparatorItem
          end
          object TBItem19: TTBItem
            Action = actEval
            ImageIndex = 16
            Images = dmImages.imglActions
          end
          object TBSeparatorItem3: TTBSeparatorItem
          end
          object TBItem18: TTBItem
            Action = actReset
            ImageIndex = 8
            Images = dmImages.imglActions
          end
        end
      end
      object seScript: TSynEdit
        Left = 1
        Top = 27
        Width = 350
        Height = 285
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
        BorderStyle = bsNone
        Gutter.Font.Charset = DEFAULT_CHARSET
        Gutter.Font.Color = clWindowText
        Gutter.Font.Height = -11
        Gutter.Font.Name = 'Terminal'
        Gutter.Font.Style = []
        Highlighter = SynVBScriptSyn
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
          'seScript')
        ReadOnly = True
        OnGutterClick = seScriptGutterClick
        OnSpecialLineColors = seScriptSpecialLineColors
        OnPaintTransient = seScriptPaintTransient
      end
    end
    object Panel5: TPanel
      Left = 0
      Top = 0
      Width = 297
      Height = 313
      Align = alLeft
      BevelOuter = bvLowered
      Caption = 'Panel5'
      TabOrder = 1
      object ScrollBox1: TScrollBox
        Left = 1
        Top = 1
        Width = 295
        Height = 311
        Align = alClient
        BorderStyle = bsNone
        Constraints.MinHeight = 150
        Constraints.MinWidth = 150
        Color = clGray
        ParentColor = False
        TabOrder = 0
      end
    end
  end
  object SynVBScriptSyn: TSynVBScriptSyn
    Left = 480
    Top = 184
  end
  object ActionList: TActionList
    Images = dmImages.il16x16
    Left = 384
    Top = 128
    object actGenerate: TAction
      Caption = 'actGenerate'
      Hint = 'Сгенерировать код'
      ImageIndex = 236
      ShortCut = 116
      OnExecute = actGenerateExecute
      OnUpdate = actGenerateUpdate
    end
    object actOk: TAction
      Caption = 'Ok'
      Hint = 'Выйти с сохранением измнений'
      ImageIndex = 25
      OnExecute = actOkExecute
      OnUpdate = actCancelUpdate
    end
    object actCancel: TAction
      Caption = 'Отмена'
      Hint = 'Выйти без сохранения изменений'
      ImageIndex = 26
      OnExecute = actCancelExecute
      OnUpdate = actCancelUpdate
    end
    object actArrow: TAction
      Category = 'Commands'
      Caption = 'Стрелка'
      ImageIndex = 241
      OnExecute = actArrowExecute
      OnUpdate = actArrowUpdate
    end
    object actSub: TAction
      Category = 'Commands'
      Caption = 'Процедура'
      OnExecute = actSubExecute
      OnUpdate = actSubUpdate
    end
    object actVar: TAction
      Category = 'Commands'
      Caption = 'Переменная'
      OnExecute = actVarExecute
      OnUpdate = actVarUpdate
    end
    object actIf: TAction
      Category = 'Commands'
      Caption = 'Условие'
      OnExecute = actIfExecute
      OnUpdate = actIfUpdate
    end
    object actElse: TAction
      Category = 'Commands'
      Caption = 'Иначе'
      OnExecute = actElseExecute
      OnUpdate = actElseUpdate
    end
    object actAccountCicle: TAction
      Category = 'Commands'
      Caption = 'Цикл по счету'
      OnExecute = actAccountCicleExecute
      OnUpdate = actAccountCicleUpdate
    end
    object actEntry: TAction
      Category = 'Commands'
      Caption = 'Проводка'
      OnExecute = actEntryExecute
      OnUpdate = actEntryUpdate
    end
    object actUser: TAction
      Category = 'Commands'
      Caption = 'Пользовательский'
      OnExecute = actUserExecute
      OnUpdate = actUserUpdate
    end
    object actHelp: TAction
      Caption = 'Справка'
      OnExecute = actHelpExecute
    end
    object actEntryCycle: TAction
      Category = 'Commands'
      Caption = 'Цикл по проводкам'
      OnExecute = actEntryCycleExecute
      OnUpdate = actEntryCycleUpdate
    end
    object actTaxExpr: TAction
      Category = 'Commands'
      Caption = 'Позиция отчета'
      OnExecute = actTaxExprExecute
      OnUpdate = actTaxExprUpdate
    end
    object actRun: TAction
      Category = 'Debug'
      Caption = 'Запустить'
      Hint = 'Запустить'
      ShortCut = 120
      OnExecute = actRunExecute
      OnUpdate = actRunUpdate
    end
    object actStep: TAction
      Category = 'Debug'
      Caption = 'Шаг в'
      Hint = 'Шаг в'
      ShortCut = 118
      OnExecute = actStepExecute
      OnUpdate = actRunUpdate
    end
    object actStepOver: TAction
      Category = 'Debug'
      Caption = 'Шаг через'
      Hint = 'Шаг через'
      ShortCut = 119
      OnExecute = actStepOverExecute
      OnUpdate = actRunUpdate
    end
    object actRunToCursor: TAction
      Category = 'Debug'
      Caption = 'Перейти к курсору'
      Hint = 'Перейти к курсору'
      ShortCut = 115
      OnExecute = actRunToCursorExecute
      OnUpdate = actRunUpdate
    end
    object actReset: TAction
      Category = 'Debug'
      Caption = 'Сброс'
      Hint = 'Сброс программы'
      ShortCut = 16497
      OnExecute = actResetExecute
      OnUpdate = actRunUpdate
    end
    object actEval: TAction
      Category = 'Debug'
      Caption = 'Вычислить'
      Hint = 'Вычислить'
      ShortCut = 16502
      OnExecute = actEvalExecute
    end
    object actToggleBreakPoint: TAction
      Category = 'Debug'
      Caption = 'Установить/снять точку остановки'
      ShortCut = 116
      OnExecute = actToggleBreakPointExecute
    end
    object actTrEntryPosition: TAction
      Category = 'Commands'
      Caption = 'Позиция типовой проводки'
      OnExecute = actTrEntryPositionExecute
      OnUpdate = actTrEntryPositionUpdate
    end
    object actTrEntry: TAction
      Category = 'Commands'
      Caption = 'Типовая проводка'
      OnExecute = actTrEntryExecute
      OnUpdate = actTrEntryUpdate
    end
    object actWhileCycle: TAction
      Category = 'Commands'
      Caption = 'Цикл WHILE'
      OnExecute = actWhileCycleExecute
      OnUpdate = actWhileCycleUpdate
    end
    object actForCycle: TAction
      Category = 'Commands'
      Caption = 'Цикл FOR'
      OnExecute = actForCycleExecute
      OnUpdate = actForCycleUpdate
    end
    object actSelect: TAction
      Category = 'Commands'
      Caption = 'Выбор из'
      OnExecute = actSelectExecute
      OnUpdate = actSelectUpdate
    end
    object actCase: TAction
      Category = 'Commands'
      Caption = 'Выбор'
      OnExecute = actCaseExecute
      OnUpdate = actCaseUpdate
    end
    object actCaseElse: TAction
      Category = 'Commands'
      Caption = 'Выбор иначе'
      OnExecute = actCaseElseExecute
      OnUpdate = actCaseElseUpdate
    end
    object actTransaction: TAction
      Category = 'Commands'
      Caption = 'Типовая операция'
      OnExecute = actTransactionExecute
      OnUpdate = actTransactionUpdate
    end
    object actSQLCycle: TAction
      Category = 'Commands'
      Caption = 'SQL цикл'
      OnExecute = actSQLCycleExecute
      OnUpdate = actSQLCycleUpdate
    end
    object actBalanceOffTrPos: TAction
      Category = 'Commands'
      Caption = 'Забалансовая проводка'
      OnExecute = actBalanceOffTrPosExecute
      OnUpdate = actBalanceOffTrPosUpdate
    end
    object actSQL: TAction
      Category = 'Commands'
      Caption = 'SQL запрос'
      OnExecute = actSQLExecute
      OnUpdate = actSQLUpdate
    end
    object actCopy: TAction
      Category = 'ClipBord'
      Caption = 'Копировать'
      ImageIndex = 10
      OnExecute = actCopyExecute
      OnUpdate = actCopyUpdate
    end
    object TAction
      Category = 'Debug'
    end
    object actCut: TAction
      Category = 'ClipBord'
      Caption = 'Вырезать'
      ImageIndex = 9
      OnExecute = actCutExecute
      OnUpdate = actCutUpdate
    end
    object actPast: TAction
      Category = 'ClipBord'
      Caption = 'Вставить'
      ImageIndex = 11
      OnExecute = actPastExecute
      OnUpdate = actPastUpdate
    end
    object actProperty: TAction
      Category = 'ClipBord'
      Caption = 'Свойства...'
      ImageIndex = 1
      OnExecute = actPropertyExecute
      OnUpdate = actPropertyUpdate
    end
    object actDelete: TAction
      Category = 'ClipBord'
      Caption = 'Удалить'
      ImageIndex = 2
      OnExecute = actDeleteExecute
      OnUpdate = actDeleteUpdate
    end
    object actFind: TAction
      Caption = 'Поиск'
      Hint = 'Поиск'
      ImageIndex = 23
      ShortCut = 16454
      OnExecute = actFindExecute
    end
    object actFindNext: TAction
      Caption = 'Найти далее'
      ImageIndex = 24
      ShortCut = 114
      OnExecute = actFindNextExecute
    end
  end
end
