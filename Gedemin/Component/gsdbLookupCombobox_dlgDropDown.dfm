object dlgDropDown: TdbdlgDropDown
  Left = 434
  Top = 228
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
        Left = 0
        Top = 0
        Width = 16
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
      end
      object sbMerge: TSpeedButton
        Left = 48
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
      end
      object SpeedButton5: TSpeedButton
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
    BufferChunks = 32
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
      OnExecute = actNewExecute
      OnUpdate = actNewUpdate
    end
    object actEdit: TAction
      OnExecute = actEditExecute
      OnUpdate = actNewUpdate
    end
    object actDelete: TAction
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
  end
end
