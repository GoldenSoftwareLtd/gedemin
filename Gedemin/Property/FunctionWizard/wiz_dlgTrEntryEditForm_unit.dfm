inherited dlgTrEntryEditForm: TdlgTrEntryEditForm
  Left = 472
  Top = 194
  Caption = '�������� ������� ������� ��������'
  ClientHeight = 321
  ClientWidth = 414
  OldCreateOrder = True
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  inherited Panel1: TPanel
    Top = 291
    Width = 414
    inherited Button4: TButton
      TabOrder = 1
    end
    inherited pnlRightButtons: TPanel
      Left = 249
      TabOrder = 0
      inherited Button2: TButton
        Left = 7
      end
    end
  end
  inherited PageControl: TPageControl
    Width = 414
    Height = 291
    OnChanging = PageControlChanging
    inherited tsGeneral: TTabSheet
      inherited Label2: TLabel
        Top = 173
      end
      object lblAccountTypeTitle: TLabel [3]
        Left = 8
        Top = 81
        Width = 54
        Height = 13
        Caption = '��� �����:'
      end
      object lblNCUSumm: TLabel [4]
        Left = 8
        Top = 104
        Width = 83
        Height = 13
        Caption = '����� � ������:'
      end
      object lAccount: TLabel [5]
        Left = 8
        Top = 57
        Width = 29
        Height = 13
        Caption = '����:'
      end
      object lblCurrTitle: TLabel [6]
        Left = 8
        Top = 128
        Width = 43
        Height = 13
        Caption = '������:'
      end
      object lblCURRSum: TLabel [7]
        Left = 8
        Top = 151
        Width = 86
        Height = 13
        Caption = '����� � ������:'
      end
      inherited cbName: TComboBox
        Width = 304
      end
      inherited mDescription: TMemo
        Top = 171
        Width = 304
        TabOrder = 8
      end
      inherited eLocalName: TEdit
        Width = 304
        TabOrder = 1
      end
      object rbDebit: TRadioButton
        Left = 96
        Top = 80
        Width = 89
        Height = 17
        Caption = '���������'
        TabOrder = 3
      end
      object rbCredit: TRadioButton
        Left = 184
        Top = 80
        Width = 89
        Height = 17
        Caption = '����������'
        TabOrder = 4
      end
      object beSum: TBtnEdit
        Left = 96
        Top = 99
        Width = 304
        Height = 22
        BtnCaption = '��������'
        BtnCursor = crArrow
        BtnGlyph.Data = {
          36030000424D3603000000000000360000002800000010000000100000000100
          18000000000000030000C40E0000C40E00000000000000000000FFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000FF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFF000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000FF9933000000FF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFF000000FF9933FF99330000000000000000000000000000000000000000
          00000000FFFFFFFFFFFFFFFFFFFFFFFF000000FF9933FFCC33FF9933FF9933FF
          9933FF9933FF9933FF9933FF9933FF9933000000FFFFFFFFFFFFFFFFFFFFFFFF
          FF6633FFFF99FFFF99FFFF99FFFF99FFFF99FFFF99FFFF99FFFF99FFFF99FF99
          33000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF6633FFFF99FFFF99000000FF
          6633FF6633FF6633FF6633FF6633FF6633000000FFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFF6633FFFF99000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF6633000000FF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFF000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF}
        BtnShowHint = False
        BtnWidth = 80
        BtnOnClick = beSumBtnOnClick
        Anchors = [akLeft, akTop, akRight]
        Enabled = True
        TabOrder = 5
      end
      object beSumCurr: TBtnEdit
        Left = 96
        Top = 147
        Width = 304
        Height = 22
        BtnCaption = '��������'
        BtnCursor = crArrow
        BtnGlyph.Data = {
          36030000424D3603000000000000360000002800000010000000100000000100
          18000000000000030000C40E0000C40E00000000000000000000FFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000FF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFF000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000FF9933000000FF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFF000000FF9933FF99330000000000000000000000000000000000000000
          00000000FFFFFFFFFFFFFFFFFFFFFFFF000000FF9933FFCC33FF9933FF9933FF
          9933FF9933FF9933FF9933FF9933FF9933000000FFFFFFFFFFFFFFFFFFFFFFFF
          FF6633FFFF99FFFF99FFFF99FFFF99FFFF99FFFF99FFFF99FFFF99FFFF99FF99
          33000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF6633FFFF99FFFF99000000FF
          6633FF6633FF6633FF6633FF6633FF6633000000FFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFF6633FFFF99000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF6633000000FF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFF000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF}
        BtnShowHint = False
        BtnWidth = 80
        BtnOnClick = beSumBtnOnClick
        Anchors = [akLeft, akTop, akRight]
        Enabled = True
        TabOrder = 7
      end
      object beAccount: TBtnEdit
        Left = 96
        Top = 54
        Width = 304
        Height = 22
        BtnCaption = '��������'
        BtnCursor = crArrow
        BtnGlyph.Data = {
          36030000424D3603000000000000360000002800000010000000100000000100
          18000000000000030000C40E0000C40E00000000000000000000FFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000FF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFF000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000FF9933000000FF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFF000000FF9933FF99330000000000000000000000000000000000000000
          00000000FFFFFFFFFFFFFFFFFFFFFFFF000000FF9933FFCC33FF9933FF9933FF
          9933FF9933FF9933FF9933FF9933FF9933000000FFFFFFFFFFFFFFFFFFFFFFFF
          FF6633FFFF99FFFF99FFFF99FFFF99FFFF99FFFF99FFFF99FFFF99FFFF99FF99
          33000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF6633FFFF99FFFF99000000FF
          6633FF6633FF6633FF6633FF6633FF6633000000FFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFF6633FFFF99000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF6633000000FF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFF000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF}
        BtnShowHint = False
        BtnWidth = 80
        BtnOnClick = beAccountBtnOnClick
        Anchors = [akLeft, akTop, akRight]
        Enabled = True
        TabOrder = 2
        OnChange = beAccountChange
        OnExit = beAccountExit
      end
      object beCurr: TBtnEdit
        Left = 96
        Top = 123
        Width = 304
        Height = 22
        BtnCaption = '��������'
        BtnCursor = crArrow
        BtnGlyph.Data = {
          36030000424D3603000000000000360000002800000010000000100000000100
          18000000000000030000C40E0000C40E00000000000000000000FFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000FF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFF000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000FF9933000000FF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFF000000FF9933FF99330000000000000000000000000000000000000000
          00000000FFFFFFFFFFFFFFFFFFFFFFFF000000FF9933FFCC33FF9933FF9933FF
          9933FF9933FF9933FF9933FF9933FF9933000000FFFFFFFFFFFFFFFFFFFFFFFF
          FF6633FFFF99FFFF99FFFF99FFFF99FFFF99FFFF99FFFF99FFFF99FFFF99FF99
          33000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF6633FFFF99FFFF99000000FF
          6633FF6633FF6633FF6633FF6633FF6633000000FFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFF6633FFFF99000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF6633000000FF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFF000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF}
        BtnShowHint = False
        BtnWidth = 80
        BtnOnClick = beCurrBtnOnClick
        Anchors = [akLeft, akTop, akRight]
        Enabled = True
        TabOrder = 6
        OnChange = beCurrChange
      end
    end
    object tsAnalytics: TTabSheet
      BorderWidth = 8
      Caption = '���������'
      ImageIndex = 1
      object sbAnalytics: TScrollBox
        Left = 0
        Top = 0
        Width = 390
        Height = 247
        Align = alClient
        BorderStyle = bsNone
        TabOrder = 0
      end
    end
    object tsQuantity: TTabSheet
      BorderWidth = 3
      Caption = '�������������� ����������'
      ImageIndex = 2
      object lvQuantity: TListView
        Left = 0
        Top = 28
        Width = 400
        Height = 229
        Align = alClient
        Columns = <
          item
            Caption = '������� ���������'
            Width = 195
          end
          item
            Caption = '����������'
            Width = 200
          end
          item
            Caption = 'Script'
          end>
        TabOrder = 0
        ViewStyle = vsReport
        OnDblClick = lvQuantityDblClick
      end
      object TBDock1: TTBDock
        Left = 0
        Top = 0
        Width = 400
        Height = 28
        BoundLines = [blTop, blBottom, blLeft, blRight]
        object TBToolbar1: TTBToolbar
          Left = 0
          Top = 0
          Caption = 'TBToolbar1'
          CloseButton = False
          DockMode = dmCannotFloatOrChangeDocks
          FullSize = True
          Images = dmImages.il16x16
          TabOrder = 0
          object TBItem2: TTBItem
            Action = actAddQuantity
          end
          object TBItem3: TTBItem
            Action = actEditQuantity
          end
          object TBSeparatorItem1: TTBSeparatorItem
          end
          object TBItem1: TTBItem
            Action = actDeleteQuantity
          end
        end
      end
    end
  end
  inherited ActionList: TActionList
    Images = dmImages.il16x16
    Left = 40
    Top = 232
    object actAddQuantity: TAction
      Caption = 'actAddQuantity'
      ImageIndex = 179
      OnExecute = actAddQuantityExecute
    end
    object actDeleteQuantity: TAction
      Caption = 'actDelteQuantity'
      ImageIndex = 178
      OnExecute = actDeleteQuantityExecute
      OnUpdate = actEditQuantityUpdate
    end
    object actEditQuantity: TAction
      Caption = 'actEditQuantity'
      ImageIndex = 177
      OnExecute = actEditQuantityExecute
      OnUpdate = actEditQuantityUpdate
    end
  end
  object pmAccount: TPopupMenu
    OnPopup = pmAccountPopup
    Left = 28
    Top = 288
  end
  object pmCurr: TPopupMenu
    OnPopup = pmCurrPopup
    Left = 12
    Top = 248
  end
end
