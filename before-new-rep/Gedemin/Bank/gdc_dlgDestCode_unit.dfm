inherited gdc_dlgDestCode: Tgdc_dlgDestCode
  Left = 438
  Top = 265
  Caption = 'Назначение платежа'
  ClientHeight = 107
  ClientWidth = 324
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel [0]
    Left = 5
    Top = 10
    Width = 68
    Height = 13
    Caption = 'Код платежа:'
  end
  object Label2: TLabel [1]
    Left = 5
    Top = 35
    Width = 53
    Height = 13
    Caption = 'Описание:'
  end
  inherited btnAccess: TButton
    Left = 5
    Top = 80
    TabOrder = 2
  end
  inherited btnNew: TButton
    Left = 5
    Top = 80
    TabOrder = 3
  end
  inherited btnOK: TButton
    Left = 165
    Top = 80
    TabOrder = 4
  end
  inherited btnCancel: TButton
    Left = 245
    Top = 80
    TabOrder = 5
  end
  inherited btnHelp: TButton
    Left = 85
    Top = 80
    TabOrder = 6
  end
  object dbeCode: TDBEdit [7]
    Left = 125
    Top = 5
    Width = 196
    Height = 21
    DataField = 'CODE'
    DataSource = dsgdcBase
    TabOrder = 0
  end
  object dbeDescription: TDBEdit [8]
    Left = 5
    Top = 50
    Width = 316
    Height = 21
    DataField = 'DESCRIPTION'
    DataSource = dsgdcBase
    TabOrder = 1
  end
  inherited alBase: TActionList
    Left = 135
    Top = 75
    inherited actSecurity: TAction
      Enabled = False
      Visible = False
    end
  end
  inherited dsgdcBase: TDataSource
    Left = 105
    Top = 75
  end
end
