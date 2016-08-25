object dlgAddValue: TdlgAddValue
  Left = 251
  Top = 234
  BorderStyle = bsDialog
  Caption = 'Единица измерения'
  ClientHeight = 139
  ClientWidth = 289
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 12
    Width = 76
    Height = 13
    Caption = 'Наименование'
  end
  object Label2: TLabel
    Left = 8
    Top = 36
    Width = 50
    Height = 13
    Caption = 'Описание'
  end
  object Label3: TLabel
    Left = 8
    Top = 61
    Width = 24
    Height = 13
    Caption = 'ТМЦ'
  end
  object btnOk: TButton
    Left = 125
    Top = 112
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 4
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 207
    Top = 112
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 5
  end
  object dbeName: TDBEdit
    Left = 112
    Top = 8
    Width = 170
    Height = 21
    DataField = 'NAME'
    DataSource = dsValue
    TabOrder = 0
  end
  object dbedDescription: TDBEdit
    Left = 112
    Top = 32
    Width = 170
    Height = 21
    TabOrder = 1
  end
  object gsIBLookupComboBox1: TgsIBLookupComboBox
    Left = 112
    Top = 57
    Width = 170
    Height = 21
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtrValue
    DataSource = dsValue
    DataField = 'GOODKEY'
    ListTable = 'GD_GOOD'
    ListField = 'NAME'
    KeyField = 'ID'
    ItemHeight = 13
    ParentShowHint = False
    ShowHint = True
    TabOrder = 2
  end
  object DBCheckBox1: TDBCheckBox
    Left = 111
    Top = 84
    Width = 165
    Height = 17
    Caption = 'Используется для упаковки'
    DataField = 'ISPACK'
    DataSource = dsValue
    TabOrder = 3
    ValueChecked = '1'
    ValueUnchecked = '0'
  end
  object ibqryEditValue: TIBQuery
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtrValue
    BufferChunks = 1000
    CachedUpdates = False
    SQL.Strings = (
      'SELECT'
      '  *'
      'FROM'
      '  gd_value '
      'WHERE'
      '  id = :id')
    UpdateObject = ibudEditValue
    Left = 184
    Top = 40
    ParamData = <
      item
        DataType = ftInteger
        Name = 'id'
        ParamType = ptUnknown
        Value = 0
      end>
  end
  object ibudEditValue: TIBUpdateSQL
    RefreshSQL.Strings = (
      'Select '
      '  ID,'
      '  NAME,'
      '  DESCRIPTION,'
      '  GOODKEY,'
      '  ISPACK'
      'from gd_value '
      'where'
      '  ID = :ID')
    ModifySQL.Strings = (
      'update gd_value'
      'set'
      '  ID = :ID,'
      '  NAME = :NAME,'
      '  DESCRIPTION = :DESCRIPTION,'
      '  GOODKEY = :GOODKEY,'
      '  ISPACK = :ISPACK'
      'where'
      '  ID = :OLD_ID')
    InsertSQL.Strings = (
      'insert into gd_value'
      '  (ID, NAME, DESCRIPTION, GOODKEY, ISPACK)'
      'values'
      '  (:ID, :NAME, :DESCRIPTION, :GOODKEY, :ISPACK)')
    DeleteSQL.Strings = (
      'delete from gd_value'
      'where'
      '  ID = :OLD_ID')
    Left = 216
    Top = 40
  end
  object dsValue: TDataSource
    DataSet = ibqryEditValue
    Left = 248
    Top = 40
  end
  object ibtrValue: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 184
    Top = 8
  end
end
