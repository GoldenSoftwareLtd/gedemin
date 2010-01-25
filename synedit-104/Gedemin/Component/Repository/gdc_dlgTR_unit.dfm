inherited gdc_dlgTR: Tgdc_dlgTR
  Left = 129
  Top = 94
  Caption = 'gdc_dlgTR'
  ClientHeight = 333
  ClientWidth = 529
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnOK: TButton
    Anchors = [akTop, akRight]
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
