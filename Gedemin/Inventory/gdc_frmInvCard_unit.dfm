inherited gdc_frmInvCard: Tgdc_frmInvCard
  Left = 955
  Top = 238
  Width = 889
  Height = 556
  Caption = '�������� �� ���'
  PixelsPerInch = 96
  TextHeight = 13
  inherited sbMain: TStatusBar
    Top = 490
    Width = 873
  end
  inherited TBDockTop: TTBDock
    Width = 873
    Height = 111
    inherited tbMainToolbar: TTBToolbar
      object TBItem4: TTBItem [2]
        Action = actListDocument
        Caption = '������� � ������ ����������'
      end
    end
    inherited tbMainCustom: TTBToolbar
      Left = 0
      Top = 51
      DockPos = 0
      DockRow = 2
      Stretch = False
      Visible = True
      object TBControlItem1: TTBControlItem
        Control = Panel1
      end
      object Panel1: TPanel
        Left = 0
        Top = 1
        Width = 379
        Height = 23
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object lStart: TLabel
          Left = 5
          Top = 5
          Width = 42
          Height = 13
          Caption = '������:'
        end
        object sbRun: TSpeedButton
          Left = 352
          Top = 0
          Width = 23
          Height = 22
          Action = actRun
          Flat = True
          Glyph.Data = {
            36040000424D3604000000000000360000002800000010000000100000000100
            2000000000000004000000000000000000000000000000000000FF00FF00FF00
            FF00B5848400B5848400B5848400B5848400B5848400B5848400B5848400B584
            8400B5848400B5848400B5848400B5848400B5848400FF00FF00FF00FF00FF00
            FF00C6A59C00FFEFD600527BC600527BC600F7DEB500F7D6AD00F7D6A500EFCE
            9C00EFCE9400EFCE9400EFCE9400F7D69C00B5848400FF00FF00FF00FF00FF00
            FF00C6A59C00FFEFD60000F7FF00527BC600527BC6009C9C9C009C9C9C009C9C
            9C009C9C9C009C9C9C009C9C9C00EFCE9C00B5848400FF00FF00FF00FF00FF00
            FF00C6ADA500FFEFE70039A5FF0000F7FF00527BC600527BC600527BC600F7D6
            AD00EFCE9C00EFCE9C00EFCE9400EFCE9C00B5848400FF00FF00FF00FF00FF00
            FF00C6ADA500FFF7E700F7E7D60039A5FF0094FFFF0000F7FF00527BC600527B
            C600F7D6AD00EFCE9C00EFCE9C00EFCE9400B5848400FF00FF00FF00FF00FF00
            FF00CEB5AD00527BC600527BC600527BC600527BC60094FFFF0000F7FF00527B
            C600527BC6009C9C9C009C9C9C00EFCE9C00B5848400FF00FF00FF00FF00FF00
            FF00D6B5AD0039A5FF0094FFFF0000F7FF0000F7FF0000F7FF0000F7FF0000F7
            FF00527BC600527BC600F7D6A500F7D6A500B5848400FF00FF00FF00FF00FF00
            FF00D6BDB500FFFFFF0039A5FF0094FFFF0000F7FF00527BC600527BC600F7E7
            C600F7DEC600F7DEBD00F7D6B500F7D6AD00B5848400FF00FF00FF00FF00FF00
            FF00D6BDB500FFFFFF00DEDEDE0039A5FF0094FFFF0000F7FF00527BC600527B
            C6009C9C9C009C9C9C009C9C9C00F7DEB500B5848400FF00FF00FF00FF00FF00
            FF00DEBDB500FFFFFF00FFFFFF0039A5FF0094FFFF0000F7FF0000F7FF00527B
            C600527BC600F7DEC600F7DEC600F7D6B500B5848400FF00FF00FF00FF00FF00
            FF00DEC6B500FFFFFF00FFFFFF00FFFFFF0039A5FF0094FFFF0000F7FF0000F7
            FF00527BC600527BC600E7DEC600C6BDAD00B5848400FF00FF00FF00FF00FF00
            FF00E7C6B500FFFFFF00DEDEDE009C9C9C009C9C9C0039A5FF0094FFFF0000F7
            FF0000F7FF00527BC600527BC600B58C8400B5848400FF00FF00FF00FF00FF00
            FF00E7C6B500FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            F700E7CECE00BD8C7300EFB57300EFA54A00C6846B00FF00FF00FF00FF00FF00
            FF00EFCEBD00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00E7D6CE00C6947B00FFC67300CE947300FF00FF00FF00FF00FF00FF00FF00
            FF00E7C6B500FFF7F700FFF7EF00FFF7EF00FFF7EF00FFF7EF00FFF7EF00FFF7
            EF00E7CECE00C6947B00CE9C8400FF00FF00FF00FF00FF00FF00FF00FF00FF00
            FF00E7C6B500EFCEB500EFCEB500EFCEB500EFCEB500E7C6B500E7C6B500EFCE
            B500D6BDB500BD847B00FF00FF00FF00FF00FF00FF00FF00FF00}
        end
        object cbAllInterval: TCheckBox
          Left = 204
          Top = 3
          Width = 147
          Height = 17
          Caption = '�������������� ������'
          Checked = True
          State = cbChecked
          TabOrder = 1
          OnClick = cbAllIntervalClick
        end
        object gsPeriodEdit: TgsPeriodEdit
          Left = 51
          Top = 1
          Width = 148
          Height = 21
          TabOrder = 0
        end
      end
    end
    inherited tbMainInvariant: TTBToolbar
      Left = 258
      Caption = '`'
      DockPos = 184
      object TBItem2: TTBItem
        Action = actOptions
      end
      object TBItem3: TTBItem
        Action = actChooseIgnoryFeatures
      end
    end
    inherited tbChooseMain: TTBToolbar
      Left = 366
      DockPos = 352
    end
    object tbGoodInfo: TTBToolbar
      Left = 0
      Top = 81
      Caption = 'tbGoodInfo'
      DockPos = 0
      DockRow = 3
      FloatingMode = fmOnTopOfAllForms
      FullSize = True
      ParentShowHint = False
      ShowHint = True
      TabOrder = 5
      object TBItem1: TTBItem
        Visible = False
      end
      object TBControlItem2: TTBControlItem
        Control = Panel2
      end
      object Panel2: TPanel
        Left = 0
        Top = 0
        Width = 602
        Height = 26
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object Label1: TLabel
          Left = 6
          Top = 6
          Width = 100
          Height = 13
          Caption = '������� �� ������ '
        end
        object Label2: TLabel
          Left = 232
          Top = 6
          Width = 45
          Height = 13
          Caption = '�� �����'
        end
        object edBeginRest: TEdit
          Left = 107
          Top = 2
          Width = 121
          Height = 21
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 0
        end
        object edEndRest: TEdit
          Left = 281
          Top = 2
          Width = 121
          Height = 21
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 1
        end
        object cbIncludeInvMovement: TCheckBox
          Left = 408
          Top = 3
          Width = 201
          Height = 17
          Caption = '�������� ���������� ��������'
          TabOrder = 2
          OnClick = cbIncludeInvMovementClick
        end
      end
    end
    object tbContact: TTBToolbar
      Left = 392
      Top = 51
      Caption = 'tbContact'
      DockMode = dmCannotFloat
      DockPos = 392
      DockRow = 2
      FloatingMode = fmOnTopOfAllForms
      Images = dmImages.il16x16
      TabOrder = 6
      object TBControlItem3: TTBControlItem
        Control = Panel3
      end
      object Panel3: TPanel
        Left = 0
        Top = 0
        Width = 447
        Height = 26
        BevelOuter = bvNone
        TabOrder = 0
        object Label3: TLabel
          Left = 5
          Top = 5
          Width = 80
          Height = 13
          Caption = '�������������'
        end
        object iblcContact: TgsIBLookupComboBox
          Left = 96
          Top = 2
          Width = 225
          Height = 21
          HelpContext = 1
          Database = dmDatabase.ibdbGAdmin
          Transaction = ibtrCommon
          ListTable = 'gd_contact'
          ListField = 'name'
          KeyField = 'id'
          SortOrder = soAsc
          Condition = 'contacttype in (2, 4)'
          gdClassName = 'TgdcBaseContact'
          ItemHeight = 13
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
          OnChange = iblcContactChange
        end
        object bSetCurrent: TButton
          Left = 320
          Top = 0
          Width = 127
          Height = 25
          Action = actSetCurrent
          TabOrder = 1
        end
      end
    end
  end
  inherited TBDockLeft: TTBDock
    Top = 111
    Height = 379
  end
  inherited TBDockRight: TTBDock
    Left = 864
    Top = 111
    Height = 379
  end
  inherited TBDockBottom: TTBDock
    Top = 509
    Width = 873
  end
  inherited pnlWorkArea: TPanel
    Top = 111
    Width = 855
    Height = 379
    inherited spChoose: TSplitter
      Top = 276
      Width = 855
    end
    inherited pnlMain: TPanel
      Width = 855
      Height = 276
      inherited pnlSearchMain: TPanel
        Height = 276
        inherited sbSearchMain: TScrollBox
          Height = 249
        end
      end
      inherited ibgrMain: TgsIBGrid
        Width = 695
        Height = 276
      end
    end
    inherited pnChoose: TPanel
      Top = 280
      Width = 855
      inherited pnButtonChoose: TPanel
        Left = 750
      end
      inherited ibgrChoose: TgsIBGrid
        Width = 750
      end
      inherited pnlChooseCaption: TPanel
        Width = 855
      end
    end
  end
  inherited alMain: TActionList
    inherited actNew: TAction
      Visible = False
    end
    inherited actDelete: TAction
      Visible = False
    end
    inherited actDuplicate: TAction
      Visible = False
    end
    inherited actMainReduction: TAction
      Visible = False
    end
    object actRun: TAction
      Category = 'Commands'
      Hint = '����������� ��������'
      ImageIndex = 73
      ShortCut = 116
      OnExecute = actRunExecute
      OnUpdate = actRunUpdate
    end
    object actOptions: TAction
      Category = 'Commands'
      Caption = '����� ����� ��� �����������'
      Hint = '����� ����� ��� �����������'
      ImageIndex = 36
      OnExecute = actOptionsExecute
    end
    object actChooseIgnoryFeatures: TAction
      Category = 'Commands'
      Caption = '����� �������, ������� �� ������ �� ������������ ��������'
      Hint = '����� �������, ������� �� ������ �� ������������ ��������'
      ImageIndex = 94
      OnExecute = actChooseIgnoryFeaturesExecute
    end
    object actSetCurrent: TAction
      Caption = '���������� �������'
      OnExecute = actSetCurrentExecute
      OnUpdate = actSetCurrentUpdate
    end
    object actListDocument: TAction
      Category = 'Commands'
      Caption = 'actListDocument'
      Hint = '������� � ������ ����������'
      ImageIndex = 7
      ShortCut = 16458
      OnExecute = actListDocumentExecute
    end
  end
  inherited pmMain: TPopupMenu
    object nListDocument: TMenuItem [2]
      Action = actListDocument
      Caption = '������ ����������'
    end
    inherited nDel_OLD: TMenuItem
      Enabled = False
    end
  end
  object gdcInvCard: TgdcInvCard
    SubSet = 'ByContact'
    CachedUpdates = True
    Left = 289
    Top = 153
  end
  object ibtrCommon: TIBTransaction
    Active = False
    DefaultDatabase = dmDatabase.ibdbGAdmin
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 280
    Top = 184
  end
end
