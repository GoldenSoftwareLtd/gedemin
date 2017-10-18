inherited gdc_dlgException: Tgdc_dlgException
  Left = 696
  Top = 507
  HelpContext = 79
  Caption = 'Исключение'
  ClientHeight = 145
  ClientWidth = 441
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel [0]
    Left = 16
    Top = 24
    Width = 52
    Height = 13
    Caption = 'Название:'
  end
  object Label2: TLabel [1]
    Left = 16
    Top = 48
    Width = 62
    Height = 13
    Caption = 'Сообщение:'
  end
  object Label3: TLabel [2]
    Left = 16
    Top = 72
    Width = 147
    Height = 13
    Caption = 'Локализованное сообщение:'
  end
  inherited btnAccess: TButton
    Left = 16
    Top = 109
    TabOrder = 5
  end
  inherited btnNew: TButton
    Left = 88
    Top = 109
    TabOrder = 6
  end
  inherited btnHelp: TButton
    Left = 160
    Top = 109
    TabOrder = 7
  end
  inherited btnOK: TButton
    Left = 284
    Top = 109
    TabOrder = 3
  end
  inherited btnCancel: TButton
    Left = 357
    Top = 109
    TabOrder = 4
  end
  object dbeName: TDBEdit [8]
    Left = 184
    Top = 20
    Width = 242
    Height = 21
    CharCase = ecUpperCase
    DataField = 'exceptionname'
    DataSource = dsgdcBase
    MaxLength = 31
    TabOrder = 0
  end
  object dbeMessage: TDBEdit [9]
    Left = 184
    Top = 45
    Width = 242
    Height = 21
    DataField = 'exceptionmessage'
    DataSource = dsgdcBase
    TabOrder = 1
  end
  object dbeLMessage: TDBEdit [10]
    Left = 184
    Top = 69
    Width = 242
    Height = 21
    DataField = 'lmessage'
    DataSource = dsgdcBase
    TabOrder = 2
  end
  inherited alBase: TActionList
    Left = 134
    Top = 7
  end
  inherited dsgdcBase: TDataSource
    Left = 104
    Top = 7
  end
end
