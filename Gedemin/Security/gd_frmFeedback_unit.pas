unit gd_frmFeedback_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_createable_form, StdCtrls, ExtCtrls, ActnList;

type
  Tgd_frmFeedback = class(TCreateableForm)
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    al: TActionList;
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    procedure Label3Click(Sender: TObject);
    procedure Label4Click(Sender: TObject);
    procedure Label5Click(Sender: TObject);
    procedure RadioButton1Click(Sender: TObject);
    procedure RadioButton2Click(Sender: TObject);
    procedure RadioButton3Click(Sender: TObject);

  private
    FResult: Integer;

  public
    property Result: Integer read FResult;
  end;

var
  gd_frmFeedback: Tgd_frmFeedback;

implementation

{$R *.DFM}

procedure Tgd_frmFeedback.Label3Click(Sender: TObject);
begin
  FResult := 1;
  ModalResult := mrOk;
end;

procedure Tgd_frmFeedback.Label4Click(Sender: TObject);
begin
  FResult := 2;
  ModalResult := mrOk;
end;

procedure Tgd_frmFeedback.Label5Click(Sender: TObject);
begin
  FResult := 3;
  ModalResult := mrOk;
end;

procedure Tgd_frmFeedback.RadioButton1Click(Sender: TObject);
begin
  FResult := 1;
  ModalResult := mrOk;
end;

procedure Tgd_frmFeedback.RadioButton2Click(Sender: TObject);
begin
  FResult := 2;
  ModalResult := mrOk;
end;

procedure Tgd_frmFeedback.RadioButton3Click(Sender: TObject);
begin
  FResult := 3;
  ModalResult := mrOk;
end;

end.
