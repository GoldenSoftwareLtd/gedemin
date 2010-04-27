object frmCalculateBalance: TfrmCalculateBalance
  Left = 448
  Top = 209
  BorderStyle = bsDialog
  Caption = 'Переход на новый месяц'
  ClientHeight = 335
  ClientWidth = 372
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlMain: TPanel
    Left = 0
    Top = 0
    Width = 372
    Height = 335
    Align = alClient
    TabOrder = 0
    object lblPreviousDate: TLabel
      Left = 7
      Top = 10
      Width = 183
      Height = 13
      Caption = 'Дата предыдущего расчета сальдо:'
    end
    object gbMain: TGroupBox
      Left = 7
      Top = 30
      Width = 359
      Height = 264
      Anchors = [akLeft, akTop, akRight, akBottom]
      Caption = ' Расчет '
      TabOrder = 1
      object lblCurrentDate: TLabel
        Left = 10
        Top = 20
        Width = 134
        Height = 13
        Caption = 'Расчитать сальдо на дату:'
      end
      object xdeCurrentDate: TxDateEdit
        Left = 264
        Top = 16
        Width = 86
        Height = 21
        Kind = kDate
        Anchors = [akTop, akRight]
        EditMask = '!99\.99\.9999;1;_'
        MaxLength = 10
        TabOrder = 0
        Text = '21.10.2008'
      end
      object pbMain: TProgressBar
        Left = 10
        Top = 82
        Width = 338
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Min = 0
        Max = 100
        Smooth = True
        Step = 1
        TabOrder = 2
      end
      object btnCalculate: TButton
        Left = 263
        Top = 45
        Width = 86
        Height = 25
        Anchors = [akTop, akRight]
        Caption = 'Рассчитать'
        TabOrder = 1
        OnClick = btnCalculateClick
      end
      object mProgress: TMemo
        Left = 10
        Top = 107
        Width = 338
        Height = 146
        Color = clBtnFace
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 3
      end
    end
    object btnClose: TButton
      Left = 284
      Top = 302
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Закрыть'
      Default = True
      TabOrder = 2
      OnClick = btnCloseClick
    end
    object xdePreviousDate: TxDateEdit
      Left = 271
      Top = 6
      Width = 86
      Height = 21
      Kind = kDate
      Anchors = [akTop, akRight]
      Enabled = False
      EditMask = '!99\.99\.9999;1;_'
      MaxLength = 10
      TabOrder = 0
      Text = '21.10.2008'
    end
  end
end
