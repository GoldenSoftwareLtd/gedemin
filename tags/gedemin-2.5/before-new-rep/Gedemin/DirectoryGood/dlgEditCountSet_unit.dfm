object dlgEditCountSet: TdlgEditCountSet
  Left = 223
  Top = 183
  BorderStyle = bsDialog
  Caption = 'Количество товара'
  ClientHeight = 92
  ClientWidth = 220
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 79
    Height = 13
    Caption = 'Наименование:'
  end
  object Label3: TLabel
    Left = 8
    Top = 32
    Width = 62
    Height = 13
    Caption = 'Количество:'
  end
  object lblName: TLabel
    Left = 96
    Top = 8
    Width = 38
    Height = 13
    Caption = 'lblName'
  end
  object btnOk: TButton
    Left = 53
    Top = 64
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 141
    Top = 64
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 2
    OnClick = btnCancelClick
  end
  object dbeCount: TDBEdit
    Left = 96
    Top = 32
    Width = 121
    Height = 21
    DataField = 'GOODCOUNT'
    DataSource = dsSetCount
    TabOrder = 0
  end
  object ibqrySetCount: TIBQuery
    Database = dmDatabase.ibdbGAdmin
    BufferChunks = 1000
    CachedUpdates = False
    SQL.Strings = (
      'SELECT'
      '  *'
      'FROM'
      '  gd_goodset'
      'WHERE'
      '  setkey = :setkey'
      '  AND goodkey = :goodkey')
    UpdateObject = ibudSetCount
    Left = 8
    Top = 64
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'setkey'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'goodkey'
        ParamType = ptUnknown
      end>
  end
  object ibudSetCount: TIBUpdateSQL
    RefreshSQL.Strings = (
      'Select '
      '  SETKEY,'
      '  GOODKEY,'
      '  GOODCOUNT'
      'from gd_goodset '
      'where'
      '  SETKEY = :SETKEY and'
      '  GOODKEY = :GOODKEY')
    ModifySQL.Strings = (
      'update gd_goodset'
      'set'
      '  SETKEY = :SETKEY,'
      '  GOODKEY = :GOODKEY,'
      '  GOODCOUNT = :GOODCOUNT'
      'where'
      '  SETKEY = :OLD_SETKEY and'
      '  GOODKEY = :OLD_GOODKEY')
    InsertSQL.Strings = (
      'insert into gd_goodset'
      '  (SETKEY, GOODKEY, GOODCOUNT)'
      'values'
      '  (:SETKEY, :GOODKEY, :GOODCOUNT)')
    DeleteSQL.Strings = (
      'delete from gd_goodset'
      'where'
      '  SETKEY = :OLD_SETKEY and'
      '  GOODKEY = :OLD_GOODKEY')
    Left = 40
    Top = 64
  end
  object dsSetCount: TDataSource
    DataSet = ibqrySetCount
    Left = 72
    Top = 64
  end
end
