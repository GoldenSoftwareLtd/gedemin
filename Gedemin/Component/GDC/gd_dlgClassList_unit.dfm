object gd_dlgClassList: Tgd_dlgClassList
  Left = 486
  Top = 263
  Width = 826
  Height = 530
  Caption = 'Список бизнес-классов'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 160
    Top = 184
    Width = 31
    Height = 13
    Caption = 'Label1'
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 460
    Width = 810
    Height = 31
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object Panel2: TPanel
      Left = 646
      Top = 0
      Width = 164
      Height = 31
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
      object btnOk: TButton
        Left = 3
        Top = 5
        Width = 75
        Height = 21
        Action = actOk
        Default = True
        TabOrder = 0
      end
      object btnCancel: TButton
        Left = 83
        Top = 5
        Width = 75
        Height = 21
        Action = actCancel
        Cancel = True
        TabOrder = 1
      end
    end
  end
  object TBDock: TTBDock
    Left = 0
    Top = 0
    Width = 810
    Height = 25
    object TBToolbar: TTBToolbar
      Left = 0
      Top = 0
      BorderStyle = bsNone
      CloseButton = False
      DockMode = dmCannotFloatOrChangeDocks
      FullSize = True
      MenuBar = True
      ProcessShortCuts = True
      ShrinkMode = tbsmWrap
      TabOrder = 0
      object TBItem1: TTBItem
        Action = actForm
      end
      object TBSeparatorItem2: TTBSeparatorItem
      end
      object TBControlItem2: TTBControlItem
        Control = Label2
      end
      object TBControlItem3: TTBControlItem
        Control = edFilter
      end
      object TBSeparatorItem1: TTBSeparatorItem
      end
      object TBControlItem1: TTBControlItem
        Control = lblClassesCount
      end
      object lblClassesCount: TLabel
        Left = 377
        Top = 4
        Width = 75
        Height = 13
        Caption = 'lblClassesCount'
      end
      object Label2: TLabel
        Left = 170
        Top = 4
        Width = 48
        Height = 13
        Caption = ' Фильтр: '
      end
      object edFilter: TEdit
        Left = 218
        Top = 0
        Width = 153
        Height = 21
        TabOrder = 0
        OnChange = edFilterChange
      end
    end
  end
  object lvClasses: TListView
    Left = 0
    Top = 25
    Width = 810
    Height = 435
    Align = alClient
    Columns = <
      item
        Caption = 'Бизнес-класс'
        Width = 180
      end
      item
        Caption = 'Подтип'
        Width = 180
      end
      item
        Caption = 'Описание'
        Width = 240
      end
      item
        Caption = 'Таблица'
        Width = 180
      end>
    HideSelection = False
    ReadOnly = True
    RowSelect = True
    SortType = stText
    TabOrder = 0
    ViewStyle = vsReport
    OnDblClick = lvClassesDblClick
  end
  object ActionList: TActionList
    Left = 688
    Top = 112
    object actOk: TAction
      Caption = 'Ok'
      OnExecute = actOkExecute
      OnUpdate = actOkUpdate
    end
    object actCancel: TAction
      Caption = 'Отмена'
      OnExecute = actCancelExecute
    end
    object actForm: TAction
      Caption = 'Открыть форму просмотра'
      OnExecute = actFormExecute
      OnUpdate = actFormUpdate
    end
  end
end
