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
  Font.Name = 'MS Sans Serif'
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
        Width = 60
        Height = 13
        Caption = 'Имя файла:'
      end
      object Label7: TLabel
        Left = 3
        Top = 79
        Width = 135
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
      object Label2: TLabel
        Left = 8
        Top = 8
        Width = 67
        Height = 13
        Caption = 'Тип объекта:'
      end
      object Label3: TLabel
        Left = 8
        Top = 88
        Width = 41
        Height = 13
        Caption = 'Объект:'
      end
      object Label6: TLabel
        Left = 8
        Top = 48
        Width = 85
        Height = 13
        Caption = 'Подтип объекта:'
      end
      object cbClasses: TComboBox
        Left = 8
        Top = 24
        Width = 273
        Height = 21
        Style = csDropDownList
        DropDownCount = 24
        ItemHeight = 0
        Sorted = True
        TabOrder = 0
        OnChange = cbClassesChange
      end
      object iblkupObject: TgsIBLookupComboBox
        Left = 8
        Top = 104
        Width = 273
        Height = 21
        HelpContext = 1
        DropDownCount = 24
        ItemHeight = 0
        TabOrder = 2
        OnEnter = iblkupObjectEnter
      end
      object cbSubTypes: TComboBox
        Left = 8
        Top = 64
        Width = 273
        Height = 21
        Style = csDropDownList
        DropDownCount = 24
        ItemHeight = 0
        Sorted = True
        TabOrder = 1
        OnChange = cbSubTypesChange
      end
      object chbxClassFirst: TCheckBox
        Left = 157
        Top = 7
        Width = 123
        Height = 17
        Alignment = taLeftJustify
        Caption = 'Сначала имя класса'
        Checked = True
        State = cbChecked
        TabOrder = 3
        OnClick = chbxClassFirstClick
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
