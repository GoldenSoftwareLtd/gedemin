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
    object pnlLoad: TPanel
      Left = 0
      Top = 0
      Width = 727
      Height = 244
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 2
      object gbLoad: TGroupBox
        Left = 11
        Top = 8
        Width = 708
        Height = 233
        Caption = ' Загрузка объектов в БД '
        TabOrder = 0
        object lLoadRecords: TLabel
          Left = 11
          Top = 21
          Width = 25
          Height = 13
          Caption = 'lLoad'
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
        object mLoadList: TMemo
          Left = 10
          Top = 98
          Width = 687
          Height = 123
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
      Action = actOk
      Default = True
      TabOrder = 0
    end
    object btnCancel: TButton
      Left = 643
      Top = 484
      Width = 75
      Height = 21
      Caption = 'Отмена'
      ModalResult = 2
      TabOrder = 1
    end
    object gbSave: TGroupBox
      Left = 11
      Top = 245
      Width = 708
      Height = 233
      Caption = ' Сохранение объектов на диске '
      TabOrder = 3
      object Label3: TLabel
        Left = 12
        Top = 65
        Width = 239
        Height = 13
        Caption = 'Список пространств имен для записи в файлы:'
      end
      object lSaveRecords: TLabel
        Left = 11
        Top = 22
        Width = 26
        Height = 13
        Caption = 'lSave'
      end
      object mSaveList: TMemo
        Left = 10
        Top = 83
        Width = 687
        Height = 140
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 1
      end
      object chbxIncVersion: TCheckBox
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
  object ActionList: TActionList
    Left = 467
    Top = 184
    object actOk: TAction
      Caption = 'Ok'
      OnExecute = actOkExecute
      OnUpdate = actOkUpdate
    end
  end
end
