inherited gdc_frmSGRAccount: Tgdc_frmSGRAccount
  Left = 220
  Top = 222
  Width = 615
  Height = 431
  Caption = 'gdc_frmSGRAccount'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 374
    Width = 599
  end
  inherited TBDockTop: TTBDock
    Width = 599
    inherited tbMainCustom: TTBToolbar
      Left = 460
      object TBControlItem1: TTBControlItem
        Control = ibcmbAccount
      end
      object ibcmbAccount: TgsIBLookupComboBox
        Left = 0
        Top = 0
        Width = 129
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = IBTransaction
        ListTable = 'gd_companyaccount'
        ListField = 'account'
        KeyField = 'id'
        Condition = '(disabled=0 or (disabled is null))'
        gdClassName = 'TgdcAccount'
        OnCreateNewObject = ibcmbAccountCreateNewObject
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        OnChange = ibcmbAccountChange
      end
    end
    inherited tbChooseMain: TTBToolbar
      Left = 427
    end
  end
  inherited TBDockLeft: TTBDock
    Height = 314
  end
  inherited TBDockRight: TTBDock
    Left = 590
    Height = 314
  end
  inherited TBDockBottom: TTBDock
    Top = 365
    Width = 599
  end
  inherited pnlWorkArea: TPanel
    Width = 581
    Height = 314
    inherited spChoose: TSplitter
      Top = 211
      Width = 581
    end
    inherited pnlMain: TPanel
      Width = 581
      Height = 211
      inherited pnlSearchMain: TPanel
        Height = 211
        inherited sbSearchMain: TScrollBox
          Height = 184
        end
      end
      inherited ibgrMain: TgsIBGrid
        Width = 421
        Height = 211
        Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit, dgMultiSelect]
      end
    end
    inherited pnChoose: TPanel
      Top = 215
      Width = 581
      inherited pnButtonChoose: TPanel
        Left = 476
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 476
      end
      inherited pnlChooseCaption: TPanel
        Width = 581
      end
    end
  end
  inherited alMain: TActionList
    Left = 85
  end
  inherited pmMain: TPopupMenu
    Left = 175
    Top = 80
    object nOptionsPrint: TMenuItem
      Caption = 'Настройка печати ...'
    end
  end
  inherited dsMain: TDataSource
    Left = 145
    Top = 80
  end
  object gsTransaction: TgsTransaction
    DocumentType = 800100
    DataSource = dsMain
    FieldName = 'TRTYPEKEY'
    FieldKey = 'ID'
    FieldTrName = 'TRANSACTIONNAME'
    FieldDocumentKey = 'DOCUMENTKEY'
    BeginTransactionType = btManual
    DocumentOnly = False
    MakeDelayedEntry = True
    Left = 115
    Top = 80
  end
  object IBTransaction: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 205
    Top = 80
  end
end
