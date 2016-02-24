object gd_DatabasesListView: Tgd_DatabasesListView
  Left = 540
  Top = 275
  Width = 741
  Height = 606
  Caption = '������ ��� ������'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pnlBottom: TPanel
    Left = 0
    Top = 533
    Width = 725
    Height = 34
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object pnlButtons: TPanel
      Left = 540
      Top = 0
      Width = 185
      Height = 34
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
      object btnOk: TButton
        Left = 23
        Top = 7
        Width = 75
        Height = 21
        Action = actOk
        Default = True
        TabOrder = 0
      end
      object btnCancel: TButton
        Left = 104
        Top = 7
        Width = 75
        Height = 21
        Action = actCancel
        Cancel = True
        TabOrder = 1
      end
    end
  end
  object pnlWorkArea: TPanel
    Left = 0
    Top = 26
    Width = 725
    Height = 507
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object Bevel1: TBevel
      Left = 0
      Top = 0
      Width = 725
      Height = 2
      Align = alTop
      Shape = bsTopLine
    end
    object lv: TListView
      Left = 0
      Top = 2
      Width = 725
      Height = 481
      Align = alClient
      BorderStyle = bsNone
      Columns = <
        item
          Caption = '������������'
          Width = 200
        end
        item
          Caption = '������/����'
          Width = 94
        end
        item
          AutoSize = True
          Caption = '��� �����'
        end>
      ColumnClick = False
      GridLines = True
      HideSelection = False
      ReadOnly = True
      RowSelect = True
      SortType = stText
      TabOrder = 0
      ViewStyle = vsReport
      OnDblClick = lvDblClick
    end
    object tc: TTabControl
      Left = 0
      Top = 483
      Width = 725
      Height = 24
      Align = alBottom
      TabOrder = 1
      TabPosition = tpBottom
      OnChange = tcChange
    end
  end
  object TBDock: TTBDock
    Left = 0
    Top = 0
    Width = 725
    Height = 26
    AllowDrag = False
    LimitToOneRow = True
    object tb: TTBToolbar
      Left = 0
      Top = 0
      Align = alTop
      BorderStyle = bsNone
      Caption = 'tb'
      CloseButton = False
      FullSize = True
      Images = dmImages.il16x16
      MenuBar = True
      ParentShowHint = False
      ProcessShortCuts = True
      ShowHint = True
      ShrinkMode = tbsmWrap
      TabOrder = 0
      object tbiCreate: TTBItem
        Action = actCreate
      end
      object TBItem4: TTBItem
        Action = actCopy
      end
      object tbiEdit: TTBItem
        Action = actEdit
      end
      object tbiDelete: TTBItem
        Action = actDelete
      end
      object TBSeparatorItem1: TTBSeparatorItem
      end
      object TBItem3: TTBItem
        Action = actBackup
      end
      object TBItem2: TTBItem
        Action = actRestore
      end
      object TBSeparatorItem3: TTBSeparatorItem
      end
      object TBItem1: TTBItem
        Action = actImport
      end
      object TBSeparatorItem2: TTBSeparatorItem
      end
      object TBControlItem1: TTBControlItem
        Control = Label1
      end
      object TBControlItem2: TTBControlItem
        Control = edFilter
      end
      object TBSeparatorItem4: TTBSeparatorItem
      end
      object TBControlItem3: TTBControlItem
        Control = lblIniFile
      end
      object Label1: TLabel
        Left = 179
        Top = 4
        Width = 48
        Height = 13
        Caption = ' ������: '
      end
      object lblIniFile: TLabel
        Left = 354
        Top = 4
        Width = 38
        Height = 13
        Caption = 'lblIniFile'
      end
      object edFilter: TEdit
        Left = 227
        Top = 0
        Width = 121
        Height = 21
        TabOrder = 0
        OnChange = edFilterChange
      end
    end
  end
  object al: TActionList
    Images = dmImages.il16x16
    OnUpdate = alUpdate
    Left = 240
    Top = 208
    object actOk: TAction
      Caption = '���������'
      OnExecute = actOkExecute
      OnUpdate = actOkUpdate
    end
    object actCreate: TAction
      Caption = '�������...'
      ImageIndex = 0
      ShortCut = 113
      OnExecute = actCreateExecute
      OnUpdate = actImportUpdate
    end
    object actEdit: TAction
      Caption = '��������...'
      ImageIndex = 1
      ShortCut = 115
      OnExecute = actEditExecute
      OnUpdate = actEditUpdate
    end
    object actDelete: TAction
      Caption = '�������'
      ImageIndex = 2
      ShortCut = 119
      OnExecute = actDeleteExecute
      OnUpdate = actDeleteUpdate
    end
    object actImport: TAction
      Caption = '������ �� ���������� �������'
      ImageIndex = 230
      ShortCut = 16457
      OnExecute = actImportExecute
      OnUpdate = actImportUpdate
    end
    object actCancel: TAction
      Caption = '������'
      OnExecute = actCancelExecute
      OnUpdate = actCancelUpdate
    end
    object actBackup: TAction
      Caption = '�������� �����������...'
      ImageIndex = 109
      ShortCut = 16450
      OnExecute = actBackupExecute
      OnUpdate = actBackupUpdate
    end
    object actRestore: TAction
      Caption = '�������������� �� ������...'
      ImageIndex = 106
      ShortCut = 16466
      OnExecute = actRestoreExecute
      OnUpdate = actRestoreUpdate
    end
    object actCopy: TAction
      Caption = '�����������...'
      ImageIndex = 3
      ShortCut = 16452
      OnExecute = actCopyExecute
      OnUpdate = actCopyUpdate
    end
    object actCopyToClipboard: TAction
      Caption = 'actCopyToClipboard'
      Hint = '���������� � �����'
      ImageIndex = 10
      ShortCut = 16451
      OnExecute = actCopyToClipboardExecute
      OnUpdate = actCopyToClipboardUpdate
    end
  end
end
