inherited gdc_frmGroup: Tgdc_frmGroup
  Left = 772
  Top = 270
  Width = 696
  Caption = 'Группы'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Width = 680
  end
  inherited TBDockTop: TTBDock
    Width = 680
  end
  inherited TBDockRight: TTBDock
    Left = 671
  end
  inherited TBDockBottom: TTBDock
    Width = 680
  end
  inherited pnlWorkArea: TPanel
    Width = 662
    inherited spChoose: TSplitter
      Width = 662
    end
    inherited pnChoose: TPanel
      Width = 662
      inherited pnButtonChoose: TPanel
        Left = 557
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 557
      end
      inherited pnlChooseCaption: TPanel
        Width = 662
      end
    end
    inherited pnlDetail: TPanel
      Width = 433
      inherited TBDockDetail: TTBDock
        Width = 433
      end
      inherited ibgrDetail: TgsIBGrid
        Width = 273
      end
    end
  end
  inherited dsMain: TDataSource
    DataSet = gdcGroup
  end
  inherited dsDetail: TDataSource
    DataSet = gdcBaseContact
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
