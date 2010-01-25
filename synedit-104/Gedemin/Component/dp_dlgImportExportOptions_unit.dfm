object dlgImportExportOptions: TdlgImportExportOptions
  Left = 28
  Top = 166
  BorderStyle = bsDialog
  Caption = 'Настройки'
  ClientHeight = 313
  ClientWidth = 370
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 5
    Top = 5
    Width = 361
    Height = 131
    Shape = bsFrame
  end
  object Bevel2: TBevel
    Left = 5
    Top = 140
    Width = 361
    Height = 111
    Shape = bsFrame
  end
  object Label1: TLabel
    Left = 10
    Top = 145
    Width = 193
    Height = 13
    Caption = 'Путь к файлам платежных поручений:'
  end
  object Label3: TLabel
    Left = 10
    Top = 229
    Width = 221
    Height = 13
    Caption = 'Расширение файлов платежных поручений:'
  end
  object Label4: TLabel
    Left = 10
    Top = 185
    Width = 208
    Height = 13
    Caption = 'Файл-шаблон для платежных поручений:'
  end
  object Bevel3: TBevel
    Left = 0
    Top = 278
    Width = 377
    Height = 2
    Anchors = [akLeft, akRight, akBottom]
  end
  object Label2: TLabel
    Left = 10
    Top = 10
    Width = 126
    Height = 13
    Caption = 'Путь к файлам выписок:'
  end
  object sbOpenPayment: TSpeedButton
    Left = 338
    Top = 160
    Width = 23
    Height = 22
    Caption = '...'
    OnClick = sbOpenPaymentClick
  end
  object Label5: TLabel
    Left = 10
    Top = 94
    Width = 154
    Height = 13
    Caption = 'Расширение файлов выписок:'
  end
  object Label6: TLabel
    Left = 10
    Top = 50
    Width = 141
    Height = 13
    Caption = 'Файл-шаблон для выписки:'
  end
  object sbOpenPaymentTemplate: TSpeedButton
    Left = 338
    Top = 200
    Width = 23
    Height = 22
    Caption = '...'
    OnClick = sbOpenPaymentTemplateClick
  end
  object sbOpenStatement: TSpeedButton
    Left = 338
    Top = 25
    Width = 23
    Height = 22
    Caption = '...'
    OnClick = sbOpenStatementClick
  end
  object sbOpenStatementTemplate: TSpeedButton
    Left = 338
    Top = 65
    Width = 23
    Height = 22
    Caption = '...'
    OnClick = sbOpenStatementTemplateClick
  end
  object btnOk: TButton
    Left = 210
    Top = 286
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'ОK'
    Default = True
    ModalResult = 1
    TabOrder = 8
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 290
    Top = 286
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 9
  end
  object edDirectoryPayment: TEdit
    Left = 10
    Top = 160
    Width = 326
    Height = 21
    TabOrder = 4
  end
  object edExtensionPayment: TEdit
    Left = 255
    Top = 225
    Width = 81
    Height = 21
    MaxLength = 3
    TabOrder = 5
  end
  object edTemplatePayment: TEdit
    Left = 10
    Top = 200
    Width = 326
    Height = 21
    TabOrder = 6
  end
  object cbDivideEnter: TCheckBox
    Left = 5
    Top = 255
    Width = 171
    Height = 17
    Caption = 'Разделитель'
    TabOrder = 7
  end
  object edDirectoryStatement: TEdit
    Left = 10
    Top = 25
    Width = 326
    Height = 21
    TabOrder = 0
  end
  object edExtensionStatement: TEdit
    Left = 255
    Top = 90
    Width = 81
    Height = 21
    MaxLength = 3
    TabOrder = 1
  end
  object edTemplateStatement: TEdit
    Left = 10
    Top = 65
    Width = 326
    Height = 21
    TabOrder = 2
  end
  object cbToday: TCheckBox
    Left = 10
    Top = 115
    Width = 326
    Height = 17
    Caption = 'Импортировать только сегодняшний день'
    TabOrder = 3
  end
  object OpenDialog: TOpenDialog
    Filter = '*.*|*.*'
    Left = 285
  end
end
