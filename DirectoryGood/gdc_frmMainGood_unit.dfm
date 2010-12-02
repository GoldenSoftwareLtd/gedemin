inherited gdc_frmMainGood: Tgdc_frmMainGood
  Left = 254
  Top = 157
  HelpContext = 42
  Caption = 'Справочник товарно-материальных ценностей'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 556
  end
  inherited TBDockTop: TTBDock
    inherited tbMainToolbar: TTBToolbar
      object tbsiNew: TTBSubmenuItem [0]
        Action = actNew
        DropdownCombo = True
        object tblMenuNew: TTBItem
          Action = actNew
        end
        object tbiSubNew: TTBItem
          Action = actNewSub
        end
      end
      inherited tbiEdit: TTBItem [1]
      end
      inherited tbiDelete: TTBItem [2]
      end
      inherited tbiDuplicate: TTBItem [3]
      end
      inherited tbiReduction: TTBItem [4]
      end
      inherited tbsiMainOne: TTBSeparatorItem [5]
      end
      inherited tbiCopy: TTBItem [6]
      end
      inherited tbiCut: TTBItem [7]
      end
      inherited tbiPaste: TTBItem [8]
      end
      inherited tbsiMainOneAndHalf: TTBSeparatorItem [9]
      end
      inherited tbiLoadFromFile: TTBItem [10]
      end
      inherited tbiSaveToFile: TTBItem [11]
      end
      inherited tbsiMainTwo: TTBSeparatorItem [12]
      end
      inherited tbiFind: TTBItem [13]
      end
      inherited tbiFilter: TTBItem [14]
      end
      inherited tbiPrint: TTBItem [15]
      end
      inherited tbiOnlySelected: TTBItem [16]
      end
      inherited tbsiMainThreeAndAHalf: TTBSeparatorItem [17]
      end
      inherited tbiHelp: TTBItem [18]
      end
      inherited tbiNew: TTBItem [19]
        Visible = False
      end
      inherited tbiEditInGrid: TTBItem [20]
      end
      inherited tbiLinkObject: TTBItem [21]
      end
    end
    inherited tbMainInvariant: TTBToolbar
      Left = 292
    end
  end
  inherited TBDockBottom: TTBDock
    Top = 575
  end
  inherited pnlWorkArea: TPanel
    inherited pnlDetail: TPanel
      inherited TBDockDetail: TTBDock
        inherited tbDetailToolbar: TTBToolbar
          Images = dmImages.il16x16
          object tbiViewAllCard: TTBItem
            Action = actViewAllCard
          end
        end
        inherited tbDetailCustom: TTBToolbar
          Left = 298
        end
      end
    end
  end
  inherited alMain: TActionList
    Left = 85
    object actNewSub: TAction
      Category = 'Main'
      Caption = 'Добавить подуровень...'
      OnExecute = actNewSubExecute
    end
    object actViewAllCard: TAction
      Category = 'Detail'
      Caption = 'Просмотр карточки по холдингу...'
      Hint = 'Просмотр карточки по холдингу...'
      ImageIndex = 74
      OnExecute = actViewAllCardExecute
      OnUpdate = actViewAllCardUpdate
    end
  end
  inherited pmMain: TPopupMenu
    Left = 145
    Top = 145
  end
  inherited dsMain: TDataSource
    DataSet = gdcGoodGroup
    Left = 115
    Top = 145
  end
  inherited dsDetail: TDataSource
    DataSet = gdcGood
    Left = 435
    Top = 230
  end
  inherited pmDetail: TPopupMenu
    Left = 465
    Top = 230
  end
  object gdcGoodGroup: TgdcGoodGroup
    Left = 55
    Top = 145
  end
  object gdcGood: TgdcGood
    MasterSource = dsMain
    MasterField = 'LB;RB'
    DetailField = 'LB;RB'
    SubSet = 'ByLBRB'
    Left = 495
    Top = 230
  end
end
