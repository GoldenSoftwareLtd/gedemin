unit Main;

// -----------------------------------------------------------------------------
// Application:     TextDiff                                                   .
// Module:          Main                                                       .
// Version:         4.2                                                        .
// Date:            24-JAN-2004                                                .
// Target:          Win32, Delphi 7                                            .
// Author:          Angus Johnson - angusj-AT-myrealbox-DOT-com                .
// Copyright;       © 2003-2004 Angus Johnson                                  .
// -----------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DiffUnit, ExtCtrls, Menus, ComCtrls, ShellApi, About,
  IniFiles, ToolWin, ImgList, Clipbrd;

type
  TMainForm = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    mnuOpen1: TMenuItem;
    mnuExit: TMenuItem;
    mnuOptions: TMenuItem;
    mnuIgnoreBlanks: TMenuItem;
    mnuIgnoreCase: TMenuItem;
    mnuCompare: TMenuItem;
    mnuFont: TMenuItem;
    Help1: TMenuItem;
    mnuAbout: TMenuItem;
    mnuOpen2: TMenuItem;
    mnuHorzSplit: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    mnuHighlightColors: TMenuItem;
    Added1: TMenuItem;
    Modified1: TMenuItem;
    Deleted1: TMenuItem;
    ColorDialog1: TColorDialog;
    mnuCancel: TMenuItem;
    mnuActions: TMenuItem;
    N6: TMenuItem;
    Contents1: TMenuItem;
    mnuShowDiffsOnly: TMenuItem;
    StatusBar1: TStatusBar;
    mnuSave1: TMenuItem;
    N8: TMenuItem;
    mnuNext: TMenuItem;
    mnuPrev: TMenuItem;
    mnuSaveReport: TMenuItem;
    N9: TMenuItem;
    N2: TMenuItem;
    N1: TMenuItem;
    mnuCopyBlockRight: TMenuItem;
    mnuCopyBlockLeft: TMenuItem;
    mnuSave2: TMenuItem;
    N3: TMenuItem;
    mnuEdit: TMenuItem;
    mnuUndo: TMenuItem;
    mnuRedo: TMenuItem;
    N7: TMenuItem;
    mnuCut: TMenuItem;
    mnuCopy: TMenuItem;
    mnuPaste: TMenuItem;
    mnuSearch: TMenuItem;
    mnuFind: TMenuItem;
    mnuFindNext: TMenuItem;
    N10: TMenuItem;
    mnuReplace: TMenuItem;
    ToolBar1: TToolBar;
    tbFolder: TToolButton;
    ToolButton5: TToolButton;
    tbOpen1: TToolButton;
    tbOpen2: TToolButton;
    ToolButton3: TToolButton;
    tbSave1: TToolButton;
    tbSave2: TToolButton;
    ToolButton6: TToolButton;
    tbHorzSplit: TToolButton;
    ToolButton8: TToolButton;
    tbCompare: TToolButton;
    tbCancel: TToolButton;
    ToolButton11: TToolButton;
    tbNext: TToolButton;
    tbPrev: TToolButton;
    ToolButton14: TToolButton;
    tbFindNext: TToolButton;
    tbReplace: TToolButton;
    ToolButton2: TToolButton;
    tbHelp: TToolButton;
    ImageList1: TImageList;
    ImageList2: TImageList;
    N11: TMenuItem;
    mnuFolder: TMenuItem;
    mnuCompareFiles: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure mnuExitClick(Sender: TObject);
    procedure mnuIgnoreBlanksClick(Sender: TObject);
    procedure mnuIgnoreCaseClick(Sender: TObject);
    procedure mnuAboutClick(Sender: TObject);
    procedure Added1Click(Sender: TObject);
    procedure Modified1Click(Sender: TObject);
    procedure Deleted1Click(Sender: TObject);
    procedure StatusBar1DrawPanel(StatusBar: TStatusBar;
      Panel: TStatusPanel; const Rect: TRect);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Contents1Click(Sender: TObject);
    procedure mnuShowDiffsOnlyClick(Sender: TObject);
    procedure mnuFolderClick(Sender: TObject);
  private
    procedure LoadOptionsFromIni;
    procedure SaveOptionsToIni;
  public
    FilesFrame: TFrame;
    FoldersFrame: TFrame;
  end;

var
  MainForm: TMainForm;
  addClr, delClr, modClr: TColor;
  LastOpenedFolder1, LastOpenedFolder2: string;
const
  FILEVIEW = 12;
  FOLDERVIEW = 13;
  DESIGN_RESOLUTION = 96;

implementation

uses FileView{, FolderView};

{$R *.DFM}

//---------------------------------------------------------------------
//---------------------------------------------------------------------

procedure TMainForm.FormCreate(Sender: TObject);
begin

  FilesFrame := TFilesFrame.Create(self);
  FilesFrame.Parent := self;
  FilesFrame.Align := alClient;
  FilesFrame.ScaleBy(Screen.PixelsPerInch, DESIGN_RESOLUTION);

  {FoldersFrame := TFoldersFrame.Create(self);
  FoldersFrame.Parent := self;
  FoldersFrame.Align := alClient;
  FoldersFrame.ScaleBy(Screen.PixelsPerInch, DESIGN_RESOLUTION);}


  //load ini settings before calling FileFrame.Setup ...
  LoadOptionsFromIni;
  TFilesFrame(FilesFrame).Setup;
  //TFoldersFrame(FoldersFrame).Setup;

  Statusbar1.Panels[2].Text := #150;

  application.helpfile := changefileext(ParamStr(0), '.hlp');
  if {FoldersFrame.Visible}False then mnuFolderClick(nil)
  else TFilesFrame(FilesFrame).SetMenuEventsToFileView;
end;
//---------------------------------------------------------------------

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  TFilesFrame(FilesFrame).Cleanup;
  //TFoldersFrame(FoldersFrame).Cleanup;
end;
//---------------------------------------------------------------------

procedure TMainForm.mnuExitClick(Sender: TObject);
begin
  close;
end;
//---------------------------------------------------------------------

procedure TMainForm.LoadOptionsFromIni;
var
  l,t,w,h: integer;
begin
  with TIniFile.create(changefileext(paramstr(0),'.ini')) do
  try
    l := ReadInteger('Options','Bounds.Left', 0);
    t := ReadInteger('Options','Bounds.Top', 0);
    w := ReadInteger('Options','Bounds.Width', -1);
    h := ReadInteger('Options','Bounds.Height', -1);
    //set (Add, Del, Mod) colors...
    addClr := strtointdef(ReadString('Options','AddColor', ''),$F0CCA8);
    modClr := strtointdef(ReadString('Options','ModColor', ''),$6FFB8A);
    delClr := strtointdef(ReadString('Options','DelColor', ''),$BB77FF);

    with TFilesFrame(FilesFrame).FontDialog1.Font do
    begin
      Name := ReadString('Options','Font.Name', 'Courier New');
      Size := ReadInteger('Options','Font.size', 10);
    end;

    if ReadBool('Options','Horizontal',false) then mnuHorzSplit.Checked := true;

    LastOpenedFolder1 := ReadString('Options','Folder.1', '');
    LastOpenedFolder2 := ReadString('Options','Folder.2', '');
    FoldersFrame.Visible := ReadBool('Options','FolderView', false);
  finally
    free;
  end;
  //make sure the form is positioned on screen ...
  //ie: make sure nobody's done something silly with the INI file!
  if (w > 0) and (h > 0) and (l < screen.Width) and (t < screen.Height) and
      (l+w > 0) and (t+h > 0) then
    setbounds(l,t,w,h) else
    Position := poScreenCenter;
end;
//---------------------------------------------------------------------

procedure TMainForm.SaveOptionsToIni;
begin
  with TIniFile.create(changefileext(paramstr(0),'.ini')) do
  try
    if windowState = wsNormal then
    begin
      WriteInteger('Options','Bounds.Left', self.Left);
      WriteInteger('Options','Bounds.Top', self.Top);
      WriteInteger('Options','Bounds.Width', self.Width);
      WriteInteger('Options','Bounds.Height', self.Height);
    end;
    WriteString('Options','AddColor', '$'+inttohex(addClr,8));
    WriteString('Options','ModColor', '$'+inttohex(modClr,8));
    WriteString('Options','DelColor', '$'+inttohex(delClr,8));
    with TFilesFrame(FilesFrame).FontDialog1.Font do
    begin
      WriteString('Options','Font.Name', name);
      WriteInteger('Options','Font.size', Size);
    end;
    WriteBool('Options','Horizontal', mnuHorzSplit.Checked);
    WriteString('Options','Folder.1', LastOpenedFolder1);
    WriteString('Options','Folder.2', LastOpenedFolder2);
    WriteBool('Options','FolderView', FoldersFrame.Visible);
  finally
    free;
  end;
end;
//---------------------------------------------------------------------

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveOptionsToIni;
  Application.HelpCommand(HELP_QUIT, 0);
end;
//---------------------------------------------------------------------

procedure TMainForm.Contents1Click(Sender: TObject);
begin
  Application.HelpCommand(HELP_CONTENTS, 0);
end;
//---------------------------------------------------------------------

procedure TMainForm.mnuIgnoreBlanksClick(Sender: TObject);
begin
  mnuIgnoreBlanks.checked := not mnuIgnoreBlanks.checked;
end;
//---------------------------------------------------------------------

procedure TMainForm.mnuIgnoreCaseClick(Sender: TObject);
begin
  mnuIgnoreCase.checked := not mnuIgnoreCase.checked;
end;
//---------------------------------------------------------------------

procedure TMainForm.mnuShowDiffsOnlyClick(Sender: TObject);
begin
  mnuShowDiffsOnly.checked := not mnuShowDiffsOnly.checked;
  //if files have already been compared then refresh the changes
  with TFilesFrame(FilesFrame) do
    if FilesCompared then DisplayDiffs;
end;
//---------------------------------------------------------------------

procedure TMainForm.mnuAboutClick(Sender: TObject);
begin
  with TAboutForm.create(self) do
  try
    showmodal;
  finally
    free;
  end;
end;
//---------------------------------------------------------------------

procedure TMainForm.Added1Click(Sender: TObject);
begin
  with ColorDialog1 do
  begin
    color := addClr;
    if not execute then exit;
    addClr := color;
  end;
  StatusBar1.Repaint;
end;
//---------------------------------------------------------------------

procedure TMainForm.Modified1Click(Sender: TObject);
begin
  with ColorDialog1 do
  begin
    color := modClr;
    if not execute then exit;
    modClr := color;
  end;
  StatusBar1.Repaint;
end;
//---------------------------------------------------------------------

procedure TMainForm.Deleted1Click(Sender: TObject);
begin
  with ColorDialog1 do
  begin
    color := delClr;
    if not execute then exit;
    delClr := color;
  end;
  StatusBar1.Repaint;
end;
//---------------------------------------------------------------------

procedure TMainForm.StatusBar1DrawPanel(StatusBar: TStatusBar;
  Panel: TStatusPanel; const Rect: TRect);
begin
  case Panel.Index of
    0: StatusBar1.Canvas.Brush.Color := addClr;
    1: StatusBar1.Canvas.Brush.Color := modClr;
    2: StatusBar1.Canvas.Brush.Color := delClr;
  else exit;
  end;
  StatusBar1.Canvas.FillRect(Rect);
  StatusBar1.Canvas.TextOut(Rect.Left+4,Rect.Top,Panel.Text);
end;
//---------------------------------------------------------------------

procedure TMainForm.mnuFolderClick(Sender: TObject);
begin
  //toggle file view vs folder view ...
  mnuFolder.Checked := not mnuFolder.Checked;

  TFilesFrame(FilesFrame).Visible := true;
  TFilesFrame(FilesFrame).SetMenuEventsToFileView;
end;
//------------------------------------------------------------------------------

end.
