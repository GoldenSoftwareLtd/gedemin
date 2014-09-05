object at_frmSyncNamespace: Tat_frmSyncNamespace
  Left = 330
  Top = 271
  Width = 1131
  Height = 518
  Caption = '������������� ����������� ����'
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
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
    Top = 370
    Width = 1115
    Height = 2
    Cursor = crVSplit
    Align = alBottom
    Color = clBtnShadow
    ParentColor = False
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
    Height = 49
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
      object TBControlItem6: TTBControlItem
        Control = chbxExisted
      end
      object TBSeparatorItem4: TTBSeparatorItem
      end
      object TBItem4: TTBItem
        Action = actEditNamespace
      end
      object TBItem5: TTBItem
        Action = actEditFile
      end
      object tbsiCompare: TTBSubmenuItem
        ImageIndex = 203
        Options = [tboDropdownArrow]
        object TBItem6: TTBItem
          Action = actCompareWithData
        end
        object TBItem18: TTBItem
          Action = actOnlyCompare
        end
        object TBSeparatorItem9: TTBSeparatorItem
        end
        object TBItem19: TTBItem
          Action = actShowChanged
        end
      end
      object TBSeparatorItem1: TTBSeparatorItem
      end
      object TBItem3: TTBItem
        Action = actSelectAll
      end
      object tbsiSetForLoading: TTBSubmenuItem
        ImageIndex = 239
        Options = [tboDropdownArrow]
        object TBItem9: TTBItem
          Action = actSetForLoading
        end
        object TBItem16: TTBItem
          Action = actSetForLoadingOne
        end
      end
      object TBItem8: TTBItem
        Action = actSetForSaving
      end
      object tbsiClear: TTBSubmenuItem
        ImageIndex = 117
        Options = [tboDropdownArrow]
        object TBItem10: TTBItem
          Action = actClear
        end
        object TBItem17: TTBItem
          Action = actClearAll
        end
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
      object TBSeparatorItem2: TTBSeparatorItem
      end
      object TBItem7: TTBItem
        Action = actFLTSave
      end
      object TBItem15: TTBItem
        Action = actFLTLoad
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
        Left = 555
        Top = 4
        Width = 45
        Height = 13
        Caption = '������: '
      end
      object tbedPath: TEdit
        Left = 0
        Top = 0
        Width = 163
        Height = 21
        TabOrder = 0
      end
      object edFilter: TEdit
        Left = 908
        Top = 0
        Width = 140
        Height = 21
        TabOrder = 1
        OnChange = edFilterChange
      end
      object cbPackets: TCheckBox
        Left = 0
        Top = 28
        Width = 66
        Height = 17
        Action = actFLTInternal
        Caption = '������'
        TabOrder = 2
      end
      object chbxUpdate: TCheckBox
        Left = 215
        Top = 2
        Width = 54
        Height = 17
        Hint = '���������� �� ���� ������ ���� ��������� ��������'
        Alignment = taLeftJustify
        Caption = '�����:'
        Checked = True
        State = cbChecked
        TabOrder = 3
      end
      object chbxExisted: TCheckBox
        Left = 269
        Top = 2
        Width = 54
        Height = 17
        Hint = '���������� ������ ������ ��� �� ������������ � �� � � �����'
        Alignment = taLeftJustify
        Caption = '   ���:'
        Checked = True
        State = cbChecked
        TabOrder = 4
      end
    end
  end
  object gr: TgsDBGrid
    Left = 0
    Top = 72
    Width = 1115
    Height = 298
    Align = alClient
    BorderStyle = bsNone
    DataSource = ds
    Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgMultiSelect]
    PopupMenu = pmSync
    ReadOnly = True
    RefreshType = rtNone
    TabOrder = 1
    InternalMenuKind = imkWithSeparator
    Expands = <>
    ExpandsActive = False
    ExpandsSeparate = False
    Conditions = <
      item
        ConditionName = 'DIR'
        FieldName = 'FileNamespaceName'
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        Color = clWhite
        Expression1 = '\'
        ConditionKind = ckContains
        DisplayOptions = [doFont]
        EvaluateFormula = False
        UserCondition = True
      end>
    ConditionsActive = True
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
  object pnlHeader: TPanel
    Left = 0
    Top = 49
    Width = 1115
    Height = 23
    Align = alTop
    Caption = '���� ������      <<----->>      ����� �� �����'
    Color = clWindow
    TabOrder = 4
  end
  object mMessages: TRichEdit
    Left = 0
    Top = 372
    Width = 1115
    Height = 89
    Align = alBottom
    BorderStyle = bsNone
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 2
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
      Hint = '������� �����'
      ImageIndex = 132
      OnExecute = actChooseDirExecute
    end
    object actCompare: TAction
      Caption = '��������'
      Hint = '�������� � �������'
      ImageIndex = 131
      ShortCut = 116
      OnExecute = actCompareExecute
      OnUpdate = actCompareUpdate
    end
    object actEditNamespace: TAction
      Caption = '<-- ������������� ������'
      Hint = '������������� ������'
      ImageIndex = 1
      OnExecute = actEditNamespaceExecute
      OnUpdate = actEditNamespaceUpdate
    end
    object actEditFile: TAction
      Caption = '������������� ���� -->'
      Hint = '������������� ����'
      ImageIndex = 177
      OnExecute = actEditFileExecute
      OnUpdate = actEditFileUpdate
    end
    object actCompareWithData: TAction
      Caption = '<-- �������� � ���������� -->'
      Hint = '�������� � ������ � ���������� ���������'
      OnExecute = actCompareWithDataExecute
      OnUpdate = actCompareWithDataUpdate
    end
    object actSetForLoading: TAction
      Caption = '<< �������� ��� �������� ������� �� � ��� ���������'
      Hint = '�������� ��� �������� �� � ������ ������ �����������'
      OnExecute = actSetForLoadingExecute
      OnUpdate = actSetForLoadingUpdate
    end
    object actSetForSaving: TAction
      Caption = '>> �������� ��� ����������'
      Hint = '�������� ��� ����������'
      ImageIndex = 240
      OnExecute = actSetForSavingExecute
      OnUpdate = actSetForSavingUpdate
    end
    object actClear: TAction
      Caption = '����� ������� � ���������� �������'
      Hint = '����� �������'
      ShortCut = 8238
      OnExecute = actClearExecute
      OnUpdate = actClearUpdate
    end
    object actSync: TAction
      Caption = '����������������...'
      Hint = '����������������'
      ImageIndex = 21
      ShortCut = 120
      OnExecute = actSyncExecute
      OnUpdate = actSyncUpdate
    end
    object actDeleteFile: TAction
      Caption = '������� ���� -->'
      Hint = '������� ����'
      ImageIndex = 178
      OnExecute = actDeleteFileExecute
      OnUpdate = actDeleteFileUpdate
    end
    object actFLTOnlyInDB: TAction
      Caption = '> '
      Hint = '������������ � ��, ����������� �� �����'
      OnExecute = actFLTOnlyInDBExecute
      OnUpdate = actFLTOnlyInDBUpdate
    end
    object actFLTOlder: TAction
      Caption = '>>'
      Hint = '� �� �����, ��� �� �����'
      OnExecute = actFLTOnlyInDBExecute
      OnUpdate = actFLTOnlyInDBUpdate
    end
    object actFLTEqualOlder: TAction
      Caption = '=>'
      Hint = 
        '���� �� ���� �� ��, �� ������� ������� ������ ��, �����, ��� ���' +
        '������� �� �����'
      OnExecute = actFLTOnlyInDBExecute
      OnUpdate = actFLTOnlyInDBUpdate
    end
    object actFLTEqual: TAction
      Caption = '=='
      Hint = '������������ ���� � �� ������������� ����������� �� �����'
      OnExecute = actFLTOnlyInDBExecute
      OnUpdate = actFLTOnlyInDBUpdate
    end
    object actFLTNewer: TAction
      Caption = '<<'
      Hint = '�� ����� �����, ��� � ��'
      OnExecute = actFLTOnlyInDBExecute
      OnUpdate = actFLTOnlyInDBUpdate
    end
    object actFLTNone: TAction
      Caption = '? '
      Hint = '������������ ���� �������� � � �� � �� �����'
      OnExecute = actFLTOnlyInDBExecute
      OnUpdate = actFLTOnlyInDBUpdate
    end
    object actFLTOnlyInFile: TAction
      Caption = '< '
      Hint = '����������� � ��, ������������ �� �����'
      OnExecute = actFLTOnlyInDBExecute
      OnUpdate = actFLTOnlyInDBUpdate
    end
    object actFLTInternal: TAction
      Caption = '������ ������'
      OnExecute = actFLTInternalExecute
      OnUpdate = actFLTInternalUpdate
    end
    object actFLTEqualNewer: TAction
      Caption = '<='
      Hint = 
        '���� �� ���� �� ��, �� ������� ������� ������ ��, ����� �� �����' +
        ', ��� � ��'
      OnExecute = actFLTOnlyInDBExecute
      OnUpdate = actFLTOnlyInDBUpdate
    end
    object actFLTInUses: TAction
      Caption = '! '
      Hint = '����������� � ������ �����������, �� �� ������� � �� � �� �����'
      OnExecute = actFLTOnlyInDBExecute
      OnUpdate = actFLTOnlyInDBUpdate
    end
    object actSelectAll: TAction
      Caption = '�������� ���'
      Hint = '�������� ��� ������'
      ImageIndex = 29
      ShortCut = 16449
      OnExecute = actSelectAllExecute
      OnUpdate = actSelectAllUpdate
    end
    object actFLTSave: TAction
      Caption = '>>>'
      Hint = '��� �����, ���������� ��� ����������'
      OnExecute = actFLTSaveExecute
      OnUpdate = actFLTSaveUpdate
    end
    object actFLTLoad: TAction
      Caption = '<<<'
      Hint = '��� �����, ���������� ��� ��������'
      OnExecute = actFLTLoadExecute
      OnUpdate = actFLTLoadUpdate
    end
    object actSetForLoadingOne: TAction
      Caption = '<< �������� ��� �������� ������ ������� ��'
      Hint = '�������� ��� �������� ������ ������� ��'
      OnExecute = actSetForLoadingOneExecute
      OnUpdate = actSetForLoadingOneUpdate
    end
    object actClearAll: TAction
      Caption = '����� ������� �� ���� �������'
      Hint = '����� ������� �� ���� �������'
      OnExecute = actClearAllExecute
      OnUpdate = actClearAllUpdate
    end
    object actOnlyCompare: TAction
      Caption = '<-- �������� -->'
      Hint = '�������� � ������'
      OnExecute = actOnlyCompareExecute
      OnUpdate = actOnlyCompareUpdate
    end
    object actShowChanged: TAction
      Caption = '�������� ���������� �������...'
      Hint = '�������� ���������� �������'
      ImageIndex = 225
      OnExecute = actShowChangedExecute
      OnUpdate = actShowChangedUpdate
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
    object N12: TMenuItem
      Action = actOnlyCompare
    end
    object N13: TMenuItem
      Action = actShowChanged
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
