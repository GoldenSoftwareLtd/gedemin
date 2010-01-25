inherited gdc_wage_dlgTableCalendarDay: Tgdc_wage_dlgTableCalendarDay
  Left = 155
  Top = 205
  Caption = 'Календарный день'
  ClientHeight = 233
  ClientWidth = 463
  Font.Charset = DEFAULT_CHARSET
  Font.Name = 'MS Sans Serif'
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 386
    Top = 73
  end
  inherited btnNew: TButton
    Left = 386
    Top = 105
  end
  inherited btnOK: TButton
    Left = 386
    Top = 9
  end
  inherited btnCancel: TButton
    Left = 386
    Top = 41
  end
  inherited btnHelp: TButton
    Left = 386
    Top = 137
  end
  inherited pgcMain: TPageControl
    Left = 7
    Top = 8
    Width = 370
    Height = 219
    inherited tbsMain: TTabSheet
      inherited labelID: TLabel
        Width = 83
      end
      object Label1: TLabel
        Left = 8
        Top = 35
        Width = 29
        Height = 13
        Caption = 'Дата:'
      end
      object Label3: TLabel
        Left = 8
        Top = 88
        Width = 40
        Height = 13
        Caption = 'Начало:'
      end
      object Label4: TLabel
        Left = 176
        Top = 88
        Width = 58
        Height = 13
        Caption = 'Окончание:'
      end
      object Label5: TLabel
        Left = 8
        Top = 112
        Width = 40
        Height = 13
        Caption = 'Начало:'
      end
      object Label6: TLabel
        Left = 176
        Top = 112
        Width = 58
        Height = 13
        Caption = 'Окончание:'
      end
      object Label7: TLabel
        Left = 8
        Top = 136
        Width = 40
        Height = 13
        Caption = 'Начало:'
      end
      object Label8: TLabel
        Left = 176
        Top = 136
        Width = 58
        Height = 13
        Caption = 'Окончание:'
      end
      object Label9: TLabel
        Left = 8
        Top = 160
        Width = 40
        Height = 13
        Caption = 'Начало:'
      end
      object Label10: TLabel
        Left = 176
        Top = 160
        Width = 58
        Height = 13
        Caption = 'Окончание:'
      end
      object Label12: TLabel
        Left = 8
        Top = 64
        Width = 80
        Height = 13
        Caption = 'Рабочее время:'
      end
      object DBCheckBox1: TDBCheckBox
        Left = 144
        Top = 35
        Width = 97
        Height = 17
        Caption = 'Рабочий день'
        DataField = 'workday'
        DataSource = dsgdcBase
        TabOrder = 1
        ValueChecked = '1'
        ValueUnchecked = '0'
      end
      object xDateDBEdit1: TxDateDBEdit
        Left = 56
        Top = 32
        Width = 65
        Height = 21
        DataField = 'theday'
        DataSource = dsgdcBase
        Kind = kDate
        EditMask = '!99\.99\.9999;1;_'
        MaxLength = 10
        TabOrder = 0
      end
      object xDateDBEdit2: TxDateDBEdit
        Left = 56
        Top = 84
        Width = 113
        Height = 21
        DataField = 'wstart1'
        DataSource = dsgdcBase
        EditMask = '!99\.99\.9999 99\:99\:99;1;_'
        MaxLength = 19
        TabOrder = 2
      end
      object xDateDBEdit3: TxDateDBEdit
        Left = 240
        Top = 84
        Width = 113
        Height = 21
        DataField = 'wend1'
        DataSource = dsgdcBase
        EditMask = '!99\.99\.9999 99\:99\:99;1;_'
        MaxLength = 19
        TabOrder = 3
      end
      object xDateDBEdit4: TxDateDBEdit
        Left = 240
        Top = 108
        Width = 113
        Height = 21
        DataField = 'wend2'
        DataSource = dsgdcBase
        EditMask = '!99\.99\.9999 99\:99\:99;1;_'
        MaxLength = 19
        TabOrder = 5
      end
      object xDateDBEdit5: TxDateDBEdit
        Left = 56
        Top = 108
        Width = 113
        Height = 21
        DataField = 'wstart2'
        DataSource = dsgdcBase
        EditMask = '!99\.99\.9999 99\:99\:99;1;_'
        MaxLength = 19
        TabOrder = 4
      end
      object xDateDBEdit6: TxDateDBEdit
        Left = 240
        Top = 132
        Width = 113
        Height = 21
        DataField = 'wend3'
        DataSource = dsgdcBase
        EditMask = '!99\.99\.9999 99\:99\:99;1;_'
        MaxLength = 19
        TabOrder = 7
      end
      object xDateDBEdit7: TxDateDBEdit
        Left = 56
        Top = 132
        Width = 113
        Height = 21
        DataField = 'wstart3'
        DataSource = dsgdcBase
        EditMask = '!99\.99\.9999 99\:99\:99;1;_'
        MaxLength = 19
        TabOrder = 6
      end
      object xDateDBEdit8: TxDateDBEdit
        Left = 240
        Top = 156
        Width = 113
        Height = 21
        DataField = 'wend4'
        DataSource = dsgdcBase
        EditMask = '!99\.99\.9999 99\:99\:99;1;_'
        MaxLength = 19
        TabOrder = 9
      end
      object xDateDBEdit9: TxDateDBEdit
        Left = 56
        Top = 156
        Width = 113
        Height = 21
        DataField = 'wstart4'
        DataSource = dsgdcBase
        EditMask = '!99\.99\.9999 99\:99\:99;1;_'
        MaxLength = 19
        TabOrder = 8
      end
    end
    inherited tbsAttr: TTabSheet
      inherited atcMain: TatContainer
        Width = 338
        Height = 191
      end
    end
  end
  inherited alBase: TActionList
    Left = 206
    Top = 7
  end
  inherited dsgdcBase: TDataSource
    Left = 176
    Top = 7
  end
  inherited pm_dlgG: TPopupMenu
    Left = 240
    Top = 8
  end
  inherited ibtrCommon: TIBTransaction
    Left = 136
    Top = 8
  end
end
