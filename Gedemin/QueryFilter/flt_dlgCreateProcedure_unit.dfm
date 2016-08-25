object dlgCreateProcedure: TdlgCreateProcedure
  Left = 170
  Top = 159
  Width = 584
  Height = 345
  Caption = 'Текст процедуры'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  PixelsPerInch = 120
  TextHeight = 16
  object mmProcedureText: TMemo
    Left = 0
    Top = 50
    Width = 576
    Height = 217
    Align = alClient
    BiDiMode = bdLeftToRight
    ParentBiDiMode = False
    TabOrder = 0
  end
  object Panel1: TPanel
    Left = 0
    Top = 267
    Width = 576
    Height = 51
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object Panel2: TPanel
      Left = 348
      Top = 0
      Width = 228
      Height = 51
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
      object btnOk: TButton
        Left = 27
        Top = 10
        Width = 92
        Height = 31
        Caption = 'Сохранить'
        ModalResult = 1
        TabOrder = 0
        OnClick = btnOkClick
      end
      object btnCancel: TButton
        Left = 126
        Top = 10
        Width = 92
        Height = 31
        Cancel = True
        Caption = 'Отмена'
        ModalResult = 2
        TabOrder = 1
      end
    end
    object btnAbout: TButton
      Left = 10
      Top = 10
      Width = 92
      Height = 31
      Caption = 'Справка'
      TabOrder = 1
    end
    object btnRigth: TButton
      Left = 108
      Top = 10
      Width = 93
      Height = 31
      Caption = 'Права'
      TabOrder = 2
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 0
    Width = 576
    Height = 50
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 2
    object Label1: TLabel
      Left = 10
      Top = 14
      Width = 67
      Height = 16
      Caption = 'Описание'
    end
    object edDescription: TEdit
      Left = 89
      Top = 10
      Width = 483
      Height = 24
      BiDiMode = bdLeftToRight
      ParentBiDiMode = False
      TabOrder = 0
    end
  end
  object ibsqlCreate: TIBSQL
    ParamCheck = False
    Transaction = ibtrCreateProcedure
    Top = 280
  end
  object ibtrCreateProcedure: TIBTransaction
    Active = False
    Params.Strings = (
      'concurrency'
      'nowait')
    AutoStopAction = saNone
    Left = 32
    Top = 280
  end
  object ibeText: TIBExtract
    Transaction = ibtrCreateProcedure
    ShowSystem = False
    Left = 64
    Top = 281
  end
end
