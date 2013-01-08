object frmDropDown: TfrmDropDown
  Left = 402
  Top = 213
  Width = 282
  Height = 241
  Caption = 'frmDropDown'
  Color = clBtnFace
  Constraints.MinHeight = 10
  Constraints.MinWidth = 30
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnHide = FormHide
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object ActionList: TActionList
    Left = 176
    Top = 48
    object actCancel: TAction
      Caption = 'actCancel'
      ShortCut = 27
      OnExecute = actCancelExecute
    end
  end
end
