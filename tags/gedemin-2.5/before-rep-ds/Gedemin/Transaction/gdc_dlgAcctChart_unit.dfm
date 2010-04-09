inherited gdc_dlgAcctChart: Tgdc_dlgAcctChart
  Left = 325
  Top = 296
  HelpContext = 117
  Caption = 'План счетов'
  ClientHeight = 64
  ClientWidth = 373
  PixelsPerInch = 96
  TextHeight = 13
  object lblName: TLabel [0]
    Left = 8
    Top = 9
    Width = 77
    Height = 13
    Caption = 'Наименование:'
  end
  inherited btnAccess: TButton
    Left = 5
    Top = 36
    TabOrder = 1
  end
  inherited btnNew: TButton
    Left = 77
    Top = 36
    TabOrder = 2
  end
  inherited btnOK: TButton
    Left = 227
    Top = 36
    TabOrder = 3
  end
  inherited btnCancel: TButton
    Left = 299
    Top = 36
    TabOrder = 4
  end
  inherited btnHelp: TButton
    Left = 149
    Top = 36
    TabOrder = 5
  end
  object dbedName: TDBEdit [6]
    Left = 102
    Top = 5
    Width = 265
    Height = 21
    DataField = 'NAME'
    DataSource = dsgdcBase
    TabOrder = 0
  end
  inherited alBase: TActionList
    Left = 242
    Top = 15
  end
  inherited dsgdcBase: TDataSource
    Left = 212
    Top = 15
  end
end
