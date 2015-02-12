inherited gdc_frmDocumentType: Tgdc_frmDocumentType
  Left = 262
  Top = 136
  Width = 1067
  Height = 749
  Caption = 'Типовые документы'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 692
    Width = 1051
  end
  inherited TBDockTop: TTBDock
    Width = 1051
  end
  inherited TBDockLeft: TTBDock
    Height = 632
  end
  inherited TBDockRight: TTBDock
    Left = 1042
    Height = 632
  end
  inherited TBDockBottom: TTBDock
    Top = 683
    Width = 1051
  end
  inherited pnlWorkArea: TPanel
    Width = 1033
    Height = 632
    inherited sMasterDetail: TSplitter
      Height = 527
    end
    inherited spChoose: TSplitter
      Top = 527
      Width = 1033
    end
    inherited pnlMain: TPanel
      Height = 527
      inherited pnlSearchMain: TPanel
        Height = 527
        inherited sbSearchMain: TScrollBox
          Height = 500
        end
      end
      inherited tvGroup: TgsDBTreeView
        Height = 527
        OnGetImageIndex = tvGroupGetImageIndex
      end
    end
    inherited pnChoose: TPanel
      Top = 533
      Width = 1033
      inherited pnButtonChoose: TPanel
        Left = 928
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 928
      end
      inherited pnlChooseCaption: TPanel
        Width = 1033
      end
    end
    inherited pnlDetail: TPanel
      Width = 861
      Height = 527
      inherited TBDockDetail: TTBDock
        Width = 861
      end
      inherited pnlSearchDetail: TPanel
        Height = 501
        inherited sbSearchDetail: TScrollBox
          Height = 474
        end
      end
      inherited ibgrDetail: TgsIBGrid
        Width = 701
        Height = 501
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
    inherited actDetailNew: TAction
      Visible = False
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
    Left = 137
    Top = 222
  end
end
