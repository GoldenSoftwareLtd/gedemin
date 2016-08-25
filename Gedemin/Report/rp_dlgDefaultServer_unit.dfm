object dlgDefaultServer: TdlgDefaultServer
  Left = 248
  Top = 237
  BorderStyle = bsDialog
  Caption = 'Сервер отчетов используемый по умолчанию'
  ClientHeight = 71
  ClientWidth = 357
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 12
    Width = 188
    Height = 13
    Caption = 'Текущий сервер построения отчетов'
  end
  object dblcDefaultServer: TDBLookupComboBox
    Left = 208
    Top = 8
    Width = 145
    Height = 21
    DataField = 'SERVERKEY'
    DataSource = dsDefaultServer
    KeyField = 'ID'
    ListField = 'COMPUTERNAME'
    ListSource = dsServerList
    TabOrder = 0
    OnKeyDown = dblcDefaultServerKeyDown
  end
  object btnOK: TButton
    Left = 192
    Top = 40
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 277
    Top = 40
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 2
  end
  object ibqryServerList: TIBQuery
    Database = dmDatabase.ibdbGAdmin
    Transaction = dmDatabase.ibtrAttr
    BufferChunks = 1000
    CachedUpdates = False
    SQL.Strings = (
      'SELECT'
      '  *'
      'FROM'
      '  rp_reportserver')
    Left = 160
    Top = 40
  end
  object ibdsDefaultServer: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = dmDatabase.ibtrAttr
    BufferChunks = 1000
    CachedUpdates = False
    DeleteSQL.Strings = (
      'delete from rp_reportdefaultserver'
      'where'
      '  SERVERKEY = :OLD_SERVERKEY and'
      '  CLIENTNAME = :OLD_CLIENTNAME')
    InsertSQL.Strings = (
      'insert into rp_reportdefaultserver'
      '  (SERVERKEY, CLIENTNAME)'
      'values'
      '  (:SERVERKEY, :CLIENTNAME)')
    RefreshSQL.Strings = (
      'Select '
      '  *'
      'from rp_reportdefaultserver '
      'where'
      '  SERVERKEY = :SERVERKEY and'
      '  CLIENTNAME = :CLIENTNAME')
    SelectSQL.Strings = (
      'SELECT'
      '  *'
      'FROM'
      '  rp_reportdefaultserver'
      'WHERE'
      '  clientname = :clientname')
    ModifySQL.Strings = (
      'update rp_reportdefaultserver'
      'set'
      '  SERVERKEY = :SERVERKEY,'
      '  CLIENTNAME = :CLIENTNAME'
      'where'
      '  SERVERKEY = :OLD_SERVERKEY and'
      '  CLIENTNAME = :OLD_CLIENTNAME')
    Left = 72
    Top = 40
  end
  object dsDefaultServer: TDataSource
    DataSet = ibdsDefaultServer
    Left = 40
    Top = 40
  end
  object dsServerList: TDataSource
    DataSet = ibqryServerList
    Left = 128
    Top = 40
  end
end
