object gd_dlgAddLinked: Tgd_dlgAddLinked
  Left = 413
  Top = 353
  BorderStyle = bsDialog
  Caption = 'Прикрепленный объект'
  ClientHeight = 292
  ClientWidth = 310
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label4: TLabel
    Left = 8
    Top = 176
    Width = 116
    Height = 13
    Caption = 'Имя для отображения:'
  end
  object Label5: TLabel
    Left = 8
    Top = 216
    Width = 120
    Height = 13
    Caption = 'Пользовательский тип:'
  end
  object btnOk: TButton
    Left = 147
    Top = 264
    Width = 75
    Height = 21
    Action = actOk
    Default = True
    TabOrder = 4
  end
  object btnCancel: TButton
    Left = 227
    Top = 264
    Width = 75
    Height = 21
    Action = actCancel
    Cancel = True
    TabOrder = 5
  end
  object btnHelp: TButton
    Left = 8
    Top = 264
    Width = 75
    Height = 21
    Action = actHelp
    TabOrder = 6
  end
  object pc: TPageControl
    Left = 8
    Top = 8
    Width = 296
    Height = 161
    ActivePage = tsFile
    TabOrder = 0
    object tsFile: TTabSheet
      Caption = 'Файл'
      object Label1: TLabel
        Left = 3
        Top = 8
        Width = 58
        Height = 13
        Caption = 'Имя файла:'
      end
      object Label7: TLabel
        Left = 3
        Top = 79
        Width = 133
        Height = 13
        Caption = 'Разместить файл в папке:'
      end
      object edFileName: TEdit
        Left = 3
        Top = 24
        Width = 265
        Height = 21
        TabOrder = 0
      end
      object Button4: TButton
        Left = 268
        Top = 24
        Width = 19
        Height = 21
        Action = actBrowse
        TabOrder = 1
      end
      object Button5: TButton
        Left = 3
        Top = 48
        Width = 75
        Height = 21
        Action = actViewFile
        TabOrder = 2
      end
      object iblkupFolder: TgsIBLookupComboBox
        Left = 3
        Top = 96
        Width = 264
        Height = 21
        HelpContext = 1
        ListTable = 'gd_file'
        ListField = 'name'
        KeyField = 'ID'
        Condition = 'filetype = '#39'D'#39
        gdClassName = 'TgdcFileFolder'
        DropDownCount = 24
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 3
      end
    end
    object tsObject: TTabSheet
      Caption = 'Объект'
      ImageIndex = 1
      object Label3: TLabel
        Left = 8
        Top = 86
        Width = 43
        Height = 13
        Caption = 'Объект:'
      end
      object iblkupObject: TgsIBLookupComboBox
        Left = 8
        Top = 102
        Width = 273
        Height = 21
        HelpContext = 1
        DropDownCount = 24
        Enabled = False
        ItemHeight = 13
        TabOrder = 1
      end
      object gbClass: TGroupBox
        Left = 8
        Top = 6
        Width = 272
        Height = 71
        Caption = ' Тип объекта '
        TabOrder = 0
        object lblClass: TLabel
          Left = 10
          Top = 20
          Width = 131
          Height = 13
          Caption = 'Выберите бизнес-класс...'
        end
        object Button1: TButton
          Left = 8
          Top = 42
          Width = 75
          Height = 21
          Action = actSelectClass
          TabOrder = 0
        end
      end
    end
  end
  object edLinkedName: TEdit
    Left = 8
    Top = 192
    Width = 207
    Height = 21
    TabOrder = 1
  end
  object edUserType: TEdit
    Left = 8
    Top = 232
    Width = 295
    Height = 21
    TabOrder = 3
  end
  object Button6: TButton
    Left = 214
    Top = 192
    Width = 89
    Height = 21
    Action = actCreateName
    TabOrder = 2
  end
  object ActionList1: TActionList
    Left = 232
    Top = 88
    object actOk: TAction
      Caption = 'Ok'
      OnExecute = actOkExecute
      OnUpdate = actOkUpdate
    end
    object actCancel: TAction
      Caption = 'Отмена'
      OnExecute = actCancelExecute
    end
    object actHelp: TAction
      Caption = 'Справка'
    end
    object actBrowse: TAction
      Caption = '...'
      OnExecute = actBrowseExecute
    end
    object actViewFile: TAction
      Caption = 'Просмотр'
      OnExecute = actViewFileExecute
      OnUpdate = actViewFileUpdate
    end
    object actCreateName: TAction
      Caption = 'Сформировать'
      OnExecute = actCreateNameExecute
    end
    object actSelectClass: TAction
      Caption = 'Выбрать...'
      OnExecute = actSelectClassExecute
    end
  end
  object od: TOpenDialog
    Options = [ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Left = 156
    Top = 80
  end
  object ibtr: TIBTransaction
    Active = False
    DefaultAction = TACommit
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 240
    Top = 128
  end
end
