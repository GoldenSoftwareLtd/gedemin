object frFilterLine: TfrFilterLine
  Left = 0
  Top = 0
  Width = 528
  Height = 84
  TabOrder = 0
  object pnlFilter: TPanel
    Left = 0
    Top = 4
    Width = 528
    Height = 78
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 0
    object Label1: TLabel
      Left = 8
      Top = 8
      Width = 106
      Height = 13
      Caption = 'Наименование поля:'
    end
    object Label2: TLabel
      Left = 305
      Top = 8
      Width = 93
      Height = 13
      Caption = 'Условие фильтра:'
    end
    object pcEdits: TPageControl
      Left = 2
      Top = 42
      Width = 523
      Height = 34
      ActivePage = tsEnterData
      MultiLine = True
      Style = tsFlatButtons
      TabOrder = 2
      object tsOnes: TTabSheet
        Caption = 'tsOnes'
        TabVisible = False
        object edCondition: TEdit
          Left = 2
          Top = 0
          Width = 513
          Height = 21
          TabOrder = 0
          OnExit = edConditionExit
        end
      end
      object tsTwise: TTabSheet
        Caption = 'tsTwise'
        ImageIndex = 1
        TabVisible = False
        object Label3: TLabel
          Left = 3
          Top = 3
          Width = 14
          Height = 13
          Caption = 'от:'
        end
        object Label4: TLabel
          Left = 261
          Top = 3
          Width = 15
          Height = 13
          Caption = 'до:'
        end
        object edFrom: TEdit
          Left = 24
          Top = 0
          Width = 233
          Height = 21
          TabOrder = 0
          OnExit = edConditionExit
        end
        object edTo: TEdit
          Left = 280
          Top = 0
          Width = 235
          Height = 21
          TabOrder = 1
          OnExit = edConditionExit
        end
      end
      object tsCombo: TTabSheet
        Caption = 'tsCombo'
        ImageIndex = 2
        TabVisible = False
        object gscbSet: TgsComboBoxAttrSet
          Left = 2
          Top = 0
          Width = 513
          Height = 21
          ItemHeight = 0
          TabOrder = 0
          DialogType = True
        end
      end
      object tsEmpty: TTabSheet
        Caption = 'tsEmpty'
        ImageIndex = 3
        TabVisible = False
      end
      object tsElementSet: TTabSheet
        Caption = 'tsElementSet'
        ImageIndex = 4
        TabVisible = False
        object gscbElementSet: TgsComboBoxAttr
          Left = 2
          Top = 0
          Width = 513
          Height = 21
          DialogType = 0
        end
      end
      object tsFilter: TTabSheet
        Caption = 'tsFilter'
        ImageIndex = 5
        TabVisible = False
        object cbFilter: TComboBox
          Left = 2
          Top = 0
          Width = 513
          Height = 21
          Style = csDropDownList
          DropDownCount = 0
          ItemHeight = 0
          TabOrder = 0
          OnDropDown = cbFilterDropDown
        end
      end
      object tsFormula: TTabSheet
        Caption = 'tsFormula'
        ImageIndex = 6
        TabVisible = False
        object cbFormula: TComboBox
          Left = 2
          Top = 0
          Width = 513
          Height = 21
          ItemHeight = 0
          TabOrder = 0
          OnDropDown = cbFormulaDropDown
          OnExit = edConditionExit
        end
      end
      object tsSelDay: TTabSheet
        Caption = 'tsSelDay'
        ImageIndex = 7
        TabVisible = False
        object dtpSelDay: TDateTimePicker
          Left = 2
          Top = 0
          Width = 513
          Height = 21
          CalAlignment = dtaLeft
          Date = 36831
          Time = 36831
          DateFormat = dfShort
          DateMode = dmComboBox
          Kind = dtkDate
          ParseInput = False
          TabOrder = 0
        end
      end
      object tsScript: TTabSheet
        Caption = 'tsScript'
        ImageIndex = 8
        TabVisible = False
        object SpeedButton1: TSpeedButton
          Left = 392
          Top = 0
          Width = 22
          Height = 22
          Glyph.Data = {
            B2050000424DB205000000000000360400002800000013000000130000000100
            0800000000007C010000C40E0000C40E00000001000000000000000000000000
            80000080000000808000800000008000800080800000C0C0C000C0DCC000F0CA
            A6000020400000206000002080000020A0000020C0000020E000004000000040
            20000040400000406000004080000040A0000040C0000040E000006000000060
            20000060400000606000006080000060A0000060C0000060E000008000000080
            20000080400000806000008080000080A0000080C0000080E00000A0000000A0
            200000A0400000A0600000A0800000A0A00000A0C00000A0E00000C0000000C0
            200000C0400000C0600000C0800000C0A00000C0C00000C0E00000E0000000E0
            200000E0400000E0600000E0800000E0A00000E0C00000E0E000400000004000
            20004000400040006000400080004000A0004000C0004000E000402000004020
            20004020400040206000402080004020A0004020C0004020E000404000004040
            20004040400040406000404080004040A0004040C0004040E000406000004060
            20004060400040606000406080004060A0004060C0004060E000408000004080
            20004080400040806000408080004080A0004080C0004080E00040A0000040A0
            200040A0400040A0600040A0800040A0A00040A0C00040A0E00040C0000040C0
            200040C0400040C0600040C0800040C0A00040C0C00040C0E00040E0000040E0
            200040E0400040E0600040E0800040E0A00040E0C00040E0E000800000008000
            20008000400080006000800080008000A0008000C0008000E000802000008020
            20008020400080206000802080008020A0008020C0008020E000804000008040
            20008040400080406000804080008040A0008040C0008040E000806000008060
            20008060400080606000806080008060A0008060C0008060E000808000008080
            20008080400080806000808080008080A0008080C0008080E00080A0000080A0
            200080A0400080A0600080A0800080A0A00080A0C00080A0E00080C0000080C0
            200080C0400080C0600080C0800080C0A00080C0C00080C0E00080E0000080E0
            200080E0400080E0600080E0800080E0A00080E0C00080E0E000C0000000C000
            2000C0004000C0006000C0008000C000A000C000C000C000E000C0200000C020
            2000C0204000C0206000C0208000C020A000C020C000C020E000C0400000C040
            2000C0404000C0406000C0408000C040A000C040C000C040E000C0600000C060
            2000C0604000C0606000C0608000C060A000C060C000C060E000C0800000C080
            2000C0804000C0806000C0808000C080A000C080C000C080E000C0A00000C0A0
            2000C0A04000C0A06000C0A08000C0A0A000C0A0C000C0A0E000C0C00000C0C0
            2000C0C04000C0C06000C0C08000C0C0A000F0FBFF00A4A0A000808080000000
            FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00FDFDFDFDFDFD
            FDFDFDFDFDFDFDFDFDFDFDFDFD00FDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFD
            FD00FDFDFDFDFDFD0404FDFDFDFDFDFDFDFDFDFDFD00FDFDFDFDFDFD040604FD
            FDFDFDFDFDFDFDFDFD00FDFDFDFDFDFD04FB0604FDFDFDFDFDFDFDFDFD00FDFD
            FDFDFDFDFD04FB0604FDFDFDFDFDFDFDFD00FDFDFDFDFD04040404FB0604FDFD
            FDFDFDFDFD00FDFDFDFDFD04FBFBFBFBFB0604FDFDFDFDFDFD00FDFDFDFDFD04
            FBFBFBFBFBFB04FDFDFDFDFDFD00FDFDFDFDFDFD04FB0604040404FDFDFDFDFD
            FD00FDFDFDFDFDFD04FBFB0604FDFDFDFDFDFDFDFD00FDFDFDFD04040404FBFB
            0604FDFDFDFDFDFDFD00FDFDFDFD04FBFBFBFBFBFB0604FDFDFDFDFDFD00FDFD
            FDFDFD04FBFBFBFBFBFB0604FDFDFDFDFD00FDFDFDFDFD04FBFBFBFBFBFBFB06
            04FDFDFDFD00FDFDFDFDFD0404040404040404040404FDFDFD00FDFDFDFDFDFD
            FDFDFDFDFDFDFDFDFDFDFDFDFD00FDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFD
            FD00FDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFDFD00}
          OnClick = SpeedButton1Click
        end
        object cbLanguage: TComboBox
          Left = 416
          Top = 0
          Width = 99
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 1
          Items.Strings = (
            'VBScript'
            'JScript')
        end
        object edScript: TEdit
          Left = 2
          Top = 0
          Width = 391
          Height = 21
          TabOrder = 0
        end
      end
      object tsEnterData: TTabSheet
        Caption = 'tsEnterData'
        ImageIndex = 9
        TabVisible = False
        object Label5: TLabel
          Left = 2
          Top = 3
          Width = 79
          Height = 13
          Caption = 'Наименование:'
        end
        object Label6: TLabel
          Left = 299
          Top = 3
          Width = 47
          Height = 13
          Caption = 'Условие:'
        end
        object cbSign: TComboBox
          Left = 352
          Top = 0
          Width = 163
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 1
          Items.Strings = (
            '<>'
            '<='
            '>='
            '='
            '<'
            '>'
            'IN'
            'NOT IN'
            'INCLUDE')
        end
        object edDataName: TEdit
          Left = 87
          Top = 0
          Width = 209
          Height = 21
          TabOrder = 0
        end
      end
      object tsEnumElement: TTabSheet
        Caption = 'tsEnumElement'
        ImageIndex = 10
        TabVisible = False
        object ecbEnum: TfltDBEnumComboBox
          Left = 2
          Top = 0
          Width = 513
          Height = 21
          Style = csDropDownList
          ItemHeight = 0
          TabOrder = 0
        end
      end
      object tsEnumSet: TTabSheet
        Caption = 'tsEnumSet'
        ImageIndex = 11
        TabVisible = False
        object escbEnumSet: TfltDBEnumSetComboBox
          Left = 2
          Top = 0
          Width = 513
          Height = 21
          Style = csDropDownList
          ItemHeight = 0
          TabOrder = 0
          AutoPopupWidth = False
        end
      end
    end
    object cbCondition: TComboBox
      Left = 304
      Top = 24
      Width = 217
      Height = 21
      Style = csDropDownList
      DropDownCount = 17
      ItemHeight = 13
      TabOrder = 1
      OnChange = cbConditionChange
      OnExit = cbConditionExit
    end
    object bbtnClose: TBitBtn
      Left = 509
      Top = 2
      Width = 15
      Height = 15
      TabOrder = 3
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
      Left = 8
      Top = 24
      Width = 294
      Height = 21
      DropDownCount = 24
      TopNodeEnabled = False
      AutoPopupWidth = True
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 0
      OnChange = cbFieldsChange
      OnExit = cbFieldsExit
    end
  end
end
