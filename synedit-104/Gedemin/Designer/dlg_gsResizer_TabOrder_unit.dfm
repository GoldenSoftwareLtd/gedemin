object dlg_gsResizer_TabOrder: Tdlg_gsResizer_TabOrder
  Left = 290
  Top = 212
  Width = 279
  Height = 271
  Anchors = [akLeft, akTop, akRight, akBottom]
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
  object Bevel1: TBevel
    Left = 8
    Top = 8
    Width = 258
    Height = 204
    Anchors = [akLeft, akTop, akRight, akBottom]
    Shape = bsFrame
  end
  object btnControlUp: TSpeedButton
    Left = 229
    Top = 80
    Width = 26
    Height = 26
    Anchors = [akRight, akBottom]
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
    Left = 229
    Top = 112
    Width = 26
    Height = 26
    Anchors = [akRight, akBottom]
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
  object lbControls: TListBox
    Left = 16
    Top = 16
    Width = 204
    Height = 188
    Anchors = [akLeft, akTop, akRight, akBottom]
    DragMode = dmAutomatic
    ItemHeight = 13
    TabOrder = 0
    OnDragDrop = lbControlsDragDrop
    OnDragOver = lbControlsDragOver
  end
  object btnOk: TButton
    Left = 128
    Top = 218
    Width = 65
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = 'ОК'
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 200
    Top = 218
    Width = 65
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 2
  end
  object btnHelp: TButton
    Left = 7
    Top = 218
    Width = 65
    Height = 21
    Anchors = [akLeft, akBottom]
    Caption = 'Помощь'
    TabOrder = 3
  end
end
