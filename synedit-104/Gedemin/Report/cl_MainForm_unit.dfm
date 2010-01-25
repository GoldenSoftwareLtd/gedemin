object MainReportClient: TMainReportClient
  Left = 15
  Top = 45
  Width = 808
  Height = 580
  Caption = 'MainReportClient'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 120
  TextHeight = 16
  object Execute: TButton
    Left = 10
    Top = 10
    Width = 92
    Height = 31
    Caption = 'Execute'
    TabOrder = 0
    OnClick = ExecuteClick
  end
end
