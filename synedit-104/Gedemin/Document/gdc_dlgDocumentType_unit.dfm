inherited gdc_dlgDocumentType: Tgdc_dlgDocumentType
  Left = 74
  Top = 0
  Caption = 'Документ'
  ClientHeight = 423
  ClientWidth = 573
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 2
    Top = 398
    Anchors = [akLeft, akBottom]
    TabOrder = 3
  end
  inherited btnNew: TButton
    Left = 74
    Top = 398
    Anchors = [akLeft, akBottom]
    TabOrder = 4
  end
  inherited btnHelp: TButton
    Left = 146
    Top = 398
    Anchors = [akLeft, akBottom]
    TabOrder = 5
  end
  inherited btnOK: TButton
    Left = 430
    Top = 398
    Anchors = [akRight, akBottom]
    TabOrder = 1
  end
  inherited btnCancel: TButton
    Left = 502
    Top = 398
    Anchors = [akRight, akBottom]
    TabOrder = 2
  end
  object pcMain: TPageControl [5]
    Left = 0
    Top = 0
    Width = 573
    Height = 392
    ActivePage = tsCommon
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object tsCommon: TTabSheet
      Caption = 'Общие'
      object lblDocumentName: TLabel
        Left = 8
        Top = 7
        Width = 135
        Height = 13
        Caption = 'Наименование документа:'
        FocusControl = edDocumentName
      end
      object lblComment: TLabel
        Left = 8
        Top = 30
        Width = 71
        Height = 13
        Caption = 'Комментарий:'
        FocusControl = edDescription
      end
      object Label7: TLabel
        Left = 8
        Top = 123
        Width = 144
        Height = 13
        Caption = 'Ветка для команды вызова:'
        FocusControl = iblcExplorerBranch
      end
      object Label1: TLabel
        Left = 8
        Top = 146
        Width = 139
        Height = 13
        Caption = 'Таблица шапки документа:'
        FocusControl = iblcHeaderTable
      end
      object Label2: TLabel
        Left = 8
        Top = 169
        Width = 148
        Height = 13
        Caption = 'Таблица позиции документа:'
        FocusControl = iblcLineTable
      end
      object Label3: TLabel
        Left = 8
        Top = 92
        Width = 91
        Height = 26
        Caption = 'Наименование на английском:'
        FocusControl = edEnglishName
        WordWrap = True
      end
      object lFunction: TLabel
        Left = 8
        Top = 186
        Width = 144
        Height = 25
        AutoSize = False
        Caption = 'Функция типовой операции шапки документа:'
        WordWrap = True
      end
      object Label4: TLabel
        Left = 8
        Top = 211
        Width = 144
        Height = 25
        AutoSize = False
        Caption = 'Функция типовой операции позиции документа:'
        WordWrap = True
      end
      object edDocumentName: TDBEdit
        Left = 157
        Top = 7
        Width = 284
        Height = 21
        Color = clBtnFace
        DataField = 'NAME'
        DataSource = dsgdcBase
        Enabled = False
        TabOrder = 0
      end
      object edDescription: TDBMemo
        Left = 157
        Top = 30
        Width = 284
        Height = 64
        Color = clBtnFace
        DataField = 'DESCRIPTION'
        DataSource = dsgdcBase
        Enabled = False
        TabOrder = 1
      end
      object iblcExplorerBranch: TgsIBLookupComboBox
        Left = 157
        Top = 119
        Width = 284
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
        TabOrder = 3
      end
      object iblcHeaderTable: TgsIBLookupComboBox
        Left = 157
        Top = 142
        Width = 284
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
        TabOrder = 4
      end
      object iblcLineTable: TgsIBLookupComboBox
        Left = 157
        Top = 165
        Width = 284
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
        TabOrder = 5
      end
      object edEnglishName: TEdit
        Left = 157
        Top = 96
        Width = 284
        Height = 21
        CharCase = ecUpperCase
        Color = clBtnFace
        Enabled = False
        TabOrder = 2
        OnExit = edEnglishNameExit
      end
      object dbcbIsCommon: TDBCheckBox
        Left = 8
        Top = 256
        Width = 121
        Height = 17
        Caption = 'Общий документ'
        DataField = 'iscommon'
        DataSource = dsgdcBase
        TabOrder = 12
        ValueChecked = '1'
        ValueUnchecked = '0'
      end
      object dbeFunctionName: TDBEdit
        Left = 157
        Top = 188
        Width = 204
        Height = 21
        Color = clBtnFace
        DataField = 'NAME'
        DataSource = dsFunction
        ReadOnly = True
        TabOrder = 6
      end
      object Button1: TButton
        Left = 362
        Top = 188
        Width = 79
        Height = 21
        Action = actWizardHeader
        TabOrder = 7
      end
      object DBEdit1: TDBEdit
        Left = 157
        Top = 213
        Width = 204
        Height = 21
        Color = clBtnFace
        DataField = 'NAME'
        DataSource = DataSource1
        ReadOnly = True
        TabOrder = 9
      end
      object Button2: TButton
        Left = 362
        Top = 213
        Width = 79
        Height = 21
        Action = actWizardLine
        TabOrder = 10
      end
      object Button3: TButton
        Left = 443
        Top = 188
        Width = 54
        Height = 21
        Action = actDeleteHeaderFunction
        TabOrder = 8
      end
      object Button4: TButton
        Left = 443
        Top = 213
        Width = 55
        Height = 21
        Action = actDeleteLineFunction
        TabOrder = 11
      end
    end
    object tsNumerator: TTabSheet
      Caption = 'Нумерация'
      ImageIndex = 1
      object lblNumCompany: TLabel
        Left = 6
        Top = 6
        Width = 512
        Height = 28
        AutoSize = False
        Color = clInfoBk
        ParentColor = False
        WordWrap = True
      end
      object gbNumber: TGroupBox
        Left = 5
        Top = 220
        Width = 513
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
          Width = 101
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
        Width = 513
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
          Left = 292
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
      object dbcbIsCheckNumber: TDBCheckBox
        Left = 7
        Top = 272
        Width = 305
        Height = 17
        Caption = 'Контроль уникальности номера документа.'
        DataField = 'ISCHECKNUMBER'
        DataSource = dsgdcBase
        TabOrder = 3
        ValueChecked = '1'
        ValueUnchecked = '0'
      end
      object Memo1: TMemo
        Left = 7
        Top = 302
        Width = 505
        Height = 41
        TabStop = False
        BorderStyle = bsNone
        Lines.Strings = (
          
            'Изменение номера рекомендуется производить только в монопольном ' +
            'режиме работы, когда '
          'другие пользователи не подключены к базе данных.')
        ParentColor = True
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
    end
  end
  inherited alBase: TActionList
    Left = 528
    Top = 128
    object actWizardHeader: TAction
      Caption = 'Конструктор'
      OnExecute = actWizardHeaderExecute
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
    Left = 440
    Top = 280
  end
  object dsFunction: TDataSource
    DataSet = gdcFunctionHeader
    Left = 408
    Top = 280
  end
  object gdcFunctionLine: TgdcFunction
    MasterSource = dsgdcBase
    MasterField = 'LINEFUNCTIONKEY'
    DetailField = 'ID'
    SubSet = 'ByID'
    Left = 440
    Top = 312
  end
  object DataSource1: TDataSource
    DataSet = gdcFunctionLine
    Left = 408
    Top = 312
  end
end
