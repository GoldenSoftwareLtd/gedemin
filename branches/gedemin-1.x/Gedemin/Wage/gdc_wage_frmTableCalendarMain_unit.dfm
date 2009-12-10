inherited gdc_wage_frmTableCalendarMain: Tgdc_wage_frmTableCalendarMain
  Left = 218
  Top = 172
  Width = 696
  Caption = 'gdc_wage_frmTableCalendarMain'
  OldCreateOrder = False
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
