inherited gdc_dlgGenerator: Tgdc_dlgGenerator
  Left = 401
  Top = 242
  Caption = '���������'
  ClientHeight = 96
  ClientWidth = 385
  PixelsPerInch = 96
  TextHeight = 13
  object lblGeneratorName: TLabel [0]
    Left = 10
    Top = 12
    Width = 77
    Height = 13
    Caption = '������������:'
  end
  object lblGeneratorValue: TLabel [1]
    Left = 10
    Top = 38
    Width = 52
    Height = 13
    Caption = '��������:'
  end
  inherited btnAccess: TButton
    Top = 65
    TabOrder = 4
  end
  inherited btnNew: TButton
    Top = 65
    TabOrder = 5
  end
  inherited btnHelp: TButton
    Top = 65
    TabOrder = 6
  end
  inherited btnOK: TButton
    Left = 235
    Top = 65
    TabOrder = 2
  end
  inherited btnCancel: TButton
    Left = 307
    Top = 65
    TabOrder = 3
  end
  object dbeGeneratorName: TDBEdit [7]
    Left = 94
    Top = 8
    Width = 163
    Height = 21
    DataField = 'GENERATORNAME'
    DataSource = dsgdcBase
    TabOrder = 0
  end
  object edGeneratorValue: TEdit [8]
    Left = 94
    Top = 34
    Width = 163
    Height = 21
    Enabled = False
    TabOrder = 1
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
