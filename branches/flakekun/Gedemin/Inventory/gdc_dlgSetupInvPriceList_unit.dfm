inherited dlgSetupInvPriceList: TdlgSetupInvPriceList
  Left = 346
  Top = 205
  Caption = 'Настройка прайс-листа'
  ClientHeight = 445
  ClientWidth = 512
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Top = 416
    Anchors = [akLeft, akBottom]
    TabOrder = 3
  end
  inherited btnNew: TButton
    Top = 416
    Anchors = [akLeft, akBottom]
    TabOrder = 4
  end
  inherited btnOK: TButton
    Left = 350
    Top = 416
    Anchors = [akRight, akBottom]
    TabOrder = 1
  end
  inherited btnCancel: TButton
    Left = 430
    Top = 416
    Anchors = [akRight, akBottom]
    TabOrder = 2
  end
  inherited btnHelp: TButton
    Top = 416
    Anchors = [akLeft, akBottom]
    TabOrder = 5
  end
  object pnlMain: TPanel [5]
    Left = 0
    Top = 0
    Width = 512
    Height = 409
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 0
    object pcMain: TPageControl
      Left = 0
      Top = 0
      Width = 512
      Height = 409
      ActivePage = tsCommon
      Align = alClient
      TabOrder = 0
      OnChange = pcMainChange
      OnChanging = pcMainChanging
      object tsCommon: TTabSheet
        Caption = 'Основные'
        object lblDocumentName: TLabel
          Left = 7
          Top = 7
          Width = 135
          Height = 13
          Caption = 'Наименование документа:'
          FocusControl = edDocumentName
        end
        object lblComment: TLabel
          Left = 7
          Top = 37
          Width = 71
          Height = 13
          Caption = 'Комментарий:'
        end
        object Label1: TLabel
          Left = 8
          Top = 137
          Width = 103
          Height = 13
          Caption = 'Шапка прайс-листа:'
          FocusControl = iblcHeaderTable
        end
        object Label2: TLabel
          Left = 8
          Top = 162
          Width = 111
          Height = 13
          Caption = 'Позиция прайс-листа:'
          FocusControl = iblcLineTable
        end
        object lblExplorer: TLabel
          Left = 8
          Top = 112
          Width = 123
          Height = 13
          Caption = 'Ветка в исследователе:'
        end
        object edDocumentName: TDBEdit
          Left = 157
          Top = 7
          Width = 254
          Height = 21
          DataField = 'NAME'
          DataSource = dsgdcBase
          TabOrder = 0
        end
        object edDescription: TDBMemo
          Left = 157
          Top = 37
          Width = 254
          Height = 64
          DataField = 'DESCRIPTION'
          DataSource = dsgdcBase
          TabOrder = 1
        end
        object iblcHeaderTable: TgsIBLookupComboBox
          Left = 157
          Top = 133
          Width = 254
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
          gdClassName = 'TgdcTable'
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 3
        end
        object iblcLineTable: TgsIBLookupComboBox
          Left = 157
          Top = 158
          Width = 254
          Height = 21
          HelpContext = 1
          Database = dmDatabase.ibdbGAdmin
          Transaction = ibtrCommon
          DataSource = dsgdcBase
          DataField = 'LINERELKEY'
          Fields = 'relationname'
          ListTable = 'AT_RELATIONS'
          ListField = 'lname'
          KeyField = 'id'
          gdClassName = 'TgdcTable'
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 4
        end
        object ibcmbExplorer: TgsIBLookupComboBox
          Left = 157
          Top = 106
          Width = 254
          Height = 21
          HelpContext = 1
          Database = dmDatabase.ibdbGAdmin
          Transaction = ibtrCommon
          ListTable = 'GD_COMMAND'
          ListField = 'NAME'
          KeyField = 'ID'
          Condition = '(ClassName is Null) or (ClassName = '#39#39')'
          gdClassName = 'TgdcExplorer'
          ViewType = vtTree
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 2
        end
        object dbcbIsCommon: TDBCheckBox
          Left = 7
          Top = 200
          Width = 121
          Height = 17
          Caption = 'Общий документ'
          DataField = 'iscommon'
          DataSource = dsgdcBase
          TabOrder = 5
          ValueChecked = '1'
          ValueUnchecked = '0'
        end
      end
      object tsHeader: TTabSheet
        Caption = 'Шапка прайс-листа'
        ImageIndex = 1
        object lvMasterAvailable: TListView
          Left = 7
          Top = 12
          Width = 204
          Height = 209
          Columns = <
            item
              AutoSize = True
              Caption = 'Существующие поля'
            end>
          HideSelection = False
          ReadOnly = True
          RowSelect = True
          SortType = stText
          TabOrder = 0
          ViewStyle = vsReport
          OnDblClick = actSelectMasterFieldExecute
        end
        object lvMasterUsed: TListView
          Left = 287
          Top = 12
          Width = 204
          Height = 209
          Columns = <
            item
              AutoSize = True
              Caption = 'Используемые поля'
            end>
          HideSelection = False
          ReadOnly = True
          RowSelect = True
          SortType = stText
          TabOrder = 1
          ViewStyle = vsReport
          OnDblClick = actDeselectMasterFieldExecute
          OnDeletion = lvDetailUsedDeletion
          OnSelectItem = lvMasterUsedSelectItem
        end
        object btnMasterAdd: TButton
          Left = 225
          Top = 23
          Width = 48
          Height = 25
          Action = actSelectMasterField
          TabOrder = 2
        end
        object btnMasterAddAll: TButton
          Left = 225
          Top = 63
          Width = 48
          Height = 25
          Action = actSelectMasterAllFields
          TabOrder = 3
        end
        object btnMasterRemove: TButton
          Left = 225
          Top = 103
          Width = 48
          Height = 25
          Action = actDeselectMasterField
          TabOrder = 4
        end
        object btnMasterRemoveAll: TButton
          Left = 225
          Top = 143
          Width = 48
          Height = 25
          Action = actDeselectMasterAllFields
          TabOrder = 5
        end
        object memoHeaderInfo: TMemo
          Left = 287
          Top = 230
          Width = 204
          Height = 111
          TabStop = False
          ScrollBars = ssVertical
          TabOrder = 6
          WantReturns = False
        end
      end
      object tsLine: TTabSheet
        Caption = 'Позиция прайс-листа'
        ImageIndex = 2
        object lblCurrency: TLabel
          Left = 7
          Top = 236
          Width = 173
          Height = 13
          Caption = 'Валюта, в которой ведется учет:'
        end
        object lblContact: TLabel
          Left = 7
          Top = 286
          Width = 131
          Height = 13
          Caption = 'Ограничение на контакт:'
        end
        object lvDetailAvailable: TListView
          Left = 7
          Top = 12
          Width = 204
          Height = 209
          Columns = <
            item
              AutoSize = True
              Caption = 'Существующие поля'
            end>
          HideSelection = False
          ReadOnly = True
          RowSelect = True
          SortType = stText
          TabOrder = 0
          ViewStyle = vsReport
          OnDblClick = actSelectDetailFieldExecute
          OnDeletion = lvDetailAvailableDeletion
          OnSelectItem = lvDetailAvailableSelectItem
        end
        object lvDetailUsed: TListView
          Left = 287
          Top = 12
          Width = 204
          Height = 209
          Columns = <
            item
              AutoSize = True
              Caption = 'Используемые поля'
            end>
          HideSelection = False
          ReadOnly = True
          RowSelect = True
          SortType = stText
          TabOrder = 1
          ViewStyle = vsReport
          OnDblClick = actDeselectDetailFieldExecute
          OnDeletion = lvDetailUsedDeletion
          OnSelectItem = lvMasterUsedSelectItem
        end
        object btnDetailAdd: TButton
          Left = 225
          Top = 23
          Width = 48
          Height = 25
          Action = actSelectDetailField
          TabOrder = 2
        end
        object btnDetailAddAll: TButton
          Left = 225
          Top = 63
          Width = 48
          Height = 25
          Action = actSelectDetailAllFields
          TabOrder = 3
        end
        object btnDetailRemove: TButton
          Left = 225
          Top = 103
          Width = 48
          Height = 25
          Action = actDeselectDetailField
          TabOrder = 4
        end
        object btnDetailRemoveAll: TButton
          Left = 225
          Top = 143
          Width = 48
          Height = 25
          Action = actDeselectDetailAllFields
          TabOrder = 5
        end
        object memoLineInfo: TMemo
          Left = 287
          Top = 230
          Width = 204
          Height = 111
          TabStop = False
          ScrollBars = ssVertical
          TabOrder = 6
          WantReturns = False
        end
        object luCurrency: TgsIBLookupComboBox
          Left = 7
          Top = 251
          Width = 204
          Height = 21
          HelpContext = 1
          Database = dmDatabase.ibdbGAdmin
          Transaction = ibtrCommon
          ListTable = 'gd_curr'
          ListField = 'name'
          KeyField = 'id'
          gdClassName = 'TgdcCurr'
          ItemHeight = 0
          ParentShowHint = False
          ShowHint = True
          TabOrder = 7
        end
        object luContact: TgsIBLookupComboBox
          Left = 7
          Top = 301
          Width = 204
          Height = 21
          HelpContext = 1
          Database = dmDatabase.ibdbGAdmin
          Transaction = ibtrCommon
          ListTable = 'gd_contact'
          ListField = 'name'
          KeyField = 'id'
          Condition = 'contacttype=2'
          gdClassName = 'TgdcContact'
          ItemHeight = 0
          ParentShowHint = False
          ShowHint = True
          TabOrder = 8
        end
      end
    end
  end
  inherited alBase: TActionList
    Left = 430
    Top = 195
    object actAddMasterField: TAction
      Category = 'Master'
      Caption = 'Добавить поле'
      ImageIndex = 0
    end
    object actEditMasterField: TAction
      Category = 'Master'
      Caption = 'Редактировать поле'
      ImageIndex = 1
    end
    object actDeleteMasterField: TAction
      Category = 'Master'
      Caption = 'Удалить поле'
      ImageIndex = 2
    end
    object actSelectMasterField: TAction
      Category = 'MasterFieldUsage'
      Caption = '>'
      Hint = 'Использовать'
      OnExecute = actSelectMasterFieldExecute
      OnUpdate = actSelectMasterFieldUpdate
    end
    object actSelectMasterAllFields: TAction
      Category = 'MasterFieldUsage'
      Caption = '>>'
      Hint = 'Использовать все'
      OnExecute = actSelectMasterAllFieldsExecute
      OnUpdate = actSelectMasterAllFieldsUpdate
    end
    object actDeselectMasterField: TAction
      Category = 'MasterFieldUsage'
      Caption = '<'
      Hint = 'Убрать'
      OnExecute = actDeselectMasterFieldExecute
      OnUpdate = actDeselectMasterFieldUpdate
    end
    object actDeselectMasterAllFields: TAction
      Category = 'MasterFieldUsage'
      Caption = '<<'
      Hint = 'Убрать все'
      OnExecute = actDeselectMasterAllFieldsExecute
      OnUpdate = actDeselectMasterAllFieldsUpdate
    end
    object actSelectDetailField: TAction
      Category = 'DetailFieldUsage'
      Caption = '>'
      Hint = 'Использовать'
      OnExecute = actSelectDetailFieldExecute
      OnUpdate = actSelectDetailFieldUpdate
    end
    object actSelectDetailAllFields: TAction
      Category = 'DetailFieldUsage'
      Caption = '>>'
      Hint = 'Использовать все'
      OnExecute = actSelectMasterAllFieldsExecute
      OnUpdate = actSelectMasterAllFieldsUpdate
    end
    object actDeselectDetailField: TAction
      Category = 'DetailFieldUsage'
      Caption = '<'
      Hint = 'Убрать'
      OnExecute = actDeselectDetailFieldExecute
      OnUpdate = actDeselectMasterFieldUpdate
    end
    object actDeselectDetailAllFields: TAction
      Category = 'DetailFieldUsage'
      Caption = '<<'
      Hint = 'Убрать все'
      OnExecute = actDeselectMasterAllFieldsExecute
      OnUpdate = actDeselectMasterAllFieldsUpdate
    end
    object actAddDetailField: TAction
      Category = 'Detail'
      Caption = 'Добавить поле'
      ImageIndex = 0
    end
    object actEditDetailField: TAction
      Category = 'Detail'
      Caption = 'Редактировать поле'
      ImageIndex = 1
    end
    object actDeleteDetailField: TAction
      Category = 'Detail'
      Caption = 'Удалить поле'
      ImageIndex = 2
    end
  end
  inherited dsgdcBase: TDataSource
    Left = 400
    Top = 195
  end
  inherited pm_dlgG: TPopupMenu
    Left = 176
    Top = 296
  end
  inherited ibtrCommon: TIBTransaction
    Left = 370
    Top = 195
  end
  object dsDetailRelationField: TDataSource
    DataSet = gdcPriceLineTableField
    Left = 460
    Top = 165
  end
  object dsMasterRelationField: TDataSource
    DataSet = gdcPriceTableField
    Left = 430
    Top = 165
  end
  object gdcPriceTableField: TgdcTableField
    MasterSource = dsHeader
    MasterField = 'ID'
    DetailField = 'relationkey'
    SubSet = 'ByRelation'
    Left = 276
    Top = 88
  end
  object gdcPriceLineTableField: TgdcTableField
    MasterSource = dsLine
    MasterField = 'ID'
    DetailField = 'relationkey'
    SubSet = 'ByRelation'
    Left = 132
    Top = 280
  end
  object gdcHeaderTable: TgdcTable
    SubSet = 'ByID'
    Left = 244
    Top = 88
  end
  object gdcLineTable: TgdcTable
    SubSet = 'ByID'
    Left = 100
    Top = 280
  end
  object dsHeader: TDataSource
    DataSet = gdcHeaderTable
    Left = 276
    Top = 57
  end
  object dsLine: TDataSource
    DataSet = gdcLineTable
    Left = 132
    Top = 249
  end
end
