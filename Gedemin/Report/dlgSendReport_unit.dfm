object dlgSendReport: TdlgSendReport
  Left = 676
  Top = 253
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsDialog
  Caption = '�������� ������ �� ����������� �����'
  ClientHeight = 269
  ClientWidth = 387
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 211
    Width = 93
    Height = 13
    Caption = '�������� ������:'
  end
  object Label3: TLabel
    Left = 8
    Top = 8
    Width = 29
    Height = 13
    Caption = '����:'
  end
  object Label4: TLabel
    Left = 8
    Top = 162
    Width = 42
    Height = 13
    Caption = '������:'
  end
  object Label5: TLabel
    Left = 8
    Top = 36
    Width = 28
    Height = 13
    Caption = '����:'
  end
  object Label6: TLabel
    Left = 8
    Top = 60
    Width = 62
    Height = 13
    Caption = '���������:'
  end
  object iblkupSMTP: TgsIBLookupComboBox
    Left = 106
    Top = 208
    Width = 155
    Height = 21
    HelpContext = 1
    ListTable = 'GD_SMTP'
    ListField = 'NAME'
    KeyField = 'ID'
    ItemHeight = 13
    ParentShowHint = False
    ShowHint = True
    TabOrder = 12
  end
  object edRecipients: TEdit
    Left = 74
    Top = 8
    Width = 230
    Height = 21
    TabOrder = 0
  end
  object edSubject: TEdit
    Left = 74
    Top = 34
    Width = 305
    Height = 21
    TabOrder = 2
  end
  object mBodyText: TMemo
    Left = 74
    Top = 58
    Width = 305
    Height = 97
    TabOrder = 3
  end
  object btnSend: TButton
    Left = 303
    Top = 160
    Width = 75
    Height = 21
    Action = actSend
    TabOrder = 13
  end
  object btnAdd: TButton
    Left = 303
    Top = 8
    Width = 75
    Height = 21
    Action = actAddContact
    TabOrder = 1
  end
  object rbDoc: TRadioButton
    Left = 74
    Top = 162
    Width = 49
    Height = 17
    Caption = 'DOC'
    Checked = True
    TabOrder = 4
    TabStop = True
  end
  object rbPDF: TRadioButton
    Left = 124
    Top = 162
    Width = 49
    Height = 17
    Caption = 'PDF'
    TabOrder = 5
    TabStop = True
  end
  object rbXLS: TRadioButton
    Left = 174
    Top = 162
    Width = 49
    Height = 17
    Caption = 'XLS'
    TabOrder = 6
    TabStop = True
  end
  object rbXML: TRadioButton
    Left = 224
    Top = 162
    Width = 49
    Height = 17
    Caption = 'XML'
    TabOrder = 7
    TabStop = True
  end
  object pnlState: TPanel
    Left = 73
    Top = 237
    Width = 305
    Height = 22
    BevelOuter = bvLowered
    Color = clInfoBk
    TabOrder = 15
  end
  object btnClose: TButton
    Left = 303
    Top = 184
    Width = 75
    Height = 21
    Caption = '�������'
    ModalResult = 1
    TabOrder = 14
  end
  object rbTXT: TRadioButton
    Left = 74
    Top = 184
    Width = 41
    Height = 17
    Caption = 'TXT'
    TabOrder = 8
    TabStop = True
  end
  object rbHTM: TRadioButton
    Left = 124
    Top = 184
    Width = 41
    Height = 17
    Caption = 'HTM'
    TabOrder = 9
    TabStop = True
  end
  object rbODT: TRadioButton
    Left = 174
    Top = 184
    Width = 41
    Height = 17
    Caption = 'ODT'
    TabOrder = 10
    TabStop = True
  end
  object rbODS: TRadioButton
    Left = 224
    Top = 184
    Width = 41
    Height = 17
    Caption = 'ODS'
    TabOrder = 11
    TabStop = True
  end
  object alBase: TActionList
    Left = 272
    Top = 96
    object actSend: TAction
      Caption = '���������'
      OnExecute = actSendExecute
      OnUpdate = actSendUpdate
    end
    object actAddContact: TAction
      Caption = '��������...'
      OnExecute = actAddContactExecute
    end
  end
end
