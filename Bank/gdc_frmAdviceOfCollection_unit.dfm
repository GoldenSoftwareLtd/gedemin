inherited gdc_frmAdviceOfCollection: Tgdc_frmAdviceOfCollection
  Left = 49
  Top = 76
  Caption = 'Инкассовые распоряжения'
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlWorkArea: TPanel
    inherited pnlMain: TPanel
      inherited ibgrMain: TgsIBGrid
        Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit, dgMultiSelect]
      end
    end
  end
  inherited dsMain: TDataSource
    DataSet = gdcAdviceOfCollection
  end
  object gdcAdviceOfCollection: TgdcAdviceOfCollection
    SubSet = 'ByAccount'
    CachedUpdates = False
    Left = 172
    Top = 103
  end
end
