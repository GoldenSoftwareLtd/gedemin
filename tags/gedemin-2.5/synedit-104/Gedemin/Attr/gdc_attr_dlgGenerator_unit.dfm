inherited gdc_dlgGenerator: Tgdc_dlgGenerator
  Left = 401
  Top = 242
  Caption = 'Генератор'
  ClientHeight = 109
  ClientWidth = 437
  PixelsPerInch = 96
  TextHeight = 13
  object lblGeneratorName: TLabel [0]
    Left = 10
    Top = 12
    Width = 77
    Height = 13
    Caption = 'Наименование:'
  end
  object lblGeneratorValue: TLabel [1]
    Left = 10
    Top = 42
    Width = 48
    Height = 13
    Caption = 'Значение'
  end
  inherited btnAccess: TButton
    Top = 77
  end
  inherited btnNew: TButton
    Top = 77
  end
  inherited btnOK: TButton
    Left = 289
    Top = 77
  end
  inherited btnCancel: TButton
    Left = 361
    Top = 77
  end
  inherited btnHelp: TButton
    Top = 77
  end
  object dbeGeneratorName: TDBEdit [7]
    Left = 105
    Top = 8
    Width = 201
    Height = 21
    DataField = 'GENERATORNAME'
    DataSource = dsgdcBase
    TabOrder = 5
  end
  object edGeneratorValue: TEdit [8]
    Left = 105
    Top = 38
    Width = 121
    Height = 21
    Enabled = False
    TabOrder = 6
    Text = 'edGeneratorValue'
  end
  inherited alBase: TActionList
    Left = 342
    Top = 31
  end
  inherited dsgdcBase: TDataSource
    Left = 344
    Top = 65535
  end
  inherited pm_dlgG: TPopupMenu
    Left = 376
    Top = 32
  end
end
