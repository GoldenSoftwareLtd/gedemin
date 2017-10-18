inherited gdc_frmBankStatementBase: Tgdc_frmBankStatementBase
  Left = 574
  Top = 155
  Width = 764
  Height = 496
  Caption = 'gdc_frmBankStatementBase'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 437
    Width = 748
  end
  inherited TBDockTop: TTBDock
    Width = 748
    inherited tbMainCustom: TTBToolbar
      Left = 421
      BorderStyle = bsSingle
      inherited ibcmbAccount: TgsIBLookupComboBox
        Condition = '(disabled=0 or (disabled is null))'
      end
    end
    inherited tbMainInvariant: TTBToolbar
      Left = 336
      object TBItem2: TTBItem [3]
        Action = actCreateEntry
      end
    end
    inherited tbChooseMain: TTBToolbar
      Left = 715
    end
  end
  inherited TBDockLeft: TTBDock
    Height = 377
  end
  inherited TBDockRight: TTBDock
    Left = 739
    Height = 377
  end
  inherited TBDockBottom: TTBDock
    Top = 428
    Width = 748
  end
  inherited pnlWorkArea: TPanel
    Width = 730
    Height = 378
    inherited sMasterDetail: TSplitter
      Width = 730
    end
    inherited spChoose: TSplitter
      Top = 273
      Width = 730
    end
    inherited pnlMain: TPanel
      Width = 730
      inherited pnlSearchMain: TPanel
        Top = 29
        Height = 138
        inherited sbSearchMain: TScrollBox
          Height = 111
        end
      end
      inherited ibgrMain: TgsIBGrid
        Top = 29
        Width = 570
        Height = 138
      end
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 730
        Height = 29
        Align = alTop
        TabOrder = 2
        object lblCurrency: TLabel
          Left = 285
          Top = 8
          Width = 37
          Height = 13
          Caption = '<Curr>'
        end
        object Label2: TLabel
          Left = 240
          Top = 8
          Width = 43
          Height = 13
          Caption = 'Валюта:'
        end
        object sbtnSaldo: TSpeedButton
          Left = 159
          Top = 3
          Width = 61
          Height = 22
          Action = actSaldo
          ParentShowHint = False
          ShowHint = True
        end
        object lblShowSaldo: TLabel
          Left = 5
          Top = 8
          Width = 85
          Height = 13
          Caption = 'Сальдо на дату:'
        end
        object xdeForDate: TxDateEdit
          Left = 93
          Top = 3
          Width = 63
          Height = 21
          Kind = kDate
          CurrentDateTimeAtStart = True
          EditMask = '!99\.99\.9999;1;_'
          MaxLength = 10
          TabOrder = 0
          Text = '07.07.2017'
        end
      end
    end
    inherited pnChoose: TPanel
      Top = 279
      Width = 730
      inherited pnButtonChoose: TPanel
        Left = 625
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 625
      end
      inherited pnlChooseCaption: TPanel
        Width = 730
      end
    end
    inherited pnlDetail: TPanel
      Width = 730
      Height = 100
      inherited TBDockDetail: TTBDock
        Width = 730
        inherited tbDetailToolbar: TTBToolbar
          object TBItem1: TTBItem [15]
            Action = actGotoEntry
          end
        end
        inherited tbDetailCustom: TTBToolbar
          Left = 298
          Visible = True
        end
      end
      inherited pnlSearchDetail: TPanel
        Height = 74
        inherited sbSearchDetail: TScrollBox
          Height = 47
        end
      end
      inherited ibgrDetail: TgsIBGrid
        Width = 570
        Height = 74
      end
    end
  end
  inherited alMain: TActionList
    inherited actDetailEdit: TAction
      Caption = 'Изменить...'
    end
    object actSearchClient: TAction
      Caption = 'Идентификация клиентов по рассчетному счету'
      Hint = 'Идентификация клиентов по рассчетному счету'
      ShortCut = 49219
    end
    object actSaldo: TAction
      Caption = 'Показать'
      Hint = 'Пересчитывает сальдо по счету'
      OnExecute = actSaldoExecute
    end
    object actCreateEntry: TAction
      Category = 'Main'
      Caption = 'Провести проводки по документу'
      Hint = 'Провести проводки по документу'
      ImageIndex = 104
      OnExecute = actCreateEntryExecute
      OnUpdate = actCreateEntryUpdate
    end
    object actGotoEntry: TAction
      Category = 'Detail'
      Caption = 'Перейти на проводку'
      Hint = 'Перейти на проводку'
      ImageIndex = 53
      OnExecute = actGotoEntryExecute
    end
  end
  inherited dsMain: TDataSource
    DataSet = gdcBankStatement
  end
  inherited dsDetail: TDataSource
    Left = 380
  end
  inherited pmDetail: TPopupMenu
    Left = 342
    object N11: TMenuItem
      Caption = '-'
    end
  end
  inherited MainMenu1: TMainMenu
    Left = 112
    Top = 120
  end
  object gdcBankStatement: TgdcBankStatement
    AfterOpen = gdcBankStatementAfterOpen
    AfterScroll = gdcBankStatementAfterScroll
    SubSet = 'ByAccount'
    Left = 144
    Top = 80
  end
  object dsCatalogue: TDataSource
    Left = 370
    Top = 90
  end
end
