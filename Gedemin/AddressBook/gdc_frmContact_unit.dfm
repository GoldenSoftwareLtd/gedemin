inherited gdc_frmContact: Tgdc_frmContact
  Left = 225
  Top = 193
  Width = 696
  Height = 480
  Caption = 'Люди'
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 430
    Width = 688
  end
  inherited TBDockTop: TTBDock
    Width = 688
  end
  inherited TBDockLeft: TTBDock
    Height = 370
  end
  inherited TBDockRight: TTBDock
    Left = 679
    Height = 370
  end
  inherited TBDockBottom: TTBDock
    Top = 421
    Width = 688
  end
  inherited pnlWorkArea: TPanel
    Width = 670
    Height = 370
    inherited sMasterDetail: TSplitter
      Height = 265
    end
    inherited spChoose: TSplitter
      Top = 265
      Width = 670
    end
    inherited pnlMain: TPanel
      Height = 265
      inherited pnlSearchMain: TPanel
        Height = 265
        inherited sbSearchMain: TScrollBox
          Height = 238
        end
      end
      inherited tvGroup: TgsDBTreeView
        Height = 265
      end
    end
    inherited pnChoose: TPanel
      Top = 271
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
    inherited pnlDetail: TPanel
      Width = 498
      Height = 265
      inherited TBDockDetail: TTBDock
        Width = 498
      end
      inherited pnlSearchDetail: TPanel
        Height = 239
        inherited sbSearchDetail: TScrollBox
          Height = 212
        end
      end
      inherited ibgrDetail: TgsIBGrid
        Width = 338
        Height = 239
      end
    end
  end
  inherited dsMain: TDataSource
    DataSet = gdcFolder
  end
  inherited dsDetail: TDataSource
    DataSet = gdcContact
  end
  object gdcFolder: TgdcFolder
    Left = 136
    Top = 216
  end
  object gdcContact: TgdcContact
    MasterSource = dsMain
    MasterField = 'LB;RB'
    DetailField = 'LB;RB'
    SubSet = 'ByLBRB'
    Left = 392
    Top = 224
  end
end
