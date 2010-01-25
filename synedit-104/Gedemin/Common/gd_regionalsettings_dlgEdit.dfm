object dlgRegionalSettings: TdlgRegionalSettings
  Left = 282
  Top = 120
  HelpContext = 120
  BorderIcons = [biSystemMenu, biHelp]
  BorderStyle = bsToolWindow
  Caption = '������������ ���������'
  ClientHeight = 424
  ClientWidth = 400
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pcRegion: TPageControl
    Left = 10
    Top = 7
    Width = 383
    Height = 361
    ActivePage = tsDate
    TabOrder = 0
    object tsNumber: TTabSheet
      Caption = '�����'
      ImageIndex = 3
      object Label1: TLabel
        Left = 16
        Top = 76
        Width = 225
        Height = 13
        Caption = '����������� ����� � ������� ������ �����:'
      end
      object Label2: TLabel
        Left = 16
        Top = 108
        Width = 147
        Height = 13
        Caption = '���������� ������� ������:'
      end
      object Label3: TLabel
        Left = 16
        Top = 140
        Width = 151
        Height = 13
        Caption = '����������� ����� ��������:'
      end
      object Label4: TLabel
        Left = 16
        Top = 172
        Width = 137
        Height = 13
        Caption = '���������� ���� � ������:'
      end
      object Label5: TLabel
        Left = 16
        Top = 204
        Width = 163
        Height = 13
        Caption = '������� �������������� �����:'
        Enabled = False
      end
      object Label6: TLabel
        Left = 16
        Top = 236
        Width = 157
        Height = 13
        Caption = '������ ������������� �����:'
      end
      object Label7: TLabel
        Left = 16
        Top = 268
        Width = 147
        Height = 13
        Caption = '����� ����� � ������ �����:'
      end
      object Label8: TLabel
        Left = 16
        Top = 300
        Width = 166
        Height = 13
        Caption = '����������� ��������� ������:'
      end
      object cbDecimalSeparator: TComboBox
        Left = 256
        Top = 72
        Width = 105
        Height = 21
        Hint = '����������� ����� � ������� ������ �����'
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        OnChange = cbDecimalSeparatorChange
        Items.Strings = (
          '.'
          ',')
      end
      object cbNumberDecimals: TComboBox
        Left = 256
        Top = 104
        Width = 105
        Height = 21
        Hint = '���������� ������� ������'
        Style = csDropDownList
        DropDownCount = 10
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        OnChange = cbDecimalSeparatorChange
        Items.Strings = (
          '0'
          '1'
          '2'
          '3'
          '4'
          '5'
          '6'
          '7'
          '8'
          '9')
      end
      object cbThousandSeparator: TComboBox
        Left = 256
        Top = 136
        Width = 105
        Height = 21
        Hint = '����������� ����� ��������'
        ItemHeight = 0
        ParentShowHint = False
        ShowHint = True
        TabOrder = 2
        OnChange = cbDecimalSeparatorChange
      end
      object cbNumberGroupCount: TComboBox
        Left = 256
        Top = 168
        Width = 105
        Height = 21
        Hint = '���������� ���� � ������'
        Style = csDropDownList
        DropDownCount = 10
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 3
        OnChange = cbDecimalSeparatorChange
        Items.Strings = (
          '0'
          '1'
          '2'
          '3'
          '4'
          '5'
          '6'
          '7'
          '8'
          '9')
      end
      object cbNegativeChar: TComboBox
        Left = 256
        Top = 200
        Width = 105
        Height = 21
        Hint = '������� �������������� �����'
        Enabled = False
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 4
        OnChange = cbDecimalSeparatorChange
        Items.Strings = (
          '-')
      end
      object cbNegativeFormat: TComboBox
        Left = 256
        Top = 232
        Width = 105
        Height = 21
        Hint = '������ ������������� �����'
        Style = csDropDownList
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 5
        OnChange = cbDecimalSeparatorChange
        Items.Strings = (
          '(1.1)'
          '-1.1'
          '- 1.1'
          '1.1-'
          '1.1 -')
      end
      object cbLeadingZero: TComboBox
        Left = 256
        Top = 264
        Width = 105
        Height = 21
        Hint = '����� ����� � ������ �����'
        Style = csDropDownList
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 6
        OnChange = cbDecimalSeparatorChange
        Items.Strings = (
          '0.7'
          '.7')
      end
      object cbListSeparator: TComboBox
        Left = 256
        Top = 296
        Width = 105
        Height = 21
        Hint = '����������� ��������� ������'
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 7
        OnChange = cbDecimalSeparatorChange
        Items.Strings = (
          ';')
      end
      object GroupBox1: TGroupBox
        Left = 8
        Top = 8
        Width = 353
        Height = 57
        Caption = '������� ������ �����'
        TabOrder = 8
        object Label9: TLabel
          Left = 14
          Top = 24
          Width = 40
          Height = 13
          Caption = '�����.:'
        end
        object Label10: TLabel
          Left = 184
          Top = 24
          Width = 37
          Height = 13
          Caption = '�����.:'
        end
        object stNegNum: TStaticText
          Left = 224
          Top = 24
          Width = 121
          Height = 17
          AutoSize = False
          BorderStyle = sbsSunken
          Caption = 'stNegNum'
          TabOrder = 0
        end
        object stNum: TStaticText
          Left = 56
          Top = 24
          Width = 121
          Height = 17
          AutoSize = False
          BorderStyle = sbsSunken
          Caption = 'stNum'
          TabOrder = 1
        end
      end
    end
    object tsCurrency: TTabSheet
      Caption = '�������� �������'
      ImageIndex = 1
      object Label11: TLabel
        Left = 16
        Top = 76
        Width = 170
        Height = 13
        Caption = '����������� �������� �������:'
      end
      object Label12: TLabel
        Left = 16
        Top = 108
        Width = 212
        Height = 13
        Caption = '������ ������������� �������� ����:'
      end
      object Label13: TLabel
        Left = 16
        Top = 140
        Width = 209
        Height = 13
        Caption = '������ ������������� �������� ����:'
      end
      object Label14: TLabel
        Left = 16
        Top = 172
        Width = 225
        Height = 13
        Caption = '����������� ����� � ������� ������ �����:'
      end
      object Label15: TLabel
        Left = 16
        Top = 204
        Width = 147
        Height = 13
        Caption = '���������� ������� ������:'
      end
      object Label16: TLabel
        Left = 16
        Top = 236
        Width = 151
        Height = 13
        Caption = '����������� ����� ��������:'
      end
      object Label17: TLabel
        Left = 16
        Top = 268
        Width = 137
        Height = 13
        Caption = '���������� ���� � ������:'
      end
      object cbCurrencyString: TComboBox
        Left = 256
        Top = 72
        Width = 105
        Height = 21
        Hint = '����������� �������� �������'
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ItemHeight = 13
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        OnChange = cbDecimalSeparatorChange
        Items.Strings = (
          '�.'
          '$')
      end
      object cbCurrencyFormat: TComboBox
        Left = 256
        Top = 104
        Width = 105
        Height = 21
        Hint = '������ ������������� �������� ����'
        Style = csDropDownList
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        OnChange = cbDecimalSeparatorChange
        Items.Strings = (
          '1.1$'
          '$1.1'
          '1.1 $'
          '$ 1.1')
      end
      object cbNegCurrFormat: TComboBox
        Left = 256
        Top = 136
        Width = 105
        Height = 21
        Hint = '������ ������������� �������� ����'
        Style = csDropDownList
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 2
        OnChange = cbDecimalSeparatorChange
        Items.Strings = (
          '($1.1)'
          '-$1.1'
          '$-1.1'
          '$1.1-'
          '(1.1$)'
          '-1.1$'
          '1.1-$'
          '1.1$-'
          '-1.1 $'
          '-$ 1.1'
          '1.1 $-'
          '$ 1.1-'
          '$ -1.1'
          '1.1- $'
          '($ 1.1)'
          '(1.1 $)')
      end
      object cbCurrSeparator: TComboBox
        Left = 256
        Top = 168
        Width = 105
        Height = 21
        Hint = '����������� ����� � ������� ������ �����'
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 3
        OnChange = cbDecimalSeparatorChange
        Items.Strings = (
          '.'
          ',')
      end
      object cbCurrencyDecimals: TComboBox
        Left = 256
        Top = 200
        Width = 105
        Height = 21
        Hint = '���������� ������� ������'
        Style = csDropDownList
        DropDownCount = 10
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 4
        OnChange = cbDecimalSeparatorChange
        Items.Strings = (
          '0'
          '1'
          '2'
          '3'
          '4'
          '5'
          '6'
          '7'
          '8'
          '9')
      end
      object cbCurrThousandSeparator: TComboBox
        Left = 256
        Top = 232
        Width = 105
        Height = 21
        Hint = '����������� ����� ��������'
        ItemHeight = 0
        ParentShowHint = False
        ShowHint = True
        TabOrder = 5
        OnChange = cbDecimalSeparatorChange
      end
      object cbCurrGroup: TComboBox
        Left = 256
        Top = 264
        Width = 105
        Height = 21
        Hint = '���������� ���� � ������'
        Style = csDropDownList
        DropDownCount = 10
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 6
        OnChange = cbDecimalSeparatorChange
        Items.Strings = (
          '0'
          '1'
          '2'
          '3'
          '4'
          '5'
          '6'
          '7'
          '8'
          '9')
      end
      object GroupBox2: TGroupBox
        Left = 8
        Top = 8
        Width = 353
        Height = 57
        Caption = '������� ������ �������� ����'
        TabOrder = 7
        object Label19: TLabel
          Left = 14
          Top = 24
          Width = 40
          Height = 13
          Caption = '�����.:'
        end
        object Label20: TLabel
          Left = 184
          Top = 24
          Width = 37
          Height = 13
          Caption = '�����.:'
        end
        object stCurr: TStaticText
          Left = 56
          Top = 24
          Width = 121
          Height = 17
          AutoSize = False
          BorderStyle = sbsSunken
          Caption = 'StaticText1'
          TabOrder = 0
        end
        object stNegCurr: TStaticText
          Left = 224
          Top = 24
          Width = 121
          Height = 17
          AutoSize = False
          BorderStyle = sbsSunken
          Caption = 'StaticText2'
          TabOrder = 1
        end
      end
    end
    object tsDate: TTabSheet
      Caption = '����'
      ImageIndex = 2
      object GroupBox4: TGroupBox
        Left = 8
        Top = 8
        Width = 353
        Height = 105
        Caption = '�������� ����'
        TabOrder = 0
        object Label26: TLabel
          Left = 16
          Top = 24
          Width = 47
          Height = 13
          Caption = '�������:'
        end
        object Label24: TLabel
          Left = 16
          Top = 52
          Width = 121
          Height = 13
          Caption = '�������� ������ ����:'
        end
        object Label25: TLabel
          Left = 16
          Top = 80
          Width = 167
          Height = 13
          Caption = '����������� ����������� ����:'
        end
        object stDate: TStaticText
          Left = 74
          Top = 24
          Width = 103
          Height = 17
          AutoSize = False
          BorderStyle = sbsSunken
          Caption = 'StaticText1'
          TabOrder = 0
        end
        object cbShortDateFormat: TComboBox
          Left = 220
          Top = 48
          Width = 125
          Height = 21
          Hint = '�������� ������ ����'
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 1
          OnChange = cbDecimalSeparatorChange
          Items.Strings = (
            'dd.MM.yy')
        end
        object cbDateSeparator: TComboBox
          Left = 220
          Top = 76
          Width = 125
          Height = 21
          Hint = '����������� ����������� ����'
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 2
          OnChange = cbDecimalSeparatorChange
          Items.Strings = (
            '.'
            '/')
        end
      end
      object GroupBox5: TGroupBox
        Left = 8
        Top = 117
        Width = 353
        Height = 81
        Caption = '������ ����'
        TabOrder = 1
        object Label27: TLabel
          Left = 16
          Top = 24
          Width = 47
          Height = 13
          Caption = '�������:'
        end
        object Label29: TLabel
          Left = 16
          Top = 56
          Width = 113
          Height = 13
          Caption = '������ ������ ����:'
        end
        object stLongDate: TStaticText
          Left = 74
          Top = 24
          Width = 103
          Height = 17
          AutoSize = False
          BorderStyle = sbsSunken
          Caption = 'StaticText1'
          TabOrder = 0
        end
        object cbLongDateFormat: TComboBox
          Left = 220
          Top = 52
          Width = 125
          Height = 21
          Hint = '������ ������ ����'
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 1
          OnChange = cbDecimalSeparatorChange
          Items.Strings = (
            'd MMMM yyyy'#39' �.'#39)
        end
      end
    end
    object tsTime: TTabSheet
      Caption = '�����'
      ImageIndex = 3
      object Label18: TLabel
        Left = 16
        Top = 76
        Width = 92
        Height = 13
        Caption = '������ �������:'
      end
      object Label21: TLabel
        Left = 16
        Top = 108
        Width = 186
        Height = 13
        Caption = '����������� ����������� �������:'
      end
      object Label22: TLabel
        Left = 16
        Top = 140
        Width = 201
        Height = 13
        Caption = '����������� ������� �� ������� (AM):'
      end
      object Label23: TLabel
        Left = 16
        Top = 172
        Width = 219
        Height = 13
        Caption = '����������� ������� ����� ������� (PM):'
      end
      object cbShortTimeFormat: TComboBox
        Left = 256
        Top = 72
        Width = 105
        Height = 21
        Hint = '������ �������'
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        OnChange = cbDecimalSeparatorChange
        Items.Strings = (
          'H:mm:ss')
      end
      object cbTimeSeparator: TComboBox
        Left = 256
        Top = 104
        Width = 105
        Height = 21
        Hint = '����������� ����������� �������'
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        OnChange = cbDecimalSeparatorChange
        Items.Strings = (
          ':')
      end
      object cbAMString: TComboBox
        Left = 256
        Top = 136
        Width = 105
        Height = 21
        Hint = '����������� ������� �� ������� (AM)'
        ItemHeight = 0
        ParentShowHint = False
        ShowHint = True
        TabOrder = 2
        OnChange = cbDecimalSeparatorChange
      end
      object cbPMString: TComboBox
        Left = 256
        Top = 168
        Width = 105
        Height = 21
        Hint = '����������� ������� ����� ������� (PM)'
        ItemHeight = 0
        ParentShowHint = False
        ShowHint = True
        TabOrder = 3
        OnChange = cbDecimalSeparatorChange
      end
      object GroupBox3: TGroupBox
        Left = 8
        Top = 8
        Width = 353
        Height = 57
        Caption = '����������'
        TabOrder = 4
        object Label28: TLabel
          Left = 16
          Top = 24
          Width = 47
          Height = 13
          Caption = '�������:'
        end
        object stTime: TStaticText
          Left = 74
          Top = 24
          Width = 103
          Height = 17
          AutoSize = False
          BorderStyle = sbsSunken
          Caption = 'StaticText1'
          TabOrder = 0
        end
      end
    end
  end
  object btnOK: TButton
    Left = 151
    Top = 392
    Width = 75
    Height = 23
    Action = aOK
    Default = True
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 231
    Top = 392
    Width = 75
    Height = 23
    Action = aCancel
    TabOrder = 2
  end
  object btnApply: TButton
    Left = 311
    Top = 392
    Width = 75
    Height = 23
    Action = aApply
    TabOrder = 3
  end
  object chbUseSystemSettings: TCheckBox
    Left = 10
    Top = 371
    Width = 225
    Height = 17
    Caption = '������������ ��������� ���������'
    TabOrder = 4
    OnClick = chbUseSystemSettingsClick
  end
  object Button1: TButton
    Left = 8
    Top = 392
    Width = 75
    Height = 25
    Caption = '�������'
    Enabled = False
    TabOrder = 5
  end
  object alRegion: TActionList
    Left = 52
    Top = 392
    object aOK: TAction
      Caption = 'OK'
      OnExecute = aOKExecute
    end
    object aCancel: TAction
      Caption = '������'
      OnExecute = aCancelExecute
    end
    object aApply: TAction
      Caption = '���������'
      Enabled = False
      OnExecute = aApplyExecute
      OnUpdate = aApplyUpdate
    end
  end
end
