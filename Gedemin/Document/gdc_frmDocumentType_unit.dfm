inherited gdc_frmDocumentType: Tgdc_frmDocumentType
  Left = 312
  Top = 88
  Width = 775
  Height = 539
  Caption = 'Типовые документы'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 482
    Width = 759
  end
  inherited TBDockTop: TTBDock
    Width = 759
  end
  inherited TBDockLeft: TTBDock
    Height = 422
  end
  inherited TBDockRight: TTBDock
    Left = 750
    Height = 422
  end
  inherited TBDockBottom: TTBDock
    Top = 473
    Width = 759
  end
  inherited pnlWorkArea: TPanel
    Width = 741
    Height = 422
    inherited sMasterDetail: TSplitter
      Height = 317
    end
    inherited spChoose: TSplitter
      Top = 317
      Width = 741
    end
    inherited pnlMain: TPanel
      Height = 317
      inherited pnlSearchMain: TPanel
        Height = 317
        inherited sbSearchMain: TScrollBox
          Height = 290
        end
      end
      inherited tvGroup: TgsDBTreeView
        Height = 317
        OnGetImageIndex = tvGroupGetImageIndex
      end
    end
    inherited pnChoose: TPanel
      Top = 323
      Width = 741
      inherited pnButtonChoose: TPanel
        Left = 636
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 636
      end
      inherited pnlChooseCaption: TPanel
        Width = 741
      end
    end
    inherited pnlDetail: TPanel
      Width = 569
      Height = 317
      inherited TBDockDetail: TTBDock
        Width = 569
      end
      inherited pnlSearchDetail: TPanel
        Height = 291
        inherited sbSearchDetail: TScrollBox
          Height = 264
        end
      end
      inherited ibgrDetail: TgsIBGrid
        Width = 409
        Height = 291
      end
    end
  end
  inherited alMain: TActionList
    Top = 135
    object actNewSub: TAction [1]
      Category = 'Main'
      Caption = 'Добавить ветвь...'
      Hint = 'Добавить ветвь...'
      ImageIndex = 0
    end
  end
  inherited pmMain: TPopupMenu
    Left = 113
    Top = 164
  end
  inherited dsMain: TDataSource
    Top = 164
  end
  inherited dsDetail: TDataSource
    DataSet = gdcDocumentType
    Left = 398
    Top = 140
  end
  inherited pmDetail: TPopupMenu
    Left = 458
    Top = 140
  end
  object gdcDocumentType: TgdcDocumentType
    MasterSource = dsMain
    MasterField = 'LB;RB'
    DetailField = 'LB;RB'
    SubSet = 'ByLBRB'
    Left = 428
    Top = 140
  end
  object gdcBaseDocumentType: TgdcBaseDocumentType
    Left = 73
    Top = 206
  end
end
