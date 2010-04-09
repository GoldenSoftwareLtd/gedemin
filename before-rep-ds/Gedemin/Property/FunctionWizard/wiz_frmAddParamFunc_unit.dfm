inherited wizfrmAddParamsFunc: TwizfrmAddParamsFunc
  Left = 294
  Top = 295
  Width = 575
  Height = 206
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  inherited plnButton: TPanel
    Top = 143
    Width = 557
  end
  inherited pnlMain: TPanel
    Width = 557
    Height = 143
    inherited pnlFunction: TPanel
      Width = 555
      inherited lblFunction: TLabel
        Width = 555
      end
    end
    inherited sbParams: TScrollBox
      Width = 555
      Height = 63
      inherited pnlParam: TPanel
        Width = 546
        inherited lblParam: TLabel
          Top = 1
        end
        inherited edtParam: TBtnEdit
          Top = 14
          Width = 538
        end
      end
    end
    inherited pnlDescr: TPanel
      Top = 80
      Width = 555
      Height = 62
      inherited Bevel1: TBevel
        Width = 555
      end
      inherited mmDescription: TMemo
        Top = 3
        Width = 555
        Height = 59
        Align = alBottom
      end
    end
  end
  inherited pmAdd: TPopupMenu
    AutoHotkeys = maManual
    OnPopup = pmAddPopup
    inherited miAnalitics: TMenuItem
      Action = nil
      ImageIndex = 210
      OnClick = nil
    end
    object N2: TMenuItem [1]
      Action = actExpression
      ImageIndex = 209
    end
    object miVar: TMenuItem [2]
      Action = actAddVar
    end
    inherited miAccount: TMenuItem [3]
      Action = nil
      ImageIndex = 216
      OnClick = nil
    end
    inherited miFunction: TMenuItem [4]
    end
    inherited N1: TMenuItem [5]
      Visible = False
    end
  end
  inherited alAdd: TActionList
    object actAddVar: TAction [3]
      Caption = 'Переменную'
      ImageIndex = 135
      OnExecute = actAddVarExecute
    end
    object actExpression: TAction
      Caption = 'Выражение'
      OnExecute = actExpressionExecute
    end
  end
end
