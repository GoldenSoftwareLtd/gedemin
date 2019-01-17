inherited gdc_frmDepartment: Tgdc_frmDepartment
  Left = 258
  Top = 181
  Width = 747
  Height = 521
  Caption = '�������������'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 471
    Width = 739
  end
  inherited TBDockTop: TTBDock
    Width = 739
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
      Left = 430
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
        Caption = '�����������   '
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
      Left = 706
    end
  end
  inherited TBDockLeft: TTBDock
    Height = 411
  end
  inherited TBDockRight: TTBDock
    Left = 730
    Height = 411
  end
  inherited TBDockBottom: TTBDock
    Top = 462
    Width = 739
  end
  inherited pnlWorkArea: TPanel
    Width = 721
    Height = 411
    inherited sMasterDetail: TSplitter
      Height = 306
    end
    inherited spChoose: TSplitter
      Top = 306
      Width = 721
    end
    inherited pnlMain: TPanel
      Height = 306
      inherited pnlSearchMain: TPanel
        Height = 306
        inherited sbSearchMain: TScrollBox
          Height = 279
        end
      end
      inherited tvGroup: TgsDBTreeView
        Height = 306
      end
    end
    inherited pnChoose: TPanel
      Top = 312
      Width = 721
      inherited pnButtonChoose: TPanel
        Left = 616
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 616
      end
      inherited pnlChooseCaption: TPanel
        Width = 721
      end
    end
    inherited pnlDetail: TPanel
      Width = 549
      Height = 306
      inherited TBDockDetail: TTBDock
        Width = 549
      end
      inherited pnlSearchDetail: TPanel
        Height = 280
        inherited sbSearchDetail: TScrollBox
          Height = 253
        end
      end
      inherited ibgrDetail: TgsIBGrid
        Width = 389
        Height = 280
      end
    end
  end
  inherited alMain: TActionList
    Left = 55
    Top = 170
    object actSubNew: TAction
      Category = 'Main'
      Caption = '�������� ����������...'
      Hint = '�������� ����������...'
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
