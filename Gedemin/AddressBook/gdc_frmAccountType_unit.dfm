inherited gdc_frmAccountType: Tgdc_frmAccountType
  Left = 370
  Top = 238
  Width = 696
  Height = 499
  HelpContext = 133
  Caption = 'Типы банковских счетов'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 440
    Width = 688
  end
  inherited TBDockTop: TTBDock
    Width = 688
  end
  inherited TBDockLeft: TTBDock
    Height = 389
  end
  inherited TBDockRight: TTBDock
    Left = 679
    Height = 389
  end
  inherited TBDockBottom: TTBDock
    Top = 459
    Width = 688
  end
  inherited pnlWorkArea: TPanel
    Width = 670
    Height = 389
    inherited spChoose: TSplitter
      Top = 286
      Width = 670
    end
    inherited pnlMain: TPanel
      Width = 670
      Height = 286
      inherited pnlSearchMain: TPanel
        Height = 286
        inherited sbSearchMain: TScrollBox
          Height = 259
        end
      end
      inherited ibgrMain: TgsIBGrid
        Width = 510
        Height = 286
        Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgMultiSelect]
      end
    end
    inherited pnChoose: TPanel
      Top = 290
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
