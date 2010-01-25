inherited bn_frmCurrCommission: Tbn_frmCurrCommission
  Left = 67
  Top = 85
  Width = 696
  Height = 480
  Caption = 'Поручение на перевод валюты'
  Font.Charset = DEFAULT_CHARSET
  Font.Name = 'MS Sans Serif'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 407
    Width = 688
  end
  inherited pnlMain: TPanel
    Width = 688
    Height = 407
    inherited ibgrMain: TgsIBGrid
      Width = 686
      Height = 377
    end
    inherited cbMain: TControlBar
      Width = 686
      inherited tbMain: TToolBar
        inherited tbnSpace6: TToolButton
          Width = 9
        end
        inherited tbHlp: TToolButton
          Left = 263
        end
      end
      inherited tbMainGrid: TToolBar
        Left = 630
      end
      object tbAccount: TToolBar
        Left = 374
        Top = 2
        Width = 243
        Height = 22
        ButtonHeight = 21
        Caption = 'tbMainGrid'
        EdgeBorders = []
        Flat = True
        TabOrder = 2
        object Panel1: TPanel
          Left = 0
          Top = 0
          Width = 241
          Height = 21
          Align = alClient
          AutoSize = True
          BevelOuter = bvNone
          TabOrder = 0
          object Label1: TLabel
            Left = 0
            Top = 5
            Width = 83
            Height = 13
            Caption = 'Расчетный счет:'
            Layout = tlCenter
          end
          object gsibluAccount: TgsIBLookupComboBox
            Left = 85
            Top = 1
            Width = 153
            Height = 21
            Database = dmDatabase.ibdbGAdmin
            Transaction = IBTransaction
            ListTable = 'gd_companyaccount'
            ListField = 'account'
            KeyField = 'id'
            SortOrder = soAsc
            Anchors = []
            BiDiMode = bdLeftToRight
            ItemHeight = 13
            ParentBiDiMode = False
            ParentShowHint = False
            ShowHint = True
            TabOrder = 0
            OnChange = gsibluAccountChange
          end
        end
      end
    end
  end
  inherited IBTransaction: TIBTransaction [2]
    DefaultDatabase = nil
    Left = 403
  end
  inherited alMain: TActionList [3]
    Left = 493
    inherited actNew: TAction
      OnExecute = actNewExecute
    end
    inherited actEdit: TAction
      OnExecute = actEditExecute
    end
    object actPrintOptions: TAction
      Caption = 'Настройки печати'
      OnExecute = actPrintOptionsExecute
    end
  end
  inherited pmMainReport: TPopupMenu [4]
    Left = 493
    object N1: TMenuItem
      Action = actPrintOptions
    end
  end
  inherited pmMain: TPopupMenu [6]
    Left = 443
  end
  inherited ibdsMain: TIBDataSet
    DeleteSQL.Strings = (
      'delete from gd_document'
      'where'
      '  id = :OLD_DOCUMENTKEY')
    InsertSQL.Strings = (
      'insert into bn_currcommission'
      '  (DOCUMENTKEY, ACCOUNTKEY, CORRCOMPANYKEY, CORRACCOUNTKEY, '
      'OWNCOMPTEXT, '
      '   OWNTAXID, OWNCOUNTRY, CORRCOMPTEXT, CORRTAXID, '
      'CORRCOUNTRY, CORRBANKTEXT, '
      '   CORRBANKCITY, CORRACCOUNT, CORRACCOUNTCODE, AMOUNT, '
      'DESTINATION, OWNBANKTEXT, '
      '   OWNBANKCITY, OWNACCOUNT, OWNACCOUNTCODE,'
      'KIND, EXPENSEACCOUNT, MIDCORRBANKTEXT, QUEUE, DESTCODE,'
      '  DESTCODEKEY)'
      'values'
      '  (:DOCUMENTKEY, :ACCOUNTKEY, :CORRCOMPANYKEY, :CORRACCOUNTKEY, '
      ':OWNCOMPTEXT, '
      '   :OWNTAXID, :OWNCOUNTRY, :CORRCOMPTEXT, :CORRTAXID, '
      ':CORRCOUNTRY, :CORRBANKTEXT, '
      '   :CORRBANKCITY, :CORRACCOUNT, :CORRACCOUNTCODE, :AMOUNT, '
      ':DESTINATION, '
      '   :OWNBANKTEXT, :OWNBANKCITY, :OWNACCOUNT, :OWNACCOUNTCODE,'
      ':KIND, :EXPENSEACCOUNT, :MIDCORRBANKTEXT, :QUEUE, :DESTCODE,'
      '   :DESTCODEKEY)')
    RefreshSQL.Strings = (
      'SELECT D.ID, D.NUMBER, D.DOCUMENTDATE, '
      '  CC.*, C.name as currname, c.shortname as currshortname'
      'FROM bn_currcommission cc  '
      ' JOIN GD_DOCUMENT D ON D.ID = CC.DOCUMENTKEY'
      ' JOIN GD_COMPANYACCOUNT CA ON CA.ID = CC.ACCOUNTKEY'
      ' LEFT JOIN GD_CURR C ON C.ID = CA.CURRKEY'
      'WHERE '
      '   CC.DOCUMENTKEY = :DOCUMENTKEY')
    SelectSQL.Strings = (
      'SELECT D.ID, D.NUMBER, D.DOCUMENTDATE, '
      '  CC.*, C.name as currname, c.shortname as currshortname'
      'FROM bn_currcommission cc  '
      ' JOIN GD_DOCUMENT D ON D.ID = CC.DOCUMENTKEY'
      ' JOIN GD_COMPANYACCOUNT CA ON CA.ID = CC.ACCOUNTKEY'
      ' LEFT JOIN GD_CURR C ON C.ID = CA.CURRKEY'
      'WHERE D.COMPANYKEY = :CompanyKey'
      '  AND  CC.ACCOUNTKEY = :ID'
      '  AND D.DOCUMENTTYPEKEY = :DT')
    ModifySQL.Strings = (
      'update bn_currcommission'
      'set'
      '  DOCUMENTKEY = :DOCUMENTKEY,'
      '  ACCOUNTKEY = :ACCOUNTKEY,'
      '  CORRCOMPANYKEY = :CORRCOMPANYKEY,'
      '  CORRACCOUNTKEY = :CORRACCOUNTKEY,'
      '  OWNCOMPTEXT = :OWNCOMPTEXT,'
      '  OWNTAXID = :OWNTAXID,'
      '  OWNCOUNTRY = :OWNCOUNTRY,'
      '  CORRCOMPTEXT = :CORRCOMPTEXT,'
      '  CORRTAXID = :CORRTAXID,'
      '  CORRCOUNTRY = :CORRCOUNTRY,'
      '  CORRBANKTEXT = :CORRBANKTEXT,'
      '  CORRBANKCITY = :CORRBANKCITY,'
      '  CORRACCOUNT = :CORRACCOUNT,'
      '  CORRACCOUNTCODE = :CORRACCOUNTCODE,'
      '  AMOUNT = :AMOUNT,'
      '  DESTINATION = :DESTINATION,'
      '  OWNBANKTEXT = :OWNBANKTEXT,'
      '  OWNBANKCITY = :OWNBANKCITY,'
      '  OWNACCOUNT = :OWNACCOUNT,'
      '  OWNACCOUNTCODE = :OWNACCOUNTCODE,'
      '  KIND = :KIND, '
      '  EXPENSEACCOUNT = :EXPENSEACCOUNT, '
      '  MIDCORRBANKTEXT = :MIDCORRBANKTEXT, '
      '  QUEUE = :QUEUE,  '
      '  DESTCODE = :DESTCODE, '
      '  DESTCODEKEY = :DESTCODEKEY'
      'where'
      '  DOCUMENTKEY = :OLD_DOCUMENTKEY')
    Left = 371
  end
  inherited dsMain: TDataSource
    Left = 339
  end
  inherited gsQFMain: TgsQueryFilter
    Database = nil
    IBDataSet = nil
    Left = 307
  end
  inherited pmMainFilter: TPopupMenu
    Left = 275
  end
  object atSQLSetup: TatSQLSetup [11]
    Ignores = <>
    Left = 368
    Top = 120
  end
  object gsqfCurrCommiss: TgsQueryFilter [12]
    OnFilterChanged = gsQFMainFilterChanged
    Database = dmDatabase.ibdbGAdmin
    RequeryParams = False
    IBDataSet = ibdsMain
    Left = 435
    Top = 80
  end
  inherited gsMainReportManager: TgsReportManager
    MenuType = mtSeparator
    GroupID = 2000310
    Left = 403
  end
end
