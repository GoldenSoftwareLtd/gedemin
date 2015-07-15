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
    Top = 433
    Width = 708
  end
  inherited TBDockTop: TTBDock
    Width = 708
    inherited tbMainCustom: TTBToolbar
      Left = 675
    end
    inherited tbMainInvariant: TTBToolbar
      inherited cbAllRemains: TCheckBox
        Left = 159
      end
    end
    inherited tbChooseMain: TTBToolbar
      Left = 421
    end
  end
  inherited TBDockLeft: TTBDock
    Height = 370
  end
  inherited TBDockRight: TTBDock
    Left = 699
    Height = 370
  end
  inherited TBDockBottom: TTBDock
    Top = 424
    Width = 708
  end
  inherited pnlWorkArea: TPanel
    Width = 690
    Height = 370
    inherited spChoose: TSplitter
      Top = 267
      Width = 690
    end
    inherited pnlMain: TPanel
      Width = 690
      Height = 267
      inherited Splitter1: TSplitter
        Height = 267
      end
      inherited pnlSearchMain: TPanel
        Height = 267
        inherited sbSearchMain: TScrollBox
          Height = 240
        end
      end
      inherited pnMain: TPanel
        Height = 267
        inherited tvGroup: TgsDBTreeView
          Height = 267
        end
      end
      inherited pnDetail: TPanel
        Width = 310
        Height = 267
        inherited ibgrDetail: TgsIBGrid
          Width = 310
          Height = 267
          CheckBox.FieldName = 'CHOOSEID'
          CheckBox.Visible = True
          CheckBox.AfterCheckEvent = ibgrDetailClickedCheck
          CheckBox.FirstColumn = True
          OnClickedCheck = ibgrDetailClickedCheck
        end
      end
    end
    inherited pnChoose: TPanel
      Top = 271
      Width = 690
      inherited pnButtonChoose: TPanel
        Left = 585
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 585
        Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgTabs, dgConfirmDelete, dgCancelOnExit, dgMultiSelect]
      end
      inherited pnlChooseCaption: TPanel
        Width = 690
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
    SubSet = 'ByGroupKey'
    CachedUpdates = True
    Left = 344
    Top = 216
  end
end
