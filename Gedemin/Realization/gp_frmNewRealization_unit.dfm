inherited Form1: TForm1
  Left = 244
  Top = 103
  Width = 696
  Height = 480
  Caption = 'Список документов на реализацию'
  Font.Charset = DEFAULT_CHARSET
  Font.Name = 'Tahoma'
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
    end
    inherited cbMain: TControlBar
      Width = 686
      inherited tbMain: TToolBar
        Height = 52
        inherited tbnSpace1: TToolButton
          Left = 0
          Wrap = True
        end
        inherited tbtUnDo: TToolButton
          Left = 0
          Top = 30
        end
        inherited tbnSpace5: TToolButton
          Left = 23
          Top = 30
        end
        inherited tbtFilter: TToolButton
          Left = 31
          Top = 30
        end
        inherited tbtPrint: TToolButton
          Left = 54
          Top = 30
        end
        inherited tbnSpace6: TToolButton
          Left = 77
          Top = 30
        end
        inherited tbHlp: TToolButton
          Left = 83
          Top = 30
        end
        object ToolButton6: TToolButton
          Left = 106
          Top = 30
          Action = actPrint
        end
        object ToolButton8: TToolButton
          Left = 129
          Top = 30
          Width = 8
          Caption = 'ToolButton8'
          ImageIndex = 6
          Style = tbsSeparator
        end
        object ToolButton9: TToolButton
          Left = 137
          Top = 30
          Action = actOption
        end
        object ToolButton10: TToolButton
          Left = 160
          Top = 30
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
  end
  inherited ibdsMain: TIBDataSet
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
      '  docr.delayedsale,'
      '  docr.rate,'
      '  docr.fromdocumentkey,'
      '  toc.name,'
      '  toc.phone,'
      '  fromc.name as fromname'
      'FROM'
      '  gd_docrealization docr'
      'JOIN'
      '  gd_document doc ON doc.id = docr.documentkey '
      'JOIN'
      '  gd_contact toc ON docr.tocontactkey = toc.id '
      'JOIN'
      '  gd_contact fromc ON docr.fromcontactkey = fromc.id '
      'WHERE'
      '  doc.companykey = :ck')
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
      'JOIN '
      '  gd_good g ON pos.goodkey = g.id '
      'LEFT JOIN gd_value v ON pos.valuekey = v.id'
      '  '
      'WHERE'
      '   pos.documentkey = :documentkey and'
      '   pos.quantity <> 0'
      ''
      'ORDER BY pos.id')
  end
  object pPrintMenu: TPopupMenu
    Left = 416
    Top = 80
  end
  object gsReportRegistry: TgsReportRegistry
    DataBase = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    DataSource = dsPrintDocRealPos
    PopupMenu = pPrintMenu
    MenuType = mtSeparator
    Caption = 'Печать документа'
    GroupID = 1002000
    OnBeforePrint = gsReportRegistryBeforePrint
    Left = 280
    Top = 261
  end
  object atSQLSetup: TatSQLSetup
    Ignores = <>
    Left = 248
    Top = 261
  end
  object ibsqlDocRealInfo: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    ParamCheck = True
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
      '  crc.*,'
      '  co.Name as CarOwner,'
      '  sk.Name as Surrender,'
      '  fk.Name as Forwarder'
      'FROM'
      '  gd_docrealinfo dop '
      'LEFT JOIN '
      '  gd_contact cr ON dop.cargoreceiverkey = cr.id'
      'LEFT JOIN'
      '  gd_company comp ON cr.id = comp.contactkey'
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
    Left = 144
    Top = 260
  end
  object ibsqlOurFirm: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    ParamCheck = True
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
    Left = 176
    Top = 260
  end
  object ibsqlCustomer: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    ParamCheck = True
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
    Left = 208
    Top = 260
  end
  object ibsqlUpdateGroupPrint: TIBSQL
    Database = dmDatabase.ibdbGAdmin
    ParamCheck = True
    SQL.Strings = (
      'UPDATE gd_docrealpos'
      'SET printgrouptext = :t,  orderprint = :o, varprint = :v'
      'WHERE'
      '  goodkey IN (select g.id from gd_good g JOIN gd_goodgroup gg ON'
      '     g.groupkey = gg.id and gg.LB >= :lb and gg.rb <= :rb)'
      '  and documentkey = :id')
    Transaction = IBTransaction
    Left = 144
    Top = 316
  end
  object ibdsPrintDocRealPos: TIBDataSet
    Database = dmDatabase.ibdbGAdmin
    Transaction = IBTransaction
    BufferChunks = 1000
    CachedUpdates = False
    SelectSQL.Strings = (
      'SELECT '
      '  pos.*,'
      '  g.Name,'
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
      '  t.Name as TransactionName'
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
      '  gd_listtrtype t ON pos.trtypekey = id'
      'WHERE'
      '  pos.documentkey = :dockey and'
      '  pos.quantity <> 0'
      'ORDER BY pos.id  ')
    Left = 104
    Top = 316
  end
  object dsPrintDocRealPos: TDataSource
    DataSet = ibdsPrintDocRealPos
    Left = 72
    Top = 316
  end
end
