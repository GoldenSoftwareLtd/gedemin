object dlg_EmailSend: Tdlg_EmailSend
  Left = 439
  Top = 282
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsDialog
  Caption = 'Отправка отчета по электронной почте'
  ClientHeight = 252
  ClientWidth = 473
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 14
  object Label1: TLabel
    Left = 9
    Top = 200
    Width = 114
    Height = 14
    Caption = 'Учетная запись SMTP:'
  end
  object Label2: TLabel
    Left = 9
    Top = 37
    Width = 97
    Height = 14
    Caption = 'Добавить контакт:'
  end
  object Label3: TLabel
    Left = 9
    Top = 9
    Width = 30
    Height = 14
    Caption = 'Кому:'
  end
  object Label4: TLabel
    Left = 9
    Top = 226
    Width = 82
    Height = 14
    Caption = 'Формат отчета:'
  end
  object Label5: TLabel
    Left = 9
    Top = 62
    Width = 56
    Height = 14
    Caption = 'Заголовок:'
  end
  object Label6: TLabel
    Left = 9
    Top = 88
    Width = 60
    Height = 14
    Caption = 'Сообщение:'
  end
  object iblkupSMTP: TgsIBLookupComboBox
    Left = 138
    Top = 198
    Width = 199
    Height = 22
    HelpContext = 1
    ListTable = 'GD_SMTP'
    ListField = 'NAME'
    KeyField = 'ID'
    ItemHeight = 14
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
  end
  object iblkupContact: TgsIBLookupComboBox
    Left = 138
    Top = 34
    Width = 328
    Height = 22
    HelpContext = 1
    ListTable = 'GD_CONTACT'
    ListField = 'NAME'
    KeyField = 'ID'
    Condition = 'GD_CONTACT.CONTACTTYPE  IN (1,2,3,4,5)'
    ItemHeight = 14
    TabOrder = 1
    OnChange = iblkupContactChange
  end
  object edRecipients: TEdit
    Left = 138
    Top = 9
    Width = 328
    Height = 22
    TabOrder = 2
  end
  object cbExportType: TComboBox
    Left = 138
    Top = 224
    Width = 199
    Height = 22
    ItemHeight = 14
    TabOrder = 3
    Text = 'PDF'
    Items.Strings = (
      'DOC'
      'XLS'
      'PDF'
      'XML')
  end
  object edSubject: TEdit
    Left = 138
    Top = 60
    Width = 328
    Height = 22
    TabOrder = 4
  end
  object mBodyText: TMemo
    Left = 138
    Top = 86
    Width = 328
    Height = 105
    TabOrder = 5
  end
  object Button1: TButton
    Left = 388
    Top = 220
    Width = 80
    Height = 27
    Action = actSend
    TabOrder = 6
  end
  object alBase: TActionList
    Left = 328
    Top = 184
    object actSend: TAction
      Caption = 'Отправить'
      OnExecute = actSendExecute
      OnUpdate = actSendUpdate
    end
  end
end
