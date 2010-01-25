inherited gdc_frmGroup: Tgdc_frmGroup
  Left = 363
  Top = 276
  Width = 696
  Caption = 'gdc_frmGroup'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Width = 688
  end
  inherited TBDockTop: TTBDock
    Width = 688
  end
  inherited TBDockRight: TTBDock
    Left = 679
  end
  inherited TBDockBottom: TTBDock
    Width = 688
  end
  inherited pnlWorkArea: TPanel
    Width = 670
    inherited spChoose: TSplitter
      Width = 670
    end
    inherited pnChoose: TPanel
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
      Width = 441
      inherited TBDockDetail: TTBDock
        Width = 441
      end
      inherited ibgrDetail: TgsIBGrid
        Width = 281
      end
    end
  end
  inherited dsMain: TDataSource
    DataSet = gdcGroup
  end
  object gdcGroup: TgdcGroup
    Left = 328
    Top = 216
  end
  object gdcBaseContact: TgdcBaseContact
    MasterSource = dsMain
    MasterField = 'ID'
    DetailField = 'GROUPKEY'
    SubSet = 'Group'
    Left = 456
    Top = 200
  end
end
