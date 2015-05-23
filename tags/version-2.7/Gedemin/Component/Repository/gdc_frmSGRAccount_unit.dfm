inherited gdc_frmSGRAccount: Tgdc_frmSGRAccount
  Left = 220
  Top = 222
  Width = 615
  Height = 431
  Caption = 'gdc_frmSGRAccount'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 385
    Width = 607
  end
  inherited TBDockTop: TTBDock
    Width = 607
    inherited tbMainCustom: TTBToolbar
      Left = 468
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
      Left = 435
    end
  end
  inherited TBDockLeft: TTBDock
    Height = 327
  end
  inherited TBDockRight: TTBDock
    Left = 598
    Height = 327
  end
  inherited TBDockBottom: TTBDock
    Top = 376
    Width = 607
  end
  inherited pnlWorkArea: TPanel
    Width = 589
    Height = 327
    inherited spChoose: TSplitter
      Top = 225
      Width = 589
    end
    inherited pnlMain: TPanel
      Width = 589
      Height = 225
      inherited pnlSearchMain: TPanel
        Height = 225
        inherited sbSearchMain: TScrollBox
          Height = 187
        end
        inherited pnlSearchMainButton: TPanel
          Top = 187
        end
      end
      inherited ibgrMain: TgsIBGrid
        Width = 429
        Height = 225
        Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit, dgMultiSelect]
      end
    end
    inherited pnChoose: TPanel
      Top = 228
      Width = 589
      inherited pnButtonChoose: TPanel
        Left = 484
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 484
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
