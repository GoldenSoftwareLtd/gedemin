object dlg_gsResizer_TabOrder: Tdlg_gsResizer_TabOrder
  Left = 348
  Top = 171
  Width = 398
  Height = 382
  Anchors = [akLeft, akTop, akRight, akBottom]
  BorderStyle = bsSizeToolWin
  BorderWidth = 3
  Caption = 'Табуляция'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  object pnlMain: TPanel
    Left = 0
    Top = 0
    Width = 376
    Height = 311
    Align = alClient
    TabOrder = 0
    object lbControls: TListBox
      Left = 1
      Top = 1
      Width = 340
      Height = 309
      Align = alClient
      DragMode = dmAutomatic
      ItemHeight = 13
      TabOrder = 0
      OnDragDrop = lbControlsDragDrop
      OnDragOver = lbControlsDragOver
    end
    object pnlUpDown: TPanel
      Left = 341
      Top = 1
      Width = 34
      Height = 309
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 1
      object btnControlUp: TSpeedButton
        Left = 4
        Top = 127
        Width = 26
        Height = 26
        Anchors = [akTop, akRight]
        Glyph.Data = {
          66010000424D6601000000000000760000002800000014000000140000000100
          040000000000F000000000000000000000001000000010000000000000000000
          BF0000BF000000BFBF00BF000000BF00BF00BFBF0000C0C0C000808080000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
          7777777700007777777777777777777700007777777777777777777700007777
          777FCCCCC777777700007777777FCCCCC777777700007777777FCCCCC7777777
          00007777777FCCCCC777777700007777777FCCCCC777777700007777777FCCCC
          C777777700007777777FCCCCC77777770000777FCCCCCCCCCCCCC77700007777
          FCCCCCCCCCCC7777000077777FCCCCCCCCC777770000777777FCCCCCCC777777
          00007777777FCCCCC7777777000077777777FCCC777777770000777777777FC7
          7777777700007777777777777777777700007777777777777777777700007777
          77777777777777770000}
        OnClick = btnControlUpClick
      end
      object btnControlDown: TSpeedButton
        Left = 4
        Top = 157
        Width = 26
        Height = 26
        Anchors = [akTop, akRight]
        Glyph.Data = {
          66010000424D6601000000000000760000002800000014000000140000000100
          040000000000F000000000000000000000001000000010000000000000000000
          BF0000BF000000BFBF00BF000000BF00BF00BFBF0000C0C0C000808080000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
          7777777700007777777777777777777700007777777777777777777700007777
          77777FC777777777000077777777FCCC7777777700007777777FCCCCC7777777
          0000777777FCCCCCCC777777000077777FCCCCCCCCC7777700007777FCCCCCCC
          CCCC77770000777FCCCCCCCCCCCCC77700007777777FCCCCC777777700007777
          777FCCCCC777777700007777777FCCCCC777777700007777777FCCCCC7777777
          00007777777FCCCCC777777700007777777FCCCCC777777700007777777FCCCC
          C777777700007777777777777777777700007777777777777777777700007777
          77777777777777770000}
        OnClick = btnControlDownClick
      end
    end
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 311
    Width = 376
    Height = 27
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object btnHelp: TButton
      Left = 2
      Top = 5
      Width = 65
      Height = 21
      Anchors = [akLeft, akBottom]
      Caption = 'Помощь'
      TabOrder = 0
    end
    object pnlBottomRight: TPanel
      Left = 208
      Top = 0
      Width = 168
      Height = 27
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 1
      object btnOk: TButton
        Left = 31
        Top = 5
        Width = 65
        Height = 21
        Anchors = [akRight, akBottom]
        Caption = 'ОК'
        Default = True
        ModalResult = 1
        TabOrder = 0
      end
      object btnCancel: TButton
        Left = 103
        Top = 5
        Width = 65
        Height = 21
        Anchors = [akRight, akBottom]
        Cancel = True
        Caption = 'Отмена'
        ModalResult = 2
        TabOrder = 1
      end
    end
  end
end
