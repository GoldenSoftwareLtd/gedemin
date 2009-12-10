inherited gdc_frmFunction: Tgdc_frmFunction
  Left = 71
  Top = 83
  Caption = 'Глобальные скрипт-функции и VB-классы'
  PixelsPerInch = 96
  TextHeight = 13
  object gdcFunction: TgdcFunction
    ModifyFromStream = True
    MasterSource = dsMain
    MasterField = 'lb;rb'
    DetailField = 'lb;rb'
    SubSet = 'ByLBRBModule,OnlyFunction'
    CachedUpdates = False
    Left = 328
    Top = 200
  end
  object gdcDelphiObject: TgdcDelphiObject
    ModifyFromStream = True
    CachedUpdates = False
    ObjectType = otObject
    Left = 177
    Top = 121
  end
end
