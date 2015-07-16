inherited gdc_frmRelation: Tgdc_frmRelation
  Left = 336
  Top = 215
  HelpContext = 80
  Caption = 'Представления'
  PixelsPerInch = 96
  TextHeight = 13
  inherited TBDockTop: TTBDock
    inherited tbMainCustom: TTBToolbar
      object TBItem1: TTBItem
        Action = actMainToSetting
      end
    end
  end
  inherited pnlWorkArea: TPanel
    inherited pnlDetail: TPanel
      inherited TBDockDetail: TTBDock
        inherited tbDetailCustom: TTBToolbar
          Left = 256
          object TBItem2: TTBItem
            Action = actDetailToSetting
          end
        end
      end
    end
  end
  inherited alMain: TActionList
    inherited actDetailNew: TAction
      Visible = False
    end
    inherited actDetailDelete: TAction
      Visible = False
    end
    inherited actDetailDuplicate: TAction
      Visible = False
    end
    inherited actDetailReduction: TAction
      Visible = False
    end
  end
  inherited pmMain: TPopupMenu
    Left = 114
    Top = 80
  end
  inherited dsMain: TDataSource
    DataSet = gdcView
    Left = 304
    Top = 80
  end
  inherited dsDetail: TDataSource
    Left = 304
    Top = 280
  end
  inherited pmDetail: TPopupMenu
    Left = 124
    Top = 280
  end
  object gdcView: TgdcView
    Left = 337
    Top = 81
  end
  object gdcViewField: TgdcViewField
    MasterSource = dsMain
    MasterField = 'id'
    DetailField = 'relationkey'
    SubSet = 'ByRelation'
    Left = 337
    Top = 284
  end
end
