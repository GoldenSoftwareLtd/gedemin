object dlgCheckOperation: TdlgCheckOperation
  Left = 500
  Top = 224
  BorderStyle = bsDialog
  Caption = 'Синхронизация пространств имен'
  ClientHeight = 512
  ClientWidth = 727
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object pnlWorkArea: TPanel
    Left = 0
    Top = 0
    Width = 727
    Height = 512
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object Panel2: TPanel
      Left = 0
      Top = 0
      Width = 727
      Height = 244
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      object GroupBox1: TGroupBox
        Left = 11
        Top = 8
        Width = 708
        Height = 233
        Caption = ' Загрузка объектов в БД '
        TabOrder = 0
        object lLoadRecords: TLabel
          Left = 11
          Top = 21
          Width = 283
          Height = 13
          Caption = 'Выбрано для загрузки файлов, включая зависимые: ХХ'
        end
        object Label1: TLabel
          Left = 12
          Top = 80
          Width = 151
          Height = 13
          Caption = 'Список файлов для загрузки:'
        end
        object cbAlwaysOverwrite: TCheckBox
          Left = 11
          Top = 39
          Width = 161
          Height = 17
          Caption = 'Всегда перезаписывать'
          TabOrder = 0
        end
        object cbDontRemove: TCheckBox
          Left = 11
          Top = 57
          Width = 422
          Height = 17
          Caption = 'Не удалять объекты, отсутствующие в загружаемом файле'
          TabOrder = 1
        end
        object Memo1: TMemo
          Left = 10
          Top = 98
          Width = 687
          Height = 123
          Lines.Strings = (
            'Memo1')
          ReadOnly = True
          ScrollBars = ssVertical
          TabOrder = 2
        end
      end
    end
    object btnOK: TButton
      Left = 562
      Top = 484
      Width = 75
      Height = 21
      Caption = 'ОК'
      Default = True
      ModalResult = 1
      TabOrder = 2
    end
    object btnCancel: TButton
      Left = 643
      Top = 484
      Width = 75
      Height = 21
      Caption = 'Отмена'
      ModalResult = 2
      TabOrder = 3
    end
    object GroupBox2: TGroupBox
      Left = 11
      Top = 245
      Width = 708
      Height = 233
      Caption = ' Сохранение объектов на диске '
      TabOrder = 1
      object Label3: TLabel
        Left = 12
        Top = 65
        Width = 218
        Height = 13
        Caption = 'Список пространств имен для сохранения:'
      end
      object lSaveRecords: TLabel
        Left = 11
        Top = 22
        Width = 350
        Height = 13
        Caption = 'Выбрано для сохранения пространств имен, включая зависимые: ХХ'
      end
      object Memo2: TMemo
        Left = 10
        Top = 83
        Width = 687
        Height = 140
        Lines.Strings = (
          'Memo1')
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 1
      end
      object cbIncVersion: TCheckBox
        Left = 11
        Top = 42
        Width = 169
        Height = 17
        Caption = 'Увеличить номер версии'
        Checked = True
        State = cbChecked
        TabOrder = 0
      end
    end
  end
end
