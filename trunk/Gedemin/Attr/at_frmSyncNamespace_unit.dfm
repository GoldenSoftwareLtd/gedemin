object at_frmSyncNamespace: Tat_frmSyncNamespace
  Left = 366
  Top = 202
  Width = 1142
  Height = 656
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
    Top = 533
    Width = 1126
    Height = 3
    Cursor = crVSplit
    Align = alBottom
  end
  object sb: TStatusBar
    Left = 0
    Top = 599
    Width = 1126
    Height = 19
    Panels = <>
    SimplePanel = False
  end
  object TBDock: TTBDock
    Left = 0
    Top = 0
    Width = 1126
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
      ProcessShortCuts = True
      ShrinkMode = tbsmWrap
      TabOrder = 0
      object tbedPath: TTBEditItem
        EditWidth = 200
      end
      object TBItem1: TTBItem
        Action = actChooseDir
      end
      object TBSeparatorItem1: TTBSeparatorItem
      end
      object TBItem2: TTBItem
        Action = actCompare
      end
      object TBItem3: TTBItem
        Action = actSaveToFile
      end
      object TBSeparatorItem3: TTBSeparatorItem
      end
      object tbiFilter: TTBItem
        Action = actSetFilter
      end
      object TBControlItem1: TTBControlItem
        Control = Label1
      end
      object tbedName: TTBEditItem
        Caption = 'Наименование:'
        EditCaption = 'Наименование:'
        EditWidth = 96
      end
      object Label1: TLabel
        Left = 345
        Top = 4
        Width = 86
        Height = 13
        Caption = '  Наименование: '
      end
    end
  end
  object gr: TgsDBGrid
    Left = 0
    Top = 26
    Width = 1126
    Height = 507
    Align = alClient
    BorderStyle = bsNone
    DataSource = ds
    Options = [dgTitles, dgColumnResize, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgMultiSelect]
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
        Width = 52
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
        Width = 294
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
    Top = 536
    Width = 1126
    Height = 63
    Align = alBottom
    ScrollBars = ssVertical
    TabOrder = 3
  end
  object cds: TClientDataSet
    Active = True
    Aggregates = <>
    Params = <>
    OnFilterRecord = cdsFilterRecord
    Left = 552
    Top = 296
    Data = {
      390100009619E0BD01000000180000000A00000000000300000039010C4E616D
      6573706163656B657904000100000000000D4E616D6573706163654E616D6502
      0049000000010005574944544802000200FF00104E616D657370616365566572
      73696F6E0100490000000100055749445448020002001400124E616D65737061
      636554696D655374616D700800080000000000094F7065726174696F6E010049
      00000001000557494454480200020001000846696C654E616D65020049000000
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
      DisplayWidth = 2
      FieldName = 'Operation'
      Size = 1
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
      ImageIndex = 27
      OnExecute = actChooseDirExecute
    end
    object actCompare: TAction
      Caption = 'Сравнить'
      OnExecute = actCompareExecute
      OnUpdate = actCompareUpdate
    end
    object actSetFilter: TAction
      Caption = 'Фильтр'
      ImageIndex = 20
      OnExecute = actSetFilterExecute
      OnUpdate = actSetFilterUpdate
    end
    object actSaveToFile: TAction
      Caption = 'actSaveToFile'
      ImageIndex = 25
      OnExecute = actSaveToFileExecute
      OnUpdate = actSaveToFileUpdate
    end
    object actEditNamespace: TAction
      Caption = '<-- Редактировать пространство имен'
      ImageIndex = 1
      OnExecute = actEditNamespaceExecute
      OnUpdate = actEditNamespaceUpdate
    end
    object actEditFile: TAction
      Caption = 'Редактировать файл пространства имен -->'
      OnExecute = actEditFileExecute
      OnUpdate = actEditFileUpdate
    end
    object actCompareWithData: TAction
      Caption = '<-- Сравнить с файлом -->'
      OnExecute = actCompareWithDataExecute
      OnUpdate = actCompareWithDataUpdate
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
  end
end
