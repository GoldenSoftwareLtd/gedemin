object frmNotebook: TfrmNotebook
  Left = 87
  Top = 190
  Width = 696
  Height = 320
  Caption = 'Блокнот'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object memo: TMemo
    Left = 0
    Top = 0
    Width = 688
    Height = 293
    Align = alClient
    Lines.Strings = (
      '')
    TabOrder = 0
  end
end
