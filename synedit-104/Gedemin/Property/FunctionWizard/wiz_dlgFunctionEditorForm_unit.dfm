inherited dlgFunctionEditForm: TdlgFunctionEditForm
  Left = 316
  Top = 190
  HelpContext = 201
  BorderIcons = [biSystemMenu, biMaximize]
  BorderStyle = bsSingle
  Caption = 'Свойства процедуры'
  ClientHeight = 373
  ClientWidth = 442
  OldCreateOrder = True
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  inherited Panel1: TPanel
    Top = 343
    Width = 442
    inherited Button1: TButton
      Left = 364
    end
    inherited Button2: TButton
      Left = 284
      Default = False
    end
  end
  inherited PageControl: TPageControl
    Width = 442
    Height = 343
    OnChange = PageControlChange
    OnChanging = PageControlChanging
    inherited tsGeneral: TTabSheet
      inherited Label2: TLabel
        Top = 76
      end
      object Label3: TLabel [2]
        Left = 8
        Top = 172
        Width = 62
        Height = 13
        Caption = 'Параметры:'
      end
      inherited cbName: TComboBox
        Width = 331
      end
      inherited mDescription: TMemo
        Top = 72
        Width = 331
        TabOrder = 3
      end
      inherited eLocalName: TEdit
        Width = 331
        TabOrder = 1
      end
      object cbReturnResult: TCheckBox
        Left = 8
        Top = 52
        Width = 257
        Height = 17
        Caption = 'Возвращает результат'
        TabOrder = 2
      end
      object lbParams: TListBox
        Left = 96
        Top = 172
        Width = 249
        Height = 137
        ItemHeight = 13
        TabOrder = 4
        OnDblClick = lbParamsDblClick
      end
      object bAddParam: TButton
        Left = 352
        Top = 172
        Width = 75
        Height = 25
        Action = actAddParam
        TabOrder = 5
      end
      object bDeleteParam: TButton
        Left = 352
        Top = 284
        Width = 75
        Height = 25
        Action = actDeleteParam
        TabOrder = 9
      end
      object bUp: TButton
        Left = 352
        Top = 224
        Width = 75
        Height = 25
        Action = actUp
        TabOrder = 7
      end
      object bDown: TButton
        Left = 352
        Top = 250
        Width = 75
        Height = 25
        Action = actDown
        TabOrder = 8
      end
      object Button3: TButton
        Left = 352
        Top = 198
        Width = 75
        Height = 25
        Action = actEditParam
        TabOrder = 6
      end
    end
    object tsParams: TTabSheet
      BorderWidth = 5
      Caption = 'Свойства параметров'
      ImageIndex = 1
      object sbParams: TScrollBox
        Left = 0
        Top = 39
        Width = 424
        Height = 266
        Align = alClient
        BorderStyle = bsNone
        TabOrder = 0
      end
      object pnlCaption: TPanel
        Left = 0
        Top = 0
        Width = 424
        Height = 39
        Align = alTop
        BevelInner = bvRaised
        BevelOuter = bvLowered
        TabOrder = 1
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
    object tsInitScript: TTabSheet
      Caption = 'Скрипт инициализации'
      ImageIndex = 2
      object seInitScript: TSynEdit
        Left = 0
        Top = 0
        Width = 434
        Height = 288
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
        Lines.Strings = (
          'seInitScript')
      end
      object Panel2: TPanel
        Left = 0
        Top = 288
        Width = 434
        Height = 27
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 1
        object Button5: TButton
          Left = 328
          Top = 4
          Width = 98
          Height = 21
          Action = actDefaultInit
          Anchors = [akRight, akBottom]
          TabOrder = 0
        end
      end
    end
    object tsFinalScript: TTabSheet
      Caption = 'Скрипт финализации'
      ImageIndex = 3
      object seFinalScript: TSynEdit
        Left = 0
        Top = 0
        Width = 434
        Height = 288
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
        Lines.Strings = (
          'seInitScript')
      end
      object Panel3: TPanel
        Left = 0
        Top = 288
        Width = 434
        Height = 27
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 1
        object Button6: TButton
          Left = 328
          Top = 4
          Width = 98
          Height = 21
          Action = actDefaultFin
          Anchors = [akRight, akBottom]
          TabOrder = 0
        end
      end
    end
  end
  inherited ActionList: TActionList
    Left = 16
    Top = 120
    object actAddParam: TAction [2]
      Caption = 'Добавить'
      OnExecute = actAddParamExecute
    end
    object actDeleteParam: TAction [3]
      Caption = 'Удалить'
      OnExecute = actDeleteParamExecute
      OnUpdate = actDeleteParamUpdate
    end
    object actUp: TAction [4]
      Caption = 'Вверх'
      OnExecute = actUpExecute
      OnUpdate = actDeleteParamUpdate
    end
    object actDown: TAction [5]
      Caption = 'Вниз'
      OnExecute = actDownExecute
      OnUpdate = actDeleteParamUpdate
    end
    object actEditParam: TAction [6]
      Caption = 'Изменить'
      OnExecute = actEditParamExecute
      OnUpdate = actDeleteParamUpdate
    end
    object actDefaultInit: TAction
      Caption = 'По умолчанию'
      OnExecute = actDefaultInitExecute
    end
    object actDefaultFin: TAction
      Caption = 'По умолчанию'
      OnExecute = actDefaultFinExecute
    end
  end
  object SynVBScriptSyn: TSynVBScriptSyn
    DefaultFilter = 'VBScript Files (*.vbs)|*.vbs'
    Left = 220
    Top = 80
  end
end
