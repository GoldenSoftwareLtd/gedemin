inherited gdc_dlgAutoTask: Tgdc_dlgAutoTask
  Left = 517
  Top = 109
  Caption = 'gdc_dlgAutoTask'
  ClientHeight = 547
  ClientWidth = 440
  Font.Charset = DEFAULT_CHARSET
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object lbPriority: TLabel [0]
    Left = 8
    Top = 493
    Width = 371
    Height = 13
    Caption = 
      '���������� ����� ���������� ��� �����, ����������� �� ���� �����' +
      ':'
  end
  object Label2: TLabel [1]
    Left = 223
    Top = 258
    Width = 205
    Height = 28
    AutoSize = False
    Caption = '�������� ���� ������ ��� ���������� ��� ����� ������� �������.'
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    WordWrap = True
  end
  object lbStartTime: TLabel [2]
    Left = 9
    Top = 450
    Width = 64
    Height = 13
    Caption = '��������� �'
  end
  object lbEndTime: TLabel [3]
    Left = 143
    Top = 450
    Width = 13
    Height = 13
    Caption = '��'
  end
  object Label4: TLabel [4]
    Left = 79
    Top = 472
    Width = 313
    Height = 13
    Caption = '�������� ���� ������� ��� ���������� � ����� ����� ���.'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object lbName: TLabel [5]
    Left = 8
    Top = 13
    Width = 77
    Height = 13
    Caption = '������������:'
  end
  object lbDescription: TLabel [6]
    Left = 8
    Top = 35
    Width = 53
    Height = 13
    Caption = '��������:'
  end
  object lbUser: TLabel [7]
    Left = 8
    Top = 237
    Width = 212
    Height = 13
    Caption = '��������� ������ ��� ������� �������:'
  end
  inherited btnAccess: TButton
    Left = 7
    Top = 518
    TabOrder = 12
  end
  inherited btnNew: TButton
    Left = 79
    Top = 518
    TabOrder = 13
  end
  inherited btnHelp: TButton
    Left = 151
    Top = 518
    TabOrder = 14
  end
  inherited btnOK: TButton
    Left = 290
    Top = 518
    TabOrder = 10
  end
  inherited btnCancel: TButton
    Left = 362
    Top = 518
    TabOrder = 11
  end
  object gbTimeTables: TGroupBox [13]
    Left = 6
    Top = 288
    Width = 425
    Height = 150
    Caption = ' ���������� '
    TabOrder = 5
    object Label3: TLabel
      Left = 26
      Top = 67
      Width = 324
      Height = 13
      Caption = '������������� �������� ������ ������ ���� � ����� ������.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Label5: TLabel
      Left = 27
      Top = 83
      Width = 249
      Height = 13
      Caption = '-1 -- ��������� ����, -2 -- ������������� � �.�.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Label6: TLabel
      Left = 273
      Top = 107
      Width = 124
      Height = 13
      Caption = '1 -- ��, 2 -- ��, ... 7 -- ��'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object rbExactDate: TRadioButton
      Left = 8
      Top = 18
      Width = 185
      Height = 21
      Caption = '���������� � ��������� ����:'
      TabOrder = 0
    end
    object xdbeExactDate: TxDateDBEdit
      Left = 200
      Top = 18
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
      Top = 41
      Width = 185
      Height = 21
      Caption = '���������� � ��������� ����:'
      TabOrder = 2
    end
    object rbWeekly: TRadioButton
      Left = 8
      Top = 104
      Width = 193
      Height = 21
      Caption = '����������� � ��������� ����:'
      TabOrder = 4
    end
    object dbcbWeekly: TDBComboBox
      Left = 200
      Top = 104
      Width = 65
      Height = 21
      Style = csDropDownList
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
      TabOrder = 5
    end
    object rbDaily: TRadioButton
      Left = 8
      Top = 128
      Width = 89
      Height = 17
      Caption = '���������'
      TabOrder = 6
    end
    object dbcbMonthly: TDBComboBox
      Left = 200
      Top = 43
      Width = 65
      Height = 21
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
      TabOrder = 3
    end
  end
  object dbcbPriority: TDBComboBox [14]
    Left = 384
    Top = 490
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
    TabOrder = 9
  end
  object xdbeStartTime: TxDateDBEdit [15]
    Left = 79
    Top = 448
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
  object xdbeEndTime: TxDateDBEdit [16]
    Left = 162
    Top = 448
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
  object btnClearTime: TButton [17]
    Left = 230
    Top = 447
    Width = 75
    Height = 21
    Caption = '��������'
    TabOrder = 8
    OnClick = btnClearTimeClick
  end
  object dbcbDisabled: TDBCheckBox [18]
    Left = 351
    Top = 35
    Width = 80
    Height = 17
    Caption = '���������'
    DataField = 'disabled'
    DataSource = dsgdcBase
    TabOrder = 2
    ValueChecked = '1'
    ValueUnchecked = '0'
  end
  object dbedName: TDBEdit [19]
    Left = 99
    Top = 10
    Width = 330
    Height = 21
    Anchors = []
    DataField = 'NAME'
    DataSource = dsgdcBase
    TabOrder = 0
  end
  object dbmDescription: TDBMemo [20]
    Left = 99
    Top = 35
    Width = 246
    Height = 49
    Anchors = []
    DataField = 'Description'
    DataSource = dsgdcBase
    TabOrder = 1
  end
  object pcTask: TPageControl [21]
    Left = 8
    Top = 92
    Width = 421
    Height = 135
    ActivePage = tsBackup
    Anchors = []
    MultiLine = True
    TabOrder = 3
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
        ItemHeight = 0
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
        Caption = '������� ��� ���������  (�������) � ��������� ��������� ������.'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlue
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
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
    object tsBackup: TTabSheet
      Caption = '�������������'
      ImageIndex = 2
      object dbeBackup: TDBEdit
        Left = 8
        Top = 8
        Width = 373
        Height = 21
        DataField = 'backupfile'
        DataSource = dsgdcBase
        TabOrder = 0
      end
      object btBackup: TButton
        Left = 381
        Top = 7
        Width = 25
        Height = 21
        Caption = '...'
        TabOrder = 1
        OnClick = btBackupClick
      end
    end
  end
  object iblkupUser: TgsIBLookupComboBox [22]
    Left = 222
    Top = 234
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
    TabOrder = 4
  end
  inherited alBase: TActionList
    Left = 238
    Top = 532
  end
  inherited dsgdcBase: TDataSource
    Left = 200
    Top = 532
  end
  inherited pm_dlgG: TPopupMenu
    Left = 272
    Top = 533
  end
  inherited ibtrCommon: TIBTransaction
    Left = 312
    Top = 533
  end
  object odCmdLine: TOpenDialog
    Filter = 
      '����������� ����� *.exe|*.exe|�������� ����� *.bat|*.bat|��� ���' +
      '�� *.*|*.*'
    Title = '����� �����'
    Left = 360
    Top = 545
  end
end
