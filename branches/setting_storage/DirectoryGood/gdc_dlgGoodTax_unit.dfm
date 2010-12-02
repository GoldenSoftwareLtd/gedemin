inherited gdc_dlgGoodTax: Tgdc_dlgGoodTax
  Left = 368
  Top = 452
  HelpContext = 44
  Caption = 'Параметры налога'
  ClientHeight = 87
  ClientWidth = 327
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel [0]
    Left = 8
    Top = 8
    Width = 73
    Height = 13
    Caption = 'Наименование'
  end
  object lblRate: TLabel [1]
    Left = 8
    Top = 31
    Width = 37
    Height = 13
    Caption = 'Ставка'
  end
  inherited btnAccess: TButton
    Left = 5
    Top = 60
    TabOrder = 4
    Visible = False
  end
  inherited btnNew: TButton
    Left = 5
    Top = 60
    TabOrder = 5
  end
  inherited btnOK: TButton
    Left = 165
    Top = 60
    TabOrder = 2
  end
  inherited btnCancel: TButton
    Left = 245
    Top = 60
    TabOrder = 3
  end
  inherited btnHelp: TButton
    Left = 85
    Top = 60
    TabOrder = 6
  end
  object dbeName: TDBEdit [7]
    Left = 135
    Top = 5
    Width = 186
    Height = 21
    DataField = 'NAME'
    DataSource = dsgdcBase
    TabOrder = 0
  end
  object dbeRate: TDBEdit [8]
    Left = 135
    Top = 30
    Width = 186
    Height = 21
    DataField = 'RATE'
    DataSource = dsgdcBase
    TabOrder = 1
  end
  inherited alBase: TActionList
    Left = 135
    Top = 50
  end
  inherited dsgdcBase: TDataSource
    Left = 105
    Top = 50
  end
end
