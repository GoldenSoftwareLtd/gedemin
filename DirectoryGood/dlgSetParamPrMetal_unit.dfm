object dlgSetParamPrMetal: TdlgSetParamPrMetal
  Left = 162
  Top = 217
  BorderStyle = bsDialog
  Caption = 'Параметры выбранного драгметалла'
  ClientHeight = 91
  ClientWidth = 291
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
    Width = 76
    Height = 13
    Caption = 'Наименование'
  end
  object lblRate: TLabel
    Left = 8
    Top = 32
    Width = 36
    Height = 13
    Caption = 'Ставка'
  end
  object dbeName: TDBEdit
    Left = 104
    Top = 8
    Width = 182
    Height = 21
    DataField = 'NAME'
    DataSource = dsGoodPrMetal
    Enabled = False
    TabOrder = 0
  end
  object dbeQuantity: TDBEdit
    Left = 104
    Top = 32
    Width = 182
    Height = 21
    DataField = 'QUANTITY'
    DataSource = dsGoodPrMetal
    TabOrder = 1
  end
  object btnOk: TButton
    Left = 130
    Top = 62
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
    Top = 62
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 3
  end
  object ibudEditGoodPrMetal: TIBUpdateSQL
    RefreshSQL.Strings = (
      'Select '
      '  GOODKEY,'
      '  PRMETALKEY,'
      '  QUANTITY'
      'from gd_goodprmetal '
      'where'
      '  GOODKEY = :GOODKEY and'
      '  PRMETALKEY = :PRMETALKEY')
    ModifySQL.Strings = (
      'update gd_goodprmetal'
      'set'
      '  GOODKEY = :GOODKEY,'
      '  PRMETALKEY = :PRMETALKEY,'
      '  QUANTITY = :QUANTITY'
      'where'
      '  GOODKEY = :OLD_GOODKEY and'
      '  PRMETALKEY = :OLD_PRMETALKEY')
    InsertSQL.Strings = (
      'insert into gd_goodprmetal'
      '  (GOODKEY, PRMETALKEY, QUANTITY)'
      'values'
      '  (:GOODKEY, :PRMETALKEY, :QUANTITY)')
    DeleteSQL.Strings = (
      'delete from gd_goodprmetal'
      'where'
      '  GOODKEY = :OLD_GOODKEY and'
      '  PRMETALKEY = :OLD_PRMETALKEY')
    Left = 40
    Top = 56
  end
  object ibqryEditGoodPrMetal: TIBQuery
    Database = dmDatabase.ibdbGAdmin
    Transaction = dmDatabase.ibtrGenUniqueID
    BufferChunks = 1000
    CachedUpdates = False
    SQL.Strings = (
      'SELECT'
      '  ggp.*'
      '  , gpm.name'
      'FROM'
      '  gd_goodprmetal ggp'
      '  , gd_preciousemetal gpm'
      'WHERE'
      '  ggp.goodkey = :goodkey'
      '  AND ggp.prmetalkey = :prmetalkey'
      '  AND gpm.id = ggp.prmetalkey')
    UpdateObject = ibudEditGoodPrMetal
    Left = 8
    Top = 56
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'goodkey'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'prmetalkey'
        ParamType = ptUnknown
      end>
  end
  object dsGoodPrMetal: TDataSource
    DataSet = ibqryEditGoodPrMetal
    Left = 72
    Top = 56
  end
end
