inherited frmRuntimeScript: TfrmRuntimeScript
  Left = 240
  Top = 199
  Width = 712
  Height = 161
  HelpContext = 305
  Caption = 'Время выполнения скрипт-функций'
  OldCreateOrder = True
  OnActivate = FormActivate
  PixelsPerInch = 96
  TextHeight = 13
  object lbRunTime: TListBox [0]
    Left = 0
    Top = 46
    Width = 704
    Height = 88
    Align = alClient
    ItemHeight = 13
    PopupMenu = pmMain
    TabOrder = 1
    OnDblClick = lbRunTimeDblClick
  end
  object TBDock1: TTBDock [1]
    Left = 0
    Top = 18
    Width = 704
    Height = 28
    BoundLines = [blTop, blBottom, blLeft, blRight]
    object TBToolbar1: TTBToolbar
      Left = 0
      Top = 0
      Caption = 'Панель инструментов'
      CloseButton = False
      Images = dmImages.il16x16
      Stretch = True
      TabOrder = 0
      object tbiSaveTime: TTBItem
        Action = actSaveTime
        AutoCheck = True
        DisplayMode = nbdmImageAndText
        ImageIndex = 92
      end
      object TBItem2: TTBItem
        AutoCheck = True
        Caption = 'Не обновлять'
        DisplayMode = nbdmImageAndText
        ImageIndex = 159
        OnClick = cbStopClick
      end
      object TBSeparatorItem1: TTBSeparatorItem
      end
      object TBItem1: TTBItem
        Caption = 'Обновить'
        DisplayMode = nbdmImageAndText
        ImageIndex = 17
        OnClick = btnRefreshClick
      end
      object tbiSave: TTBItem
        Action = actSave
        DisplayMode = nbdmImageAndText
      end
      object TBSeparatorItem2: TTBSeparatorItem
      end
      object tbiIgnore: TTBItem
        Action = actIgnore
        AutoCheck = True
        DisplayMode = nbdmImageAndText
      end
      object TBControlItem1: TTBControlItem
        Control = edtIgnoreList
      end
      object edtIgnoreList: TEdit
        Left = 557
        Top = 0
        Width = 133
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        Constraints.MinWidth = 133
        TabOrder = 0
      end
    end
  end
  inherited pCaption: TPanel
    Width = 704
  end
  inherited alMain: TActionList
    Left = 112
    Top = 56
    object actSaveTime: TAction
      Caption = 'Сохранять время выполнения'
      OnExecute = cbRuntimeSaveClick
    end
    object actDonorefresh: TAction
      Caption = 'Не обновлять'
      OnExecute = cbStopClick
    end
    object actRefresh: TAction
      Caption = 'Обновить'
      OnExecute = btnRefreshClick
      OnUpdate = actRefreshUpdate
    end
    object actDeleteAll: TAction
      Caption = 'Очистить список'
      OnExecute = actClearExecute
      OnUpdate = actDeleteAllUpdate
    end
    object actGotoFunction: TAction
      Caption = 'Перейти'
      ImageIndex = 99
      OnExecute = actGotoFunctionExecute
    end
    object actIgnore: TAction
      Caption = 'Не учитывать'
      ImageIndex = 20
      OnExecute = actIgnoreExecute
      OnUpdate = actIgnoreUpdate
    end
    object actSave: TAction
      Caption = 'Сохранить'
      Hint = 'Сохранить в файл...'
      ImageIndex = 25
      OnExecute = actSaveExecute
    end
  end
  inherited pmMain: TPopupMenu
    Left = 64
    Top = 56
    object N4: TMenuItem [0]
      Action = actGotoFunction
    end
    object N5: TMenuItem [1]
      Caption = '-'
    end
    object N3: TMenuItem [2]
      Action = actDeleteAll
    end
    object N1: TMenuItem [3]
      Caption = '-'
    end
  end
end
