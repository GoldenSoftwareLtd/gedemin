object dlgDropDown: TdlgDropDown
  Left = 842
  Top = 362
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderStyle = bsNone
  Caption = 'dlgDropDown'
  ClientHeight = 248
  ClientWidth = 330
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  OnCreate = FormCreate
  OnHide = FormHide
  OnKeyDown = FormKeyDown
  OnMouseDown = FormMouseDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlMain: TPanel
    Left = 0
    Top = 0
    Width = 330
    Height = 248
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 1
    Color = clWindowFrame
    TabOrder = 0
    object pnlToolbar: TPanel
      Left = 1
      Top = 1
      Width = 328
      Height = 16
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      object sbNew: TSpeedButton
        Left = 1
        Top = 0
        Width = 17
        Height = 16
        Action = actNew
        AllowAllUp = True
        Flat = True
        Glyph.Data = {
          E6010000424DE60100000000000036000000280000000C0000000C0000000100
          180000000000B0010000C40E0000C40E00000000000000000000FF00FFB78183
          B78183B78183B78183B78183B78183B78183B78183B78183B78183FF00FFFF00
          FFCEB2AAF8EADAF7E7D3F5E2CBF5DFC2F1D7B2F1D3AAF0D0A1F3D29BB78183FF
          00FFFF00FFD3B7AFFAEFE3F9EBDAF7E7D2F5E3C9F4DBBAF2D7B1F0D4A9F5D5A3
          B78183FF00FFFF00FFD7BBB2FBF3ECFAEFE2F9EADAF8E7D2F5DEC2F4DBBAF2D8
          B2F6D9ACB78183FF00FFFF00FFDABEB3FDF8F4FBF3ECF9EFE3F8EADAF6E2CAF6
          DEC1F4DBB9F8DDB4B78183FF00FFFF00FFDEC1B5FFFEFDFEF9F4FBF3EBFAEFE2
          F8E6D1F6E2C8F7E1C2F0DAB7B78183FF00FFFF00FFE2C5B5FFFFFFFFFEFDFDF9
          F4FBF3EBFAEDDCFCEFD9E6D9C4C6BCA9B78183FF00FFFF00FFE5C7B7FFFFFFFF
          FFFFFFFEFDFDF8F3F1E1D5C6A194B59489B08F81B78183FF00FFFF00FFE9CBB8
          FFFFFFFFFFFFFFFFFFFFFEFCE3CFC9BF8C76E8B270ECA54AC58768FF00FFFF00
          FFECCDBAFFFFFFFFFFFFFFFFFFFFFFFFE4D4D2C89A7FFAC577CD9377FF00FFFF
          00FFFF00FFEACAB6FBF6F3FBF6F3FAF5F3F9F5F3E1D0CEC7977CCF9B86FF00FF
          FF00FFFF00FFFF00FFE9C6B1EBCCB8EBCBB8EACBB8EACBB8DABBB0B8857AFF00
          FFFF00FFFF00FFFF00FF}
        ParentShowHint = False
        ShowHint = True
      end
      object sbEdit: TSpeedButton
        Left = 16
        Top = 0
        Width = 16
        Height = 16
        Action = actEdit
        AllowAllUp = True
        Flat = True
        Glyph.Data = {
          D6000000424DD60000000000000076000000280000000C0000000C0000000100
          04000000000060000000C40E0000C40E00001000000000000000000000000000
          8000008000000080800080000000800080008080000080808000C0C0C0000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00DDDDDDDDDDDD
          0000DDDDDDD0000D0000DDDDD00FF80D0000DDDD000F880D0000DDD03B3080DD
          0000DD03B3BB00DD0000D03B3BB30DDD000003B3BB30DDDD00003B3BB30DDDDD
          0000B3BB30DDDDDD00003BB30DDDDDDD0000BB30DDDDDDDD0000}
        ParentShowHint = False
        ShowHint = True
      end
      object sbDelete: TSpeedButton
        Left = 32
        Top = 0
        Width = 16
        Height = 16
        Action = actDelete
        AllowAllUp = True
        Flat = True
        Glyph.Data = {
          E6010000424DE60100000000000036000000280000000C0000000C0000000100
          180000000000B0010000C40E0000C40E00000000000000000000FF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF0732
          DE0732DEFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF0732DE07
          32DE0732DE0732DE0732DEFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF0732DE
          0732DEFF00FF0732DE0732DD0732DE0732DEFF00FFFF00FFFF00FFFF00FF0732
          DE0732DEFF00FFFF00FFFF00FF0534ED0732DF0732DE0732DDFF00FF0732DD07
          32DE0732DEFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF0732DD0633E60633E6
          0633E90732DCFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF0633
          E30732E30534EFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF07
          32DD0534ED0533E90434EF0434F5FF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
          0335FC0534EF0533EBFF00FFFF00FF0434F40335F8FF00FFFF00FFFF00FFFF00
          FF0335FB0335FB0434F8FF00FFFF00FFFF00FFFF00FF0335FC0335FBFF00FFFF
          00FF0335FB0335FB0335FBFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
          0335FBFF00FF0335FB0335FBFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
          FFFF00FFFF00FFFF00FF}
        ParentShowHint = False
        ShowHint = True
      end
      object sbMerge: TSpeedButton
        Left = 138
        Top = 0
        Width = 16
        Height = 16
        Action = actMerge
        AllowAllUp = True
        Flat = True
        Glyph.Data = {
          E6010000424DE60100000000000036000000280000000C0000000C0000000100
          180000000000B0010000C40E0000C40E00000000000000000000FF00FFFF00FF
          B48E888D5E5D8D5E5D8D5E5D8D5E5D8D5E5D8D5E5D8D5E5D8D5E5DFF00FFFF00
          FFFF00FFB48E88F9F1E4F5E2CDF4DFC9F3DEC5F2DDC3F2E2CDEBDBC98E5F5EFF
          00FFB48E888D5E5DB48E88FBF3E6FDD2A7FDD2A7FDD2A7FDD2A7FDD2A7EADCCB
          8E5F5EFF00FFB48E888D5E5DB48E88FEF8F0FAE3CBFAE1C7F9DFC6F9DEC3F6E6
          D4EDE0D2996D68FF00FFB48E88F9F1E4B48E88FEFBF5FDD2A7FDD2A7FDD2A7FD
          D2A7FDD2A7F0E5DAA57A75FF00FFB48E88FBF3E6B48E88FFFDFBFDEAD8FBE6D3
          FAE6D1FDE9D3FDF4E6E8E0D9A57974FF00FFB48E88FEF8F0B48E88FFFFFFFEFF
          FFFBFAF9FBFBF8EBDFDBD3C2C0BAA9AAB28175FF00FFB48E88FEFBF5B48E88FF
          FFFFFFFFFFFFFFFFFFFFFFB48E88B48E88B48E88B48E88FF00FFB48E88FFFDFB
          B48E88B48E88B48E88B48E88B48E88B48E88EBB56FC68C78FF00FFFF00FFB48E
          88FFFFFFFEFFFFFBFAF9FBFBF8EBDFDBD3C2C0BAA9AAB28175FF00FFFF00FFFF
          00FFB48E88FFFFFFFFFFFFFFFFFFFFFFFFB48E88B48E88B48E88B48E88FF00FF
          FF00FFFF00FFB48E88B48E88B48E88B48E88B48E88B48E88EBB56FFF00FFFF00
          FFFF00FFFF00FFFF00FF}
        ParentShowHint = False
        ShowHint = True
      end
      object sbShrink: TSpeedButton
        Left = 296
        Top = 0
        Width = 16
        Height = 16
        Action = actShrink
        AllowAllUp = True
        Anchors = [akTop, akRight]
        Flat = True
        Glyph.Data = {
          D6000000424DD60000000000000076000000280000000C0000000C0000000100
          0400000000006000000000000000000000001000000000000000000000000000
          8000008000000080800080000000800080008080000080808000C0C0C0000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00888888888888
          00008888888488880000888888C48888000088888C44888800008888C4448888
          0000888C444488880000888C4444888800008888C4448888000088888C448888
          0000888888C4888800008888888C888800008888888888880000}
      end
      object sbGrow: TSpeedButton
        Left = 312
        Top = 0
        Width = 16
        Height = 16
        Action = actGrow
        AllowAllUp = True
        Anchors = [akTop, akRight]
        Flat = True
        Glyph.Data = {
          D6000000424DD60000000000000076000000280000000C0000000C0000000100
          0400000000006000000000000000000000001000000000000000000000000000
          8000008000000080800080000000800080008080000080808000C0C0C0000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00888888888888
          000088884888888800008888C488888800008888C448888800008888C4448888
          00008888C444488800008888C444C88800008888C44C888800008888C4C88888
          00008888CC88888800008888C888888800008888888888880000}
      end
      object sbSelectObj: TSpeedButton
        Left = 57
        Top = 0
        Width = 16
        Height = 16
        Action = actSelectObj
        AllowAllUp = True
        Flat = True
        Glyph.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000FF00FF00FF00
          FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
          FF00FF00FF00C6D6C600B5C6BD00B5C6BD00FF00FF00FF00FF00FF00FF00BDCE
          C600B5C6B500B5C6B500B5C6B500B5C6B500B5C6B500B5C6B500B5C6B500B5C6
          B500B5BDB500949C94005A5A5A005A635A00B5C6B500FF00FF00BDCEC600848C
          840052525200424A4200424A4200424A4200424A4200424A4200424A4200424A
          4200635A5A008C7B9C006384AD00424A4200ADBDAD00FF00FF0073A5B5001884
          B5001884B500187BB500107BAD00107BAD001073AD000873A5000873A500397B
          9C008C84A5004A8CDE00319CDE00394242008C948C00C6CEC6001884B50042AD
          DE00D6FFFF007BD6FF006BD6FF006BD6FF006BD6FF006BD6FF007BCEEF00948C
          AD004A8CDE0052BDFF000873A500214A5A00636B6300BDC6BD00218CBD00298C
          C600DEFFFF00ADEFFF0094CEDE00CECEC600C6C6B500ADBDBD0094A5B5005A94
          D60052BDFF0073DEFF00107BAD00085A84004A4A4A00B5BDB500298CC6002994
          C60084CEF700CEC6CE00F7EFE700FFFFEF00FFFFDE00FFF7C600DEB59C0094C6
          DE007BE7FF0084EFFF00319CCE001884AD00424242008C9C9400298CC6004AB5
          E700399CD600DECEB500FFFFFF00FFFFFF00FFFFE700FFF7C600FFEFB500B5CE
          CE0094F7FF0094F7FF0052BDEF00107BA500294A52005A635A002994C6006BD6
          FF00218CBD00E7D6B500FFFFE700FFFFEF00FFFFDE00FFEFBD00FFEFBD00DED6
          BD009CFFFF009CFFFF0063C6FF0042ADCE00105A7B00394239002994C6007BE7
          FF0042ADD600DEC6A500FFFFD600FFFFCE00FFF7C600FFEFC600FFF7D600EFCE
          C600FFFFFF00FFFFFF0084E7FF007BDEEF0000639400424A42003194CE0084EF
          FF006BD6F700848C9400FFEFB500FFEFB500FFF7C600FFFFF700EFDED600528C
          B500218CBD002184BD001884B5001884B500006B9C00ADBDB500319CCE0094F7
          FF008CF7FF0094EFF700BDBDBD00EFCEAD00E7CEAD00DEC6BD00EFDEDE00FFFF
          FF00FFFFFF00FFFFFF00107BAD005A5A5A00B5C6B500FF00FF00319CCE00FFFF
          FF009CFFFF009CFFFF009CFFFF009CFFFF00FFFFFF00218CBD002184BD001884
          B5001884B5001884B500187BB500B5C6B500FF00FF00FF00FF00FF00FF00319C
          CE00FFFFFF00FFFFFF00FFFFFF00FFFFFF00298CC600A5ADA500FF00FF00FF00
          FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
          FF00319CCE00319CCE003194CE002994C600B5C6B500FF00FF00FF00FF00FF00
          FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
          FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
          FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00}
        ParentShowHint = False
        ShowHint = True
      end
      object sbSelectDoc: TSpeedButton
        Left = 81
        Top = 0
        Width = 16
        Height = 16
        Action = actSelectDoc
        AllowAllUp = True
        Flat = True
        Glyph.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000FF00FF00FF00
          FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
          FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF0052AD
          FF0018529400185A9C00185A9C00185A9C00185AA500185AA500185A9C00185A
          9C00185294001852940018528C00184A84004AADFF00FF00FF00FF00FF00185A
          A500186BBD001873CE001873CE001873CE001873CE001873CE001873CE001873
          CE001873CE00186BC600186BBD00185AA500104A7B00FF00FF00FF00FF001863
          AD001873CE00187BDE00187BDE00187BE7001884E7001884E7001884E7001884
          E7001884E700186BC600186BC6001863AD0018528C00FF00FF00FF00FF00186B
          C600187BDE00188CFF00188CFF00188CFF00188CFF00188CFF00188CFF00188C
          FF00188CFF001884E7001873CE00186BBD0018529400FF00FF00FF00FF001873
          CE001884E700188CFF00188CFF00188CFF00188CFF00188CFF00188CFF00188C
          FF00188CFF001884E7001873D600186BC600185A9C00FF00FF00FF00FF00187B
          DE00188CF700188CFF00188CFF00188CFF00188CFF00188CFF00188CFF00188C
          F700188CF7001884E7001873D6001873CE00185AA500FF00FF00FF00FF001884
          E700188CFF00188CFF0084C6FF0084C6FF001884EF0084C6FF0084C6FF00188C
          F70084C6FF0084C6FF001873CE001873CE001863AD00FF00FF00FF00FF001884
          EF00188CFF00188CFF00FFFFFF00FFFFFF00188CFF00FFFFFF00FFFFFF00188C
          F700FFFFFF00FFFFFF001873CE001873CE001863AD00FF00FF00FF00FF00188C
          FF002194FF002194FF00188CFF00188CFF00188CF7001884F7001884EF001884
          EF001884EF001873D6001873CE001873CE001863AD00FF00FF00FF00FF00188C
          FF0039A5FF0039A5FF002194FF001894FF00188CFF00188CFF001884EF001884
          E700187BDE00187BDE00187BDE001873CE001863AD00FF00FF00FF00FF002194
          FF0052ADFF004AADFF00299CFF002194FF002194FF001894FF00188CF7001884
          EF001884E700187BDE00187BDE001873CE001863AD00FF00FF00FF00FF0039A5
          FF006BBDFF0052ADFF0039A5FF00319CFF00299CFF00299CFF002194FF00188C
          FF001884F7001884EF00187BDE001873CE001863AD00FF00FF00FF00FF004AAD
          FF0084C6FF006BBDFF0052ADFF004AADFF0039A5FF00319CFF00299CFF002194
          FF001894FF00188CF7001884EF001873CE00185A9C00FF00FF00FF00FF00ADDE
          FF004AADFF00319CFF002194FF00188CFF00188CFF00188CF700188CF7001884
          EF001884E700187BDE001873CE00186BBD0063B5FF00FF00FF00FF00FF00FF00
          FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
          FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00}
        ParentShowHint = False
        ShowHint = True
      end
      object sbAcctAccCard: TSpeedButton
        Left = 97
        Top = 0
        Width = 16
        Height = 16
        Action = actAcctAccCard
        AllowAllUp = True
        Flat = True
        Glyph.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000FF00FF00FF00
          FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
          FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
          FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
          FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
          FF00FF00FF00CE630000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
          FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
          FF00FF00FF00CE630000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
          FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
          FF00FF00FF00CE630000FF00FF00FF00FF00CE630000CE630000CE630000CE63
          0000CE630000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
          FF00FF00FF00CE630000CE630000CE630000CE630000FFFFFF00FFFFFF00FFDE
          B500CE630000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
          FF00FF00FF00CE630000FF00FF00FF00FF00CE630000CE630000CE630000CE63
          0000CE630000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
          FF00FF00FF00CE630000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
          FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
          FF00FF00FF00CE630000FF00FF00FF00FF00CE630000CE630000CE630000CE63
          0000CE630000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
          FF00FF00FF00CE630000CE630000CE630000CE630000FFFFFF00FFFFFF00FFDE
          B500CE630000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
          FF00FF00FF00CE630000FF00FF00FF00FF00CE630000CE630000CE630000CE63
          0000CE630000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
          FF00FF00FF00CE630000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
          FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00CE63
          0000CE630000CE630000CE630000CE630000FF00FF00FF00FF00FF00FF00FF00
          FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00CE63
          0000FFFFFF00FFFFFF00FFDEB500CE630000FF00FF00FF00FF00FF00FF00FF00
          FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00CE63
          0000CE630000CE630000CE630000CE630000FF00FF00FF00FF00FF00FF00FF00
          FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
          FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
          FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00}
        ParentShowHint = False
        ShowHint = True
      end
      object sbFullCollapse: TSpeedButton
        Left = 113
        Top = 0
        Width = 16
        Height = 16
        Action = actFullCollapse
        AllowAllUp = True
        Flat = True
        Glyph.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000FF00FF00FF00
          FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
          FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
          FF00FF00FF00FF00FF00FF00FF00008400008400000084000000840000008400
          000084000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
          FF00FF00FF00FF00FF00FF00FF0000FF00000084000000840000008400000084
          000084000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
          FF00FF00FF00FF00FF00FF00FF0000FF00000084000000840000008400000084
          000084000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
          FF00FF00FF00FF00FF00FF00FF0000FF00000084000000840000008400000084
          000084000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF000084
          0000840000008400000084000000008400000084000000840000008400000084
          00008400000084000000840000008400000084000000FF00FF00FF00FF0000FF
          0000008400000084000000840000008400000084000000840000008400000084
          00000084000000840000008400000084000084000000FF00FF00FF00FF0000FF
          0000008400000084000000840000008400000084000000840000008400000084
          00000084000000840000008400000084000084000000FF00FF00FF00FF0000FF
          0000008400000084000000840000008400000084000000840000008400000084
          00000084000000840000008400000084000084000000FF00FF00FF00FF0000FF
          0000008400000084000000840000008400000084000000840000008400000084
          00000084000000840000008400000084000084000000FF00FF00FF00FF0000FF
          000000FF000000FF000000FF000000FF00000084000000840000008400000084
          00000084000000FF000000FF000000FF000000840000FF00FF00FF00FF00FF00
          FF00FF00FF00FF00FF00FF00FF0000FF00000084000000840000008400000084
          000084000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
          FF00FF00FF00FF00FF00FF00FF0000FF00000084000000840000008400000084
          000084000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
          FF00FF00FF00FF00FF00FF00FF0000FF00000084000000840000008400000084
          000084000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
          FF00FF00FF00FF00FF00FF00FF0000FF000000FF000000FF000000FF000000FF
          000084000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
          FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
          FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00}
        Margin = 0
        ParentShowHint = False
        ShowHint = True
      end
    end
    object gsDBGrid: TgsDBGrid
      Left = 1
      Top = 17
      Width = 328
      Height = 230
      HelpContext = 3
      Align = alClient
      BorderStyle = bsNone
      DataSource = dsList
      Options = [dgColLines, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit]
      RefreshType = rtNone
      TabOrder = 1
      OnCellClick = gsDBGridCellClick
      OnDblClick = gsDBGridDblClick
      OnKeyDown = gsDBGridKeyDown
      OnMouseMove = gsDBGridMouseMove
      InternalMenuKind = imkWithSeparator
      Expands = <>
      ExpandsActive = True
      ExpandsSeparate = False
      Conditions = <>
      ConditionsActive = False
      CheckBox.Visible = False
      CheckBox.FirstColumn = False
      ScaleColumns = True
      MinColWidth = 40
    end
    object tv: TgsDBTreeView
      Left = 1
      Top = 17
      Width = 328
      Height = 230
      DataSource = dsList
      KeyField = 'ID'
      ParentField = 'PARENT'
      DisplayField = 'NAME'
      Align = alClient
      BorderStyle = bsNone
      Indent = 19
      ReadOnly = True
      TabOrder = 2
      OnClick = tvClick
      OnKeyDown = tvKeyDown
      MainFolderHead = True
      MainFolder = False
      MainFolderCaption = '���'
      WithCheckBox = False
    end
  end
  object ibdsList: TIBDataSet
    Left = 120
    Top = 56
  end
  object dsList: TDataSource
    DataSet = ibdsList
    Left = 152
    Top = 56
  end
  object ActionList: TActionList
    Left = 120
    Top = 88
    object actNew: TAction
      Hint = '�������...'
      OnExecute = actNewExecute
      OnUpdate = actNewUpdate
    end
    object actEdit: TAction
      Hint = '�������������...'
      OnExecute = actEditExecute
      OnUpdate = actNewUpdate
    end
    object actDelete: TAction
      Hint = '�������'
      OnExecute = actDeleteExecute
      OnUpdate = actNewUpdate
    end
    object actMerge: TAction
      Enabled = False
      Visible = False
      OnExecute = actMergeExecute
      OnUpdate = actNewUpdate
    end
    object actShrink: TAction
      OnExecute = actShrinkExecute
      OnUpdate = actShrinkUpdate
    end
    object actGrow: TAction
      OnExecute = actGrowExecute
      OnUpdate = actGrowUpdate
    end
    object actSelectObj: TAction
      Hint = '������� ������...'
      OnExecute = actSelectObjExecute
      OnUpdate = actNewUpdate
    end
    object actSelectDoc: TAction
      Hint = '������� ��������...'
      OnExecute = actSelectDocExecute
      OnUpdate = actSelectDocUpdate
    end
    object actAcctAccCard: TAction
      Hint = '������� ����� �����...'
      OnExecute = actAcctAccCardExecute
      OnUpdate = actSelectDocUpdate
    end
    object actFullCollapse: TAction
      Hint = '������� ������...'
      OnExecute = actFullCollapseExecute
      OnUpdate = actFullCollapseUpdate
    end
  end
end
