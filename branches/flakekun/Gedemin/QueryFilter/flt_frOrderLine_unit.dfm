object frOrderLine: TfrOrderLine
  Left = 0
  Top = 0
  Width = 528
  Height = 57
  TabOrder = 0
  object pnlOrder: TPanel
    Left = 1
    Top = 3
    Width = 527
    Height = 52
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 0
    object Label1: TLabel
      Left = 8
      Top = 29
      Width = 106
      Height = 13
      Caption = 'Наименование поля:'
    end
    object Label2: TLabel
      Left = 8
      Top = 6
      Width = 135
      Height = 13
      Caption = 'Упорядочивать записи по:'
    end
    object cbOrderType: TComboBox
      Left = 376
      Top = 25
      Width = 147
      Height = 21
      Style = csDropDownList
      DropDownCount = 2
      ItemHeight = 13
      TabOrder = 0
      Items.Strings = (
        'по возрастанию'
        'по убыванию')
    end
    object bbtnClose: TBitBtn
      Left = 509
      Top = 2
      Width = 15
      Height = 15
      Cancel = True
      TabOrder = 1
      OnClick = bbtnCloseClick
      Glyph.Data = {
        DE010000424DDE01000000000000760000002800000024000000120000000100
        0400000000006801000000000000000000001000000000000000000000000000
        80000080000000808000800000008000800080800000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
        333333333333333333333333000033338833333333333333333F333333333333
        0000333911833333983333333388F333333F3333000033391118333911833333
        38F38F333F88F33300003339111183911118333338F338F3F8338F3300003333
        911118111118333338F3338F833338F3000033333911111111833333338F3338
        3333F8330000333333911111183333333338F333333F83330000333333311111
        8333333333338F3333383333000033333339111183333333333338F333833333
        00003333339111118333333333333833338F3333000033333911181118333333
        33338333338F333300003333911183911183333333383338F338F33300003333
        9118333911183333338F33838F338F33000033333913333391113333338FF833
        38F338F300003333333333333919333333388333338FFF830000333333333333
        3333333333333333333888330000333333333333333333333333333333333333
        0000}
      NumGlyphs = 2
    end
    object ctbFields: TComboTreeBox
      Left = 128
      Top = 25
      Width = 245
      Height = 21
      DropDownCount = 16
      TopNodeEnabled = False
      AutoPopupWidth = True
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 2
      OnChange = cbFieldsChange
      OnExit = cbFieldsExit
    end
  end
end
