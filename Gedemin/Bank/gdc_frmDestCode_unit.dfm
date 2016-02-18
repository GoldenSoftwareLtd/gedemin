inherited gdc_frmDestCode: Tgdc_frmDestCode
  Left = 265
  Top = 214
  Width = 696
  Height = 480
  Caption = 'Назначения платежа'
  Font.Name = 'Tahoma'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 418
    Width = 688
  end
  inherited TBDockTop: TTBDock
    Width = 688
  end
  inherited TBDockLeft: TTBDock
    Height = 369
  end
  inherited TBDockRight: TTBDock
    Left = 679
    Height = 369
  end
  inherited TBDockBottom: TTBDock
    Top = 437
    Width = 688
  end
  inherited pnlWorkArea: TPanel
    Width = 670
    Height = 369
    inherited spChoose: TSplitter
      Top = 267
      Width = 670
    end
    inherited pnlMain: TPanel
      Width = 670
      Height = 267
      inherited pnlSearchMain: TPanel
        Height = 267
        inherited sbSearchMain: TScrollBox
          Height = 237
        end
        inherited pnlSearchMainButton: TPanel
          Top = 237
        end
      end
      inherited ibgrMain: TgsIBGrid
        Width = 510
        Height = 267
        Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgMultiSelect]
      end
    end
    inherited pnChoose: TPanel
      Top = 270
      Width = 670
      inherited pnButtonChoose: TPanel
        Left = 565
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 565
      end
    end
  end
  inherited alMain: TActionList
    Left = 85
    Top = 85
  end
  inherited pmMain: TPopupMenu
    Left = 175
    Top = 85
  end
  inherited dsMain: TDataSource
    DataSet = gdcDestCode
    Left = 145
    Top = 85
  end
  object gdcDestCode: TgdcDestCode
    CachedUpdates = False
    Left = 115
    Top = 85
  end
end
