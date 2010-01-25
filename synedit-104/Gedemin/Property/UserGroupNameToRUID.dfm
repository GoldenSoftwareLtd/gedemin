object Form1: TForm1
  Left = 333
  Top = 410
  BorderStyle = bsDialog
  BorderWidth = 5
  Caption = 'Form1'
  ClientHeight = 50
  ClientWidth = 285
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Edit1: TEdit
    Left = 0
    Top = 0
    Width = 280
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
  end
  object Button1: TButton
    Left = 207
    Top = 24
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Go!'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Database: TIBDatabase
    DefaultTransaction = Transaction
    IdleTimer = 0
    SQLDialect = 3
    TraceFlags = []
    Left = 104
    Top = 16
  end
  object Transaction: TIBTransaction
    Active = False
    DefaultDatabase = Database
    AutoStopAction = saNone
    Left = 64
    Top = 16
  end
  object sqlDObject: TIBSQL
    Database = Database
    ParamCheck = True
    SQL.Strings = (
      'SELECT'
      '  usergroupname,'
      '  id'
      'FROM'
      '  rp_reportgroup'
      'WHERE'
      '  usergroupname = cast(id as varchar(20))')
    Transaction = Transaction
    Left = 32
    Top = 16
  end
  object IBSQL1: TIBSQL
    Database = Database
    ParamCheck = True
    SQL.Strings = (
      'UPDATE rp_reportgroup'
      'SET'
      '  usergroupname = :usergroupname'
      'WHERE'
      '  id = :id')
    Transaction = Transaction
    Left = 136
    Top = 16
  end
end
