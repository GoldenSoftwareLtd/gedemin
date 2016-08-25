object gd_security_dlgSetClassRight: Tgd_security_dlgSetClassRight
  Left = 243
  Top = 200
  Width = 696
  Height = 460
  Caption = 'gd_security_dlgSetClassRight'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object TPanel
    Left = 9
    Top = 26
    Width = 670
    Height = 388
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object Splitter1: TSplitter
      Left = 250
      Top = 0
      Width = 3
      Height = 388
      Cursor = crHSplit
    end
    object lvClasses: TListView
      Left = 0
      Top = 0
      Width = 250
      Height = 388
      Align = alLeft
      BorderStyle = bsNone
      Columns = <>
      TabOrder = 0
    end
    object ListView2: TListView
      Left = 253
      Top = 0
      Width = 417
      Height = 388
      Align = alClient
      BorderStyle = bsNone
      Columns = <>
      TabOrder = 1
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 414
    Width = 688
    Height = 19
    Panels = <>
    SimplePanel = False
  end
  object TBDock1: TTBDock
    Left = 0
    Top = 0
    Width = 688
    Height = 26
    object TBToolbar1: TTBToolbar
      Left = 0
      Top = 0
      Caption = 'TBToolbar1'
      TabOrder = 0
    end
  end
  object TBDock2: TTBDock
    Left = 0
    Top = 26
    Width = 9
    Height = 388
    Position = dpLeft
  end
  object TBDock3: TTBDock
    Left = 679
    Top = 26
    Width = 9
    Height = 388
    Position = dpRight
  end
end
