inherited gdc_wage_frmTableCalendarMain: Tgdc_wage_frmTableCalendarMain
  Left = 440
  Top = 214
  Width = 696
  Caption = 'gdc_wage_frmTableCalendarMain'
  OldCreateOrder = False
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
        ReadOnly = False
      end
    end
  end
  inherited dsMain: TDataSource
    DataSet = gdcTableCalendar
  end
  inherited dsDetail: TDataSource
    DataSet = gdcTableCalendarDay
  end
  object gdcTableCalendar: TgdcTableCalendar
    Left = 112
    Top = 160
  end
  object gdcTableCalendarDay: TgdcTableCalendarDay
    MasterSource = dsMain
    MasterField = 'id'
    DetailField = 'tblcalkey'
    SubSet = 'ByTableCalendar'
    Left = 376
    Top = 224
  end
end
