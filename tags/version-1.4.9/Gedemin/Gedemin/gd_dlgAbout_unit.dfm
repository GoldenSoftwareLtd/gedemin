object gd_dlgAbout: Tgd_dlgAbout
  Left = 433
  Top = 244
  HelpContext = 119
  BorderStyle = bsDialog
  Caption = '� ���������'
  ClientHeight = 353
  ClientWidth = 487
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 8
    Top = 8
    Width = 472
    Height = 313
    ActivePage = TabSheet1
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = '� ���������'
      object Label30: TLabel
        Left = 6
        Top = 2
        Width = 299
        Height = 21
        Caption = '��������� �������, v.2.5 beta 1'
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -17
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Memo1: TMemo
        Left = 5
        Top = 30
        Width = 452
        Height = 247
        TabStop = False
        BorderStyle = bsNone
        Color = clBtnFace
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -8
        Font.Name = 'Tahoma'
        Font.Style = []
        Lines.Strings = (
          
            'Copyright (c) 1994-2009 by Golden Software of Belarus, Ltd. All ' +
            'rights reserved.'
          ''
          'http://gsbelarus.com, email: support@gsbelarus.com'
          '���/����: +375-17-2921333, 3313546.'
          ''
          '�������� Golden Software, Ltd:'
          
            '������ ������, ������ ������, ����� �����������, ����� �������, ' +
            '������ ���, ������ ��������,'
          
            '�������� �����, ������ ������������, ������ �������, ��������� �' +
            '�����, ������ ��������,'
          
            '�������� �������, ��������� ���������, �������� �������, ������ ' +
            '��������, ������ ��������,'
          
            '���� ���������, ��������� ��������, ����� �������, ��������� ���' +
            '����, ������� ���,'
          
            '������� ����������, ���� �������, ������� ������, ������ �������' +
            '��, ������ ����������,'
          
            '���� ��������, ����� ������, ������� ���������, ������� �������,' +
            ' ���� ������, ��������� �������,'
          
            '������ ������, ����� �������, ���� ��������, ��������� ���������' +
            ', ��������� ������,'
          
            '���� ����������, ������ ����������, ������� ������, ����� �����,' +
            ' ������ �������, ������� ��������,'
          
            '������ ������, ������ �������, ������ ��������, ������ ����, ���' +
            '������ �������, ��������� �����,'
          
            '���������� ���������, ���� ������, ���� �������, ��������� �����' +
            '���, ������� �������,'
          
            '������� ���������, ����� �����, ����� �����, ������� ���������, ' +
            '��������� ������, ������� ��������,'
          
            '��������� �������, �������� ������, ���� �����������, �������� �' +
            '��������, ����� ��������,'
          
            '����� ���������, ���� �������, ������ ���������, �������� ������' +
            '�, ������ ��������,'
          '������ ���������.'
          ''
          '��������� �������:'
          
            '��� ��������, �������� ��������, Stefan Boether, ������ "������"' +
            ' ���������.'
          ' '
          ' '
          ' '
          ' '
          ' ')
        ParentFont = False
        ReadOnly = True
        TabOrder = 0
      end
      object btnMSInfo: TButton
        Left = 380
        Top = 256
        Width = 75
        Height = 21
        Caption = '� �������...'
        TabOrder = 1
        OnClick = btnMSInfoClick
      end
    end
    object TabSheet2: TTabSheet
      Caption = '�����'
      ImageIndex = 1
      object gbGDS32: TGroupBox
        Left = 8
        Top = 8
        Width = 446
        Height = 65
        Caption = ' ���������� GDS32 '
        TabOrder = 0
        object Label2: TLabel
          Left = 11
          Top = 17
          Width = 77
          Height = 13
          Caption = '������������:'
        end
        object lGDS32FileName: TLabel
          Left = 136
          Top = 17
          Width = 77
          Height = 13
          Caption = 'lGDS32FileName'
        end
        object lGDS32Version: TLabel
          Left = 136
          Top = 31
          Width = 69
          Height = 13
          Caption = 'lGDS32Version'
        end
        object lGDS32FileDescription: TLabel
          Left = 136
          Top = 45
          Width = 87
          Height = 13
          Caption = 'lGDS32Description'
        end
        object Label3: TLabel
          Left = 11
          Top = 31
          Width = 39
          Height = 13
          Caption = '������:'
        end
        object Label4: TLabel
          Left = 11
          Top = 45
          Width = 88
          Height = 13
          Caption = '�������� �����:'
        end
      end
      object GroupBox2: TGroupBox
        Left = 8
        Top = 74
        Width = 446
        Height = 144
        Caption = ' ������ '
        TabOrder = 1
        object lServerVersion: TLabel
          Left = 136
          Top = 15
          Width = 69
          Height = 13
          Caption = 'lServerVersion'
        end
        object lDBSiteName: TLabel
          Left = 136
          Top = 46
          Width = 60
          Height = 13
          Caption = 'lDBSiteName'
        end
        object lODSVersion: TLabel
          Left = 136
          Top = 61
          Width = 58
          Height = 13
          Caption = 'lODSVersion'
        end
        object lPageSize: TLabel
          Left = 136
          Top = 77
          Width = 45
          Height = 13
          Caption = 'lPageSize'
        end
        object lForcedWrites: TLabel
          Left = 136
          Top = 92
          Width = 66
          Height = 13
          Caption = 'lForcedWrites'
        end
        object lNumBuffers: TLabel
          Left = 136
          Top = 108
          Width = 58
          Height = 13
          Caption = 'lNumBuffers'
        end
        object lCurrentMemory: TLabel
          Left = 136
          Top = 123
          Width = 77
          Height = 13
          Caption = 'lCurrentMemory'
        end
        object Label1: TLabel
          Left = 11
          Top = 15
          Width = 83
          Height = 13
          Caption = '������ �������:'
        end
        object Label5: TLabel
          Left = 11
          Top = 30
          Width = 75
          Height = 13
          Caption = '��� ����� ��:'
        end
        object Label6: TLabel
          Left = 11
          Top = 46
          Width = 89
          Height = 13
          Caption = '��� ����������:'
        end
        object Label7: TLabel
          Left = 11
          Top = 61
          Width = 63
          Height = 13
          Caption = 'ODS ������:'
        end
        object Label8: TLabel
          Left = 11
          Top = 77
          Width = 91
          Height = 13
          Caption = '������ ��������:'
        end
        object Label9: TLabel
          Left = 11
          Top = 92
          Width = 114
          Height = 13
          Caption = '�������������� ���.:'
        end
        object Label10: TLabel
          Left = 11
          Top = 108
          Width = 111
          Height = 13
          Caption = '���������� �������:'
        end
        object Label11: TLabel
          Left = 11
          Top = 123
          Width = 114
          Height = 13
          Caption = '������������ ������:'
        end
        object eDBFileName: TEdit
          Left = 136
          Top = 30
          Width = 305
          Height = 15
          BorderStyle = bsNone
          Ctl3D = False
          ParentColor = True
          ParentCtl3D = False
          ReadOnly = True
          TabOrder = 0
          Text = 'eDBFileName'
        end
      end
      object GroupBox3: TGroupBox
        Left = 8
        Top = 219
        Width = 446
        Height = 62
        Caption = ' ������� '
        TabOrder = 2
        object lGedeminFile: TLabel
          Left = 136
          Top = 16
          Width = 59
          Height = 13
          Caption = 'lGedeminFile'
        end
        object lGedeminPath: TLabel
          Left = 136
          Top = 30
          Width = 65
          Height = 13
          Caption = 'lGedeminPath'
        end
        object lGedeminVersion: TLabel
          Left = 136
          Top = 44
          Width = 78
          Height = 13
          Caption = 'lGedeminVersion'
        end
        object Label12: TLabel
          Left = 11
          Top = 16
          Width = 58
          Height = 13
          Caption = '��� �����:'
        end
        object Label13: TLabel
          Left = 11
          Top = 30
          Width = 77
          Height = 13
          Caption = '������������:'
        end
        object Label14: TLabel
          Left = 11
          Top = 44
          Width = 74
          Height = 13
          Caption = '������ �����:'
        end
      end
    end
    object TabSheet3: TTabSheet
      Caption = '���������� �����'
      ImageIndex = 2
      object GroupBox4: TGroupBox
        Left = 8
        Top = 8
        Width = 446
        Height = 273
        Caption = ' ���������� ����� '
        TabOrder = 0
        object lISC_USER: TLabel
          Left = 114
          Top = 16
          Width = 51
          Height = 13
          Caption = 'lISC_USER'
        end
        object lISC_PASSWORD: TLabel
          Left = 114
          Top = 32
          Width = 82
          Height = 13
          Caption = 'lISC_PASSWORD'
        end
        object lISC_PATH: TLabel
          Left = 114
          Top = 48
          Width = 51
          Height = 13
          Caption = 'lISC_PATH'
        end
        object lTemp: TLabel
          Left = 114
          Top = 64
          Width = 28
          Height = 13
          Caption = 'lTemp'
        end
        object lTmp: TLabel
          Left = 114
          Top = 80
          Width = 22
          Height = 13
          Caption = 'lTmp'
        end
        object Label15: TLabel
          Left = 10
          Top = 16
          Width = 53
          Height = 13
          Caption = 'ISC_USER:'
        end
        object Label16: TLabel
          Left = 10
          Top = 32
          Width = 84
          Height = 13
          Caption = 'ISC_PASSWORD:'
        end
        object Label17: TLabel
          Left = 10
          Top = 48
          Width = 53
          Height = 13
          Caption = 'ISC_PATH:'
        end
        object Label18: TLabel
          Left = 10
          Top = 64
          Width = 30
          Height = 13
          Caption = 'TEMP:'
        end
        object Label19: TLabel
          Left = 10
          Top = 80
          Width = 24
          Height = 13
          Caption = 'TMP:'
        end
        object Label20: TLabel
          Left = 10
          Top = 96
          Width = 30
          Height = 13
          Caption = 'PATH:'
        end
        object mPath: TMemo
          Left = 111
          Top = 96
          Width = 322
          Height = 169
          TabStop = False
          BorderStyle = bsNone
          Color = clBtnFace
          Lines.Strings = (
            'mPath')
          ReadOnly = True
          TabOrder = 0
        end
      end
    end
    object tsLogin: TTabSheet
      Caption = '�����������'
      ImageIndex = 3
      object GroupBox6: TGroupBox
        Left = 8
        Top = 8
        Width = 446
        Height = 129
        Caption = ' ������������ '
        TabOrder = 0
        object Label25: TLabel
          Left = 11
          Top = 61
          Width = 101
          Height = 13
          Caption = '�� ������� ������:'
        end
        object Label26: TLabel
          Left = 11
          Top = 46
          Width = 92
          Height = 13
          Caption = '������������ ��:'
        end
        object Label27: TLabel
          Left = 11
          Top = 30
          Width = 47
          Height = 13
          Caption = '�������:'
        end
        object Label28: TLabel
          Left = 11
          Top = 15
          Width = 84
          Height = 13
          Caption = '������� ������:'
        end
        object lUser: TLabel
          Left = 136
          Top = 15
          Width = 2
          Height = 13
          Caption = 'l'
        end
        object lContact: TLabel
          Left = 136
          Top = 30
          Width = 2
          Height = 13
          Caption = 'l'
        end
        object lIBUser: TLabel
          Left = 136
          Top = 46
          Width = 2
          Height = 13
          Caption = 'l'
        end
        object lUserKey: TLabel
          Left = 136
          Top = 61
          Width = 2
          Height = 13
          Caption = 'l'
        end
        object Label33: TLabel
          Left = 11
          Top = 77
          Width = 70
          Height = 13
          Caption = '�� ��������:'
        end
        object lContactKey: TLabel
          Left = 136
          Top = 77
          Width = 2
          Height = 13
          Caption = 'l'
        end
        object Label29: TLabel
          Left = 11
          Top = 93
          Width = 39
          Height = 13
          Caption = '������:'
        end
        object lSession: TLabel
          Left = 136
          Top = 93
          Width = 2
          Height = 13
          Caption = 'l'
        end
        object Label31: TLabel
          Left = 11
          Top = 109
          Width = 110
          Height = 13
          Caption = '���� � ����� �����.:'
        end
        object lDateAndTime: TLabel
          Left = 136
          Top = 109
          Width = 2
          Height = 13
          Caption = 'l'
        end
      end
      object GroupBox7: TGroupBox
        Left = 8
        Top = 141
        Width = 446
        Height = 41
        Caption = ' ��������� ������ '
        TabOrder = 1
        object Label34: TEdit
          Left = 8
          Top = 14
          Width = 433
          Height = 21
          BorderStyle = bsNone
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 0
        end
      end
    end
    object tsDB: TTabSheet
      Caption = '���� ������'
      ImageIndex = 4
      object GroupBox5: TGroupBox
        Left = 8
        Top = 1
        Width = 446
        Height = 81
        Caption = ' ���� ���� ������ '
        TabOrder = 0
        object Label21: TLabel
          Left = 11
          Top = 15
          Width = 91
          Height = 13
          Caption = '������ ����� ��:'
        end
        object Label22: TLabel
          Left = 11
          Top = 30
          Width = 71
          Height = 13
          Caption = '�� ����� ��:'
        end
        object Label23: TLabel
          Left = 11
          Top = 46
          Width = 85
          Height = 13
          Caption = '���� ������ ��:'
        end
        object Label24: TLabel
          Left = 11
          Top = 61
          Width = 71
          Height = 13
          Caption = '�����������:'
        end
        object lDBComment: TLabel
          Left = 136
          Top = 61
          Width = 2
          Height = 13
          Caption = 'l'
        end
        object lDBRelease: TLabel
          Left = 136
          Top = 46
          Width = 2
          Height = 13
          Caption = 'l'
        end
        object lDBID: TLabel
          Left = 136
          Top = 30
          Width = 2
          Height = 13
          Caption = 'l'
        end
        object lDBVersion: TLabel
          Left = 136
          Top = 15
          Width = 2
          Height = 13
          Caption = 'l'
        end
      end
      object GroupBox8: TGroupBox
        Left = 8
        Top = 82
        Width = 446
        Height = 79
        Caption = ' ��������� �����������  '
        TabOrder = 1
        object mDBParams: TMemo
          Left = 9
          Top = 15
          Width = 427
          Height = 55
          TabStop = False
          ReadOnly = True
          TabOrder = 0
        end
      end
      object gbTrace: TGroupBox
        Left = 8
        Top = 161
        Width = 446
        Height = 59
        Caption = ' ��������� ����������� ����������� � �� '
        TabOrder = 2
        object mTrace: TMemo
          Left = 9
          Top = 16
          Width = 427
          Height = 35
          TabStop = False
          ReadOnly = True
          TabOrder = 0
        end
      end
      object GroupBox9: TGroupBox
        Left = 8
        Top = 221
        Width = 446
        Height = 60
        Caption = ' ��������� ����������� SQL �������� '
        TabOrder = 3
        object mSQLMonitor: TMemo
          Left = 9
          Top = 16
          Width = 427
          Height = 35
          TabStop = False
          ReadOnly = True
          TabOrder = 0
        end
      end
    end
    object tsTempFiles: TTabSheet
      Caption = '����. �����'
      ImageIndex = 5
      object lblTempPath: TLabel
        Left = 9
        Top = 8
        Width = 35
        Height = 13
        Caption = '�����:'
      end
      object lvTempFiles: TListView
        Left = 7
        Top = 32
        Width = 449
        Height = 113
        Columns = <
          item
            Caption = '���'
            Width = 280
          end
          item
            Alignment = taRightJustify
            AutoSize = True
            Caption = '������, ����'
          end>
        GridLines = True
        ReadOnly = True
        RowSelect = True
        TabOrder = 0
        ViewStyle = vsReport
      end
      object edTempPath: TEdit
        Left = 48
        Top = 4
        Width = 408
        Height = 21
        Color = clBtnFace
        ReadOnly = True
        TabOrder = 2
        Text = 'edTempPath'
      end
      object mTempFiles: TMemo
        Left = 7
        Top = 152
        Width = 449
        Height = 124
        Color = clBtnFace
        Lines.Strings = (
          
            '��������� ����� ������������ ��� ����������� ���������� �� ���� ' +
            '������ �'
          '��������� ������� ���������.'
          ''
          
            '��� �������� ��������� ������ �������: �������� �������, �������' +
            '�� �'
          '��������� �����, ������� ����� �� ������.'
          ''
          
            '��������� �������� ��������� ������ ����� � ������� ��������� ��' +
            '�������'
          '������ /nc.'
          ' '
          ' '
          ' ')
        ReadOnly = True
        TabOrder = 1
      end
    end
  end
  object btnOk: TButton
    Left = 405
    Top = 328
    Width = 75
    Height = 21
    Caption = 'Ok'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnHelp: TButton
    Left = 8
    Top = 328
    Width = 75
    Height = 21
    Caption = '�������'
    TabOrder = 2
    OnClick = btnHelpClick
  end
  object IBDatabaseInfo1: TIBDatabaseInfo
    Left = 328
    Top = 56
  end
end
