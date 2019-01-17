object gd_frmBackupRestore: Tgd_frmBackupRestore
  Left = 569
  Top = 268
  BorderStyle = bsDialog
  Caption = '<>'
  ClientHeight = 364
  ClientWidth = 512
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label3: TLabel
    Left = 6
    Top = 64
    Width = 92
    Height = 13
    Caption = 'Архивные файлы:'
  end
  object Label1: TLabel
    Left = 6
    Top = 199
    Width = 72
    Height = 13
    Caption = 'Ход процесса:'
  end
  object lblServer: TLabel
    Left = 8
    Top = 14
    Width = 41
    Height = 13
    Caption = 'Сервер:'
  end
  object Label4: TLabel
    Left = 8
    Top = 37
    Width = 69
    Height = 13
    Caption = 'База данных:'
  end
  object dbgrBackupFiles: TDBGrid
    Left = 5
    Top = 80
    Width = 396
    Height = 72
    DataSource = dsBackupFiles
    Options = [dgEditing, dgTitles, dgIndicator, dgColLines]
    TabOrder = 3
    TitleFont.Charset = RUSSIAN_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    OnExit = dbgrBackupFilesExit
  end
  object mProgress: TMemo
    Left = 4
    Top = 216
    Width = 421
    Height = 144
    TabStop = False
    Color = clBlack
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clLime
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 10
  end
  object btnDoIt: TButton
    Left = 433
    Top = 8
    Width = 75
    Height = 21
    Action = actDoIt
    Default = True
    TabOrder = 7
  end
  object btnClose: TButton
    Left = 433
    Top = 32
    Width = 75
    Height = 21
    Action = actClose
    Cancel = True
    TabOrder = 8
  end
  object btnHelp: TButton
    Left = 433
    Top = 80
    Width = 75
    Height = 21
    Action = actHelp
    TabOrder = 9
  end
  object chbxVerbose: TCheckBox
    Left = 160
    Top = 198
    Width = 265
    Height = 17
    Alignment = taLeftJustify
    Caption = '<> :'
    TabOrder = 6
  end
  object edServer: TEdit
    Left = 104
    Top = 8
    Width = 297
    Height = 21
    TabOrder = 0
  end
  object edDatabase: TEdit
    Left = 104
    Top = 32
    Width = 297
    Height = 21
    TabOrder = 1
  end
  object chbxDeleteTemp: TCheckBox
    Left = 248
    Top = 183
    Width = 177
    Height = 17
    Alignment = taLeftJustify
    Caption = 'Удалить временные данные:'
    Checked = True
    State = cbChecked
    TabOrder = 5
  end
  object btnSelectDatabase: TButton
    Left = 401
    Top = 32
    Width = 24
    Height = 20
    Action = actSelectDatabase
    TabOrder = 2
  end
  object btnSelectArchive: TButton
    Left = 401
    Top = 80
    Width = 24
    Height = 20
    Action = actSelectArchive
    TabOrder = 4
  end
  object chbxShutDown: TCheckBox
    Left = 205
    Top = 153
    Width = 220
    Height = 17
    Alignment = taLeftJustify
    Caption = 'Выключить компьютер по завершении:'
    TabOrder = 11
  end
  object dsBackupFiles: TDataSource
    DataSet = cdsBackupFiles
    Left = 312
    Top = 80
  end
  object cdsBackupFiles: TClientDataSet
    Active = True
    Aggregates = <>
    FieldDefs = <
      item
        Name = 'cdsBackupFilesField1'
        DataType = ftString
        Size = 200
      end
      item
        Name = 'cdsBackupFilesField2'
        DataType = ftInteger
      end>
    IndexDefs = <>
    Params = <>
    StoreDefs = True
    Left = 280
    Top = 80
    Data = {
      600000009619E0BD010000001800000002000000000003000000600014636473
      4261636B757046696C65734669656C6431010049000000010005574944544802
      000200C800146364734261636B757046696C65734669656C6432040001000000
      00000000}
    object fldFileName: TStringField
      CustomConstraint = 'x > '#39#39
      ConstraintErrorMessage = 'Укажите имя файла архива'
      DisplayLabel = 'Имя файла'
      DisplayWidth = 50
      FieldName = 'cdsBackupFilesField1'
      Size = 200
    end
    object fldFileSize: TIntegerField
      CustomConstraint = '(x is null) or (x >= 2048)'
      ConstraintErrorMessage = 'Размер фархивного файла должен превышать 2048 байт'
      DisplayLabel = 'Размер файла'
      DisplayWidth = 11
      FieldName = 'cdsBackupFilesField2'
    end
  end
  object ActionList: TActionList
    Left = 368
    Top = 80
    object actDoIt: TAction
      Caption = '<>'
      OnUpdate = actDoItUpdate
    end
    object actClose: TAction
      Caption = 'Закрыть'
      OnExecute = actCloseExecute
      OnUpdate = actCloseUpdate
    end
    object actHelp: TAction
      Caption = 'Справка'
      OnExecute = actHelpExecute
    end
    object actSelectDatabase: TAction
      Caption = '...'
      OnExecute = actSelectDatabaseExecute
      OnUpdate = actSelectDatabaseUpdate
    end
    object actSelectArchive: TAction
      Caption = '...'
      OnExecute = actSelectArchiveExecute
      OnUpdate = actSelectArchiveUpdate
    end
  end
  object ibdb: TIBDatabase
    LoginPrompt = False
    Left = 280
    Top = 128
  end
  object ibtr: TIBTransaction
    Active = False
    DefaultDatabase = ibdb
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 312
    Top = 128
  end
  object q: TIBSQL
    Database = ibdb
    Transaction = ibtr
    Left = 344
    Top = 128
  end
  object od: TOpenDialog
    DefaultExt = 'GDB'
    Filter = 'Файлы базы данных (*.gdb, *.fdb)|*.?db|Все файлы (*.*)|*.*'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Title = 'Файл базы данных'
    Left = 464
    Top = 144
  end
  object sd: TSaveDialog
    DefaultExt = 'BK'
    Filter = 'Архивные файлы (*.bk)|*.bk|Все файлы (*.*)|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Title = 'Архив базы данных'
    Left = 440
    Top = 120
  end
end
