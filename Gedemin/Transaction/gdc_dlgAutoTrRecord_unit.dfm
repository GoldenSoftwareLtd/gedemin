inherited gdc_dlgAutoTrRecord: Tgdc_dlgAutoTrRecord
  Left = 332
  Top = 188
  HelpContext = 200
  BorderWidth = 5
  Caption = 'Автоматическая проводка'
  ClientHeight = 170
  ClientWidth = 357
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel [0]
    Left = 0
    Top = 141
    Width = 357
    Height = 3
    Align = alTop
    Shape = bsTopLine
  end
  inherited btnAccess: TButton
    Left = 0
    Top = 149
    Anchors = [akLeft, akBottom]
    TabOrder = 3
  end
  inherited btnNew: TButton
    Left = 72
    Top = 149
    Anchors = [akLeft, akBottom]
    TabOrder = 4
  end
  inherited btnOK: TButton
    Left = 217
    Top = 149
    Anchors = [akRight, akBottom]
    TabOrder = 1
  end
  inherited btnCancel: TButton
    Left = 289
    Top = 149
    Anchors = [akRight, akBottom]
    TabOrder = 2
  end
  inherited btnHelp: TButton
    Left = 144
    Top = 149
    Hint = '200'
    Anchors = [akLeft, akBottom]
    TabOrder = 5
  end
  object Panel1: TPanel [6]
    Left = 0
    Top = 0
    Width = 357
    Height = 141
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object Label1: TLabel
      Left = 5
      Top = 4
      Width = 53
      Height = 13
      Caption = 'Описание:'
    end
    object Label2: TLabel
      Left = 5
      Top = 52
      Width = 48
      Height = 13
      Caption = 'Функция:'
    end
    object lShowInFolder: TLabel
      Left = 16
      Top = 94
      Width = 108
      Height = 13
      Caption = 'Показывать в папке:'
    end
    object lImage: TLabel
      Left = 16
      Top = 118
      Width = 41
      Height = 13
      Caption = 'Иконка:'
    end
    object Label3: TLabel
      Left = 5
      Top = 28
      Width = 67
      Height = 13
      Caption = 'План счетов:'
    end
    object DBEdit1: TDBEdit
      Left = 80
      Top = 0
      Width = 275
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      DataField = 'DESCRIPTION'
      DataSource = dsgdcBase
      TabOrder = 0
    end
    object dbeFumctionName: TDBEdit
      Left = 80
      Top = 48
      Width = 191
      Height = 21
      Color = clBtnFace
      DataField = 'NAME'
      DataSource = dsFunction
      ReadOnly = True
      TabOrder = 2
    end
    object Button1: TButton
      Left = 272
      Top = 48
      Width = 83
      Height = 21
      Action = actWizard
      TabOrder = 3
    end
    object dbcbShowInExplorer: TDBCheckBox
      Left = 5
      Top = 72
      Width = 177
      Height = 17
      Caption = 'Показывать в исследователе'
      DataField = 'SHOWINEXPLORER'
      DataSource = dsgdcBase
      TabOrder = 4
      ValueChecked = '1'
      ValueUnchecked = '0'
      OnClick = dbcbShowInExplorerClick
    end
    object iblFolder: TgsIBLookupComboBox
      Left = 130
      Top = 90
      Width = 225
      Height = 21
      HelpContext = 1
      Database = dmDatabase.ibdbGAdmin
      DataSource = dsgdcBase
      DataField = 'FOLDERKEY'
      ListTable = 'gd_command'
      ListField = 'name'
      KeyField = 'ID'
      gdClassName = 'TgdcExplorer'
      Enabled = False
      ItemHeight = 13
      ParentShowHint = False
      ShowHint = True
      TabOrder = 5
    end
    object cbImage: TComboBox
      Left = 130
      Top = 113
      Width = 224
      Height = 22
      Style = csOwnerDrawFixed
      ItemHeight = 16
      TabOrder = 6
      OnChange = cbImageClick
      OnDrawItem = cbImageDrawItem
      OnDropDown = cbImageDropDown
    end
    object iblcAccountChart: TgsIBLookupComboBox
      Left = 80
      Top = 24
      Width = 276
      Height = 21
      HelpContext = 1
      Database = dmDatabase.ibdbGAdmin
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
      TabOrder = 1
    end
  end
  inherited alBase: TActionList
    Left = 136
    Top = 120
    object actWizard: TAction
      Caption = 'Конструктор'
      OnExecute = actWizardExecute
      OnUpdate = actWizardUpdate
    end
  end
  inherited dsgdcBase: TDataSource
    Left = 168
    Top = 120
  end
  inherited pm_dlgG: TPopupMenu
    Left = 64
    Top = 104
  end
  object dsFunction: TDataSource
    DataSet = gdcFunction
    Left = 232
    Top = 112
  end
  object gdcFunction: TgdcFunction
    MasterSource = dsgdcBase
    MasterField = 'FUNCTIONKEY'
    DetailField = 'ID'
    SubSet = 'ByID'
    Left = 296
    Top = 112
  end
end
