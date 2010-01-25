object Form1: TForm1
  Left = 140
  Top = 124
  Width = 544
  Height = 375
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object DBGrid1: TDBGrid
    Left = 120
    Top = 8
    Width = 408
    Height = 329
    DataSource = DataSource1
    PopupMenu = PopupMenu1
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
  end
  object Button1: TButton
    Left = 8
    Top = 80
    Width = 97
    Height = 25
    Caption = 'Disconnect'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 8
    Top = 112
    Width = 97
    Height = 25
    Caption = 'End Transaction'
    TabOrder = 2
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 8
    Top = 144
    Width = 97
    Height = 25
    Caption = 'Commit Retaining'
    TabOrder = 3
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 8
    Top = 176
    Width = 97
    Height = 25
    Caption = 'Button4'
    TabOrder = 4
  end
  object IBQuery1: TIBQuery
    Database = IBDatabase1
    Transaction = IBTransaction1
    BufferChunks = 1000
    CachedUpdates = False
    SQL.Strings = (
      'SELECT '
      '  *'
      'FROM'
      '  gd_good')
    Left = 48
    Top = 8
  end
  object DataSource1: TDataSource
    DataSet = IBQuery1
    Left = 80
    Top = 8
  end
  object IBTransaction1: TIBTransaction
    Active = False
    DefaultDatabase = IBDatabase1
    Left = 16
    Top = 40
  end
  object PopupMenu1: TPopupMenu
    Left = 184
    Top = 80
  end
  object gsQueryFilter1: TgsQueryFilter
    Database = IBDatabase1
    IBDataSet = IBQuery1
    Left = 184
    Top = 112
  end
  object IBDatabase1: TIBDatabase
    DatabaseName = 'win2000server:k:\bases\gedemin\gdbase.gdb'
    Params.Strings = (
      'user_name=SYSDBA'
      'password=masterkey'
      'lc_ctype=WIN1251')
    LoginPrompt = False
    DefaultTransaction = IBTransaction1
    IdleTimer = 0
    SQLDialect = 3
    TraceFlags = []
    Left = 16
    Top = 8
  end
end
