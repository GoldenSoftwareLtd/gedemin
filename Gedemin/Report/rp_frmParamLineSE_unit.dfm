object frmParamLineSE: TfrmParamLineSE
  Left = 0
  Top = 0
  Width = 584
  Height = 81
  Align = alTop
  ParentShowHint = False
  ShowHint = True
  TabOrder = 0
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 584
    Height = 81
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 2
    TabOrder = 0
    object pcParam: TPageControl
      Left = 2
      Top = 2
      Width = 580
      Height = 77
      ActivePage = tsParam
      Align = alClient
      TabOrder = 0
      object tsParam: TTabSheet
        Caption = '��������'
        object Label1: TLabel
          Left = 4
          Top = 5
          Width = 79
          Height = 13
          Caption = '������������:'
        end
        object Label2: TLabel
          Left = 4
          Top = 29
          Width = 59
          Height = 13
          Caption = '���������:'
        end
        object edDisplayName: TEdit
          Left = 88
          Top = 2
          Width = 346
          Height = 21
          Hint = '������������ ��������� ��� �����������'
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 0
          OnChange = edDisplayNameChange
        end
        object cbParamType: TComboBox
          Left = 437
          Top = 2
          Width = 133
          Height = 21
          Hint = '��� ���������'
          Style = csDropDownList
          Anchors = [akTop, akRight]
          DropDownCount = 16
          ItemHeight = 13
          TabOrder = 1
          OnChange = cbParamTypeChange
          Items.Strings = (
            '����� �����'
            '�����'
            '����'
            '���� � �����'
            '�����'
            '������'
            '����������'
            '������ �� �������'
            '��������� ������'
            '�� �������������'
            '������'
            '������ ��������'
            '����� ��������'
            '��������� ��������')
        end
        object edHint: TEdit
          Left = 88
          Top = 26
          Width = 346
          Height = 21
          Hint = '�������� ���������'
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 2
          OnChange = edDisplayNameChange
        end
        object chbxRequired: TCheckBox
          Left = 438
          Top = 28
          Width = 120
          Height = 17
          Hint = '�������� ���������� ��� ����������'
          Anchors = [akTop, akRight]
          Caption = '������������ '
          TabOrder = 3
          OnClick = chbxRequiredClick
        end
      end
      object tsValuesList: TTabSheet
        Caption = '������ ��������'
        ImageIndex = 1
        object Label3: TLabel
          Left = 4
          Top = 29
          Width = 379
          Height = 13
          Caption = 
            '������ ����������: "���=1","����� � ������=2","����� �� �������=' +
            '3"'
        end
        object edValuesList: TEdit
          Left = 3
          Top = 1
          Width = 566
          Height = 21
          Hint = 
            '������ � ������� "�����������1=��������1","�����������2=��������' +
            '2",...'
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 0
        end
      end
      object tsLink: TTabSheet
        Caption = '������� � ����'
        ImageIndex = 2
        object Label4: TLabel
          Left = 1
          Top = 4
          Width = 46
          Height = 13
          Caption = '�������:'
        end
        object Label5: TLabel
          Left = 2
          Top = 29
          Width = 120
          Height = 13
          Caption = '���� ��� �����������:'
        end
        object Label6: TLabel
          Left = 421
          Top = 29
          Width = 49
          Height = 13
          Anchors = [akTop, akRight]
          Caption = '���� ��:'
        end
        object edTableName: TEdit
          Left = 50
          Top = 1
          Width = 519
          Height = 21
          Hint = '������������ ������� ��� ��������� ������'
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 0
          Text = '<��� �������>'
          OnChange = edDisplayNameChange
        end
        object edDisplayField: TEdit
          Left = 125
          Top = 26
          Width = 290
          Height = 21
          Hint = '������������ ���� ��� ����������� ��� ��������� ������'
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 1
          Text = '<���� ��� �����������>'
          OnChange = edDisplayNameChange
        end
        object edPrimaryField: TEdit
          Left = 477
          Top = 26
          Width = 92
          Height = 21
          Hint = '������������ ����� ������� ��� ��������� ������'
          Anchors = [akTop, akRight]
          TabOrder = 2
          Text = '<���� ��>'
          OnChange = edDisplayNameChange
        end
      end
      object tsLink2: TTabSheet
        Caption = '������� � ����������'
        ImageIndex = 3
        object Label7: TLabel
          Left = 3
          Top = 4
          Width = 85
          Height = 13
          Caption = '������� ������:'
        end
        object Label8: TLabel
          Left = 4
          Top = 28
          Width = 31
          Height = 13
          Caption = '����:'
        end
        object Label9: TLabel
          Left = 380
          Top = 29
          Width = 63
          Height = 13
          Anchors = [akTop, akRight]
          Caption = '����������:'
        end
        object edConditionScript: TEdit
          Left = 91
          Top = 1
          Width = 477
          Height = 21
          Hint = '������ ��� ��������� ������� ������� ������'
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 0
          Text = '<������� ������ �������>'
          OnChange = edDisplayNameChange
        end
        object cbLanguage: TComboBox
          Left = 91
          Top = 26
          Width = 122
          Height = 21
          Hint = '���� ��������� �������'
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 1
          OnChange = edDisplayNameChange
          Items.Strings = (
            '���'
            'VBScript'
            'JScript')
        end
        object cbSortOrder: TComboBox
          Left = 447
          Top = 26
          Width = 122
          Height = 21
          Hint = '������� ���������� ������'
          Style = csDropDownList
          Anchors = [akTop, akRight]
          ItemHeight = 13
          TabOrder = 2
          OnChange = edDisplayNameChange
          Items.Strings = (
            ''
            '�� �����������'
            '�� ��������')
        end
      end
      object tsLink3: TTabSheet
        Caption = '�������'
        ImageIndex = 4
        object Label10: TLabel
          Left = 7
          Top = 17
          Width = 306
          Height = 13
          Caption = '����������� ������ ������ �� ������������ ����������:'
        end
        object Button1: TButton
          Left = 320
          Top = 13
          Width = 81
          Height = 21
          Caption = '���������...'
          TabOrder = 0
          OnClick = Button1Click
        end
      end
    end
  end
end
