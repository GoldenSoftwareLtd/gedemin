{++

  Copyright (c) 2003 by Golden Software of Belarus

  Module

    inst_dlgSelfExtrInfo_unit

  Abstract

    Окно информации об установке самораспаковывающихся архивов. 

  Author

    Yuri Strokov

  Revisions history

    1.00    25.11.03    Yuri        Initial version.
                                                    
--}

unit inst_dlgSelfExtrInfo_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  Tinst_dlgSelfExtrInfo = class(TForm)
    btnClose: TButton;
    cbDontShowAgain: TCheckBox;
    Memo1: TMemo;
    Bevel1: TBevel;
    Button1: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    ProgramName: String;
  end;

var
  inst_dlgSelfExtrInfo: Tinst_dlgSelfExtrInfo;

implementation

{$R *.DFM}

procedure Tinst_dlgSelfExtrInfo.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if cbDontShowAgain.Checked then
    ModalResult := mrNo;    
end;


procedure Tinst_dlgSelfExtrInfo.FormShow(Sender: TObject);
begin
  Memo1.Lines[0] := Memo1.Lines[0] + ' ' + ProgramName; 
end;


procedure Tinst_dlgSelfExtrInfo.Button1Click(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

end.
