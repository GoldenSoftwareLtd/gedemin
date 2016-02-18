object frmPrintReport: TfrmPrintReport
  Left = 95
  Top = 202
  Width = 685
  Height = 375
  Caption = 'Печать отчета'
  Color = 13556702
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 35
    Width = 587
    Height = 302
    Align = alClient
    BevelInner = bvLowered
    BevelOuter = bvNone
    BorderWidth = 4
    Caption = 'Panel1'
    ParentColor = True
    TabOrder = 0
  end
  object Panel2: TPanel
    Left = 587
    Top = 35
    Width = 82
    Height = 302
    Align = alRight
    BevelOuter = bvNone
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentColor = True
    ParentFont = False
    TabOrder = 1
  end
  object Panel3: TPanel
    Left = 0
    Top = 0
    Width = 669
    Height = 35
    Align = alTop
    BevelOuter = bvNone
    BorderWidth = 6
    ParentColor = True
    TabOrder = 2
    object xlbReport: TxLabel
      Left = 6
      Top = 6
      Width = 268
      Height = 23
      Align = alClient
      Caption = 'Печатная форма'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clBlack
      Font.Height = -19
      Font.Name = 'Times New Roman'
      Font.Style = []
      FromColor = 3246295
      ToColor = 13556702
    end
    object Panel4: TPanel
      Left = 274
      Top = 6
      Width = 389
      Height = 23
      Align = alRight
      BevelOuter = bvNone
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentColor = True
      ParentFont = False
      TabOrder = 0
      object Label1: TLabel
        Left = 255
        Top = 5
        Width = 49
        Height = 13
        Caption = 'Масштаб:'
      end
      object Label2: TLabel
        Left = 8
        Top = 5
        Width = 29
        Height = 13
        Caption = 'Файл'
      end
      object edFile: TEdit
        Left = 48
        Top = 1
        Width = 201
        Height = 19
        Ctl3D = False
        ParentCtl3D = False
        TabOrder = 0
      end
    end
  end
  object SaveDialog: TSaveDialog
    DefaultExt = 'rtf'
    FileName = '*.rtf'
    Filter = 'Файлы в формате RTF|*.rtf'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofNoReadOnlyReturn]
    Title = 'Запись на диск'
    Left = 412
    Top = 200
  end
  object FormPlaceSaver1: TFormPlaceSaver
    Left = 440
    Top = 200
  end
  object dsReport2: TDataSource
    Left = 356
    Top = 200
  end
  object dsReport1: TDataSource
    Left = 328
    Top = 200
  end
end
