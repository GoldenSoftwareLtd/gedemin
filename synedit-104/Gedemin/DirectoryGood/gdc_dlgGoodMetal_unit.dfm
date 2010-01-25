inherited gdc_dlgGoodMetal: Tgdc_dlgGoodMetal
  Left = 311
  Top = 203
  Caption = 'Драгметалл'
  ClientHeight = 131
  ClientWidth = 325
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
    Top = 32
    Width = 53
    Height = 13
    Caption = 'Описание:'
  end
  inherited btnAccess: TButton
    Left = 5
    Top = 105
    TabOrder = 5
    Visible = False
  end
  inherited btnNew: TButton
    Left = 5
    Top = 105
    TabOrder = 6
  end
  inherited btnOK: TButton
    Left = 165
    Top = 105
    TabOrder = 2
  end
  inherited btnCancel: TButton
    Left = 245
    Top = 105
    TabOrder = 3
  end
  inherited btnHelp: TButton
    Left = 85
    Top = 105
  end
  object dbeName: TDBEdit [7]
    Left = 110
    Top = 10
    Width = 206
    Height = 21
    DataField = 'NAME'
    DataSource = dsgdcBase
    TabOrder = 0
  end
  object dbmDescription: TDBMemo [8]
    Left = 110
    Top = 35
    Width = 206
    Height = 66
    DataField = 'DESCRIPTION'
    DataSource = dsgdcBase
    TabOrder = 1
  end
  inherited alBase: TActionList
    Left = 50
    Top = 65
  end
  inherited dsgdcBase: TDataSource
    Left = 20
    Top = 65
  end
end
