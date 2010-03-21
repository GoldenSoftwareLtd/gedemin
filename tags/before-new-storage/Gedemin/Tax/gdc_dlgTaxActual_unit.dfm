inherited gdc_dlgTaxActual: Tgdc_dlgTaxActual
  Left = 338
  Top = 327
  HelpContext = 10
  BorderWidth = 5
  Caption = 'Актуальный отчет бухгалтерии'
  ClientHeight = 126
  ClientWidth = 374
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object XPBevel1: TXPBevel [0]
    Left = 0
    Top = 96
    Width = 374
    Height = 3
    Align = alTop
    Shape = bsTopLine
    Style = bsLowered
  end
  inherited btnAccess: TButton
    Left = 0
    Top = 105
    Anchors = [akLeft, akBottom]
    TabOrder = 3
  end
  inherited btnNew: TButton
    Left = 72
    Top = 105
    Anchors = [akLeft, akBottom]
    TabOrder = 4
  end
  inherited btnOK: TButton
    Left = 233
    Top = 105
    Anchors = [akRight, akBottom]
    TabOrder = 1
  end
  inherited btnCancel: TButton
    Left = 305
    Top = 105
    Anchors = [akRight, akBottom]
    TabOrder = 2
  end
  inherited btnHelp: TButton
    Left = 144
    Top = 105
    Anchors = [akLeft, akBottom]
    TabOrder = 5
  end
  object pnlMain: TPanel [6]
    Left = 0
    Top = 0
    Width = 374
    Height = 96
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 0
    object lblTaxName: TLabel
      Left = 5
      Top = 4
      Width = 62
      Height = 13
      Caption = 'Имя отчета:'
    end
    object lblActualDate: TLabel
      Left = 5
      Top = 27
      Width = 108
      Height = 13
      Caption = 'Дата начала отчета:'
    end
    object lblReportDay: TLabel
      Left = 5
      Top = 50
      Width = 86
      Height = 13
      Caption = 'Отчетное число:'
    end
    object lblType: TLabel
      Left = 208
      Top = 27
      Width = 22
      Height = 13
      Caption = 'Тип:'
    end
    object Label2: TLabel
      Left = 5
      Top = 75
      Width = 48
      Height = 13
      Caption = 'Функция:'
    end
    object ibcbTax: TgsIBLookupComboBox
      Left = 125
      Top = 0
      Width = 249
      Height = 21
      HelpContext = 1
      Database = dmDatabase.ibdbGAdmin
      Transaction = dmDatabase.ibtrGenUniqueID
      DataSource = dsgdcBase
      DataField = 'taxnamekey'
      ListTable = 'GD_TAXNAME'
      ListField = 'name'
      KeyField = 'ID'
      SortOrder = soAsc
      gdClassName = 'TgdcTaxName'
      ItemHeight = 13
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      OnChange = ibcbTaxChange
    end
    object xedTaxDate: TxDateDBEdit
      Left = 125
      Top = 23
      Width = 65
      Height = 21
      DataField = 'actualdate'
      DataSource = dsgdcBase
      Kind = kDate
      EditMask = '!99\.99\.9999;1;_'
      MaxLength = 10
      TabOrder = 1
    end
    object speRepotDay: TSpinEdit
      Left = 125
      Top = 46
      Width = 65
      Height = 22
      MaxValue = 31
      MinValue = 1
      TabOrder = 3
      Value = 20
      OnChange = speRepotDayChange
    end
    object dbcbType: TDBLookupComboBox
      Left = 244
      Top = 23
      Width = 130
      Height = 21
      DataField = 'typekey'
      DataSource = dsgdcBase
      KeyField = 'id'
      ListField = 'name'
      ListSource = dsType
      TabOrder = 2
    end
    object dbeFumctionName: TDBEdit
      Left = 125
      Top = 71
      Width = 165
      Height = 21
      Color = clBtnFace
      DataField = 'NAME'
      DataSource = dsFunction
      ReadOnly = True
      TabOrder = 4
    end
    object Button1: TButton
      Left = 291
      Top = 71
      Width = 83
      Height = 21
      Action = actWizard
      TabOrder = 5
    end
  end
  inherited alBase: TActionList
    Left = 230
    Top = 65535
    object actWizard: TAction
      Caption = 'Конструктор'
      OnExecute = actWizardExecute
      OnUpdate = actWizardUpdate
    end
  end
  inherited dsgdcBase: TDataSource
    Left = 296
    Top = 65535
  end
  inherited pm_dlgG: TPopupMenu
    Left = 264
    Top = 0
  end
  object dsType: TDataSource
    Left = 200
  end
  object dsFunction: TDataSource
    DataSet = gdcFunction
    Left = 168
  end
  object gdcFunction: TgdcFunction
    MasterSource = dsAutoTrRecord
    MasterField = 'FUNCTIONKEY'
    DetailField = 'ID'
    SubSet = 'ByID'
    Left = 48
  end
  object dsAutoTrRecord: TDataSource
    DataSet = gdcTrRecord
    Left = 80
    Top = 64
  end
  object gdcTrRecord: TgdcAutoTrRecord
    MasterSource = dsgdcBase
    MasterField = 'TRRECORDKEY'
    DetailField = 'ID'
    SubSet = 'ByID'
    Left = 48
    Top = 64
  end
end
