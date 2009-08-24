inherited gdc_dlgCheckList: Tgdc_dlgCheckList
  Left = 335
  Top = 114
  Width = 530
  Caption = 'Реестр чеков'
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Left = 85
  end
  inherited btnNew: TButton
    Left = 5
  end
  inherited btnOK: TButton
    Left = 365
  end
  inherited btnCancel: TButton
    Left = 445
  end
  inherited btnHelp: TButton
    Left = 165
  end
  inherited pnlMain: TPanel
    Width = 522
    inherited splMain: TSplitter
      Top = 153
      Width = 522
    end
    inherited pnlDetail: TPanel
      Top = 159
      Width = 522
      Height = 253
      inherited ibgrDetail: TgsIBGrid
        Width = 504
        Height = 218
        Options = [dgEditing, dgTitles, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
        ColumnEditors = <
          item
            Lookup.LookupListField = 'ACCOUNT'
            Lookup.LookupKeyField = 'ID'
            Lookup.LookupTable = 'GD_COMPANYACCOUNT'
            Lookup.gdClassName = 'TgdcAccount'
            Lookup.Transaction = ibtrCommon
            EditorStyle = cesLookup
            FieldName = 'ACCOUNTKEY'
            DisplayField = 'ACCOUNTTEXT'
            ValueList.Strings = ()
            DropDownCount = 8
          end>
      end
      inherited tbdTop: TTBDock
        Width = 522
      end
      inherited tbdLeft: TTBDock
        Height = 218
      end
      inherited tbdRight: TTBDock
        Left = 513
        Height = 218
      end
      inherited tbdBottom: TTBDock
        Top = 244
        Width = 522
      end
    end
    inherited pnlMaster: TPanel
      Width = 522
      Height = 153
      object Label11: TLabel
        Left = 15
        Top = 74
        Width = 54
        Height = 13
        Caption = 'Вид опер.:'
        Transparent = True
      end
      object Label6: TLabel
        Left = 15
        Top = 99
        Width = 63
        Height = 13
        Caption = 'Назн. плат.:'
        Transparent = True
      end
      object Label16: TLabel
        Left = 170
        Top = 74
        Width = 65
        Height = 13
        Caption = 'Очер. плат.:'
        Transparent = True
      end
      object Label7: TLabel
        Left = 170
        Top = 99
        Width = 76
        Height = 13
        Caption = 'Срок платежа:'
        Transparent = True
      end
      object Label8: TLabel
        Left = 335
        Top = 74
        Width = 68
        Height = 13
        Caption = '№ гр. банка:'
        Transparent = True
      end
      object Bevel3: TBevel
        Left = 5
        Top = 65
        Width = 511
        Height = 57
        Shape = bsFrame
      end
      object Bevel1: TBevel
        Left = 5
        Top = 5
        Width = 511
        Height = 56
        Shape = bsFrame
      end
      object Label1: TLabel
        Left = 15
        Top = 14
        Width = 35
        Height = 13
        Caption = 'Номер:'
        Transparent = True
      end
      object Label3: TLabel
        Left = 15
        Top = 39
        Width = 57
        Height = 13
        Caption = 'Код банка:'
        Transparent = True
      end
      object Label2: TLabel
        Left = 170
        Top = 14
        Width = 30
        Height = 13
        Caption = 'Дата:'
        Transparent = True
      end
      object Label5: TLabel
        Left = 170
        Top = 39
        Width = 28
        Height = 13
        Caption = 'Банк:'
        Transparent = True
      end
      object Label4: TLabel
        Left = 301
        Top = 14
        Width = 88
        Height = 13
        Caption = 'Оплата со счета:'
        Transparent = True
      end
      object dbeOperKind: TDBEdit
        Left = 90
        Top = 70
        Width = 71
        Height = 21
        DataField = 'OPER'
        DataSource = dsgdcBase
        TabOrder = 0
      end
      object dbeDest: TgsIBLookupComboBox
        Left = 90
        Top = 95
        Width = 71
        Height = 21
        Database = dmDatabase.ibdbGAdmin
        Transaction = ibtrCommon
        DataSource = dsgdcBase
        DataField = 'DESTCODEKEY'
        ListTable = 'BN_DESTCODE'
        ListField = 'CODE'
        KeyField = 'ID'
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
      end
      object dbeQueue: TDBEdit
        Left = 250
        Top = 70
        Width = 76
        Height = 21
        DataField = 'QUEUE'
        DataSource = dsgdcBase
        TabOrder = 2
      end
      object dbeTerm: TxDateDBEdit
        Left = 250
        Top = 95
        Width = 76
        Height = 21
        DataField = 'TERM'
        DataSource = dsgdcBase
        Kind = kDate
        EditMask = '!99\.99\.9999;1;_'
        MaxLength = 10
        TabOrder = 3
      end
      object dbeBankGroup: TDBEdit
        Left = 415
        Top = 70
        Width = 76
        Height = 21
        DataField = 'BANKGROUP'
        DataSource = dsgdcBase
        TabOrder = 4
      end
      object gsibluBankCode: TgsIBLookupComboBox
        Left = 90
        Top = 35
        Width = 71
        Height = 21
        Database = dmDatabase.ibdbGAdmin
        Transaction = ibtrCommon
        DataSource = dsgdcBase
        DataField = 'BANKKEY'
        ListTable = 'GD_BANK'
        ListField = 'BANKCODE'
        KeyField = 'BANKKEY'
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 5
      end
      object gsibluBank: TgsIBLookupComboBox
        Left = 215
        Top = 35
        Width = 294
        Height = 21
        Database = dmDatabase.ibdbGAdmin
        Transaction = ibtrCommon
        DataSource = dsgdcBase
        DataField = 'BANKKEY'
        Fields = 'bankcode'
        ListTable = 'GD_CONTACT'
        ListField = 'NAME'
        KeyField = 'ID'
        Condition = 'CONTACTTYPE = 5'
        gdClassName = 'TgdcBank'
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 6
      end
      object dbeDate: TxDateDBEdit
        Left = 215
        Top = 10
        Width = 74
        Height = 21
        DataField = 'DOCUMENTDATE'
        DataSource = dsgdcBase
        Kind = kDate
        EditMask = '!99\.99\.9999;1;_'
        MaxLength = 10
        TabOrder = 7
      end
      object dbeNumber: TDBEdit
        Left = 90
        Top = 10
        Width = 71
        Height = 21
        DataField = 'NUMBER'
        DataSource = dsgdcBase
        TabOrder = 9
      end
      object gsibluOwnAccount: TgsIBLookupComboBox
        Left = 395
        Top = 10
        Width = 114
        Height = 21
        Database = dmDatabase.ibdbGAdmin
        Transaction = ibtrCommon
        DataSource = dsgdcBase
        DataField = 'ACCOUNTKEY'
        ListTable = 'GD_COMPANYACCOUNT'
        ListField = 'ACCOUNT'
        KeyField = 'ID'
        gdClassName = 'TgdcAccount'
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 8
      end
    end
  end
  inherited alBase: TActionList
    Left = 380
    Top = 152
  end
  inherited dsgdcBase: TDataSource
    Left = 413
    Top = 151
  end
  inherited dsDetail: TDataSource
    Left = 416
    Top = 182
  end
  object sqlBankData: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    ParamCheck = True
    SQL.Strings = (
      'SELECT '
      '  COMP.FULLNAME,'
      '  C.CITY,'
      '  BANK.BANKCODE,'
      '  BANK.BANKKEY'
      ''
      'FROM'
      '  GD_COMPANYACCOUNT A,'
      ''
      '  GD_COMPANY COMP'
      ''
      '    JOIN'
      '      GD_CONTACT C'
      '    ON'
      '      COMP.CONTACTKEY = C.ID'
      ''
      '    JOIN'
      '      GD_BANK BANK'
      '    ON'
      '      COMP.CONTACTKEY = BANK.BANKKEY'
      ''
      'WHERE'
      '  A.ID = :Id'
      '    AND'
      '  COMP.CONTACTKEY = A.BANKKEY')
    Transaction = dmDatabase.ibtrGenUniqueID
    Left = 466
    Top = 240
  end
end
