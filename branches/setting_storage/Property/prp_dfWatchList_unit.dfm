inherited dfWatchList: TdfWatchList
  Left = 245
  Top = 340
  Width = 650
  Height = 168
  HelpContext = 304
  Caption = 'Список переменных'
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  object lvWatchList: TListView [0]
    Left = 0
    Top = 18
    Width = 642
    Height = 123
    Align = alClient
    Columns = <
      item
        AutoSize = True
      end>
    ReadOnly = True
    RowSelect = True
    PopupMenu = pmMain
    ShowColumnHeaders = False
    TabOrder = 1
    ViewStyle = vsReport
    OnCustomDrawItem = lvWatchListCustomDrawItem
    OnDblClick = lvWatchListDblClick
  end
  inherited pCaption: TPanel
    Width = 642
  end
  inherited alMain: TActionList
    Left = 120
    Top = 88
    object actEditWatch: TAction [1]
      Caption = 'Редактировать'
      ShortCut = 16453
      OnExecute = actEditWatchExecute
      OnUpdate = actEditWatchUpdate
    end
    object actAddWatch: TAction [2]
      Caption = 'Добавить'
      ShortCut = 16449
      OnExecute = actAddWatchExecute
    end
    object actDisable: TAction [3]
      Caption = 'Не вычислять'
      OnExecute = actDisableExecute
      OnUpdate = actDisableUpdate
    end
    object actDeleteWatch: TAction [4]
      Caption = 'Удалить'
      ShortCut = 16430
      OnExecute = actDeleteWatchExecute
      OnUpdate = actEditWatchUpdate
    end
    object actEnable: TAction [5]
      Caption = 'Вычислять'
      OnExecute = actEnableExecute
      OnUpdate = actEnableUpdate
    end
    object actDeleteAll: TAction [6]
      Caption = 'Удалить все'
      OnExecute = actDeleteAllExecute
    end
    object actDisableAll: TAction [7]
      Caption = 'Не вычислять все'
      OnExecute = actDisableAllExecute
    end
    object actEnableAll: TAction [8]
      Caption = 'Вычислять все'
      OnExecute = actEnableAllExecute
    end
  end
  inherited pmMain: TPopupMenu
    Left = 64
    Top = 88
    object N3: TMenuItem [0]
      Action = actEditWatch
    end
    object N2: TMenuItem [1]
      Action = actAddWatch
    end
    object N4: TMenuItem [2]
      Caption = '-'
    end
    object N5: TMenuItem [3]
      Action = actEnable
    end
    object N6: TMenuItem [4]
      Action = actDisable
    end
    object N7: TMenuItem [5]
      Caption = '-'
    end
    object N8: TMenuItem [6]
      Action = actEnableAll
    end
    object N9: TMenuItem [7]
      Action = actDisableAll
    end
    object N10: TMenuItem [8]
      Caption = '-'
    end
    object N11: TMenuItem [9]
      Action = actDeleteWatch
    end
    object N12: TMenuItem [10]
      Action = actDeleteAll
    end
    object N1: TMenuItem [11]
      Caption = '-'
    end
  end
end
