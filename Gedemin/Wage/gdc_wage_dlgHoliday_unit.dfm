inherited gdc_wage_dlgHoliday: Tgdc_wage_dlgHoliday
  Left = 315
  Top = 286
  Caption = 'Государственный праздник'
  ClientHeight = 149
  ClientWidth = 388
  Font.Charset = DEFAULT_CHARSET
  Font.Name = 'MS Sans Serif'
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 14
  inherited btnAccess: TButton
    Left = 310
    Top = 66
  end
  inherited btnNew: TButton
    Left = 310
    Top = 95
  end
  inherited btnHelp: TButton
    Left = 310
    Top = 124
  end
  inherited btnOK: TButton
    Left = 310
    Top = 7
  end
  inherited btnCancel: TButton
    Left = 310
    Top = 36
  end
  inherited pgcMain: TPageControl
    Width = 293
    Height = 139
    inherited tbsMain: TTabSheet
      inherited labelID: TLabel
        Width = 85
        Height = 14
      end
      object Label1: TLabel
        Left = 8
        Top = 32
        Width = 79
        Height = 14
        Caption = 'Наименование:'
      end
      object Label2: TLabel
        Left = 8
        Top = 83
        Width = 29
        Height = 14
        Caption = 'Дата:'
      end
      object dbedName: TDBEdit
        Left = 8
        Top = 48
        Width = 273
        Height = 22
        DataField = 'NAME'
        DataSource = dsgdcBase
        TabOrder = 0
      end
      object dbeHolidaydate: TxDateDBEdit
        Left = 72
        Top = 80
        Width = 89
        Height = 22
        DataField = 'holidaydate'
        DataSource = dsgdcBase
        Kind = kDate
        EditMask = '!99\.99\.9999;1;_'
        MaxLength = 10
        TabOrder = 1
      end
    end
  end
  inherited alBase: TActionList
    Left = 198
    Top = 7
  end
  inherited dsgdcBase: TDataSource
    Left = 168
    Top = 7
  end
  inherited pm_dlgG: TPopupMenu
    Left = 240
    Top = 8
  end
  inherited ibtrCommon: TIBTransaction
    Left = 272
    Top = 8
  end
end
