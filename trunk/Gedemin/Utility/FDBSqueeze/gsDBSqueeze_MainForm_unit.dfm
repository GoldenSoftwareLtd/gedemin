object gsDBSqueeze_MainForm: TgsDBSqueeze_MainForm
  Left = 381
  Top = 202
  BorderStyle = bsDialog
  Caption = 'gsDBSqueeze_MainForm'
  ClientHeight = 465
  ClientWidth = 673
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCloseQuery = FormCloseQuery
  PixelsPerInch = 96
  TextHeight = 13
  object lbl1: TLabel
    Left = 8
    Top = 8
    Width = 50
    Height = 13
    Caption = 'Database:'
  end
  object lbl2: TLabel
    Left = 7
    Top = 56
    Width = 26
    Height = 13
    Caption = 'User:'
  end
  object lbl3: TLabel
    Left = 137
    Top = 56
    Width = 50
    Height = 13
    Caption = 'Password:'
  end
  object lblLog: TLabel
    Left = 289
    Top = 7
    Width = 71
    Height = 13
    Caption = 'Выполняется:'
  end
  object Label1: TLabel
    Left = 8
    Top = 120
    Width = 183
    Height = 13
    Caption = 'Удалить записи из gd_document до:'
  end
  object edDatabaseName: TEdit
    Left = 8
    Top = 24
    Width = 272
    Height = 21
    TabOrder = 0
    Text = 'C:\Users\mk\Desktop\BUSINESS_2.fdb'
  end
  object edUserName: TEdit
    Left = 39
    Top = 52
    Width = 88
    Height = 21
    TabOrder = 1
    Text = 'SYSDBA'
  end
  object edPassword: TEdit
    Left = 192
    Top = 52
    Width = 88
    Height = 21
    PasswordChar = '*'
    TabOrder = 2
    Text = 'masterkey'
  end
  object btnConnect: TButton
    Left = 122
    Top = 84
    Width = 75
    Height = 21
    Action = actConnect
    TabOrder = 3
  end
  object btnDisconnect: TButton
    Left = 204
    Top = 84
    Width = 75
    Height = 21
    Action = actDisconnect
    TabOrder = 4
  end
  object mLog: TMemo
    Left = 288
    Top = 24
    Width = 377
    Height = 433
    ScrollBars = ssVertical
    TabOrder = 6
  end
  object dtp: TDateTimePicker
    Left = 199
    Top = 117
    Width = 81
    Height = 21
    CalAlignment = dtaLeft
    Date = 41380.5593590046
    Time = 41380.5593590046
    DateFormat = dfShort
    DateMode = dmComboBox
    Kind = dtkDate
    ParseInput = False
    TabOrder = 5
  end
  object ActionList: TActionList
    Left = 240
    Top = 8
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
