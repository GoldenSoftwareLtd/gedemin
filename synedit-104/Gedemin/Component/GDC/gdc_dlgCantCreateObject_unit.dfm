inherited gdc_dlgCantCreateObject: Tgdc_dlgCantCreateObject
  Left = 271
  Top = 150
  Caption = 'Сохранение объекта'
  ClientHeight = 319
  ClientWidth = 447
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel [0]
    Left = 8
    Top = 165
    Width = 345
    Height = 147
    Shape = bsFrame
  end
  inherited btnAccess: TButton
    Left = 362
    Top = 197
    Enabled = False
    Visible = False
  end
  inherited btnNew: TButton
    Left = 362
    Top = 229
    Enabled = False
    Visible = False
  end
  inherited btnOK: TButton
    Left = 361
    Top = 13
  end
  inherited btnCancel: TButton
    Left = 361
    Top = 45
  end
  inherited btnHelp: TButton
    Left = 362
    Top = 93
  end
  object Memo1: TMemo [6]
    Left = 48
    Top = 170
    Width = 297
    Height = 134
    TabStop = False
    BorderStyle = bsNone
    Color = clBtnFace
    Lines.Strings = (
      'Объект уже существует в базе данных.'
      'Необходимо выбрать его.'
      ''
      'Объект уже существует в базе данных.'
      'Выбрать его и обновить данными из файла.'
      ''
      'Изменить данные объекта, чтобы не'
      'возникало ошибок при его сохранении.'
      ''
      'Не сохранять объект в базе данных.')
    ReadOnly = True
    TabOrder = 5
  end
  object mObjectInfo: TMemo [7]
    Left = 8
    Top = 13
    Width = 345
    Height = 145
    BorderStyle = bsNone
    Color = clBtnFace
    Lines.Strings = (
      'Возникла ошибка при попытке сохранить в базе данных объект: '
      ''
      '    Наименование: %s'
      '    Тип: %s '
      '    Подтип: %s '
      '    Идентификатор: %d'
      ''
      'Возможно такой объект уже присутствует в базе данных, но '
      'имеет другой идентификатор. '
      ''
      'Выберите одно из предлагаемых действий:')
    ReadOnly = True
    TabOrder = 6
  end
  object rbSelect: TRadioButton [8]
    Left = 16
    Top = 170
    Width = 17
    Height = 17
    Checked = True
    TabOrder = 7
    TabStop = True
  end
  object rbSelectAndUpdate: TRadioButton [9]
    Left = 16
    Top = 209
    Width = 17
    Height = 17
    TabOrder = 8
  end
  object rbReject: TRadioButton [10]
    Left = 16
    Top = 286
    Width = 17
    Height = 17
    TabOrder = 9
  end
  object rbEdit: TRadioButton [11]
    Left = 16
    Top = 247
    Width = 17
    Height = 17
    TabOrder = 10
  end
  inherited alBase: TActionList
    Left = 398
    Top = 263
  end
  inherited dsgdcBase: TDataSource
    Left = 368
    Top = 263
  end
  object OpenDialog1: TOpenDialog
    Options = [ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Left = 400
    Top = 136
  end
end
