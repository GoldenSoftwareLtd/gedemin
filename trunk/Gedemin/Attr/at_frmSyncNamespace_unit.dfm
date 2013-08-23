object at_frmSyncNamespace: Tat_frmSyncNamespace
  Left = 329
  Top = 330
  Width = 1131
  Height = 518
  Caption = 'Синхронизация пространств имен'
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
  object splMessages: TSplitter
    Left = 0
    Top = 395
    Width = 1115
    Height = 3
    Cursor = crVSplit
    Align = alBottom
  end
  object sb: TStatusBar
    Left = 0
    Top = 461
    Width = 1115
    Height = 19
    Panels = <>
    SimplePanel = False
  end
  object TBDock: TTBDock
    Left = 0
    Top = 0
    Width = 1115
    Height = 26
    object TBToolbar: TTBToolbar
      Left = 0
      Top = 0
      Caption = 'TBToolbar'
      CloseButton = False
      DockMode = dmCannotFloatOrChangeDocks
      DockPos = 104
      FullSize = True
      Images = dmImages.il16x16
      MenuBar = True
      ParentShowHint = False
      ProcessShortCuts = True
      ShowHint = True
      ShrinkMode = tbsmWrap
      TabOrder = 0
      object TBControlItem2: TTBControlItem
        Control = tbedPath
      end
      object TBItem1: TTBItem
        Action = actChooseDir
      end
      object TBItem2: TTBItem
        Action = actCompare
      end
      object TBSeparatorItem8: TTBSeparatorItem
      end
      object TBControlItem5: TTBControlItem
        Control = chbxUpdate
      end
      object TBSeparatorItem4: TTBSeparatorItem
      end
      object TBItem4: TTBItem
        Action = actEditNamespace
      end
      object TBItem5: TTBItem
        Action = actEditFile
      end
      object TBItem6: TTBItem
        Action = actCompareWithData
      end
      object TBSeparatorItem1: TTBSeparatorItem
      end
      object TBItem9: TTBItem
        Action = actSetForLoading
      end
      object TBItem8: TTBItem
        Action = actSetForSaving
      end
      object TBItem10: TTBItem
        Action = actClear
      end
      object TBSeparatorItem3: TTBSeparatorItem
      end
      object TBItem11: TTBItem
        Action = actSync
      end
      object TBSeparatorItem5: TTBSeparatorItem
      end
      object TBControlItem1: TTBControlItem
        Control = lSearch
      end
      object tbiFLTOnlyInDB: TTBItem
        Action = actFLTOnlyInDB
      end
      object tbiFLTOlder: TTBItem
        Action = actFLTOlder
      end
      object TBItem12: TTBItem
        Action = actFLTEqualOlder
      end
      object tbiFLTEqual: TTBItem
        Action = actFLTEqual
      end
      object TBItem13: TTBItem
        Action = actFLTEqualNewer
      end
      object tbiFLTNewer: TTBItem
        Action = actFLTNewer
      end
      object tbiFLTOnlyInFile: TTBItem
        Action = actFLTOnlyInFile
      end
      object tbiFLTNone: TTBItem
        Action = actFLTNone
      end
      object TBItem14: TTBItem
        Action = actFLTInUses
      end
      object TBSeparatorItem6: TTBSeparatorItem
      end
      object TBControlItem3: TTBControlItem
        Control = edFilter
      end
      object TBSeparatorItem7: TTBSeparatorItem
      end
      object TBControlItem4: TTBControlItem
        Control = cbPackets
      end
      object lSearch: TLabel
        Left = 474
        Top = 4
        Width = 45
        Height = 13
        Caption = 'Фильтр: '
      end
      object tbedPath: TEdit
        Left = 0
        Top = 0
        Width = 163
        Height = 21
        TabOrder = 0
      end
      object edFilter: TEdit
        Left = 737
        Top = 0
        Width = 140
        Height = 21
        TabOrder = 1
        OnChange = edFilterChange
      end
      object cbPackets: TCheckBox
        Left = 883
        Top = 2
        Width = 66
        Height = 17
        Action = actFLTInternal
        Caption = 'Пакеты'
        TabOrder = 2
      end
      object chbxUpdate: TCheckBox
        Left = 215
        Top = 2
        Width = 74
        Height = 17
        Caption = 'Обновить'
        Checked = True
        State = cbChecked
        TabOrder = 3
      end
    end
  end
  object gr: TgsDBGrid
    Left = 0
    Top = 49
    Width = 1115
    Height = 346
    Align = alClient
    BorderStyle = bsNone
    DataSource = ds
    Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgMultiSelect]
    PopupMenu = pmSync
    ReadOnly = True
    TabOrder = 2
    InternalMenuKind = imkWithSeparator
    Expands = <>
    ExpandsActive = False
    ExpandsSeparate = False
    Conditions = <>
    ConditionsActive = False
    CheckBox.DisplayField = 'Operation'
    CheckBox.Visible = False
    CheckBox.FirstColumn = False
    ScaleColumns = True
    MinColWidth = 40
    Columns = <
      item
        Expanded = False
        FieldName = 'Namespacekey'
        Width = -1
        Visible = False
      end
      item
        Expanded = False
        FieldName = 'NamespaceName'
        Width = 112
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'NamespaceVersion'
        Width = 40
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'NamespaceTimeStamp'
        Width = 101
        Visible = True
      end
      item
        Color = clActiveCaption
        Expanded = False
        FieldName = 'Operation'
        Title.Caption = 'Op'
        Width = 40
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'FileName'
        Width = -1
        Visible = False
      end
      item
        Expanded = False
        FieldName = 'FileNamespaceName'
        Width = 514
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'FileVersion'
        Width = 124
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'FileTimeStamp'
        Width = 112
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'FileSize'
        Width = 64
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'FileRUID'
        Width = -1
        Visible = False
      end
      item
        Expanded = False
        FieldName = 'FileInternal'
        Width = -1
        Visible = False
      end
      item
        Expanded = False
        FieldName = 'NamespaceInternal'
        Width = -1
        Visible = False
      end
      item
        Expanded = False
        FieldName = 'HiddenRow'
        Width = -1
        Visible = False
      end>
  end
  object mMessages: TMemo
    Left = 0
    Top = 398
    Width = 1115
    Height = 63
    Align = alBottom
    ScrollBars = ssVertical
    TabOrder = 3
  end
  object Panel1: TPanel
    Left = 0
    Top = 26
    Width = 1115
    Height = 23
    Align = alTop
    Caption = 'База данных      <<----->>      Файлы на диске'
    Color = clWindow
    TabOrder = 4
  end
  object cds: TClientDataSet
    Active = True
    Aggregates = <>
    FieldDefs = <
      item
        Name = 'Namespacekey'
        DataType = ftInteger
      end
      item
        Name = 'NamespaceName'
        DataType = ftString
        Size = 255
      end
      item
        Name = 'NamespaceVersion'
        DataType = ftString
        Size = 20
      end
      item
        Name = 'NamespaceTimeStamp'
        DataType = ftDateTime
      end
      item
        Name = 'Operation'
        DataType = ftString
        Size = 2
      end
      item
        Name = 'FileName'
        DataType = ftString
        Size = 255
      end
      item
        Name = 'FileNamespaceName'
        DataType = ftString
        Size = 255
      end
      item
        Name = 'FileVersion'
        DataType = ftString
        Size = 20
      end
      item
        Name = 'FileTimeStamp'
        DataType = ftDateTime
      end
      item
        Name = 'FileSize'
        DataType = ftInteger
      end
      item
        Name = 'FileRUID'
        DataType = ftString
        Size = 20
      end
      item
        Name = 'FileInternal'
        DataType = ftInteger
      end
      item
        Name = 'NamespaceInternal'
        DataType = ftInteger
      end
      item
        Name = 'HiddenRow'
        Attributes = [faHiddenCol]
        DataType = ftInteger
      end>
    IndexDefs = <
      item
        Name = 'DEFAULT_ORDER'
      end
      item
        Name = 'CHANGEINDEX'
      end>
    Params = <>
    StoreDefs = True
    OnFilterRecord = cdsFilterRecord
    Left = 552
    Top = 296
    Data = {
      AD0100009619E0BD01000000180000000E000000000003000000AD010C4E616D
      6573706163656B657904000100000000000D4E616D6573706163654E616D6502
      0049000000010005574944544802000200FF00104E616D657370616365566572
      73696F6E0100490000000100055749445448020002001400124E616D65737061
      636554696D655374616D700800080000000000094F7065726174696F6E010049
      00000001000557494454480200020002000846696C654E616D65020049000000
      010005574944544802000200FF001146696C654E616D6573706163654E616D65
      020049000000010005574944544802000200FF000B46696C6556657273696F6E
      01004900000001000557494454480200020014000D46696C6554696D65537461
      6D7008000800000000000846696C6553697A6504000100000000000846696C65
      5255494401004900000001000557494454480200020014000C46696C65496E74
      65726E616C0400010000000000114E616D657370616365496E7465726E616C04
      000100000000000948696464656E526F77040001000100000001000D44454641
      554C545F4F524445520200820000000000}
    object cdsNamespacekey: TIntegerField
      FieldName = 'Namespacekey'
      Visible = False
    end
    object cdsNamespaceName: TStringField
      DisplayWidth = 72
      FieldName = 'NamespaceName'
      Size = 255
    end
    object cdsNamespaceVersion: TStringField
      DisplayWidth = 12
      FieldName = 'NamespaceVersion'
    end
    object cdsNamespaceTimeStamp: TDateTimeField
      FieldName = 'NamespaceTimeStamp'
    end
    object cdsNamespaceInternal: TIntegerField
      FieldName = 'NamespaceInternal'
      Visible = False
    end
    object cdsOperation: TStringField
      DisplayLabel = 'Op'
      DisplayWidth = 2
      FieldName = 'Operation'
      Size = 2
    end
    object cdsFileName2: TStringField
      DisplayWidth = 40
      FieldName = 'FileName'
      Visible = False
      Size = 255
    end
    object cdsFileName: TStringField
      DisplayWidth = 72
      FieldName = 'FileNamespaceName'
      Size = 255
    end
    object cdsFileVersion: TStringField
      DisplayWidth = 12
      FieldName = 'FileVersion'
    end
    object cdsFileTimeStamp: TDateTimeField
      FieldName = 'FileTimeStamp'
    end
    object cdsFileSize: TIntegerField
      FieldName = 'FileSize'
    end
    object cdsFileRUID: TStringField
      FieldName = 'FileRUID'
      Visible = False
    end
    object cdsFileInternal: TIntegerField
      FieldName = 'FileInternal'
      ProviderFlags = []
      Visible = False
    end
    object cdsHiddenRow: TIntegerField
      DefaultExpression = '0'
      FieldName = 'HiddenRow'
      Visible = False
    end
  end
  object ds: TDataSource
    Left = 600
    Top = 296
  end
  object ActionList: TActionList
    Images = dmImages.il16x16
    Left = 552
    Top = 242
    object actChooseDir: TAction
      Caption = 'actChooseDir'
      Hint = 'Открыть папку'
      ImageIndex = 132
      OnExecute = actChooseDirExecute
    end
    object actCompare: TAction
      Caption = 'Сравнить'
      Hint = 'Сравнить с файлами'
      ImageIndex = 131
      ShortCut = 116
      OnExecute = actCompareExecute
      OnUpdate = actCompareUpdate
    end
    object actEditNamespace: TAction
      Caption = '<-- Редактировать объект'
      Hint = 'Редактировать объект'
      ImageIndex = 1
      OnExecute = actEditNamespaceExecute
      OnUpdate = actEditNamespaceUpdate
    end
    object actEditFile: TAction
      Caption = 'Редактировать файл -->'
      Hint = 'Редактировать файл'
      ImageIndex = 177
      OnExecute = actEditFileExecute
      OnUpdate = actEditFileUpdate
    end
    object actCompareWithData: TAction
      Caption = '<-- Сравнить с файлом -->'
      Hint = 'Сравнить с файлом'
      ImageIndex = 203
      OnExecute = actCompareWithDataExecute
      OnUpdate = actCompareWithDataUpdate
    end
    object actSetForLoading: TAction
      Caption = '<< Пометить для загрузки'
      Hint = 'Пометить для загрузки'
      ImageIndex = 239
      OnExecute = actSetForLoadingExecute
      OnUpdate = actSetForLoadingUpdate
    end
    object actSetForSaving: TAction
      Caption = '>> Пометить для сохранения'
      Hint = 'Пометить для сохранения'
      ImageIndex = 240
      OnExecute = actSetForSavingExecute
      OnUpdate = actSetForSavingUpdate
    end
    object actClear: TAction
      Caption = 'Снять отметку'
      Hint = 'Снять пометку'
      ImageIndex = 117
      ShortCut = 8238
      OnExecute = actClearExecute
      OnUpdate = actClearUpdate
    end
    object actSync: TAction
      Caption = 'Синхронизировать...'
      Hint = 'Синхронизировать'
      ImageIndex = 21
      ShortCut = 120
      OnExecute = actSyncExecute
      OnUpdate = actSyncUpdate
    end
    object actDeleteFile: TAction
      Caption = 'Удалить файл -->'
      Hint = 'Удалить файл'
      ImageIndex = 178
      OnExecute = actDeleteFileExecute
      OnUpdate = actDeleteFileUpdate
    end
    object actFLTOnlyInDB: TAction
      Caption = '>'
      Hint = 'Присутствует в БД, отсутствует на диске'
      OnExecute = actFLTOnlyInDBExecute
      OnUpdate = actFLTOnlyInDBUpdate
    end
    object actFLTEqual: TAction
      Caption = '=='
      Hint = 'Пространство имен в БД соответствует записанному на диске'
      OnExecute = actFLTOnlyInDBExecute
      OnUpdate = actFLTOnlyInDBUpdate
    end
    object actFLTOlder: TAction
      Caption = '>>'
      Hint = 'В БД новее, чем на диске'
      OnExecute = actFLTOnlyInDBExecute
      OnUpdate = actFLTOnlyInDBUpdate
    end
    object actFLTNewer: TAction
      Caption = '<<'
      Hint = 'На диске новее, чем в БД'
      OnExecute = actFLTOnlyInDBExecute
      OnUpdate = actFLTOnlyInDBUpdate
    end
    object actFLTNone: TAction
      Caption = '?'
      Hint = 'Пространство имен изменено и в БД и на диске'
      OnExecute = actFLTOnlyInDBExecute
      OnUpdate = actFLTOnlyInDBUpdate
    end
    object actFLTOnlyInFile: TAction
      Caption = '<'
      Hint = 'Отсутствует в БД, присутствует на диске'
      OnExecute = actFLTOnlyInDBExecute
      OnUpdate = actFLTOnlyInDBUpdate
    end
    object actFLTInternal: TAction
      Caption = 'Только пакеты'
      OnExecute = actFLTInternalExecute
    end
    object actFLTEqualOlder: TAction
      Caption = '=>'
      Hint = 
        'Хотя бы одно из ПИ, от которых зависит данное ПИ, новее, чем зап' +
        'исанное на диске'
      OnExecute = actFLTOnlyInDBExecute
      OnUpdate = actFLTOnlyInDBUpdate
    end
    object actFLTEqualNewer: TAction
      Caption = '<='
      Hint = 
        'Хотя бы одно из ПИ, от которых зависит данное ПИ, новее на диске' +
        ', чем в БД'
      OnExecute = actFLTOnlyInDBExecute
      OnUpdate = actFLTOnlyInDBUpdate
    end
    object actFLTInUses: TAction
      Caption = '!'
      Hint = 'Перечислено в списке зависимости, но не найдено в БД и на диске'
      OnExecute = actFLTOnlyInDBExecute
      OnUpdate = actFLTOnlyInDBUpdate
    end
    object actSelectAll: TAction
      Caption = 'Выделить все'
      Hint = 'Выделить все записи'
      ShortCut = 16449
      OnExecute = actSelectAllExecute
      OnUpdate = actSelectAllUpdate
    end
  end
  object pmSync: TPopupMenu
    Images = dmImages.il16x16
    Left = 408
    Top = 160
    object actEditNamespace1: TMenuItem
      Action = actEditNamespace
    end
    object N1: TMenuItem
      Action = actEditFile
    end
    object N10: TMenuItem
      Action = actDeleteFile
    end
    object N7: TMenuItem
      Caption = '-'
    end
    object N2: TMenuItem
      Action = actCompareWithData
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object N4: TMenuItem
      Action = actSetForLoading
    end
    object N5: TMenuItem
      Action = actSetForSaving
    end
    object N6: TMenuItem
      Action = actClear
    end
    object N8: TMenuItem
      Caption = '-'
    end
    object actSelectAll1: TMenuItem
      Action = actSelectAll
    end
    object N9: TMenuItem
      Caption = '-'
    end
    object N11: TMenuItem
      Action = actSync
    end
  end
end
