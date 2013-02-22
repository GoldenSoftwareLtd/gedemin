object at_frmSyncNamespace: Tat_frmSyncNamespace
  Left = 417
  Top = 183
  Width = 949
  Height = 505
  Caption = 'at_frmSyncNamespace'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object splMessages: TSplitter
    Left = 0
    Top = 382
    Width = 933
    Height = 3
    Cursor = crVSplit
    Align = alBottom
  end
  object sb: TStatusBar
    Left = 0
    Top = 448
    Width = 933
    Height = 19
    Panels = <>
    SimplePanel = False
  end
  object TBDock: TTBDock
    Left = 0
    Top = 0
    Width = 933
    Height = 26
    object TBToolbar: TTBToolbar
      Left = 0
      Top = 0
      Caption = 'TBToolbar'
      CloseButton = False
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
      object TBSeparatorItem4: TTBSeparatorItem
      end
      object TBItem7: TTBItem
        Action = actLoadFromFile
      end
      object TBItem3: TTBItem
        Action = actSaveToFile
      end
      object TBSeparatorItem2: TTBSeparatorItem
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
      object tbedPath: TEdit
        Left = 0
        Top = 0
        Width = 163
        Height = 21
        TabOrder = 0
      end
    end
  end
  object gr: TgsDBGrid
    Left = 0
    Top = 26
    Width = 933
    Height = 356
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
        Width = 244
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'NamespaceVersion'
        Width = 124
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'NamespaceTimeStamp'
        Width = 112
        Visible = True
      end
      item
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
        Width = 105
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
      end>
  end
  object mMessages: TMemo
    Left = 0
    Top = 385
    Width = 933
    Height = 63
    Align = alBottom
    ScrollBars = ssVertical
    TabOrder = 3
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
      end>
    IndexDefs = <>
    Params = <>
    StoreDefs = True
    Left = 552
    Top = 296
    Data = {
      390100009619E0BD01000000180000000A00000000000300000039010C4E616D
      6573706163656B657904000100000000000D4E616D6573706163654E616D6502
      0049000000010005574944544802000200FF00104E616D657370616365566572
      73696F6E0100490000000100055749445448020002001400124E616D65737061
      636554696D655374616D700800080000000000094F7065726174696F6E010049
      00000001000557494454480200020002000846696C654E616D65020049000000
      010005574944544802000200FF001146696C654E616D6573706163654E616D65
      020049000000010005574944544802000200FF000B46696C6556657273696F6E
      01004900000001000557494454480200020014000D46696C6554696D65537461
      6D7008000800000000000846696C6553697A6504000100000000000000}
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
  end
  object ds: TDataSource
    DataSet = cds
    Left = 600
    Top = 296
  end
  object ActionList: TActionList
    Images = dmImages.il16x16
    OnUpdate = ActionListUpdate
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
      OnExecute = actCompareExecute
      OnUpdate = actCompareUpdate
    end
    object actSaveToFile: TAction
      Caption = '--> Сохранить в файл'
      Hint = 'Сохранить в файл'
      ImageIndex = 202
      OnExecute = actSaveToFileExecute
      OnUpdate = actSaveToFileUpdate
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
    object actSetForSaving: TAction
      Caption = '>> Пометить для сохранения'
      Hint = 'Пометить для сохранения'
      ImageIndex = 240
      OnExecute = actSetForSavingExecute
      OnUpdate = actSetForSavingUpdate
    end
    object actSetForLoading: TAction
      Caption = '<< Пометить для загрузки'
      Hint = 'Пометить для загрузки'
      ImageIndex = 239
      OnExecute = actSetForLoadingExecute
      OnUpdate = actSetForLoadingUpdate
    end
    object actClear: TAction
      Caption = 'Снять отметку'
      Hint = 'Снять пометку'
      ImageIndex = 117
      OnExecute = actClearExecute
      OnUpdate = actClearUpdate
    end
    object actLoadFromFile: TAction
      Caption = 'Загрузить из файла <--'
      Hint = 'Загрузить из файла'
      ImageIndex = 27
      OnUpdate = actLoadFromFileUpdate
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
    object N2: TMenuItem
      Action = actCompareWithData
    end
    object N7: TMenuItem
      Caption = '-'
    end
    object actSaveToFile1: TMenuItem
      Action = actSaveToFile
    end
    object N8: TMenuItem
      Action = actLoadFromFile
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
  end
end
