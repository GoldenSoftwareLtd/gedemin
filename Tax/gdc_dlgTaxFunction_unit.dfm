inherited gdc_dlgTaxFunction: Tgdc_dlgTaxFunction
  Left = 327
  Top = 190
  Width = 498
  Height = 459
  HelpContext = 11
  BorderStyle = bsSizeable
  BorderWidth = 5
  Caption = 'Показатель отчета бухгалтерии '
  Constraints.MinHeight = 458
  Constraints.MinWidth = 477
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 0
    Top = 400
    Anchors = [akLeft, akBottom]
    TabOrder = 3
  end
  inherited btnNew: TButton
    Left = 72
    Top = 400
    Anchors = [akLeft, akBottom]
    TabOrder = 4
  end
  inherited btnOK: TButton
    Left = 340
    Top = 400
    Width = 67
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    TabOrder = 1
  end
  inherited btnCancel: TButton
    Left = 412
    Top = 400
    Width = 67
    Anchors = [akRight, akBottom]
    TabOrder = 2
  end
  inherited btnHelp: TButton
    Left = 144
    Top = 400
    Anchors = [akLeft, akBottom]
    TabOrder = 5
  end
  object pnlMain: TPanel [5]
    Left = 0
    Top = 0
    Width = 480
    Height = 389
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 0
    object lblFText: TLabel
      Left = 8
      Top = 54
      Width = 104
      Height = 13
      Caption = 'Расчетная функция:'
    end
    object lblFName: TLabel
      Left = 8
      Top = 8
      Width = 139
      Height = 13
      Caption = 'Наименование показателя:'
      Color = clBtnFace
      ParentColor = False
      Transparent = True
    end
    object lblDescription: TLabel
      Left = 8
      Top = 263
      Width = 53
      Height = 13
      Anchors = [akLeft, akBottom]
      Caption = 'Описание:'
    end
    object edFName: TDBEdit
      Left = 8
      Top = 27
      Width = 463
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      DataField = 'name'
      DataSource = dsgdcBase
      TabOrder = 0
    end
    object mmDescription: TDBMemo
      Left = 8
      Top = 282
      Width = 463
      Height = 73
      Anchors = [akLeft, akRight, akBottom]
      DataField = 'description'
      DataSource = dsgdcBase
      TabOrder = 2
    end
    object pnlTaxFunction: TPanel
      Left = 9
      Top = 71
      Width = 461
      Height = 182
      Anchors = [akLeft, akTop, akRight, akBottom]
      BevelOuter = bvNone
      TabOrder = 1
      object mmTaxFunction: TDBMemo
        Left = 0
        Top = 28
        Width = 461
        Height = 154
        Align = alClient
        DataField = 'taxfunction'
        DataSource = dsgdcBase
        ScrollBars = ssVertical
        TabOrder = 0
        OnChange = mmTaxFunctionChange
      end
      object tbdFunction: TTBDock
        Left = 0
        Top = 0
        Width = 461
        Height = 28
        BoundLines = [blTop, blBottom, blLeft, blRight]
        object TBToolbar1: TTBToolbar
          Left = 0
          Top = 0
          Align = alLeft
          DockMode = dmCannotFloatOrChangeDocks
          DragHandleStyle = dhNone
          FullSize = True
          Images = dmImages.il16x16
          Resizable = False
          ShowCaption = False
          TabOrder = 0
          object TBItem4: TTBItem
            Action = actAddFunction
            DisplayMode = nbdmImageAndText
            ImageIndex = 137
          end
          object TBItem3: TTBItem
            Action = actAddAccount
            Caption = 'Добавить счет  '
            DisplayMode = nbdmImageAndText
            ImageIndex = 216
          end
          object TBItem2: TTBItem
            Action = actAddAnalytics
            DisplayMode = nbdmImageAndText
            ImageIndex = 210
          end
          object TBItem1: TTBItem
            Action = actTestFunction
            Caption = 'Тест  '
            DisplayMode = nbdmImageAndText
            ImageIndex = 236
          end
        end
      end
    end
    object cbTest: TCheckBox
      Left = 10
      Top = 364
      Width = 176
      Height = 17
      Anchors = [akLeft, akBottom]
      Caption = 'Тестировать при сохранении'
      Checked = True
      State = cbChecked
      TabOrder = 3
    end
  end
  inherited alBase: TActionList
    Left = 278
    Top = 391
    object actAddFunction: TAction
      Category = 'Function'
      Caption = 'Добавить функцию'
      Hint = 'Добавить функцию'
      ShortCut = 16454
      OnExecute = actAddFunctionExecute
    end
    object actTestFunction: TAction
      Category = 'Function'
      Caption = 'Тест'
      Hint = 'Тест'
      ShortCut = 16468
      OnExecute = actTestFunctionExecute
    end
    object actAddAccount: TAction
      Category = 'Function'
      Caption = 'Добавить счет'
      Hint = 'Добавить счет'
      ShortCut = 16449
      OnExecute = actAddAccountExecute
    end
    object actAddAnalytics: TAction
      Category = 'Function'
      Caption = 'Добавить аналитику'
      Hint = 'Добавить аналитику'
      ShortCut = 16462
      OnExecute = actAddAnalyticsExecute
    end
  end
  inherited dsgdcBase: TDataSource
    Left = 240
    Top = 391
  end
  inherited pm_dlgG: TPopupMenu
    Left = 312
    Top = 392
  end
end
