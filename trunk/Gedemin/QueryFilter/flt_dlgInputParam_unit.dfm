object dlgInputParam: TdlgInputParam
  Left = 344
  Top = 213
  BorderStyle = bsDialog
  Caption = 'Введите параметры запроса'
  ClientHeight = 312
  ClientWidth = 536
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 283
    Width = 536
    Height = 29
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object Panel2: TPanel
      Left = 373
      Top = 0
      Width = 163
      Height = 29
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
      object btnOk: TButton
        Left = 3
        Top = 5
        Width = 75
        Height = 21
        Caption = 'OK'
        Default = True
        ModalResult = 1
        TabOrder = 0
      end
      object btnCancel: TButton
        Left = 83
        Top = 5
        Width = 75
        Height = 21
        Cancel = True
        Caption = 'Отмена'
        ModalResult = 2
        TabOrder = 1
      end
    end
    object chbxRepeat: TCheckBox
      Left = 182
      Top = 7
      Width = 185
      Height = 17
      Alignment = taLeftJustify
      Caption = 'Повторить выполнение запроса'
      TabOrder = 1
    end
  end
  object ScrollBox: TScrollBox
    Left = 0
    Top = 26
    Width = 536
    Height = 257
    Align = alClient
    TabOrder = 0
  end
  object pnTop: TPanel
    Left = 0
    Top = 0
    Width = 536
    Height = 26
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 2
    object TBDock1: TTBDock
      Left = 0
      Top = 0
      Width = 536
      Height = 26
      object TBToolbar1: TTBToolbar
        Left = 0
        Top = 0
        Caption = 'Панель инструментов'
        CloseButton = False
        DockMode = dmCannotFloat
        FullSize = True
        Images = dmImages.il16x16
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        object TBItem1: TTBItem
          Action = actSaveToFile
          Images = dmImages.il16x16
        end
        object TBItem2: TTBItem
          Action = actLoadFromFile
          Images = dmImages.il16x16
        end
      end
    end
  end
  object OpenDialog: TOpenDialog
    Filter = 'Файлы параметров|*.prm|Все файлы|*.*'
    Left = 256
    Top = 144
  end
  object SaveDialog: TSaveDialog
    DefaultExt = 'prm'
    Filter = 'Файлы параметров|*.prm|Все файлы|*.*'
    Left = 288
    Top = 144
  end
  object ActionList: TActionList
    Images = dmImages.il16x16
    Left = 319
    Top = 144
    object actSaveToFile: TAction
      Caption = 'Сохранить параметры'
      ImageIndex = 25
      OnExecute = actSaveToFileExecute
    end
    object actLoadFromFile: TAction
      Caption = 'Загрузить параметры'
      ImageIndex = 27
      OnExecute = actLoadFromFileExecute
    end
  end
end
