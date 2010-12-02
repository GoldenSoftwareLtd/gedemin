unit prp_PreparedScriptViewer_Unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, SynEditHighlighter, SynHighlighterVBScript, SynEdit,
  SynEditKeyCmds;

type
  TPreparedScriptViewer = class(TForm)
    SynEdit1: TSynEdit;
    SynVBScriptSyn1: TSynVBScriptSyn;
    Panel1: TPanel;
    Button1: TButton;
    Label1: TLabel;
    procedure SynEdit1CommandProcessed(Sender: TObject;
      var Command: TSynEditorCommand; var AChar: Char; Data: Pointer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  PreparedScriptViewer: TPreparedScriptViewer;

implementation

{$R *.DFM}

procedure TPreparedScriptViewer.SynEdit1CommandProcessed(Sender: TObject;
  var Command: TSynEditorCommand; var AChar: Char; Data: Pointer);
begin
  Label1.Caption := IntToStr(SynEdit1.CaretY) + ', ' + IntToStr(SynEdit1.CaretX);
end;

end.
