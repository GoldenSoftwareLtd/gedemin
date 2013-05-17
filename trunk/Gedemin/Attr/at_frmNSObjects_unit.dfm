object at_frmNSObjects: Tat_frmNSObjects
  Left = 302
  Top = 132
  Width = 1142
  Height = 654
  Caption = '������ ��������'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object TBDock: TTBDock
    Left = 0
    Top = 0
    Width = 1126
    Height = 26
    object tb: TTBToolbar
      Left = 0
      Top = 0
      Caption = 'tb'
      CloseButton = False
      DockMode = dmCannotFloatOrChangeDocks
      FullSize = True
      Images = dmImages.il16x16
      MenuBar = True
      ParentShowHint = False
      ProcessShortCuts = True
      ShowHint = True
      ShrinkMode = tbsmWrap
      TabOrder = 0
      object TBItem1: TTBItem
        Action = actOpenObject
      end
      object TBItem2: TTBItem
        Action = actAddToNamespace
      end
      object TBSeparatorItem1: TTBSeparatorItem
      end
    end
  end
  object sb: TStatusBar
    Left = 0
    Top = 597
    Width = 1126
    Height = 19
    Panels = <>
    SimplePanel = False
  end
  object gsIBGrid1: TgsIBGrid
    Left = 0
    Top = 26
    Width = 1126
    Height = 571
    Align = alClient
    BorderStyle = bsNone
    DataSource = ds
    Options = [dgTitles, dgColumnResize, dgColLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgMultiSelect]
    PopupMenu = pm
    ReadOnly = True
    TabOrder = 2
    InternalMenuKind = imkWithSeparator
    Expands = <>
    ExpandsActive = False
    ExpandsSeparate = False
    TitlesExpanding = False
    Conditions = <>
    ConditionsActive = False
    CheckBox.Visible = False
    CheckBox.FirstColumn = False
    ScaleColumns = True
    MinColWidth = 40
    ColumnEditors = <>
    Aliases = <>
  end
  object ActionList: TActionList
    Images = dmImages.il16x16
    Left = 816
    Top = 80
    object actOpenObject: TAction
      Caption = '������� ������...'
      Hint = '������� ������...'
      ImageIndex = 1
      OnExecute = actOpenObjectExecute
      OnUpdate = actOpenObjectUpdate
    end
    object actAddToNamespace: TAction
      Caption = '�������� � ������������ ����'
      ImageIndex = 81
      OnExecute = actAddToNamespaceExecute
      OnUpdate = actAddToNamespaceUpdate
    end
  end
  object ibtr: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    AutoStopAction = saNone
    Left = 552
    Top = 296
  end
  object ibds: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibtr
    SelectSQL.Strings = (
      'SELECT'
      '  CAST('#39'TgdcReport'#39' AS VARCHAR(60)) AS ObjectClass,'
      '  '#39#39' AS SubType,'
      '  ruid.xid,'
      '  ruid.dbid,'
      '  r.name,'
      '  list(n.id || '#39'='#39' || n.name) AS ns_list'
      'FROM'
      '  rp_reportlist r'
      '  JOIN gd_ruid ruid ON ruid.id = r.id'
      
        '  LEFT JOIN at_object o ON o.xid = ruid.xid AND o.dbid = ruid.db' +
        'id'
      '  LEFT JOIN at_namespace n ON n.id = o.namespacekey'
      'GROUP BY'
      '  1, 2, 3, 4, 5'
      ''
      'UNION ALL'
      ''
      'SELECT'
      '  '#39'TgdcMacros'#39' AS ObjectClass,'
      '  '#39#39' AS SubType,'
      '  ruid.xid,'
      '  ruid.dbid,'
      '  r.name,'
      '  list(n.id || '#39'='#39' || n.name) AS ns_list'
      'FROM'
      '  evt_macroslist r'
      '  JOIN gd_ruid ruid ON ruid.id = r.id'
      
        '  LEFT JOIN at_object o ON o.xid = ruid.xid AND o.dbid = ruid.db' +
        'id'
      '  LEFT JOIN at_namespace n ON n.id = o.namespacekey'
      'GROUP BY'
      '  1, 2, 3, 4, 5'
      ''
      'UNION ALL'
      ''
      'SELECT'
      '  '#39'TgdcBaseTable'#39' AS ObjectClass,'
      '  '#39#39' AS SubType,'
      '  ruid.xid,'
      '  ruid.dbid,'
      '  r.relationname,'
      '  list(n.id || '#39'='#39' || n.name) AS ns_list'
      'FROM'
      '  at_relations r'
      '  JOIN gd_ruid ruid ON ruid.id = r.id'
      
        '  LEFT JOIN at_object o ON o.xid = ruid.xid AND o.dbid = ruid.db' +
        'id'
      '  LEFT JOIN at_namespace n ON n.id = o.namespacekey'
      'GROUP BY'
      '  1, 2, 3, 4, 5'
      ''
      'UNION ALL'
      ''
      'SELECT'
      '  '#39'TgdcField'#39' AS ObjectClass,'
      '  '#39#39' AS SubType,'
      '  ruid.xid,'
      '  ruid.dbid,'
      '  r.fieldname,'
      '  list(n.id || '#39'='#39' || n.name) AS ns_list'
      'FROM'
      '  at_fields r'
      '  JOIN gd_ruid ruid ON ruid.id = r.id'
      
        '  LEFT JOIN at_object o ON o.xid = ruid.xid AND o.dbid = ruid.db' +
        'id'
      '  LEFT JOIN at_namespace n ON n.id = o.namespacekey'
      'GROUP BY'
      '  1, 2, 3, 4, 5'
      ''
      'UNION ALL'
      ''
      'SELECT'
      '  '#39'TgdcStoredProc'#39' AS ObjectClass,'
      '  '#39#39' AS SubType,'
      '  ruid.xid,'
      '  ruid.dbid,'
      '  r.procedurename,'
      '  list(n.id || '#39'='#39' || n.name) AS ns_list'
      'FROM'
      '  at_procedures r'
      '  JOIN gd_ruid ruid ON ruid.id = r.id'
      
        '  LEFT JOIN at_object o ON o.xid = ruid.xid AND o.dbid = ruid.db' +
        'id'
      '  LEFT JOIN at_namespace n ON n.id = o.namespacekey'
      'GROUP BY'
      '  1, 2, 3, 4, 5'
      ''
      'UNION ALL'
      ''
      'SELECT'
      '  '#39'TgdcTrigger'#39' AS ObjectClass,'
      '  '#39#39' AS SubType,'
      '  ruid.xid,'
      '  ruid.dbid,'
      '  r.triggername,'
      '  list(n.id || '#39'='#39' || n.name) AS ns_list'
      'FROM'
      '  at_triggers r'
      '  JOIN gd_ruid ruid ON ruid.id = r.id'
      
        '  LEFT JOIN at_object o ON o.xid = ruid.xid AND o.dbid = ruid.db' +
        'id'
      '  LEFT JOIN at_namespace n ON n.id = o.namespacekey'
      'GROUP BY'
      '  1, 2, 3, 4, 5 '
      ''
      'UNION ALL'
      ''
      'SELECT'
      '  '#39'TgdcRelationField'#39' AS ObjectClass,'
      '  '#39#39' AS SubType,'
      '  ruid.xid,'
      '  ruid.dbid,'
      '  r.fieldname,'
      '  list(n.id || '#39'='#39' || n.name) AS ns_list'
      'FROM'
      '  at_relation_fields r'
      '  JOIN gd_ruid ruid ON ruid.id = r.id'
      
        '  LEFT JOIN at_object o ON o.xid = ruid.xid AND o.dbid = ruid.db' +
        'id'
      '  LEFT JOIN at_namespace n ON n.id = o.namespacekey'
      'GROUP BY'
      '  1, 2, 3, 4, 5'
      ''
      'UNION ALL'
      ''
      'SELECT'
      '  '#39'TgdcCheckConstraint'#39' AS ObjectClass,'
      '  '#39#39' AS SubType,'
      '  ruid.xid,'
      '  ruid.dbid,'
      '  r.checkname,'
      '  list(n.id || '#39'='#39' || n.name) AS ns_list'
      'FROM'
      '  at_check_constraints r'
      '  JOIN gd_ruid ruid ON ruid.id = r.id'
      
        '  LEFT JOIN at_object o ON o.xid = ruid.xid AND o.dbid = ruid.db' +
        'id'
      '  LEFT JOIN at_namespace n ON n.id = o.namespacekey'
      'GROUP BY'
      '  1, 2, 3, 4, 5'
      ''
      'UNION ALL'
      ''
      'SELECT'
      '  '#39'TgdcException'#39' AS ObjectClass,'
      '  '#39#39' AS SubType,'
      '  ruid.xid,'
      '  ruid.dbid,'
      '  r.exceptionname,'
      '  list(n.id || '#39'='#39' || n.name) AS ns_list'
      'FROM'
      '  at_exceptions r'
      '  JOIN gd_ruid ruid ON ruid.id = r.id'
      
        '  LEFT JOIN at_object o ON o.xid = ruid.xid AND o.dbid = ruid.db' +
        'id'
      '  LEFT JOIN at_namespace n ON n.id = o.namespacekey'
      'GROUP BY'
      '  1, 2, 3, 4, 5'
      ''
      'UNION ALL'
      ''
      'SELECT'
      '  '#39'TgdcGenerator'#39' AS ObjectClass,'
      '  '#39#39' AS SubType,'
      '  ruid.xid,'
      '  ruid.dbid,'
      '  r.generatorname,'
      '  list(n.id || '#39'='#39' || n.name) AS ns_list'
      'FROM'
      '  at_generators r'
      '  JOIN gd_ruid ruid ON ruid.id = r.id'
      
        '  LEFT JOIN at_object o ON o.xid = ruid.xid AND o.dbid = ruid.db' +
        'id'
      '  LEFT JOIN at_namespace n ON n.id = o.namespacekey'
      'GROUP BY'
      '  1, 2, 3, 4, 5'
      ''
      'UNION ALL'
      ''
      'SELECT'
      '  '#39'TgdcIndex'#39' AS ObjectClass,'
      '  '#39#39' AS SubType,'
      '  ruid.xid,'
      '  ruid.dbid,'
      '  r.indexname,'
      '  list(n.id || '#39'='#39' || n.name) AS ns_list'
      'FROM'
      '  at_indices r'
      '  JOIN gd_ruid ruid ON ruid.id = r.id'
      
        '  LEFT JOIN at_object o ON o.xid = ruid.xid AND o.dbid = ruid.db' +
        'id'
      '  LEFT JOIN at_namespace n ON n.id = o.namespacekey'
      'GROUP BY'
      '  1, 2, 3, 4, 5'
      ''
      'UNION ALL'
      ''
      'SELECT'
      '  '#39'TgdcFunction'#39' AS ObjectClass,'
      '  '#39#39' AS SubType,'
      '  ruid.xid,'
      '  ruid.dbid,'
      '  r.name,'
      '  list(n.id || '#39'='#39' || n.name) AS ns_list'
      'FROM'
      '  gd_function r'
      '  JOIN gd_ruid ruid ON ruid.id = r.id'
      
        '  LEFT JOIN at_object o ON o.xid = ruid.xid AND o.dbid = ruid.db' +
        'id'
      '  LEFT JOIN at_namespace n ON n.id = o.namespacekey'
      'GROUP BY'
      '  1, 2, 3, 4, 5'
      ''
      'UNION ALL'
      ''
      'SELECT'
      '  '#39'TgdcEvent'#39' AS ObjectClass,'
      '  '#39#39' AS SubType,'
      '  ruid.xid,'
      '  ruid.dbid,'
      '  r.eventname,'
      '  list(n.id || '#39'='#39' || n.name) AS ns_list'
      'FROM'
      '  evt_objectevent r'
      '  JOIN gd_ruid ruid ON ruid.id = r.id'
      
        '  LEFT JOIN at_object o ON o.xid = ruid.xid AND o.dbid = ruid.db' +
        'id'
      '  LEFT JOIN at_namespace n ON n.id = o.namespacekey'
      'GROUP BY'
      '  1, 2, 3, 4, 5'
      ''
      'UNION ALL'
      ''
      'SELECT'
      '  '#39'TgdcBaseAcctTransactionEntry'#39' AS ObjectClass,'
      '  '#39#39' AS SubType,'
      '  ruid.xid,'
      '  ruid.dbid,'
      '  r.description,'
      '  list(n.id || '#39'='#39' || n.name) AS ns_list'
      'FROM'
      '  ac_trrecord r'
      '  JOIN gd_ruid ruid ON ruid.id = r.id'
      
        '  LEFT JOIN at_object o ON o.xid = ruid.xid AND o.dbid = ruid.db' +
        'id'
      '  LEFT JOIN at_namespace n ON n.id = o.namespacekey'
      'GROUP BY'
      '  1, 2, 3, 4, 5'
      ''
      'UNION ALL'
      ''
      'SELECT'
      '  '#39'TgdcDelphiObject'#39' AS ObjectClass,'
      '  '#39#39' AS SubType,'
      '  ruid.xid,'
      '  ruid.dbid,'
      '  r.name,'
      '  list(n.id || '#39'='#39' || n.name) AS ns_list'
      'FROM'
      '  evt_object r'
      '  JOIN gd_ruid ruid ON ruid.id = r.id'
      
        '  LEFT JOIN at_object o ON o.xid = ruid.xid AND o.dbid = ruid.db' +
        'id'
      '  LEFT JOIN at_namespace n ON n.id = o.namespacekey'
      'GROUP BY'
      '  1, 2, 3, 4, 5'
      ''
      'UNION ALL'
      ''
      'SELECT'
      '  '#39'TgdcBaseAcctTransaction'#39' AS ObjectClass,'
      '  '#39#39' AS SubType,'
      '  ruid.xid,'
      '  ruid.dbid,'
      '  r.name,'
      '  list(n.id || '#39'='#39' || n.name) AS ns_list'
      'FROM'
      '  ac_transaction r'
      '  JOIN gd_ruid ruid ON ruid.id = r.id'
      
        '  LEFT JOIN at_object o ON o.xid = ruid.xid AND o.dbid = ruid.db' +
        'id'
      '  LEFT JOIN at_namespace n ON n.id = o.namespacekey'
      'GROUP BY'
      '  1, 2, 3, 4, 5')
    ReadTransaction = ibtr
    Left = 592
    Top = 296
  end
  object ds: TDataSource
    DataSet = ibds
    OnDataChange = dsDataChange
    Left = 552
    Top = 336
  end
  object pm: TPopupMenu
    Left = 128
    Top = 280
  end
end
