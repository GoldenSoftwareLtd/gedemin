inherited gdc_frmDepartment: Tgdc_frmDepartment
  Left = 258
  Top = 181
  Width = 747
  Height = 521
  Caption = 'Подразделения'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 463
    Width = 731
  end
  inherited TBDockTop: TTBDock
    Width = 731
    inherited tbMainToolbar: TTBToolbar
      object tbsiNew: TTBSubmenuItem [0]
        Action = actNew
        DropdownCombo = True
        object tbiMenuNew: TTBItem
          Action = actNew
        end
        object tbiMenuSubNew: TTBItem
          Action = actSubNew
        end
      end
      inherited tbiNew: TTBItem
        Visible = False
      end
    end
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
    inherited tbMainInvariant: TTBToolbar
      Left = 286
    end
    inherited tbChooseMain: TTBToolbar
      Left = 698
    end
  end
  inherited TBDockLeft: TTBDock
    Height = 403
  end
  inherited TBDockRight: TTBDock
    Left = 722
    Height = 403
  end
  inherited TBDockBottom: TTBDock
    Top = 454
    Width = 731
  end
  inherited pnlWorkArea: TPanel
    Width = 713
    Height = 403
    inherited sMasterDetail: TSplitter
      Height = 298
    end
    inherited spChoose: TSplitter
      Top = 298
      Width = 713
    end
    inherited pnlMain: TPanel
      Height = 298
      inherited pnlSearchMain: TPanel
        Height = 298
        inherited sbSearchMain: TScrollBox
          Height = 271
        end
      end
      inherited tvGroup: TgsDBTreeView
        Height = 298
      end
    end
    inherited pnChoose: TPanel
      Top = 304
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
      Height = 298
      inherited TBDockDetail: TTBDock
        Width = 541
      end
      inherited pnlSearchDetail: TPanel
        Height = 272
        inherited sbSearchDetail: TScrollBox
          Height = 245
        end
      end
      inherited ibgrDetail: TgsIBGrid
        Width = 381
        Height = 272
      end
    end
  end
  inherited alMain: TActionList
    Left = 55
    Top = 170
    object actSubNew: TAction
      Category = 'Main'
      Caption = 'Добавить подуровень...'
      Hint = 'Добавить подуровень...'
      ImageIndex = 0
      OnExecute = actSubNewExecute
    end
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
