object dlgChoosePriceVar: TdlgChoosePriceVar
  Left = 244
  Top = 106
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Выбор переменной'
  ClientHeight = 322
  ClientWidth = 462
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object bOk: TButton
    Left = 364
    Top = 7
    Width = 84
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object bCancel: TButton
    Left = 364
    Top = 35
    Width = 84
    Height = 25
    Cancel = True
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 1
  end
  object lvVariable: TListView
    Left = 11
    Top = 8
    Width = 340
    Height = 305
    Columns = <
      item
        AutoSize = True
        Caption = 'Наименование'
      end
      item
        AutoSize = True
        Caption = 'Переменная'
      end
      item
        AutoSize = True
        Caption = 'Поле в таблице'
      end>
    GridLines = True
    RowSelect = True
    SortType = stText
    TabOrder = 2
    ViewStyle = vsReport
  end
  object IBSQL: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    ParamCheck = True
    SQL.Strings = (
      
        'SELECT * FROM at_relation_fields WHERE relationname = '#39'GD_PRICEP' +
        'OS'#39' AND fieldname <> :fn')
    Transaction = IBTransaction
    Left = 368
    Top = 64
  end
  object IBTransaction: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    Left = 400
    Top = 64
  end
  object ibsqlCur: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    ParamCheck = True
    SQL.Strings = (
      'SELECT * FROM gd_curr ORDER BY name')
    Transaction = IBTransaction
    Left = 368
    Top = 96
  end
end
