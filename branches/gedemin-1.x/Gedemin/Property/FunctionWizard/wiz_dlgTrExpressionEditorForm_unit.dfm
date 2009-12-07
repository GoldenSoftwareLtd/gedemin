inherited dlgTrExpressionEditorForm: TdlgTrExpressionEditorForm
  OldCreateOrder = True
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  inherited TBDock: TTBDock
    Height = 73
    inherited tbtMain: TTBToolbar
      object TBItem1: TTBItem
        Action = actAddField
        DisplayMode = nbdmImageAndText
      end
    end
    inherited TBToolbar1: TTBToolbar
      Top = 48
    end
  end
  inherited Panel2: TPanel
    Top = 73
    Height = 301
    inherited mExpression: TSynMemo
      Height = 299
    end
  end
  inherited ActionList: TActionList
    object actAddField: TAction
      Caption = 'Добавить поле документа'
      ImageIndex = 141
      OnExecute = actAddFieldExecute
      OnUpdate = actAddFieldUpdate
    end
  end
  object pmAddField: TPopupMenu [4]
    OnPopup = pmAddFieldPopup
    Left = 112
    Top = 128
  end
end
