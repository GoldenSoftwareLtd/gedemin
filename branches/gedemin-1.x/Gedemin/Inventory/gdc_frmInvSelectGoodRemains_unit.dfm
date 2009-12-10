inherited gdc_frmInvSelectGoodRemains: Tgdc_frmInvSelectGoodRemains
  Left = 239
  Top = 202
  Caption = 'Выбор остатков'
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlWorkArea: TPanel
    inherited pnlMain: TPanel
      inherited pnMain: TPanel
        Visible = False
      end
      inherited pnDetail: TPanel
        inherited ibgrDetail: TgsIBGrid
          CheckBox.FieldName = 'CHOOSEID'
          CheckBox.Visible = True
          CheckBox.AfterCheckEvent = ibgrDetailClickedCheck
          CheckBox.FirstColumn = True
          OnClickedCheck = ibgrDetailClickedCheck
        end
      end
    end
    inherited pnChoose: TPanel
      inherited ibgrChoose: TgsIBGrid
        Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgTabs, dgConfirmDelete, dgCancelOnExit, dgMultiSelect]
      end
    end
  end
  object gdcInvRemains: TgdcInvGoodRemains
    AfterPost = gdcInvGoodRemainsAfterPost
    CachedUpdates = True
    Left = 424
    Top = 232
  end
end
