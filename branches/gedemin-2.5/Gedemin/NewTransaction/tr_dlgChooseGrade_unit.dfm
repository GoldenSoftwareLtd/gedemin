object dlgChooseGrade: TdlgChooseGrade
  Left = 245
  Top = 182
  Width = 323
  Height = 182
  Caption = '��������, ��� ����������� ������'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  PixelsPerInch = 96
  TextHeight = 13
  object rgTypeRecord: TRadioGroup
    Left = 8
    Top = 10
    Width = 297
    Height = 79
    Caption = '��� ����������� ������'
    ItemIndex = 0
    Items.Strings = (
      '���� ������'
      '������'
      '���� (�������)')
    TabOrder = 0
  end
  object bOk: TButton
    Left = 64
    Top = 119
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object bCancel: TButton
    Left = 176
    Top = 119
    Width = 75
    Height = 25
    Cancel = True
    Caption = '������'
    ModalResult = 2
    TabOrder = 2
  end
  object cbDontShow: TCheckBox
    Left = 16
    Top = 95
    Width = 209
    Height = 17
    Caption = '������ �� ���������� ��� ����'
    TabOrder = 3
  end
end
