object gdv_frmG: Tgdv_frmG
  Left = 441
  Top = 456
  Width = 601
  Height = 404
  Caption = 'gdv_frmG'
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object TBDock1: TTBDock
    Left = 0
    Top = 0
    Width = 585
    Height = 30
    object tbMainToolbar: TTBToolbar
      Left = 0
      Top = 0
      Caption = 'Панель инструментов'
      DockPos = -7
      DockRow = 1
      Images = dmImages.il16x16
      Stretch = True
      TabOrder = 0
      object TBItem4: TTBItem
        Action = actFilter
      end
      object tbiPrint: TTBItem
        Action = actPrint
      end
      object tbiMacros: TTBItem
        Action = actMacros
      end
      object TBItem1: TTBItem
        Action = actHlp
      end
    end
    object TBToolbar2: TTBToolbar
      Left = 102
      Top = 0
      Caption = 'Период расчета'
      CloseButton = False
      DockPos = 80
      DockRow = 1
      Stretch = True
      TabOrder = 1
      object TBControlItem1: TTBControlItem
        Control = Panel4
      end
      object Panel4: TPanel
        Left = 0
        Top = 0
        Width = 275
        Height = 26
        BevelOuter = bvNone
        TabOrder = 0
        object lblPeriod: TLabel
          Left = 4
          Top = 6
          Width = 42
          Height = 13
          Caption = 'Период:'
        end
        object SpeedButton1: TSpeedButton
          Left = 202
          Top = 2
          Width = 23
          Height = 22
          Action = actRun
          Flat = True
          Glyph.Data = {
            36040000424D3604000000000000360000002800000010000000100000000100
            2000000000000004000000000000000000000000000000000000FF00FF00FF00
            FF00B5848400B5848400B5848400B5848400B5848400B5848400B5848400B584
            8400B5848400B5848400B5848400B5848400B5848400FF00FF00FF00FF00FF00
            FF00C6A59C00FFEFD600527BC600527BC600F7DEB500F7D6AD00F7D6A500EFCE
            9C00EFCE9400EFCE9400EFCE9400F7D69C00B5848400FF00FF00FF00FF00FF00
            FF00C6A59C00FFEFD60000F7FF00527BC600527BC6009C9C9C009C9C9C009C9C
            9C009C9C9C009C9C9C009C9C9C00EFCE9C00B5848400FF00FF00FF00FF00FF00
            FF00C6ADA500FFEFE70039A5FF0000F7FF00527BC600527BC600527BC600F7D6
            AD00EFCE9C00EFCE9C00EFCE9400EFCE9C00B5848400FF00FF00FF00FF00FF00
            FF00C6ADA500FFF7E700F7E7D60039A5FF0094FFFF0000F7FF00527BC600527B
            C600F7D6AD00EFCE9C00EFCE9C00EFCE9400B5848400FF00FF00FF00FF00FF00
            FF00CEB5AD00527BC600527BC600527BC600527BC60094FFFF0000F7FF00527B
            C600527BC6009C9C9C009C9C9C00EFCE9C00B5848400FF00FF00FF00FF00FF00
            FF00D6B5AD0039A5FF0094FFFF0000F7FF0000F7FF0000F7FF0000F7FF0000F7
            FF00527BC600527BC600F7D6A500F7D6A500B5848400FF00FF00FF00FF00FF00
            FF00D6BDB500FFFFFF0039A5FF0094FFFF0000F7FF00527BC600527BC600F7E7
            C600F7DEC600F7DEBD00F7D6B500F7D6AD00B5848400FF00FF00FF00FF00FF00
            FF00D6BDB500FFFFFF00DEDEDE0039A5FF0094FFFF0000F7FF00527BC600527B
            C6009C9C9C009C9C9C009C9C9C00F7DEB500B5848400FF00FF00FF00FF00FF00
            FF00DEBDB500FFFFFF00FFFFFF0039A5FF0094FFFF0000F7FF0000F7FF00527B
            C600527BC600F7DEC600F7DEC600F7D6B500B5848400FF00FF00FF00FF00FF00
            FF00DEC6B500FFFFFF00FFFFFF00FFFFFF0039A5FF0094FFFF0000F7FF0000F7
            FF00527BC600527BC600E7DEC600C6BDAD00B5848400FF00FF00FF00FF00FF00
            FF00E7C6B500FFFFFF00DEDEDE009C9C9C009C9C9C0039A5FF0094FFFF0000F7
            FF0000F7FF00527BC600527BC600B58C8400B5848400FF00FF00FF00FF00FF00
            FF00E7C6B500FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            F700E7CECE00BD8C7300EFB57300EFA54A00C6846B00FF00FF00FF00FF00FF00
            FF00EFCEBD00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00E7D6CE00C6947B00FFC67300CE947300FF00FF00FF00FF00FF00FF00FF00
            FF00E7C6B500FFF7F700FFF7EF00FFF7EF00FFF7EF00FFF7EF00FFF7EF00FFF7
            EF00E7CECE00C6947B00CE9C8400FF00FF00FF00FF00FF00FF00FF00FF00FF00
            FF00E7C6B500EFCEB500EFCEB500EFCEB500EFCEB500E7C6B500E7C6B500EFCE
            B500D6BDB500BD847B00FF00FF00FF00FF00FF00FF00FF00FF00}
        end
        object gsPeriodEdit: TgsPeriodEdit
          Left = 50
          Top = 2
          Width = 148
          Height = 21
          TabOrder = 0
        end
      end
    end
  end
  object Panel1: TPanel
    Left = 9
    Top = 30
    Width = 567
    Height = 330
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
  end
  object TBDock2: TTBDock
    Left = 0
    Top = 30
    Width = 9
    Height = 330
    Position = dpLeft
  end
  object TBDock3: TTBDock
    Left = 576
    Top = 30
    Width = 9
    Height = 330
    Position = dpRight
  end
  object TBDock4: TTBDock
    Left = 0
    Top = 360
    Width = 585
    Height = 9
    Position = dpBottom
  end
  object dsMain: TDataSource
    Left = 85
    Top = 175
  end
  object alMain: TActionList
    Images = dmImages.il16x16
    Left = 55
    Top = 175
    object actHlp: TAction
      Category = 'Commands'
      Caption = 'Помощь'
      Hint = 'Помощь'
      ImageIndex = 13
      ShortCut = 112
      OnExecute = actHlpExecute
    end
    object actPrint: TAction
      Category = 'Commands'
      Caption = 'Печать'
      Hint = 'Печать'
      ImageIndex = 15
      ShortCut = 16464
      OnExecute = actPrintExecute
    end
    object actMacros: TAction
      Category = 'Commands'
      Caption = 'Макросы'
      Hint = 'Макросы и события'
      ImageIndex = 21
      ShortCut = 16461
      OnExecute = actMacrosExecute
    end
    object actFilter: TAction
      Category = 'Commands'
      Caption = 'Фильтр'
      Hint = 'Фильтр'
      ImageIndex = 20
      ShortCut = 16454
      OnExecute = actFilterExecute
    end
    object actProperties: TAction
      Category = 'Commands'
      Caption = 'Свойства...'
      Hint = 'Свойства'
      ImageIndex = 28
    end
    object actQExport: TAction
      Caption = 'Экспорт...'
    end
    object actFilterQuery: TAction
      Caption = 'actFilterQuery'
      ShortCut = 16500
    end
    object actRun: TAction
      Category = 'Commands'
      ImageIndex = 73
      ShortCut = 116
      OnExecute = actRunExecute
    end
  end
  object gdMacrosMenu: TgdMacrosMenu
    Left = 249
    Top = 111
  end
  object gdReportMenu: TgdReportMenu
    Left = 285
    Top = 110
  end
  object gsQueryFilter: TgsQueryFilter
    Database = dmDatabase.ibdbGAdmin
    RequeryParams = False
    Left = 344
    Top = 32
  end
end
