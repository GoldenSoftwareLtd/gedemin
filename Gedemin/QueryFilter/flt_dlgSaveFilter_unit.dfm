object dlgSaveFilter: TdlgSaveFilter
  Left = 204
  Top = 213
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Сохранение фильтра'
  ClientHeight = 138
  ClientWidth = 266
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
  object Label1: TLabel
    Left = 5
    Top = 10
    Width = 125
    Height = 13
    Caption = 'Наименование фильтра:'
  end
  object Label2: TLabel
    Left = 5
    Top = 35
    Width = 73
    Height = 13
    Caption = 'Комментарий:'
  end
  object btnAccess: TButton
    Left = 5
    Top = 108
    Width = 75
    Height = 25
    Action = aRights
    TabOrder = 3
  end
  object btnOk: TButton
    Left = 105
    Top = 108
    Width = 75
    Height = 25
    Caption = 'ОK'
    Default = True
    ModalResult = 1
    TabOrder = 4
  end
  object btnCancel: TButton
    Left = 186
    Top = 108
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 5
  end
  object dbeName: TDBEdit
    Left = 136
    Top = 8
    Width = 125
    Height = 21
    DataField = 'NAME'
    DataSource = dsFilter
    TabOrder = 0
  end
  object dbeDescription: TDBEdit
    Left = 6
    Top = 56
    Width = 255
    Height = 21
    DataField = 'DESCRIPTION'
    DataSource = dsFilter
    TabOrder = 1
  end
  object cbFilterForMe: TCheckBox
    Left = 6
    Top = 82
    Width = 115
    Height = 17
    Caption = 'Только для меня'
    Checked = True
    State = cbChecked
    TabOrder = 2
  end
  object ActionList1: TActionList
    Left = 126
    Top = 28
    object aRights: TAction
      Caption = 'Доступ'
      OnUpdate = aRightsUpdate
    end
  end
  object ibdsAddFilter: TIBDataSet
    BufferChunks = 1000
    CachedUpdates = False
    DeleteSQL.Strings = (
      'delete from flt_savedfilter'
      'where'
      '  ID = :OLD_ID')
    InsertSQL.Strings = (
      'insert into flt_savedfilter'
      
        '  (ID, NAME, USERKEY, COMPONENTKEY, DESCRIPTION, LASTEXTIME, DIS' +
        'ABLED, '
      '   RESERVED, AVIEW, ACHAG, AFULL, DATA)'
      'values'
      
        '  (:ID, :NAME, :USERKEY, :COMPONENTKEY, :DESCRIPTION, :LASTEXTIM' +
        'E, :DISABLED, '
      '   :RESERVED, :AVIEW, :ACHAG, :AFULL, :DATA)')
    RefreshSQL.Strings = (
      'Select '
      '  ID,'
      '  NAME,'
      '  USERKEY,'
      '  COMPONENTKEY,'
      '  DESCRIPTION,'
      '  LASTEXTIME,'
      '  DISABLED,'
      '  RESERVED,'
      '  AVIEW,'
      '  ACHAG,'
      '  AFULL,'
      '  DATA'
      'from flt_savedfilter '
      'where'
      '  ID = :ID')
    SelectSQL.Strings = (
      'SELECT'
      '  *'
      'FROM'
      '  flt_savedfilter'
      'WHERE '
      '  id = :id')
    ModifySQL.Strings = (
      'update flt_savedfilter'
      'set'
      '  ID = :ID,'
      '  NAME = :NAME,'
      '  USERKEY = :USERKEY,'
      '  COMPONENTKEY = :COMPONENTKEY,'
      '  DESCRIPTION = :DESCRIPTION,'
      '  LASTEXTIME = :LASTEXTIME,'
      '  DISABLED = :DISABLED,'
      '  RESERVED = :RESERVED,'
      '  AVIEW = :AVIEW,'
      '  ACHAG = :ACHAG,'
      '  AFULL = :AFULL,'
      '  DATA = :DATA'
      'where'
      '  ID = :OLD_ID')
    Left = 158
    Top = 28
  end
  object dsFilter: TDataSource
    DataSet = ibdsAddFilter
    Left = 189
    Top = 29
  end
  object ibsqlGetID: TIBSQL
    ParamCheck = True
    SQL.Strings = (
      
        'SELECT GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0) FROM rdb$' +
        'database')
    Left = 160
    Top = 56
  end
end
