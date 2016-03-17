inherited gdc_frmStyleObject: Tgdc_frmStyleObject
  Left = 399
  Top = 229
  Width = 1305
  Height = 675
  Caption = 'gdc_frmStyleObject'
  Font.Name = 'MS Sans Serif'
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 625
    Width = 1297
  end
  inherited TBDockTop: TTBDock
    Width = 1297
  end
  inherited TBDockLeft: TTBDock
    Height = 565
  end
  inherited TBDockRight: TTBDock
    Left = 1288
    Height = 565
  end
  inherited TBDockBottom: TTBDock
    Top = 616
    Width = 1297
  end
  inherited pnlWorkArea: TPanel
    Width = 1279
    Height = 565
    inherited sMasterDetail: TSplitter
      Width = 1279
    end
    inherited spChoose: TSplitter
      Top = 460
      Width = 1279
    end
    inherited pnlMain: TPanel
      Width = 1279
      inherited ibgrMain: TgsIBGrid
        Width = 1119
      end
    end
    inherited pnChoose: TPanel
      Top = 466
      Width = 1279
      inherited pnButtonChoose: TPanel
        Left = 1174
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 1174
      end
      inherited pnlChooseCaption: TPanel
        Width = 1279
      end
    end
    inherited pnlDetail: TPanel
      Width = 1279
      Height = 287
      inherited TBDockDetail: TTBDock
        Width = 1279
      end
      inherited pnlSearchDetail: TPanel
        Height = 261
        inherited sbSearchDetail: TScrollBox
          Height = 234
        end
      end
      inherited ibgrDetail: TgsIBGrid
        Width = 1119
        Height = 261
      end
    end
  end
  object gdcStyleObject: TgdcStyleObject
    Left = 193
    Top = 139
  end
  object gdcStyle: TgdcStyle
    MasterSource = dsMain
    MasterField = 'ID'
    DetailField = 'OBJECTKEY'
    SubSet = 'ByStyleObject'
    Left = 249
    Top = 328
  end
end
