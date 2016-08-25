object dlgAddGoodGroup: TdlgAddGoodGroup
  Left = 290
  Top = 173
  ActiveControl = dbeName
  BorderStyle = bsDialog
  Caption = 'Параметры группы ТМЦ'
  ClientHeight = 243
  ClientWidth = 356
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 5
    Top = 5
    Width = 346
    Height = 196
    ActivePage = tsGood
    TabOrder = 0
    object tsGood: TTabSheet
      Caption = '&1. Группа'
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
      object Label3: TLabel
        Left = 8
        Top = 120
        Width = 68
        Height = 13
        Caption = 'Шифр группы'
      end
      object dbmDescription: TDBMemo
        Left = 136
        Top = 40
        Width = 195
        Height = 77
        DataField = 'DESCRIPTION'
        DataSource = dsGroup
        TabOrder = 1
      end
      object dbcbDisabled: TDBCheckBox
        Left = 8
        Top = 144
        Width = 97
        Height = 17
        Caption = 'Отключена'
        DataField = 'DISABLED'
        DataSource = dsGroup
        TabOrder = 3
        ValueChecked = '1'
        ValueUnchecked = '0'
      end
      object dbeName: TDBEdit
        Left = 136
        Top = 16
        Width = 195
        Height = 21
        DataField = 'NAME'
        DataSource = dsGroup
        TabOrder = 0
      end
      object dbeAlias: TDBEdit
        Left = 136
        Top = 120
        Width = 195
        Height = 21
        DataField = 'ALIAS'
        DataSource = dsGroup
        TabOrder = 2
      end
    end
    object TabSheet1: TTabSheet
      Caption = '&2. Атрибуты'
      ImageIndex = 1
      object atContainer1: TatContainer
        Left = 0
        Top = 0
        Width = 338
        Height = 156
        DataSource = dsGroup
        Align = alTop
        TabOrder = 0
      end
    end
  end
  object btnHelp: TButton
    Left = 5
    Top = 210
    Width = 75
    Height = 25
    Caption = 'Справка'
    TabOrder = 1
  end
  object btnRight: TButton
    Left = 95
    Top = 210
    Width = 75
    Height = 25
    Action = actSetRigth
    TabOrder = 2
  end
  object btnOk: TButton
    Left = 185
    Top = 210
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 3
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 275
    Top = 210
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 4
  end
  object ActionList1: TActionList
    Left = 40
    Top = 72
    object actSetRigth: TAction
      Caption = 'Права...'
    end
  end
  object ibqryGroup: TIBQuery
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtrGroup
    BufferChunks = 1000
    CachedUpdates = False
    SQL.Strings = (
      'SELECT'
      '  *'
      'FROM'
      '  gd_goodgroup'
      'WHERE'
      '  id = :id')
    UpdateObject = ibudGroup
    Left = 288
    Top = 144
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'id'
        ParamType = ptUnknown
      end>
  end
  object ibudGroup: TIBUpdateSQL
    RefreshSQL.Strings = (
      'Select '
      '  ID,'
      '  PARENT,'
      '  NAME,'
      '  ALIAS,'
      '  DESCRIPTION,'
      '  LB,'
      '  RB,'
      '  DISABLED,'
      '  RESERVED,'
      '  AFULL,'
      '  ACHAG,'
      '  AVIEW'
      'from gd_goodgroup '
      'where'
      '  ID = :ID')
    ModifySQL.Strings = (
      'update gd_goodgroup'
      'set'
      '  ID = :ID,'
      '  PARENT = :PARENT,'
      '  NAME = :NAME,'
      '  ALIAS = :ALIAS,'
      '  DESCRIPTION = :DESCRIPTION,'
      '  LB = :LB,'
      '  RB = :RB,'
      '  DISABLED = :DISABLED,'
      '  RESERVED = :RESERVED,'
      '  AFULL = :AFULL,'
      '  ACHAG = :ACHAG,'
      '  AVIEW = :AVIEW'
      'where'
      '  ID = :OLD_ID')
    InsertSQL.Strings = (
      'insert into gd_goodgroup'
      
        '  (ID, PARENT, NAME, ALIAS, DESCRIPTION, LB, RB, DISABLED, RESER' +
        'VED, AFULL, '
      '   ACHAG, AVIEW)'
      'values'
      
        '  (:ID, :PARENT, :NAME, :ALIAS, :DESCRIPTION, :LB, :RB, :DISABLE' +
        'D, :RESERVED, '
      '   :AFULL, :ACHAG, :AVIEW)')
    DeleteSQL.Strings = (
      'delete from gd_goodgroup'
      'where'
      '  ID = :OLD_ID')
    Left = 256
    Top = 144
  end
  object dsGroup: TDataSource
    DataSet = ibqryGroup
    Left = 224
    Top = 144
  end
  object ibsqlGroupKey: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    ParamCheck = True
    SQL.Strings = (
      
        'SELECT GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0) FROM RDB$' +
        'DATABASE')
    Transaction = ibtrGroup
    Left = 192
    Top = 144
  end
  object ibtrGroup: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    AutoStopAction = saNone
    Left = 160
    Top = 144
  end
  object atSQLSetup: TatSQLSetup
    Ignores = <>
    Left = 290
    Top = 110
  end
end
