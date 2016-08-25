object UnvisibleForm: TUnvisibleForm
  Left = 524
  Top = 261
  Width = 259
  Height = 77
  Caption = 'UnvisibleForm'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 88
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Close'
    TabOrder = 0
    OnClick = Button1Click
  end
  object gsIBDatabase: TIBDatabase
    DatabaseName = 'mensk:k:\bases\gedemin\gdbase.gdb'
    Params.Strings = (
      'user_name=SYSDBA'
      'password=masterkey'
      'lc_ctype=WIN1251')
    LoginPrompt = False
    AllowStreamedConnected = False
    AfterConnect = gsIBDatabaseAfterConnect
    BeforeDisconnect = gsIBDatabaseBeforeDisconnect
    Left = 8
    Top = 8
  end
  object ServerReport: TServerReport
    OnCreateObject = ServerReportCreateObject
    Database = gsIBDatabase
    Left = 208
    Top = 8
  end
  object IBTransaction: TIBTransaction
    Active = False
    DefaultDatabase = gsIBDatabase
    Params.Strings = (
      'concurrency'
      'nowait')
    AutoStopAction = saNone
    Left = 176
    Top = 8
  end
  object IBEvents1: TIBEvents
    AutoRegister = False
    Database = gsIBDatabase
    Events.Strings = (
      'CloseGedemin')
    Registered = False
    OnEventAlert = IBEvents1EventAlert
    OnError = IBEvents1Error
    Left = 40
    Top = 8
  end
end
