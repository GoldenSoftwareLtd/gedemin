inherited frmRealizationBill: TfrmRealizationBill
  Left = 271
  Top = 103
  Width = 696
  Height = 480
  Caption = 'Список документов на реализацию'
  Font.Charset = DEFAULT_CHARSET
  Font.Name = 'MS Sans Serif'
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  inherited Splitter: TSplitter
    Width = 688
  end
  inherited sbMain: TStatusBar
    Top = 415
    Width = 688
  end
  inherited pnlMain: TPanel
    Width = 688
    inherited ibgrMain: TgsIBGrid
      Width = 686
      Options = [dgTitles, dgColumnResize, dgColLines, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgMultiSelect]
      PopupMenu = pmMenu
    end
    inherited cbMain: TControlBar
      Width = 686
      inherited tbMain: TToolBar
        inherited tbtFilter: TToolButton
          DropdownMenu = nil
        end
        inherited tbtPrint: TToolButton
          DropdownMenu = pPrintMenu
        end
        object ToolButton8: TToolButton
          Left = 283
          Top = 0
          Width = 8
          Caption = 'ToolButton8'
          ImageIndex = 6
          Style = tbsSeparator
        end
      end
      inherited tbMainGrid: TToolBar
        Left = 470
      end
      object tbNew: TToolBar
        Left = 374
        Top = 2
        Width = 83
        Height = 22
        Caption = 'tbMainGrid'
        EdgeBorders = []
        Flat = True
        Images = dmImages.ilToolBarSmall
        TabOrder = 2
        object tbDetail: TToolButton
          Left = 0
          Top = 0
          Action = actDetailBill
        end
        object ToolButton3: TToolButton
          Left = 23
          Top = 0
          Width = 8
          Caption = 'ToolButton3'
          ImageIndex = 9
          Style = tbsSeparator
        end
        object tbOption: TToolButton
          Left = 31
          Top = 0
          Action = actOption
        end
        object tbEntry: TToolButton
          Left = 54
          Top = 0
          Action = actEntry
        end
      end
    end
  end
  inherited pnlDetails: TPanel
    Width = 688
    Height = 242
    inherited ibgrDetails: TgsIBGrid
      Width = 686
      Height = 214
    end
    inherited cbDetails: TControlBar
      Width = 686
      Visible = False
    end
  end
  inherited alMain: TActionList
    inherited actNew: TAction
      OnExecute = actNewExecute
    end
    inherited actEdit: TAction
      OnExecute = actEditExecute
    end
    inherited actDuplicate: TAction
      OnExecute = actDuplicateExecute
    end
    object actDetailBill: TAction
      Category = 'Master'
      Caption = 'actDetailBill'
      Hint = 'Отчет экспедитора'
      ImageIndex = 8
      OnExecute = actDetailBillExecute
    end
    object actOption: TAction
      Category = 'Master'
      Caption = 'Настройки'
      Hint = 'Настройки накладной'
      ImageIndex = 7
      OnExecute = actOptionExecute
    end
    object actEntry: TAction
      Category = 'Master'
      Caption = 'Проводки'
      Hint = 'Формирование проводок'
      ImageIndex = 9
      OnExecute = actEntryExecute
    end
    object actCheckContract: TAction
      Category = 'Master'
      Caption = 'Проверка договоров'
      OnExecute = actCheckContractExecute
    end
  end
  inherited ibdsMain: TIBDataSet
    DeleteSQL.Strings = (
      'delete from gd_document'
      'where   id = :OLD_DOCUMENTKEY')
    RefreshSQL.Strings = (
      'SELECT '
      '  doc.number,'
      '  doc.documentdate,'
      '  docr.documentkey,'
      '  docr.transsumncu,'
      '  docr.transsumcurr,'
      '  doc.currkey,'
      '  docr.tocontactkey,'
      '  docr.fromcontactkey,'
      '  docr.rate,'
      '  docr.fromdocumentkey,'
      '  docr.pricekey,'
      '  docr.typetransport,'
      '  toc.name,'
      '  toc.phone,'
      '  toc.city,'
      '  toc.country,'
      '  toc.region,'
      '  fromc.name as fromname'
      'FROM'
      '  gd_document doc'
      'JOIN'
      
        '  gd_docrealization docr ON doc.id = docr.documentkey AND docr.D' +
        'OCUMENTKEY = :DOCUMENTKEY'
      'JOIN'
      '  gd_contact toc ON docr.tocontactkey = toc.id '
      'JOIN'
      '  gd_contact fromc ON docr.fromcontactkey = fromc.id '
      '  ')
    SelectSQL.Strings = (
      'SELECT '
      '  doc.number,'
      '  doc.documentdate,'
      '  docr.documentkey,'
      '  docr.transsumncu,'
      '  docr.transsumcurr,'
      '  doc.currkey,'
      '  docr.tocontactkey,'
      '  docr.fromcontactkey,'
      '  docr.rate,'
      '  docr.fromdocumentkey,'
      '  docr.pricekey,'
      '  docr.typetransport,'
      '  toc.name,'
      '  toc.phone,'
      '  toc.city,'
      '  toc.country,'
      '  toc.region,'
      '  fromc.name as fromname'
      'FROM'
      '  gd_document doc'
      'JOIN'
      
        '  gd_docrealization docr ON doc.id = docr.documentkey AND doc.do' +
        'cumenttypekey = :dt'
      'JOIN'
      '  gd_contact toc ON docr.tocontactkey = toc.id '
      'JOIN'
      '  gd_contact fromc ON docr.fromcontactkey = fromc.id ')
  end
  inherited gsQFMain: TgsQueryFilter
    IBDataSet = nil
  end
  inherited ibdsDetails: TIBDataSet
    SelectSQL.Strings = (
      'SELECT '
      '  pos.*,'
      '  g.Name,'
      '  v.Name as ValueName,'
      '  pos.AmountNCU / pos.Quantity  as CostNCU,'
      '  pos.AmountCurr / pos.Quantity  as CostCurr'
      '  '
      'FROM'
      '  gd_docrealpos pos'
      'LEFT JOIN '
      '  gd_good g ON pos.goodkey = g.id '
      'LEFT JOIN gd_value v ON pos.valuekey = v.id'
      '  '
      'WHERE'
      '   pos.documentkey = :documentkey and'
      '   pos.quantity <> 0'
      ''
      'ORDER BY pos.id')
  end
  inherited gsQFDetail: TgsQueryFilter
    IBDataSet = nil
  end
  object pPrintMenu: TPopupMenu [16]
    Left = 416
    Top = 80
  end
  object atSQLSetup: TatSQLSetup [17]
    Ignores = <>
    Left = 248
    Top = 261
  end
  object gsQueryFilter: TgsQueryFilter [19]
    OnFilterChanged = gsQFMainFilterChanged
    Database = dmDatabase.ibdbGAdmin
    RequeryParams = False
    IBDataSet = ibdsMain
    Left = 448
    Top = 80
  end
  object gsQFDetailPosReal: TgsQueryFilter [20]
    Database = dmDatabase.ibdbGAdmin
    RequeryParams = False
    IBDataSet = ibdsDetails
    Left = 448
    Top = 112
  end
  object dsPrintDocRealPos: TDataSource [21]
    DataSet = ibdsPrintDocRealPos
    Left = 48
    Top = 340
  end
  object ibdsPrintDocRealPos: TIBDataSet [22]
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    BufferChunks = 100
    SelectSQL.Strings = (
      'SELECT '
      '  pos.*,'
      '  g.Name,'
      '  g.ShortName,'
      '  g.valuekey as goodvaluekey,'
      '  g.Alias,'
      '  g.description,'
      '  pos.AmountNCU / pos.Quantity  as CostNCU,'
      '  pos.AmountCurr / pos.Quantity  as CostCurr,'
      '  v.Name as VALUENAME,'
      '  vg.scale,'
      '  vg.decdigit,'
      '  w.Name as WeightName,'
      '  wg.scale as WeightScale,'
      '  p.Name as PackName,'
      '  pg.scale as PackScale,'
      '  t.Name as TransactionName,'
      '  tnvd.Name as TNVDCode'
      'FROM'
      '  gd_docrealpos pos '
      'JOIN '
      '  gd_good g ON pos.goodkey = g.id '
      'JOIN'
      '  gd_value v ON pos.valuekey = v.id'
      'LEFT JOIN'
      
        '  gd_goodvalue vg ON pos.goodkey = vg.goodkey AND pos.valuekey =' +
        ' vg.valuekey'
      'LEFT JOIN'
      '  gd_value w ON pos.weightkey = w.id'
      'LEFT JOIN'
      '  gd_goodvalue wg ON wg.goodkey = g.id and wg.valuekey = w.id'
      'LEFT JOIN'
      '  gd_value p ON pos.packkey = p.id  '
      'LEFT JOIN'
      '  gd_goodvalue pg ON pg.goodkey = g.id and pg.valuekey = p.id'
      'LEFT JOIN'
      '  gd_listtrtype t ON pos.trtypekey = t.id'
      'LEFT JOIN'
      '  gd_tnvd tnvd ON g.tnvdkey = tnvd.id'
      'WHERE'
      '  pos.documentkey = :dockey and'
      '  pos.quantity <> 0'
      'ORDER BY pos.id  ')
    ReadTransaction = IBTransaction
    Left = 72
    Top = 340
  end
  object ibsqlUpdateGroupPrint: TIBSQL [23]
    Database = dmDatabase.ibdbGAdmin
    SQL.Strings = (
      'UPDATE gd_docrealpos'
      'SET printgrouptext = :t,  orderprint = :o, varprint = :v'
      'WHERE'
      '  goodkey IN (select g.id from gd_good g JOIN gd_goodgroup gg ON'
      '     g.groupkey = gg.id and gg.LB >= :lb and gg.rb <= :rb)'
      '  and documentkey = :id')
    Transaction = IBTransaction
    Left = 120
    Top = 340
  end
  object ibsqlDocRealInfo: TIBSQL [24]
    Database = dmDatabase.ibdbGAdmin
    SQL.Strings = (
      'SELECT '
      '  dop.*,'
      '  cr.Name as CargoReceiverName,'
      '  cr.Address as CargoReceiverAddress,'
      '  crbc.Name as CargoReceiverBank,'
      '  crbc.Address as CargoReceiverBankAddress,'
      '  cra.Account as CargoReceiverAccount,'
      '  crb.BankCode as CargoReceiverCode,'
      '  crb.BankMFO as CargoReceiverMFO,'
      '  crcc.TaxID as CargoReceiveUNN,'
      '  crcc.OKPO as CargoReceiveOKPO,'
      '  crcc.licence as CargoReceiveLicence, '
      '  crc.*,'
      '  co.Name as CarOwner,'
      '  sk.Name as Surrender,'
      '  fk.Name as Forwarder,'
      ' curr.ShortName as CurrName,'
      ' curr.Sign '
      'FROM'
      '  gd_docrealinfo dop '
      'JOIN'
      '  gd_document doc ON dop.documentkey = doc.id '
      'LEFT JOIN'
      '  gd_curr curr ON doc.currkey = curr.id'
      'LEFT JOIN '
      '  gd_contact cr ON dop.cargoreceiverkey = cr.id'
      'LEFT JOIN'
      '  gd_company comp ON cr.id = comp.contactkey'
      'LEFT JOIN '
      '  gd_companycode crcc ON crcc.companykey = cr.id'
      'LEFT JOIN'
      '  gd_companyaccount cra ON comp.companyaccountkey = cra.id'
      'LEFT JOIN '
      '  gd_bank crb ON cra.BankKey = crb.BankKey'
      'LEFT JOIN '
      '  gd_contact crbc ON crb.BankKey = crbc.ID'
      'LEFT JOIN'
      '  gd_companycode crc ON comp.contactkey = crc.companykey'
      'LEFT JOIN'
      '  gd_contact co ON dop.carownerkey = co.id'
      'LEFT JOIN'
      '  gd_contact sk ON dop.surrenderkey = sk.id'
      'LEFT JOIN '
      '  gd_contact fk ON dop.forwarderkey = fk.id'
      'WHERE'
      '  dop.documentkey = :dk')
    Transaction = IBTransaction
    Left = 120
    Top = 284
  end
  object ibsqlOurFirm: TIBSQL [25]
    Database = dmDatabase.ibdbGAdmin
    SQL.Strings = (
      'SELECT'
      '  c.Name as Sender,'
      '  c.Address as SenderAddress,'
      '  cc.taxid as SenderUNN,'
      '  cc.okpo as SenderOKPO,'
      '  cc.licence as SenderLicence,'
      '  ca.Account as SenderAccount,'
      '  cab.BankCode as SenderCode,'
      '  cab.BankMFO as SenderMFO,'
      '  cabc.Name as SenderBank'
      'FROM'
      '  gd_contact c '
      'LEFT JOIN '
      '  gd_companycode cc ON c.id = cc.companykey '
      'LEFT JOIN'
      '  gd_company comp ON c.id = comp.contactkey'
      'LEFT JOIN'
      '  gd_companyaccount ca ON comp.companyaccountkey = ca.id'
      'LEFT JOIN'
      '  gd_bank cab ON ca.bankkey = cab.bankkey'
      'LEFT JOIN'
      '  gd_contact cabc ON cab.bankkey = cabc.id'
      'WHERE'
      '    c.id = :id')
    Transaction = IBTransaction
    Left = 152
    Top = 284
  end
  object ibsqlCustomer: TIBSQL [26]
    Database = dmDatabase.ibdbGAdmin
    SQL.Strings = (
      'SELECT '
      '  c.Name as CustomerName,'
      '  c.Address as CustomerAddress,'
      '  ccode.TaxID as CustomerTaxID,'
      '  ccode.OKPO as CustomerOKPO,'
      '  ccode.Licence as CustomerLicence,'
      '  ca.Account as CustomerAccount,'
      '  cb.bankcode as CustomerBankCode,'
      '  cbc.Name as CustomerBank'
      'FROM'
      '  gd_contact c '
      'LEFT JOIN'
      '  gd_companycode ccode ON c.ID = ccode.companykey'
      'LEFT JOIN '
      '  gd_company com ON c.id = com.contactkey'
      'LEFT JOIN '
      '  gd_companyaccount ca ON ca.ID = com.companyaccountkey'
      'LEFT JOIN '
      '  gd_bank cb ON cb.bankkey = ca.bankkey'
      'LEFT JOIN'
      '  gd_contact cbc ON cb.bankkey = cbc.id'
      'WHERE'
      '  c.ID = :ID'
      '  ')
    Transaction = IBTransaction
    Left = 184
    Top = 284
  end
  object ibsqlDocReal: TIBSQL [27]
    Database = dmDatabase.ibdbGAdmin
    SQL.Strings = (
      'SELECT '
      '   pr.relevancedate,'
      '   pr.name as pricename,'
      '   pr.description as pricedesc'
      'FROM'
      '  gd_price pr'
      'WHERE'
      '  pr.id = :id')
    Transaction = IBTransaction
    Left = 216
    Top = 283
  end
  object pmMenu: TPopupMenu [28]
    Left = 488
    Top = 80
    object N1: TMenuItem
      Action = actCheckContract
    end
  end
  inherited gsMainReportManager: TgsReportManager
    PopupMenu = pPrintMenu
    MenuType = mtSeparator
    GroupID = 2000001
  end
end
