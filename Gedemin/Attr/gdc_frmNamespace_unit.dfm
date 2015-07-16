inherited gdc_frmNamespace: Tgdc_frmNamespace
  Left = 622
  Top = 190
  Width = 1090
  Height = 742
  Caption = '������������ ����'
  Visible = True
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 692
    Width = 1082
  end
  inherited TBDockTop: TTBDock
    Width = 1082
    inherited tbMainCustom: TTBToolbar
      Images = dmImages.il16x16
      object TBItem1: TTBItem
        Action = actSetObjectPos
      end
      object TBItem2: TTBItem
        Action = actCompareWithData
      end
      object TBItem3: TTBItem
        Action = actShowDuplicates
      end
      object TBItem4: TTBItem
        Action = actShowRecursion
      end
      object TBItem6: TTBItem
        Action = actNSObjects
      end
      object TBItem7: TTBItem
        Action = actViewNS
        Caption = '����������� ������ ����������� ����'
        Hint = '�������� ����������� ����� ������� ����������� ����'
      end
    end
  end
  inherited TBDockLeft: TTBDock
    Height = 632
  end
  inherited TBDockRight: TTBDock
    Left = 1073
    Height = 632
  end
  inherited TBDockBottom: TTBDock
    Top = 683
    Width = 1082
  end
  inherited pnlWorkArea: TPanel
    Width = 1064
    Height = 632
    inherited sMasterDetail: TSplitter
      Width = 1064
    end
    inherited spChoose: TSplitter
      Top = 527
      Width = 1064
    end
    inherited pnlMain: TPanel
      Width = 1064
      inherited ibgrMain: TgsIBGrid
        Width = 904
      end
    end
    inherited pnChoose: TPanel
      Top = 533
      Width = 1064
      inherited pnButtonChoose: TPanel
        Left = 959
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 959
      end
      inherited pnlChooseCaption: TPanel
        Width = 1064
      end
    end
    inherited pnlDetail: TPanel
      Width = 1064
      Height = 354
      inherited TBDockDetail: TTBDock
        Width = 1064
        inherited tbDetailCustom: TTBToolbar
          Images = dmImages.il16x16
          object TBItem5: TTBItem
            Action = actShowObject
          end
        end
      end
      inherited pnlSearchDetail: TPanel
        Height = 328
        inherited sbSearchDetail: TScrollBox
          Height = 301
        end
      end
      inherited ibgrDetail: TgsIBGrid
        Width = 904
        Height = 328
      end
    end
  end
  inherited alMain: TActionList
    object actSetObjectPos: TAction
      Caption = '���������� ����������� ��������'
      Hint = '���������� ����������� ��������'
      ImageIndex = 206
      OnExecute = actSetObjectPosExecute
      OnUpdate = actSetObjectPosUpdate
    end
    object actCompareWithData: TAction
      Caption = '�������� � ������'
      Hint = '�������� � ������'
      ImageIndex = 131
      OnExecute = actCompareWithDataExecute
      OnUpdate = actCompareWithDataUpdate
    end
    object actShowDuplicates: TAction
      Caption = '�������� ���������'
      Hint = '�������� ���������'
      ImageIndex = 100
      OnExecute = actShowDuplicatesExecute
      OnUpdate = actShowDuplicatesUpdate
    end
    object actShowRecursion: TAction
      Caption = '�������� ����������� �����������'
      Hint = '�������� ����������� �����������'
      ImageIndex = 203
      OnExecute = actShowRecursionExecute
      OnUpdate = actShowRecursionUpdate
    end
    object actNSObjects: TAction
      Caption = '������ ��������'
      Hint = '������ ��������'
      ImageIndex = 181
      OnExecute = actNSObjectsExecute
      OnUpdate = actNSObjectsUpdate
    end
    object actShowObject: TAction
      Category = 'Detail'
      Caption = '������� ������'
      Hint = '������� ������'
      ImageIndex = 131
      OnExecute = actShowObjectExecute
      OnUpdate = actShowObjectUpdate
    end
    object actViewNS: TAction
      Caption = '�������� ����� ����������� ����'
      Hint = '�������� ����� ����������� ����'
      ImageIndex = 80
      OnExecute = actViewNSExecute
    end
  end
  object gdcNamespace: TgdcNamespace
    Left = 425
    Top = 129
  end
  object gdcNamespaceObject: TgdcNamespaceObject
    MasterSource = dsMain
    MasterField = 'id'
    DetailField = 'namespacekey'
    SubSet = 'ByNamespace'
    Left = 337
    Top = 161
  end
end
