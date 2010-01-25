object frmIBFilterSummary: TfrmIBFilterSummary
  Left = 192
  Top = 120
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Filter Summary'
  ClientHeight = 199
  ClientWidth = 437
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  PixelsPerInch = 96
  TextHeight = 13
  object lstSummary: TListView
    Left = 8
    Top = 8
    Width = 421
    Height = 149
    Columns = <
      item
        Caption = 'Field'
        Width = 100
      end
      item
        Caption = 'Search Type'
        Width = 150
      end
      item
        Caption = 'Value'
        Width = 150
      end>
    TabOrder = 0
    ViewStyle = vsReport
  end
  object btnOk: TBitBtn
    Left = 181
    Top = 168
    Width = 75
    Height = 25
    TabOrder = 1
    Kind = bkOK
  end
end
