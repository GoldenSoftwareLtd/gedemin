object frmCalculateBalance: TfrmCalculateBalance
  Left = 556
  Top = 232
  BorderStyle = bsDialog
  Caption = 'Переход на новый месяц'
  ClientHeight = 228
  ClientWidth = 312
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlMain: TPanel
    Left = 0
    Top = 0
    Width = 312
    Height = 228
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
      Width = 299
      Height = 157
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
      object lblProgress: TLabel
        Left = 15
        Top = 108
        Width = 268
        Height = 26
        AutoSize = False
        Caption = 'lblProgress'
        WordWrap = True
      end
      object lblTime: TLabel
        Left = 15
        Top = 135
        Width = 268
        Height = 13
        AutoSize = False
        Caption = 'lblTime'
      end
      object xdeCurrentDate: TxDateEdit
        Left = 198
        Top = 16
        Width = 92
        Height = 21
        Kind = kDate
        EditMask = '!99\.99\.9999;1;_'
        MaxLength = 10
        TabOrder = 0
        Text = '21.10.2008'
      end
      object pbMain: TProgressBar
        Left = 10
        Top = 82
        Width = 278
        Height = 17
        Anchors = [akLeft, akTop, akRight, akBottom]
        Min = 0
        Max = 100
        Smooth = True
        Step = 1
        TabOrder = 2
      end
      object btnCalculate: TButton
        Left = 197
        Top = 45
        Width = 92
        Height = 25
        Caption = 'Рассчитать'
        TabOrder = 1
        OnClick = btnCalculateClick
      end
    end
    object btnClose: TButton
      Left = 224
      Top = 195
      Width = 75
      Height = 25
      Anchors = [akLeft, akTop, akRight, akBottom]
      Cancel = True
      Caption = 'Закрыть'
      Default = True
      TabOrder = 2
      OnClick = btnCloseClick
    end
    object xdePreviousDate: TxDateEdit
      Left = 205
      Top = 6
      Width = 92
      Height = 21
      Kind = kDate
      Enabled = False
      EditMask = '!99\.99\.9999;1;_'
      MaxLength = 10
      TabOrder = 0
      Text = '21.10.2008'
    end
  end
end
