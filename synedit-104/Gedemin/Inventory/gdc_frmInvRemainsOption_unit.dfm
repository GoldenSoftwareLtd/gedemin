inherited gdc_frmInvRemainsOption: Tgdc_frmInvRemainsOption
  Left = 214
  Top = 157
  Width = 696
  Height = 480
  Caption = 'Настройка остатков'
  Font.Name = 'MS Sans Serif'
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 425
    Width = 688
  end
  inherited TBDockTop: TTBDock
    Width = 688
  end
  inherited TBDockLeft: TTBDock
    Height = 376
  end
  inherited TBDockRight: TTBDock
    Left = 679
    Height = 376
  end
  inherited TBDockBottom: TTBDock
    Top = 444
    Width = 688
  end
  inherited pnlWorkArea: TPanel
    Width = 670
    Height = 376
    inherited spChoose: TSplitter
      Top = 274
      Width = 670
    end
    inherited pnlMain: TPanel
      Width = 670
      Height = 274
      inherited pnlSearchMain: TPanel
        Height = 274
        inherited sbSearchMain: TScrollBox
          Height = 236
        end
        inherited pnlSearchMainButton: TPanel
          Top = 236
        end
      end
      inherited ibgrMain: TgsIBGrid
        Width = 510
        Height = 274
      end
    end
    inherited pnChoose: TPanel
      Top = 277
      Width = 670
      inherited pnButtonChoose: TPanel
        Left = 565
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 565
      end
    end
  end
  inherited dsMain: TDataSource
    DataSet = gdcInvRemainsOption
  end
  object gdcInvRemainsOption: TgdcInvRemainsOption
    ModifyFromStream = False
    CachedUpdates = False
    Left = 329
    Top = 169
  end
end
