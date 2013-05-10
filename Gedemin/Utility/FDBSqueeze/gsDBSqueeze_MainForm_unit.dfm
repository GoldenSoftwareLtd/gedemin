object gsDBSqueeze_MainForm: TgsDBSqueeze_MainForm
  Left = 58
  Top = 177
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
  object lbl4: TLabel
    Left = 289
    Top = 7
    Width = 71
    Height = 13
    Caption = 'Выполняется:'
  end
  object lbl5: TLabel
    Left = 8
    Top = 120
    Width = 183
    Height = 13
    Caption = 'Удалить записи из gd_document до:'
  end
  object lbl6: TLabel
    Left = 8
    Top = 152
    Width = 227
    Height = 13
    Caption = 'Компания, для которой рассчитать сальдо: '
  end
  object edDatabaseName: TEdit
    Left = 8
    Top = 24
    Width = 272
    Height = 21
    TabOrder = 0
    Text = 'C:\_BP.fdb'
  end
  object edUserName: TEdit
    Left = 39
    Top = 52
    Width = 88
    Height = 21
    TabOrder = 2
    Text = 'SYSDBA'
  end
  object edPassword: TEdit
    Left = 192
    Top = 52
    Width = 88
    Height = 21
    PasswordChar = '*'
    TabOrder = 3
    Text = 'masterkey'
  end
  object btnConnect: TButton
    Left = 122
    Top = 84
    Width = 75
    Height = 21
    Action = actConnect
    TabOrder = 4
  end
  object btnDisconnect: TButton
    Left = 204
    Top = 84
    Width = 75
    Height = 21
    Action = actDisconnect
    TabOrder = 5
  end
  object mLog: TMemo
    Left = 288
    Top = 24
    Width = 377
    Height = 433
    ScrollBars = ssVertical
    TabOrder = 1
  end
  object dtpDocumentdateWhereClause: TDateTimePicker
    Left = 199
    Top = 117
    Width = 81
    Height = 21
    Hint = 'рассчитать сальдо и удалить документы'
    CalAlignment = dtaLeft
    Date = 41380.5593590046
    Time = 41380.5593590046
    Color = clWhite
    DateFormat = dfShort
    DateMode = dmComboBox
    Kind = dtkDate
    ParseInput = False
    TabOrder = 6
  end
  object cbbCompany: TComboBox
    Left = 7
    Top = 176
    Width = 273
    Height = 21
    ItemHeight = 13
    TabOrder = 7
  end
  object btnGo: TButton
    Left = 104
    Top = 208
    Width = 75
    Height = 21
    Action = actSetCompanyName
    Caption = 'Go!'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 8
  end
  object ActionList: TActionList
    Left = 240
    Top = 8
    object actConnect: TAction
      Caption = 'Connect'
      OnExecute = actConnectExecute
      OnUpdate = actConnectUpdate
    end
    object actSetCompanyName: TAction
      Caption = 'actSetCompanyName'
      OnExecute = actSetCompanyNameExecute
      OnUpdate = actSetCompanyNameUpdate
    end
    object actDisconnect: TAction
      Caption = 'Disconnect'
      OnExecute = actDisconnectExecute
      OnUpdate = actDisconnectUpdate
    end
  end
end
