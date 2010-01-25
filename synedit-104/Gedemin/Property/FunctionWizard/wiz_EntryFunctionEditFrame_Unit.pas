unit wiz_EntryFunctionEditFrame_Unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  wiz_FunctionEditFrame_Unit, SynEditHighlighter, SynHighlighterVBScript,
  ActnList, SynEdit, ExtCtrls, StdCtrls, ComCtrls, wiz_FunctionBlock_unit;

type
  TfrEntryFunctionEditFrame = class(TfrFunctionEditFrame)
    cbNoDeleteLastResults: TCheckBox;
  private
    { Private declarations }
  protected
    procedure SetBlock(const Value: TVisualBlock); override;
  public
    { Public declarations }
    procedure SaveChanges; override;
  end;

var
  frEntryFunctionEditFrame: TfrEntryFunctionEditFrame;

implementation

{$R *.DFM}

{ TfrEntryFunctionEditFrame }

procedure TfrEntryFunctionEditFrame.SaveChanges;
begin
  inherited;
  if FBlock is TEntryFunctionBlock then
  begin
    TEntryFunctionBlock(FBlock).NoDeleteLastResults := cbNoDeleteLastResults.Checked;
  end;
end;

procedure TfrEntryFunctionEditFrame.SetBlock(const Value: TVisualBlock);
begin
  inherited;
  if FBlock is TEntryFunctionBlock then
  begin
    cbNoDeleteLastResults.Checked := TEntryFunctionBlock(FBlock).NoDeleteLastResults;
  end;
end;

end.
