object frEditFrame: TfrEditFrame
  Left = 0
  Top = 0
  Width = 442
  Height = 277
  HelpContext = 205
  Align = alClient
  AutoSize = True
  Constraints.MaxWidth = 442
  Constraints.MinHeight = 173
  Constraints.MinWidth = 442
  TabOrder = 0
  object PageControl: TPageControl
    Left = 0
    Top = 0
    Width = 442
    Height = 277
    ActivePage = tsGeneral
    Align = alClient
    Constraints.MinHeight = 173
    Constraints.MinWidth = 442
    HotTrack = True
    TabOrder = 0
    object tsGeneral: TTabSheet
      Caption = '�����'
      object Label1: TLabel
        Left = 4
        Top = 5
        Width = 79
        Height = 13
        Caption = '������������:'
        WordWrap = True
      end
      object Label2: TLabel
        Left = 4
        Top = 55
        Width = 53
        Height = 13
        Caption = '��������:'
      end
      object lLocalName: TLabel
        Left = 4
        Top = 23
        Width = 89
        Height = 30
        AutoSize = False
        Caption = '�������������� ������������:'
        WordWrap = True
      end
      object cbName: TComboBox
        Left = 95
        Top = 5
        Width = 330
        Height = 21
        Style = csSimple
        Anchors = [akLeft, akTop, akRight]
        ItemHeight = 13
        TabOrder = 0
        Text = 'cbName'
      end
      object mDescription: TMemo
        Left = 95
        Top = 51
        Width = 330
        Height = 89
        Anchors = [akLeft, akTop, akRight]
        Lines.Strings = (
          'mDescription')
        TabOrder = 2
      end
      object eLocalName: TEdit
        Left = 95
        Top = 28
        Width = 330
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 1
      end
    end
  end
end
