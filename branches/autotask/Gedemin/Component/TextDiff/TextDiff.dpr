program TextDiff;

// -----------------------------------------------------------------------------
// Application:     TextDiff                                                   .
// Version:         4.2                                                        .
// Date:            24-JAN-2004                                                .
// Target:          Win32, Delphi 7                                            .
// Author:          Angus Johnson - angusj-AT-myrealbox-DOT-com                .
// Copyright;       © 2003-2004 Angus Johnson                                  .
// -----------------------------------------------------------------------------

uses
  Forms,
  Main in 'Main.pas' {MainForm},
  HashUnit in 'HashUnit.pas',
  About in 'About.pas' {AboutForm},
  CodeEditor in 'CodeEditor.pas',
  Searches in 'Searches.pas',
  FindReplace in 'FindReplace.pas',
  FileView in 'FileView.pas' {FilesFrame: TFrame},
  FolderView in 'FolderView.pas' {FoldersFrame: TFrame},
  DirWatch in 'DirWatch.pas',
  DiffUnit in 'DiffUnit.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'TextDiff';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
