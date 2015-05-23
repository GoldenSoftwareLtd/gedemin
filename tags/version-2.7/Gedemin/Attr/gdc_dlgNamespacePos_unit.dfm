inherited gdc_dlgNamespacePos: Tgdc_dlgNamespacePos
  Left = 737
  Top = 296
  Caption = 'Свойства'
  ClientHeight = 388
  ClientWidth = 522
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 8
    Top = 360
  end
  inherited btnNew: TButton
    Left = 80
    Top = 360
  end
  inherited btnHelp: TButton
    Left = 152
    Top = 360
  end
  inherited btnOK: TButton
    Left = 372
    Top = 358
  end
  inherited btnCancel: TButton
    Left = 444
    Top = 358
  end
  inherited pgcMain: TPageControl
    Left = 9
    Width = 503
    Height = 345
    inherited tbsMain: TTabSheet
      BorderWidth = 2
      inherited labelID: TLabel
        Left = 2
      end
      inherited dbtxtID: TDBText
        Left = 111
      end
      object Label2: TLabel
        Left = 2
        Top = 154
        Width = 122
        Height = 13
        Caption = 'Подчиненные объекты:'
      end
      object lName: TLabel
        Left = 2
        Top = 29
        Width = 77
        Height = 13
        Caption = 'Наименование:'
      end
      object dbtxtName: TDBText
        Left = 111
        Top = 29
        Width = 53
        Height = 13
        AutoSize = True
        DataField = 'objectname'
        DataSource = dsgdcBase
      end
      object Label1: TLabel
        Left = 2
        Top = 52
        Width = 102
        Height = 13
        Caption = 'Пространство имен:'
      end
      object Label3: TLabel
        Left = 2
        Top = 76
        Width = 88
        Height = 13
        Caption = 'Главный объект:'
      end
      object ibgr: TgsIBGrid
        Left = 0
        Top = 169
        Width = 491
        Height = 144
        Align = alBottom
        DataSource = dsNSDependent
        Options = [dgTitles, dgColumnResize, dgColLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit]
        ReadOnly = True
        TabOrder = 5
        InternalMenuKind = imkWithSeparator
        Expands = <>
        ExpandsActive = False
        ExpandsSeparate = False
        TitlesExpanding = False
        Conditions = <>
        ConditionsActive = False
        CheckBox.Visible = False
        CheckBox.FirstColumn = False
        MinColWidth = 40
        ColumnEditors = <>
        Aliases = <>
      end
      object iblkupNamespace: TgsIBLookupComboBox
        Left = 109
        Top = 48
        Width = 238
        Height = 21
        HelpContext = 1
        Transaction = ibtrCommon
        DataSource = dsgdcBase
        DataField = 'NAMESPACEKEY'
        ListTable = 'at_namespace'
        ListField = 'name'
        KeyField = 'id'
        ItemHeight = 13
        TabOrder = 0
      end
      object iblkupHeadObject: TgsIBLookupComboBox
        Left = 109
        Top = 72
        Width = 238
        Height = 21
        HelpContext = 1
        Transaction = ibtrCommon
        DataSource = dsgdcBase
        DataField = 'HEADOBJECTKEY'
        ListTable = 'at_object'
        ListField = 'objectname'
        KeyField = 'id'
        ReadOnly = True
        ItemHeight = 13
        TabOrder = 1
      end
      object dbchbxalwaysoverwrite: TDBCheckBox
        Left = 2
        Top = 97
        Width = 217
        Height = 17
        Caption = 'Всегда перезаписывать при загрузке'
        DataField = 'alwaysoverwrite'
        DataSource = dsgdcBase
        TabOrder = 2
        ValueChecked = '1'
        ValueUnchecked = '0'
      end
      object dbchbxdontremove: TDBCheckBox
        Left = 2
        Top = 116
        Width = 257
        Height = 17
        Caption = 'Не удалять при удалении пространства имен'
        DataField = 'dontremove'
        DataSource = dsgdcBase
        TabOrder = 3
        ValueChecked = '1'
        ValueUnchecked = '0'
      end
      object dbchbxincludesiblings: TDBCheckBox
        Left = 2
        Top = 134
        Width = 329
        Height = 17
        Caption = 'Для древовидных иерархий включать вложенные объекты'
        DataField = 'includesiblings'
        DataSource = dsgdcBase
        TabOrder = 4
        ValueChecked = '1'
        ValueUnchecked = '0'
      end
    end
    object tsNS: TTabSheet [1]
      BorderWidth = 2
      Caption = 'ПИ'
      ImageIndex = 2
      object tbNS: TTBToolbar
        Left = 0
        Top = 0
        Width = 491
        Height = 22
        Align = alTop
        Caption = 'tbNS'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        object TBItem1: TTBItem
          Action = actDeleteFromNS
          ImageIndex = 261
          Images = dmImages.il16x16
        end
      end
      object ibgrNS: TgsIBGrid
        Left = 0
        Top = 22
        Width = 491
        Height = 291
        Align = alClient
        DataSource = dsNS
        Options = [dgTitles, dgColumnResize, dgColLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit]
        ReadOnly = True
        TabOrder = 1
        InternalMenuKind = imkWithSeparator
        Expands = <>
        ExpandsActive = False
        ExpandsSeparate = False
        TitlesExpanding = False
        Conditions = <>
        ConditionsActive = False
        CheckBox.Visible = False
        CheckBox.FirstColumn = False
        MinColWidth = 40
        ColumnEditors = <>
        Aliases = <>
      end
    end
  end
  object btnShowObject: TButton [6]
    Left = 224
    Top = 360
    Width = 75
    Height = 21
    Action = actShowObject
    TabOrder = 6
  end
  inherited alBase: TActionList
    Left = 454
    Top = 7
    object actShowObject: TAction
      Caption = 'Объект...'
      OnExecute = actShowObjectExecute
      OnUpdate = actShowObjectUpdate
    end
    object actDeleteFromNS: TAction
      Caption = 'Удалить из пространства имен'
      Hint = 'Удалить из пространства имен'
      OnExecute = actDeleteFromNSExecute
      OnUpdate = actDeleteFromNSUpdate
    end
  end
  inherited dsgdcBase: TDataSource
    Left = 360
    Top = 7
  end
  inherited pm_dlgG: TPopupMenu
    Left = 392
    Top = 8
  end
  inherited ibtrCommon: TIBTransaction
    Left = 424
    Top = 8
  end
  object gdcNSDependent: TgdcNamespaceObject
    MasterSource = dsgdcBase
    MasterField = 'id'
    DetailField = 'headobjectkey'
    SubSet = 'ByHeadObject'
    Left = 376
    Top = 272
  end
  object dsNSDependent: TDataSource
    DataSet = gdcNSDependent
    Left = 408
    Top = 272
  end
  object ibdsNS: TIBDataSet
    Transaction = ibtrCommon
    DeleteSQL.Strings = (
      'DELETE FROM at_object WHERE id = :ObjectID')
    SelectSQL.Strings = (
      'SELECT'
      '  n.name,'
      '  o.id AS ObjectID'
      'FROM'
      '  at_namespace n'
      '    JOIN at_object o ON o.namespacekey = n.id'
      'WHERE'
      '  o.xid = :xid AND o.dbid = :dbid'
      'ORDER BY'
      '  n.name')
    ReadTransaction = ibtrCommon
    Left = 248
    Top = 184
  end
  object dsNS: TDataSource
    DataSet = ibdsNS
    Left = 287
    Top = 184
  end
end
