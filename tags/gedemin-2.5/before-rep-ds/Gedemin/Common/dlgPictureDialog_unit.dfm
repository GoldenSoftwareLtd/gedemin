object dlgPictureDialog: TdlgPictureDialog
  Left = 234
  Top = 255
  Width = 356
  Height = 309
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSizeToolWin
  Color = clBtnFace
  Constraints.MinHeight = 175
  Constraints.MinWidth = 255
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 262
    Top = 0
    Width = 86
    Height = 241
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 0
    object btnOk: TButton
      Left = 8
      Top = 16
      Width = 75
      Height = 25
      Caption = 'ОК'
      ModalResult = 1
      TabOrder = 0
    end
    object btnCancel: TButton
      Left = 8
      Top = 48
      Width = 75
      Height = 25
      Caption = 'Отмена'
      ModalResult = 2
      TabOrder = 1
    end
    object btnHelp: TButton
      Left = 8
      Top = 80
      Width = 75
      Height = 25
      Action = aHelp
      TabOrder = 2
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 262
    Height = 241
    Align = alClient
    BevelInner = bvSpace
    BevelOuter = bvLowered
    BorderWidth = 5
    Caption = 'Panel2'
    TabOrder = 2
    object sbImage: TScrollBox
      Left = 7
      Top = 7
      Width = 248
      Height = 227
      Align = alClient
      Color = clWhite
      ParentColor = False
      TabOrder = 0
      object Image: TImage
        Left = 0
        Top = 0
        Width = 244
        Height = 223
        Align = alClient
        AutoSize = True
        Center = True
        PopupMenu = pmImage
      end
      object lbEmpty: TLabel
        Left = 108
        Top = 108
        Width = 36
        Height = 13
        Anchors = []
        Caption = '[Пусто]'
      end
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 241
    Width = 348
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object btnLoad: TButton
      Left = 8
      Top = 8
      Width = 75
      Height = 25
      Action = aLoad
      TabOrder = 0
    end
    object btnSave: TButton
      Left = 88
      Top = 8
      Width = 75
      Height = 25
      Action = aSave
      TabOrder = 1
    end
    object btnClear: TButton
      Left = 168
      Top = 8
      Width = 75
      Height = 25
      Action = aClear
      TabOrder = 2
    end
  end
  object alPictureBox: TActionList
    Left = 301
    Top = 136
    object aHelp: TAction
      Caption = 'Помощь'
    end
    object aLoad: TAction
      Caption = 'Загрузить...'
      OnExecute = aLoadExecute
      OnUpdate = aLoadUpdate
    end
    object aSave: TAction
      Caption = 'Сохранить...'
      OnExecute = aSaveExecute
      OnUpdate = aSaveUpdate
    end
    object aClear: TAction
      Caption = 'Очистить'
      OnExecute = aClearExecute
    end
    object aStretch: TAction
      Caption = 'Растягивать'
      Checked = True
      OnExecute = aStretchExecute
    end
    object aFullSize: TAction
      Caption = 'Полный размер'
      OnExecute = aFullSizeExecute
    end
  end
  object opdLoad: TOpenPictureDialog
    Filter = 
      'All (*.*)|*.*|Bitmaps (*.bmp)|*.bmp|JPEG(*.jpg)|*.jpg|ICO(*.ico)' +
      '|*.ico'
    FilterIndex = 2
    Left = 301
    Top = 176
  end
  object spdSave: TSavePictureDialog
    Filter = 
      'All (*.*)|*.*|Bitmaps (*.bmp)|*.bmp|JPEG(*.jpg)|*.jpg|ICO(*.ico)' +
      '|*.ico'
    FilterIndex = 2
    Left = 301
    Top = 208
  end
  object pmImage: TPopupMenu
    Left = 33
    Top = 17
    object N1: TMenuItem
      Action = aStretch
    end
    object N2: TMenuItem
      Action = aFullSize
    end
  end
end
