inherited gdc_dlgNamespacePos: Tgdc_dlgNamespacePos
  Left = 397
  Top = 433
  Caption = '��������'
  ClientHeight = 153
  ClientWidth = 328
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Top = 53
  end
  inherited btnNew: TButton
    Top = 53
  end
  inherited btnHelp: TButton
    Top = 53
  end
  inherited btnOK: TButton
    Left = 176
    Top = 123
  end
  inherited btnCancel: TButton
    Left = 248
    Top = 123
  end
  object Panel1: TPanel [5]
    Left = 0
    Top = 0
    Width = 328
    Height = 113
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 5
    object lName: TLabel
      Left = 8
      Top = 10
      Width = 77
      Height = 13
      Caption = '������������:'
    end
    object dbtxtName: TDBText
      Left = 8
      Top = 24
      Width = 313
      Height = 17
      DataField = 'objectname'
      DataSource = dsgdcBase
    end
    object dbchbxalwaysoverwrite: TDBCheckBox
      Left = 8
      Top = 42
      Width = 217
      Height = 17
      Caption = '������ �������������� ��� ��������'
      DataField = 'alwaysoverwrite'
      DataSource = dsgdcBase
      TabOrder = 0
      ValueChecked = '1'
      ValueUnchecked = '0'
    end
    object dbchbxdontremove: TDBCheckBox
      Left = 8
      Top = 66
      Width = 257
      Height = 17
      Caption = '�� ������� ��� �������� ������������ ����'
      DataField = 'dontremove'
      DataSource = dsgdcBase
      TabOrder = 1
      ValueChecked = '1'
      ValueUnchecked = '0'
    end
    object dbchbxincludesiblings: TDBCheckBox
      Left = 8
      Top = 90
      Width = 233
      Height = 17
      Caption = '�������� ��������� �������'
      DataField = 'includesiblings'
      DataSource = dsgdcBase
      TabOrder = 2
      ValueChecked = '1'
      ValueUnchecked = '0'
    end
  end
  inherited alBase: TActionList
    Left = 446
    Top = 7
  end
  inherited dsgdcBase: TDataSource
    Left = 360
    Top = 7
  end
  inherited pm_dlgG: TPopupMenu
    Left = 392
    Top = 8
  end
  inherited ibtrCommon: TIBTransaction
    Left = 424
    Top = 8
  end
end
