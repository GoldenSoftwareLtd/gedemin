object gd_dlgInitialInfo: Tgd_dlgInitialInfo
  Left = 411
  Top = 203
  BorderStyle = bsDialog
  Caption = '��������� ����������'
  ClientHeight = 486
  ClientWidth = 713
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label32: TLabel
    Left = 363
    Top = 360
    Width = 340
    Height = 33
    AutoSize = False
    Caption = 
      '��������� ������ ����� ����� ��������� ��� ��������� � �������� ' +
      '������ � ����������.'
    WordWrap = True
  end
  object Label33: TLabel
    Left = 363
    Top = 397
    Width = 340
    Height = 49
    AutoSize = False
    Caption = 
      '�� ��������� ������ ������ �� ������������ ����������� ���������' +
      ' ������������ ���� � ������� �� ����� �� ������� �������� � ����' +
      '���� �����.'
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
  object btnOk: TButton
    Left = 549
    Top = 456
    Width = 75
    Height = 21
    Action = actOk
    Default = True
    TabOrder = 4
  end
  object gbCompany: TGroupBox
    Left = 8
    Top = 56
    Width = 345
    Height = 291
    Caption = ' �������� �� ����������� '
    TabOrder = 1
    object Label1: TLabel
      Left = 12
      Top = 26
      Width = 77
      Height = 13
      Caption = '������������:'
    end
    object Label2: TLabel
      Left = 12
      Top = 50
      Width = 48
      Height = 13
      Caption = '�������:'
    end
    object Label3: TLabel
      Left = 12
      Top = 98
      Width = 57
      Height = 13
      Caption = '��� (���):'
    end
    object Label4: TLabel
      Left = 196
      Top = 99
      Width = 41
      Height = 13
      Caption = '������:'
    end
    object Label5: TLabel
      Left = 12
      Top = 122
      Width = 41
      Height = 13
      Caption = '������:'
    end
    object Label6: TLabel
      Left = 12
      Top = 147
      Width = 47
      Height = 13
      Caption = '�������:'
    end
    object Label7: TLabel
      Left = 12
      Top = 195
      Width = 59
      Height = 13
      Caption = '���. �����:'
    end
    object Label8: TLabel
      Left = 12
      Top = 219
      Width = 35
      Height = 13
      Caption = '�����:'
    end
    object Label9: TLabel
      Left = 12
      Top = 243
      Width = 54
      Height = 13
      Caption = '��������:'
    end
    object Label10: TLabel
      Left = 12
      Top = 267
      Width = 76
      Height = 13
      Caption = '��. ���������:'
    end
    object Label25: TLabel
      Left = 12
      Top = 171
      Width = 34
      Height = 13
      Caption = '�����:'
    end
    object Label29: TLabel
      Left = 12
      Top = 74
      Width = 52
      Height = 13
      Caption = '��������:'
    end
    object edName: TEdit
      Left = 96
      Top = 24
      Width = 241
      Height = 21
      Color = 10526975
      TabOrder = 0
    end
    object edPhone: TEdit
      Left = 96
      Top = 48
      Width = 241
      Height = 21
      TabOrder = 1
    end
    object edTaxID: TEdit
      Left = 96
      Top = 96
      Width = 89
      Height = 21
      TabOrder = 3
    end
    object cbCountry: TComboBox
      Left = 96
      Top = 120
      Width = 241
      Height = 21
      Style = csDropDownList
      DropDownCount = 16
      ItemHeight = 13
      Sorted = True
      TabOrder = 5
      Items.Strings = (
        '���������'
        '�������'
        '�����������'
        '�������'
        '�����'
        '������� (��������)'
        '������'
        '�������'
        '������� � �������'
        '���������'
        '�������'
        '�����'
        '����������'
        '��������� �������'
        '���������'
        '��������'
        '�������'
        '��������'
        '�����'
        '�������'
        '�����'
        '���������� �������'
        '��������'
        '�������'
        '������ � �����������'
        '��������'
        '��������'
        '���������� ���������� �������'
        '������'
        '�������-����'
        '�������'
        '�����'
        '�������'
        '�������'
        '��������������'
        '�������'
        '���������'
        '���������� �������'
        '��������� (������������) �����'
        '��������� �����'
        '�������'
        '�����'
        '������'
        '�����'
        '������'
        '����'
        '���������'
        '���������'
        '������'
        '������-�����'
        '��������'
        '���������'
        '��������'
        '�������'
        '����������'
        '������'
        '������'
        '����'
        '�����'
        '��������������� ���������� �����'
        '�������'
        '��������'
        '������������� ����������'
        '������'
        '������'
        '�������� ������'
        '�������� �����'
        '��������'
        '�����'
        '�������'
        '�����'
        '���������'
        '��������'
        '����'
        '����'
        '��������'
        '��������'
        '�������'
        '������'
        '����-�����'
        '���������'
        '��������� �������'
        '��������'
        '�������'
        '������'
        '�����'
        '�����'
        '����'
        '��������'
        '��������'
        '�����'
        '����'
        '��������� �������'
        '��������'
        '��������� �������'
        '�����-����'
        '���-�'#39'�����'
        '����'
        '������'
        '���� �������'
        '����'
        '������'
        '������'
        '�������'
        '�����'
        '�����'
        '�����'
        '�����������'
        '����������'
        '��������'
        '����������'
        '����������'
        '����� (������)'
        '���������'
        '������'
        '��������'
        '����'
        '��������'
        '������'
        '�������'
        '���������'
        '��������� �������'
        '�������'
        '������'
        '����������'
        '��������'
        '��������'
        '������'
        '��������'
        '����������'
        '������ (�����)'
        '�������'
        '�������� ���������� �����'
        '�����'
        '�����'
        '�����'
        '�������'
        '������������� �������'
        '����������'
        '���������'
        '����'
        '����� ��������'
        '����� ���������'
        '��������'
        '�������'
        '���'
        '����'
        '��������'
        '�����'
        '���������'
        '������'
        '�����-����� ������'
        '��������'
        '����'
        '�������'
        '������'
        '����������'
        '������-����'
        '�������'
        '��������� ������'
        '������'
        '������'
        '�������'
        '���������'
        '���-������'
        '���-���� � ��������'
        '���������� ������'
        '���������'
        '������ ����� ������'
        '�������� ���������� �������'
        '����������� �������'
        '�������'
        '���-���� � �������'
        '����-������� � ���������'
        '����-���� � �����'
        '����-�����'
        '������ � ����������'
        '��������'
        '�����'
        '��������'
        '��������'
        '������'
        '�����'
        '�������'
        '���'
        '������-�����'
        '�����������'
        '�������'
        '��������'
        'Ҹ��� � ������'
        '����'
        '�������'
        '�����'
        '�������� � ������'
        '������'
        '�����'
        '������������'
        '������'
        '������'
        '����������'
        '�������'
        '������ � ������'
        '�������'
        '����'
        '��������� �������'
        '�����'
        '���������'
        '���������'
        '������������ (�����������) �������'
        '�������'
        '����������� ���������'
        '��������'
        '����������-����������� ����������'
        '���'
        '����������'
        '�����'
        '����'
        '���������'
        '������'
        '���-�����'
        '�������'
        '�������������� ������'
        '�������'
        '�������'
        '�������'
        '����� �����'
        '����-����������� ����������'
        '������'
        '������')
    end
    object edZIP: TEdit
      Left = 248
      Top = 96
      Width = 89
      Height = 21
      TabOrder = 4
    end
    object edArea: TEdit
      Left = 96
      Top = 144
      Width = 241
      Height = 21
      TabOrder = 6
    end
    object edCity: TEdit
      Left = 96
      Top = 192
      Width = 241
      Height = 21
      TabOrder = 8
    end
    object edAddress: TEdit
      Left = 96
      Top = 216
      Width = 241
      Height = 21
      TabOrder = 9
    end
    object edDirector: TEdit
      Left = 96
      Top = 239
      Width = 241
      Height = 21
      Hint = '������� ��� ��������'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 10
    end
    object edAccountant: TEdit
      Left = 96
      Top = 263
      Width = 241
      Height = 21
      Hint = '������� ��� ��������'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 11
    end
    object edDistrict: TEdit
      Left = 96
      Top = 168
      Width = 241
      Height = 21
      TabOrder = 7
    end
    object edLicence: TEdit
      Left = 96
      Top = 72
      Width = 241
      Height = 21
      TabOrder = 2
    end
  end
  object gbBank: TGroupBox
    Left = 361
    Top = 56
    Width = 345
    Height = 291
    Caption = ' ���������� ��������� '
    TabOrder = 3
    object Label13: TLabel
      Left = 12
      Top = 26
      Width = 28
      Height = 13
      Caption = '����:'
    end
    object Label14: TLabel
      Left = 12
      Top = 242
      Width = 37
      Height = 13
      Caption = '�/����:'
    end
    object Label15: TLabel
      Left = 12
      Top = 52
      Width = 57
      Height = 13
      Caption = '��� �����:'
    end
    object Label16: TLabel
      Left = 12
      Top = 124
      Width = 41
      Height = 13
      Caption = '������:'
    end
    object Label17: TLabel
      Left = 12
      Top = 148
      Width = 47
      Height = 13
      Caption = '�������:'
    end
    object Label18: TLabel
      Left = 12
      Top = 196
      Width = 59
      Height = 13
      Caption = '���. �����:'
    end
    object Label19: TLabel
      Left = 12
      Top = 220
      Width = 35
      Height = 13
      Caption = '�����:'
    end
    object Label21: TLabel
      Left = 12
      Top = 266
      Width = 43
      Height = 13
      Caption = '������:'
    end
    object Label24: TLabel
      Left = 12
      Top = 100
      Width = 41
      Height = 13
      Caption = '������:'
    end
    object Label26: TLabel
      Left = 12
      Top = 172
      Width = 34
      Height = 13
      Caption = '�����:'
    end
    object Label27: TLabel
      Left = 12
      Top = 76
      Width = 42
      Height = 13
      Caption = '������:'
    end
    object iblkupCurr: TgsIBLookupComboBox
      Left = 96
      Top = 264
      Width = 242
      Height = 21
      HelpContext = 1
      Database = dmDatabase.ibdbGAdmin
      Transaction = ibtrLookup
      ListTable = 'GD_CURR'
      ListField = 'SHORTNAME'
      KeyField = 'ID'
      gdClassName = 'TgdcCurr'
      ItemHeight = 13
      ParentShowHint = False
      ShowHint = True
      TabOrder = 10
    end
    object edBankName: TEdit
      Left = 96
      Top = 24
      Width = 241
      Height = 21
      TabOrder = 0
    end
    object edBankCode: TEdit
      Left = 96
      Top = 48
      Width = 241
      Height = 21
      TabOrder = 1
    end
    object edAccount: TEdit
      Left = 96
      Top = 240
      Width = 241
      Height = 21
      TabOrder = 9
    end
    object edBankArea: TEdit
      Left = 96
      Top = 144
      Width = 241
      Height = 21
      TabOrder = 5
    end
    object edBankCity: TEdit
      Left = 96
      Top = 192
      Width = 241
      Height = 21
      TabOrder = 7
    end
    object edBankAddress: TEdit
      Left = 96
      Top = 216
      Width = 241
      Height = 21
      TabOrder = 8
    end
    object cbBankCountry: TComboBox
      Left = 96
      Top = 120
      Width = 241
      Height = 21
      Style = csDropDownList
      DropDownCount = 16
      ItemHeight = 13
      Sorted = True
      TabOrder = 4
      Items.Strings = (
        '���������'
        '�������'
        '�����������'
        '�������'
        '�����'
        '������� (��������)'
        '������'
        '�������'
        '������� � �������'
        '���������'
        '�������'
        '�����'
        '����������'
        '��������� �������'
        '���������'
        '��������'
        '�������'
        '��������'
        '�����'
        '�������'
        '�����'
        '���������� �������'
        '��������'
        '�������'
        '������ � �����������'
        '��������'
        '��������'
        '���������� ���������� �������'
        '������'
        '�������-����'
        '�������'
        '�����'
        '�������'
        '�������'
        '��������������'
        '�������'
        '���������'
        '���������� �������'
        '��������� (������������) �����'
        '��������� �����'
        '�������'
        '�����'
        '������'
        '�����'
        '������'
        '����'
        '���������'
        '���������'
        '������'
        '������-�����'
        '��������'
        '���������'
        '��������'
        '�������'
        '����������'
        '������'
        '������'
        '����'
        '�����'
        '��������������� ���������� �����'
        '�������'
        '��������'
        '������������� ����������'
        '������'
        '������'
        '�������� ������'
        '�������� �����'
        '��������'
        '�����'
        '�������'
        '�����'
        '���������'
        '��������'
        '����'
        '����'
        '��������'
        '��������'
        '�������'
        '������'
        '����-�����'
        '���������'
        '��������� �������'
        '��������'
        '�������'
        '������'
        '�����'
        '�����'
        '����'
        '��������'
        '��������'
        '�����'
        '����'
        '��������� �������'
        '��������'
        '��������� �������'
        '�����-����'
        '���-�'#39'�����'
        '����'
        '������'
        '���� �������'
        '����'
        '������'
        '������'
        '�������'
        '�����'
        '�����'
        '�����'
        '�����������'
        '����������'
        '��������'
        '����������'
        '����������'
        '����� (������)'
        '���������'
        '������'
        '��������'
        '����'
        '��������'
        '������'
        '�������'
        '���������'
        '��������� �������'
        '�������'
        '������'
        '����������'
        '��������'
        '��������'
        '������'
        '��������'
        '����������'
        '������ (�����)'
        '�������'
        '�������� ���������� �����'
        '�����'
        '�����'
        '�����'
        '�������'
        '������������� �������'
        '����������'
        '���������'
        '����'
        '����� ��������'
        '����� ���������'
        '��������'
        '�������'
        '���'
        '����'
        '��������'
        '�����'
        '���������'
        '������'
        '�����-����� ������'
        '��������'
        '����'
        '�������'
        '������'
        '����������'
        '������-����'
        '�������'
        '��������� ������'
        '������'
        '������'
        '�������'
        '���������'
        '���-������'
        '���-���� � ��������'
        '���������� ������'
        '���������'
        '������ ����� ������'
        '�������� ���������� �������'
        '����������� �������'
        '�������'
        '���-���� � �������'
        '����-������� � ���������'
        '����-���� � �����'
        '����-�����'
        '������ � ����������'
        '��������'
        '�����'
        '��������'
        '��������'
        '������'
        '�����'
        '�������'
        '���'
        '������-�����'
        '�����������'
        '�������'
        '��������'
        'Ҹ��� � ������'
        '����'
        '�������'
        '�����'
        '�������� � ������'
        '������'
        '�����'
        '������������'
        '������'
        '������'
        '����������'
        '�������'
        '������ � ������'
        '�������'
        '����'
        '��������� �������'
        '�����'
        '���������'
        '���������'
        '������������ (�����������) �������'
        '�������'
        '����������� ���������'
        '��������'
        '����������-����������� ����������'
        '���'
        '����������'
        '�����'
        '����'
        '���������'
        '������'
        '���-�����'
        '�������'
        '�������������� ������'
        '�������'
        '�������'
        '�������'
        '����� �����'
        '����-����������� ����������'
        '������'
        '������')
    end
    object edBankZIP: TEdit
      Left = 96
      Top = 96
      Width = 241
      Height = 21
      TabOrder = 3
    end
    object edBankDistrict: TEdit
      Left = 96
      Top = 168
      Width = 241
      Height = 21
      TabOrder = 6
    end
    object edBranch: TEdit
      Left = 96
      Top = 72
      Width = 241
      Height = 21
      TabOrder = 2
    end
  end
  object gbLogin: TGroupBox
    Left = 8
    Top = 352
    Width = 345
    Height = 125
    Caption = ' ������� ������ ������������ '
    TabOrder = 2
    object Label11: TLabel
      Left = 12
      Top = 58
      Width = 34
      Height = 13
      Caption = '�����:'
    end
    object Label12: TLabel
      Left = 12
      Top = 101
      Width = 41
      Height = 13
      Caption = '������:'
    end
    object Label22: TLabel
      Left = 12
      Top = 22
      Width = 76
      Height = 13
      Caption = '������������:'
    end
    object Label23: TLabel
      Left = 192
      Top = 101
      Width = 53
      Height = 13
      Caption = '��������:'
    end
    object Label30: TLabel
      Left = 96
      Top = 39
      Width = 150
      Height = 13
      Caption = '(��� ������������ �������)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Label31: TLabel
      Left = 97
      Top = 78
      Width = 195
      Height = 13
      Caption = '(������� ������ ��� ����� � �������)'
    end
    object edUser: TEdit
      Left = 96
      Top = 18
      Width = 241
      Height = 21
      Hint = '��� ������������ �������'
      Color = 10526975
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
    end
    object edLogin: TEdit
      Left = 96
      Top = 57
      Width = 241
      Height = 21
      Hint = '������� ������ ��� ����� � �������'
      Color = 10526975
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
    end
    object edPassword: TEdit
      Left = 96
      Top = 97
      Width = 89
      Height = 21
      Color = 10526975
      PasswordChar = '*'
      TabOrder = 2
    end
    object edPassword2: TEdit
      Left = 248
      Top = 97
      Width = 89
      Height = 21
      Color = 10526975
      PasswordChar = '*'
      TabOrder = 3
    end
  end
  object btnCancel: TButton
    Left = 629
    Top = 456
    Width = 75
    Height = 21
    Action = actCancel
    TabOrder = 5
  end
  object pnlInfo: TPanel
    Left = 0
    Top = 0
    Width = 713
    Height = 49
    Align = alTop
    BevelOuter = bvNone
    Color = clHighlight
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clHighlightText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
    object Label20: TLabel
      Left = 10
      Top = 8
      Width = 562
      Height = 16
      Caption = 
        '����������, ��� ������ ������ � ���������� ������� ��������� ���' +
        '�������'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clHighlightText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label28: TLabel
      Left = 11
      Top = 25
      Width = 293
      Height = 13
      Caption = '(���������� ������ ���� ����������� ��� ����������)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clHighlightText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
  end
  object Post: TActionList
    Left = 528
    Top = 296
    object actOk: TAction
      Caption = 'Ok'
      OnExecute = actOkExecute
      OnUpdate = actOkUpdate
    end
    object actCancel: TAction
      Caption = '������'
      OnExecute = actCancelExecute
    end
  end
  object ibTr: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    AutoStopAction = saNone
    Left = 560
    Top = 296
  end
  object gdcEmployee: TgdcEmployee
    Transaction = ibTr
    ReadTransaction = ibTr
    Left = 544
    Top = 216
  end
  object q: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    Transaction = ibTr
    Left = 592
    Top = 296
  end
  object gdcFolder: TgdcFolder
    Transaction = ibTr
    ReadTransaction = ibTr
    Left = 480
    Top = 216
  end
  object gdcDepartment: TgdcDepartment
    Transaction = ibTr
    ReadTransaction = ibTr
    Left = 480
    Top = 248
  end
  object gdcUser: TgdcUser
    Transaction = ibTr
    ReadTransaction = ibTr
    Left = 512
    Top = 248
  end
  object gdcBank: TgdcBank
    Transaction = ibTr
    SubSet = 'ByID'
    ReadTransaction = ibTr
    Left = 544
    Top = 248
  end
  object gdcCompany: TgdcOurCompany
    Transaction = ibTr
    ReadTransaction = ibTr
    Left = 512
    Top = 216
  end
  object gdcAccount: TgdcAccount
    Transaction = ibTr
    ReadTransaction = ibTr
    Left = 576
    Top = 216
  end
  object ibtrLookup: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    AutoStopAction = saNone
    Left = 624
    Top = 296
  end
end
