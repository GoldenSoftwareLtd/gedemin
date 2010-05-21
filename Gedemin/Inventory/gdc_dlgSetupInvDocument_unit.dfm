inherited gdc_dlgSetupInvDocument: Tgdc_dlgSetupInvDocument
  Left = 389
  Top = 194
  Caption = 'Складской документ'
  ClientHeight = 451
  ClientWidth = 532
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Top = 426
  end
  inherited btnNew: TButton
    Top = 426
  end
  inherited btnHelp: TButton
    Top = 426
  end
  inherited btnOK: TButton
    Left = 386
    Top = 426
  end
  inherited btnCancel: TButton
    Left = 458
    Top = 426
  end
  inherited pcMain: TPageControl
    Width = 532
    Height = 422
    ActivePage = tsReferences
    Align = alTop
    OnChange = pcMainChange
    OnChanging = pcMainChanging
    inherited tsCommon: TTabSheet
      inherited lblDocumentName: TLabel
        Top = 11
      end
      inherited Label1: TLabel
        Top = 192
      end
      inherited Label2: TLabel
        Top = 215
      end
      object lblDocument: TLabel [6]
        Left = 8
        Top = 169
        Width = 118
        Height = 13
        Caption = 'Из другого документа:'
      end
      object lFormatDoc: TLabel [7]
        Left = 8
        Top = 146
        Width = 102
        Height = 13
        Caption = 'Шаблон документа:'
      end
      inherited lFunction: TLabel
        Top = 233
      end
      inherited Label4: TLabel
        Top = 261
      end
      inherited edDocumentName: TDBEdit
        Color = clWindow
        Enabled = True
      end
      inherited edDescription: TDBMemo
        Color = clWindow
        Enabled = True
      end
      inherited iblcExplorerBranch: TgsIBLookupComboBox
        Condition = '(Classname is null) or (ClassName = '#39#39')'
        Color = clWindow
        Enabled = True
      end
      inherited iblcHeaderTable: TgsIBLookupComboBox
        Top = 188
        Color = clWindow
        Enabled = True
        TabOrder = 6
      end
      inherited iblcLineTable: TgsIBLookupComboBox
        Top = 211
        Color = clWindow
        Enabled = True
        TabOrder = 7
        OnChange = iblcLineTableChange
      end
      inherited edEnglishName: TEdit
        Color = clWindow
        Enabled = True
      end
      inherited dbcbIsCommon: TDBCheckBox
        Top = 293
        Visible = False
      end
      inherited dbeFunctionName: TDBEdit
        Top = 235
        TabOrder = 13
      end
      inherited Button1: TButton
        Top = 235
        TabOrder = 9
      end
      inherited DBEdit1: TDBEdit
        Top = 263
        TabOrder = 10
      end
      inherited Button2: TButton
        Top = 263
        TabOrder = 14
      end
      inherited Button3: TButton
        Top = 235
      end
      inherited Button4: TButton
        Top = 263
      end
      object cbTemplate: TComboBox
        Left = 157
        Top = 142
        Width = 284
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 4
        OnClick = cbTemplateClick
        Items.Strings = (
          'Обычный складской документ'
          'Документ с изменением свойств ТМЦ'
          'Инвентаризационный документ'
          'Документ трансформации ТМЦ')
      end
      object cbDocument: TComboBox
        Left = 157
        Top = 165
        Width = 284
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 5
        OnClick = cbDocumentClick
      end
    end
    object tsFeatures: TTabSheet [1]
      Caption = 'Признаки'
      ImageIndex = 3
      object lvFeatures: TListView
        Left = 7
        Top = 7
        Width = 193
        Height = 191
        Columns = <
          item
            AutoSize = True
            Caption = 'Существующие признаки'
          end>
        HideSelection = False
        ReadOnly = True
        RowSelect = True
        SortType = stText
        TabOrder = 0
        ViewStyle = vsReport
        OnDblClick = actAddFeatureExecute
      end
      object lvUsedFeatures: TListView
        Left = 270
        Top = 7
        Width = 193
        Height = 191
        Columns = <
          item
            AutoSize = True
            Caption = 'Выбранные признаки'
          end>
        HideSelection = False
        ReadOnly = True
        RowSelect = True
        SortType = stText
        TabOrder = 5
        ViewStyle = vsReport
        OnDblClick = actRemoveFeatureExecute
      end
      object btnAdd: TButton
        Left = 211
        Top = 23
        Width = 48
        Height = 25
        Action = actAddFeature
        TabOrder = 1
      end
      object btnRemove: TButton
        Left = 211
        Top = 103
        Width = 48
        Height = 25
        Action = actAddAllFeatures
        TabOrder = 3
      end
      object btnAddAll: TButton
        Left = 211
        Top = 63
        Width = 48
        Height = 25
        Action = actRemoveFeature
        TabOrder = 2
      end
      object btnRemoveAll: TButton
        Left = 211
        Top = 143
        Width = 48
        Height = 25
        Action = actRemoveAllFeatures
        TabOrder = 4
      end
      object rgFeatures: TRadioGroup
        Left = 8
        Top = 205
        Width = 457
        Height = 65
        ItemIndex = 0
        Items.Strings = (
          'Признаки новой карточки'
          'Признаки существующей карточки')
        TabOrder = 6
        OnClick = rgFeaturesClick
      end
      object cbIsChangeCardValue: TCheckBox
        Left = 16
        Top = 272
        Width = 329
        Height = 17
        Caption = 'Разрешить изменять признаки существующей карточки'
        TabOrder = 7
      end
      object cbIsAppendCardValue: TCheckBox
        Left = 16
        Top = 289
        Width = 337
        Height = 17
        Caption = 'Разрешить добавлять признаки существующей карточки'
        TabOrder = 8
      end
    end
    object tsIncomeMovement: TTabSheet [2]
      Caption = 'Приход'
      ImageIndex = 4
      object Label6: TLabel
        Left = 7
        Top = 4
        Width = 104
        Height = 27
        AutoSize = False
        Caption = 'Приход оформляется на:'
        WordWrap = True
      end
      object lblDebitFrom: TLabel
        Left = 7
        Top = 77
        Width = 83
        Height = 13
        Caption = 'Поле в таблице:'
      end
      object lblDebitSubFrom: TLabel
        Left = 7
        Top = 260
        Width = 83
        Height = 13
        Caption = 'Поле в таблице:'
      end
      object lblDebitValue: TLabel
        Left = 7
        Top = 120
        Width = 54
        Height = 25
        AutoSize = False
        Caption = 'Список значений:'
        WordWrap = True
      end
      object lblSubDebitValue: TLabel
        Left = 7
        Top = 302
        Width = 54
        Height = 25
        AutoSize = False
        Caption = 'Список значений:'
        WordWrap = True
      end
      object cbDebitMovement: TComboBox
        Left = 120
        Top = 7
        Width = 341
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 0
        OnChange = cbDebitMovementChange
      end
      object lvDebitMovementValues: TListView
        Left = 70
        Top = 100
        Width = 317
        Height = 77
        Columns = <
          item
            Caption = 'Наименование'
            Width = 200
          end>
        HideSelection = False
        ReadOnly = True
        RowSelect = True
        ShowColumnHeaders = False
        TabOrder = 3
        ViewStyle = vsReport
      end
      object btnAddDebitValue: TButton
        Left = 397
        Top = 100
        Width = 64
        Height = 22
        Action = actAddDebitContact
        TabOrder = 4
      end
      object btnDeleteDebitValue: TButton
        Left = 397
        Top = 127
        Width = 64
        Height = 22
        Action = actDeleteDebitContact
        TabOrder = 5
      end
      object rgDebitFrom: TRadioGroup
        Left = 7
        Top = 31
        Width = 455
        Height = 38
        Caption = ' Приход из: '
        Columns = 2
        ItemIndex = 0
        Items.Strings = (
          '"шапки" документа'
          'позиции документа')
        TabOrder = 1
        OnClick = luCreditFromDropDown
      end
      object luDebitFrom: TComboBox
        Left = 240
        Top = 73
        Width = 223
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 2
        OnDropDown = luCreditFromDropDown
      end
      object luDebitSubFrom: TComboBox
        Left = 238
        Top = 256
        Width = 223
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 8
        OnDropDown = luCreditFromDropDown
      end
      object lvSubDebitMovementValues: TListView
        Left = 70
        Top = 283
        Width = 317
        Height = 77
        Columns = <
          item
            Caption = 'Наименование'
            Width = 200
          end>
        HideSelection = False
        ReadOnly = True
        RowSelect = True
        ShowColumnHeaders = False
        TabOrder = 9
        ViewStyle = vsReport
      end
      object btnAddSubDebitValue: TButton
        Left = 396
        Top = 284
        Width = 64
        Height = 22
        Action = actAddSubDebitContact
        TabOrder = 10
      end
      object btnDeleteSubDebitValue: TButton
        Left = 396
        Top = 311
        Width = 64
        Height = 22
        Action = actDeleteSubDebitContact
        TabOrder = 11
      end
      object rgDebitSubFrom: TRadioGroup
        Left = 6
        Top = 214
        Width = 455
        Height = 38
        Caption = ' Ограничение по приходу из: '
        Columns = 2
        ItemIndex = 0
        Items.Strings = (
          '"шапки" документа'
          'позиции документа')
        TabOrder = 7
        OnClick = luCreditFromDropDown
      end
      object cbUseIncomeSub: TCheckBox
        Left = 6
        Top = 191
        Width = 225
        Height = 17
        Caption = 'Использовать ограничение по приходу:'
        TabOrder = 6
        OnClick = cbUseIncomeSubClick
      end
    end
    object tsOutlayMovement: TTabSheet [3]
      Caption = 'Расход'
      ImageIndex = 5
      object Label8: TLabel
        Left = 7
        Top = 4
        Width = 94
        Height = 27
        AutoSize = False
        Caption = 'Расход оформляется на:'
        WordWrap = True
      end
      object lblCreditFrom: TLabel
        Left = 7
        Top = 77
        Width = 83
        Height = 13
        Caption = 'Поле в таблице:'
      end
      object lblCreditSubFrom: TLabel
        Left = 7
        Top = 260
        Width = 83
        Height = 13
        Caption = 'Поле в таблице:'
      end
      object lblCreditValue: TLabel
        Left = 7
        Top = 120
        Width = 54
        Height = 25
        AutoSize = False
        Caption = 'Список значений:'
        WordWrap = True
      end
      object lblSubCreditValue: TLabel
        Left = 7
        Top = 302
        Width = 54
        Height = 25
        AutoSize = False
        Caption = 'Список значений:'
        WordWrap = True
      end
      object cbCreditMovement: TComboBox
        Left = 120
        Top = 7
        Width = 341
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 0
        OnChange = cbDebitMovementChange
      end
      object lvCreditMovementValues: TListView
        Left = 70
        Top = 100
        Width = 317
        Height = 77
        Columns = <
          item
            Caption = 'Наименование'
            Width = 200
          end>
        HideSelection = False
        ReadOnly = True
        RowSelect = True
        ShowColumnHeaders = False
        TabOrder = 3
        ViewStyle = vsReport
      end
      object btnAddCreditValue: TButton
        Left = 397
        Top = 100
        Width = 64
        Height = 22
        Action = actAddCreditContact
        TabOrder = 4
      end
      object btnDeleteCreditValue: TButton
        Left = 397
        Top = 127
        Width = 64
        Height = 22
        Action = actDeleteCreditContact
        TabOrder = 5
      end
      object rgCreditFrom: TRadioGroup
        Left = 7
        Top = 31
        Width = 455
        Height = 38
        Caption = ' Расход из: '
        Columns = 2
        ItemIndex = 0
        Items.Strings = (
          '"шапки" документа'
          'позиции документа')
        TabOrder = 1
        OnClick = luCreditFromDropDown
      end
      object luCreditFrom: TComboBox
        Left = 240
        Top = 73
        Width = 223
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 2
        OnDropDown = luCreditFromDropDown
      end
      object luCreditSubFrom: TComboBox
        Left = 238
        Top = 256
        Width = 223
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 8
        OnDropDown = luCreditFromDropDown
      end
      object lvSubCreditMovementValues: TListView
        Left = 70
        Top = 283
        Width = 317
        Height = 77
        Columns = <
          item
            Caption = 'Наименование'
            Width = 200
          end>
        HideSelection = False
        ReadOnly = True
        RowSelect = True
        ShowColumnHeaders = False
        TabOrder = 9
        ViewStyle = vsReport
      end
      object btnAddSubCreditValue: TButton
        Left = 396
        Top = 284
        Width = 64
        Height = 22
        Action = actAddSubCreditContact
        TabOrder = 10
      end
      object btnDeleteSubCreditValue: TButton
        Left = 396
        Top = 311
        Width = 64
        Height = 22
        Action = actDeleteSubCreditContact
        TabOrder = 11
      end
      object rgCreditSubFrom: TRadioGroup
        Left = 6
        Top = 214
        Width = 455
        Height = 38
        Caption = ' Ограничение по расходу из: '
        Columns = 2
        ItemIndex = 0
        Items.Strings = (
          '"шапки" документа'
          'позиции документа')
        TabOrder = 7
        OnClick = luCreditFromDropDown
      end
      object cbUseOutlaySub: TCheckBox
        Left = 6
        Top = 191
        Width = 225
        Height = 17
        Caption = 'Использовать ограничение по расходу:'
        TabOrder = 6
        OnClick = cbUseIncomeSubClick
      end
    end
    object tsReferences: TTabSheet [4]
      Caption = 'Справочники'
      ImageIndex = 6
      object rgMovementDirection: TRadioGroup
        Left = 7
        Top = 44
        Width = 395
        Height = 47
        Caption = ' Остатки определять по: '
        Columns = 3
        ItemIndex = 0
        Items.Strings = (
          'FIFO'
          'LIFO'
          'По каждому ТМЦ')
        TabOrder = 2
      end
      object cbRemains: TCheckBox
        Left = 7
        Top = 26
        Width = 395
        Height = 17
        Alignment = taLeftJustify
        Caption = 'Использовать справочник остатков по ТМЦ'
        TabOrder = 1
        OnClick = cbRemainsClick
      end
      object cbReference: TCheckBox
        Left = 7
        Top = 7
        Width = 395
        Height = 17
        Alignment = taLeftJustify
        Caption = 'Использовать справочник ТМЦ'
        TabOrder = 0
      end
      object cbControlRemains: TCheckBox
        Left = 7
        Top = 96
        Width = 201
        Height = 17
        Caption = 'Осуществлять контроль остатков'
        TabOrder = 3
        OnClick = cbRemainsClick
      end
      object cbLiveTimeRemains: TCheckBox
        Left = 7
        Top = 117
        Width = 281
        Height = 17
        Caption = 'Документ работает только с текущими остатками'
        TabOrder = 5
        OnClick = cbRemainsClick
      end
      object cbDelayedDocument: TCheckBox
        Left = 7
        Top = 137
        Width = 323
        Height = 17
        Caption = 'Документ может быть отложенным'
        TabOrder = 6
      end
      object cbMinusRemains: TCheckBox
        Left = 231
        Top = 96
        Width = 209
        Height = 17
        Caption = 'Выбор из отрицательных остатков'
        TabOrder = 4
        OnClick = cbMinusRemainsClick
      end
      object gbMinusFeatures: TGroupBox
        Left = 8
        Top = 181
        Width = 458
        Height = 199
        Hint = 
          'В признаках для выбора из отрицательных остатков используются то' +
          'лько признаки новой карточки'
        Caption = 'Признаки для выбора из отрицательных остатков'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 7
        object lvMinusFeatures: TListView
          Left = 7
          Top = 21
          Width = 193
          Height = 168
          Columns = <
            item
              AutoSize = True
              Caption = 'Существующие признаки'
            end>
          HideSelection = False
          ReadOnly = True
          RowSelect = True
          SortType = stText
          TabOrder = 0
          ViewStyle = vsReport
          OnDblClick = actAdd_MinusFeatureExecute
        end
        object btnAdd_Minus: TButton
          Left = 205
          Top = 40
          Width = 48
          Height = 25
          Action = actAdd_MinusFeature
          TabOrder = 1
        end
        object btnRemove_Minus: TButton
          Left = 205
          Top = 75
          Width = 48
          Height = 25
          Action = actRemove_MinusFeature
          TabOrder = 2
        end
        object btnAddAll_Minus: TButton
          Left = 205
          Top = 111
          Width = 48
          Height = 25
          Action = actAddAll_MinusFeature
          TabOrder = 3
        end
        object btnRemoveAll_Minus: TButton
          Left = 205
          Top = 146
          Width = 48
          Height = 25
          Action = actRemoveAll_MinusFeature
          TabOrder = 4
        end
        object lvMinusUsedFeatures: TListView
          Left = 257
          Top = 21
          Width = 193
          Height = 168
          Columns = <
            item
              AutoSize = True
              Caption = 'Выбранные признаки'
            end>
          HideSelection = False
          ReadOnly = True
          RowSelect = True
          SortType = stText
          TabOrder = 5
          ViewStyle = vsReport
          OnDblClick = actRemove_MinusFeatureExecute
        end
      end
      object cbIsUseCompanyKey: TCheckBox
        Left = 231
        Top = 137
        Width = 206
        Height = 17
        Caption = 'Ограничение на рабочую компанию'
        TabOrder = 8
      end
      object cbSaveRestWindowOption: TCheckBox
        Left = 7
        Top = 156
        Width = 273
        Height = 17
        Caption = 'Сохранять настройки окна остаков'
        TabOrder = 9
      end
    end
  end
  inherited alBase: TActionList
    Left = 270
    Top = 255
    object actAddFeature: TAction [10]
      Category = 'Features'
      Caption = '>'
      OnExecute = actAddFeatureExecute
      OnUpdate = actAddFeatureUpdate
    end
    object actRemoveFeature: TAction [11]
      Category = 'Features'
      Caption = '<'
      OnExecute = actRemoveFeatureExecute
      OnUpdate = actRemoveFeatureUpdate
    end
    object actAddAllFeatures: TAction [12]
      Category = 'Features'
      Caption = '>>'
      OnExecute = actAddAllFeaturesExecute
      OnUpdate = actAddAllFeaturesUpdate
    end
    object actRemoveAllFeatures: TAction [13]
      Category = 'Features'
      Caption = '<<'
      OnExecute = actRemoveAllFeaturesExecute
      OnUpdate = actRemoveAllFeaturesUpdate
    end
    object actAddDebitContact: TAction [14]
      Category = 'Income'
      Caption = 'Добавить'
      OnExecute = actAddDebitContactExecute
      OnUpdate = actAddDebitContactUpdate
    end
    object actDeleteDebitContact: TAction [15]
      Category = 'Income'
      Caption = 'Удалить'
      OnExecute = actDeleteDebitContactExecute
      OnUpdate = actDeleteDebitContactUpdate
    end
    object actAddCreditContact: TAction [16]
      Category = 'Outlay'
      Caption = 'Добавить'
      OnExecute = actAddDebitContactExecute
      OnUpdate = actAddDebitContactUpdate
    end
    object actDeleteCreditContact: TAction [17]
      Category = 'Outlay'
      Caption = 'Удалить'
      OnExecute = actDeleteDebitContactExecute
      OnUpdate = actDeleteDebitContactUpdate
    end
    object actAddSubDebitContact: TAction [18]
      Category = 'Income'
      Caption = 'Добавить'
      OnExecute = actAddDebitContactExecute
      OnUpdate = actAddDebitContactUpdate
    end
    object actDeleteSubDebitContact: TAction [19]
      Category = 'Income'
      Caption = 'Удалить'
      OnExecute = actDeleteDebitContactExecute
      OnUpdate = actDeleteDebitContactUpdate
    end
    object actAddSubCreditContact: TAction [20]
      Category = 'Outlay'
      Caption = 'Добавить'
      OnExecute = actAddDebitContactExecute
      OnUpdate = actAddDebitContactUpdate
    end
    object actDeleteSubCreditContact: TAction [21]
      Category = 'Outlay'
      Caption = 'Удалить'
      OnExecute = actDeleteDebitContactExecute
      OnUpdate = actDeleteDebitContactUpdate
    end
    object actAddAmountField: TAction [22]
      Category = 'AmountField'
      Caption = '>'
    end
    object actCreateCalcMacros: TAction [23]
      Category = 'AmountField'
      Caption = 'Создать'
    end
    object actViewCalcMacros: TAction [24]
      Category = 'AmountField'
      Caption = 'Просмотр'
    end
    object actDeleteCalcMacros: TAction [25]
      Category = 'AmountField'
      Caption = 'Удалить'
    end
    object actDelAmountField: TAction [26]
      Category = 'AmountField'
      Caption = '<'
    end
    object actAdd_MinusFeature: TAction [39]
      Category = 'Features'
      Caption = '>'
      OnExecute = actAdd_MinusFeatureExecute
    end
    object actRemove_MinusFeature: TAction [40]
      Category = 'Features'
      Caption = '<'
      OnExecute = actRemove_MinusFeatureExecute
    end
    object actAddAll_MinusFeature: TAction [41]
      Category = 'Features'
      Caption = '>>'
      OnExecute = actAddAll_MinusFeatureExecute
    end
    object actRemoveAll_MinusFeature: TAction [42]
      Category = 'Features'
      Caption = '<<'
      OnExecute = actRemoveAll_MinusFeatureExecute
    end
  end
  inherited dsgdcBase: TDataSource
    Left = 272
    Top = 231
  end
  inherited pm_dlgG: TPopupMenu
    Left = 448
    Top = 88
  end
  inherited ibtrCommon: TIBTransaction
    Left = 296
    Top = 248
  end
  inherited gdcFunctionHeader: TgdcFunction
    Left = 334
    Top = 209
  end
  inherited dsFunction: TDataSource
    Left = 446
    Top = 41
  end
end
