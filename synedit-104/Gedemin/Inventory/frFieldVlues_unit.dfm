object frFieldValues: TfrFieldValues
  Left = 0
  Top = 0
  Width = 320
  Height = 117
  TabOrder = 0
  object ppMain: TgdvParamPanel
    Left = 0
    Top = 0
    Width = 320
    Height = 30
    Align = alTop
    Caption = '�������� ������������ ���������'
    Color = 15329769
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clNavy
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
    OnResize = ppMainResize
    Unwraped = True
    HorisontalOffset = 0
    VerticalOffset = 0
    FillColor = 16316664
    StripeOdd = clLime
    StripeEven = 49606634
    Origin = oLeft
  end
  object sbMain: TgdvParamScrolBox
    Left = 0
    Top = 30
    Width = 320
    Height = 87
    Align = alClient
    Color = 14084071
    ParentColor = False
    TabOrder = 1
    Visible = False
  end
  object pmCondition: TPopupMenu
    Images = dmImages.ilConditionType
    Left = 202
    Top = 48
    object mi0: TMenuItem
      Caption = '�����'
      ImageIndex = 0
    end
    object mi1: TMenuItem
      Tag = 1
      Caption = '�� �����'
      ImageIndex = 1
    end
    object mi2: TMenuItem
      Tag = 2
      Caption = '������'
      ImageIndex = 2
    end
    object mi3: TMenuItem
      Tag = 3
      Caption = '������ ��� �����'
      ImageIndex = 3
    end
    object mi4: TMenuItem
      Tag = 4
      Caption = '������'
      ImageIndex = 4
    end
    object mi5: TMenuItem
      Tag = 5
      Caption = '������ ��� �����'
      ImageIndex = 5
    end
    object mi6: TMenuItem
      Tag = 6
      Caption = '����������'
      ImageIndex = 6
    end
    object mi7: TMenuItem
      Tag = 7
      Caption = '�� ����������'
      ImageIndex = 7
    end
    object N1: TMenuItem
      Tag = 8
      Caption = '����� ����. �������'
      ImageIndex = 8
    end
    object N2: TMenuItem
      Tag = 9
      Caption = '��� ���. �������'
      ImageIndex = 9
    end
  end
end
