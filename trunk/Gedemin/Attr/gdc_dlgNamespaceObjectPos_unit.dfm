object gdc_dlgNamespaceObjectPos: Tgdc_dlgNamespaceObjectPos
  Left = 630
  Top = 204
  Width = 529
  Height = 634
  Caption = '��������� ������� ��������'
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
      TabOrder = 1
    end
    object btnDown: TButton
      Left = 83
      Top = 2
      Width = 75
      Height = 21
      Action = actDown
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
      Top = 4
      Width = 505
      Height = 559
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
      TabOrder = 0
      ViewStyle = vsReport
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
      Caption = '������'
      OnExecute = actCancelExecute
    end
    object actUp: TAction
      Caption = '�����'
      OnExecute = actUpExecute
      OnUpdate = actUpUpdate
    end
    object actDown: TAction
      Caption = '����'
      OnExecute = actDownExecute
      OnUpdate = actDownUpdate
    end
  end
end
