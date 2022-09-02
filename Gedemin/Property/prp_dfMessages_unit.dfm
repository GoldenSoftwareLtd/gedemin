inherited dfMessages: TdfMessages
  Left = 451
  Top = 286
  Width = 707
  Height = 164
  HelpContext = 302
  Caption = '—ообщени€'
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  object lvMessages: TListView [0]
    Left = 0
    Top = 18
    Width = 691
    Height = 108
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
    Width = 691
  end
  inherited alMain: TActionList
    Top = 49
    object actDelete: TAction
      Caption = '”далить'
      Hint = '”далить выделенное сообщение'
      ShortCut = 16430
      OnExecute = actDeleteExecute
      OnUpdate = actDeleteUpdate
    end
    object actClearErrorMessages: TAction
      Caption = '”далить сообщени€ об ошибках'
      Hint = '”далить сообщени€ об ошибках'
      OnExecute = actClearErrorMessagesExecute
    end
    object actClearCompileMessages: TAction
      Caption = '”далить результаты компил€ции'
      Hint = '”далить результаты компил€ции'
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
    object N4: TMenuItem [2]
      Action = actClearErrorMessages
    end
    object N1: TMenuItem [3]
      Caption = '-'
    end
  end
end
