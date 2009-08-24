object dlgStreamSaverOptions: TdlgStreamSaverOptions
  Left = 379
  Top = 130
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsDialog
  Caption = 'Опции переноса данных'
  ClientHeight = 450
  ClientWidth = 386
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pcMain: TPageControl
    Left = 0
    Top = 0
    Width = 386
    Height = 409
    ActivePage = tbsMain
    Align = alClient
    TabOrder = 0
    object tbsMain: TTabSheet
      Caption = 'Основные'
      object gbUseNewStream: TGroupBox
        Left = 5
        Top = 2
        Width = 369
        Height = 64
        Caption = ' Использовать новый метод сохранения '
        TabOrder = 0
        object chbxUseNewStream: TCheckBox
          Left = 10
          Top = 16
          Width = 87
          Height = 17
          Caption = 'для файлов'
          TabOrder = 0
        end
        object chbxUseNewStreamForSetting: TCheckBox
          Left = 10
          Top = 38
          Width = 95
          Height = 17
          Caption = 'для настроек'
          TabOrder = 1
        end
      end
      object rgReplaceRecordBehaviuor: TRadioGroup
        Left = 5
        Top = 223
        Width = 369
        Height = 78
        Caption = ' При загрузке существующей записи '
        Items.Strings = (
          'перезаписывать новой'
          'оставлять существующую запись'
          'выводить диалог сравнения записей')
        TabOrder = 1
        Visible = False
      end
      object rgLogType: TRadioGroup
        Left = 5
        Top = 134
        Width = 369
        Height = 78
        Caption = ' Лог-файл '
        Items.Strings = (
          'не вести лог'
          'кратко'
          'подробно')
        TabOrder = 2
      end
      object rgStreamType: TRadioGroup
        Left = 5
        Top = 69
        Width = 181
        Height = 61
        Caption = ' Формат файлов '
        Items.Strings = (
          'двоичный'
          'XML')
        TabOrder = 3
      end
      object rgSettingStreamType: TRadioGroup
        Left = 193
        Top = 69
        Width = 181
        Height = 61
        Caption = ' Формат настроек '
        Items.Strings = (
          'двоичный'
          'XML')
        TabOrder = 4
      end
    end
    object tbsIncrement: TTabSheet
      Caption = 'Инкрементное сохранение'
      ImageIndex = 1
      object lblUseIncrementSaving: TLabel
        Left = 8
        Top = 330
        Width = 361
        Height = 42
        AutoSize = False
        Caption = 
          'ЗАМЕЧАНИЕ: При использовании инкрементного сохранения, будут сох' +
          'ранятся только те данные, которые отсутствуют на целевой базе да' +
          'нных.'
        WordWrap = True
      end
      object gbBaseList: TGroupBox
        Left = 5
        Top = 34
        Width = 369
        Height = 255
        Caption = ' Базы данных для инкрементных файлов '
        TabOrder = 0
        object pnlSSDatabases: TPanel
          Left = 9
          Top = 18
          Width = 351
          Height = 151
          BevelOuter = bvLowered
          TabOrder = 0
        end
        object btnCreateDatabaseFile: TButton
          Left = 15
          Top = 217
          Width = 217
          Height = 25
          Action = actCreateDatabaseFile
          TabOrder = 1
        end
        object btnClearRPLRecords: TButton
          Left = 15
          Top = 181
          Width = 217
          Height = 25
          Action = actClearRPLRecords
          TabOrder = 2
        end
      end
      object chbxUseIncrementSaving: TCheckBox
        Left = 15
        Top = 10
        Width = 306
        Height = 17
        Caption = 'Использовать инкрементное сохранение данных'
        TabOrder = 1
        OnClick = chbxUseIncrementSavingClick
      end
    end
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 409
    Width = 386
    Height = 41
    Align = alBottom
    TabOrder = 1
    object btnOK: TButton
      Left = 208
      Top = 8
      Width = 75
      Height = 25
      Action = actOK
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object btnCancel: TButton
      Left = 304
      Top = 8
      Width = 75
      Height = 25
      Action = actCancel
      Cancel = True
      ModalResult = 2
      TabOrder = 1
    end
  end
  object ActionList1: TActionList
    Left = 4
    Top = 416
    object actClearRPLRecords: TAction
      Caption = 'Очистить таблицу переданных записей'
      OnExecute = actClearRPLRecordsExecute
    end
    object actOK: TAction
      Caption = 'ОК'
      OnExecute = actOKExecute
      OnUpdate = actOKUpdate
    end
    object actCancel: TAction
      Caption = 'Отмена'
      OnExecute = actCancelExecute
    end
    object actCreateDatabaseFile: TAction
      Caption = 'Сформировать файл со списком баз'
    end
  end
end
