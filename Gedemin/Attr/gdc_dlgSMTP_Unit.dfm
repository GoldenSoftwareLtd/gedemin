inherited gdc_dlgSMTP: Tgdc_dlgSMTP
  Left = 445
  Top = 232
  Caption = 'gdc_dlgSMTP'
  ClientHeight = 361
  ClientWidth = 399
  Font.Charset = DEFAULT_CHARSET
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel [0]
    Left = 8
    Top = 11
    Width = 77
    Height = 13
    Caption = 'Наименование:'
  end
  object Label2: TLabel [1]
    Left = 8
    Top = 35
    Width = 53
    Height = 13
    Caption = 'Описание:'
  end
  object Label3: TLabel [2]
    Left = 8
    Top = 151
    Width = 70
    Height = 13
    Caption = 'Адрес почты:'
  end
  object Label4: TLabel [3]
    Left = 8
    Top = 175
    Width = 84
    Height = 13
    Caption = 'Учетная запись:'
  end
  object Label5: TLabel [4]
    Left = 8
    Top = 199
    Width = 37
    Height = 13
    Caption = 'Пароль'
  end
  object Label6: TLabel [5]
    Left = 8
    Top = 223
    Width = 125
    Height = 13
    Caption = 'Протокол безопасности:'
  end
  object Label7: TLabel [6]
    Left = 8
    Top = 247
    Width = 88
    Height = 13
    Caption = 'Время ожидания:'
  end
  object Label8: TLabel [7]
    Left = 8
    Top = 103
    Width = 68
    Height = 13
    Caption = 'SMTP сервер:'
  end
  object Label9: TLabel [8]
    Left = 8
    Top = 127
    Width = 57
    Height = 13
    Caption = 'SMTP порт:'
  end
  inherited btnAccess: TButton
    Left = 6
    Top = 330
    TabOrder = 13
  end
  inherited btnNew: TButton
    Left = 78
    Top = 330
    TabOrder = 14
  end
  inherited btnHelp: TButton
    Left = 150
    Top = 330
    TabOrder = 15
  end
  inherited btnOK: TButton
    Left = 252
    Top = 330
    TabOrder = 11
  end
  inherited btnCancel: TButton
    Left = 324
    Top = 330
    TabOrder = 12
  end
  object dbeName: TDBEdit [14]
    Left = 144
    Top = 9
    Width = 249
    Height = 21
    DataField = 'name'
    DataSource = dsgdcBase
    TabOrder = 0
  end
  object dbmDescription: TDBMemo [15]
    Left = 144
    Top = 33
    Width = 249
    Height = 65
    DataField = 'description'
    DataSource = dsgdcBase
    TabOrder = 1
  end
  object dbeEMAIL: TDBEdit [16]
    Left = 144
    Top = 149
    Width = 249
    Height = 21
    DataField = 'email'
    DataSource = dsgdcBase
    TabOrder = 4
  end
  object dbeLogin: TDBEdit [17]
    Left = 144
    Top = 173
    Width = 249
    Height = 21
    DataField = 'login'
    DataSource = dsgdcBase
    TabOrder = 5
  end
  object dbcbIPSec: TDBComboBox [18]
    Left = 144
    Top = 221
    Width = 249
    Height = 21
    DataField = 'ipsec'
    DataSource = dsgdcBase
    ItemHeight = 13
    Items.Strings = (
      'SSLV2'
      'SSLV23'
      'SSLV3'
      'TLSV1')
    TabOrder = 7
  end
  object dbeTimeout: TDBEdit [19]
    Left = 144
    Top = 245
    Width = 249
    Height = 21
    DataField = 'timeout'
    DataSource = dsgdcBase
    TabOrder = 8
  end
  object dbeServer: TDBEdit [20]
    Left = 144
    Top = 101
    Width = 249
    Height = 21
    DataField = 'server'
    DataSource = dsgdcBase
    TabOrder = 2
  end
  object dbePort: TDBEdit [21]
    Left = 144
    Top = 125
    Width = 249
    Height = 21
    DataField = 'port'
    DataSource = dsgdcBase
    TabOrder = 3
  end
  object dbcbDisabled: TDBCheckBox [22]
    Left = 144
    Top = 272
    Width = 121
    Height = 17
    Caption = 'Запись отключена'
    DataField = 'disabled'
    DataSource = dsgdcBase
    TabOrder = 9
    ValueChecked = '1'
    ValueUnchecked = '0'
  end
  object btnTest: TButton [23]
    Left = 143
    Top = 297
    Width = 137
    Height = 21
    Action = actCheckConnect
    TabOrder = 10
  end
  object edPassw: TEdit [24]
    Left = 144
    Top = 197
    Width = 249
    Height = 21
    PasswordChar = '*'
    TabOrder = 6
  end
  object dbcbPrincipal: TDBCheckBox [25]
    Left = 8
    Top = 272
    Width = 97
    Height = 17
    Caption = 'Основной'
    DataField = 'PRINCIPAL'
    DataSource = dsgdcBase
    TabOrder = 16
    ValueChecked = '1'
    ValueUnchecked = '0'
  end
  inherited alBase: TActionList
    Left = 284
    Top = 307
    object actCheckConnect: TAction
      Caption = 'Проверить соединение'
      OnExecute = actCheckConnectExecute
    end
  end
  inherited dsgdcBase: TDataSource
    Left = 246
    Top = 307
  end
  inherited pm_dlgG: TPopupMenu
    Left = 318
    Top = 308
  end
  inherited ibtrCommon: TIBTransaction
    Left = 358
    Top = 308
  end
end
