inherited frmContractSell: TfrmContractSell
  Left = 328
  Top = 206
  Width = 696
  Height = 480
  Caption = 'Договора на поставку ТМЦ'
  Font.Charset = DEFAULT_CHARSET
  Font.Name = 'Tahoma'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 415
    Width = 688
  end
  inherited pnlMain: TPanel
    Width = 688
    Height = 415
    inherited ibgrMain: TgsIBGrid
      Width = 686
      Height = 385
    end
    inherited cbMain: TControlBar
      Width = 686
      inherited tbMain: TToolBar
        Images = dmImages.ilToolBarSmall
        inherited tbtPrint: TToolButton
          PopupMenu = pmMainReport
        end
      end
    end
  end
  inherited alMain: TActionList
    Images = dmImages.ilToolBarSmall
    inherited actNew: TAction
      OnExecute = actNewExecute
    end
    inherited actEdit: TAction
      OnExecute = actEditExecute
    end
  end
  inherited dsMain: TDataSource
    DataSet = ibdsContract
  end
  inherited gsQFMain: TgsQueryFilter
    Database = nil
    IBDataSet = nil
  end
  inherited gsMainReportManager: TgsReportManager
    GroupID = 2000004
  end
  object ibdsContract: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    BufferChunks = 1000
    CachedUpdates = False
    DeleteSQL.Strings = (
      'delete from gd_document'
      'where'
      '  ID = :OLD_ID')
    RefreshSQL.Strings = (
      
        'SELECT doc.id, doc.number, doc.documentdate, doc.description, c.' +
        'Name'
      'FROM'
      '  gd_contract con JOIN gd_document doc ON '
      '      con.documentkey = doc.id'
      '  JOIN gd_contact c ON con.contactkey = c.id'
      'where'
      '  doc.ID = :ID')
    SelectSQL.Strings = (
      
        'SELECT doc.id, doc.number, doc.documentdate, doc.description, c.' +
        'Name,'
      '  con.Percent'
      'FROM'
      '  gd_contract con JOIN gd_document doc ON '
      '      con.documentkey = doc.id'
      '  JOIN gd_contact c ON con.contactkey = c.id')
    Left = 320
    Top = 112
  end
  object gsqryContract: TgsQueryFilter
    OnFilterChanged = gsQFMainFilterChanged
    Database = dmDatabase.ibdbGAdmin
    IBDataSet = ibdsContract
    Left = 352
    Top = 112
  end
  object atSQLSetup1: TatSQLSetup
    Ignores = <>
    Left = 408
    Top = 128
  end
end
