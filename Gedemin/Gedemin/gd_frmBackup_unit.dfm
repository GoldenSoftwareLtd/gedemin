inherited gd_frmBackup: Tgd_frmBackup
  Left = 304
  Top = 218
  HelpContext = 28
  Caption = '�������� �������� ����� ���� ������'
  PixelsPerInch = 96
  TextHeight = 13
  inherited mProgress: TMemo
    Lines.Strings = (
      '��� �������� ������ ���� ������ ������� ��� ��������� �����  '
      '� ������� ������ �������.'
      ''
      '���� ���������� ������� ��������� �������� ������, ��������,'
      '��� ������ �� �������, ������� ��� ������� � ��� ������ � ������'
      '(������ ���� ������������� ����� ����� �� ������� 2048). '
      '��� ���������� ����� � ������ ������ ����� �� ��������.'
      ''
      
        '�������� ���� ��������� �� ������� ���� ������ � ��������� �����' +
        '���.'
      ''
      
        '����� ��������� ���������� ������ ��������� ������� ������������' +
        '�.'
      ''
      '��� �������� ������ ������������ ������ ������ ������ SYSDBA.')
    TabOrder = 13
  end
  inherited btnDoIt: TButton
    TabOrder = 11
  end
  inherited btnClose: TButton
    TabOrder = 14
  end
  inherited btnHelp: TButton
    TabOrder = 12
  end
  inherited chbxVerbose: TCheckBox
    Left = 154
    Width = 271
    Caption = '��������� ���������� � ���� �������������:'
    TabOrder = 10
  end
  inherited chbxDeleteTemp: TCheckBox
    Checked = False
    State = cbUnchecked
    TabOrder = 9
  end
  object chbxGarbage: TCheckBox [15]
    Left = 318
    Top = 168
    Width = 107
    Height = 17
    Alignment = taLeftJustify
    Caption = '������ ������:'
    TabOrder = 8
  end
  object chbxCheck: TCheckBox [16]
    Left = 5
    Top = 167
    Width = 200
    Height = 17
    Alignment = taLeftJustify
    Caption = '��������� ����������� ������:'
    TabOrder = 5
  end
  object chbxSetToZero: TCheckBox [17]
    Left = 5
    Top = 183
    Width = 200
    Height = 17
    Alignment = taLeftJustify
    Caption = '�������� ������������� ��:'
    TabOrder = 6
  end
  inherited chbxShutDown: TCheckBox
    TabOrder = 7
  end
  inherited ActionList: TActionList
    inherited actDoIt: TAction
      Caption = '�������'
      OnExecute = actDoItExecute
    end
  end
  object IBBackupService: TIBBackupService [24]
    Protocol = TCP
    LoginPrompt = False
    TraceFlags = []
    BufferSize = 8192
    BlockingFactor = 0
    Options = []
    Left = 272
    Top = 16
  end
end
