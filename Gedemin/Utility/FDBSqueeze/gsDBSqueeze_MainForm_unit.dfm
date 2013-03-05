object gsDBSqueeze_MainForm: TgsDBSqueeze_MainForm
  Left = 197
  Top = 469
  BorderStyle = bsDialog
  Caption = 'gsDBSqueeze_MainForm'
  ClientHeight = 165
  ClientWidth = 315
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  PixelsPerInch = 96
  TextHeight = 13
  object lbl1: TLabel
    Left = 24
    Top = 16
    Width = 50
    Height = 13
    Caption = 'Database:'
  end
  object lbl2: TLabel
    Left = 23
    Top = 64
    Width = 26
    Height = 13
    Caption = 'User:'
  end
  object lbl3: TLabel
    Left = 153
    Top = 64
    Width = 50
    Height = 13
    Caption = 'Password:'
  end
  object edDatabaseName: TEdit
    Left = 24
    Top = 32
    Width = 272
    Height = 21
    TabOrder = 0
    Text = 'C:\Users\mk\Desktop\BUSINESS_2.fdb'
  end
  object edUserName: TEdit
    Left = 55
    Top = 60
    Width = 88
    Height = 21
    TabOrder = 1
    Text = 'SYSDBA'
  end
  object edPassword: TEdit
    Left = 208
    Top = 60
    Width = 88
    Height = 21
    PasswordChar = '*'
    TabOrder = 2
    Text = 'masterkey'
  end
  object btnConnect: TButton
    Left = 138
    Top = 92
    Width = 75
    Height = 21
    Action = actConnect
    TabOrder = 3
  end
  object btnDisconnect: TButton
    Left = 220
    Top = 92
    Width = 75
    Height = 21
    Action = actDisconnect
    TabOrder = 4
  end
  object ActionList: TActionList
    Left = 256
    Top = 16
    object actConnect: TAction
      Caption = 'Connect'
      OnExecute = actConnectExecute
      OnUpdate = actConnectUpdate
    end
    object actDisconnect: TAction
      Caption = 'Disconnect'
      OnExecute = actDisconnectExecute
      OnUpdate = actDisconnectUpdate
    end
  end
end
