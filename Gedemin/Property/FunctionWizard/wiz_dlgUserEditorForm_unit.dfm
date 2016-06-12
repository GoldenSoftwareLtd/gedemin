inherited dlgUserEditorForm: TdlgUserEditorForm
  Left = 241
  Top = 203
  Width = 664
  Height = 525
  HelpContext = 208
  BorderIcons = [biSystemMenu, biMaximize]
  BorderStyle = bsSizeable
  Caption = 'Свойства пользовательского блока'
  OldCreateOrder = True
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  inherited Panel1: TPanel
    Top = 454
    Width = 646
    inherited pnlRightButtons: TPanel
      Left = 481
      inherited Button2: TButton
        Left = 489
        Default = False
      end
      inherited Button1: TButton
        Left = 569
      end
    end
  end
  inherited PageControl: TPageControl
    Width = 646
    Height = 454
    inherited tsGeneral: TTabSheet
      inherited Label1: TLabel
        Top = 12
      end
      inherited Label2: TLabel
        Top = 56
      end
      object Label3: TLabel [2]
        Left = 8
        Top = 150
        Width = 41
        Height = 13
        Caption = 'Скрипт:'
      end
      object Label4: TLabel [3]
        Left = 8
        Top = 351
        Width = 100
        Height = 26
        Anchors = [akLeft, akBottom]
        Caption = 'Зарезервировнные имена переменных:'
        WordWrap = True
      end
      inherited cbName: TComboBox
        Left = 112
        Width = 519
      end
      inherited mDescription: TMemo
        Left = 112
        Width = 519
        TabOrder = 2
      end
      inherited eLocalName: TEdit
        Left = 112
        Width = 519
        TabOrder = 1
      end
      object Panel2: TPanel
        Left = 112
        Top = 150
        Width = 517
        Height = 194
        Anchors = [akLeft, akTop, akRight, akBottom]
        BevelOuter = bvNone
        TabOrder = 3
        object seScript: TSynEdit
          Left = 0
          Top = 28
          Width = 517
          Height = 166
          Cursor = crIBeam
          Align = alClient
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Courier New'
          Font.Style = []
          ParentColor = False
          ParentFont = False
          TabOrder = 0
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
        end
        object TBDock1: TTBDock
          Left = 0
          Top = 0
          Width = 517
          Height = 28
          BoundLines = [blTop, blBottom, blLeft, blRight]
          object tbtMain: TTBToolbar
            Left = 0
            Top = 0
            Caption = 'tbtMain'
            DockMode = dmCannotFloat
            DragHandleStyle = dhNone
            FullSize = True
            Images = dmImages.il16x16
            TabOrder = 0
            object TBItem3: TTBItem
              Action = actAddFunction
              DisplayMode = nbdmImageAndText
            end
            object tbiAddAccount: TTBItem
              Caption = 'Добавить счёт'
              DisplayMode = nbdmImageAndText
              ImageIndex = 216
              OnClick = tbiAddAccountClick
            end
            object tbiAddAnalitics: TTBItem
              Caption = 'Добавить аналитику'
              DisplayMode = nbdmImageAndText
              ImageIndex = 210
              OnClick = tbiAddAnaliticsClick
            end
            object TBItem4: TTBItem
              Action = actAddVar
              DisplayMode = nbdmImageAndText
            end
          end
        end
      end
      object lbReservedVars: TListBox
        Left = 112
        Top = 351
        Width = 421
        Height = 75
        Anchors = [akLeft, akRight, akBottom]
        ItemHeight = 13
        TabOrder = 4
      end
      object Button3: TButton
        Left = 540
        Top = 351
        Width = 89
        Height = 21
        Action = actReserveVar
        Anchors = [akRight, akBottom]
        TabOrder = 5
      end
      object Button5: TButton
        Left = 540
        Top = 399
        Width = 89
        Height = 21
        Action = actReleaseVar
        Anchors = [akRight, akBottom]
        TabOrder = 6
      end
      object Button6: TButton
        Left = 540
        Top = 375
        Width = 89
        Height = 21
        Action = actEditReservedVar
        Anchors = [akRight, akBottom]
        TabOrder = 7
      end
    end
  end
  inherited ActionList: TActionList
    Images = dmImages.il16x16
    object actAddFunction: TAction
      Caption = 'Добавить функцию'
      Hint = 'Добавить функцию'
      ImageIndex = 137
      OnExecute = actAddFunctionExecute
    end
    object actAddAccount: TAction
      Caption = 'Добавить счёт'
      Hint = 'Добавить счёт'
      ImageIndex = 216
      OnExecute = actAddAccountExecute
    end
    object actAddAnalytics: TAction
      Caption = 'Добавить аналитику'
      Hint = 'Добавить аналитику'
      ImageIndex = 210
      OnExecute = actAddAnalyticsExecute
    end
    object actAddVar: TAction
      Caption = 'Добавить переменную'
      Hint = 'Добавить переменную'
      ImageIndex = 135
      OnExecute = actAddVarExecute
    end
    object actReserveVar: TAction
      Caption = 'Добавить'
      OnExecute = actReserveVarExecute
    end
    object actReleaseVar: TAction
      Caption = 'Удалить'
      OnExecute = actReleaseVarExecute
      OnUpdate = actReleaseVarUpdate
    end
    object actEditReservedVar: TAction
      Caption = 'Редактировать'
      OnExecute = actEditReservedVarExecute
      OnUpdate = actReleaseVarUpdate
    end
  end
  object SynVBScriptSyn: TSynVBScriptSyn
    Left = 32
    Top = 184
  end
  object SynCompletionProposal: TSynCompletionProposal
    DefaultType = ctCode
    OnExecute = SynCompletionProposalExecute
    Position = 0
    NbLinesInWindow = 8
    ClSelect = clHighlight
    ClText = clWindowText
    ClSelectedText = clHighlightText
    ClBackground = clWindow
    AnsiStrings = True
    CaseSensitive = False
    ShrinkList = True
    Width = 262
    BiggestWord = 'property'
    UsePrettyText = True
    UseInsertList = True
    EndOfTokenChr = '()[].,=<>-+&"'
    LimitToMatchedText = False
    TriggerChars = '.'
    ShortCut = 16416
    Editor = seScript
    Left = 32
    Top = 216
  end
end
