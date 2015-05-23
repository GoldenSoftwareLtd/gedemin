unit About;

// -----------------------------------------------------------------------------
// Application:     TextDiff                                                   .
// Module:          About                                                      .
// Version:         4.1                                                        .
// Date:            16-JAN-2004                                                .
// Target:          Win32, Delphi 7                                            .
// Author:          Angus Johnson - angusj-AT-myrealbox-DOT-com                .
// Copyright;       © 2003-2004 Angus Johnson                                  .
// -----------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ShellAPI;

type
  TAboutForm = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Image1: TImage;
    Button1: TButton;
    Label3: TLabel;
    procedure Label5Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Label6Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutForm: TAboutForm;

implementation

{$R *.DFM}

procedure TAboutForm.Label5Click(Sender: TObject);
var
  str: string;
begin
  Label5.cursor := crAppStart;
  application.processmessages; {otherwise cursor change will be missed}
  str := 'mailto:angusj@myrealbox.com?subject=TextDiff';
  ShellExecute(0, Nil, PChar(str), Nil, Nil, SW_NORMAL);
  Label5.cursor := crHandPoint;
end;

procedure TAboutForm.Label6Click(Sender: TObject);
begin
  Label6.cursor := crAppStart;
  application.processmessages;
  ShellExecute(0, Nil, PChar(Label6.caption), Nil, Nil, SW_NORMAL);
  Label6.cursor := crHandPoint;
end;

procedure TAboutForm.FormShow(Sender: TObject);
var
  l,t,w,h: integer;
begin
  w := width;
  h := height;
  with application.mainform do
  begin
    l := left + (width-self.width) div 2;
    t := top + (height-self.height) div 2;
  end;
  setbounds(l,t,w,h);
end;

end.
