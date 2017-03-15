inherited gdc_frmUserSimpleDocument: Tgdc_frmUserSimpleDocument
  Left = 616
  Width = 783
  Height = 540
  Caption = 'gdc_frmUserSimpleDocument'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 482
    Width = 767
  end
  inherited TBDockTop: TTBDock
    Width = 767
    inherited tbMainInvariant: TTBToolbar
      object TBItem2: TTBItem
        Action = actCreateEntry
      end
      object TBItem1: TTBItem
        Action = actGotoEntry
      end
    end
  end
  inherited TBDockLeft: TTBDock
    Height = 422
  end
  inherited TBDockRight: TTBDock
    Left = 758
    Height = 422
  end
  inherited TBDockBottom: TTBDock
    Top = 473
    Width = 767
  end
  inherited pnlWorkArea: TPanel
    Width = 749
    Height = 422
    inherited spChoose: TSplitter
      Top = 319
      Width = 749
    end
    inherited pnlMain: TPanel
      Width = 749
      Height = 319
      inherited pnlSearchMain: TPanel
        Height = 319
        inherited sbSearchMain: TScrollBox
          Height = 292
        end
      end
      inherited ibgrMain: TgsIBGrid
        Width = 589
        Height = 319
      end
    end
    inherited pnChoose: TPanel
      Top = 323
      Width = 749
      inherited pnButtonChoose: TPanel
        Left = 644
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 644
      end
      inherited pnlChooseCaption: TPanel
        Width = 749
      end
    end
  end
  inherited alMain: TActionList
    object actCreateEntry: TAction
      Category = 'Commands'
      Caption = 'Провести проводки'
      Hint = 'Провести проводки по документам'
      ImageIndex = 104
      OnExecute = actCreateEntryExecute
      OnUpdate = actCreateEntryUpdate
    end
    object actGotoEntry: TAction
      Category = 'Commands'
      Caption = 'Перейти на проводку'
      Hint = 'Перейти на проводку'
      ImageIndex = 53
      OnExecute = actGotoEntryExecute
    end
  end
  inherited dsMain: TDataSource
    DataSet = gdcUserDocument
  end
  inherited gdMacrosMenu: TgdMacrosMenu
    Top = 103
  end
  object gdcUserDocument: TgdcUserDocument
    Left = 169
    Top = 105
  end
  object IBTransaction: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 217
    Top = 105
  end
end
