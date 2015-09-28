inherited gdc_dlgDocumentType: Tgdc_dlgDocumentType
  Left = 686
  Top = 293
  Caption = 'Документ'
  ClientHeight = 423
  ClientWidth = 532
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 4
    Top = 399
    TabOrder = 3
  end
  inherited btnNew: TButton
    Left = 76
    Top = 399
    TabOrder = 4
  end
  inherited btnHelp: TButton
    Left = 148
    Top = 399
    TabOrder = 5
  end
  inherited btnOK: TButton
    Left = 388
    Top = 399
    TabOrder = 1
  end
  inherited btnCancel: TButton
    Left = 460
    Top = 399
    TabOrder = 2
  end
  object pcMain: TPageControl [5]
    Left = 4
    Top = 4
    Width = 524
    Height = 392
    ActivePage = tsCommon
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object tsCommon: TTabSheet
      Caption = 'Общие'
      object lblDocumentName: TLabel
        Left = 8
        Top = 10
        Width = 135
        Height = 13
        Caption = 'Наименование документа:'
        FocusControl = edDocumentName
      end
      object lblComment: TLabel
        Left = 8
        Top = 56
        Width = 71
        Height = 13
        Caption = 'Комментарий:'
        FocusControl = edDescription
      end
      object Label7: TLabel
        Left = 8
        Top = 146
        Width = 144
        Height = 13
        Caption = 'Ветка для команды вызова:'
        FocusControl = iblcExplorerBranch
      end
      object Label1: TLabel
        Left = 8
        Top = 169
        Width = 139
        Height = 13
        Caption = 'Таблица шапки документа:'
        FocusControl = iblcHeaderTable
      end
      object Label2: TLabel
        Left = 8
        Top = 191
        Width = 148
        Height = 13
        Caption = 'Таблица позиции документа:'
        FocusControl = iblcLineTable
      end
      object Label3: TLabel
        Left = 8
        Top = 123
        Width = 122
        Height = 13
        Caption = 'Наименование на англ.:'
        FocusControl = edEnglishName
        WordWrap = True
      end
      object lFunction: TLabel
        Left = 8
        Top = 214
        Width = 100
        Height = 13
        Caption = 'Функция ТО шапки:'
        WordWrap = True
      end
      object Label4: TLabel
        Left = 8
        Top = 237
        Width = 109
        Height = 13
        Caption = 'Функция ТО позиции:'
        WordWrap = True
      end
      object lblParent: TLabel
        Left = 8
        Top = 34
        Width = 80
        Height = 13
        Caption = 'Наследован от:'
      end
      object edDocumentName: TDBEdit
        Left = 157
        Top = 7
        Width = 352
        Height = 21
        Color = clBtnFace
        DataField = 'NAME'
        DataSource = dsgdcBase
        Enabled = False
        TabOrder = 0
      end
      object edDescription: TDBMemo
        Left = 157
        Top = 53
        Width = 352
        Height = 64
        Color = clBtnFace
        DataField = 'DESCRIPTION'
        DataSource = dsgdcBase
        Enabled = False
        TabOrder = 2
      end
      object iblcExplorerBranch: TgsIBLookupComboBox
        Left = 157
        Top = 142
        Width = 352
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = ibtrCommon
        ListTable = 'GD_COMMAND'
        ListField = 'NAME'
        KeyField = 'ID'
        Condition = '(Classname IS NULL) or (ClassName = '#39#39')'
        gdClassName = 'TgdcExplorer'
        ViewType = vtTree
        Color = clBtnFace
        Enabled = False
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 4
      end
      object iblcHeaderTable: TgsIBLookupComboBox
        Left = 157
        Top = 165
        Width = 352
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = ibtrCommon
        DataSource = dsgdcBase
        DataField = 'HEADERRELKEY'
        Fields = 'relationname'
        ListTable = 'AT_RELATIONS'
        ListField = 'LNAME'
        KeyField = 'ID'
        gdClassName = 'TgdcDocumentTable'
        OnCreateNewObject = iblcHeaderTableCreateNewObject
        Color = clBtnFace
        Enabled = False
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 5
        OnChange = iblcHeaderTableChange
      end
      object iblcLineTable: TgsIBLookupComboBox
        Left = 157
        Top = 188
        Width = 352
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = ibtrCommon
        DataSource = dsgdcBase
        DataField = 'LINERELKEY'
        Fields = 'relationname'
        ListTable = 'AT_RELATIONS'
        ListField = 'LNAME'
        KeyField = 'ID'
        gdClassName = 'TgdcDocumentLineTable'
        OnCreateNewObject = iblcLineTableCreateNewObject
        Color = clBtnFace
        Enabled = False
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 6
      end
      object edEnglishName: TEdit
        Left = 157
        Top = 119
        Width = 352
        Height = 21
        CharCase = ecUpperCase
        Color = clBtnFace
        Enabled = False
        TabOrder = 3
        OnExit = edEnglishNameExit
      end
      object dbcbIsCommon: TDBCheckBox
        Left = 6
        Top = 257
        Width = 163
        Height = 17
        Alignment = taLeftJustify
        Caption = 'Общий документ:'
        DataField = 'iscommon'
        DataSource = dsgdcBase
        TabOrder = 13
        ValueChecked = '1'
        ValueUnchecked = '0'
      end
      object dbeFunctionName: TDBEdit
        Left = 157
        Top = 211
        Width = 188
        Height = 21
        Color = clBtnFace
        DataField = 'NAME'
        DataSource = dsFunction
        ReadOnly = True
        TabOrder = 7
      end
      object btnConstr1: TButton
        Left = 348
        Top = 211
        Width = 79
        Height = 21
        Action = actWizardHeader
        TabOrder = 8
      end
      object DBEdit1: TDBEdit
        Left = 157
        Top = 234
        Width = 188
        Height = 21
        Color = clBtnFace
        DataField = 'NAME'
        DataSource = DataSource1
        ReadOnly = True
        TabOrder = 10
      end
      object btnConstr2: TButton
        Left = 348
        Top = 234
        Width = 79
        Height = 21
        Action = actWizardLine
        TabOrder = 11
      end
      object btnDel1: TButton
        Left = 429
        Top = 211
        Width = 79
        Height = 21
        Action = actDeleteHeaderFunction
        TabOrder = 9
      end
      object btnDel2: TButton
        Left = 429
        Top = 234
        Width = 79
        Height = 21
        Action = actDeleteLineFunction
        TabOrder = 12
      end
      object edParentName: TEdit
        Left = 157
        Top = 30
        Width = 352
        Height = 21
        ParentColor = True
        ReadOnly = True
        TabOrder = 1
        Text = 'edParentName'
      end
    end
    object tsNumerator: TTabSheet
      Caption = 'Нумерация'
      ImageIndex = 1
      object lblNumCompany: TLabel
        Left = 6
        Top = 6
        Width = 505
        Height = 28
        AutoSize = False
        Color = clInfoBk
        ParentColor = False
        WordWrap = True
      end
      object gbNumber: TGroupBox
        Left = 5
        Top = 220
        Width = 506
        Height = 42
        TabOrder = 2
        object lblCurrentNumber: TLabel
          Left = 8
          Top = 16
          Width = 140
          Height = 13
          Caption = 'Текущий номер документа:'
          FocusControl = edCurrentNumber
        end
        object lblIncrement: TLabel
          Left = 278
          Top = 16
          Width = 107
          Height = 13
          Caption = 'Прирост для номера:'
          FocusControl = dbeIncrement
        end
        object edCurrentNumber: TDBEdit
          Left = 160
          Top = 13
          Width = 101
          Height = 21
          DataField = 'LASTNUMBER'
          DataSource = dsgdcBase
          TabOrder = 0
          OnExit = edCurrentNumberExit
        end
        object dbeIncrement: TDBEdit
          Left = 402
          Top = 13
          Width = 94
          Height = 21
          DataField = 'ADDNUMBER'
          DataSource = dsgdcBase
          TabOrder = 1
          OnExit = dbeIncrementExit
        end
      end
      object gbMask: TGroupBox
        Left = 5
        Top = 59
        Width = 506
        Height = 157
        TabOrder = 1
        object lblMask: TLabel
          Left = 8
          Top = 15
          Width = 231
          Height = 13
          Caption = 'Маска для формирования номера документа:'
          FocusControl = dbcMask
        end
        object lblExample: TLabel
          Left = 8
          Top = 60
          Width = 198
          Height = 13
          Caption = 'Образец, как будет выглядеть номер:'
          FocusControl = edExample
        end
        object Label5: TLabel
          Left = 8
          Top = 104
          Width = 156
          Height = 13
          Caption = 'Фиксированная длина номера:'
          FocusControl = edFixLength
        end
        object lvVariable: TListView
          Left = 286
          Top = 15
          Width = 211
          Height = 131
          Columns = <
            item
              AutoSize = True
              Caption = 'Переменные'
            end>
          HideSelection = False
          Items.Data = {
            180100000700000000000000FFFFFFFFFFFFFFFF00000000000000000E4E554D
            424552202D20EDEEECE5F000000000FFFFFFFFFFFFFFFF00000000000000000A
            444159202D20E4E5EDFC00000000FFFFFFFFFFFFFFFF0000000000000000134D
            4F4E5448202D20ECE5F1FFF620F7E8F1EBEE00000000FFFFFFFFFFFFFFFF0000
            000000000000174D4F4E5448535452202D20ECE5F1FFF620F1F2F0EEEAE00000
            0000FFFFFFFFFFFFFFFF00000000000000000A59454152202D20E3EEE4000000
            00FFFFFFFFFFFFFFFF00000000000000001355534552202D20EFEEEBFCE7EEE2
            E0F2E5EBFC00000000FFFFFFFFFFFFFFFF00000000000000001E434F4D505554
            4552202D20EDE0E7E2E0EDE8E520EAEEECEFFCFEF2E5F0E0}
          ReadOnly = True
          TabOrder = 2
          ViewStyle = vsReport
          OnDblClick = lvVariableDblClick
        end
        object dbcMask: TDBComboBox
          Left = 8
          Top = 31
          Width = 267
          Height = 21
          DataField = 'MASK'
          DataSource = dsgdcBase
          ItemHeight = 13
          TabOrder = 0
          OnChange = dbcMaskChange
        end
        object edExample: TEdit
          Left = 8
          Top = 76
          Width = 267
          Height = 21
          TabStop = False
          ParentColor = True
          ReadOnly = True
          TabOrder = 1
        end
        object edFixLength: TDBEdit
          Left = 178
          Top = 102
          Width = 97
          Height = 21
          DataField = 'fixlength'
          DataSource = dsgdcBase
          TabOrder = 3
          OnChange = edFixLengthChange
        end
      end
      object Memo1: TMemo
        Left = 3
        Top = 329
        Width = 506
        Height = 30
        TabStop = False
        BorderStyle = bsNone
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clBtnText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        Lines.Strings = (
          
            'Изменение номера рекомендуется производить только в монопольном ' +
            'режиме работы, когда '
          'другие пользователи не подключены к базе данных.')
        ParentColor = True
        ParentFont = False
        ReadOnly = True
        TabOrder = 4
      end
      object chbxAutoNumeration: TCheckBox
        Left = 8
        Top = 40
        Width = 409
        Height = 17
        Action = actAutoNumeration
        TabOrder = 0
      end
      object dbrgIsCheckNumber: TDBRadioGroup
        Left = 5
        Top = 266
        Width = 506
        Height = 57
        Caption = ' Контролировать уникальность номера документа  '
        Columns = 2
        DataField = 'ISCHECKNUMBER'
        DataSource = dsgdcBase
        Items.Strings = (
          'Не контролировать'
          'Для всех документов'
          'В пределах года'
          'В пределах месяца')
        TabOrder = 3
        Values.Strings = (
          '0'
          '1'
          '2'
          '3')
      end
    end
  end
  inherited alBase: TActionList
    Left = 456
    Top = 72
    object actWizardHeader: TAction
      Caption = 'Конструктор'
      OnExecute = actWizardHeaderExecute
      OnUpdate = actWizardHeaderUpdate
    end
    object actCreateEvent: TAction
      Category = 'Events'
      Caption = 'Создать'
    end
    object actModifyEvent: TAction
      Category = 'Events'
      Caption = 'Изменить'
    end
    object actDeleteEvent: TAction
      Category = 'Events'
      Caption = 'Удалить'
    end
    object actWizardLine: TAction
      Caption = 'Конструктор'
      OnExecute = actWizardHeaderExecute
      OnUpdate = actWizardLineUpdate
    end
    object actDeleteHeaderFunction: TAction
      Caption = 'Удалить'
      ImageIndex = 117
      OnExecute = actDeleteHeaderFunctionExecute
      OnUpdate = actDeleteHeaderFunctionUpdate
    end
    object actDeleteLineFunction: TAction
      Caption = 'Удалить'
      ImageIndex = 117
      OnExecute = actDeleteLineFunctionExecute
      OnUpdate = actDeleteLineFunctionUpdate
    end
    object actAutoNumeration: TAction
      Caption = 'Не использовать автоматическое формирование номера документа.'
      OnExecute = actAutoNumerationExecute
    end
  end
  inherited dsgdcBase: TDataSource
    Left = 536
    Top = 176
  end
  inherited pm_dlgG: TPopupMenu
    Left = 16
    Top = 376
  end
  inherited ibtrCommon: TIBTransaction
    Left = 56
    Top = 376
  end
  object gdcFunctionHeader: TgdcFunction
    MasterSource = dsgdcBase
    MasterField = 'HEADERFUNCTIONKEY'
    DetailField = 'ID'
    SubSet = 'ByID'
    Left = 408
    Top = 16
  end
  object dsFunction: TDataSource
    DataSet = gdcFunctionHeader
    Left = 376
    Top = 16
  end
  object gdcFunctionLine: TgdcFunction
    MasterSource = dsgdcBase
    MasterField = 'LINEFUNCTIONKEY'
    DetailField = 'ID'
    SubSet = 'ByID'
    Left = 408
    Top = 48
  end
  object DataSource1: TDataSource
    DataSet = gdcFunctionLine
    Left = 376
    Top = 48
  end
end
