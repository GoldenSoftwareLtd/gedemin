inherited ServerManager: TServerManager
  Left = 273
  Top = 262
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnProperty: TButton
    OnClick = btnPropertyClick
  end
  inherited btnDisconnect: TButton
    OnClick = btnDisconnectClick
  end
  inherited btnRefresh: TButton
    OnClick = btnRefreshClick
  end
  inherited btnRebuild: TButton
    OnClick = btnRebuildClick
  end
  inherited btnConnectParam: TButton
    OnClick = btnConnectParamClick
  end
  inherited btnRun: TButton
    OnClick = btnRunClick
  end
  inherited btnClear: TButton
    OnClick = btnClearClick
  end
  inherited ActionList1: TActionList
    inherited actClose: TAction
      OnExecute = actCloseExecute
    end
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 168
    Top = 40
  end
end
