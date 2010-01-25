inherited dlgVarEditForm: TdlgVarEditForm
  Left = 234
  Top = 307
  HelpContext = 202
  Caption = 'Свойства переменной'
  ClientHeight = 249
  ClientWidth = 446
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  inherited Panel1: TPanel
    Top = 219
    Width = 446
    inherited Button1: TButton
      Left = 367
    end
    inherited Button2: TButton
      Left = 287
    end
    inherited Button4: TButton
      Left = 1
    end
  end
  inherited PageControl: TPageControl
    Width = 446
    Height = 219
    inherited tsGeneral: TTabSheet
      inherited Label1: TLabel
        Top = 12
        Width = 90
        Caption = 'Имя переменной:'
      end
      inherited Label2: TLabel
        Top = 96
      end
      object Label3: TLabel [2]
        Left = 8
        Top = 59
        Width = 65
        Height = 13
        Caption = 'Выражение: '
      end
      inherited cbName: TComboBox
        Left = 104
        Width = 327
        Style = csDropDown
        OnClick = cbNameClick
        OnDropDown = cbNameDropDown
      end
      inherited mDescription: TMemo
        Left = 104
        Top = 96
        Width = 327
        TabOrder = 4
      end
      inherited eLocalName: TEdit
        Left = 104
        Width = 327
        TabOrder = 1
      end
      object BtnEdit1: TBtnEdit
        Left = 104
        Top = 54
        Width = 326
        Height = 22
        BtnCaption = 'Вставить'
        BtnCursor = crHandPoint
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
        BtnOnClick = actEditExpressionExecute
        Action = actEditExpression
        Anchors = [akLeft, akTop, akRight]
        Enabled = True
        TabOrder = 2
      end
      object CheckBox1: TCheckBox
        Left = 8
        Top = 78
        Width = 328
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Ссылка на объект'
        TabOrder = 3
      end
    end
  end
  inherited ActionList: TActionList
    Top = 152
    object actEditExpression: TAction [2]
      ImageIndex = 239
      OnExecute = actEditExpressionExecute
    end
  end
end
