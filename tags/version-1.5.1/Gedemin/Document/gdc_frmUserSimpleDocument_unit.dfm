inherited gdc_frmUserSimpleDocument: Tgdc_frmUserSimpleDocument
  Left = 241
  Top = 120
  Width = 783
  Height = 540
  Caption = 'gdc_frmUserSimpleDocument'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 494
    Width = 775
  end
  inherited TBDockTop: TTBDock
    Width = 775
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
    Height = 436
  end
  inherited TBDockRight: TTBDock
    Left = 766
    Height = 436
  end
  inherited TBDockBottom: TTBDock
    Top = 485
    Width = 775
  end
  inherited pnlWorkArea: TPanel
    Width = 757
    Height = 436
    inherited spChoose: TSplitter
      Top = 333
      Width = 757
    end
    inherited pnlMain: TPanel
      Width = 757
      Height = 333
      inherited pnlSearchMain: TPanel
        Height = 333
        inherited sbSearchMain: TScrollBox
          Height = 295
        end
        inherited pnlSearchMainButton: TPanel
          Top = 295
        end
      end
      inherited ibgrMain: TgsIBGrid
        Width = 597
        Height = 333
      end
    end
    inherited pnChoose: TPanel
      Top = 337
      Width = 757
      inherited pnButtonChoose: TPanel
        Left = 652
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 652
      end
      inherited pnlChooseCaption: TPanel
        Width = 757
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
