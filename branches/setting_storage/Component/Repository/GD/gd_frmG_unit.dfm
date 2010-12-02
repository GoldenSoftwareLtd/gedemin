object gd_frmG: Tgd_frmG
  Left = 247
  Top = 207
  Width = 553
  Height = 365
  Caption = 'gd_frmG'
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  object sbMain: TStatusBar
    Left = 0
    Top = 303
    Width = 545
    Height = 19
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Panels = <>
    SimplePanel = True
    UseSystemFont = False
  end
  object pnlMain: TPanel
    Left = 0
    Top = 0
    Width = 545
    Height = 303
    Align = alClient
    BevelOuter = bvLowered
    Constraints.MinHeight = 100
    Constraints.MinWidth = 200
    TabOrder = 1
    object cbMain: TControlBar
      Left = 1
      Top = 1
      Width = 543
      Height = 28
      Align = alTop
      AutoSize = True
      BevelEdges = [beBottom]
      Color = clBtnFace
      DockSite = False
      ParentColor = False
      TabOrder = 0
      object tbMain: TToolBar
        Left = 11
        Top = 2
        Width = 350
        Height = 22
        AutoSize = True
        EdgeBorders = []
        Flat = True
        Images = dmImages.ilToolBarSmall
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        object tbtNew: TToolButton
          Left = 0
          Top = 0
          Action = actNew
        end
        object tbtEdit: TToolButton
          Left = 23
          Top = 0
          Action = actEdit
        end
        object tbtDelete: TToolButton
          Left = 46
          Top = 0
          Action = actDelete
        end
        object tbtDuplicate: TToolButton
          Left = 69
          Top = 0
          Action = actDuplicate
        end
        object tbnSpace7: TToolButton
          Left = 92
          Top = 0
          Width = 8
          Caption = 'tbnSpace7'
          ImageIndex = 14
          Style = tbsSeparator
        end
        object tbtCopy: TToolButton
          Left = 100
          Top = 0
          Action = actCopy
        end
        object tbtCut: TToolButton
          Left = 123
          Top = 0
          Action = actCut
        end
        object tbtPaste: TToolButton
          Left = 146
          Top = 0
          Action = actPaste
        end
        object tbnSpace1: TToolButton
          Left = 169
          Top = 0
          Width = 8
          Caption = 'tbnSpace1'
          ImageIndex = 14
          Style = tbsSeparator
        end
        object tbtUnDo: TToolButton
          Left = 177
          Top = 0
          Action = actUnDo
        end
        object tbnSpace5: TToolButton
          Left = 200
          Top = 0
          Width = 8
          Caption = 'tbnSpace5'
          ImageIndex = 10
          Style = tbsSeparator
        end
        object tbtFilter: TToolButton
          Left = 208
          Top = 0
          Action = actFilter
        end
        object tbtPrint: TToolButton
          Left = 231
          Top = 0
          Action = actPrint
          DropdownMenu = pmMainReport
        end
        object tbnSpace6: TToolButton
          Left = 254
          Top = 0
          Width = 6
          Caption = 'tbnSpace6'
          ImageIndex = 14
          Style = tbsSeparator
        end
        object tbHlp: TToolButton
          Left = 260
          Top = 0
          Action = actHlp
        end
      end
    end
  end
  object alMain: TActionList
    Images = dmImages.ilToolBarSmall
    Left = 165
    Top = 45
    object actNew: TAction
      Caption = 'actNew'
      ImageIndex = 0
      ShortCut = 45
    end
    object actEdit: TAction
      Caption = 'actEdit'
      ImageIndex = 1
      ShortCut = 16463
    end
    object actDelete: TAction
      Caption = 'actDelete'
      ImageIndex = 2
      ShortCut = 16452
    end
    object actDuplicate: TAction
      Caption = 'actDuplicate'
      ImageIndex = 3
      ShortCut = 16469
    end
    object actFilter: TAction
      Caption = 'actFilter'
      ImageIndex = 4
      ShortCut = 16454
      OnExecute = actFilterExecute
    end
    object actHlp: TAction
      Caption = 'actHlp'
      ImageIndex = 13
      ShortCut = 112
    end
    object actPrint: TAction
      Caption = 'actPrint'
      ImageIndex = 6
      ShortCut = 16464
      OnExecute = actPrintExecute
    end
    object actCut: TAction
      Caption = 'actCut'
      ImageIndex = 7
      ShortCut = 16472
    end
    object actCopy: TAction
      Caption = 'actCopy'
      ImageIndex = 8
      ShortCut = 16451
    end
    object actPaste: TAction
      Caption = 'actPaste'
      ImageIndex = 9
      ShortCut = 16470
    end
    object actUnDo: TAction
      Caption = 'actUnDo'
      ImageIndex = 17
    end
  end
  object pmMainReport: TPopupMenu
    Left = 195
    Top = 45
  end
  object pmMain: TPopupMenu
    Images = dmImages.ilToolBarSmall
    Left = 225
    Top = 45
    object actCopy1: TMenuItem
      Action = actCopy
    end
    object actCut1: TMenuItem
      Action = actCut
    end
    object actPaste1: TMenuItem
      Action = actPaste
    end
  end
  object MainMenu: TMainMenu
    Images = dmImages.ilToolBarSmall
    Left = 255
    Top = 45
    object mN1: TMenuItem
      Caption = 'Документ'
    end
    object mN2: TMenuItem
      Caption = 'Справка'
    end
  end
end
