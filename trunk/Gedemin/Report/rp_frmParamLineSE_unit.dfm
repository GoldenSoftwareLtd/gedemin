object frmParamLineSE: TfrmParamLineSE
  Left = 0
  Top = 0
  Width = 443
  Height = 111
  Align = alTop
  ParentShowHint = False
  ShowHint = True
  TabOrder = 0
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 443
    Height = 111
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object Bevel1: TBevel
      Left = 0
      Top = 109
      Width = 443
      Height = 2
      Align = alBottom
      Shape = bsBottomLine
    end
    object pnlSimple: TPanel
      Left = 0
      Top = 0
      Width = 443
      Height = 56
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      object lblParamName: TLabel
        Left = 8
        Top = 7
        Width = 68
        Height = 13
        Hint = '������������ ���������'
        Caption = 'lblParamName'
      end
      object edDisplayName: TEdit
        Left = 176
        Top = 4
        Width = 130
        Height = 21
        Hint = '������������ ��������� ��� �����������'
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 0
        OnChange = edDisplayNameChange
      end
      object cbParamType: TComboBox
        Left = 310
        Top = 4
        Width = 133
        Height = 21
        Hint = '��� ���������'
        Style = csDropDownList
        Anchors = [akTop, akRight]
        DropDownCount = 10
        ItemHeight = 13
        TabOrder = 1
        OnChange = cbParamTypeChange
        Items.Strings = (
          '����� �����'
          '����� �������'
          '����'
          '���� � �����'
          '�����'
          '������'
          '����������'
          '������ �� �������'
          '������ �� ���������'
          '�� �������������')
      end
      object edHint: TEdit
        Left = 8
        Top = 28
        Width = 298
        Height = 21
        Hint = '�������� ���������'
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 2
        OnChange = edDisplayNameChange
      end
      object chbxRequired: TCheckBox
        Left = 310
        Top = 30
        Width = 120
        Height = 17
        Hint = '�������� ���������� ��� ����������'
        Anchors = [akTop, akRight]
        Caption = '������������ '
        TabOrder = 3
        OnClick = chbxRequiredClick
      end
    end
    object pnlLink: TPanel
      Left = 0
      Top = 56
      Width = 443
      Height = 53
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 1
      object edTableName: TEdit
        Left = 8
        Top = 4
        Width = 209
        Height = 21
        Hint = '������������ ������� ��� ��������� ������'
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 0
        Text = '<��� �������>'
        OnChange = edDisplayNameChange
      end
      object edDisplayField: TEdit
        Left = 222
        Top = 4
        Width = 148
        Height = 21
        Hint = '������������ ���� ��� ����������� ��� ��������� ������'
        Anchors = [akTop, akRight]
        TabOrder = 1
        Text = '<���� ��� �����������>'
        OnChange = edDisplayNameChange
      end
      object edPrimaryField: TEdit
        Left = 375
        Top = 4
        Width = 68
        Height = 21
        Hint = '������������ ����� ������� ��� ��������� ������'
        Anchors = [akTop, akRight]
        TabOrder = 2
        Text = '<���� ��>'
        OnChange = edDisplayNameChange
      end
      object edConditionScript: TEdit
        Left = 8
        Top = 28
        Width = 209
        Height = 21
        Hint = '������ ��� ��������� ������� ������� ������'
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 3
        Text = '<������� ������ �������>'
        OnChange = edDisplayNameChange
      end
      object cbLanguage: TComboBox
        Left = 222
        Top = 28
        Width = 108
        Height = 21
        Hint = '���� ��������� �������'
        Style = csDropDownList
        Anchors = [akTop, akRight]
        ItemHeight = 13
        TabOrder = 4
        OnChange = edDisplayNameChange
        Items.Strings = (
          '���'
          'VBScript'
          'JScript')
      end
      object cbSortOrder: TComboBox
        Left = 335
        Top = 28
        Width = 108
        Height = 21
        Hint = '������� ���������� ������'
        Style = csDropDownList
        Anchors = [akTop, akRight]
        ItemHeight = 13
        TabOrder = 5
        OnChange = edDisplayNameChange
        Items.Strings = (
          ''
          '�� �����������'
          '�� ��������')
      end
    end
  end
end
