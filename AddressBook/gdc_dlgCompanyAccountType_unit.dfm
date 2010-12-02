inherited gdc_dlgCompanyAccountType: Tgdc_dlgCompanyAccountType
  Left = 385
  Top = 297
  HelpContext = 134
  ClientHeight = 89
  ClientWidth = 326
  PixelsPerInch = 96
  TextHeight = 13
  object Label4: TLabel [0]
    Left = 8
    Top = 9
    Width = 86
    Height = 13
    Caption = 'Идентификатор:'
  end
  object DBText1: TDBText [1]
    Left = 96
    Top = 9
    Width = 142
    Height = 17
    DataField = 'ID'
    DataSource = dsgdcBase
  end
  object Label1: TLabel [2]
    Left = 8
    Top = 37
    Width = 77
    Height = 13
    Caption = '&Наименование:'
  end
  inherited btnAccess: TButton
    Left = 5
    Top = 60
    TabOrder = 4
  end
  inherited btnNew: TButton
    Left = 5
    Top = 60
    TabOrder = 5
  end
  inherited btnOK: TButton
    Left = 165
    Top = 60
    TabOrder = 1
  end
  object dbedName: TDBEdit [6]
    Left = 96
    Top = 32
    Width = 220
    Height = 21
    DataField = 'Name'
    DataSource = dsgdcBase
    TabOrder = 0
  end
  inherited btnCancel: TButton
    Left = 245
    Top = 60
    TabOrder = 2
  end
  inherited btnHelp: TButton
    Left = 85
    Top = 60
    TabOrder = 3
  end
  inherited alBase: TActionList
    Left = 130
    Top = 50
    inherited actSecurity: TAction
      Visible = False
    end
  end
  inherited dsgdcBase: TDataSource
    Left = 100
    Top = 50
  end
end
