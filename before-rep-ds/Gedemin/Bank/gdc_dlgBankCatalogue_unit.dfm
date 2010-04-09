inherited gdc_dlgBankCatalogue: Tgdc_dlgBankCatalogue
  Left = 352
  Top = 141
  Caption = 'Банковская картотека'
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    inherited splMain: TSplitter
      Top = 92
    end
    inherited pnlDetail: TPanel
      Top = 96
      Height = 256
      inherited ibgrDetail: TgsIBGrid
        Height = 221
        Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
        ColumnEditors = <
          item
            Lookup.LookupListField = 'name'
            Lookup.LookupKeyField = 'id'
            Lookup.LookupTable = 'gd_contact c JOIN gd_company cp ON cp.contactkey = c.id'
            Lookup.ViewType = vtGrid
            Lookup.gdClassName = 'TgdcCompany'
            Lookup.Transaction = ibtrCommon
            Lookup.Distinct = False
            EditorStyle = cesLookup
            FieldName = 'companykeyline'
            DisplayField = 'companyname'
            ValueList.Strings = ()
            DropDownCount = 8
          end>
      end
      inherited tbdLeft: TTBDock
        Height = 221
      end
      inherited tbdRight: TTBDock
        Height = 221
      end
      inherited tbdBottom: TTBDock
        Top = 247
      end
    end
    inherited pnlMaster: TPanel
      Height = 92
      object Label1: TLabel
        Left = 16
        Top = 16
        Width = 85
        Height = 13
        Caption = 'Расчетный счет:'
        FocusControl = ibcmbAccount
      end
      object Label2: TLabel
        Left = 16
        Top = 40
        Width = 79
        Height = 13
        Caption = 'Тип картотеки:'
        FocusControl = dbeType
      end
      object dbeType: TDBEdit
        Left = 108
        Top = 35
        Width = 144
        Height = 21
        DataField = 'cataloguetype'
        DataSource = dsgdcBase
        TabOrder = 1
      end
      object ibcmbAccount: TgsIBLookupComboBox
        Left = 108
        Top = 10
        Width = 145
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = ibtrCommon
        DataSource = dsgdcBase
        DataField = 'accountkey'
        ListTable = 'gd_companyaccount'
        ListField = 'account'
        KeyField = 'id'
        gdClassName = 'TgdcAccount'
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
      end
    end
  end
  inherited alBase: TActionList
    Left = 404
    Top = 120
  end
  inherited dsgdcBase: TDataSource
    Left = 437
    Top = 119
  end
  inherited dsDetail: TDataSource
    Left = 440
    Top = 150
  end
  object ibsql: TIBSQL
    Left = 336
    Top = 226
  end
end
