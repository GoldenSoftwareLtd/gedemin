object dlgSetParamValue: TdlgSetParamValue
  Left = 244
  Top = 167
  BorderStyle = bsDialog
  Caption = 'Соотношение единиц измерения'
  ClientHeight = 145
  ClientWidth = 324
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
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 150
    Height = 13
    Caption = 'Базовая единица измерения:'
  end
  object lblBaseValue: TLabel
    Left = 168
    Top = 8
    Width = 61
    Height = 13
    Caption = 'lblBaseValue'
  end
  object Label2: TLabel
    Left = 8
    Top = 32
    Width = 125
    Height = 13
    Caption = 'Коэффициент пересчета'
  end
  object Label3: TLabel
    Left = 8
    Top = 56
    Width = 129
    Height = 13
    Caption = 'Скидка на ед. измерения'
  end
  object Label4: TLabel
    Left = 8
    Top = 80
    Width = 150
    Height = 13
    Caption = 'Кол-во знаков после запятой'
  end
  object dbeScale: TDBEdit
    Left = 168
    Top = 32
    Width = 153
    Height = 21
    DataField = 'SCALE'
    DataSource = dsEditGoodValue
    TabOrder = 0
  end
  object dbeDiscount: TDBEdit
    Left = 168
    Top = 56
    Width = 153
    Height = 21
    DataField = 'DISCOUNT'
    DataSource = dsEditGoodValue
    TabOrder = 1
  end
  object btnOk: TButton
    Left = 165
    Top = 117
    Width = 75
    Height = 25
    Caption = 'OK
    Default = True
    ModalResult = 1
    TabOrder = 3
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 247
    Top = 117
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 4
    OnClick = btnCancelClick
  end
  object dbeDecDigit: TDBEdit
    Left = 168
    Top = 80
    Width = 153
    Height = 21
    DataField = 'DECDIGIT'
    DataSource = dsEditGoodValue
    TabOrder = 2
  end
  object ibqryEditGoodValue: TIBQuery
    Database = dmDatabase.ibdbGAdmin
    Transaction = dmDatabase.ibtrGAdmin
    BufferChunks = 1000
    CachedUpdates = False
    SQL.Strings = (
      'SELECT'
      '  ggv.*'
      '  , gv.name'
      'FROM'
      '  gd_goodvalue ggv'
      '  , gd_value gv'
      'WHERE'
      '  ggv.goodkey = :goodkey'
      '  AND ggv.valuekey = :valuekey'
      '  AND gv.id = ggv.valuekey')
    UpdateObject = ibudEditGoodValue
    Left = 8
    Top = 96
    ParamData = <
      item
        DataType = ftFloat
        Name = 'goodkey'
        ParamType = ptUnknown
        Value = 0
      end
      item
        DataType = ftInteger
        Name = 'valuekey'
        ParamType = ptUnknown
        Value = 0
      end>
  end
  object ibudEditGoodValue: TIBUpdateSQL
    RefreshSQL.Strings = (
      'Select '
      '  GOODKEY,'
      '  VALUEKEY,'
      '  SCALE,'
      '  DISCOUNT,'
      '  DECDIGIT'
      'from gd_goodvalue '
      'where'
      '  GOODKEY = :GOODKEY and'
      '  VALUEKEY = :VALUEKEY')
    ModifySQL.Strings = (
      'update gd_goodvalue'
      'set'
      '  GOODKEY = :GOODKEY,'
      '  VALUEKEY = :VALUEKEY,'
      '  SCALE = :SCALE,'
      '  DISCOUNT = :DISCOUNT,'
      '  DECDIGIT = :DECDIGIT'
      'where'
      '  GOODKEY = :OLD_GOODKEY and'
      '  VALUEKEY = :OLD_VALUEKEY')
    InsertSQL.Strings = (
      'insert into gd_goodvalue'
      '  (GOODKEY, VALUEKEY, SCALE, DISCOUNT, DECDIGIT)'
      'values'
      '  (:GOODKEY, :VALUEKEY, :SCALE, :DISCOUNT, :DECDIGIT)')
    DeleteSQL.Strings = (
      'delete from gd_goodvalue'
      'where'
      '  GOODKEY = :OLD_GOODKEY and'
      '  VALUEKEY = :OLD_VALUEKEY')
    Left = 40
    Top = 96
  end
  object dsEditGoodValue: TDataSource
    DataSet = ibqryEditGoodValue
    Left = 72
    Top = 96
  end
end
