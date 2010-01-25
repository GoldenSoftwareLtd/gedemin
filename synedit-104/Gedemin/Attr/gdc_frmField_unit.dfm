inherited gdc_frmField: Tgdc_frmField
  Left = 224
  Top = 213
  Width = 537
  Height = 388
  HelpContext = 81
  Caption = 'Типы'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 333
    Width = 529
  end
  inherited TBDockTop: TTBDock
    Width = 529
    inherited tbMainCustom: TTBToolbar
      Left = 496
      object TBItem1: TTBItem
        Action = actMainToSetting
      end
    end
  end
  inherited TBDockLeft: TTBDock
    Height = 284
  end
  inherited TBDockRight: TTBDock
    Left = 520
    Height = 284
  end
  inherited TBDockBottom: TTBDock
    Top = 352
    Width = 529
  end
  inherited pnlWorkArea: TPanel
    Width = 511
    Height = 284
    inherited spChoose: TSplitter
      Top = 182
      Width = 511
    end
    inherited pnlMain: TPanel
      Width = 511
      Height = 182
      inherited pnlSearchMain: TPanel
        Height = 182
        inherited sbSearchMain: TScrollBox
          Height = 144
        end
        inherited pnlSearchMainButton: TPanel
          Top = 144
        end
      end
      inherited ibgrMain: TgsIBGrid
        Width = 351
        Height = 182
      end
    end
    inherited pnChoose: TPanel
      Top = 185
      Width = 511
      inherited pnButtonChoose: TPanel
        Left = 406
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 406
      end
    end
  end
  inherited alMain: TActionList
    Left = 55
    Top = 110
    inherited actDuplicate: TAction
      Enabled = False
    end
  end
  inherited pmMain: TPopupMenu
    Left = 115
    Top = 110
  end
  inherited dsMain: TDataSource
    DataSet = gdcField
    Left = 85
    Top = 110
  end
  inherited dsChoose: TDataSource
    Top = 242
  end
  object gdcField: TgdcField
    Left = 145
    Top = 110
  end
end
