inherited dfBreakPoints: TdfBreakPoints
  Left = 246
  Top = 458
  Width = 696
  Height = 191
  HelpContext = 307
  Caption = 'Точки остановки'
  OldCreateOrder = True
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lvBreakPoints: TListView [0]
    Left = 0
    Top = 18
    Width = 688
    Height = 146
    Align = alClient
    Columns = <
      item
        AutoSize = True
        Caption = 'Ид'
        MinWidth = 70
      end
      item
        AutoSize = True
        Caption = 'Наименование функци'
        MinWidth = 200
      end
      item
        AutoSize = True
        Caption = 'Строка'
      end
      item
        AutoSize = True
        Caption = 'Условие'
        MinWidth = 70
      end
      item
        AutoSize = True
        Caption = 'Кол-во проходов'
        MinWidth = 150
      end>
    ReadOnly = True
    RowSelect = True
    PopupMenu = pmMain
    SmallImages = dmImages.imglActions
    TabOrder = 1
    ViewStyle = vsReport
    OnDblClick = lvBreakPointsDblClick
  end
  inherited pCaption: TPanel
    Width = 688
  end
  inherited alMain: TActionList
    object actEdit: TAction
      Caption = 'Свойства'
      ShortCut = 16453
      OnExecute = actEditExecute
      OnUpdate = actEditUpdate
    end
    object actDelete: TAction
      Caption = 'Удалить'
      ShortCut = 16430
      OnExecute = actDeleteExecute
      OnUpdate = actEditUpdate
    end
    object actEnable: TAction
      Caption = 'Подключить'
      OnExecute = actEnableExecute
      OnUpdate = actEnableUpdate
    end
    object actDeleteAll: TAction
      Caption = 'Удалить все'
      OnExecute = actDeleteAllExecute
      OnUpdate = actDeleteAllUpdate
    end
    object actEnableAll: TAction
      Caption = 'Подключить все'
      OnExecute = actEnableAllExecute
      OnUpdate = actDeleteAllUpdate
    end
    object actDisableAll: TAction
      Caption = 'Отключить все'
      OnExecute = actDisableAllExecute
      OnUpdate = actDeleteAllUpdate
    end
  end
  inherited pmMain: TPopupMenu
    object N10: TMenuItem [0]
      Action = actEdit
    end
    object N11: TMenuItem [1]
      Caption = '-'
    end
    object N12: TMenuItem [2]
      Action = actEnable
    end
    object N1: TMenuItem [3]
      Caption = '-'
    end
    object N13: TMenuItem [4]
      Action = actEnableAll
    end
    object N15: TMenuItem [5]
      Action = actDisableAll
    end
    object N14: TMenuItem [6]
      Caption = '-'
    end
    object N16: TMenuItem [7]
      Action = actDelete
    end
    object N17: TMenuItem [8]
      Action = actDeleteAll
    end
    object N9: TMenuItem [9]
      Caption = '-'
    end
  end
end
