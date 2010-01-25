object dlgAddTNVD: TdlgAddTNVD
  Left = 348
  Top = 137
  BorderStyle = bsDialog
  Caption = 'ТНВД'
  ClientHeight = 133
  ClientWidth = 277
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 76
    Height = 13
    Caption = 'Наименование'
  end
  object lblTNVD: TLabel
    Left = 8
    Top = 32
    Width = 84
    Height = 13
    Caption = 'Описание ТНВД'
  end
  object btnOk: TButton
    Left = 116
    Top = 104
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 0
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 198
    Top = 104
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 1
    OnClick = btnCancelClick
  end
  object dbeName: TDBEdit
    Left = 112
    Top = 8
    Width = 161
    Height = 21
    DataField = 'NAME'
    DataSource = dsTNVD
    TabOrder = 2
  end
  object dbmDescription: TDBMemo
    Left = 112
    Top = 32
    Width = 161
    Height = 65
    DataField = 'DESCRIPTION'
    DataSource = dsTNVD
    TabOrder = 3
  end
  object ibqryEditTNVD: TIBQuery
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtrTNVD
    BufferChunks = 1000
    CachedUpdates = False
    SQL.Strings = (
      'SELECT'
      '  *'
      'FROM'
      '  gd_tnvd'
      'WHERE'
      '  id = :id')
    UpdateObject = ibudEditTNVD
    Left = 8
    Top = 80
    ParamData = <
      item
        DataType = ftInteger
        Name = 'id'
        ParamType = ptUnknown
        Value = 0
      end>
  end
  object ibudEditTNVD: TIBUpdateSQL
    RefreshSQL.Strings = (
      'Select '
      '  ID,'
      '  NAME,'
      '  DESCRIPTION'
      'from gd_tnvd '
      'where'
      '  ID = :ID')
    ModifySQL.Strings = (
      'update gd_tnvd'
      'set'
      '  ID = :ID,'
      '  NAME = :NAME,'
      '  DESCRIPTION = :DESCRIPTION'
      'where'
      '  ID = :OLD_ID')
    InsertSQL.Strings = (
      'insert into gd_tnvd'
      '  (ID, NAME, DESCRIPTION)'
      'values'
      '  (:ID, :NAME, :DESCRIPTION)')
    DeleteSQL.Strings = (
      'delete from gd_tnvd'
      'where'
      '  ID = :OLD_ID')
    Left = 40
    Top = 80
  end
  object ibqryTnvdID: TIBQuery
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtrTNVD
    BufferChunks = 1000
    CachedUpdates = False
    SQL.Strings = (
      'SELECT '
      '  GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0) id'
      'FROM'
      '  RDB$DATABASE')
    Left = 74
    Top = 80
  end
  object dsTNVD: TDataSource
    DataSet = ibqryEditTNVD
    Left = 112
    Top = 80
  end
  object ibtrTNVD: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    AutoStopAction = saNone
    Left = 74
    Top = 49
  end
end
