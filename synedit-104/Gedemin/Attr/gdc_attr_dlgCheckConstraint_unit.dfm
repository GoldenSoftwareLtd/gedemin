inherited gdc_dlgCheckConstraint: Tgdc_dlgCheckConstraint
  Left = 379
  Top = 447
  Caption = '�����������'
  ClientHeight = 140
  ClientWidth = 480
  PixelsPerInch = 96
  TextHeight = 13
  object lblCheckName: TLabel [0]
    Left = 10
    Top = 13
    Width = 77
    Height = 13
    Caption = '������������:'
  end
  object lblCheckExpression: TLabel [1]
    Left = 10
    Top = 46
    Width = 71
    Height = 13
    Caption = '�����������:'
  end
  object lbMsg: TLabel [2]
    Left = 8
    Top = 79
    Width = 147
    Height = 13
    Caption = '�������������� ���������:'
  end
  inherited btnAccess: TButton
    Left = 8
    Top = 110
    Anchors = [akLeft, akBottom]
    TabOrder = 4
  end
  inherited btnNew: TButton
    Left = 80
    Top = 110
    Anchors = [akLeft, akBottom]
    TabOrder = 5
  end
  inherited btnOK: TButton
    Left = 327
    Top = 110
    Anchors = [akRight, akBottom]
    TabOrder = 2
  end
  inherited btnCancel: TButton
    Left = 399
    Top = 110
    Height = 22
    Anchors = [akRight, akBottom]
    TabOrder = 3
  end
  inherited btnHelp: TButton
    Left = 152
    Top = 110
    Anchors = [akLeft, akBottom]
    TabOrder = 6
  end
  object dbeCheckName: TDBEdit [8]
    Left = 176
    Top = 9
    Width = 129
    Height = 21
    DataField = 'checkname'
    DataSource = dsgdcBase
    TabOrder = 0
  end
  object dbCheckExpression: TDBMemo [9]
    Left = 176
    Top = 42
    Width = 290
    Height = 21
    DataField = 'RDB$TRIGGER_SOURCE'
    DataSource = dsgdcBase
    TabOrder = 1
  end
  object dbMsg: TDBMemo [10]
    Left = 176
    Top = 75
    Width = 290
    Height = 21
    DataField = 'MSG'
    DataSource = dsgdcBase
    TabOrder = 7
  end
end
