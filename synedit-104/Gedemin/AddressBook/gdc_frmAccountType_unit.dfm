inherited gdc_frmAccountType: Tgdc_frmAccountType
  Left = 231
  Top = 258
  Width = 696
  Height = 480
  HelpContext = 133
  Caption = ''
  Font.Name = 'MS Sans Serif'
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
      Top = 273
      Width = 670
    end
    inherited pnlMain: TPanel
      Width = 670
      Height = 273
      inherited pnlSearchMain: TPanel
        Height = 273
        inherited sbSearchMain: TScrollBox
          Height = 235
        end
        inherited pnlSearchMainButton: TPanel
          Top = 235
        end
      end
      inherited ibgrMain: TgsIBGrid
        Width = 510
        Height = 273
        Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgMultiSelect]
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
      inherited pnlChooseCaption: TPanel
        Width = 670
      end
    end
  end
  inherited alMain: TActionList
    Left = 85
  end
  inherited pmMain: TPopupMenu
    Left = 175
    Top = 80
  end
  inherited dsMain: TDataSource
    DataSet = gdcCompanyAccountType
    Left = 145
    Top = 80
  end
  object gdcCompanyAccountType: TgdcCompanyAccountType
    Left = 115
    Top = 80
  end
end
