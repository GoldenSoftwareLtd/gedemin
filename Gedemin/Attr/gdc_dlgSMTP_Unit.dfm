inherited gdc_dlgSMTP: Tgdc_dlgSMTP
  Left = 435
  Top = 221
  Caption = 'gdc_dlgSMTP'
  ClientHeight = 383
  ClientWidth = 397
  Font.Charset = DEFAULT_CHARSET
  Font.Name = 'MS Sans Serif'
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel [0]
    Left = 8
    Top = 10
    Width = 79
    Height = 13
    Caption = 'Наименование:'
  end
  object Label2: TLabel [1]
    Left = 8
    Top = 34
    Width = 53
    Height = 13
    Caption = 'Описание:'
  end
  object Label3: TLabel [2]
    Left = 8
    Top = 106
    Width = 135
    Height = 13
    Caption = 'Адрес электронной почты:'
  end
  object Label4: TLabel [3]
    Left = 8
    Top = 130
    Width = 25
    Height = 13
    Caption = 'Имя:'
  end
  object Label5: TLabel [4]
    Left = 8
    Top = 154
    Width = 38
    Height = 13
    Caption = 'Пароль'
  end
  object Label6: TLabel [5]
    Left = 8
    Top = 178
    Width = 126
    Height = 13
    Caption = 'Протокол безопасности:'
  end
  object Label7: TLabel [6]
    Left = 8
    Top = 202
    Width = 87
    Height = 13
    Caption = 'Время одидания:'
  end
  object Label8: TLabel [7]
    Left = 8
    Top = 226
    Width = 72
    Height = 13
    Caption = 'SMTP сервер:'
  end
  object Label9: TLabel [8]
    Left = 8
    Top = 250
    Width = 59
    Height = 13
    Caption = 'SMTP порт:'
  end
  inherited btnAccess: TButton
    Top = 350
  end
  inherited btnNew: TButton
    Top = 350
  end
  inherited btnHelp: TButton
    Top = 350
  end
  inherited btnOK: TButton
    Left = 248
    Top = 350
  end
  inherited btnCancel: TButton
    Left = 320
    Top = 350
  end
  object dbeName: TDBEdit [14]
    Left = 144
    Top = 8
    Width = 249
    Height = 21
    DataField = 'name'
    DataSource = dsgdcBase
    TabOrder = 5
  end
  object dbmDescription: TDBMemo [15]
    Left = 144
    Top = 32
    Width = 249
    Height = 65
    DataField = 'description'
    DataSource = dsgdcBase
    TabOrder = 6
  end
  object dbeEMAIL: TDBEdit [16]
    Left = 144
    Top = 104
    Width = 249
    Height = 21
    DataField = 'email'
    DataSource = dsgdcBase
    TabOrder = 7
  end
  object dbeLogin: TDBEdit [17]
    Left = 144
    Top = 128
    Width = 249
    Height = 21
    DataField = 'login'
    DataSource = dsgdcBase
    TabOrder = 8
  end
  object dbcbIPSec: TDBComboBox [18]
    Left = 144
    Top = 176
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
    TabOrder = 9
  end
  object dbeTimeout: TDBEdit [19]
    Left = 144
    Top = 200
    Width = 249
    Height = 21
    DataField = 'timeout'
    DataSource = dsgdcBase
    TabOrder = 10
  end
  object dbeServer: TDBEdit [20]
    Left = 144
    Top = 224
    Width = 249
    Height = 21
    DataField = 'server'
    DataSource = dsgdcBase
    TabOrder = 11
  end
  object dbePort: TDBEdit [21]
    Left = 144
    Top = 248
    Width = 249
    Height = 21
    DataField = 'port'
    DataSource = dsgdcBase
    TabOrder = 12
  end
  object dbcbDisabled: TDBCheckBox [22]
    Left = 8
    Top = 282
    Width = 121
    Height = 17
    Caption = 'Запись отключена'
    DataField = 'disabled'
    DataSource = dsgdcBase
    TabOrder = 13
    ValueChecked = '1'
    ValueUnchecked = '0'
  end
  object Button1: TButton [23]
    Left = 8
    Top = 312
    Width = 137
    Height = 25
    Action = actCheckConnect
    TabOrder = 14
  end
  object edPassw: TEdit [24]
    Left = 144
    Top = 152
    Width = 249
    Height = 21
    PasswordChar = '*'
    TabOrder = 15
    Text = 'edPassw'
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
