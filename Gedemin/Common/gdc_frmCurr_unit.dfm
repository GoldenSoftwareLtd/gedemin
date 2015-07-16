inherited gdc_frmCurr: Tgdc_frmCurr
  Left = 327
  Top = 200
  Width = 812
  Height = 511
  HelpContext = 47
  Caption = 'Курсы валют'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 452
    Width = 804
  end
  inherited TBDockTop: TTBDock
    Width = 804
    inherited tbMainInvariant: TTBToolbar
      Left = 304
    end
  end
  inherited TBDockLeft: TTBDock
    Height = 401
  end
  inherited TBDockRight: TTBDock
    Left = 795
    Height = 401
  end
  inherited TBDockBottom: TTBDock
    Top = 471
    Width = 804
  end
  inherited pnlWorkArea: TPanel
    Width = 786
    Height = 401
    inherited sMasterDetail: TSplitter
      Left = 301
      Height = 296
    end
    inherited spChoose: TSplitter
      Top = 296
      Width = 786
    end
    inherited pnlMain: TPanel
      Width = 301
      Height = 296
      inherited pnlSearchMain: TPanel
        Height = 296
        inherited sbSearchMain: TScrollBox
          Height = 269
        end
      end
      inherited ibgrMain: TgsIBGrid
        Width = 141
        Height = 296
      end
    end
    inherited pnChoose: TPanel
      Top = 302
      Width = 786
      inherited pnButtonChoose: TPanel
        Left = 681
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 681
      end
      inherited pnlChooseCaption: TPanel
        Width = 786
      end
    end
    inherited pnlDetail: TPanel
      Left = 305
      Width = 481
      Height = 296
      inherited TBDockDetail: TTBDock
        Width = 481
      end
      inherited pnlSearchDetail: TPanel
        Height = 270
        TabOrder = 1
        inherited sbSearchDetail: TScrollBox
          Height = 243
        end
      end
      inherited ibgrDetail: TgsIBGrid
        Width = 321
        Height = 270
        TabOrder = 2
      end
    end
  end
  inherited alMain: TActionList
    inherited actDuplicate: TAction
      Visible = False
    end
  end
  inherited dsMain: TDataSource
    DataSet = gdcCurr
  end
  inherited dsDetail: TDataSource
    Left = 475
    Top = 180
  end
  inherited pmDetail: TPopupMenu
    Left = 444
    Top = 181
  end
  object gdcCurr: TgdcCurr
    Left = 112
    Top = 174
  end
  object gdcCurrRate: TgdcCurrRate
    MasterSource = dsMain
    MasterField = 'id'
    DetailField = 'fromcurr'
    SubSet = 'ByFromCurrency'
    Left = 595
    Top = 180
  end
end
