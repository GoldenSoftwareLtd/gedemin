inherited frameQuantity: TframeQuantity
  inherited gbGroup: TGroupBox
    Caption = ' Количественные показатели '
    inherited Button1: TButton
      Visible = False
    end
    inherited Button2: TButton
      Visible = False
    end
  end
  inherited ActionList1: TActionList
    inherited actDown: TAction
      OnUpdate = actUpUpdate
    end
  end
end
