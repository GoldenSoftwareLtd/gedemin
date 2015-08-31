inherited gdc_frmDocumentType: Tgdc_frmDocumentType
  Left = 365
  Top = 169
  Width = 795
  Height = 542
  Caption = '������� ���������'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 484
    Width = 779
  end
  inherited TBDockTop: TTBDock
    Width = 779
    inherited tbMainToolbar: TTBToolbar
      inherited tbiNew: TTBItem
        Visible = False
      end
      object TBSubmenuItem1: TTBSubmenuItem [1]
        Action = actNew
        DropdownCombo = True
        object TBItem1: TTBItem
          Action = actNew
        end
        object TBItem2: TTBItem
          Action = actNewSub
        end
      end
    end
    inherited tbMainInvariant: TTBToolbar
      Left = 286
    end
  end
  inherited TBDockLeft: TTBDock
    Height = 424
  end
  inherited TBDockRight: TTBDock
    Left = 770
    Height = 424
  end
  inherited TBDockBottom: TTBDock
    Top = 475
    Width = 779
  end
  inherited pnlWorkArea: TPanel
    Width = 761
    Height = 424
    inherited sMasterDetail: TSplitter
      Height = 319
    end
    inherited spChoose: TSplitter
      Top = 319
      Width = 761
    end
    inherited pnlMain: TPanel
      Height = 319
      inherited pnlSearchMain: TPanel
        Height = 319
        inherited sbSearchMain: TScrollBox
          Height = 292
        end
      end
      inherited tvGroup: TgsDBTreeView
        Height = 319
        Images = dmImages.ilTree
        OnGetImageIndex = tvGroupGetImageIndex
      end
    end
    inherited pnChoose: TPanel
      Top = 325
      Width = 761
      inherited pnButtonChoose: TPanel
        Left = 656
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 656
      end
      inherited pnlChooseCaption: TPanel
        Width = 761
      end
    end
    inherited pnlDetail: TPanel
      Width = 589
      Height = 319
      object splDocumentOptions: TSplitter [0]
        Left = 0
        Top = 272
        Width = 589
        Height = 6
        Cursor = crVSplit
        Align = alBottom
      end
      inherited TBDockDetail: TTBDock
        Width = 589
        inherited tbDetailToolbar: TTBToolbar
          object tbsmNew: TTBSubmenuItem [0]
            Caption = '��������'
            DropdownCombo = True
            Hint = '�������� ��������'
            ImageIndex = 0
            OnClick = tbsmNewClick
            object tbiAddUserDoc: TTBItem
              Action = actAddUserDoc
            end
            object tbiAddInvDocument: TTBItem
              Action = actAddInvDocument
            end
            object tbiAddInvPriceList: TTBItem
              Action = actAddInvPriceList
            end
          end
        end
        inherited tbDetailCustom: TTBToolbar
          Left = 286
        end
      end
      inherited pnlSearchDetail: TPanel
        Height = 246
        inherited sbSearchDetail: TScrollBox
          Height = 219
        end
      end
      inherited ibgrDetail: TgsIBGrid
        Width = 429
        Height = 246
      end
      object pnlDocumentOptions: TPanel
        Left = 0
        Top = 278
        Width = 589
        Height = 41
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 3
      end
    end
  end
  inherited alMain: TActionList
    Top = 135
    object actNewSub: TAction [1]
      Category = 'Main'
      Caption = '�������� �����...'
      Hint = '�������� �����...'
      ImageIndex = 0
      OnExecute = actNewSubExecute
      OnUpdate = actNewSubUpdate
    end
    inherited actDetailNew: TAction
      Visible = False
      OnExecute = actAddUserDocExecute
    end
    object actAddUserDoc: TAction
      Category = 'Detail'
      Caption = '�������� �������� ������������'
      Hint = '�������� �������� ������������'
      ImageIndex = 0
      OnExecute = actAddUserDocExecute
      OnUpdate = actAddUserDocUpdate
    end
    object actAddInvDocument: TAction
      Category = 'Detail'
      Caption = '�������� ��������� ��������'
      Hint = '�������� ��������� ��������'
      ImageIndex = 0
      OnExecute = actAddInvDocumentExecute
      OnUpdate = actAddInvDocumentUpdate
    end
    object actAddInvPriceList: TAction
      Category = 'Detail'
      Caption = '�������� �����-����'
      Hint = '�������� �����-����'
      ImageIndex = 0
      OnExecute = actAddInvPriceListExecute
      OnUpdate = actAddInvPriceListUpdate
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
    Left = 72
    Top = 128
  end
end
