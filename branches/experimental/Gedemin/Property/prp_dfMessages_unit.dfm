inherited dfMessages: TdfMessages
  Left = 334
  Top = 282
  Width = 554
  Height = 122
  HelpContext = 302
  Caption = 'Сообщения'
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  object lvMessages: TListView [0]
    Left = 0
    Top = 18
    Width = 546
    Height = 77
    Align = alClient
    Columns = <
      item
        AutoSize = True
      end>
    ReadOnly = True
    PopupMenu = pmMain
    ShowColumnHeaders = False
    TabOrder = 1
    ViewStyle = vsReport
    OnCustomDrawItem = lvMessagesCustomDrawItem
    OnDblClick = lvMessagesDblClick
    OnDeletion = lvMessagesDeletion
    OnExit = lvMessagesExit
    OnKeyDown = lvMessagesKeyDown
    OnSelectItem = lvMessagesSelectItem
  end
  inherited pCaption: TPanel
    Width = 546
  end
  inherited alMain: TActionList
    Top = 49
    object actDelete: TAction
      Caption = 'Удалить'
      Hint = 'Удалить выделенное сообщение'
      ShortCut = 16430
      OnExecute = actDeleteExecute
      OnUpdate = actDeleteUpdate
    end
    object actClearErrorMessages: TAction
      Caption = 'Удалить сообщения об ошибках'
      Hint = 'Удалить сообщения об ошибках'
      OnExecute = actClearErrorMessagesExecute
    end
    object actClearSearchMessages: TAction
      Caption = 'Удалить результаты поиска'
      Hint = 'Удалить результаты поиска'
      OnExecute = actClearSearchMessagesExecute
    end
    object actClearCompileMessages: TAction
      Caption = 'Удалить результаты компиляции'
      Hint = 'Удалить результаты компиляции'
      OnExecute = actClearCompileMessagesExecute
    end
  end
  inherited pmMain: TPopupMenu
    OnPopup = pmMainPopup
    Top = 49
    object N2: TMenuItem [0]
      Action = actDelete
    end
    object N5: TMenuItem [1]
      Action = actClearCompileMessages
    end
    object N3: TMenuItem [2]
      Action = actClearSearchMessages
    end
    object N4: TMenuItem [3]
      Action = actClearErrorMessages
    end
    object N1: TMenuItem [4]
      Caption = '-'
    end
  end
end
