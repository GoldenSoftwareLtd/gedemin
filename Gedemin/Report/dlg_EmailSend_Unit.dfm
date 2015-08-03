object dlg_EmailSend: Tdlg_EmailSend
  Left = 439
  Top = 282
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsDialog
  Caption = 'Отправка отчета по электронной почте'
  ClientHeight = 234
  ClientWidth = 439
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 186
    Width = 117
    Height = 13
    Caption = 'Учетная запись SMTP:'
  end
  object Label2: TLabel
    Left = 8
    Top = 34
    Width = 96
    Height = 13
    Caption = 'Добавить контакт:'
  end
  object Label3: TLabel
    Left = 8
    Top = 8
    Width = 29
    Height = 13
    Caption = 'Кому:'
  end
  object Label4: TLabel
    Left = 8
    Top = 210
    Width = 81
    Height = 13
    Caption = 'Формат отчета:'
  end
  object Label5: TLabel
    Left = 8
    Top = 58
    Width = 57
    Height = 13
    Caption = 'Заголовок:'
  end
  object Label6: TLabel
    Left = 8
    Top = 82
    Width = 61
    Height = 13
    Caption = 'Сообщение:'
  end
  object iblkupSMTP: TgsIBLookupComboBox
    Left = 128
    Top = 184
    Width = 185
    Height = 21
    HelpContext = 1
    ListTable = 'GD_SMTP'
    ListField = 'NAME'
    KeyField = 'ID'
    ItemHeight = 13
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
  end
  object iblkupContact: TgsIBLookupComboBox
    Left = 128
    Top = 32
    Width = 305
    Height = 21
    HelpContext = 1
    ListTable = 'GD_CONTACT'
    ListField = 'NAME'
    KeyField = 'ID'
    Condition = 'GD_CONTACT.CONTACTTYPE  IN (1,2,3,4,5)'
    ItemHeight = 13
    TabOrder = 1
    OnChange = iblkupContactChange
  end
  object edRecipients: TEdit
    Left = 128
    Top = 8
    Width = 305
    Height = 21
    TabOrder = 2
  end
  object cbExportType: TComboBox
    Left = 128
    Top = 208
    Width = 185
    Height = 21
    ItemHeight = 13
    TabOrder = 3
    Text = 'PDF'
    Items.Strings = (
      'DOC'
      'XLS'
      'PDF'
      'XML')
  end
  object edSubject: TEdit
    Left = 128
    Top = 56
    Width = 305
    Height = 21
    TabOrder = 4
  end
  object mBodyText: TMemo
    Left = 128
    Top = 80
    Width = 305
    Height = 97
    TabOrder = 5
  end
  object Button1: TButton
    Left = 360
    Top = 204
    Width = 75
    Height = 25
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
