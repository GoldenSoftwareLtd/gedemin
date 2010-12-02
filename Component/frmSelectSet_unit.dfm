object frmSelectSet: TfrmSelectSet
  Left = 328
  Top = 201
  BorderStyle = bsNone
  ClientHeight = 135
  ClientWidth = 162
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 162
    Height = 135
    Align = alClient
    Caption = 'Panel1'
    TabOrder = 0
    object ListView: TListView
      Left = 1
      Top = 1
      Width = 160
      Height = 105
      Align = alTop
      Checkboxes = True
      Columns = <
        item
          Width = 100
        end>
      ShowColumnHeaders = False
      TabOrder = 0
      ViewStyle = vsReport
    end
    object btnOk: TButton
      Left = 4
      Top = 108
      Width = 75
      Height = 25
      Caption = 'OK'
      ModalResult = 1
      TabOrder = 1
    end
    object btnCancel: TButton
      Left = 84
      Top = 108
      Width = 75
      Height = 25
      Caption = 'Отмена'
      ModalResult = 2
      TabOrder = 2
    end
  end
end
