object gdv_dlgInvCardParams: Tgdv_dlgInvCardParams
  Left = 375
  Top = 247
  Width = 516
  Height = 436
  Caption = 'Ввод значений параметров карточки ТМЦ'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 508
    Height = 377
    BevelOuter = bvNone
    TabOrder = 0
    object pnlDate: TPanel
      Left = 0
      Top = 57
      Width = 508
      Height = 30
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      object Bevel1: TBevel
        Left = 0
        Top = 28
        Width = 508
        Height = 2
        Align = alBottom
        Style = bsRaised
      end
      object Bevel2: TBevel
        Left = 0
        Top = 0
        Width = 508
        Height = 2
        Align = alTop
        Style = bsRaised
      end
      object Label8: TLabel
        Left = 8
        Top = 8
        Width = 41
        Height = 13
        Caption = 'Период:'
      end
      object gsPeriodEdit: TgsPeriodEdit
        Left = 53
        Top = 5
        Width = 148
        Height = 21
        TabOrder = 0
      end
    end
    object pcValues: TPageControl
      Left = 0
      Top = 183
      Width = 508
      Height = 194
      ActivePage = tsCardValues
      Align = alClient
      TabOrder = 1
      object tsCardValues: TTabSheet
        Caption = 'Карточки'
        inline frCardValues: TfrFieldValues
          Width = 500
          Height = 166
          Align = alClient
          inherited ppMain: TgdvParamPanel
            Width = 500
          end
          inherited sbMain: TgdvParamScrolBox
            Width = 500
            Height = 136
          end
        end
      end
      object tsGoodValues: TTabSheet
        Caption = 'Товара'
        ImageIndex = 1
        inline frGoodValues: TfrFieldValues
          Width = 500
          Height = 166
          Align = alClient
          inherited ppMain: TgdvParamPanel
            Width = 500
          end
          inherited sbMain: TgdvParamScrolBox
            Width = 500
            Height = 136
          end
        end
      end
    end
    inline frMainValues: TfrFieldValues
      Width = 508
      Height = 57
      Align = alTop
      TabOrder = 2
      inherited ppMain: TgdvParamPanel
        Width = 508
      end
      inherited sbMain: TgdvParamScrolBox
        Width = 508
        Height = 27
        BorderStyle = bsNone
        Color = clBtnFace
      end
      inherited pmCondition: TPopupMenu
        Top = 32
      end
    end
    inline frDebitDocsValues: TfrFieldValues
      Top = 87
      Width = 508
      Height = 48
      Align = alTop
      TabOrder = 3
      inherited ppMain: TgdvParamPanel
        Width = 508
        Caption = 'Документы прихода'
      end
      inherited sbMain: TgdvParamScrolBox
        Width = 508
        Height = 18
        BorderStyle = bsNone
        Color = clBtnFace
      end
    end
    inline frCreditDocsValues: TfrFieldValues
      Top = 135
      Width = 508
      Height = 48
      Align = alTop
      TabOrder = 4
      inherited ppMain: TgdvParamPanel
        Width = 508
        Caption = 'Документы расхода'
      end
      inherited sbMain: TgdvParamScrolBox
        Width = 508
        Height = 18
        BorderStyle = bsNone
        Color = clBtnFace
      end
    end
  end
  object btnOK: TButton
    Left = 366
    Top = 385
    Width = 68
    Height = 21
    Action = actOk
    Anchors = [akLeft, akBottom]
    Default = True
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 438
    Top = 385
    Width = 68
    Height = 21
    Action = actCancel
    Anchors = [akLeft, akBottom]
    Cancel = True
    TabOrder = 2
  end
  object ActionList1: TActionList
    Left = 304
    Top = 49
    object actOk: TAction
      Caption = 'Ok'
      ShortCut = 16397
      OnExecute = actOkExecute
    end
    object actCancel: TAction
      Caption = 'Отмена'
      ShortCut = 27
      OnExecute = actCancelExecute
    end
    object actPrepare: TAction
      Caption = 'actPrepare'
      OnExecute = actPrepareExecute
    end
  end
end
