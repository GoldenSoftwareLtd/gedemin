object gd_dlgReg: Tgd_dlgReg
  Left = 373
  Top = 230
  ActiveControl = eCipher
  BorderStyle = bsDialog
  Caption = '�����������'
  ClientHeight = 299
  ClientWidth = 396
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
  object Label2: TLabel
    Left = 17
    Top = 236
    Width = 104
    Height = 13
    Caption = '��� �������������:'
  end
  object Bevel1: TBevel
    Left = 0
    Top = 263
    Width = 401
    Height = 6
    Shape = bsTopLine
  end
  object eCipher: TEdit
    Left = 124
    Top = 233
    Width = 153
    Height = 21
    TabOrder = 1
  end
  object btnClose: TButton
    Left = 316
    Top = 271
    Width = 75
    Height = 21
    Anchors = []
    Cancel = True
    Caption = '�������'
    Default = True
    ModalResult = 2
    TabOrder = 3
    OnClick = btnCloseClick
  end
  object btnReg: TButton
    Left = 282
    Top = 233
    Width = 109
    Height = 21
    Anchors = []
    Caption = '����������������'
    TabOrder = 2
    OnClick = btnRegClick
  end
  object pc: TPageControl
    Left = 5
    Top = 4
    Width = 386
    Height = 221
    ActivePage = tsUnReg
    TabOrder = 0
    object tsReg: TTabSheet
      Caption = 'tsReg'
      TabVisible = False
      object lblRegNumber2: TLabel
        Left = 8
        Top = 175
        Width = 361
        Height = 33
        Alignment = taCenter
        AutoSize = False
        Caption = 'lblRegNumber'
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -27
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object mReg: TMemo
        Left = 5
        Top = 3
        Width = 372
        Height = 171
        BorderStyle = bsNone
        Lines.Strings = (
          '�� ��������� � ������������������ ������ ���������. '
          '���������� �������������: %s. ���� ��������� ��������: %s'
          ''
          '��� ���������� ���������� ������� ���� ��� ��������� ����� '
          '�������� ���������� �������� �������������� �������� � '
          '��������� ����������� ���������. �������� � ���� �������� '
          'Golden Software �� ��������� +375-17-2561759 ��� '
          '+375-17-2562782, ��� ����������� ����� support@gsbelarus.com '
          '����� ��������, � ����� ��������� ���� ����������� �����.'
          ''
          '� �����, ��� ����� ������ ��� �������������, ������� ����������'
          
            '������ � ���� ��� ������������� � ������ ������ ����������������' +
            '. ')
        ParentColor = True
        ReadOnly = True
        TabOrder = 0
      end
    end
    object tsUnReg: TTabSheet
      Caption = 'tsUnReg'
      ImageIndex = 1
      TabVisible = False
      object lblRegNumber: TLabel
        Left = 8
        Top = 174
        Width = 361
        Height = 33
        Alignment = taCenter
        AutoSize = False
        Caption = 'lblRegNumber'
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -27
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object mUnreg: TMemo
        Left = 5
        Top = 3
        Width = 372
        Height = 169
        BorderStyle = bsNone
        Lines.Strings = (
          '�� ��������� � �������������������� ������ ���������. '
          '� �������������������� ������ ������ �� �� ������ ��������'
          '��������� �� ������.'
          ''
          '��� ����������� ��������� ���������� �������� � ���� '
          '�������� Golden Software �� ��������� +375-17-2561759,'
          '��� +375-17-2562782 ��� ����������� ����� support@gsbelarus.com'
          '����� ��������, ������� ��� ����� ��� ������ � ����������,'
          '� ����� ��������� ���� ����������� �����.'
          ''
          '� �����, ��� ����� ������ ��� �������������, ������� ����������'
          
            '������ � ���� ��� ������������� � ������ ������ ����������������' +
            '. ')
        ParentColor = True
        ReadOnly = True
        TabOrder = 0
      end
    end
  end
end
