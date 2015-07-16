inherited gdc_frmMDHGRAccount: Tgdc_frmMDHGRAccount
  Left = 257
  Top = 178
  Width = 713
  Height = 503
  Caption = 'gdc_frmMDHGRAccount'
  Menu = MainMenu1
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 453
    Width = 705
  end
  inherited TBDockTop: TTBDock
    Width = 705
    inherited tbMainToolbar: TTBToolbar
      DockPos = -40
    end
    inherited tbMainCustom: TTBToolbar
      Left = 378
      Align = alLeft
      AutoResize = False
      BorderStyle = bsNone
      DockPos = 360
      Visible = True
      object TBControlItem4: TTBControlItem
        Control = lblComp
      end
      object TBControlItem3: TTBControlItem
        Control = ibcmbComp
      end
      object TBControlItem2: TTBControlItem
        Control = lblAcct
      end
      object TBControlItem1: TTBControlItem
        Control = ibcmbAccount
      end
      object lblAcct: TLabel
        Left = 144
        Top = 4
        Width = 32
        Height = 13
        Caption = 'Счет: '
      end
      object lblComp: TLabel
        Left = 0
        Top = 4
        Width = 36
        Height = 13
        Caption = 'Комп.: '
      end
      object ibcmbAccount: TgsIBLookupComboBox
        Left = 176
        Top = 0
        Width = 108
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = SelfTransaction
        ListTable = 'gd_companyaccount'
        ListField = 'account'
        KeyField = 'id'
        Condition = '(disabled = 0 or (disabled is null))'
        OnCreateNewObject = ibcmbAccountCreateNewObject
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        OnChange = ibcmbAccountChange
      end
      object ibcmbComp: TgsIBLookupComboBox
        Left = 36
        Top = 0
        Width = 108
        Height = 21
        HelpContext = 1
        Database = dmDatabase.ibdbGAdmin
        Transaction = SelfTransaction
        ListTable = 'gd_contact'
        ListField = 'name'
        KeyField = 'id'
        Condition = 
          ' EXISTS(SELECT * FROM gd_ourcompany our WHERE our.companykey = g' +
          'd_contact.id) '
        gdClassName = 'TgdcOurCompany'
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        OnChange = ibcmbCompChange
      end
    end
    inherited tbMainInvariant: TTBToolbar
      DockPos = 344
    end
    inherited tbChooseMain: TTBToolbar
      Left = 672
      DockPos = 392
    end
  end
  inherited TBDockLeft: TTBDock
    Height = 393
  end
  inherited TBDockRight: TTBDock
    Left = 696
    Height = 393
  end
  inherited TBDockBottom: TTBDock
    Top = 444
    Width = 705
  end
  inherited pnlWorkArea: TPanel
    Width = 687
    Height = 393
    inherited sMasterDetail: TSplitter
      Width = 687
    end
    inherited spChoose: TSplitter
      Top = 288
      Width = 687
    end
    inherited pnlMain: TPanel
      Width = 687
      inherited ibgrMain: TgsIBGrid
        Width = 527
      end
    end
    inherited pnChoose: TPanel
      Top = 294
      Width = 687
      inherited pnButtonChoose: TPanel
        Left = 582
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 582
      end
      inherited pnlChooseCaption: TPanel
        Width = 687
      end
    end
    inherited pnlDetail: TPanel
      Width = 687
      Height = 115
      inherited TBDockDetail: TTBDock
        Width = 687
      end
      inherited pnlSearchDetail: TPanel
        Height = 89
        inherited sbSearchDetail: TScrollBox
          Height = 62
        end
      end
      inherited ibgrDetail: TgsIBGrid
        Width = 527
        Height = 89
      end
    end
  end
  inherited alMain: TActionList
    Left = 85
    Top = 88
  end
  inherited pmMain: TPopupMenu
    Left = 205
    Top = 80
  end
  inherited dsMain: TDataSource
    Left = 115
    Top = 80
  end
  inherited dsDetail: TDataSource
    Left = 410
    Top = 230
  end
  inherited pmDetail: TPopupMenu
    Left = 350
    Top = 230
  end
  object SelfTransaction: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 175
    Top = 80
  end
  object MainMenu1: TMainMenu
    Left = 96
    Top = 96
  end
end
