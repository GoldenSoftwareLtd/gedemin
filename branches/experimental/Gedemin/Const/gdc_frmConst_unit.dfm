inherited gdc_frmConst: Tgdc_frmConst
  Left = 285
  Top = 205
  Width = 601
  Height = 441
  Caption = 'Константы'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 395
    Width = 593
  end
  inherited TBDockTop: TTBDock
    Width = 593
  end
  inherited TBDockLeft: TTBDock
    Height = 337
  end
  inherited TBDockRight: TTBDock
    Left = 584
    Height = 337
  end
  inherited TBDockBottom: TTBDock
    Top = 386
    Width = 593
  end
  inherited pnlWorkArea: TPanel
    Width = 575
    Height = 337
    inherited sMasterDetail: TSplitter
      Height = 234
    end
    inherited spChoose: TSplitter
      Top = 234
      Width = 575
    end
    inherited pnlMain: TPanel
      Height = 234
      inherited pnlSearchMain: TPanel
        Height = 234
        inherited sbSearchMain: TScrollBox
          Height = 196
        end
        inherited pnlSearchMainButton: TPanel
          Top = 196
        end
      end
      inherited ibgrMain: TgsIBGrid
        Height = 234
      end
    end
    inherited pnChoose: TPanel
      Top = 238
      Width = 575
      inherited pnButtonChoose: TPanel
        Left = 470
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 470
      end
      inherited pnlChooseCaption: TPanel
        Width = 575
      end
    end
    inherited pnlDetail: TPanel
      Width = 346
      Height = 234
      inherited TBDockDetail: TTBDock
        Width = 346
      end
      inherited pnlSearchDetail: TPanel
        Height = 208
        inherited sbSearchDetail: TScrollBox
          Height = 170
        end
        inherited pnlSearchDetailButton: TPanel
          Top = 170
        end
      end
      inherited ibgrDetail: TgsIBGrid
        Width = 186
        Height = 208
      end
    end
  end
  inherited alMain: TActionList
    Left = 85
    Top = 85
  end
  inherited pmMain: TPopupMenu
    Left = 145
    Top = 85
  end
  inherited dsMain: TDataSource
    DataSet = gdcConst
    Left = 115
    Top = 85
  end
  inherited dsDetail: TDataSource
    DataSet = gdcConstValue
    Left = 415
    Top = 225
  end
  inherited pmDetail: TPopupMenu
    Left = 445
    Top = 225
  end
  object gdcConst: TgdcConst
    Left = 175
    Top = 85
  end
  object gdcConstValue: TgdcConstValue
    MasterSource = dsMain
    MasterField = 'ID'
    DetailField = 'constkey'
    SubSet = 'ByConst'
    Left = 382
    Top = 225
  end
end
