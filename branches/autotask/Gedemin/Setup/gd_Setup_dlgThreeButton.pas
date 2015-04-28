unit gd_Setup_dlgThreeButton;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type

  ThreeButtonResult = (tbFirst, tbSecond, tbThird, tbNone);
  
  TdlgThreeButton = class(TForm)
    pnlText: TPanel;
    pnlButton: TPanel;
    btnFirst: TButton;
    btnSecond: TButton;
    btnThird: TButton;
    lbText: TLabel;
    procedure btnFirstClick(Sender: TObject);
    procedure btnSecondClick(Sender: TObject);
    procedure btnThirdClick(Sender: TObject);
  private
    ThreeResult: ThreeButtonResult;
    { Private declarations }
  public
    { Public declarations }
  end;
  
  function ThreeButtonDialog(Const ACaption, AMessage, AFirstButton: String;
          Const AHelpCtx: Integer): ThreeButtonResult; overload;
  function ThreeButtonDialog(Const ACaption, AMessage, AFirstButton, ASecondButton: String; 
          Const AHelpCtx: Integer): ThreeButtonResult; overload;
  function ThreeButtonDialog(Const ACaption, AMessage, AFirstButton, ASecondButton, AThirdButton: String; 
          Const AHelpCtx: Integer): ThreeButtonResult; overload;
var
  dlgThreeButton: TdlgThreeButton;

implementation

{$R *.DFM}
function CreateThreeButtonDialog(Const ACaption, AMessage, AFirstButton, ASecondButton, 
                           AThirdButton: String; Const AButtonCount, AHelpCtx: Integer): ThreeButtonResult;
begin
  dlgThreeButton := TdlgThreeButton.Create(nil);
  with dlgThreeButton do
  begin
    btnSecond.Visible := False;
    btnThird.Visible := False;

    btnFirst.Visible := True;
    btnFirst.Caption := AFirstButton;
    
    if AButtonCount > 1 then 
    begin
      btnSecond.Visible := True;
      btnSecond.Caption := ASecondButton;
    end;
    
    if AButtonCount > 2 then 
    begin
      btnThird.Visible := True;
      btnThird.Caption := AThirdButton;
    end;
    
    Caption := ACaption;
    
    lbText.Caption := AMessage;
    
    case AButtonCount of
    1: btnFirst.Left := (pnlButton.Width div 2) - (BtnFirst.Width div 2);
    2: begin
         btnFirst.Left := (pnlButton.Width div 2) - BtnFirst.Width - (BtnFirst.Height div 2);
         btnSecond.Left := (pnlButton.Width div 2) + (BtnFirst.Height div 2);
       end;
    3: begin
         btnFirst.Left := (pnlButton.Width div 2) - BtnFirst.Width - (BtnFirst.Width div 2) - BtnFirst.Height;
         btnSecond.Left := (pnlButton.Width div 2) - (BtnFirst.Width div 2);
         btnThird.Left := (pnlButton.Width div 2) + (BtnFirst.Width div 2) + BtnFirst.Height;
       end;
    end;
    
    ThreeResult := tbNone;
    ShowModal;
    Result := ThreeResult;
  end;
end;

function ThreeButtonDialog(Const ACaption, AMessage, AFirstButton: String; Const AHelpCtx: Integer): ThreeButtonResult;
begin
  Result := CreateThreeButtonDialog(ACaption, AMessage, AFirstButton, '', '', 1, AHelpCtx);
end;

function ThreeButtonDialog(Const ACaption, AMessage, AFirstButton, ASecondButton: String; Const AHelpCtx: Integer): ThreeButtonResult;
begin
  Result := CreateThreeButtonDialog(ACaption, AMessage, AFirstButton, ASecondButton, '', 2, AHelpCtx);
end;

function ThreeButtonDialog(Const ACaption, AMessage, AFirstButton, ASecondButton, AThirdButton: String; Const AHelpCtx: Integer): ThreeButtonResult;
begin
  Result := CreateThreeButtonDialog(ACaption, AMessage, AFirstButton, ASecondButton, AThirdButton, 3, AHelpCtx);
end;


procedure TdlgThreeButton.btnFirstClick(Sender: TObject);
begin
  ThreeResult := tbFirst;
end;


procedure TdlgThreeButton.btnSecondClick(Sender: TObject);
begin
  ThreeResult := tbSecond;
end;

procedure TdlgThreeButton.btnThirdClick(Sender: TObject);
begin
  ThreeResult := tbThird;
end;

end.
