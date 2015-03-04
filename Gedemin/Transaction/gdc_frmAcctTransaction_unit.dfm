inherited gdc_frmAcctTransaction: Tgdc_frmAcctTransaction
  Left = 163
  Top = 71
  Caption = 'Типовые операции'
  PixelsPerInch = 96
  TextHeight = 13
  inherited TBDockTop: TTBDock
    inherited tbMainToolbar: TTBToolbar
      inherited tbiNew: TTBItem
        Visible = False
      end
      object TBSubmenuItem1: TTBSubmenuItem [1]
        Action = actNew
        DropdownCombo = True
        object TBItem1: TTBItem
          Action = actNew
        end
        object TBItem2: TTBItem
          Action = actNewSub
        end
      end
    end
  end
  inherited pnlWorkArea: TPanel
    inherited sMasterDetail: TSplitter
      Left = 200
    end
    inherited pnlMain: TPanel
      Width = 200
      inherited tvGroup: TgsDBTreeView
        Width = 40
      end
    end
    inherited pnlDetail: TPanel
      Left = 204
      Width = 582
      inherited TBDockDetail: TTBDock
        Width = 582
      end
      inherited ibgrDetail: TgsIBGrid
        Width = 422
      end
    end
  end
  inherited alMain: TActionList
    Top = 141
    object actNewSub: TAction [1]
      Category = 'Main'
      Caption = 'Добавить подуровень...'
      ImageIndex = 0
      OnExecute = actNewSubExecute
      OnUpdate = actNewSubUpdate
    end
  end
  inherited pmMain: TPopupMenu
    Left = 115
    Top = 174
    inherited nNew_OLD: TMenuItem
      Action = nil
      ShortCut = 0
      OnClick = nil
      object N1: TMenuItem
        Action = actNew
      end
      object N2: TMenuItem
        Action = actNewSub
      end
    end
  end
  inherited dsMain: TDataSource
    DataSet = gdcAcctTransaction
    Left = 83
  end
  inherited dsDetail: TDataSource
    DataSet = gdcAcctTransactionEntry
    Left = 412
  end
  inherited pmDetail: TPopupMenu
    Left = 444
    Top = 300
  end
  object gdcAcctTransaction: TgdcAcctTransaction
    SubSet = 'ByCompany'
    Left = 116
    Top = 141
  end
  object gdcAcctTransactionEntry: TgdcAcctTransactionEntry
    MasterSource = dsMain
    MasterField = 'ID'
    DetailField = 'TransactionKey'
    SubSet = 'ByTransaction'
    Left = 373
    Top = 188
  end
end
