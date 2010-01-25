object dlgAddTran: TdlgAddTran
  Left = 267
  Top = 122
  ActiveControl = dbedName
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Операция'
  ClientHeight = 332
  ClientWidth = 458
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 40
    Width = 76
    Height = 13
    Caption = 'Наименование'
  end
  object Label2: TLabel
    Left = 16
    Top = 64
    Width = 50
    Height = 13
    Caption = 'Описание'
  end
  object Label3: TLabel
    Left = 16
    Top = 177
    Width = 125
    Height = 13
    Caption = 'Документы по операции'
  end
  object Label4: TLabel
    Left = 16
    Top = 16
    Width = 83
    Height = 13
    Caption = 'Идентификатор:'
  end
  object dbedName: TDBEdit
    Left = 104
    Top = 36
    Width = 249
    Height = 21
    DataField = 'NAME'
    DataSource = dsTrType
    TabOrder = 0
  end
  object dbmDescription: TDBMemo
    Left = 104
    Top = 60
    Width = 249
    Height = 96
    DataField = 'DESCRIPTION'
    DataSource = dsTrType
    TabOrder = 1
  end
  object bOk: TButton
    Left = 368
    Top = 12
    Width = 75
    Height = 25
    Action = actOK
    Default = True
    ModalResult = 1
    TabOrder = 4
  end
  object bNext: TButton
    Left = 368
    Top = 42
    Width = 75
    Height = 25
    Action = actNext
    TabOrder = 5
  end
  object bCancel: TButton
    Left = 368
    Top = 72
    Width = 75
    Height = 25
    Action = actCancel
    Cancel = True
    TabOrder = 6
  end
  object gsibgrTrDocType: TgsIBGrid
    Left = 16
    Top = 193
    Width = 337
    Height = 129
    DataSource = dsTrDocType
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgConfirmDelete, dgCancelOnExit]
    ReadOnly = True
    TabOrder = 3
    InternalMenuKind = imkWithSeparator
    Expands = <>
    ExpandsActive = False
    ExpandsSeparate = False
    Conditions = <>
    ConditionsActive = False
    CheckBox.Visible = False
    MinColWidth = 40
    ColumnEditors = <>
    Aliases = <>
  end
  object Button1: TButton
    Left = 368
    Top = 193
    Width = 75
    Height = 25
    Action = actChooseDoc
    TabOrder = 7
  end
  object Button2: TButton
    Left = 368
    Top = 222
    Width = 75
    Height = 25
    Action = actDelDoc
    TabOrder = 8
  end
  object Button3: TButton
    Left = 368
    Top = 107
    Width = 75
    Height = 25
    Action = actCondition
    TabOrder = 9
  end
  object Button4: TButton
    Left = 368
    Top = 135
    Width = 75
    Height = 25
    Action = actTypeEntry
    TabOrder = 10
  end
  object dbcbIsDocument: TDBCheckBox
    Left = 104
    Top = 159
    Width = 249
    Height = 17
    Caption = 'Операция на весь документ'
    DataField = 'ISDOCUMENT'
    DataSource = dsTrType
    TabOrder = 2
    ValueChecked = '1'
    ValueUnchecked = '0'
  end
  object DBEdit1: TDBEdit
    Left = 104
    Top = 12
    Width = 121
    Height = 21
    TabStop = False
    DataField = 'ID'
    DataSource = dsTrType
    ReadOnly = True
    TabOrder = 11
  end
  object ActionList1: TActionList
    Left = 184
    Top = 16
    object actOK: TAction
      Caption = 'OK'
      OnExecute = actOKExecute
    end
    object actNext: TAction
      Caption = 'Следующая'
      ShortCut = 45
      OnExecute = actNextExecute
    end
    object actCancel: TAction
      Caption = 'Отмена'
      OnExecute = actCancelExecute
    end
    object actChooseDoc: TAction
      Caption = 'Выбрать...'
      ShortCut = 32836
      OnExecute = actChooseDocExecute
    end
    object actDelDoc: TAction
      Caption = 'Удалить'
      ShortCut = 119
      OnExecute = actDelDocExecute
    end
    object actTypeEntry: TAction
      Caption = 'Проводки...'
      ShortCut = 32839
      OnExecute = actTypeEntryExecute
    end
    object actCondition: TAction
      Caption = 'Условия...'
      ShortCut = 32837
      OnExecute = actConditionExecute
    end
  end
  object ibdsTrType: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    BufferChunks = 1000
    CachedUpdates = False
    DeleteSQL.Strings = (
      'delete from GD_LISTTRTYPE'
      'where'
      '  ID = :OLD_ID')
    InsertSQL.Strings = (
      'insert into GD_LISTTRTYPE'
      
        '  (ID, PARENT, LB, RB, NAME, DESCRIPTION, SCRIPT, DISABLED, AFUL' +
        'L, '
      'ACHAG, '
      '   AVIEW, ISDOCUMENT, COMPANYKEY)'
      'values'
      
        '  (:ID, :PARENT, :LB, :RB, :NAME, :DESCRIPTION, :SCRIPT, :DISABL' +
        'ED, :AFULL, '
      '   :ACHAG, :AVIEW, :ISDOCUMENT, :COMPANYKEY)')
    RefreshSQL.Strings = (
      'Select '
      '  ID,'
      '  PARENT,'
      '  LB,'
      '  RB,'
      '  NAME,'
      '  DESCRIPTION,'
      '  SCRIPT,'
      '  DISABLED,'
      '  AFULL,'
      '  ACHAG,'
      '  AVIEW,'
      '  ISDOCUMENT,'
      '  COMPANYKEY'
      'from GD_LISTTRTYPE '
      'where'
      '  ID = :ID')
    SelectSQL.Strings = (
      'select * from GD_LISTTRTYPE'
      'where ID = :ID')
    ModifySQL.Strings = (
      'update GD_LISTTRTYPE'
      'set'
      '  ID = :ID,'
      '  PARENT = :PARENT,'
      '  LB = :LB,'
      '  RB = :RB,'
      '  NAME = :NAME,'
      '  DESCRIPTION = :DESCRIPTION,'
      '  SCRIPT = :SCRIPT,'
      '  DISABLED = :DISABLED,'
      '  AFULL = :AFULL,'
      '  ACHAG = :ACHAG,'
      '  AVIEW = :AVIEW,'
      '  ISDOCUMENT = :ISDOCUMENT,'
      '  COMPANYKEY = :COMPANYKEY'
      'where'
      '  ID = :OLD_ID')
    Left = 184
    Top = 48
  end
  object dsTrType: TDataSource
    DataSet = ibdsTrType
    Left = 216
    Top = 48
  end
  object IBTransaction: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    AutoStopAction = saNone
    Left = 184
    Top = 80
  end
  object ibdsTrDocType: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    BufferChunks = 1000
    CachedUpdates = False
    DeleteSQL.Strings = (
      'delete from gd_documenttrtype'
      'where'
      '  TRTYPEKEY = :OLD_TRTYPEKEY and'
      '  DOCUMENTTYPEKEY = :OLD_DOCUMENTTYPEKEY')
    InsertSQL.Strings = (
      'insert into gd_documenttrtype'
      '  (TRTYPEKEY, DOCUMENTTYPEKEY)'
      'values'
      '  (:TRTYPEKEY, :DOCUMENTTYPEKEY)')
    RefreshSQL.Strings = (
      'SELECT * FROM'
      'gd_documenttrtype dtr JOIN'
      'gd_documenttype dt ON dtr.documenttypekey = dt.ID'
      'where'
      '  TRTYPEKEY = :TRTYPEKEY and'
      '  DOCUMENTTYPEKEY = :DOCUMENTTYPEKEY')
    SelectSQL.Strings = (
      'SELECT * FROM'
      'gd_documenttrtype dtr JOIN'
      'gd_documenttype dt ON dtr.documenttypekey = dt.ID and'
      'dtr.trtypekey = :trtypekey')
    ModifySQL.Strings = (
      'update gd_documenttrtype'
      'set'
      '  TRTYPEKEY = :TRTYPEKEY,'
      '  DOCUMENTTYPEKEY = :DOCUMENTTYPEKEY'
      'where'
      '  TRTYPEKEY = :OLD_TRTYPEKEY and'
      '  DOCUMENTTYPEKEY = :OLD_DOCUMENTTYPEKEY')
    Left = 184
    Top = 201
    object ibdsTrDocTypeTRTYPEKEY: TIntegerField
      FieldName = 'TRTYPEKEY'
      Required = True
      Visible = False
    end
    object ibdsTrDocTypeDOCUMENTTYPEKEY: TIntegerField
      FieldName = 'DOCUMENTTYPEKEY'
      Required = True
      Visible = False
    end
    object ibdsTrDocTypeID: TIntegerField
      FieldName = 'ID'
      Visible = False
    end
    object ibdsTrDocTypePARENT: TIntegerField
      FieldName = 'PARENT'
      Visible = False
    end
    object ibdsTrDocTypeLB: TIntegerField
      FieldName = 'LB'
      Visible = False
    end
    object ibdsTrDocTypeRB: TIntegerField
      FieldName = 'RB'
      Visible = False
    end
    object ibdsTrDocTypeNAME: TIBStringField
      DisplayLabel = 'Наименование'
      DisplayWidth = 30
      FieldName = 'NAME'
      Size = 60
    end
    object ibdsTrDocTypeDESCRIPTION: TIBStringField
      DisplayLabel = 'Описание'
      DisplayWidth = 40
      FieldName = 'DESCRIPTION'
      Size = 180
    end
    object ibdsTrDocTypeAFULL: TIntegerField
      FieldName = 'AFULL'
      Visible = False
    end
    object ibdsTrDocTypeACHAG: TIntegerField
      FieldName = 'ACHAG'
      Visible = False
    end
    object ibdsTrDocTypeAVIEW: TIntegerField
      FieldName = 'AVIEW'
      Visible = False
    end
    object ibdsTrDocTypeDISABLED: TSmallintField
      FieldName = 'DISABLED'
      Visible = False
    end
    object ibdsTrDocTypeRESERVED: TIntegerField
      FieldName = 'RESERVED'
      Visible = False
    end
  end
  object dsTrDocType: TDataSource
    DataSet = ibdsTrDocType
    Left = 216
    Top = 201
  end
  object ibdsListTrTypeCond: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    BufferChunks = 1000
    CachedUpdates = False
    DeleteSQL.Strings = (
      'delete from gd_listtrtypecond'
      'where'
      '  ID = :OLD_ID')
    InsertSQL.Strings = (
      'insert into gd_listtrtypecond'
      
        '  (ID, LISTTRTYPEKEY, DOCUMENTTYPEKEY, DATA, RESERVED, TEXTCONDI' +
        'TION)'
      'values'
      
        '  (:ID, :LISTTRTYPEKEY, :DOCUMENTTYPEKEY, :DATA, :RESERVED, :TEX' +
        'TCONDITION)')
    RefreshSQL.Strings = (
      'SELECT * FROM gd_listtrtypecond'
      'WHERE '
      '  ID = :OLD_ID')
    SelectSQL.Strings = (
      'SELECT * FROM gd_listtrtypecond a '
      'WHERE '
      '  a.listtrtypekey = :trkey and '
      '  a.documenttypekey = :dt')
    ModifySQL.Strings = (
      'update gd_listtrtypecond'
      'set'
      '  ID = :ID,'
      '  LISTTRTYPEKEY = :LISTTRTYPEKEY,'
      '  DOCUMENTTYPEKEY = :DOCUMENTTYPEKEY,'
      '  DATA = :DATA,'
      '  TEXTCONDITION = :TEXTCONDITION,'
      '  RESERVED = :RESERVED'
      'where'
      '  ID = :OLD_ID')
    Left = 140
    Top = 149
  end
end
