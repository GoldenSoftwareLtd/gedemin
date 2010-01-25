inherited gdc_frmInvSelectRemains: Tgdc_frmInvSelectRemains
  Left = 243
  Top = 74
  Width = 724
  Height = 491
  Caption = 'Выбор остатков'
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 445
    Width = 716
  end
  inherited TBDockTop: TTBDock
    Width = 716
  end
  inherited TBDockLeft: TTBDock
    Height = 384
  end
  inherited TBDockRight: TTBDock
    Left = 707
    Height = 384
  end
  inherited TBDockBottom: TTBDock
    Top = 436
    Width = 716
  end
  inherited pnlWorkArea: TPanel
    Width = 698
    Height = 384
    inherited spChoose: TSplitter
      Top = 281
      Width = 698
    end
    inherited pnlMain: TPanel
      Width = 698
      Height = 281
      inherited Splitter1: TSplitter
        Height = 281
      end
      inherited pnlSearchMain: TPanel
        Height = 281
        inherited sbSearchMain: TScrollBox
          Height = 243
        end
        inherited pnlSearchMainButton: TPanel
          Top = 243
        end
      end
      inherited pnMain: TPanel
        Height = 281
        inherited tvGroup: TgsDBTreeView
          Height = 281
        end
      end
      inherited pnDetail: TPanel
        Width = 318
        Height = 281
        inherited ibgrDetail: TgsIBGrid
          Width = 318
          Height = 281
          CheckBox.FieldName = 'CHOOSEID'
          CheckBox.Visible = True
          CheckBox.AfterCheckEvent = ibgrDetailClickedCheck
          CheckBox.FirstColumn = True
          OnClickedCheck = ibgrDetailClickedCheck
        end
      end
    end
    inherited pnChoose: TPanel
      Top = 285
      Width = 698
      inherited pnButtonChoose: TPanel
        Left = 593
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 593
        Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgTabs, dgConfirmDelete, dgCancelOnExit, dgMultiSelect]
      end
      inherited pnlChooseCaption: TPanel
        Width = 698
      end
    end
  end
  inherited alMain: TActionList
    inherited actCommit: TAction
      ShortCut = 116
    end
  end
  inherited gdcGoodGroup: TgdcGoodGroup
    CachedUpdates = True
  end
  object gdcInvRemains: TgdcInvRemains
    AfterPost = gdcInvRemainsAfterPost
    MasterSource = dsDetail
    MasterField = 'LB;RB'
    DetailField = 'LB;RB'
    CachedUpdates = True
    Left = 344
    Top = 216
  end
end
