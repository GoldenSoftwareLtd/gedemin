inherited gdc_frmTable: Tgdc_frmTable
  Left = 331
  Top = 258
  HelpContext = 83
  Caption = 'Таблицы'
  PixelsPerInch = 96
  TextHeight = 13
  inherited TBDockTop: TTBDock
    inherited tbMainCustom: TTBToolbar
      Images = dmImages.il16x16
      object TBItem3: TTBItem
        Action = actMainToSetting
      end
      object TBItem1: TTBItem
        Action = actOpenTable
      end
      object TBItem4: TTBItem
        Action = actShowSQLEditor
      end
    end
  end
  inherited pnlWorkArea: TPanel
    inherited pnlDetail: TPanel
      inherited TBDockDetail: TTBDock
        inherited tbDetailCustom: TTBToolbar
          object TBItem2: TTBItem
            Action = actDetailToSetting
          end
        end
      end
    end
  end
  inherited alMain: TActionList
    Top = 79
    object actOpenTable: TAction
      Caption = 'Открыть таблицу'
      ImageIndex = 7
      OnExecute = actOpenTableExecute
      OnUpdate = actOpenTableUpdate
    end
    object actShowSQLEditor: TAction
      Caption = 'SQL редактор'
      Hint = 'SQL редактор'
      ImageIndex = 108
      OnExecute = actShowSQLEditorExecute
      OnUpdate = actShowSQLEditorUpdate
    end
  end
  inherited pmMain: TPopupMenu
    Left = 114
  end
  inherited dsMain: TDataSource
    DataSet = gdcTable
  end
  inherited gdMacrosMenu: TgdMacrosMenu
    Left = 225
    Top = 119
  end
  inherited dsDetail: TDataSource
    DataSet = gdcTableField
    Left = 418
  end
  inherited pmDetail: TPopupMenu
    Left = 378
    Top = 300
  end
  object gdcTable: TgdcTable
    Left = 114
    Top = 79
  end
  object gdcTableField: TgdcTableField
    MasterSource = dsMain
    MasterField = 'id'
    DetailField = 'relationkey'
    SubSet = 'ByRelation'
    Left = 418
    Top = 329
  end
end
