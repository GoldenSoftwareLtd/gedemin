object frPreviewForm: TfrPreviewForm
  Left = 233
  Top = 115
  AutoScroll = False
  Caption = 'Print preview'
  ClientHeight = 293
  ClientWidth = 459
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clBlack
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Icon.Data = {
    0000010001001010100000000000280100001600000028000000100000002000
    00000100040000000000C0000000000000000000000000000000000000000000
    0000000080000080000000808000800000008000800080800000C0C0C0008080
    80000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF000000
    E00000000E0000000E00000EEE00000000E0EEEEE000F00000EEEEE00000FF00
    00EE000000000FF0000EEEEEE000000F0000E00EEEE00000F00E0E0000EE0FFF
    FFF000E0000E00FFFFFFEEEEEEEE000000FEEEEEEEE00000000F0000000000FF
    0000F000000000FFF000F000000000FFFFFFFFFFF00000000FFFFFFFFF00F7FB
    0000FBE30000FD0700007C1F00003CFF00009E070000EF610000F6BC000081DE
    0000C0000000FC010000FEFF0000CF7F0000C77F0000C0070000F8030000}
  KeyPreview = True
  OldCreateOrder = True
  Scaled = False
  ShowHint = True
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnDeactivate = FormDeactivate
  OnKeyDown = FormKeyDown
  OnMouseDown = FormMouseDown
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object TPanel: TPanel
    Left = 0
    Top = 0
    Width = 459
    Height = 33
    Align = alTop
    BevelOuter = bvNone
    FullRepaint = False
    TabOrder = 0
    object Bevel2: TBevel
      Left = 0
      Top = 0
      Width = 459
      Height = 2
      Align = alTop
    end
    object Panel1: TPanel
      Left = 4
      Top = 6
      Width = 273
      Height = 24
      BevelOuter = bvNone
      TabOrder = 0
      object ZoomBtn: TfrTBButton
        Tag = 200
        Left = 0
        Top = 0
        Width = 53
        Height = 24
        Caption = '200%'
        Glyph.Data = {
          F6000000424DF600000000000000760000002800000010000000100000000100
          0400000000008000000000000000000000001000000010000000000000000000
          80000080000000808000800000008000800080800000C0C0C000808080000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
          7777777708077777777777770807777777777777080777777777777708077777
          7777777708077777777777770807777777777777080777777777777708077777
          7777700000000000000770880808888888877000000000000007777708077777
          7777777708077777777777770007777777777777777777777777}
        GrayedInactive = False
        Margin = 3
        OnClick = ZoomBtnClick
        ImageIndex = 0
        Align = alLeft
      end
      object frTBSeparator1: TfrTBSeparator
        Left = 53
        Top = 0
        Width = 8
        Height = 24
        Align = alLeft
        DrawBevel = False
      end
      object LoadBtn: TfrTBButton
        Tag = 201
        Left = 61
        Top = 0
        Width = 24
        Height = 24
        Glyph.Data = {
          F6000000424DF600000000000000760000002800000010000000100000000100
          0400000000008000000000000000000000001000000010000000000000000000
          80000080000000808000800000008000800080800000C0C0C000808080000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
          77777777777777777777000000000007777700333333333077770B0333333333
          07770FB03333333330770BFB0333333333070FBFB000000000000BFBFBFBFB07
          77770FBFBFBFBF0777770BFB0000000777777000777777770007777777777777
          7007777777770777070777777777700077777777777777777777}
        GrayedInactive = False
        OnClick = LoadBtnClick
        ImageIndex = 0
        Align = alLeft
      end
      object SaveBtn: TfrTBButton
        Tag = 202
        Left = 85
        Top = 0
        Width = 24
        Height = 24
        Glyph.Data = {
          F6000000424DF600000000000000760000002800000010000000100000000100
          0400000000008000000000000000000000001000000010000000000000000000
          80000080000000808000800000008000800080800000C0C0C000808080000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
          7777770000000000000770330000007703077033000000770307703300000077
          0307703300000000030770333333333333077033000000003307703077777777
          0307703077777777030770307777777703077030777777770307703077777777
          0007703077777777070770000000000000077777777777777777}
        GrayedInactive = False
        OnClick = SaveBtnClick
        ImageIndex = 0
        Align = alLeft
      end
      object PrintBtn: TfrTBButton
        Tag = 203
        Left = 109
        Top = 0
        Width = 24
        Height = 24
        Glyph.Data = {
          F6000000424DF600000000000000760000002800000010000000100000000100
          0400000000008000000000000000000000001000000010000000000000000000
          80000080000000808000800000008000800080800000C0C0C000808080000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
          77777700000000000777707777777770707700000000000007070777777BBB77
          0007077777788877070700000000000007700777777777707070700000000007
          0700770FFFFFFFF070707770F00000F000077770FFFFFFFF077777770F00000F
          077777770FFFFFFFF07777777000000000777777777777777777}
        GrayedInactive = False
        OnClick = PrintBtnClick
        ImageIndex = 0
        Align = alLeft
      end
      object frTBSeparator2: TfrTBSeparator
        Left = 157
        Top = 0
        Width = 8
        Height = 24
        Align = alLeft
        DrawBevel = False
      end
      object FindBtn: TfrTBButton
        Tag = 204
        Left = 165
        Top = 0
        Width = 24
        Height = 24
        Glyph.Data = {
          F6000000424DF600000000000000760000002800000010000000100000000100
          0400000000008000000000000000000000001000000010000000000000000000
          8000008000000080800080000000800080008080000080808000C0C0C0000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00888888888888
          8888888888888888888800000888880000080F000888880F00080F000888880F
          0008000000080000000800F000000F00000800F000800F00000800F000800F00
          00088000000000000088880F00080F0008888800000800000888888000888000
          88888880F08880F0888888800088800088888888888888888888}
        GrayedInactive = False
        OnClick = FindBtnClick
        ImageIndex = 0
        Align = alLeft
      end
      object HelpBtn: TfrTBButton
        Left = 189
        Top = 0
        Width = 24
        Height = 24
        Glyph.Data = {
          F6000000424DF600000000000000760000002800000010000000100000000100
          0400000000008000000000000000000000001000000010000000000000000000
          8000008000000080800080000000800080008080000080808000C0C0C0000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00888888888888
          8888888880088888888888888008888888888888008888444888088800888844
          4888008008888888888800000888884478880000000088447888000000088884
          4888000000888888447800000887448874470000888447888444000888844788
          8444008888884488744708888888844444788888888888888888}
        GrayedInactive = False
        OnClick = HelpBtnClick
        ImageIndex = 0
        Align = alLeft
      end
      object frTBSeparator3: TfrTBSeparator
        Left = 213
        Top = 0
        Width = 8
        Height = 24
        Align = alLeft
        DrawBevel = False
      end
      object ExitBtn: TfrTBButton
        Tag = 205
        Left = 221
        Top = 0
        Width = 24
        Height = 24
        Glyph.Data = {
          F6000000424DF600000000000000760000002800000010000000100000000100
          0400000000008000000000000000000000001000000010000000000000000000
          80000080000000808000800000008000800080800000C0C0C000808080000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
          777777777777777770F77770F7777777777777000F7777770F7777000F777770
          F777777000F77700F7777777000F700F77777777700000F77777777777000F77
          77777777700000F777777777000F70F77777770000F77700F77770000F777770
          0F77700F7777777700F777777777777777777777777777777777}
        GrayedInactive = False
        OnClick = ExitBtnClick
        ImageIndex = 0
        Align = alLeft
      end
      object PageSetupBtn: TfrTBButton
        Tag = 203
        Left = 133
        Top = 0
        Width = 24
        Height = 24
        Glyph.Data = {
          F6000000424DF600000000000000760000002800000010000000100000000100
          0400000000008000000000000000000000001000000010000000000000000000
          80000080000000808000800000008000800080800000C0C0C000808080000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
          77777700000000000077770F7FFFFFF7F0777707777777777077770F7FFFFFF7
          F077770F7FFFFFF7F077770F7FFFFFF7F077770F7FFFFFF7F077770F7FFFFFF7
          F077770F7FFFFFF7F077770F7FFFFFF7F077770F7FFFFF00007777077777770F
          0777770F7FFFFF00777777000000000777777777777777777777}
        GrayedInactive = False
        OnClick = PageSetupBtnClick
        ImageIndex = 0
        Align = alLeft
      end
    end
  end
  object PreviewPanel: TPanel
    Left = 0
    Top = 33
    Width = 459
    Height = 260
    Align = alClient
    BevelOuter = bvNone
    FullRepaint = False
    TabOrder = 1
    object ScrollBox1: TScrollBox
      Left = 0
      Top = 0
      Width = 459
      Height = 242
      Align = alClient
      TabOrder = 0
      object RPanel: TPanel
        Left = 439
        Top = 0
        Width = 16
        Height = 238
        Align = alRight
        BevelOuter = bvNone
        FullRepaint = False
        TabOrder = 0
        object PgUp: TfrSpeedButton
          Left = 0
          Top = 186
          Width = 16
          Height = 16
          Glyph.Data = {
            D6000000424DD60000000000000076000000280000000C0000000C0000000100
            0400000000006000000000000000000000001000000010000000000000000000
            80000080000000808000800000008000800080800000C0C0C000808080000000
            FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
            0000777777777777000077777777777700007770000077770000777700077777
            0000777770777777000077777777777700007770000077770000777700077777
            0000777770777777000077777777777700007777777777770000}
          OnClick = PgUpClick
          ImageIndex = 0
        end
        object PgDown: TfrSpeedButton
          Left = 0
          Top = 202
          Width = 16
          Height = 16
          Glyph.Data = {
            D6000000424DD60000000000000076000000280000000C0000000C0000000100
            0400000000006000000000000000000000001000000010000000000000000000
            80000080000000808000800000008000800080800000C0C0C000808080000000
            FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
            0000777777777777000077777077777700007777000777770000777000007777
            0000777777777777000077777077777700007777000777770000777000007777
            0000777777777777000077777777777700007777777777770000}
          OnClick = PgDownClick
          ImageIndex = 0
        end
        object VScrollBar: TScrollBar
          Left = 0
          Top = 0
          Width = 16
          Height = 185
          Ctl3D = True
          Kind = sbVertical
          LargeChange = 200
          Max = 32000
          PageSize = 0
          ParentCtl3D = False
          SmallChange = 10
          TabOrder = 0
          TabStop = False
          OnChange = VScrollBarChange
          OnEnter = HScrollBarEnter
        end
      end
    end
    object BPanel: TPanel
      Left = 0
      Top = 242
      Width = 459
      Height = 18
      Align = alBottom
      BevelOuter = bvNone
      FullRepaint = False
      TabOrder = 1
      object Bevel1: TBevel
        Tag = 206
        Left = 0
        Top = 1
        Width = 77
        Height = 17
      end
      object Label1: TLabel
        Tag = 206
        Left = 3
        Top = 3
        Width = 3
        Height = 13
      end
      object Bevel3: TBevel
        Tag = 206
        Left = 79
        Top = 1
        Width = 154
        Height = 17
      end
      object Label2: TLabel
        Tag = 206
        Left = 82
        Top = 3
        Width = 147
        Height = 13
        AutoSize = False
      end
      object HScrollBar: TScrollBar
        Left = 236
        Top = 1
        Width = 173
        Height = 16
        Ctl3D = True
        LargeChange = 200
        Max = 32000
        PageSize = 0
        ParentCtl3D = False
        SmallChange = 10
        TabOrder = 0
        TabStop = False
        OnChange = HScrollBarChange
        OnEnter = HScrollBarEnter
      end
    end
  end
  object ProcMenu: TPopupMenu
    Left = 84
    Top = 99
    object N2001: TMenuItem
      Tag = 200
      Caption = '200%'
      GroupIndex = 1
      RadioItem = True
      OnClick = N3Click
    end
    object N1501: TMenuItem
      Tag = 150
      Caption = '150%'
      GroupIndex = 1
      RadioItem = True
      OnClick = N3Click
    end
    object N1001: TMenuItem
      Tag = 100
      Caption = '100%'
      Checked = True
      GroupIndex = 1
      RadioItem = True
      OnClick = N3Click
    end
    object N751: TMenuItem
      Tag = 75
      Caption = '75%'
      GroupIndex = 1
      RadioItem = True
      OnClick = N3Click
    end
    object N501: TMenuItem
      Tag = 50
      Caption = '50%'
      GroupIndex = 1
      RadioItem = True
      OnClick = N3Click
    end
    object N251: TMenuItem
      Tag = 25
      Caption = '25%'
      GroupIndex = 1
      RadioItem = True
      OnClick = N3Click
    end
    object N101: TMenuItem
      Tag = 10
      Caption = '10%'
      GroupIndex = 1
      RadioItem = True
      OnClick = N3Click
    end
    object N1: TMenuItem
      Tag = 1
      Caption = 'Page width'
      GroupIndex = 1
      RadioItem = True
      OnClick = N3Click
    end
    object N2: TMenuItem
      Tag = 2
      Caption = 'Whole page'
      GroupIndex = 1
      RadioItem = True
      OnClick = N3Click
    end
    object N3: TMenuItem
      Tag = 3
      Caption = 'Two pages'
      GroupIndex = 1
      RadioItem = True
      OnClick = N3Click
    end
    object N4: TMenuItem
      Caption = '-'
      GroupIndex = 1
    end
    object N5: TMenuItem
      Caption = 'Edit page...'
      GroupIndex = 1
      OnClick = EditBtnClick
    end
    object N6: TMenuItem
      Caption = 'Add page'
      GroupIndex = 1
      OnClick = NewPageBtnClick
    end
    object N7: TMenuItem
      Caption = 'Remove page'
      GroupIndex = 1
      OnClick = DelPageBtnClick
    end
  end
  object OpenDialog: TOpenDialog
    Left = 124
    Top = 99
  end
  object SaveDialog: TSaveDialog
    Left = 164
    Top = 99
  end
end
