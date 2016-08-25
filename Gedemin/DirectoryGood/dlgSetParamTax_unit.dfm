object dlgSetParamTax: TdlgSetParamTax
  Left = 231
  Top = 170
  BorderStyle = bsDialog
  Caption = 'Параметры налога'
  ClientHeight = 114
  ClientWidth = 291
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
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
  object lblRate: TLabel
    Left = 8
    Top = 56
    Width = 36
    Height = 13
    Caption = 'Ставка'
  end
  object Label3: TLabel
    Left = 8
    Top = 32
    Width = 76
    Height = 13
    Caption = 'Дата принятия'
  end
  object dbeName: TDBEdit
    Left = 136
    Top = 8
    Width = 150
    Height = 21
    DataField = 'NAME'
    DataSource = dsGoodTax
    Enabled = False
    TabOrder = 0
  end
  object dbeRate: TDBEdit
    Left = 136
    Top = 56
    Width = 150
    Height = 21
    DataField = 'RATE'
    DataSource = dsGoodTax
    TabOrder = 1
  end
  object btnOk: TButton
    Left = 130
    Top = 86
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 2
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 212
    Top = 86
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 3
    OnClick = btnCancelClick
  end
  object dtpDate: TDateTimePicker
    Left = 136
    Top = 32
    Width = 150
    Height = 21
    CalAlignment = dtaLeft
    Date = 36683.5956959606
    Time = 36683.5956959606
    DateFormat = dfShort
    DateMode = dmComboBox
    Kind = dtkDate
    ParseInput = False
    TabOrder = 4
  end
  object ibudEditGoodTax: TIBUpdateSQL
    RefreshSQL.Strings = (
      'Select '
      '  GOODKEY,'
      '  TAXKEY,'
      '  DATETAX,'
      '  RATE'
      'from gd_goodtax '
      'where'
      '  GOODKEY = :GOODKEY and'
      '  TAXKEY = :TAXKEY and'
      '  DATETAX = :DATETAX')
    ModifySQL.Strings = (
      'update gd_goodtax'
      'set'
      '  GOODKEY = :GOODKEY,'
      '  TAXKEY = :TAXKEY,'
      '  DATETAX = :DATETAX,'
      '  RATE = :RATE'
      'where'
      '  GOODKEY = :OLD_GOODKEY and'
      '  TAXKEY = :OLD_TAXKEY and'
      '  DATETAX = :OLD_DATETAX')
    InsertSQL.Strings = (
      'insert into gd_goodtax'
      '  (GOODKEY, TAXKEY, DATETAX, RATE)'
      'values'
      '  (:GOODKEY, :TAXKEY, :DATETAX, :RATE)')
    DeleteSQL.Strings = (
      'delete from gd_goodtax'
      'where'
      '  GOODKEY = :OLD_GOODKEY and'
      '  TAXKEY = :OLD_TAXKEY and'
      '  DATETAX = :OLD_DATETAX')
    Left = 40
    Top = 80
  end
  object ibqryEditGoodTax: TIBQuery
    Database = dmDatabase.ibdbGAdmin
    Transaction = dmDatabase.ibtrGenUniqueID
    BufferChunks = 1000
    CachedUpdates = False
    SQL.Strings = (
      'SELECT'
      '  ggt.*'
      '  , gt.name'
      'FROM'
      '  gd_goodtax ggt'
      '  , gd_tax gt'
      'WHERE'
      '  ggt.goodkey = :goodkey'
      '  AND ggt.taxkey = :taxkey'
      '  AND ggt.datetax = :datetax'
      '  AND gt.id = ggt.taxkey')
    UpdateObject = ibudEditGoodTax
    Left = 8
    Top = 80
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'goodkey'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'taxkey'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'datetax'
        ParamType = ptUnknown
      end>
  end
  object dsGoodTax: TDataSource
    DataSet = ibqryEditGoodTax
    Left = 72
    Top = 80
  end
end
