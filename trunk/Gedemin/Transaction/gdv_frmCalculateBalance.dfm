object frmCalculateBalance: TfrmCalculateBalance
  Left = 448
  Top = 209
  BorderStyle = bsDialog
  Caption = 'Переход на новый месяц'
  ClientHeight = 375
  ClientWidth = 408
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlMain: TPanel
    Left = 0
    Top = 0
    Width = 408
    Height = 375
    Align = alClient
    TabOrder = 0
    object lblPreviousDate: TLabel
      Left = 7
      Top = 10
      Width = 183
      Height = 13
      Caption = 'Дата предыдущего расчета сальдо:'
    end
    object lblPreviousDontBalanceAnalytic: TLabel
      Left = 7
      Top = 34
      Width = 153
      Height = 13
      Caption = 'Неучтенные ранее аналитики:'
    end
    object gbMain: TGroupBox
      Left = 7
      Top = 53
      Width = 395
      Height = 283
      Anchors = [akLeft, akTop, akRight, akBottom]
      Caption = ' Расчет '
      TabOrder = 2
      object lblCurrentDate: TLabel
        Left = 10
        Top = 20
        Width = 134
        Height = 13
        Caption = 'Расчитать сальдо на дату:'
      end
      object lblDontBalanceAnalytic: TLabel
        Left = 10
        Top = 44
        Width = 142
        Height = 13
        Caption = 'Неучитываемые аналитики:'
      end
      object xdeCurrentDate: TxDateEdit
        Left = 160
        Top = 16
        Width = 86
        Height = 21
        Kind = kDate
        Color = 11141119
        EditMask = '!99\.99\.9999;1;_'
        MaxLength = 10
        TabOrder = 0
        Text = '21.10.2008'
      end
      object pbMain: TProgressBar
        Left = 10
        Top = 101
        Width = 374
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Min = 0
        Max = 100
        Smooth = True
        Step = 1
        TabOrder = 3
      end
      object btnCalculate: TButton
        Left = 299
        Top = 68
        Width = 86
        Height = 25
        Action = actCalculate
        Anchors = [akTop, akRight]
        TabOrder = 2
      end
      object mProgress: TMemo
        Left = 10
        Top = 126
        Width = 374
        Height = 147
        Anchors = [akLeft, akTop, akRight, akBottom]
        Color = clBtnFace
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 4
      end
      object eDontBalanceAnalytic: TEdit
        Left = 160
        Top = 40
        Width = 204
        Height = 21
        TabOrder = 1
        Text = 'ePreviousDontBalanceAnalytic'
      end
      object TBToolbar1: TTBToolbar
        Left = 364
        Top = 39
        Width = 23
        Height = 22
        Caption = 'TBToolbar1'
        TabOrder = 5
        object TBItem1: TTBItem
          Action = actTestAnalyticList
          Images = dmImages.il16x16
        end
      end
    end
    object btnClose: TButton
      Left = 320
      Top = 343
      Width = 75
      Height = 25
      Action = actClose
      Anchors = [akRight, akBottom]
      Cancel = True
      Default = True
      TabOrder = 3
    end
    object xdePreviousDate: TxDateEdit
      Left = 196
      Top = 6
      Width = 86
      Height = 21
      Kind = kDate
      Color = clBtnFace
      EditMask = '!99\.99\.9999;1;_'
      MaxLength = 10
      ReadOnly = True
      TabOrder = 0
      Text = '21.10.2008'
    end
    object ePreviousDontBalanceAnalytic: TEdit
      Left = 196
      Top = 30
      Width = 205
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Color = clBtnFace
      ReadOnly = True
      TabOrder = 1
      Text = 'ePreviousDontBalanceAnalytic'
    end
  end
  object alMain: TActionList
    Images = dmImages.il16x16
    Left = 71
    Top = 118
    object actClose: TAction
      Caption = 'Закрыть'
      OnExecute = actCloseExecute
    end
    object actCalculate: TAction
      Caption = 'Рассчитать'
      OnExecute = actCalculateExecute
    end
    object actTestAnalyticList: TAction
      Caption = 'Проверить список полей'
      Hint = 'Проверить список полей'
      ImageIndex = 38
      OnExecute = actTestAnalyticListExecute
      OnUpdate = actTestAnalyticListUpdate
    end
  end
end
