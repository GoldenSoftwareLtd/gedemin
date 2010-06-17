object frmIBUserList: TfrmIBUserList
  Left = 421
  Top = 322
  BorderStyle = bsDialog
  Caption = '������������'
  ClientHeight = 366
  ClientWidth = 499
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label5: TLabel
    Left = 10
    Top = 10
    Width = 483
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = '  � ���� ���������� ��������� ������������:'
    Color = clBlack
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindow
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
    Layout = tlCenter
  end
  object lblCount: TLabel
    Left = 13
    Top = 289
    Width = 3
    Height = 13
  end
  object lvUser: TgsListView
    Left = 10
    Top = 40
    Width = 483
    Height = 161
    Anchors = [akLeft, akTop, akRight]
    Columns = <
      item
        AutoSize = True
        Caption = '������������ IB'
      end
      item
        AutoSize = True
        Caption = '��� ������������'
      end
      item
        Caption = '���������'
        Width = 126
      end
      item
        AutoSize = True
        Caption = '����� �����������'
      end>
    FlatScrollBars = True
    GridLines = True
    ReadOnly = True
    RowSelect = True
    TabOrder = 1
    ViewStyle = vsReport
  end
  object memoInfo: TMemo
    Left = 10
    Top = 205
    Width = 481
    Height = 82
    TabStop = False
    Anchors = [akLeft, akTop, akRight]
    BorderStyle = bsNone
    Lines.Strings = (
      
        '��� ������������� �������� ����������/�������� �����-������, ���' +
        '��-��������'
      '���������� ��������� ������ ������������� �� ���� ������.'
      ''
      
        '���� ������������ ��������� ��� �� ������������ ��������� ���� �' +
        '�������,'
      '������� ����������.'
      ' ')
    ParentColor = True
    ReadOnly = True
    TabOrder = 2
  end
  object pnlButtons: TPanel
    Left = 0
    Top = 327
    Width = 499
    Height = 39
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object Bevel1: TBevel
      Left = 0
      Top = 0
      Width = 499
      Height = 2
      Align = alTop
    end
    object btnCancel: TButton
      Left = 332
      Top = 10
      Width = 75
      Height = 21
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = '��������'
      ModalResult = 2
      TabOrder = 0
    end
    object btnOk: TButton
      Left = 418
      Top = 10
      Width = 75
      Height = 21
      Action = actOk
      Anchors = [akTop, akRight]
      Default = True
      ModalResult = 1
      TabOrder = 1
    end
    object btnRefresh: TButton
      Left = 10
      Top = 10
      Width = 75
      Height = 21
      Action = actRefresh
      TabOrder = 2
    end
    object btnDeleteUser: TButton
      Left = 91
      Top = 10
      Width = 75
      Height = 21
      Action = actRefresh
      Caption = '���������'
      TabOrder = 3
    end
  end
  object chbxShowNames: TCheckBox
    Left = 10
    Top = 307
    Width = 351
    Height = 17
    Caption = '���������� ������� ����� �����������'
    TabOrder = 3
  end
  object IBUserTimer: TTimer
    Enabled = False
    Interval = 60000
    OnTimer = IBUserTimerTimer
    Left = 90
    Top = 150
  end
  object alIBUsers: TActionList
    Left = 272
    Top = 112
    object actOk: TAction
      Caption = '����������'
      Hint = '�� ������ ����������, ������ ���� ��������� ���� ������������'
      OnExecute = actOkExecute
      OnUpdate = actOkUpdate
    end
    object actRefresh: TAction
      Caption = '��������'
      OnExecute = actRefreshExecute
      OnUpdate = actRefreshUpdate
    end
  end
end
