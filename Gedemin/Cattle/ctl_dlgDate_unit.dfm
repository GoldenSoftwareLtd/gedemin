object ctl_dlgDate: Tctl_dlgDate
  Left = 475
  Top = 278
  BorderStyle = bsDialog
  Caption = 'Дата'
  ClientHeight = 191
  ClientWidth = 278
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 200
    Height = 13
    Caption = 'Выберите дату для отметки квитанций:'
  end
  object Button1: TButton
    Left = 205
    Top = 32
    Width = 65
    Height = 21
    Caption = 'ОК'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object Button2: TButton
    Left = 205
    Top = 56
    Width = 65
    Height = 21
    Cancel = True
    Caption = 'Отмена'
    ModalResult = 2
    TabOrder = 2
  end
  object MonthCalendar: TMonthCalendar
    Left = 8
    Top = 32
    Width = 191
    Height = 154
    Date = 37055
    TabOrder = 0
  end
end
