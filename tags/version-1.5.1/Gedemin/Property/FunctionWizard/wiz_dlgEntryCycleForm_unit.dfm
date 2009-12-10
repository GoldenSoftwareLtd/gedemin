inherited dlgEntryCycleForm: TdlgEntryCycleForm
  Left = 269
  Top = 165
  Caption = 'Свойства цикла по проводкам'
  ClientWidth = 422
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  inherited Panel1: TPanel
    Width = 422
    inherited Button1: TButton
      Left = 343
    end
    inherited Button2: TButton
      Left = 263
    end
  end
  inherited PageControl: TPageControl
    Width = 422
    inherited tsGeneral: TTabSheet
      inherited mDescription: TMemo
        Height = 71
      end
    end
    inherited tsAdditional: TTabSheet
      inherited beBeginDate: TBtnEdit
        Width = 289
      end
      inherited beEndDate: TBtnEdit
        Width = 289
      end
    end
  end
end
