inherited gdc_dlgAutoTask: Tgdc_dlgAutoTask
  Left = 633
  Top = 250
  Caption = 'gdc_dlgAutoTask'
  ClientHeight = 582
  ClientWidth = 440
  Font.Charset = DEFAULT_CHARSET
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object lbPriority: TLabel [0]
    Left = 8
    Top = 500
    Width = 371
    Height = 13
    Caption = 
      '���������� ����� ���������� ��� �����, ����������� �� ���� �����' +
      ':'
  end
  object Label2: TLabel [1]
    Left = 223
    Top = 265
    Width = 205
    Height = 32
    AutoSize = False
    Caption = '(�������� ���� ������ ��� ���������� ��� ����� ������� �������)'
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    WordWrap = True
  end
  object lbName: TLabel [2]
    Left = 8
    Top = 20
    Width = 77
    Height = 13
    Caption = '������������:'
  end
  object lbDescription: TLabel [3]
    Left = 8
    Top = 42
    Width = 53
    Height = 13
    Caption = '��������:'
  end
  object lbUser: TLabel [4]
    Left = 8
    Top = 244
    Width = 212
    Height = 13
    Caption = '��������� ������ ��� ������� �������:'
  end
  inherited btnAccess: TButton
    Top = 552
    TabOrder = 4
  end
  inherited btnNew: TButton
    Top = 552
    TabOrder = 5
  end
  inherited btnHelp: TButton
    Top = 552
    TabOrder = 6
  end
  inherited btnOK: TButton
    Left = 292
    Top = 552
    TabOrder = 2
  end
  inherited btnCancel: TButton
    Left = 364
    Top = 552
    TabOrder = 3
  end
  object gbTimeTables: TGroupBox [10]
    Left = 6
    Top = 302
    Width = 425
    Height = 188
    Caption = ' ���������� '
    TabOrder = 0
    object lbStartTime: TLabel
      Left = 10
      Top = 145
      Width = 64
      Height = 13
      Caption = '��������� �'
    end
    object lbEndTime: TLabel
      Left = 144
      Top = 145
      Width = 13
      Height = 13
      Caption = '��'
    end
    object Label3: TLabel
      Left = 26
      Top = 69
      Width = 324
      Height = 13
      Caption = '������������� �������� ������ ������ ���� � ����� ������.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Label4: TLabel
      Left = 10
      Top = 166
      Width = 313
      Height = 13
      Caption = '�������� ���� ������� ��� ���������� � ����� ����� ���.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object rbExactDate: TRadioButton
      Left = 8
      Top = 20
      Width = 185
      Height = 21
      Caption = '���������� � ��������� ����:'
      TabOrder = 0
    end
    object xdbeExactDate: TxDateDBEdit
      Left = 200
      Top = 20
      Width = 65
      Height = 21
      DataField = 'exactdate'
      DataSource = dsgdcBase
      Kind = kDate
      EmptyAtStart = True
      EditMask = '!99\.99\.9999;1;_'
      MaxLength = 10
      TabOrder = 1
    end
    object rbMonthly: TRadioButton
      Left = 8
      Top = 44
      Width = 185
      Height = 21
      Caption = '���������� � ��������� ����:'
      TabOrder = 2
    end
    object rbWeekly: TRadioButton
      Left = 8
      Top = 92
      Width = 193
      Height = 21
      Caption = '����������� � ��������� ����:'
      TabOrder = 3
    end
    object dbcbWeekly: TDBComboBox
      Left = 200
      Top = 92
      Width = 113
      Height = 21
      DataField = 'weekly'
      DataSource = dsgdcBase
      ItemHeight = 13
      Items.Strings = (
        '1'
        '2'
        '3'
        '4'
        '5'
        '6'
        '7')
      TabOrder = 4
    end
    object rbDaily: TRadioButton
      Left = 8
      Top = 119
      Width = 89
      Height = 17
      Caption = '���������'
      TabOrder = 5
    end
    object xdbeStartTime: TxDateDBEdit
      Left = 80
      Top = 143
      Width = 57
      Height = 21
      DataField = 'starttime'
      DataSource = dsgdcBase
      Kind = kTime
      EmptyAtStart = True
      EditMask = '!99\:99\:99;1;_'
      MaxLength = 8
      TabOrder = 6
    end
    object xdbeEndTime: TxDateDBEdit
      Left = 163
      Top = 143
      Width = 57
      Height = 21
      DataField = 'endtime'
      DataSource = dsgdcBase
      Kind = kTime
      EmptyAtStart = True
      EditMask = '!99\:99\:99;1;_'
      MaxLength = 8
      TabOrder = 7
    end
    object DBComboBox1: TDBComboBox
      Left = 200
      Top = 46
      Width = 65
      Height = 21
      Style = csDropDownList
      DataField = 'MONTHLY'
      DataSource = dsgdcBase
      DropDownCount = 16
      ItemHeight = 13
      Items.Strings = (
        '1'
        '2'
        '3'
        '4'
        '5'
        '6'
        '7'
        '8'
        '9'
        '10'
        '11'
        '12'
        '13'
        '14'
        '15'
        '16'
        '17'
        '18'
        '19'
        '20'
        '21'
        '22'
        '23'
        '24'
        '25'
        '26'
        '27'
        '28'
        '29'
        '30'
        '31'
        '-1'
        '-2'
        '-3'
        '-4'
        '-5'
        '-6'
        '-7'
        '-8'
        '-9'
        '-10'
        '-11'
        '-12'
        '-13'
        '-14'
        '-15'
        '-16'
        '-17'
        '-18'
        '-19'
        '-20'
        '-21'
        '-22'
        '-23'
        '-24'
        '-25'
        '-26'
        '-27'
        '-28'
        '-29'
        '-30'
        '-31')
      TabOrder = 8
    end
  end
  object dbcbDisabled: TDBCheckBox [11]
    Left = 8
    Top = 522
    Width = 297
    Height = 17
    Caption = '������ ���������'
    DataField = 'disabled'
    DataSource = dsgdcBase
    TabOrder = 1
    ValueChecked = '1'
    ValueUnchecked = '0'
  end
  object dbcbPriority: TDBComboBox [12]
    Left = 384
    Top = 497
    Width = 48
    Height = 21
    DataField = 'PRIORITY'
    DataSource = dsgdcBase
    ItemHeight = 13
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
    TabOrder = 7
  end
  object dbedName: TDBEdit [13]
    Left = 99
    Top = 17
    Width = 330
    Height = 21
    Anchors = []
    DataField = 'NAME'
    DataSource = dsgdcBase
    TabOrder = 8
  end
  object dbmDescription: TDBMemo [14]
    Left = 99
    Top = 42
    Width = 330
    Height = 49
    Anchors = []
    DataField = 'Description'
    DataSource = dsgdcBase
    TabOrder = 9
  end
  object pcTask: TPageControl [15]
    Left = 8
    Top = 98
    Width = 421
    Height = 135
    ActivePage = tsFunction
    Anchors = []
    MultiLine = True
    TabOrder = 10
    object tsFunction: TTabSheet
      Caption = '������-�������'
      object iblkupFunction: TgsIBLookupComboBox
        Left = 8
        Top = 8
        Width = 400
        Height = 21
        HelpContext = 1
        DataSource = dsgdcBase
        DataField = 'FUNCTIONKEY'
        ListTable = 'GD_FUNCTION'
        ListField = 'NAME'
        KeyField = 'ID'
        gdClassName = 'TgdcFunction'
        Anchors = [akLeft, akTop, akRight]
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
      end
    end
    object tsCmd: TTabSheet
      Caption = '������� ���������'
      ImageIndex = 1
      object Label1: TLabel
        Left = 8
        Top = 34
        Width = 368
        Height = 33
        AutoSize = False
        Caption = 
          '��� ������������� ������� ��� ���������  (�������) � ��������� �' +
          '�������� ������.'
        WordWrap = True
      end
      object dbeCmdLine: TDBEdit
        Left = 8
        Top = 8
        Width = 373
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        DataField = 'cmdline'
        DataSource = dsgdcBase
        TabOrder = 0
      end
      object btnCmdLine: TButton
        Left = 381
        Top = 7
        Width = 25
        Height = 21
        Anchors = [akTop, akRight]
        Caption = '...'
        TabOrder = 1
        OnClick = btnCmdLineClick
      end
    end
  end
  object iblkupUser: TgsIBLookupComboBox [16]
    Left = 222
    Top = 240
    Width = 208
    Height = 21
    HelpContext = 1
    DataSource = dsgdcBase
    DataField = 'USERKEY'
    ListTable = 'GD_USER'
    ListField = 'NAME'
    KeyField = 'ID'
    gdClassName = 'TgdcUser'
    Anchors = []
    ItemHeight = 13
    ParentShowHint = False
    ShowHint = True
    TabOrder = 11
  end
  inherited alBase: TActionList
    Left = 238
    Top = 549
  end
  inherited dsgdcBase: TDataSource
    Left = 200
    Top = 549
  end
  inherited pm_dlgG: TPopupMenu
    Left = 272
    Top = 550
  end
  inherited ibtrCommon: TIBTransaction
    Left = 312
    Top = 550
  end
  object odCmdLine: TOpenDialog
    Filter = 
      '����������� ����� *.exe|*.exe|�������� ����� *.bat|*.bat|��� ���' +
      '�� *.*|*.*'
    Title = '����� �����'
    Left = 360
    Top = 552
  end
end
