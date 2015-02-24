object ExpressionEditorForm: TExpressionEditorForm
  Left = 415
  Top = 266
  Width = 703
  Height = 440
  BorderWidth = 5
  Caption = 'Редактор выражений'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object TBDock: TTBDock
    Left = 0
    Top = 0
    Width = 677
    Height = 53
    BoundLines = [blTop, blBottom, blLeft, blRight]
    object tbtMain: TTBToolbar
      Left = 0
      Top = 0
      Caption = 'tbtMain'
      DockMode = dmCannotFloatOrChangeDocks
      DockPos = 0
      Images = dmImages.il16x16
      ShrinkMode = tbsmWrap
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
    object TBToolbar1: TTBToolbar
      Left = 0
      Top = 26
      Caption = 'TBToolbar1'
      DockMode = dmCannotFloatOrChangeDocks
      DockPos = 0
      DockRow = 1
      TabOrder = 1
      object _TBItem13: TTBItem
        Action = Action1
      end
      object _TBItem12: TTBItem
        Action = Action2
      end
      object _TBItem11: TTBItem
        Action = Action3
      end
      object _TBItem10: TTBItem
        Action = Action4
      end
      object _TBItem9: TTBItem
        Action = Action5
      end
      object _TBItem8: TTBItem
        Action = Action6
      end
      object _TBItem7: TTBItem
        Action = Action7
      end
      object _TBItem6: TTBItem
        Action = Action8
      end
      object _TBSeparatorItem1: TTBSeparatorItem
      end
      object _TBItem18: TTBItem
        Action = Action9
      end
      object _TBItem17: TTBItem
        Action = Action10
      end
      object _TBItem16: TTBItem
        Action = Action11
      end
      object _TBItem15: TTBItem
        Action = Action12
      end
      object _TBItem14: TTBItem
        Action = Action13
      end
      object _TBItem5: TTBItem
        Action = Action14
      end
      object _TBItem2: TTBItem
        Action = Action15
      end
      object _TBItem1: TTBItem
        Action = Action16
      end
      object _TBItem20: TTBItem
        Action = Action17
      end
      object _TBItem19: TTBItem
        Action = Action18
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 363
    Width = 677
    Height = 29
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object Button1: TButton
      Left = 602
      Top = 7
      Width = 75
      Height = 21
      Action = actCancel
      Anchors = [akRight, akBottom]
      TabOrder = 0
    end
    object Button2: TButton
      Left = 522
      Top = 7
      Width = 75
      Height = 21
      Action = actOk
      Anchors = [akRight, akBottom]
      Default = True
      TabOrder = 1
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 53
    Width = 677
    Height = 310
    Align = alClient
    BevelInner = bvLowered
    BevelOuter = bvNone
    FullRepaint = False
    TabOrder = 2
    object mExpression: TMemo
      Left = 1
      Top = 1
      Width = 675
      Height = 308
      Align = alClient
      BorderStyle = bsNone
      Lines.Strings = (
        'mExpression')
      TabOrder = 0
    end
  end
  object ActionList: TActionList
    Images = dmImages.il16x16
    Left = 48
    Top = 138
    object actOk: TAction
      Caption = 'Ok'
      OnExecute = actOkExecute
    end
    object actCancel: TAction
      Caption = 'Отмена'
      ShortCut = 27
      OnExecute = actCancelExecute
    end
    object actAddFunction: TAction
      Caption = 'Добавить функцию'
      ImageIndex = 137
      OnExecute = actAddFunctionExecute
    end
    object actAddAccount: TAction
      Caption = 'Добавить счёт'
      ImageIndex = 216
      OnExecute = actAddAccountExecute
    end
    object actAddAnalytics: TAction
      Caption = 'Добавить аналитику'
      ImageIndex = 210
      OnExecute = actAddAnalyticsExecute
    end
    object actAddVar: TAction
      Caption = 'Добавить переменную'
      ImageIndex = 135
      OnExecute = actAddVarExecute
    end
    object Action1: TAction
      Caption = '+'
      OnExecute = Action1Execute
    end
    object Action2: TAction
      Caption = '-'
      OnExecute = Action1Execute
    end
    object Action3: TAction
      Caption = '*'
      OnExecute = Action1Execute
    end
    object Action4: TAction
      Caption = '/'
      OnExecute = Action1Execute
    end
    object Action5: TAction
      Caption = '='
      OnExecute = Action1Execute
    end
    object Action6: TAction
      Caption = '('
      OnExecute = Action1Execute
    end
    object Action7: TAction
      Caption = ')'
      OnExecute = Action1Execute
    end
    object Action8: TAction
      Caption = '"'
      OnExecute = Action1Execute
    end
    object Action9: TAction
      Caption = '1'
      OnExecute = Action1Execute
    end
    object Action10: TAction
      Caption = '2'
      OnExecute = Action1Execute
    end
    object Action11: TAction
      Caption = '3'
      OnExecute = Action1Execute
    end
    object Action12: TAction
      Caption = '4'
      OnExecute = Action1Execute
    end
    object Action13: TAction
      Caption = '5'
      OnExecute = Action1Execute
    end
    object Action14: TAction
      Caption = '6'
      OnExecute = Action1Execute
    end
    object Action15: TAction
      Caption = '7'
      OnExecute = Action1Execute
    end
    object Action16: TAction
      Caption = '8'
      OnExecute = Action1Execute
    end
    object Action17: TAction
      Caption = '9'
      OnExecute = Action1Execute
    end
    object Action18: TAction
      Caption = '0'
      OnExecute = Action1Execute
    end
  end
end
