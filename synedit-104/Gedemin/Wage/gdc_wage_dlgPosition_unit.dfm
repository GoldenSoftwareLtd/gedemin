inherited gdc_wage_dlgPosition: Tgdc_wage_dlgPosition
  Left = 370
  Top = 294
  Caption = 'Должность'
  ClientHeight = 138
  ClientWidth = 408
  Font.Charset = DEFAULT_CHARSET
  Font.Name = 'MS Sans Serif'
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 336
    Top = 62
  end
  inherited btnNew: TButton
    Left = 336
    Top = 86
  end
  inherited btnOK: TButton
    Left = 336
    Top = 6
  end
  inherited btnCancel: TButton
    Left = 336
    Top = 30
  end
  inherited btnHelp: TButton
    Left = 336
    Top = 110
  end
  inherited pgcMain: TPageControl
    Width = 325
    Height = 125
    inherited tbsMain: TTabSheet
      inherited labelID: TLabel
        Width = 83
      end
      object Label2: TLabel
        Left = 8
        Top = 32
        Width = 79
        Height = 13
        Caption = 'Наименование:'
      end
      object DBEdit2: TDBEdit
        Left = 96
        Top = 28
        Width = 217
        Height = 21
        DataField = 'name'
        DataSource = dsgdcBase
        TabOrder = 0
      end
    end
  end
  inherited alBase: TActionList
    Top = 95
  end
  inherited dsgdcBase: TDataSource
    Top = 87
  end
  inherited pm_dlgG: TPopupMenu
    Top = 96
  end
  inherited ibtrCommon: TIBTransaction
    Left = 248
    Top = 88
  end
end
