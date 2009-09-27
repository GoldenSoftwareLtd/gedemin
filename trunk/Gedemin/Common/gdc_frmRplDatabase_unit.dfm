inherited gdc_frmRplDatabase: Tgdc_frmRplDatabase
  Left = 280
  Top = 236
  Width = 870
  Height = 640
  Caption = 'gdc_frmRplDatabase'
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 585
    Width = 862
  end
  inherited TBDockTop: TTBDock
    Width = 862
    inherited tbMainCustom: TTBToolbar
      object TBControlItem1: TTBControlItem
        Control = lblMainBase
      end
      object TBSeparatorItem1: TTBSeparatorItem
      end
      object TBControlItem2: TTBControlItem
        Control = Button1
      end
      object lblMainBase: TLabel
        Left = 0
        Top = 4
        Width = 61
        Height = 13
        Caption = 'lblMainBase  '
      end
      object Button1: TButton
        Left = 67
        Top = 1
        Width = 75
        Height = 19
        Action = actSetMainBase
        TabOrder = 0
      end
    end
  end
  inherited TBDockLeft: TTBDock
    Height = 536
  end
  inherited TBDockRight: TTBDock
    Left = 853
    Height = 536
  end
  inherited TBDockBottom: TTBDock
    Top = 604
    Width = 862
  end
  inherited pnlWorkArea: TPanel
    Width = 844
    Height = 536
    inherited spChoose: TSplitter
      Top = 433
      Width = 844
    end
    inherited pnlMain: TPanel
      Width = 844
      Height = 433
      inherited pnlSearchMain: TPanel
        Height = 433
        inherited sbSearchMain: TScrollBox
          Height = 395
        end
        inherited pnlSearchMainButton: TPanel
          Top = 395
        end
      end
      inherited ibgrMain: TgsIBGrid
        Width = 684
        Height = 433
      end
    end
    inherited pnChoose: TPanel
      Top = 437
      Width = 844
      inherited pnButtonChoose: TPanel
        Left = 739
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 739
      end
      inherited pnlChooseCaption: TPanel
        Width = 844
      end
    end
  end
  inherited alMain: TActionList
    object actSetMainBase: TAction
      Caption = 'Назначить'
      Hint = 'Сделать выбранную в списке базу главной в схеме репликации'
      OnExecute = actSetMainBaseExecute
      OnUpdate = actSetMainBaseUpdate
    end
  end
  object gdcRplDatabase: TgdcRplDatabase
    Left = 416
    Top = 296
  end
end
