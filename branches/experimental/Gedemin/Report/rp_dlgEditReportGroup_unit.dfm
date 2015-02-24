object dlgEditReportGroup: TdlgEditReportGroup
  Left = 229
  Top = 179
  BorderStyle = bsDialog
  Caption = 'Параметры группы отчетов'
  ClientHeight = 101
  ClientWidth = 326
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
    Top = 16
    Width = 115
    Height = 13
    Caption = 'Наименование группы'
  end
  object Label2: TLabel
    Left = 8
    Top = 40
    Width = 89
    Height = 13
    Caption = 'Описание группы'
  end
  object dbeName: TDBEdit
    Left = 144
    Top = 13
    Width = 177
    Height = 21
    DataField = 'NAME'
    DataSource = dsReportGroup
    TabOrder = 0
  end
  object dbeDescription: TDBEdit
    Left = 144
    Top = 37
    Width = 177
    Height = 21
    DataField = 'DESCRIPTION'
    DataSource = dsReportGroup
    TabOrder = 1
  end
  object btnOk: TButton
    Left = 168
    Top = 72
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    TabOrder = 3
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 248
    Top = 72
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 4
  end
  object btnRigth: TButton
    Left = 8
    Top = 72
    Width = 75
    Height = 25
    Caption = 'Права'
    TabOrder = 2
  end
  object ibdsReportGroup: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = dmDatabase.ibtrAttr
    BufferChunks = 1000
    CachedUpdates = False
    DeleteSQL.Strings = (
      'delete from rp_reportgroup'
      'where'
      '  ID = :OLD_ID')
    InsertSQL.Strings = (
      'insert into rp_reportgroup'
      '  (ID, PARENT, NAME, DESCRIPTION, AFULL, ACHAG, AVIEW, RESERVED)'
      'values'
      
        '  (:ID, :PARENT, :NAME, :DESCRIPTION, :AFULL, :ACHAG, :AVIEW, :R' +
        'ESERVED)')
    RefreshSQL.Strings = (
      'Select '
      '  *'
      'from rp_reportgroup '
      'where'
      '  ID = :ID')
    SelectSQL.Strings = (
      'SELECT'
      '  *'
      'FROM'
      '  rp_reportgroup'
      'WHERE'
      '  id = :id')
    ModifySQL.Strings = (
      'update rp_reportgroup'
      'set'
      '  ID = :ID,'
      '  PARENT = :PARENT,'
      '  NAME = :NAME,'
      '  DESCRIPTION = :DESCRIPTION,'
      '  AFULL = :AFULL,'
      '  ACHAG = :ACHAG,'
      '  AVIEW = :AVIEW,'
      '  RESERVED = :RESERVED'
      'where'
      '  ID = :OLD_ID')
    Left = 8
    Top = 64
  end
  object dsReportGroup: TDataSource
    DataSet = ibdsReportGroup
    Left = 40
    Top = 64
  end
end
