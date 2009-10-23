inherited frmBills: TfrmBills
  Left = 93
  Top = 102
  Caption = 'Список счетов-фактур'
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMain: TPanel
    inherited ibgrMain: TgsIBGrid
      Aliases = <
        item
          Alias = 'ISPERMIT'
          LName = 'Разрешено'
        end>
    end
    inherited cbMain: TControlBar
      inherited tbMainGrid: TToolBar
        Left = 531
      end
      object tbBill: TToolBar [2]
        Left = 374
        Top = 2
        Width = 48
        Height = 22
        Caption = 'tbAddButton'
        EdgeBorders = []
        Flat = True
        Images = dmImages.ilToolBarSmall
        TabOrder = 2
        object tbCheck: TToolButton
          Left = 0
          Top = 0
          Action = actGiveBill
          Caption = 'Выдать'
        end
      end
      inherited tbNew: TToolBar
        Left = 435
        TabOrder = 3
        Visible = False
      end
    end
  end
  inherited alMain: TActionList
    object actGiveBill: TAction
      Category = 'Master'
      Caption = 'Выдано'
      ImageIndex = 14
      OnExecute = actGiveBillExecute
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
      '  docr.ispermit,'
      '  doc.currkey,'
      '  docr.tocontactkey,'
      '  docr.fromcontactkey,'
      '  docr.rate,'
      '  docr.fromdocumentkey,'
      '  docr.pricekey,'
      '  toc.name,'
      '  toc.phone,'
      '  toc.city,'
      '  toc.country,'
      '  toc.region,'
      '  fromc.name as fromname'
      'FROM'
      '  gd_docrealization docr'
      'JOIN'
      '  gd_document doc ON doc.id = docr.documentkey and'
      '    doc.documenttypekey = :dt'
      'JOIN'
      '  gd_contact toc ON docr.tocontactkey = toc.id '
      'JOIN'
      '  gd_contact fromc ON docr.fromcontactkey = fromc.id '
      'WHERE'
      '  doc.companykey = :ck')
    ModifySQL.Strings = (
      'update gd_docrealization'
      'set'
      '  ISPERMIT = :ISPERMIT'
      'where'
      '  documentkey = :OLD_DOCUMENTKEY')
  end
  inherited gsMainReportManager: TgsReportManager
    GroupID = 2000006
  end
end
