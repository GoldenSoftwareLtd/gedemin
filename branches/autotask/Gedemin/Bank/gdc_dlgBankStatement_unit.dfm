inherited gdc_dlgBankStatement: Tgdc_dlgBankStatement
  Left = 305
  Top = 280
  Width = 896
  Height = 557
  Caption = 'Банковская выписка'
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Top = 502
    TabOrder = 3
  end
  inherited btnNew: TButton
    Top = 502
    TabOrder = 4
  end
  inherited btnHelp: TButton
    Top = 502
    TabOrder = 5
  end
  inherited btnOK: TButton
    Left = 733
    Top = 502
    TabOrder = 1
  end
  inherited btnCancel: TButton
    Left = 810
    Top = 502
    TabOrder = 2
  end
  inherited pnlMain: TPanel
    Width = 880
    Height = 495
    TabOrder = 0
    inherited splMain: TSplitter
      Top = 86
      Width = 880
    end
    inherited pnlDetail: TPanel
      Top = 90
      Width = 880
      Height = 405
      TabOrder = 1
      inherited ibgrDetail: TgsIBGrid
        Width = 862
        Height = 370
        Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit]
        ColumnEditors = <
          item
            Lookup.LookupListField = 'NAME'
            Lookup.LookupKeyField = 'ID'
            Lookup.LookupTable = 'gd_contact c JOIN gd_company cp ON cp.contactkey = c.id'
            Lookup.ViewType = vtGrid
            Lookup.gdClassName = 'TgdcCompany'
            Lookup.Database = dmDatabase.ibdbGAdmin
            Lookup.Transaction = ibtrCommon
            Lookup.Distinct = False
            EditorStyle = cesLookup
            FieldName = 'companykeyline'
            DisplayField = 'COMPANYNAME'
            ValueList.Strings = ()
            DropDownCount = 8
          end
          item
            Lookup.LookupListField = 'NAME'
            Lookup.LookupKeyField = 'ID'
            Lookup.LookupTable = 'GD_LISTTRTYPE'
            Lookup.SortOrder = soAsc
            Lookup.Database = dmDatabase.ibdbGAdmin
            Lookup.Transaction = ibtrCommon
            Lookup.Distinct = False
            EditorStyle = cesLookup
            FieldName = 'trtypekeyline'
            DisplayField = 'OPERATIONNAME'
            ValueList.Strings = ()
            DropDownCount = 8
          end
          item
            Lookup.LookupListField = 'NAME'
            Lookup.LookupKeyField = 'ID'
            Lookup.LookupTable = 'AC_TRANSACTION'
            Lookup.Condition = 
              'EXISTS (SELECT * FROM ac_trrecord WHERE ac_transaction.id = ac_t' +
              'rrecord.transactionkey and ac_trrecord.documenttypekey = 800300)'
            Lookup.SortOrder = soAsc
            Lookup.gdClassName = 'TgdcAcctTransaction'
            Lookup.Database = dmDatabase.ibdbGAdmin
            Lookup.Transaction = ibtrCommon
            Lookup.Distinct = False
            EditorStyle = cesLookup
            FieldName = 'TRANSACTIONKEY'
            DisplayField = 'TRANSACTIONNAME'
            ValueList.Strings = ()
            DropDownCount = 8
          end
          item
            Lookup.LookupListField = 'alias'
            Lookup.LookupKeyField = 'ID'
            Lookup.LookupTable = 'ac_account'
            Lookup.gdClassName = 'TgdcAcctAccount'
            Lookup.Transaction = ibtrCommon
            Lookup.Distinct = False
            EditorStyle = cesLookup
            FieldName = 'accountkey'
            DisplayField = 'alias'
            ValueList.Strings = ()
            DropDownCount = 8
          end
          item
            Lookup.LookupListField = 'NAME'
            Lookup.LookupKeyField = 'ID'
            Lookup.LookupTable = 'gd_contact c JOIN gd_company cp ON cp.contactkey = c.id'
            Lookup.ViewType = vtGrid
            Lookup.gdClassName = 'TgdcCompany'
            Lookup.Database = dmDatabase.ibdbGAdmin
            Lookup.Transaction = ibtrCommon
            Lookup.Distinct = False
            EditorStyle = cesLookup
            FieldName = 'contractorkey'
            DisplayField = 'CONTRACTORNAME'
            ValueList.Strings = ()
            DropDownCount = 8
          end>
      end
      inherited tbdTop: TTBDock
        Width = 880
      end
      inherited tbdLeft: TTBDock
        Height = 370
      end
      inherited tbdRight: TTBDock
        Left = 871
        Height = 370
      end
      inherited tbdBottom: TTBDock
        Top = 396
        Width = 880
      end
    end
    inherited pnlMaster: TPanel
      Width = 880
      Height = 86
      TabOrder = 0
      object Label2: TLabel
        Left = 261
        Top = 10
        Width = 75
        Height = 13
        Caption = '№ документа:'
        FocusControl = edtDocNumber
      end
      object Label3: TLabel
        Left = 442
        Top = 10
        Width = 30
        Height = 13
        Caption = 'Дата:'
        FocusControl = edtDocDate
      end
      object Label1: TLabel
        Left = 5
        Top = 31
        Width = 49
        Height = 13
        Caption = '№ счета:'
        FocusControl = ibcmbAccount
      end
      object Label4: TLabel
        Left = 261
        Top = 31
        Width = 43
        Height = 13
        Caption = 'Валюта:'
      end
      object Label5: TLabel
        Left = 5
        Top = 10
        Width = 70
        Height = 13
        Caption = 'Организация:'
        FocusControl = edtDocNumber
      end
      object Label6: TLabel
        Left = 443
        Top = 31
        Width = 28
        Height = 13
        Caption = 'Курс:'
      end
      object ibcmbAccount: TgsIBLookupComboBox
        Left = 82
        Top = 29
        Width = 175
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = ibtrCommon
        DataSource = dsgdcBase
        DataField = 'accountkey'
        ListTable = 'gd_Companyaccount'
        ListField = 'account'
        KeyField = 'id'
        gdClassName = 'TgdcAccount'
        OnCreateNewObject = ibcmbAccountCreateNewObject
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 3
      end
      object edtDocDate: TxDateDBEdit
        Left = 479
        Top = 6
        Width = 74
        Height = 21
        DataField = 'Documentdate'
        DataSource = dsgdcBase
        Kind = kDate
        EditMask = '!99\.99\.9999;1;_'
        MaxLength = 10
        TabOrder = 2
      end
      object edtDocNumber: TDBEdit
        Left = 338
        Top = 6
        Width = 95
        Height = 21
        Hint = 'Номер банковской выписки'
        DataField = 'Number'
        DataSource = dsgdcBase
        TabOrder = 1
      end
      object edCompany: TEdit
        Left = 82
        Top = 6
        Width = 175
        Height = 21
        TabStop = False
        Color = clBtnFace
        ReadOnly = True
        TabOrder = 0
      end
      object edCurrency: TEdit
        Left = 338
        Top = 29
        Width = 95
        Height = 21
        TabStop = False
        Color = clBtnFace
        ImeMode = imAlpha
        ReadOnly = True
        TabOrder = 4
      end
      object xdbcRate: TxDBCalculatorEdit
        Left = 479
        Top = 29
        Width = 75
        Height = 21
        TabOrder = 5
        DataField = 'rate'
        DataSource = dsgdcBase
      end
      object cbDontRecalc: TCheckBox
        Left = 6
        Top = 64
        Width = 218
        Height = 17
        Caption = 'Не пересчитывать позиции выписки'
        TabOrder = 6
      end
    end
  end
  inherited alBase: TActionList
    Left = 380
    Top = 208
  end
  inherited dsgdcBase: TDataSource
    Left = 413
    Top = 207
  end
  inherited dsDetail: TDataSource
    Left = 416
    Top = 246
  end
  object IBSQL: TIBSQL
    Left = 192
    Top = 223
  end
end
