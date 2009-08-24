object Form1: TForm1
  Left = 335
  Top = 356
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
  object sqlNameList: TIBSQL
    Database = Database
    ParamCheck = True
    SQL.Strings = (
      'select'
      '  distinct name'
      'from'
      '  evt_object'
      'WHERE'
      '  (Upper(name) containing('#39'_dlg'#39') or'
      '  Upper(name) containing('#39'_frm'#39')) and'
      '  objecttype = 0'
      'order by name')
    Transaction = Transaction
    Top = 16
  end
  object sqlObject: TIBSQL
    Database = Database
    ParamCheck = True
    SQL.Strings = (
      'SELECT'
      '   *'
      'FROM'
      '  evt_object'
      'WHERE'
      '  name = :name'
      'ORDER BY'
      '  ID desc')
    Transaction = Transaction
    Left = 144
    Top = 16
  end
  object sqlDEvent: TIBSQL
    Database = Database
    ParamCheck = True
    SQL.Strings = (
      'DELETE FROM evt_objectevent WHERE  ID = :ID')
    Transaction = Transaction
    Left = 176
    Top = 16
  end
  object sqlDObject: TIBSQL
    Database = Database
    ParamCheck = True
    SQL.Strings = (
      'DELETE FROM evt_object WHERE name = :name and id <> :id')
    Transaction = Transaction
    Left = 32
    Top = 16
  end
  object sqlUObject: TIBSQL
    Database = Database
    ParamCheck = True
    SQL.Strings = (
      'UPDATE evt_object'
      'SET'
      '   parent = null'
      'WHERE'
      '  (name containing '#39'_dlg'#39' or'
      '  name containing '#39'_frm'#39') and'
      '  objecttype = 0')
    Transaction = Transaction
    Left = 224
    Top = 16
  end
  object IBScript1: TIBScript
    Database = Database
    Transaction = Transaction
    Terminator = ';'
    Script.Strings = (
      
        'ALTER TABLE EVT_OBJECTEVENT DROP CONSTRAINT EVT_FK_OBJECT_OBJECT' +
        'KEY;'
      'alter table EVT_OBJECTEVENT'
      'add constraint EVT_FK_OBJECT_OBJECTKEY'
      'foreign key (OBJECTKEY)'
      'references EVT_OBJECT(ID)'
      'on delete CASCADE'
      'on update CASCADE;')
  end
end
