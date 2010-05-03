inherited gdc_dlgAcctTrEntry: Tgdc_dlgAcctTrEntry
  Left = 459
  Top = 430
  BorderWidth = 5
  Caption = 'Типовая проводка'
  ClientHeight = 190
  ClientWidth = 357
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel [0]
    Left = 0
    Top = 162
    Width = 357
    Height = 2
    Align = alTop
    Shape = bsTopLine
  end
  inherited btnAccess: TButton
    Left = 0
    Top = 169
    Anchors = [akLeft, akBottom]
    TabOrder = 3
  end
  inherited btnNew: TButton
    Left = 72
    Top = 169
    Anchors = [akLeft, akBottom]
    TabOrder = 4
  end
  inherited btnHelp: TButton
    Left = 144
    Top = 169
    Anchors = [akLeft, akBottom]
    TabOrder = 5
  end
  inherited btnOK: TButton
    Left = 217
    Top = 169
    Anchors = [akRight, akBottom]
    TabOrder = 1
  end
  inherited btnCancel: TButton
    Left = 289
    Top = 169
    Anchors = [akRight, akBottom]
    TabOrder = 2
  end
  object Panel2: TPanel [6]
    Left = 0
    Top = 0
    Width = 357
    Height = 162
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object Label1: TLabel
      Left = 1
      Top = 4
      Width = 53
      Height = 13
      Caption = 'Описание:'
    end
    object Label2: TLabel
      Left = 1
      Top = 52
      Width = 75
      Height = 13
      Caption = 'По документу:'
    end
    object lblRecordFunction: TLabel
      Left = 1
      Top = 124
      Width = 48
      Height = 13
      Caption = 'Функция:'
    end
    object Label3: TLabel
      Left = 1
      Top = 100
      Width = 67
      Height = 13
      Caption = 'План счетов:'
    end
    object lDocType: TLabel
      Left = 1
      Top = 76
      Width = 80
      Height = 13
      Caption = 'Тип документа:'
    end
    object Label4: TLabel
      Left = 1
      Top = 28
      Width = 77
      Height = 13
      Caption = 'Типовая опер.:'
    end
    object dbedDescription: TDBEdit
      Left = 88
      Top = 0
      Width = 268
      Height = 21
      DataField = 'DESCRIPTION'
      DataSource = dsgdcBase
      TabOrder = 0
    end
    object iblcDocumentType: TgsIBLookupComboBox
      Left = 88
      Top = 48
      Width = 268
      Height = 21
      HelpContext = 1
      Database = dmDatabase.ibdbGAdmin
      Transaction = ibtrCommon
      DataSource = dsgdcBase
      DataField = 'documenttypekey'
      ListTable = 'GD_DOCUMENTTYPE'
      ListField = 'NAME'
      KeyField = 'ID'
      SortOrder = soAsc
      ItemHeight = 13
      TabOrder = 2
    end
    object BtnFuncWizard: TButton
      Left = 274
      Top = 120
      Width = 82
      Height = 21
      Action = actWizard
      ParentShowHint = False
      ShowHint = True
      TabOrder = 6
    end
    object dbcbIsSaveNullEntry: TDBCheckBox
      Left = 88
      Top = 142
      Width = 187
      Height = 17
      Caption = 'Сохранять нулевую проводку'
      DataField = 'issavenull'
      DataSource = dsgdcBase
      TabOrder = 7
      ValueChecked = '1'
      ValueUnchecked = '0'
    end
    object iblcAccountChart: TgsIBLookupComboBox
      Left = 88
      Top = 96
      Width = 268
      Height = 21
      HelpContext = 1
      Database = dmDatabase.ibdbGAdmin
      Transaction = ibtrCommon
      DataSource = dsgdcBase
      DataField = 'accountkey'
      ListTable = 'ac_account'
      ListField = 'alias'
      KeyField = 'ID'
      SortOrder = soAsc
      Condition = 
        'accounttype = '#39'C'#39' and EXISTS (SELECT * FROM ac_companyaccount c ' +
        'WHERE c.accountkey = ac_account.id)'
      gdClassName = 'TgdcAcctChart'
      ItemHeight = 13
      ParentShowHint = False
      ShowHint = True
      TabOrder = 4
    end
    object dbeFumctionName: TDBEdit
      Left = 88
      Top = 120
      Width = 183
      Height = 21
      Color = clBtnFace
      DataField = 'NAME'
      DataSource = dsFunction
      ReadOnly = True
      TabOrder = 5
    end
    object cbDocumentPart: TDBComboBox
      Left = 88
      Top = 72
      Width = 268
      Height = 21
      DataField = 'DOCUMENTPART'
      DataSource = dsgdcBase
      ItemHeight = 13
      Items.Strings = (
        'шапка'
        'позиция')
      TabOrder = 3
    end
    object iblcTransaction: TgsIBLookupComboBox
      Left = 88
      Top = 24
      Width = 268
      Height = 21
      HelpContext = 1
      DataSource = dsgdcBase
      DataField = 'TRANSACTIONKEY'
      ListTable = 'ac_transaction'
      ListField = 'name'
      KeyField = 'ID'
      gdClassName = 'TgdcAcctTransaction'
      ItemHeight = 13
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
    end
  end
  inherited alBase: TActionList
    Left = 248
    Top = 128
    object actDetailNew: TAction
      Category = 'Detail'
      Caption = 'Новый'
      ImageIndex = 0
    end
    object actDetailEdit: TAction
      Category = 'Detail'
      Caption = 'Редактировать'
      ImageIndex = 1
    end
    object actDetailDelete: TAction
      Category = 'Detail'
      Caption = 'Удалить'
      ImageIndex = 2
    end
    object actDetailDuplicate: TAction
      Category = 'Detail'
      Caption = 'Дубликат'
      ImageIndex = 3
    end
    object actDetailCut: TAction
      Category = 'Detail'
      Caption = 'Вырезать'
      ImageIndex = 7
    end
    object actDetailCopy: TAction
      Category = 'Detail'
      Caption = 'Копировать'
      ImageIndex = 8
    end
    object actDetailPaste: TAction
      Category = 'Detail'
      Caption = 'Вставить'
      ImageIndex = 9
    end
    object actDetailMacro: TAction
      Category = 'Detail'
      Caption = 'Макросы'
      ImageIndex = 19
    end
    object actWizard: TAction
      Caption = 'Конструктор'
      Hint = 'Конструктор функции'
      OnExecute = actWizardExecute
      OnUpdate = actWizardUpdate
    end
  end
  inherited dsgdcBase: TDataSource
    Left = 224
    Top = 128
  end
  inherited pm_dlgG: TPopupMenu
    Left = 272
    Top = 128
  end
  inherited ibtrCommon: TIBTransaction
    Left = 168
    Top = 80
  end
  object dsFunction: TDataSource
    DataSet = gdcFunction
    Left = 200
    Top = 80
  end
  object gdcFunction: TgdcFunction
    MasterSource = dsgdcBase
    MasterField = 'FUNCTIONKEY'
    DetailField = 'ID'
    SubSet = 'ByID'
    Left = 232
    Top = 88
  end
end
