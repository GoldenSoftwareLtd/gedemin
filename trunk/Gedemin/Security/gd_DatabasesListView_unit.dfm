object gd_DatabasesListView: Tgd_DatabasesListView
  Left = 620
  Top = 294
  Width = 677
  Height = 447
  Caption = 'Список зарегистрированных баз данных'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
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
    TabOrder = 0
    object pnlButtons: TPanel
      Left = 476
      Top = 0
      Width = 185
      Height = 34
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
      object btnOk: TButton
        Left = 98
        Top = 6
        Width = 75
        Height = 21
        Action = actOk
        TabOrder = 0
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
    TabOrder = 1
    object lv: TListView
      Left = 1
      Top = 1
      Width = 659
      Height = 347
      Align = alClient
      BorderStyle = bsNone
      Checkboxes = True
      Columns = <
        item
          Caption = 'Наименование'
          Width = 120
        end
        item
          Caption = 'Сервер'
          Width = 74
        end
        item
          Caption = 'Порт'
        end
        item
          AutoSize = True
          Caption = 'Файл БД'
        end>
      GridLines = True
      HideSelection = False
      MultiSelect = True
      RowSelect = True
      SortType = stText
      TabOrder = 0
      ViewStyle = vsReport
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
      object TBControlItem1: TTBControlItem
        Control = Label1
      end
      object tbiFilter: TTBEditItem
        Caption = 'Фильтр:'
        EditCaption = 'Фильтр:'
        EditWidth = 240
      end
      object Label1: TLabel
        Left = 75
        Top = 4
        Width = 48
        Height = 13
        Caption = ' Фильтр: '
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
    end
    object actCreate: TAction
      Caption = 'Создать...'
      ImageIndex = 0
      OnExecute = actCreateExecute
    end
    object actEdit: TAction
      Caption = 'Изменить...'
      ImageIndex = 1
    end
    object actDelete: TAction
      Caption = 'Удалить'
      ImageIndex = 2
    end
  end
end
