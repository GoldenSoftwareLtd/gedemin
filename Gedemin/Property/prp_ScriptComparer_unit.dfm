object prp_ScriptComparer: Tprp_ScriptComparer
  Left = 446
  Top = 101
  Width = 865
  Height = 664
  Caption = 'Сравнение содержимого'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  PixelsPerInch = 96
  TextHeight = 13
  object pnBottom: TPanel
    Left = 0
    Top = 598
    Width = 857
    Height = 35
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object btnOK: TButton
      Left = 681
      Top = 6
      Width = 75
      Height = 21
      Anchors = [akRight, akBottom]
      Caption = 'ОК'
      ModalResult = 1
      TabOrder = 0
    end
    object btnCancel: TButton
      Left = 764
      Top = 6
      Width = 75
      Height = 21
      Anchors = [akRight, akBottom]
      Caption = 'Отмена'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object pnMain: TPanel
    Left = 0
    Top = 28
    Width = 857
    Height = 570
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
  end
  object pnToolBar: TPanel
    Left = 0
    Top = 0
    Width = 857
    Height = 28
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 2
    object TBDock1: TTBDock
      Left = 0
      Top = 0
      Width = 857
      Height = 26
      object TBToolbar1: TTBToolbar
        Left = 0
        Top = 0
        BorderStyle = bsNone
        Caption = 'TBToolbar1'
        DefaultDock = TBDock1
        DockMode = dmCannotFloatOrChangeDocks
        DockPos = -16
        Images = dmImages.il16x16
        ParentShowHint = False
        ShowHint = True
        Stretch = True
        TabOrder = 0
        object tbNextDiff: TTBItem
          Caption = 'Следующее отличие'
          Hint = 'Следующее отличие'
          ImageIndex = 48
          Images = dmImages.il16x16
          OnClick = tbNextDiffClick
        end
        object tbPrevDiff: TTBItem
          Caption = 'Предыдущее отличие'
          Hint = 'Предыдущее отличие'
          ImageIndex = 47
          Images = dmImages.il16x16
          OnClick = tbPrevDiffClick
        end
        object TBSeparatorItem1: TTBSeparatorItem
        end
        object tbOnlyDiff: TTBItem
          Action = actOnlyDiff
          Images = dmImages.il16x16
        end
        object tbHorizSplit: TTBItem
          Action = actHorizSplit
          Images = dmImages.il16x16
        end
        object TBSeparatorItem2: TTBSeparatorItem
        end
        object TBItem1: TTBItem
          Action = actFind
        end
        object TBItem2: TTBItem
          Action = actReplace
        end
      end
    end
  end
  object ActionList1: TActionList
    Images = dmImages.il16x16
    Left = 192
    Top = 292
    object actFind: TAction
      Category = 'Find'
      Caption = 'Найти'
      Hint = 'Найти'
      ImageIndex = 23
      ShortCut = 16454
      OnExecute = actFindExecute
    end
    object actFindNext: TAction
      Category = 'Find'
      Caption = 'actFindNext'
      ImageIndex = 23
      ShortCut = 114
      OnExecute = actFindNextExecute
    end
    object actReplace: TAction
      Category = 'Find'
      Caption = 'Заменить'
      Hint = 'Заменить'
      ImageIndex = 22
      Visible = False
      OnExecute = actReplaceExecute
    end
    object actOnlyDiff: TAction
      Caption = 'Только отличия'
      ImageIndex = 29
      OnExecute = actOnlyDiffExecute
      OnUpdate = actOnlyDiffUpdate
    end
    object actHorizSplit: TAction
      Caption = 'Горизонтальное отображение'
      ImageIndex = 203
      OnExecute = actHorizSplitExecute
    end
  end
end
