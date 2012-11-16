object gd_DatabasesListView: Tgd_DatabasesListView
  Left = 461
  Top = 119
  Width = 677
  Height = 447
  Caption = '������ ������������������ ��� ������'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pnlBottom: TPanel
    Left = 0
    Top = 375
    Width = 661
    Height = 34
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object pnlButtons: TPanel
      Left = 476
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
      object Button1: TButton
        Left = 104
        Top = 7
        Width = 75
        Height = 21
        Action = actCancel
        TabOrder = 1
      end
    end
  end
  object pnlWorkArea: TPanel
    Left = 0
    Top = 26
    Width = 661
    Height = 349
    Align = alClient
    BevelOuter = bvLowered
    TabOrder = 0
    object lv: TListView
      Left = 1
      Top = 1
      Width = 659
      Height = 347
      Align = alClient
      BorderStyle = bsNone
      Columns = <
        item
          Caption = '������������'
          Width = 200
        end
        item
          Caption = '������'
          Width = 94
        end
        item
          AutoSize = True
          Caption = '���� ��'
        end>
      ColumnClick = False
      GridLines = True
      HideSelection = False
      ReadOnly = True
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
      OnChange = lvChange
      OnDblClick = lvDblClick
    end
  end
  object TBDock: TTBDock
    Left = 0
    Top = 0
    Width = 661
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
      ProcessShortCuts = True
      ShrinkMode = tbsmWrap
      TabOrder = 0
      object tbiCreate: TTBItem
        Action = actCreate
      end
      object tbiEdit: TTBItem
        Action = actEdit
      end
      object tbiDelete: TTBItem
        Action = actDelete
      end
      object TBSeparatorItem1: TTBSeparatorItem
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
      object Label1: TLabel
        Left = 104
        Top = 4
        Width = 48
        Height = 13
        Caption = ' ������: '
      end
      object edFilter: TEdit
        Left = 152
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
    Left = 32
    Top = 232
    object actOk: TAction
      Caption = 'Ok'
      OnExecute = actOkExecute
      OnUpdate = actOkUpdate
    end
    object actCreate: TAction
      Caption = '�������...'
      ImageIndex = 0
      OnExecute = actCreateExecute
      OnUpdate = actImportUpdate
    end
    object actEdit: TAction
      Caption = '��������...'
      ImageIndex = 1
      OnUpdate = actImportUpdate
    end
    object actDelete: TAction
      Caption = '�������'
      ImageIndex = 2
      OnUpdate = actImportUpdate
    end
    object actImport: TAction
      Caption = '������ �� ���������� �������'
      ImageIndex = 230
      OnExecute = actImportExecute
      OnUpdate = actImportUpdate
    end
    object actCancel: TAction
      Caption = '������'
      OnExecute = actCancelExecute
    end
  end
end
