object prp_ScriptComparer: Tprp_ScriptComparer
  Left = 446
  Top = 100
  Width = 865
  Height = 664
  Caption = '��������� �����������'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  PixelsPerInch = 96
  TextHeight = 13
  object pnBottom: TPanel
    Left = 0
    Top = 591
    Width = 849
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
      Caption = '��'
      ModalResult = 1
      TabOrder = 0
    end
    object btnCancel: TButton
      Left = 764
      Top = 6
      Width = 75
      Height = 21
      Anchors = [akRight, akBottom]
      Caption = '������'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object pnMain: TPanel
    Left = 0
    Top = 28
    Width = 849
    Height = 563
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
  end
  object pnToolBar: TPanel
    Left = 0
    Top = 0
    Width = 849
    Height = 28
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 2
    object TBDock1: TTBDock
      Left = 0
      Top = 0
      Width = 849
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
          Caption = '��������� �������'
          Hint = '��������� �������'
          ImageIndex = 48
          Images = dmImages.il16x16
          OnClick = tbNextDiffClick
        end
        object tbPrevDiff: TTBItem
          Caption = '���������� �������'
          Hint = '���������� �������'
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
      Caption = '�����'
      Hint = '�����'
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
      Caption = '��������'
      Hint = '��������'
      ImageIndex = 22
      Visible = False
      OnExecute = actReplaceExecute
    end
    object actOnlyDiff: TAction
      Caption = '������ �������'
      ImageIndex = 29
      OnExecute = actOnlyDiffExecute
      OnUpdate = actOnlyDiffUpdate
    end
    object actHorizSplit: TAction
      Caption = '�������������� �����������'
      ImageIndex = 203
      OnExecute = actHorizSplitExecute
    end
  end
end
