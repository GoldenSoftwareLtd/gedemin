inherited gdc_frmBlockRule: Tgdc_frmBlockRule
  Left = 283
  Top = 77
  Width = 802
  Height = 591
  Caption = 'gdc_frmBlockRule'
  Font.Name = 'MS Sans Serif'
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 548
    Width = 794
    Height = 7
  end
  inherited TBDockTop: TTBDock
    Width = 794
    inherited tbMainToolbar: TTBToolbar
      object tbBlokRupePriorUp: TTBItem [6]
        Action = actBlockRulePriorUp
        Caption = 'Повысить приоритет'
        Hint = 'Повысить приоритет'
      end
      object tbBlokRupePriorDown: TTBItem [7]
        Action = actBlockRulePriorDown
        Caption = 'Понизить приоритет'
        Hint = 'Понизить приоритет'
      end
      object TBSeparatorItem1: TTBSeparatorItem [8]
      end
    end
    inherited tbMainInvariant: TTBToolbar
      Left = 379
    end
  end
  inherited TBDockLeft: TTBDock
    Height = 499
  end
  inherited TBDockRight: TTBDock
    Left = 785
    Height = 499
  end
  inherited TBDockBottom: TTBDock
    Top = 555
    Width = 794
  end
  inherited pnlWorkArea: TPanel
    Width = 776
    Height = 499
    inherited spChoose: TSplitter
      Top = 395
      Width = 776
      Height = 5
    end
    inherited pnlMain: TPanel
      Width = 776
      Height = 395
      inherited pnlSearchMain: TPanel
        Height = 395
        inherited sbSearchMain: TScrollBox
          Height = 357
        end
        inherited pnlSearchMainButton: TPanel
          Top = 357
        end
      end
      inherited ibgrMain: TgsIBGrid
        Width = 616
        Height = 395
      end
    end
    inherited pnChoose: TPanel
      Top = 400
      Width = 776
      inherited pnButtonChoose: TPanel
        Left = 671
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 671
      end
      inherited pnlChooseCaption: TPanel
        Width = 776
      end
    end
  end
  inherited alMain: TActionList
    object actBlockRulePriorUp: TAction
      Category = 'Commands'
      Caption = 'Переместить вверх'
      ImageIndex = 47
      OnExecute = actBlockRulePriorUpExecute
      OnUpdate = actBlockRulePriorUpUpdate
    end
    object actBlockRulePriorDown: TAction
      Category = 'Commands'
      Caption = 'Переместить вниз'
      ImageIndex = 48
      OnExecute = actBlockRulePriorDownExecute
      OnUpdate = actBlockRulePriorDownUpdate
    end
  end
  object DataSource1: TDataSource
    DataSet = gdcBlockRule
    Left = 361
    Top = 89
  end
  object gdcBlockRule: TgdcBlockRule
    BeforeDelete = gdcBlockRuleBeforeDelete
    OnGetOrderClause = gdcBlockRuleGetOrderClause
    ExclTblLst.Strings = (
      'GD_BLOCK_DT'
      'GD_BLOCK_RULE'
      'GD_USER'
      'GD_USERGROUP')
    Left = 249
    Top = 177
  end
end
