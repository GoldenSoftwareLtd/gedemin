inherited gdc_frmAutoTask: Tgdc_frmAutoTask
  Left = 290
  Top = 187
  Width = 1044
  Height = 531
  Caption = 'gdc_frmAutoTask'
  Font.Name = 'MS Sans Serif'
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 474
    Width = 1028
  end
  inherited TBDockTop: TTBDock
    Width = 1028
  end
  inherited TBDockLeft: TTBDock
    Height = 414
  end
  inherited TBDockRight: TTBDock
    Left = 1019
    Height = 414
  end
  inherited TBDockBottom: TTBDock
    Top = 465
    Width = 1028
  end
  inherited pnlWorkArea: TPanel
    Width = 1010
    Height = 414
    inherited sMasterDetail: TSplitter
      Width = 1010
    end
    inherited spChoose: TSplitter
      Top = 309
      Width = 1010
    end
    inherited pnlMain: TPanel
      Width = 1010
      inherited ibgrMain: TgsIBGrid
        Width = 850
      end
    end
    inherited pnChoose: TPanel
      Top = 315
      Width = 1010
      inherited pnButtonChoose: TPanel
        Left = 905
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 905
      end
      inherited pnlChooseCaption: TPanel
        Width = 1010
      end
    end
    inherited pnlDetail: TPanel
      Width = 1010
      Height = 136
      inherited TBDockDetail: TTBDock
        Width = 1010
      end
      inherited pnlSearchDetail: TPanel
        Height = 110
        inherited sbSearchDetail: TScrollBox
          Height = 83
        end
      end
      inherited ibgrDetail: TgsIBGrid
        Width = 850
        Height = 110
      end
    end
  end
  inherited dsMain: TDataSource
    DataSet = gdcAutoTask
  end
  inherited dsDetail: TDataSource
    DataSet = gdcAutoTaskLog
  end
  object gdcAutoTaskLog: TgdcAutoTaskLog
    MasterSource = dsMain
    MasterField = 'ID'
    DetailField = 'AUTOTASKKEY'
    SubSet = 'ByAutoTask'
    Left = 361
    Top = 293
  end
  object gdcAutoTask: TgdcAutoTask
    Left = 113
    Top = 102
  end
end
