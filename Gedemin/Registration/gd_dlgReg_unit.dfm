object gd_dlgReg: Tgd_dlgReg
  Left = 556
  Top = 582
  ActiveControl = eCipher
  BorderStyle = bsDialog
  Caption = '�����������'
  ClientHeight = 299
  ClientWidth = 446
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
    Left = 7
    Top = 236
    Width = 183
    Height = 13
    Caption = '��� ������������� (��� ��������):'
  end
  object Bevel1: TBevel
    Left = 0
    Top = 263
    Width = 447
    Height = 6
    Shape = bsTopLine
  end
  object eCipher: TEdit
    Left = 200
    Top = 233
    Width = 124
    Height = 21
    TabOrder = 0
  end
  object btnClose: TButton
    Left = 363
    Top = 271
    Width = 75
    Height = 21
    Anchors = []
    Cancel = True
    Caption = '�������'
    Default = True
    ModalResult = 2
    TabOrder = 2
    OnClick = btnCloseClick
  end
  object btnReg: TButton
    Left = 329
    Top = 233
    Width = 109
    Height = 21
    Action = actReg
    Anchors = []
    TabOrder = 1
  end
  object pc: TPageControl
    Left = 5
    Top = 4
    Width = 433
    Height = 221
    ActivePage = tsReg
    TabOrder = 3
    object tsReg: TTabSheet
      Caption = 'tsReg'
      TabVisible = False
      object lblRegNumber2: TLabel
        Left = 8
        Top = 103
        Width = 409
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
        Left = 2
        Top = 3
        Width = 417
        Height = 94
        BorderStyle = bsNone
        Lines.Strings = (
          '�� ��������� � ������������������ ������ ���������.'
          ''
          '%s %s'
          ''
          
            '��� ��������� ���������� ����������� ���������� ���������� � ���' +
            '� '
          
            '�������� Golden Software, Ltd �� �������������� ���������, � ���' +
            '�� '
          '�������� ��������� ���� ����������� �����.'
          ' ')
        ParentColor = True
        ReadOnly = True
        TabOrder = 0
      end
      object mReg2: TMemo
        Left = 2
        Top = 146
        Width = 417
        Height = 57
        BorderStyle = bsNone
        Lines.Strings = (
          '���������� ������ ���������: +375-17-2561759, 2562782  '
          '����������� �����: support@gsbelarus.com'
          ''
          '� ����� ��� ����� ������� ��� �������������.')
        ParentColor = True
        ReadOnly = True
        TabOrder = 1
      end
    end
    object tsUnReg: TTabSheet
      Caption = 'tsUnReg'
      ImageIndex = 1
      TabVisible = False
      object lblRegNumber: TLabel
        Left = 8
        Top = 103
        Width = 408
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
        Left = 2
        Top = 3
        Width = 417
        Height = 94
        BorderStyle = bsNone
        Lines.Strings = (
          '�� ��������� � �������������������� ������ ���������.'
          ''
          '��������� ������� ����� ����������.'
          ''
          
            '��� ����������� ���������� �������� � ���� �������� Golden Softw' +
            'are, Ltd '
          
            '����� ��������, ������� ��� ����� ��� ��� �������, � ����� �����' +
            '���� '
          '���� ����������� �����.'
          ' ')
        ParentColor = True
        ReadOnly = True
        TabOrder = 0
      end
      object mUnreg2: TMemo
        Left = 2
        Top = 146
        Width = 417
        Height = 57
        BorderStyle = bsNone
        Lines.Strings = (
          '���������� ������ ���������: +375-17-2561759, 2562782  '
          '����������� �����: support@gsbelarus.com'
          ''
          '� ����� ��� ����� ������� ��� �������������.')
        ParentColor = True
        ReadOnly = True
        TabOrder = 1
      end
    end
  end
  object ActionList: TActionList
    Left = 376
    Top = 144
    object actReg: TAction
      Caption = '����������������'
      OnExecute = actRegExecute
      OnUpdate = actRegUpdate
    end
  end
end
