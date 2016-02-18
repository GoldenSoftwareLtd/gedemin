object gdc_dlgSettingPos: Tgdc_dlgSettingPos
  Left = 280
  Top = 179
  HelpContext = 132
  ActiveControl = lbxSettingType
  BorderStyle = bsDialog
  Caption = 'Тип объекта для добавления'
  ClientHeight = 212
  ClientWidth = 240
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object btnOk: TButton
    Left = 160
    Top = 7
    Width = 75
    Height = 21
    Caption = 'Выбрать'
    Default = True
    ModalResult = 1
    TabOrder = 0
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 160
    Top = 31
    Width = 75
    Height = 21
    Cancel = True
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 1
  end
  object lbxSettingType: TListBox
    Left = 7
    Top = 7
    Width = 145
    Height = 201
    ItemHeight = 13
    Items.Strings = (
      'Домен'
      'Индекс'
      'Исключение'
      'Макрос'
      'Отчет'
      'Поле'
      'Представление'
      'Процедура'
      'Скрипт-функции'
      'Событие'
      'Таблица'
      'Триггер'
      'Фильтр'
      'Форма')
    Sorted = True
    TabOrder = 2
    OnDblClick = btnOkClick
  end
  object btnHelp: TButton
    Left = 160
    Top = 71
    Width = 75
    Height = 21
    Caption = 'Справка'
    TabOrder = 3
    OnClick = btnHelpClick
  end
end
