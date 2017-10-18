inherited gdc_dlgTR: Tgdc_dlgTR
  Left = 1375
  Top = 668
  Caption = 'gdc_dlgTR'
  ClientHeight = 333
  ClientWidth = 529
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnAccess: TButton
    Top = 303
    Anchors = [akLeft, akBottom]
  end
  inherited btnNew: TButton
    Top = 303
    Anchors = [akLeft, akBottom]
  end
  inherited btnHelp: TButton
    Top = 303
    Anchors = [akLeft, akBottom]
  end
  inherited btnOK: TButton
    Top = 303
    Anchors = [akRight, akBottom]
  end
  inherited btnCancel: TButton
    Top = 303
    Anchors = [akRight, akBottom]
  end
  object ibtrCommon: TIBTransaction
    Active = False
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    AutoStopAction = saNone
    Left = 440
    Top = 216
  end
end
