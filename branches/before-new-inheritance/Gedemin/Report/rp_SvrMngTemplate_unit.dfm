object SvrMngTemplate: TSvrMngTemplate
  Left = 351
  Top = 343
  BorderStyle = bsDialog
  Caption = '������� ������� �������'
  ClientHeight = 126
  ClientWidth = 305
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  PixelsPerInch = 120
  TextHeight = 16
  object btnClose: TButton
    Left = 207
    Top = 89
    Width = 92
    Height = 30
    Action = actClose
    TabOrder = 7
  end
  object btnProperty: TButton
    Left = 10
    Top = 10
    Width = 92
    Height = 31
    Caption = '���������'
    TabOrder = 0
  end
  object btnDisconnect: TButton
    Left = 108
    Top = 10
    Width = 93
    Height = 31
    Caption = '���������'
    TabOrder = 1
  end
  object btnRefresh: TButton
    Left = 10
    Top = 49
    Width = 92
    Height = 31
    Caption = '��������'
    TabOrder = 3
  end
  object btnRebuild: TButton
    Left = 108
    Top = 49
    Width = 93
    Height = 31
    Caption = '�����������'
    TabOrder = 4
  end
  object btnConnectParam: TButton
    Left = 108
    Top = 89
    Width = 93
    Height = 30
    Caption = '���� ������'
    TabOrder = 6
  end
  object btnRun: TButton
    Left = 10
    Top = 89
    Width = 92
    Height = 30
    Caption = '���������'
    TabOrder = 5
  end
  object btnClear: TButton
    Left = 207
    Top = 10
    Width = 92
    Height = 31
    Caption = '��������'
    TabOrder = 2
  end
  object ActionList1: TActionList
    Left = 16
    object actClose: TAction
      Caption = '�������'
    end
  end
end
