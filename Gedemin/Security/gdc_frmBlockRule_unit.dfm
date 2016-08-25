inherited gdc_frmBlockRule: Tgdc_frmBlockRule
  Left = 205
  Top = 133
  Width = 928
  Height = 480
  Caption = 'gdc_frmBlockRule'
  Font.Name = 'Tahoma'
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 425
    Width = 920
  end
  inherited TBDockTop: TTBDock
    Width = 920
    inherited tbMainCustom: TTBToolbar
      object TBItem2: TTBItem
        Action = actPrevBlockRule
      end
      object TBItem1: TTBItem
        Action = actNextBlockRule
      end
    end
  end
  inherited TBDockLeft: TTBDock
    Height = 376
  end
  inherited TBDockRight: TTBDock
    Left = 911
    Height = 376
  end
  inherited TBDockBottom: TTBDock
    Top = 444
    Width = 920
  end
  inherited pnlWorkArea: TPanel
    Width = 902
    Height = 376
    inherited spChoose: TSplitter
      Top = 273
      Width = 902
    end
    inherited pnlMain: TPanel
      Width = 902
      Height = 273
      inherited pnlSearchMain: TPanel
        Height = 273
        inherited sbSearchMain: TScrollBox
          Height = 235
        end
        inherited pnlSearchMainButton: TPanel
          Top = 235
        end
      end
      inherited ibgrMain: TgsIBGrid
        Width = 742
        Height = 273
      end
    end
    inherited pnChoose: TPanel
      Top = 277
      Width = 902
      inherited pnButtonChoose: TPanel
        Left = 797
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 797
      end
      inherited pnlChooseCaption: TPanel
        Width = 902
      end
    end
  end
  inherited alMain: TActionList
    object actPrevBlockRule: TAction
      Category = 'Navigation'
      Caption = 'Предыдущее правило блокировки'
      ImageIndex = 47
      OnExecute = actPrevBlockRuleExecute
    end
    object actNextBlockRule: TAction
      Category = 'Navigation'
      Caption = 'Следующее правило блокировки'
      ImageIndex = 48
      OnExecute = actNextBlockRuleExecute
    end
  end
  object gdcBlockRule: TgdcBlockRule
    Left = 481
    Top = 193
  end
end
