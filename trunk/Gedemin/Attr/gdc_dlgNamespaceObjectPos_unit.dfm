object gdc_dlgNamespaceObjectPos: Tgdc_dlgNamespaceObjectPos
  Left = 630
  Top = 204
  Width = 529
  Height = 634
  Caption = 'Изменение позиции объектов'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object pnlButtons: TPanel
    Left = 0
    Top = 567
    Width = 513
    Height = 29
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object btnUp: TButton
      Left = 3
      Top = 2
      Width = 75
      Height = 21
      Action = actUp
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
    end
    object btnDown: TButton
      Left = 83
      Top = 2
      Width = 75
      Height = 21
      Action = actDown
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
    end
    object Panel3: TPanel
      Left = 351
      Top = 0
      Width = 162
      Height = 29
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
      object btnOk: TButton
        Left = 1
        Top = 2
        Width = 75
        Height = 21
        Action = actOK
        Default = True
        TabOrder = 0
      end
      object btnCancel: TButton
        Left = 82
        Top = 2
        Width = 75
        Height = 21
        Action = actCancel
        Cancel = True
        TabOrder = 1
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 513
    Height = 567
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 4
    TabOrder = 0
    object lv: TListView
      Left = 4
      Top = 31
      Width = 505
      Height = 532
      Align = alClient
      Columns = <
        item
          AutoSize = True
        end>
      HideSelection = False
      MultiSelect = True
      ReadOnly = True
      RowSelect = True
      ShowColumnHeaders = False
      TabOrder = 1
      ViewStyle = vsReport
    end
    object pnlFind: TPanel
      Left = 4
      Top = 4
      Width = 505
      Height = 27
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      object Label1: TLabel
        Left = 2
        Top = 5
        Width = 35
        Height = 13
        Caption = 'Поиск:'
      end
      object edFind: TEdit
        Left = 43
        Top = 2
        Width = 198
        Height = 21
        TabOrder = 0
        Text = 'edFind'
      end
      object btnFind: TButton
        Left = 240
        Top = 1
        Width = 75
        Height = 21
        Action = actFind
        Caption = 'Поиск (F3)'
        TabOrder = 1
      end
    end
  end
  object ActionList: TActionList
    Left = 176
    Top = 192
    object actOK: TAction
      Caption = 'Ok'
      OnExecute = actOKExecute
    end
    object actCancel: TAction
      Caption = 'Отмена'
      OnExecute = actCancelExecute
    end
    object actUp: TAction
      Caption = 'Вверх'
      Hint = 'Переместить вверх'
      ShortCut = 16469
      OnExecute = actUpExecute
      OnUpdate = actUpUpdate
    end
    object actDown: TAction
      Caption = 'Вниз'
      Hint = 'Переместить вниз'
      ShortCut = 16452
      OnExecute = actDownExecute
      OnUpdate = actDownUpdate
    end
    object actFind: TAction
      Caption = 'Поиск'
      ShortCut = 114
      OnExecute = actFindExecute
      OnUpdate = actFindUpdate
    end
  end
end
