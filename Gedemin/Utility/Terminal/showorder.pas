unit ShowOrder;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Windows, commctrl, ExtCtrls, BaseOperation, MessageForm;

type

  { TShowOrder }

  TShowOrder = class(TBaseOperation)
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { private declarations }
  protected
     procedure SetBarCode(const AKey: String); override;
  public
    { public declarations }
  end;

implementation

{$R *.lfm}
 procedure TShowOrder.SetBarCode(const AKey: String);
   begin
     MessageForm.MessageDlg('Для сканирования необходимо выйти из режима просмотра, нажав клавишу ESC!', 'Внимание',
          mtInformation, [mbOK]);
   end;
 procedure TShowOrder.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
   begin
      case Key of
       VK_UP:
        begin
          SendMessage(mTP.Handle, EM_SCROLL, SB_LINEUP,0);
          Key := 0;
        end;
        VK_DOWN:
        begin
          SendMessage(mTP.Handle, EM_SCROLL, SB_LINEDOWN,0);
          Key := 0;
        end;
       VK_ESCAPE: ModalResult := mrCancel;
       VK_F4:
        begin
          MessageForm.MessageDlg('Для ручного ввода необходимо выйти режима просмотра, нажав клавишу ESC!', 'Внимание',
            mtInformation, [mbOK]);
          Key := 0;
        end;
       VK_F2:
        begin
          MessageForm.MessageDlg('Для отмены последнего ввода необходимо выйти режима просмотра, нажав клавишу ESC!', 'Внимание',
            mtInformation, [mbOK]);
          Key := 0;
        end;
       VK_F3:
        begin
         MessageForm.MessageDlg('Для ручного ввода необходимо выйти режима просмотра, нажав клавишу ESC!', 'Внимание',
          mtInformation, [mbOK]);
         Key := 0;
        end;
     end;
   end;
end.

