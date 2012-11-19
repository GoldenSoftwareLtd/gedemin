object gd_DatabasesListView: Tgd_DatabasesListView
  Left = 461
  Top = 119
  Width = 677
  Height = 547
  Caption = 'Список баз данных'
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
    Top = 475
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
    Height = 449
    Align = alClient
    BevelOuter = bvLowered
    TabOrder = 0
    object lv: TListView
      Left = 1
      Top = 1
      Width = 659
      Height = 447
      Align = alClient
      BorderStyle = bsNone
      Columns = <
        item
          Caption = 'Наименование'
          Width = 200
        end
        item
          Caption = 'Сервер'
          Width = 94
        end
        item
          AutoSize = True
          Caption = 'Файл БД'
        end>
      ColumnClick = False
      GridLines = True
      HideSelection = False
      ReadOnly = True
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
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
      object Label1: TLabel
        Left = 179
        Top = 4
        Width = 48
        Height = 13
        Caption = ' Фильтр: '
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
    Left = 32
    Top = 232
    object actOk: TAction
      Caption = 'Ok'
      OnExecute = actOkExecute
      OnUpdate = actOkUpdate
    end
    object actCreate: TAction
      Caption = 'Создать...'
      ImageIndex = 0
      OnExecute = actCreateExecute
      OnUpdate = actImportUpdate
    end
    object actEdit: TAction
      Caption = 'Изменить...'
      ImageIndex = 1
      OnExecute = actEditExecute
      OnUpdate = actEditUpdate
    end
    object actDelete: TAction
      Caption = 'Удалить'
      ImageIndex = 2
      OnExecute = actDeleteExecute
      OnUpdate = actDeleteUpdate
    end
    object actImport: TAction
      Caption = 'Импорт из системного реестра'
      ImageIndex = 230
      OnExecute = actImportExecute
      OnUpdate = actImportUpdate
    end
    object actCancel: TAction
      Caption = 'Отмена'
      OnExecute = actCancelExecute
    end
    object actBackup: TAction
      Caption = 'Архивное копирование...'
      ImageIndex = 109
      OnExecute = actBackupExecute
    end
    object actRestore: TAction
      Caption = 'Восстановление из архива...'
      ImageIndex = 106
      OnExecute = actRestoreExecute
    end
    object actCopy: TAction
      Caption = 'Дублировать...'
      ImageIndex = 3
      OnExecute = actCopyExecute
      OnUpdate = actCopyUpdate
    end
  end
end
