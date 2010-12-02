inherited gdc_frmAutoTransaction: Tgdc_frmAutoTransaction
  Left = 271
  Top = 264
  HelpContext = 203
  Caption = 'Автоматические хоз. операции'
  PixelsPerInch = 96
  TextHeight = 13
  inherited TBDockTop: TTBDock
    inherited tbMainMenu: TTBToolbar
      inherited tbsiMainMenuDetailObject: TTBSubmenuItem
        object TBSeparatorItem2: TTBSeparatorItem
        end
        object TBItem2: TTBItem
          Action = actExecOperation
        end
      end
    end
    inherited tbMainInvariant: TTBToolbar
      Left = 256
      DockPos = 256
    end
  end
  inherited pnlWorkArea: TPanel
    inherited pnlDetail: TPanel
      inherited TBDockDetail: TTBDock
        inherited tbDetailCustom: TTBToolbar
          Visible = True
          object TBItem1: TTBItem
            Action = actExecOperation
            ShortCut = 116
          end
        end
      end
    end
  end
  inherited alMain: TActionList
    object actExecOperation: TAction
      Caption = 'Выполнить операцию'
      Hint = 'Выполнить операцию'
      ImageIndex = 126
      OnExecute = actExecOperationExecute
      OnUpdate = actExecOperationUpdate
    end
  end
  inherited dsMain: TDataSource
    DataSet = gdcAutoTransaction
    Left = 116
    Top = 133
  end
  inherited dsChoose: TDataSource
    DataSet = gdcAutoTrRecord
  end
  inherited dsDetail: TDataSource
    DataSet = gdcAutoTrRecord
    Top = 164
  end
  object gdcAutoTransaction: TgdcAutoTransaction
    SubSet = 'ByCompany'
    Left = 104
    Top = 96
  end
  object gdcAutoTrRecord: TgdcAutoTrRecord
    MasterSource = dsMain
    MasterField = 'ID'
    DetailField = 'TransactionKey'
    SubSet = 'ByTransaction'
    Left = 336
    Top = 152
  end
end
