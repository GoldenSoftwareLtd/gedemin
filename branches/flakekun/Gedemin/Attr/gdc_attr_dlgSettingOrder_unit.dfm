inherited gdc_dlgSettingOrder: Tgdc_dlgSettingOrder
  Left = 317
  Top = 127
  Width = 655
  Height = 577
  BorderStyle = bsSizeable
  Caption = '������� ��������'
  Font.Charset = DEFAULT_CHARSET
  Font.Name = 'MS Sans Serif'
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    TabOrder = 8
    Visible = False
  end
  inherited btnNew: TButton
    Top = 301
    Visible = False
  end
  inherited btnHelp: TButton
    Top = 301
    Visible = False
  end
  inherited btnOK: TButton
    Left = 493
    Top = 522
    Anchors = [akRight, akBottom]
    TabOrder = 5
  end
  object bbtnUp: TBitBtn [4]
    Left = 36
    Top = 512
    Width = 33
    Height = 33
    Action = actUp
    TabOrder = 1
    Glyph.Data = {
      76010000424D7601000000000000760000002800000020000000100000000100
      04000000000000010000120B0000120B00001000000000000000000000000000
      800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF003C3333339333
      337437FFF3337F3333F73CCC33339333344437773F337F33377733CCC3339337
      4447337F73FF7F3F337F33CCCCC3934444433373F7737F773373333CCCCC9444
      44733337F337773337F3333CCCCC9444443333373F337F3337333333CCCC9444
      473333337F337F337F333333CCCC94444333333373F37F33733333333CCC9444
      7333333337F37F37F33333333CCC944433333333373F7F373333333333CC9447
      33333333337F7F7F3333333333CC94433333333333737F7333333333333C9473
      33333333333737F333333333333C943333333333333737333333333333339733
      3333333333337F33333333333333933333333333333373333333}
    NumGlyphs = 2
  end
  object bbtnDown: TBitBtn [5]
    Left = 76
    Top = 512
    Width = 33
    Height = 33
    Action = actDown
    TabOrder = 2
    Glyph.Data = {
      76010000424D7601000000000000760000002800000020000000100000000100
      04000000000000010000120B0000120B00001000000000000000000000000000
      800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333393333
      333333333337F3333333333333397333333333333337FF333333333333C94333
      3333333333737F333333333333C9473333333333337373F3333333333CC94433
      3333333337F7F7F3333333333CC94473333333333737F73F33333333CCC94443
      333333337F37F37F33333333CCC94447333333337337F373F333333CCCC94444
      33333337F337F337F333333CCCC94444733333373337F3373F3333CCCCC94444
      4333337F3337FF337F3333CCCCC94444473333733F7773FF73F33CCCCC393444
      443337F37737F773F7F33CCC33393374447337F73337F33737FFCCC333393333
      444377733337F333777FC3333339333337437333333733333373}
    NumGlyphs = 2
  end
  object lbxSetting: TListBox [6]
    Left = 16
    Top = 512
    Width = 12
    Height = 25
    DragMode = dmAutomatic
    ItemHeight = 13
    MultiSelect = True
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    OnDragDrop = lbxSettingDragDrop
    OnDragOver = lbxSettingDragOver
    OnMouseMove = lbxSettingMouseMove
  end
  object pnlMain: TPanel [7]
    Left = 0
    Top = 0
    Width = 647
    Height = 515
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 7
    object lvSetting: TListView
      Left = 1
      Top = 27
      Width = 645
      Height = 487
      Align = alClient
      Columns = <
        item
          Caption = '������������'
          Width = 200
        end
        item
          Caption = '���������'
          Width = 100
        end>
      ColumnClick = False
      DragMode = dmAutomatic
      GridLines = True
      HideSelection = False
      ReadOnly = True
      RowSelect = True
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      ViewStyle = vsReport
      OnDragOver = lvSettingDragOver
      OnMouseMove = lvSettingMouseMove
    end
    object TBDock1: TTBDock
      Left = 1
      Top = 1
      Width = 645
      Height = 26
      object TBToolbar1: TTBToolbar
        Left = 0
        Top = 0
        Caption = 'TBToolbar1'
        Images = dmImages.il16x16
        TabOrder = 0
        object TBItem4: TTBItem
          Action = actTop
        end
        object TBSeparatorItem1: TTBSeparatorItem
        end
        object TBItem3: TTBItem
          Action = actUp
        end
        object TBItem2: TTBItem
          Action = actDown
        end
        object TBSeparatorItem2: TTBSeparatorItem
        end
        object TBItem1: TTBItem
          Action = actBottom
        end
      end
    end
  end
  inherited btnCancel: TButton
    Left = 576
    Top = 522
    Anchors = [akRight, akBottom]
    TabOrder = 6
  end
  inherited alBase: TActionList
    Images = dmImages.il16x16
    Left = 78
    Top = 31
    object actUp: TAction
      Category = 'Order'
      Hint = '�����'
      ImageIndex = 239
      OnExecute = actUpExecute
    end
    object actDown: TAction
      Category = 'Order'
      Hint = '����'
      ImageIndex = 240
      OnExecute = actDownExecute
    end
    object actTop: TAction
      Category = 'Order'
      Caption = 'actTop'
      Hint = '� ������'
      ImageIndex = 47
      OnExecute = actTopExecute
    end
    object actBottom: TAction
      Category = 'Order'
      Caption = 'actBottom'
      Hint = '� �����'
      ImageIndex = 48
      OnExecute = actBottomExecute
    end
  end
  inherited dsgdcBase: TDataSource
    Left = 48
    Top = 31
  end
  inherited pm_dlgG: TPopupMenu
    Left = 120
    Top = 32
  end
end
