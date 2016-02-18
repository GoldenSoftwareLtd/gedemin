object ctl_dlgVariablesList: Tctl_dlgVariablesList
  Left = 260
  Top = 151
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Список переменных:'
  ClientHeight = 236
  ClientWidth = 265
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object btnClose: TButton
    Left = 186
    Top = 210
    Width = 75
    Height = 20
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Закрыть'
    ModalResult = 2
    TabOrder = 0
  end
  object btnOk: TButton
    Left = 96
    Top = 209
    Width = 75
    Height = 20
    Anchors = [akRight, akBottom]
    Caption = 'Выбрать'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object cblVariables: TCheckListBox
    Left = 6
    Top = 6
    Width = 254
    Height = 195
    ItemHeight = 13
    Items.Strings = (
      'Текущая_дата'
      'Дата_из_квитании'
      'Дата_из_накладной'
      '------------------------------------------------------------'
      '№_из_квитанции'
      '№_из_накладной'
      '№_из_ТТН'
      '------------------------------------------------------------'
      'Поставщик')
    TabOrder = 2
  end
end
