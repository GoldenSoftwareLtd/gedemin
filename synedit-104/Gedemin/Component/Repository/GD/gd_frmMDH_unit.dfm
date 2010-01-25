inherited gd_frmMDH: Tgd_frmMDH
  Left = 234
  Top = 172
  Width = 580
  Height = 402
  Caption = 'gd_frmMDH'
  PixelsPerInch = 96
  TextHeight = 13
  object splMain: TSplitter [0]
    Left = 0
    Top = 153
    Width = 572
    Height = 3
    Cursor = crVSplit
    Align = alBottom
  end
  inherited sbMain: TStatusBar
    Top = 337
    Width = 572
  end
  object pnlDetail: TPanel [2]
    Left = 0
    Top = 156
    Width = 572
    Height = 181
    Align = alBottom
    BevelOuter = bvLowered
    Constraints.MinHeight = 100
    Constraints.MinWidth = 200
    TabOrder = 0
    object cbDetail: TControlBar
      Left = 1
      Top = 1
      Width = 570
      Height = 28
      Align = alTop
      AutoSize = True
      BevelEdges = [beBottom]
      TabOrder = 0
      object tbDetail: TToolBar
        Left = 11
        Top = 2
        Width = 262
        Height = 22
        AutoSize = True
        EdgeBorders = []
        Flat = True
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        object tbtNewDetail: TToolButton
          Left = 0
          Top = 0
          Action = actNewDetail
        end
        object tbtEditDetail: TToolButton
          Left = 23
          Top = 0
          Action = actEditDetail
        end
        object tbtDeleteDetail: TToolButton
          Left = 46
          Top = 0
          Action = actDeleteDetail
        end
        object tbtDuplicateDetail: TToolButton
          Left = 69
          Top = 0
          Action = actDuplicateDetail
        end
        object ToolButton1: TToolButton
          Left = 92
          Top = 0
          Width = 8
          Caption = 'ToolButton1'
          ImageIndex = 10
          Style = tbsSeparator
        end
        object tbtCopyDetail: TToolButton
          Left = 100
          Top = 0
          Action = actCopyDetail
        end
        object tbtCutDetail: TToolButton
          Left = 123
          Top = 0
          Action = actCutDetail
        end
        object tbtPasteDetail: TToolButton
          Left = 146
          Top = 0
          Caption = 'tbtPasteDetail'
          ImageIndex = 9
        end
        object ToolButton2: TToolButton
          Left = 169
          Top = 0
          Width = 8
          Caption = 'ToolButton2'
          ImageIndex = 10
          Style = tbsSeparator
        end
        object tbtFilterDetail: TToolButton
          Left = 177
          Top = 0
          Action = actFilterDetail
        end
        object tbtPrintDetail: TToolButton
          Left = 200
          Top = 0
          Action = actPrintDetail
          DropdownMenu = pmDetailReport
        end
      end
    end
  end
  inherited pnlMain: TPanel
    Width = 572
    Height = 153
    inherited cbMain: TControlBar
      Width = 570
    end
  end
  inherited alMain: TActionList
    Left = 504
    Top = 40
    inherited actNew: TAction
      Category = 'Master'
    end
    inherited actEdit: TAction
      Category = 'Master'
    end
    inherited actDelete: TAction
      Category = 'Master'
    end
    inherited actDuplicate: TAction
      Category = 'Master'
    end
    inherited actFilter: TAction
      Category = 'Master'
    end
    inherited actPrint: TAction
      Category = 'Master'
    end
    object actNewDetail: TAction [7]
      Category = 'Detail'
      Caption = 'actNewDetail'
      ImageIndex = 0
    end
    object actEditDetail: TAction [8]
      Category = 'Detail'
      Caption = 'actEditDetail'
      ImageIndex = 1
    end
    object actDeleteDetail: TAction [9]
      Category = 'Detail'
      Caption = 'actDeleteDetail'
      ImageIndex = 2
    end
    object actDuplicateDetail: TAction [10]
      Category = 'Detail'
      Caption = 'actDuplicateDetail'
      ImageIndex = 3
    end
    object actFilterDetail: TAction [11]
      Category = 'Detail'
      Caption = 'actFilterDetail'
      ImageIndex = 4
    end
    object actPrintDetail: TAction [12]
      Category = 'Detail'
      Caption = 'actPrintDetail'
      ImageIndex = 6
      OnExecute = actPrintDetailExecute
    end
    inherited actCut: TAction
      Category = 'Master'
    end
    inherited actCopy: TAction
      Category = 'Master'
    end
    inherited actPaste: TAction
      Category = 'Master'
    end
    object actCopyDetail: TAction
      Category = 'Detail'
      Caption = 'actCopyDetail'
      ImageIndex = 8
    end
    object actCutDetail: TAction
      Category = 'Detail'
      Caption = 'actCutDetail'
      ImageIndex = 7
    end
    object actPasteDetail: TAction
      Category = 'Detail'
      Caption = 'actPasteDetail'
      ImageIndex = 9
    end
  end
  inherited pmMain: TPopupMenu
    Left = 208
    Top = 80
  end
  object pmDetailReport: TPopupMenu [7]
    Left = 168
    Top = 172
  end
  object pmDetail: TPopupMenu
    Left = 208
    Top = 172
  end
end
