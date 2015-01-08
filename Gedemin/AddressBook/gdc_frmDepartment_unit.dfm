inherited gdc_frmDepartment: Tgdc_frmDepartment
  Left = 220
  Top = 184
  Width = 747
  Height = 521
  Caption = 'Подразделения'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 464
    Width = 731
  end
  inherited TBDockTop: TTBDock
    Width = 731
    inherited tbMainCustom: TTBToolbar
      Left = 422
      DockPos = 454
      object TBControlItem2: TTBControlItem
        Control = Label1
      end
      object TBControlItem1: TTBControlItem
        Control = ibcmbCompany
      end
      object Label1: TLabel
        Left = 0
        Top = 4
        Width = 75
        Height = 13
        Caption = 'Организация   '
      end
      object ibcmbCompany: TgsIBLookupComboBox
        Left = 75
        Top = 0
        Width = 191
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = IBTransaction
        ListTable = 'gd_contact'
        ListField = 'name'
        KeyField = 'ID'
        Condition = 'contacttype in (3, 5)'
        gdClassName = 'TgdcCompany'
        ItemHeight = 13
        TabOrder = 0
        OnChange = ibcmbCompanyChange
      end
    end
    inherited tbChooseMain: TTBToolbar
      Left = 698
    end
  end
  inherited TBDockLeft: TTBDock
    Height = 404
  end
  inherited TBDockRight: TTBDock
    Left = 722
    Height = 404
  end
  inherited TBDockBottom: TTBDock
    Top = 455
    Width = 731
  end
  inherited pnlWorkArea: TPanel
    Width = 713
    Height = 404
    inherited sMasterDetail: TSplitter
      Height = 299
    end
    inherited spChoose: TSplitter
      Top = 299
      Width = 713
    end
    inherited pnlMain: TPanel
      Height = 299
      inherited pnlSearchMain: TPanel
        Height = 299
        inherited sbSearchMain: TScrollBox
          Height = 272
        end
      end
      inherited tvGroup: TgsDBTreeView
        Height = 299
      end
    end
    inherited pnChoose: TPanel
      Top = 305
      Width = 713
      inherited pnButtonChoose: TPanel
        Left = 608
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 608
      end
      inherited pnlChooseCaption: TPanel
        Width = 713
      end
    end
    inherited pnlDetail: TPanel
      Width = 541
      Height = 299
      inherited TBDockDetail: TTBDock
        Width = 541
      end
      inherited pnlSearchDetail: TPanel
        Height = 273
        inherited sbSearchDetail: TScrollBox
          Height = 246
        end
      end
      inherited ibgrDetail: TgsIBGrid
        Width = 381
        Height = 273
      end
    end
  end
  inherited alMain: TActionList
    Left = 55
    Top = 170
  end
  inherited pmMain: TPopupMenu
    Left = 115
    Top = 170
  end
  inherited dsMain: TDataSource
    DataSet = gdcDepartment
    Left = 85
    Top = 170
  end
  inherited dsDetail: TDataSource
    DataSet = gdcEmployee
    Left = 350
    Top = 270
  end
  inherited pmDetail: TPopupMenu
    Left = 380
    Top = 270
  end
  object gdcDepartment: TgdcDepartment
    OnNewRecord = gdcDepartmentNewRecord
    SubSet = 'ByLBRBDepartment'
    Left = 145
    Top = 170
  end
  object IBTransaction: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 410
    Top = 270
  end
  object gdcEmployee: TgdcEmployee
    MasterSource = dsMain
    MasterField = 'LB;RB'
    DetailField = 'LB;RB'
    SubSet = 'ByLBRB'
    Left = 352
    Top = 232
  end
end
