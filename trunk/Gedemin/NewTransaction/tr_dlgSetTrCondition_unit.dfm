object dlgSetTrCondition: TdlgSetTrCondition
  Left = 242
  Top = 100
  Width = 408
  Height = 490
  Caption = 'Установка условий формирования операции'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label4: TLabel
    Left = 8
    Top = 10
    Width = 78
    Height = 13
    Caption = 'Для документа'
  end
  object tvRelations: TTreeView
    Left = 8
    Top = 32
    Width = 294
    Height = 409
    HideSelection = False
    Indent = 19
    TabOrder = 0
  end
  object Button1: TButton
    Left = 315
    Top = 6
    Width = 75
    Height = 25
    Action = actOk
    Default = True
    TabOrder = 1
  end
  object Button2: TButton
    Left = 315
    Top = 35
    Width = 75
    Height = 25
    Action = actCancel
    TabOrder = 2
  end
  object Button3: TButton
    Left = 315
    Top = 78
    Width = 75
    Height = 25
    Action = actNewValue
    TabOrder = 3
  end
  object Button4: TButton
    Left = 315
    Top = 108
    Width = 75
    Height = 25
    Action = actEditValue
    TabOrder = 4
  end
  object Button5: TButton
    Left = 315
    Top = 138
    Width = 75
    Height = 25
    Action = actDelValue
    TabOrder = 5
  end
  object gsiblcDocumentType: TgsIBLookupComboBox
    Left = 98
    Top = 6
    Width = 204
    Height = 21
    Database = dmDatabase.ibdbGAdmin
    ListTable = 'GD_V_DOCUMENT_TRTYPE'
    ListField = 'DOCUMENT_NAME'
    KeyField = 'DOCTYPE_KEY'
    ItemHeight = 13
    ParentShowHint = False
    ShowHint = True
    TabOrder = 6
    OnChange = gsiblcDocumentTypeChange
  end
  object ibdsFields_old: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    BufferChunks = 1000
    CachedUpdates = False
    SelectSQL.Strings = (
      'SELECT * FROM'
      '    GD_DOCUMENTTRTYPE D'
      'JOIN'
      '   GD_RELATIONTYPEDOC RT '
      'ON '
      '   D.documenttypekey = RT.doctypekey AND'
      '   D.TRTYPEKEY = :trtypekey AND'
      '   RT.doctypekey = :documenttype   '
      'JOIN'
      '  AT_RELATIONS R ON '
      '  RT.relationname = R.relationname '
      'JOIN'
      '   AT_RELATION_FIELDS RF ON'
      '   R.relationname = RF.relationname '
      'JOIN AT_FIELDS F ON'
      '  RF.fieldsource = F.fieldname'
      'LEFT JOIN'
      '  GD_LISTTRTYPECOND LC ON D.trtypekey = LC.listtrtypekey AND'
      '  RF.relationname = LC.relationname AND'
      '  RF.fieldname = LC.fieldname'
      'ORDER BY'
      '  RF.relationname,'
      '  RF.fieldname,'
      '  LC.valuetext')
    Left = 144
    Top = 56
  end
  object dsFields: TDataSource
    DataSet = ibdsFields
    Left = 176
    Top = 96
  end
  object ActionList1: TActionList
    Left = 224
    Top = 80
    object actOk: TAction
      Caption = 'OK'
      OnExecute = actOkExecute
    end
    object actCancel: TAction
      Caption = 'Отмена'
      OnExecute = actCancelExecute
    end
    object actNewValue: TAction
      Caption = 'Добавить...'
      OnExecute = actNewValueExecute
      OnUpdate = actNewValueUpdate
    end
    object actEditValue: TAction
      Caption = 'Изменить'
      OnExecute = actEditValueExecute
      OnUpdate = actEditValueUpdate
    end
    object actDelValue: TAction
      Caption = 'Удалить'
      OnExecute = actDelValueExecute
      OnUpdate = actDelValueUpdate
    end
  end
  object ibdsFields: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    BufferChunks = 1000
    CachedUpdates = False
    SelectSQL.Strings = (
      'SELECT * FROM'
      '    GD_DOCUMENTTRTYPE D'
      'JOIN'
      '   GD_RELATIONTYPEDOC RT '
      'ON '
      '   D.documenttypekey = RT.doctypekey AND'
      '   D.TRTYPEKEY = :trtypekey AND'
      '   RT.doctypekey = :documenttype   ')
    Left = 144
    Top = 96
  end
  object ibsqlCondition: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    ParamCheck = True
    SQL.Strings = (
      'SELECT relationname, fieldname, valuetext FROM gd_listtrtypecond'
      'WHERE'
      '  listtrtypekey = :tk and'
      '  documenttypekey = :dk')
    Left = 144
    Top = 128
  end
end
