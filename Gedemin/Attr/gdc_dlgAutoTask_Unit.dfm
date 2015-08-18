inherited gdc_dlgAutoTask: Tgdc_dlgAutoTask
  Left = 648
  Top = 11
  Caption = 'gdc_dlgAutoTask'
  ClientHeight = 565
  ClientWidth = 440
  Font.Charset = DEFAULT_CHARSET
  OldCreateOrder = False
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object lbPriority: TLabel [0]
    Left = 8
    Top = 511
    Width = 371
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 
      '���������� ����� ���������� ��� �����, ����������� �� ���� �����' +
      ':'
  end
  object Label2: TLabel [1]
    Left = 9
    Top = 257
    Width = 419
    Height = 27
    Anchors = [akLeft, akRight, akBottom]
    AutoSize = False
    Caption = 
      '�������� ���� ������� ��� ���������� ��� ����� ������� ������� �' +
      '/��� �� ����� ����������. ��� �������� ���������� ����������� IP' +
      ' ����� ��� ���.'
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
    Top = 449
    Width = 64
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = '��������� �'
  end
  object lbEndTime: TLabel [3]
    Left = 143
    Top = 449
    Width = 13
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = '��'
  end
  object Label4: TLabel [4]
    Left = 79
    Top = 471
    Width = 313
    Height = 13
    Anchors = [akLeft, akBottom]
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
    Top = 213
    Width = 212
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = '��������� ������ ��� ������� �������:'
  end
  object Label8: TLabel [8]
    Left = 8
    Top = 237
    Width = 180
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = '��������� ������ �� ����������:'
  end
  object Label9: TLabel [9]
    Left = 8
    Top = 490
    Width = 354
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 
      '��������� ���������� ������                  ������ (0 -- �� ���' +
      '������)'
  end
  inherited btnAccess: TButton
    Left = 7
    Top = 536
    TabOrder = 17
  end
  inherited btnNew: TButton
    Left = 79
    Top = 536
    TabOrder = 18
  end
  inherited btnHelp: TButton
    Left = 151
    Top = 536
    TabOrder = 19
  end
  inherited btnOK: TButton
    Left = 290
    Top = 536
    TabOrder = 15
  end
  inherited btnCancel: TButton
    Left = 362
    Top = 536
    TabOrder = 16
  end
  object gbTimeTables: TGroupBox [15]
    Left = 6
    Top = 288
    Width = 425
    Height = 155
    Anchors = [akLeft, akRight, akBottom]
    Caption = ' ���������� '
    TabOrder = 9
    object Label3: TLabel
      Left = 26
      Top = 77
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
      Top = 93
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
      Top = 114
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
      Top = 34
      Width = 185
      Height = 21
      Caption = '���������� � ��������� ����:'
      TabOrder = 1
    end
    object xdbeExactDate: TxDateDBEdit
      Left = 200
      Top = 34
      Width = 65
      Height = 21
      DataField = 'exactdate'
      DataSource = dsgdcBase
      Kind = kDate
      EmptyAtStart = True
      EditMask = '!99\.99\.9999;1;_'
      MaxLength = 10
      TabOrder = 2
    end
    object rbMonthly: TRadioButton
      Left = 8
      Top = 55
      Width = 185
      Height = 21
      Caption = '���������� � ��������� ����:'
      TabOrder = 3
    end
    object rbWeekly: TRadioButton
      Left = 8
      Top = 111
      Width = 193
      Height = 21
      Caption = '����������� � ��������� ����:'
      TabOrder = 5
    end
    object dbcbWeekly: TDBComboBox
      Left = 200
      Top = 111
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
      TabOrder = 6
    end
    object rbDaily: TRadioButton
      Left = 8
      Top = 133
      Width = 89
      Height = 17
      Caption = '���������'
      TabOrder = 7
    end
    object dbcbMonthly: TDBComboBox
      Left = 200
      Top = 57
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
      TabOrder = 4
    end
    object rbAtStartup: TRadioButton
      Left = 8
      Top = 16
      Width = 201
      Height = 17
      Caption = '��� ������� �������'
      TabOrder = 0
    end
  end
  object dbcbPriority: TDBComboBox [16]
    Left = 384
    Top = 508
    Width = 48
    Height = 21
    Anchors = [akLeft, akBottom]
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
    TabOrder = 14
  end
  object xdbeStartTime: TxDateDBEdit [17]
    Left = 79
    Top = 447
    Width = 57
    Height = 21
    DataField = 'starttime'
    DataSource = dsgdcBase
    Kind = kTime
    EmptyAtStart = True
    Anchors = [akLeft, akBottom]
    EditMask = '!99\:99\:99;1;_'
    MaxLength = 8
    TabOrder = 10
  end
  object xdbeEndTime: TxDateDBEdit [18]
    Left = 162
    Top = 447
    Width = 57
    Height = 21
    DataField = 'endtime'
    DataSource = dsgdcBase
    Kind = kTime
    EmptyAtStart = True
    Anchors = [akLeft, akBottom]
    EditMask = '!99\:99\:99;1;_'
    MaxLength = 8
    TabOrder = 11
  end
  object btnClearTime: TButton [19]
    Left = 230
    Top = 446
    Width = 75
    Height = 21
    Anchors = [akLeft, akBottom]
    Caption = '��������'
    TabOrder = 12
    OnClick = btnClearTimeClick
  end
  object dbcbDisabled: TDBCheckBox [20]
    Left = 351
    Top = 35
    Width = 80
    Height = 17
    Anchors = [akTop, akRight]
    Caption = '���������'
    DataField = 'disabled'
    DataSource = dsgdcBase
    TabOrder = 3
    ValueChecked = '1'
    ValueUnchecked = '0'
  end
  object dbedName: TDBEdit [21]
    Left = 99
    Top = 10
    Width = 246
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    DataField = 'NAME'
    DataSource = dsgdcBase
    TabOrder = 0
  end
  object dbmDescription: TDBMemo [22]
    Left = 99
    Top = 35
    Width = 246
    Height = 33
    Anchors = [akLeft, akTop, akRight]
    DataField = 'Description'
    DataSource = dsgdcBase
    TabOrder = 1
  end
  object pcTask: TPageControl [23]
    Left = 8
    Top = 72
    Width = 421
    Height = 132
    ActivePage = tsFunction
    Anchors = [akLeft, akTop, akRight, akBottom]
    MultiLine = True
    TabOrder = 4
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
        Height = 23
        AutoSize = False
        Caption = '������� ��� ��������� (�������) � ��������� ��������� ������.'
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
      object Label7: TLabel
        Left = 9
        Top = 36
        Width = 397
        Height = 47
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        Caption = 
          '����������� �������������� [YYYY], [MM], [DD], [HH], [NN], [SS] ' +
          '��� ����������� � ��� ����� ������� �������� ����, ������, ���, ' +
          '����, ������ � ������, ��������������.'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlue
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        WordWrap = True
      end
      object dbeBackup: TDBEdit
        Left = 8
        Top = 8
        Width = 303
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        DataField = 'backupfile'
        DataSource = dsgdcBase
        TabOrder = 0
      end
      object btBackup: TButton
        Left = 312
        Top = 7
        Width = 94
        Height = 21
        Anchors = [akTop, akRight]
        Caption = '������������'
        TabOrder = 1
        OnClick = btBackupClick
      end
    end
    object tsReport: TTabSheet
      Caption = '�����'
      ImageIndex = 3
      object Label10: TLabel
        Left = 8
        Top = 10
        Width = 36
        Height = 13
        Caption = '�����:'
      end
      object Label11: TLabel
        Left = 8
        Top = 84
        Width = 113
        Height = 13
        Caption = '������� ������ SMTP:'
      end
      object Label12: TLabel
        Left = 296
        Top = 10
        Width = 42
        Height = 13
        Anchors = [akTop]
        Caption = '������:'
      end
      object Label13: TLabel
        Left = 8
        Top = 58
        Width = 97
        Height = 13
        Caption = '������ ���������:'
      end
      object Label15: TLabel
        Left = 8
        Top = 34
        Width = 29
        Height = 13
        Caption = '����:'
      end
      object iblkupReport: TgsIBLookupComboBox
        Left = 125
        Top = 8
        Width = 164
        Height = 21
        HelpContext = 1
        DataSource = dsgdcBase
        DataField = 'REPORTKEY'
        ListTable = 'RP_REPORTLIST'
        ListField = 'NAME'
        KeyField = 'ID'
        Anchors = [akLeft, akTop, akRight]
        ItemHeight = 13
        TabOrder = 0
      end
      object dbcbExportType: TDBComboBox
        Left = 344
        Top = 8
        Width = 64
        Height = 21
        Anchors = [akTop, akRight]
        DataField = 'EMAILEXPORTTYPE'
        DataSource = dsgdcBase
        ItemHeight = 13
        Items.Strings = (
          'DOC'
          'XLS'
          'PDF'
          'XML'
          'TXT'
          'HTM'
          'ODT'
          'ODS')
        TabOrder = 1
      end
      object iblkupSMTP: TgsIBLookupComboBox
        Left = 125
        Top = 80
        Width = 283
        Height = 21
        HelpContext = 1
        DataSource = dsgdcBase
        DataField = 'EMAILSMTPKEY'
        ListTable = 'GD_SMTP'
        ListField = 'NAME'
        KeyField = 'ID'
        gdClassName = 'TgdcSMTP'
        Anchors = [akLeft, akTop, akRight]
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 4
      end
      object iblkupGroup: TgsIBLookupComboBox
        Left = 125
        Top = 56
        Width = 283
        Height = 21
        HelpContext = 1
        DataSource = dsgdcBase
        DataField = 'EMAILGROUPKEY'
        ListTable = 'GD_CONTACT'
        ListField = 'NAME'
        KeyField = 'ID'
        Condition = 'GD_CONTACT.CONTACTTYPE  =  1'
        gdClassName = 'TgdcGroup'
        Anchors = [akLeft, akTop, akRight]
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 3
      end
      object dbeRecipients: TDBEdit
        Left = 125
        Top = 32
        Width = 283
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        DataField = 'emailrecipients'
        DataSource = dsgdcBase
        TabOrder = 2
      end
    end
  end
  object iblkupUser: TgsIBLookupComboBox [24]
    Left = 222
    Top = 210
    Width = 208
    Height = 21
    HelpContext = 1
    DataSource = dsgdcBase
    DataField = 'USERKEY'
    ListTable = 'GD_USER'
    ListField = 'NAME'
    KeyField = 'ID'
    gdClassName = 'TgdcUser'
    Anchors = [akLeft, akRight, akBottom]
    ItemHeight = 13
    ParentShowHint = False
    ShowHint = True
    TabOrder = 5
  end
  object btExecTask: TButton [25]
    Left = 352
    Top = 9
    Width = 75
    Height = 21
    Action = actExecTask
    Anchors = [akTop, akRight]
    TabOrder = 2
  end
  object dbedComputer: TDBEdit [26]
    Left = 222
    Top = 235
    Width = 136
    Height = 21
    Anchors = [akLeft, akRight, akBottom]
    DataField = 'COMPUTER'
    DataSource = dsgdcBase
    TabOrder = 6
  end
  object btnIP: TButton [27]
    Left = 358
    Top = 235
    Width = 35
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = 'IP'
    TabOrder = 7
    OnClick = btnIPClick
  end
  object btnCN: TButton [28]
    Left = 393
    Top = 235
    Width = 35
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '���'
    TabOrder = 8
    OnClick = btnCNClick
  end
  object dbedPulse: TDBEdit [29]
    Left = 177
    Top = 487
    Width = 43
    Height = 21
    Anchors = [akLeft, akBottom]
    DataField = 'PULSE'
    DataSource = dsgdcBase
    TabOrder = 13
  end
  inherited alBase: TActionList
    Left = 46
    Top = 52
    object actExecTask: TAction
      Caption = '���������'
      OnExecute = actExecTaskExecute
      OnUpdate = actExecTaskUpdate
    end
  end
  inherited dsgdcBase: TDataSource
    Left = 8
    Top = 52
  end
  inherited pm_dlgG: TPopupMenu
    Left = 352
    Top = 53
  end
  inherited ibtrCommon: TIBTransaction
    Left = 384
    Top = 53
  end
  object odCmdLine: TOpenDialog
    Filter = 
      '����������� ����� *.exe|*.exe|�������� ����� *.bat|*.bat|��� ���' +
      '�� *.*|*.*'
    Title = '����� �����'
    Left = 416
    Top = 49
  end
end
