object Form1: TForm1
  Left = 464
  Top = 261
  Width = 374
  Height = 97
  Caption = 'Добавление поля ИД в таблицу EVT_OBJECTEVENT'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 51
    Height = 13
    Caption = 'Имя базы'
  end
  object Edit1: TEdit
    Left = 64
    Top = 8
    Width = 297
    Height = 21
    TabOrder = 0
  end
  object Button1: TButton
    Left = 288
    Top = 40
    Width = 75
    Height = 25
    Caption = 'Добавить'
    TabOrder = 1
    OnClick = Button1Click
  end
  object IBDatabase1: TIBDatabase
    DefaultTransaction = IBTransaction1
    IdleTimer = 0
    SQLDialect = 3
    TraceFlags = []
    Left = 96
    Top = 32
  end
  object IBTransaction1: TIBTransaction
    Active = False
    DefaultDatabase = IBDatabase1
    AutoStopAction = saNone
    Left = 128
    Top = 32
  end
  object IBSQL1: TIBSQL
    Database = IBDatabase1
    ParamCheck = True
    SQL.Strings = (
      'SELECT'
      '  1 AS EXIST'
      'FROM'
      '  rdb$relation_fields rf'
      'WHERE'
      '  upper(rf.rdb$relation_name) = '#39'EVT_OBJECTEVENT'#39
      '  AND'
      '  upper(rf.RDB$FIELD_NAME) = '#39'ID'#39)
    Transaction = IBTransaction1
    Left = 32
    Top = 32
  end
  object IBSQL2: TIBSQL
    Database = IBDatabase1
    ParamCheck = True
    Transaction = IBTransaction1
    Left = 64
    Top = 32
  end
end
