unit Main;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, ExtCtrls, Menus, xRTFView, xRTF, xRTFSubs;

type
  TMainForm = class(TForm)
    SpeedBar: TPanel;
    SpeedButton1: TSpeedButton;  { &New }
    SpeedButton2: TSpeedButton;  { &Open... }
    SpeedButton3: TSpeedButton;  { &Save }
    SpeedButton4: TSpeedButton;  { Save &As... }
    SpeedButton5: TSpeedButton;  { &Print... }
    SpeedButton6: TSpeedButton;  { P&rint Setup... }
    SpeedButton7: TSpeedButton;
    RTFViewer: TxRTFViewer;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;  { E&xit }
    procedure FileNew(Sender: TObject);
    procedure FileOpen(Sender: TObject);
    procedure FileSave(Sender: TObject);
    procedure FileExit(Sender: TObject);
    procedure EditUndo(Sender: TObject);
    procedure EditCut(Sender: TObject);
    procedure EditCopy(Sender: TObject);
    procedure EditPaste(Sender: TObject);
    procedure WindowTile(Sender: TObject);
    procedure WindowCascade(Sender: TObject);
    procedure WindowArrange(Sender: TObject);
    procedure HelpContents(Sender: TObject);
    procedure HelpSearch(Sender: TObject);
    procedure HelpHowToUse(Sender: TObject);
    procedure HelpAbout(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SpeedButton6Click(Sender: TObject);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.DFM}

procedure TMainForm.FileNew(Sender: TObject);
begin
  { Add code to create a new file }
  RTFViewer.DataFilename := 'c:\test.rtf';
end;

procedure TMainForm.FileOpen(Sender: TObject);
begin
  if OpenDialog.Execute then
  begin
    RTFViewer.LoadRTF(OpenDialog.FileName);
  end;
end;

procedure TMainForm.FileSave(Sender: TObject);
begin
   { Add code to save current file under current name }
  SaveDialog.FileName := 'd:\test.rtf'; 
  if SaveDialog.Execute then
  begin
    RTFViewer.SaveRTF(SaveDialog.FileName);
  end;
end;

procedure TMainForm.FileExit(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.EditUndo(Sender: TObject);
begin
  { Add code to perform Edit Undo }
end;

procedure TMainForm.EditCut(Sender: TObject);
begin
  { Add code to perform Edit Cut }
end;

procedure TMainForm.EditCopy(Sender: TObject);
begin
  { Add code to perform Edit Copy }
end;

procedure TMainForm.EditPaste(Sender: TObject);
begin
  { Add code to perform Edit Paste }
end;

procedure TMainForm.WindowTile(Sender: TObject);
begin
  Tile;
end;

procedure TMainForm.WindowCascade(Sender: TObject);
begin
  Cascade;
end;

procedure TMainForm.WindowArrange(Sender: TObject);
begin
  ArrangeIcons;
end;

procedure TMainForm.HelpContents(Sender: TObject);
begin
  Application.HelpCommand(HELP_CONTENTS, 0);
end;

procedure TMainForm.HelpSearch(Sender: TObject);
const
  EmptyString: PChar = '';
begin
  Application.HelpCommand(HELP_PARTIALKEY, Longint(EmptyString));
end;

procedure TMainForm.HelpHowToUse(Sender: TObject);
begin
  Application.HelpCommand(HELP_HELPONHELP, 0);
end;

procedure TMainForm.HelpAbout(Sender: TObject);
begin
  { Add code to show program's About Box }
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
{  RTFViewer.LoadRTF('d:\testb.rtf');}
end;

procedure TMainForm.SpeedButton6Click(Sender: TObject);
begin
  RTFViewer.PreviewOptions := RTFViewer.PreviewOptions - [poDrawLRMargins]; 
end;

end.
