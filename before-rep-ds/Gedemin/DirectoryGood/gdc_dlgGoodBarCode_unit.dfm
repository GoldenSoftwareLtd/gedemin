inherited gdc_dlgGoodBarCode: Tgdc_dlgGoodBarCode
  Left = 362
  Top = 369
  Caption = 'Штрих код'
  ClientHeight = 93
  ClientWidth = 328
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel [0]
    Left = 8
    Top = 12
    Width = 77
    Height = 13
    Caption = 'Наименование:'
  end
  object lblTNVD: TLabel [1]
    Left = 8
    Top = 39
    Width = 53
    Height = 13
    Caption = 'Описание:'
    WordWrap = True
  end
  inherited btnAccess: TButton
    Left = 5
    Top = 65
    TabOrder = 5
    Visible = False
  end
  inherited btnNew: TButton
    Left = 5
    Top = 65
    TabOrder = 6
  end
  inherited btnOK: TButton
    Left = 178
    Top = 65
    TabOrder = 2
  end
  inherited btnCancel: TButton
    Left = 253
    Top = 65
    TabOrder = 3
  end
  inherited btnHelp: TButton
    Left = 80
    Top = 65
  end
  object dbeBarCode: TDBEdit [7]
    Left = 90
    Top = 10
    Width = 231
    Height = 21
    DataField = 'BARCODE'
    DataSource = dsgdcBase
    TabOrder = 0
  end
  object dbeDescription: TDBEdit [8]
    Left = 89
    Top = 35
    Width = 232
    Height = 21
    DataField = 'DESCRIPTION'
    DataSource = dsgdcBase
    TabOrder = 1
  end
  inherited alBase: TActionList
    Left = 165
    Top = 0
  end
  inherited dsgdcBase: TDataSource
    Left = 135
    Top = 0
  end
end
