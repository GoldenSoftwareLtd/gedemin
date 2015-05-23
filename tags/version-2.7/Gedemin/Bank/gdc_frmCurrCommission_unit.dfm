inherited gdc_frmCurrCommission: Tgdc_frmCurrCommission
  Left = 182
  Top = 156
  Width = 601
  Height = 407
  Caption = 'Валютное платежное поручение'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 354
    Width = 593
  end
  inherited TBDockTop: TTBDock
    Width = 593
    inherited tbMainCustom: TTBToolbar
      Left = 454
    end
    inherited tbMainInvariant: TTBToolbar
      Left = 336
    end
    inherited tbChooseMain: TTBToolbar
      Left = 421
    end
  end
  inherited TBDockLeft: TTBDock
    Height = 296
  end
  inherited TBDockRight: TTBDock
    Left = 584
    Height = 296
  end
  inherited TBDockBottom: TTBDock
    Top = 345
    Width = 593
  end
  inherited pnlWorkArea: TPanel
    Width = 575
    Height = 296
    inherited spChoose: TSplitter
      Top = 194
      Width = 575
    end
    inherited pnlMain: TPanel
      Width = 575
      Height = 194
      inherited pnlSearchMain: TPanel
        Top = 31
        Height = 163
        inherited sbSearchMain: TScrollBox
          Height = 133
        end
        inherited pnlSearchMainButton: TPanel
          Top = 133
        end
      end
      inherited ibgrMain: TgsIBGrid
        Top = 31
        Width = 415
        Height = 163
        Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit, dgMultiSelect]
      end
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 575
        Height = 31
        Align = alTop
        TabOrder = 2
        object Label2: TLabel
          Left = 384
          Top = 8
          Width = 43
          Height = 13
          Caption = 'Валюта:'
        end
        object lblCurrency: TLabel
          Left = 429
          Top = 8
          Width = 37
          Height = 13
          Caption = '<Curr>'
        end
      end
    end
    inherited pnChoose: TPanel
      Top = 197
      Width = 575
      inherited pnButtonChoose: TPanel
        Left = 470
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 470
      end
    end
  end
  inherited alMain: TActionList
    Top = 160
  end
  object gdcCurrCommission: TgdcCurrCommission [7]
    AfterOpen = gdcCurrCommissionAfterScroll
    AfterScroll = gdcCurrCommissionAfterScroll
    CachedUpdates = False
    Left = 145
    Top = 160
  end
  inherited pmMain: TPopupMenu
    Top = 160
  end
  inherited dsMain: TDataSource
    DataSet = gdcCurrCommission
    Left = 235
    Top = 160
  end
  inherited gsTransaction: TgsTransaction
    Top = 160
  end
  inherited IBTransaction: TIBTransaction
    Top = 160
  end
end
