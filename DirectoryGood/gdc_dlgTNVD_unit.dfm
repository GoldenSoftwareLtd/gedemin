inherited gdc_dlgTNVD: Tgdc_dlgTNVD
  Left = 319
  Top = 229
  HelpContext = 45
  Caption = 'ТНВД'
  ClientHeight = 132
  ClientWidth = 402
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel [0]
    Left = 8
    Top = 8
    Width = 73
    Height = 13
    Caption = 'Наименование'
  end
  object lblTNVD: TLabel [1]
    Left = 8
    Top = 32
    Width = 79
    Height = 13
    Caption = 'Описание ТНВД'
  end
  inherited btnAccess: TButton
    Left = 5
    Top = 105
    TabOrder = 3
  end
  inherited btnNew: TButton
    Left = 85
    Top = 105
    TabOrder = 5
  end
  inherited btnOK: TButton
    Left = 245
    Top = 105
    TabOrder = 4
  end
  inherited btnCancel: TButton
    Left = 325
    Top = 105
    TabOrder = 6
  end
  inherited btnHelp: TButton
    Left = 165
    Top = 105
    TabOrder = 2
  end
  object dbeName: TDBEdit [7]
    Left = 110
    Top = 5
    Width = 289
    Height = 21
    DataField = 'NAME'
    DataSource = dsgdcBase
    TabOrder = 0
  end
  object dbmDescription: TDBMemo [8]
    Left = 110
    Top = 30
    Width = 289
    Height = 66
    DataField = 'DESCRIPTION'
    DataSource = dsgdcBase
    TabOrder = 1
  end
  inherited alBase: TActionList
    Left = 70
    Top = 65
  end
  inherited dsgdcBase: TDataSource
    DataSet = gdcTNVD
    Left = 40
    Top = 65
  end
  object gdcTNVD: TgdcTNVD
    Left = 100
    Top = 65
  end
end
