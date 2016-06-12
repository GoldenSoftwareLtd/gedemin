inherited dlgTrExpressionEditorForm: TdlgTrExpressionEditorForm
  OldCreateOrder = True
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  inherited TBDock: TTBDock
    Height = 75
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
  inherited pnlExpression: TPanel
    Top = 75
    Height = 287
    inherited mExpression: TMemo
      Height = 285
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
  object pmAddField: TPopupMenu
    OnPopup = pmAddFieldPopup
    Left = 112
    Top = 128
  end
end
