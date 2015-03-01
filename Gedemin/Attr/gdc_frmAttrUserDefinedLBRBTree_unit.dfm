inherited gdc_frmAttrUserDefinedLBRBTree: Tgdc_frmAttrUserDefinedLBRBTree
  Left = 241
  Top = 106
  Width = 607
  Height = 467
  Caption = 'Таблица пользователя'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 410
    Width = 591
  end
  inherited TBDockTop: TTBDock
    Width = 591
  end
  inherited TBDockLeft: TTBDock
    Height = 350
  end
  inherited TBDockRight: TTBDock
    Left = 582
    Height = 350
  end
  inherited TBDockBottom: TTBDock
    Top = 401
    Width = 591
  end
  inherited pnlWorkArea: TPanel
    Width = 573
    Height = 350
    inherited sMasterDetail: TSplitter
      Height = 245
    end
    inherited spChoose: TSplitter
      Top = 245
      Width = 573
    end
    inherited pnlMain: TPanel
      Height = 245
      inherited pnlSearchMain: TPanel
        Height = 245
        inherited sbSearchMain: TScrollBox
          Height = 218
        end
      end
      inherited tvGroup: TgsDBTreeView
        Height = 245
        DisplayField = ''
        ReadOnly = True
        StateImages = nil
        MainFolder = False
        WithCheckBox = False
      end
    end
    inherited pnChoose: TPanel
      Top = 251
      Width = 573
      inherited pnButtonChoose: TPanel
        Left = 468
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 468
      end
      inherited pnlChooseCaption: TPanel
        Width = 573
      end
    end
    inherited pnlDetail: TPanel
      Width = 401
      Height = 245
      inherited TBDockDetail: TTBDock
        Width = 401
      end
      inherited pnlSearchDetail: TPanel
        Height = 219
        inherited sbSearchDetail: TScrollBox
          Height = 192
        end
      end
      inherited ibgrDetail: TgsIBGrid
        Width = 241
        Height = 219
      end
    end
  end
  inherited pmMain: TPopupMenu
    Left = 113
    Top = 145
  end
  inherited dsMain: TDataSource
    DataSet = Master
    Top = 174
  end
  inherited dsDetail: TDataSource
    DataSet = Detail
    Left = 436
    Top = 240
  end
  inherited pmDetail: TPopupMenu
    Left = 465
    Top = 269
  end
  object Master: TgdcAttrUserDefinedLBRBTree
    Left = 113
    Top = 174
  end
  object Detail: TgdcAttrUserDefinedLBRBTree
    MasterSource = dsMain
    MasterField = 'LB;RB'
    DetailField = 'LB;RB'
    SubSet = 'ByLBRB'
    Left = 436
    Top = 269
  end
end
