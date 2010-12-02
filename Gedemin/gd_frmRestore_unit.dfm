inherited gd_frmRestore: Tgd_frmRestore
  Left = 427
  Top = 304
  HelpContext = 29
  Caption = 'Восстановление базы данных из архива'
  PixelsPerInch = 96
  TextHeight = 13
  inherited Label3: TLabel
    Top = 8
  end
  inherited Label1: TLabel
    Top = 215
  end
  inherited lblServer: TLabel
    Left = 6
    Top = 88
  end
  inherited Label4: TLabel
    Left = 6
    Top = 111
  end
  object Label5: TLabel [4]
    Left = 6
    Top = 135
    Width = 91
    Height = 13
    Caption = 'Размер страницы:'
  end
  object Label6: TLabel [5]
    Left = 160
    Top = 135
    Width = 126
    Height = 13
    Caption = 'байт.      Размер буфера:'
  end
  object Label7: TLabel [6]
    Left = 344
    Top = 135
    Width = 45
    Height = 13
    Caption = 'страниц.'
  end
  inherited dbgrBackupFiles: TDBGrid
    Top = 24
    Height = 55
    TabOrder = 0
  end
  inherited mProgress: TMemo
    Top = 232
    Height = 128
    TabOrder = 20
  end
  inherited btnDoIt: TButton
    TabOrder = 16
  end
  inherited btnClose: TButton
    TabOrder = 17
  end
  inherited btnHelp: TButton
    TabOrder = 18
  end
  inherited chbxVerbose: TCheckBox
    Left = 154
    Top = 214
    Width = 271
    Caption = 'Подробная информация о ходе восстановления:'
    TabOrder = 15
  end
  inherited edServer: TEdit
    Top = 82
    TabOrder = 2
  end
  inherited edDatabase: TEdit
    Top = 106
    TabOrder = 3
  end
  inherited chbxDeleteTemp: TCheckBox
    Left = 252
    Width = 173
    Enabled = False
    TabOrder = 19
    Visible = False
  end
  object edPageBuffers: TEdit [16]
    Left = 288
    Top = 130
    Width = 49
    Height = 21
    TabOrder = 6
    Text = '8192'
  end
  inherited btnSelectDatabase: TButton
    Top = 106
    TabOrder = 4
  end
  inherited btnSelectArchive: TButton
    Top = 24
    TabOrder = 1
  end
  object chbxOneRelationAtATime: TCheckBox [19]
    Left = 241
    Top = 167
    Width = 184
    Height = 17
    Alignment = taLeftJustify
    Caption = 'Commit после каждой таблицы:'
    TabOrder = 12
  end
  object chbxGenDBID: TCheckBox [20]
    Left = 4
    Top = 167
    Width = 200
    Height = 17
    Alignment = taLeftJustify
    Caption = 'Присваивать уникальный ИД базы:'
    Checked = True
    State = cbChecked
    TabOrder = 8
  end
  object chbxOverwrite: TCheckBox [21]
    Left = 4
    Top = 183
    Width = 200
    Height = 17
    Alignment = taLeftJustify
    Caption = 'Перезаписывать файл базы дан.:'
    TabOrder = 9
  end
  object edPageSize: TComboBox [22]
    Left = 104
    Top = 130
    Width = 54
    Height = 21
    ItemHeight = 13
    TabOrder = 5
    Text = '8192'
    Items.Strings = (
      '1024'
      '2048'
      '4096'
      '8192'
      '16384')
  end
  object chbxForcedWrites: TCheckBox [23]
    Left = 4
    Top = 151
    Width = 200
    Height = 17
    Alignment = taLeftJustify
    Caption = 'Включить принудительную запись:'
    Checked = True
    State = cbChecked
    TabOrder = 7
  end
  object chbxRestrTree: TCheckBox [24]
    Left = 208
    Top = 151
    Width = 217
    Height = 17
    Alignment = taLeftJustify
    Caption = 'Перестроить интервальные деревья:'
    TabOrder = 11
  end
  object chbxUseAllSpace: TCheckBox [25]
    Left = 4
    Top = 199
    Width = 200
    Height = 17
    Alignment = taLeftJustify
    Caption = 'Заполнять всю страницу:'
    TabOrder = 10
  end
  inherited chbxShutDown: TCheckBox
    Top = 198
    TabOrder = 14
  end
  object chbxRecompileProcedures: TCheckBox [27]
    Left = 234
    Top = 183
    Width = 191
    Height = 17
    Alignment = taLeftJustify
    Caption = 'Перекомпилировать процедуры:'
    TabOrder = 13
  end
  inherited cdsBackupFiles: TClientDataSet
    inherited fldFileName: TStringField
      DisplayWidth = 65
    end
    inherited fldFileSize: TIntegerField
      Visible = False
    end
  end
  inherited ActionList: TActionList
    inherited actDoIt: TAction
      Caption = 'Выполнить'
      OnExecute = actDoItExecute
    end
  end
  inherited ibdb: TIBDatabase
    Left = 208
    Top = 8
  end
  inherited ibtr: TIBTransaction
    Left = 240
    Top = 8
  end
  object IBRestoreService: TIBRestoreService [33]
    Protocol = TCP
    LoginPrompt = False
    TraceFlags = []
    BufferSize = 8192
    PageSize = 0
    PageBuffers = 0
    Options = [NoValidityCheck, CreateNewDB]
    Left = 320
    Top = 48
  end
  inherited q: TIBSQL
    Left = 272
    Top = 8
  end
  inherited od: TOpenDialog
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofEnableSizing]
  end
  inherited sd: TSaveDialog
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
  end
  object IBConfigService: TIBConfigService
    LoginPrompt = False
    TraceFlags = []
    Left = 440
    Top = 256
  end
end
