object Form1: TForm1
  Left = 261
  Top = 261
  Width = 696
  Height = 155
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 96
    Top = 40
    Width = 32
    Height = 13
    Caption = 'Label1'
  end
  object Edit: TEdit
    Left = 96
    Top = 16
    Width = 441
    Height = 21
    TabOrder = 0
    Text = 'd:\golden\gedemin\*.pas'
  end
  object Button1: TButton
    Left = 184
    Top = 88
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 1
    OnClick = Button1Click
  end
  object xFileList: TxFileList
    Active = False
    Sorting = srNO
    GoSubDirs = True
    TextCase = csLower
    Left = 328
    Top = 48
  end
  object IBDatabase: TIBDatabase
    DatabaseName = 'ibserver:k:\bases\test\etalon.fdb'
    Params.Strings = (
      'user_name=sysdba'
      'password=masterkey'
      'lc_ctype=WIN1251')
    LoginPrompt = False
    DefaultTransaction = IBTransaction
    Left = 424
    Top = 64
  end
  object IBTransaction: TIBTransaction
    Active = False
    DefaultDatabase = IBDatabase
    Params.Strings = (
      'concurrency'
      'nowait')
    AutoStopAction = saNone
    Left = 456
    Top = 64
  end
end
