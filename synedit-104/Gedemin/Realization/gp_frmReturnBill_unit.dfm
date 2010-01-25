inherited frmReturnBill: TfrmReturnBill
  Top = 106
  Caption = 'Накладные на возврат с реализации'
  PixelsPerInch = 96
  TextHeight = 13
  inherited alMain: TActionList
    inherited actDetailBill: TAction
      Visible = False
    end
    inherited actOption: TAction
      Visible = False
    end
  end
  inherited gsMainReportManager: TgsReportManager
    GroupID = 2000002
  end
end
