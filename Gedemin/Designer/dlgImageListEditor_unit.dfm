object dlgImageListEditor: TdlgImageListEditor
  Left = 266
  Top = 230
  BorderStyle = bsDialog
  Caption = 'Редактор рисунков'
  ClientHeight = 251
  ClientWidth = 433
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 433
    Height = 251
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 10
    Caption = 'Panel1'
    TabOrder = 0
    object Panel2: TPanel
      Left = 10
      Top = 10
      Width = 323
      Height = 231
      Align = alClient
      BevelOuter = bvNone
      Caption = 'Panel2'
      TabOrder = 0
      object GroupBox1: TGroupBox
        Left = 0
        Top = 0
        Width = 323
        Height = 89
        Align = alTop
        Caption = 'Выбранный рисунок'
        TabOrder = 0
        object Label2: TLabel
          Left = 96
          Top = 54
          Width = 3
          Height = 13
        end
        object Panel3: TPanel
          Left = 10
          Top = 17
          Width = 64
          Height = 63
          BevelOuter = bvLowered
          TabOrder = 0
          object Image: TImage
            Left = 1
            Top = 1
            Width = 62
            Height = 61
            Align = alClient
            Stretch = True
          end
        end
      end
      object GroupBox2: TGroupBox
        Left = 0
        Top = 91
        Width = 323
        Height = 140
        Align = alBottom
        Caption = 'Рисунки'
        TabOrder = 1
        object Button5: TButton
          Left = 11
          Top = 112
          Width = 70
          Height = 21
          Action = actAdd
          TabOrder = 0
        end
        object Button6: TButton
          Left = 87
          Top = 112
          Width = 70
          Height = 21
          Action = actDelete
          TabOrder = 1
        end
        object Button7: TButton
          Left = 164
          Top = 112
          Width = 70
          Height = 21
          Action = actClear
          TabOrder = 2
        end
        object Button8: TButton
          Left = 241
          Top = 112
          Width = 70
          Height = 21
          Action = actExport
          TabOrder = 3
        end
        object lvImages: TListView
          Left = 10
          Top = 20
          Width = 302
          Height = 82
          Columns = <>
          ColumnClick = False
          HideSelection = False
          IconOptions.AutoArrange = True
          IconOptions.WrapText = False
          LargeImages = IL
          ReadOnly = True
          TabOrder = 4
          OnChange = lvImagesChange
        end
      end
    end
    object Panel4: TPanel
      Left = 333
      Top = 10
      Width = 90
      Height = 231
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 1
      object Button1: TButton
        Left = 14
        Top = 8
        Width = 75
        Height = 25
        Caption = 'OK'
        Default = True
        ModalResult = 1
        TabOrder = 0
      end
      object Button2: TButton
        Left = 14
        Top = 40
        Width = 75
        Height = 25
        Caption = 'Отмена'
        ModalResult = 2
        TabOrder = 1
      end
      object Button3: TButton
        Left = 14
        Top = 72
        Width = 75
        Height = 25
        Caption = 'Применить'
        TabOrder = 2
        OnClick = Button3Click
      end
    end
  end
  object OPD: TOpenPictureDialog
    DefaultExt = '*.bmp'
    Options = [ofAllowMultiSelect, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Left = 376
    Top = 144
  end
  object SPD: TSavePictureDialog
    DefaultExt = '*.bmp'
    Options = [ofOverwritePrompt, ofPathMustExist, ofEnableSizing]
    Left = 344
    Top = 144
  end
  object IL: TImageList
    Left = 344
    Top = 184
  end
  object ActionList1: TActionList
    Left = 400
    Top = 192
    object actAdd: TAction
      Caption = 'Добавить'
      ShortCut = 45
      OnExecute = actAddExecute
    end
    object actDelete: TAction
      Caption = 'Удалить'
      ShortCut = 46
      OnExecute = actDeleteExecute
      OnUpdate = actDeleteUpdate
    end
    object actClear: TAction
      Caption = 'Очистить'
      OnExecute = actClearExecute
      OnUpdate = actClearUpdate
    end
    object actExport: TAction
      Caption = 'Экспорт'
      OnExecute = actExportExecute
      OnUpdate = actClearUpdate
    end
  end
end
