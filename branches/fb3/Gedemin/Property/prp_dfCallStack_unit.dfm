inherited dfCallStack: TdfCallStack
  Left = 300
  Top = 383
  Width = 499
  Height = 105
  HelpContext = 303
  Caption = 'Стек вызовов'
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  object lvCallStack: TListView [0]
    Left = 0
    Top = 18
    Width = 491
    Height = 60
    Align = alClient
    Columns = <
      item
        AutoSize = True
      end>
    HideSelection = False
    ReadOnly = True
    RowSelect = True
    PopupMenu = pmMain
    ShowColumnHeaders = False
    TabOrder = 1
    ViewStyle = vsReport
    OnDblClick = lvCallStackDblClick
  end
  inherited pCaption: TPanel
    Width = 491
  end
  inherited pmMain: TPopupMenu
    Top = 24
  end
end
