object dlgSendReport: TdlgSendReport
  Left = 439
  Top = 282
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsDialog
  Caption = 'Отправка отчета по электронной почте'
  ClientHeight = 243
  ClientWidth = 387
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 187
    Width = 93
    Height = 13
    Caption = 'Почтовый сервер:'
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
    Top = 162
    Width = 42
    Height = 13
    Caption = 'Формат:'
  end
  object Label5: TLabel
    Left = 8
    Top = 36
    Width = 28
    Height = 13
    Caption = 'Тема:'
  end
  object Label6: TLabel
    Left = 8
    Top = 60
    Width = 62
    Height = 13
    Caption = 'Сообщение:'
  end
  object iblkupSMTP: TgsIBLookupComboBox
    Left = 106
    Top = 184
    Width = 155
    Height = 21
    HelpContext = 1
    ListTable = 'GD_SMTP'
    ListField = 'NAME'
    KeyField = 'ID'
    ItemHeight = 13
    ParentShowHint = False
    ShowHint = True
    TabOrder = 8
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
    TabOrder = 9
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
  end
  object rbXLS: TRadioButton
    Left = 174
    Top = 162
    Width = 49
    Height = 17
    Caption = 'XLS'
    TabOrder = 6
  end
  object rbXML: TRadioButton
    Left = 224
    Top = 162
    Width = 49
    Height = 17
    Caption = 'XML'
    TabOrder = 7
  end
  object pnlState: TPanel
    Left = 73
    Top = 213
    Width = 305
    Height = 22
    BevelOuter = bvLowered
    Color = clInfoBk
    TabOrder = 11
  end
  object btnClose: TButton
    Left = 303
    Top = 184
    Width = 75
    Height = 21
    Caption = 'Закрыть'
    ModalResult = 1
    TabOrder = 10
  end
  object alBase: TActionList
    Left = 272
    Top = 96
    object actSend: TAction
      Caption = 'Отправить'
      OnExecute = actSendExecute
      OnUpdate = actSendUpdate
    end
    object actAddContact: TAction
      Caption = 'Добавить...'
      OnExecute = actAddContactExecute
    end
  end
end
