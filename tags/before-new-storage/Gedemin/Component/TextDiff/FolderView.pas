unit FolderView;

// -----------------------------------------------------------------------------
// Application:     TextDiff                                                   .
// Module:          FolderView                                                 .
// Version:         4.1                                                        .
// Date:            16-JAN-2004                                                .
// Target:          Win32, Delphi 7                                            .
// Author:          Angus Johnson - angusj-AT-myrealbox-DOT-com                .
// Copyright;       © 2003-2004 Angus Johnson                                  .
// -----------------------------------------------------------------------------

{$IFNDEF VER130}
  {$WARN SYMBOL_PLATFORM OFF}
{$ENDIF}  

interface

uses
  Windows, Messages, SysUtils, {$IFNDEF VER130}Variants,{$ENDIF} Classes, Graphics, Controls, Forms,
  Dialogs, Grids, ExtCtrls, Main, ShellApi, ShlObj, DirWatch;

type
  TFolderDiff = (fdNone, fdAdded, fdDeleted, fdModified);

  PFolderRec = ^TFolderRec;
  TFolderRec = record
    Name: string;
    IsDirectory: boolean;
    Size: cardinal;
    Modified: TDatetime;
    Difference: TFolderDiff;
  end;

  TFoldersFrame = class(TFrame)
    pnlMain: TPanel;
    Splitter1: TSplitter;
    pnlLeft: TPanel;
    pnlCaptionLeft: TPanel;
    sgFolder1: TStringGrid;
    pnlRight: TPanel;
    pnlCaptionRight: TPanel;
    sgFolder2: TStringGrid;
    procedure sgFolder1DrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure sgFolder1TopLeftChanged(Sender: TObject);
    procedure sgFolder1Click(Sender: TObject);
    procedure FrameResize(Sender: TObject);
    procedure sgFolder1DblClick(Sender: TObject);
  private
    fDiffResultStr: string;
    fFoldersCompared: boolean;
    fFolderBmp: TBitmap;
    fBulletBmp:  TBitmap;
    fFolder1StringList: TStringList;
    fFolder2StringList: TStringList;
    fDirectoryWatch1: TDirectoryWatch;
    fDirectoryWatch2: TDirectoryWatch;
    procedure LoadFolderList(const Path: string; IsFolder1: boolean);
    procedure DisplayFolderList(IsFolder1: boolean);
    procedure ClearFolderSL(folderSL: TStringList);
    procedure DiffFolders;

    procedure OpenClick(Sender: TObject);
    procedure CompareClick(Sender: TObject);
    procedure DirectoryWatchOnChange(Sender: TObject);
  public
    procedure Setup;
    procedure Cleanup;
    procedure SetMenuEventsToFolderView;
    procedure DoOpenFolder(const Foldername: string; IsFolder1: boolean);
  end;

implementation

uses FileView;

{$R *.dfm}
{$R folder.res}

//------------------------------------------------------------------------------
// Miscellaneous functions ...
//------------------------------------------------------------------------------

function MakeLighter(Color: TColor): TColor;
var
  r,g,b: byte;
begin
  Color := ColorToRGB(Color);
  b := (Color and $FF0000) shr 16;
  g := (Color and $FF00) shr 8;
  r := (Color and $FF);
  b := 255 - ((255 - b) * 1 div 2);
  g := 255 - ((255 - g) * 1 div 2);
  r := 255 - ((255 - r) * 1 div 2);
  result := (b shl 16) or (g shl 8) or r;
end;
//------------------------------------------------------------------------------

function max(int1, int2: integer): integer;
begin
  if int1 > int2 then result := int1 else result := int2;
end;
//------------------------------------------------------------------------------

function FileTime2DateTime(FileTime: TFileTime): TDateTime;
var
  LocalFileTime: TFileTime;
  SystemTime: TSystemTime;
begin
  FileTimeToLocalFileTime(FileTime, LocalFileTime);
  FileTimeToSystemTime(LocalFileTime, SystemTime);
  Result := SystemTimeToDateTime(SystemTime);
end;
//------------------------------------------------------------------------------

//BrowseProc() is used by GetFolder() to set the initial folder and display
//the path for the currently selected folder.
function BrowseProc(hwnd: HWnd; uMsg: integer; lParam, lpData: LPARAM): integer; stdcall;
var
  sfi: TSHFileInfo;
begin
  case uMsg of
    BFFM_INITIALIZED:
      begin
        SendMessage(hwnd, BFFM_SETSTATUSTEXT,0, lpData);
        SendMessage(hwnd, BFFM_SETSELECTION, 1, lpData);
      end;
    BFFM_SELCHANGED:
      begin
        ShGetFileInfo(PChar(lParam), 0, sfi,sizeof(sfi),SHGFI_DISPLAYNAME or SHGFI_PIDL);
        SendMessage(hwnd, BFFM_SETSTATUSTEXT,0, integer(@sfi.szDisplayName));
      end;
  end;
  result := 0;
end;
//------------------------------------------------------------------------------

procedure CoTaskMemFree(pv: Pointer); stdcall; external 'ole32.dll' name 'CoTaskMemFree';

//------------------------------------------------------------------------------

function StripSlash(const path: string): string;
var
  len: integer;
begin
  result := path;
  len := length(path);
  if (len = 0) or (path[len] <> '\') then exit;
  setlength(result,len-1);
end;
//------------------------------------------------------------------------------

function AppendSlash(const path: string): string;
var
  len: integer;
begin
  len := length(path);
  if (len = 0) or (path[len] = '\') then
    result := path else
    result := path+'\';
end;
//------------------------------------------------------------------------------

function GetFolder(OwnerForm: TForm;
  const Caption: string; var Folder: string): boolean;
var
  displayname: array[0..MAX_PATH] of char;
  bi: TBrowseInfo;
  pidl: PItemIdList;
begin
  bi.hWndOwner := OwnerForm.Handle;
  bi.pIDLRoot := nil;
  bi.pszDisplayName := pchar(@displayname[0]);
  bi.lpszTitle := pchar(Caption);
  bi.ulFlags := BIF_RETURNONLYFSDIRS or BIF_STATUSTEXT;
  bi.lpfn := @BrowseProc;
  if Folder <> '' then Folder := StripSlash(Folder);
  bi.lParam := integer(pchar(Folder));
  bi.iImage := 0;
  pidl := SHBrowseForFolder(bi);
  result := pidl <> nil;
  if result then
  try
    result := SHGetPathFromIDList(pidl,pchar(@displayname[0]));
    Folder := displayname;
  finally
    CoTaskMemFree(pidl);
  end;
end;

//------------------------------------------------------------------------------
// TFoldersFrame methods
//------------------------------------------------------------------------------

procedure TFoldersFrame.Setup;
begin
  fFolderBmp := TBitmap.create;
  fFolderBmp.LoadFromResourceName(hInstance,'FOLDER');
  fFolderBmp.Transparent := true;

  fBulletBmp := TBitmap.create;
  fBulletBmp.LoadFromResourceName(hInstance,'BULLET');
  fBulletBmp.Transparent := true;

  fDirectoryWatch1 := TDirectoryWatch.Create(MainForm);
  fDirectoryWatch1.OnChange := DirectoryWatchOnChange;
  fDirectoryWatch2 := TDirectoryWatch.Create(MainForm);
  fDirectoryWatch2.OnChange := DirectoryWatchOnChange;

  fFolder1StringList := TStringList.create;
  fFolder2StringList := TStringList.create;
  with sgFolder1 do
  begin
    cells[0,0] := 'Name';
    cells[1,0] := 'Size';
    cells[2,0] := 'Modified';
  end;
  with sgFolder2 do
  begin
    cells[0,0] := 'Name';
    cells[1,0] := 'Size';
    cells[2,0] := 'Modified';
  end;

  sgFolder1.ColWidths[1] :=
    MainForm.Canvas.TextWidth(format('    %1.0n KB',[1024 * 99000/1]));
  sgFolder2.ColWidths[1] := sgFolder1.ColWidths[1];

  sgFolder1.ColWidths[2] :=
    MainForm.Canvas.TextWidth(formatDatetime(shortDateFormat +
      '        '+ ShortTimeFormat, 0));
  sgFolder2.ColWidths[2] := sgFolder1.ColWidths[2];

end;
//------------------------------------------------------------------------------

procedure TFoldersFrame.Cleanup;
begin
  fFolderBmp.free;
  fBulletBmp.free;
  ClearFolderSL(fFolder1StringList);
  ClearFolderSL(fFolder2StringList);
  fFolder1StringList.Free;
  fFolder2StringList.Free;
  fDirectoryWatch1.Free;
  fDirectoryWatch2.Free;
end;
//------------------------------------------------------------------------------

procedure TFoldersFrame.SetMenuEventsToFolderView;
begin
  with MainForm do
  begin
    tbFolder.ImageIndex := Main.FOLDERVIEW;
    tbFolder.Hint := 'Toggle to File View';
    tbOpen1.Hint := 'Open Folder 1';
    tbOpen2.Hint := 'Open Folder 2';
    mnuOpen1.OnClick := OpenClick;
    mnuOpen2.OnClick := OpenClick;
    tbOpen1.OnClick := OpenClick;
    tbOpen2.OnClick := OpenClick;
    mnuOpen1.Caption := 'Op&en Folder 1';
    mnuOpen2.Caption := 'Ope&n Folder 2';
    tbOpen1.Hint := 'Open Folder 1';
    tbOpen2.Hint := 'Open Folder 2';

    mnuSave1.Enabled := false;
    mnuSave2.Enabled := false;
    tbSave1.Enabled := false;
    tbSave2.Enabled := false;

    mnucompare.OnClick := CompareClick;
    mnuCompare.enabled := not fFoldersCompared and
      (fFolder1StringList.Count > 0) and (fFolder2StringList.Count > 0);
    tbCompare.OnClick := CompareClick;
    tbCompare.enabled := mnuCompare.enabled;

    mnuEdit.Enabled := false;
    mnuSearch.Enabled := false;
    mnuOptions.Enabled := false;

    tbHorzSplit.enabled := false;
    tbFindNext.Enabled := false;
    tbReplace.Enabled := false;

    mnuCopyBlockLeft.Visible := false;
    mnuCopyBlockRight.Visible := false;
    N1.Visible := false;
    mnuCompareFiles.Visible := true;
    mnuCompareFiles.OnClick := sgFolder1DblClick;
    mnuNext.visible := false;
    mnuPrev.visible := false;
    tbNext.Enabled := false;
    tbPrev.Enabled := false;

    mnuSaveReport.Enabled := false;

    application.OnActivate := nil;
    if fFoldersCompared then
      Statusbar1.Panels[3].text := fDiffResultStr else
      Statusbar1.Panels[3].text := '';
    ActiveControl := sgFolder1;
  end;
end;
//------------------------------------------------------------------------------

procedure TFoldersFrame.OpenClick(Sender: TObject);
var
  IsFolder1: boolean;
begin
  with MainForm do
    IsFolder1 := (Sender = mnuOpen1) or (Sender = tbOpen1);
  if IsFolder1 then
  begin
    if not GetFolder(MainForm,'Open Folder 1',LastOpenedFolder1) then exit;
    DoOpenFolder(LastOpenedFolder1, true)
  end else
  begin
    if not GetFolder(MainForm,'Open Folder 2',LastOpenedFolder2) then exit;
    DoOpenFolder(LastOpenedFolder2, false);
  end;
end;
//---------------------------------------------------------------------

procedure TFoldersFrame.DoOpenFolder(const Foldername: string; IsFolder1: boolean);
begin
  if IsFolder1 then
  begin
    LastOpenedFolder1 := Foldername;
    fDirectoryWatch1.Directory := Foldername;
    fDirectoryWatch1.Active := true;
  end else
  begin
    LastOpenedFolder2 := Foldername;
    fDirectoryWatch2.Directory := Foldername;
    fDirectoryWatch2.Active := true;
  end;
  LoadFolderList(Foldername, IsFolder1);

  MainForm.Statusbar1.Panels[3].text := '';
  if not fFoldersCompared then exit;
  //reload the other folder too otherwise comparing will be broken
  //nb: LastOpenedFolders may have been changed in filesview so ...
  if IsFolder1 then
    LoadFolderList(trim(pnlCaptionRight.Caption), false) else
    LoadFolderList(trim(pnlCaptionLeft.Caption), true);
  fFoldersCompared := false;
end;
//---------------------------------------------------------------------

procedure TFoldersFrame.DirectoryWatchOnChange(Sender: TObject);
begin
  //a file or folder has been added, deleted or modified in
  //one of the directories so reload the directory list ...
  if Sender = fDirectoryWatch1 then
    DoOpenFolder(LastOpenedFolder1, true) else
    DoOpenFolder(LastOpenedFolder2, false);
end;
//---------------------------------------------------------------------

procedure TFoldersFrame.sgFolder1DrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  idx, textLen: integer;
  FolderStringList: TStringList;
  sgFolder: TStringGrid;
begin
  if Sender = sgFolder1 then
  begin
    FolderStringList := fFolder1StringList;
    sgFolder := sgFolder1;
  end else
  begin
    FolderStringList := fFolder2StringList;
    sgFolder := sgFolder2;
  end;

  idx := ARow -1;
  with sgFolder, Canvas do
  begin

    if (ARow > 0) and (FolderStringList.Count = 0) then
    begin
      brush.Color := color;
      FillRect(Rect);
      exit;
    end;

    if gdFixed in State then brush.Color := clBtnFace
    else if (FolderStringList.Count = 0) then brush.Color := color
    else
    case PFolderRec(FolderStringList.objects[idx]).Difference of
      fdNone: brush.Color := color;
      fdAdded: brush.Color := AddClr;
      fdDeleted: brush.Color := DelClr;
      fdModified: brush.Color := ModClr;
    end;

    if gdSelected in State then
      brush.Color := MakeLighter(brush.Color);

    if ACol = 0 then
    begin
      textRect(Rect, Rect.Left+24, Rect.Top+2, Cells[ACol,ARow]);
      if (idx < FolderStringList.Count) and not (gdFixed in State) then
      begin
        with PFolderRec(FolderStringList.objects[idx])^ do
          if Name = '' then {draw no image}
          else if IsDirectory then Draw(Rect.Left + 4, Rect.Top +2, fFolderBmp)
          else Draw(Rect.Left + 4, Rect.Top +2, fBulletBmp);
      end;

    end
    else if ACol < 3 then
    begin
      //right align ...
      textLen := TextExtent(Cells[ACol,ARow]).cx;
      textRect(Rect, Rect.Right - textLen -4,Rect.Top+2, Cells[ACol,ARow])
    end else
      textRect(Rect, Rect.Left+4, Rect.Top+2, Cells[ACol,ARow]);

    if (gdFixed in State) then
    begin
      pen.Color := clBtnHighlight;
      moveto(rect.Left,rect.Bottom-1);
      LineTo(rect.Left,rect.Top);
      LineTo(rect.Right-1,rect.Top);
      pen.Color := clBtnShadow;
      LineTo(rect.Right-1,rect.Bottom-1);
      LineTo(rect.Left,rect.Bottom-1);
    end
    else if (gdSelected in State) then
    begin
      pen.Color := clBtnShadow;
      if ACol = 0 then
      begin
        MoveTo(rect.Left,rect.Bottom-1);
        LineTo(rect.Left,rect.Top);
      end else
        MoveTo(rect.Left,rect.Top);
      LineTo(rect.Right,rect.Top);

      if ACol = 2 then
      begin
        MoveTo(rect.Right-1,rect.Top);
        LineTo(rect.Right-1,rect.Bottom-1);
      end else
        MoveTo(rect.Right,rect.Bottom-1);
      LineTo(rect.Left-1,rect.Bottom-1);
    end;
  end;
end;
//------------------------------------------------------------------------------

procedure TFoldersFrame.LoadFolderList(const Path: string; IsFolder1: boolean);
var
  res: integer;
  FolderStringList: TStringList;
  FolderRec: PFolderRec;
  sr: TSearchRec;
begin
  if not DirectoryExists(Path) then exit;
  if IsFolder1 then
    FolderStringList := fFolder1StringList else
    FolderStringList := fFolder2StringList;
  ClearFolderSL(FolderStringList);

  res := sysUtils.FindFirst(appendSlash(Path)+'*.*',faAnyFile, sr);
  while res = 0 do
  begin
    if (sr.Name[1] <> '.') or //speeds this up a bit ....
      ((sr.Name <> '.') and (sr.Name <> '..')) then
    begin
      New(FolderRec);
      FolderRec.IsDirectory := (sr.Attr and faDirectory = faDirectory);
      if FolderRec.IsDirectory then
        FolderStringList.AddObject('D'+uppercase(sr.Name),pointer(FolderRec))
      else
        FolderStringList.AddObject('F'+uppercase(sr.Name),pointer(FolderRec));
      FolderRec.Name := sr.Name;
      FolderRec.Size := sr.Size;
      FolderRec.Modified := FileTime2DateTime(sr.FindData.ftLastWriteTime);
      FolderRec.Difference := fdNone;
    end;
    res := sysUtils.FindNext(sr);
  end;
  FolderStringList.Sort;

  DisplayFolderList(IsFolder1);
  if IsFolder1 then
    pnlCaptionLeft.Caption := '  ' + Path else
    pnlCaptionRight.Caption := '  ' + Path;

  with MainForm do
  begin
    mnuCompare.enabled :=
    (fFolder1StringList.Count > 0) and (fFolder2StringList.Count > 0);
    tbCompare.enabled := mnuCompare.enabled;
    mnuCompareFiles.Enabled := false;
  end;
end;
//------------------------------------------------------------------------------

procedure TFoldersFrame.DisplayFolderList(IsFolder1: boolean);
var
  i,j: integer;
  FolderStringList: TStringList;
  sgFolder: TStringgrid;
begin
  if IsFolder1 then
  begin
    FolderStringList := fFolder1StringList;
    sgFolder := sgFolder1;
  end else
  begin
    FolderStringList := fFolder2StringList;
    sgFolder := sgFolder2;
  end;

  if FolderStringList.count = 0 then
    sgFolder.RowCount := 2 else
    sgFolder.RowCount := FolderStringList.count +1;
  for i := 0 to FolderStringList.Count -1 do
    with PFolderRec(FolderStringList.objects[i])^ do
  begin
    sgFolder.Cells[0,i+1] := Name;
    for j := 1 to 2 do sgFolder.Cells[j,i+1] := '';
    if (Name <> '') and not IsDirectory then
    begin
      sgFolder.Cells[1,i+1] := format('%1.0n KB',[(Size + 512)/1024]);
      sgFolder.Cells[2,i+1] :=
          formatDatetime(shortDateFormat + '  '+ ShortTimeFormat, Modified);
    end;
  end;
end;
//------------------------------------------------------------------------------

procedure TFoldersFrame.ClearFolderSL(folderSL: TStringList);
var
  i: integer;
begin
  for i := 0 to folderSL.count -1 do
    if assigned(folderSL.objects[i]) then
      Dispose(PFolderRec(folderSL.objects[i]));
  folderSL.clear;
end;
//------------------------------------------------------------------------------

procedure TFoldersFrame.CompareClick(Sender: TObject);
begin
    DiffFolders;
    DisplayFolderList(true);
    DisplayFolderList(false);
    fFoldersCompared := true;
    Mainform.mnuCompare.Enabled := false;
    Mainform.tbCompare.Enabled := false;
    //match up selections ready to keep them in sync ...
    sgFolder2.Selection := sgFolder1.Selection;
end;
//------------------------------------------------------------------------------

procedure TFoldersFrame.DiffFolders;
var
  FolderRec, FolderRec1, FolderRec2: PFolderRec;
  i, j, compResult, ADCnt, DDCnt, AFCnt, MFCnt, DFCnt: integer;

  //---------------------------------------------------------

  procedure Added;
  begin
    new(FolderRec);
    fFolder1StringList.InsertObject(i, '', pointer(FolderRec));
    FolderRec.Name := '';
    FolderRec.IsDirectory := (fFolder2StringList[j][1] = 'D');
    FolderRec.Size := 0;
    FolderRec.Modified := 0;
    FolderRec.Difference := fdAdded;
    PFolderRec(fFolder2StringList.objects[j]).Difference := fdAdded;
    if FolderRec.IsDirectory then inc(ADCnt) else inc(AFCnt);
  end;
  //---------------------------------------------------------

  procedure Modified;
  begin
    FolderRec1.Difference := fdModified;
    FolderRec2.Difference := fdModified;
    inc(MFCnt);
  end;
  //---------------------------------------------------------

  procedure Deleted;
  begin
    new(FolderRec);
    fFolder2StringList.InsertObject(j, '', pointer(FolderRec));
    FolderRec.Name := '';
    FolderRec.IsDirectory := (fFolder1StringList[i][1] = 'D');
    FolderRec.Size := 0;
    FolderRec.Modified := 0;
    FolderRec.Difference := fdDeleted;
    PFolderRec(fFolder1StringList.objects[i]).Difference := fdDeleted;
    if FolderRec.IsDirectory then inc(DDCnt) else inc(DFCnt);
  end;
  //---------------------------------------------------------

begin
  ADCnt := 0; DDCnt := 0;
  AFCnt := 0; MFCnt := 0; DFCnt := 0;
  i := 0; j := 0;
  while (i <fFolder1StringList.count) and (j <fFolder2StringList.count) do
  begin
    compResult :=
      AnsiCompareText(fFolder1StringList[i], fFolder2StringList[j]);
    if compResult < 0 then Deleted
    else if compResult > 0 then Added
    else
    begin
      FolderRec1 := PFolderRec(fFolder1StringList.objects[i]);
      FolderRec2 := PFolderRec(fFolder2StringList.objects[j]);
      if not FolderRec1.IsDirectory and
        ((FolderRec1.Size <> FolderRec2.Size) or
        (FolderRec1.Modified <> FolderRec2.Modified)) then Modified;
    end;
    inc(i);
    inc(j);
  end;
  while (i <fFolder1StringList.count) do begin Deleted; inc(i); inc(j); end;
  while (i <fFolder2StringList.count) do begin Added; inc(i); inc(j); end;

  fDiffResultStr := '  ';
  if ADCnt > 0 then
    fDiffResultStr := fDiffResultStr + format('%d directories added, ',[ADCnt]);
  if DDCnt > 0 then
    fDiffResultStr := fDiffResultStr + format('%d directories deleted, ',[DDCnt]);
  if AFCnt > 0 then
    fDiffResultStr := fDiffResultStr + format('%d files added, ',[AFCnt]);
  if MFCnt > 0 then
    fDiffResultStr := fDiffResultStr + format('%d files modified, ',[MFCnt]);
  if DFCnt > 0 then
    fDiffResultStr := fDiffResultStr + format('%d files deleted, ',[DFCnt]);
  i := length(fDiffResultStr);
  if i > 2 then setlength(fDiffResultStr,i-2) else
  fDiffResultStr := '  No differences found.';
  MainForm.Statusbar1.Panels[3].text := fDiffResultStr;
end;
//------------------------------------------------------------------------------

procedure TFoldersFrame.sgFolder1TopLeftChanged(Sender: TObject);
begin
  if not fFoldersCompared then exit;
  if Sender = sgFolder1 then
    sgFolder2.TopRow := sgFolder1.TopRow else
    sgFolder1.TopRow := sgFolder2.TopRow;
end;
//------------------------------------------------------------------------------

procedure TFoldersFrame.sgFolder1Click(Sender: TObject);
var
  i: integer;
begin
  if not TStringGrid(Sender).focused or not fFoldersCompared then exit;
  if Sender = sgFolder1 then
    sgFolder2.Selection := sgFolder1.Selection else
    sgFolder1.Selection := sgFolder2.Selection;
  i := sgFolder1.Selection.Top -1;
  MainForm.mnuCompareFiles.Enabled :=
    assigned(fFolder1StringList.objects[i]) and
    (PFolderRec(fFolder1StringList.objects[i]).Difference = fdModified);
end;
//------------------------------------------------------------------------------

procedure TFoldersFrame.FrameResize(Sender: TObject);
begin
  pnlLeft.width := pnlMain.ClientWidth div 2 -1;

  sgFolder2.ColWidths[0] :=
    sgFolder2.ClientWidth - sgFolder2.ColWidths[1] - sgFolder2.ColWidths[2];
  sgFolder1.ColWidths[0] := sgFolder2.ColWidths[0];
end;
//------------------------------------------------------------------------------

procedure TFoldersFrame.sgFolder1DblClick(Sender: TObject);
var
  i: integer;
begin
  if not fFoldersCompared then exit;
  i := sgFolder1.Selection.Top -1;
  if assigned(fFolder1StringList.objects[i]) and
    (PFolderRec(fFolder1StringList.objects[i]).Difference = fdModified) then
    begin
      //toggle to fileview ...
      MainForm.mnuFolderClick(nil);
      //check for overwriting of opened files ...
      with TFilesFrame(MainForm.FilesFrame) do
      begin
        if (pnlCaptionLeft.Color = ISMODIFIED_COLOR) then
        begin
          case application.MessageBox(pchar('Save changes to'#10 +
            pnlCaptionLeft.Caption+' ?  '),pchar(application.title),
              MB_YESNOCANCEL or MB_ICONSTOP or MB_DEFBUTTON3) of
            IDCANCEL: exit;
            IDYES: SaveFileClick(MainForm.mnuSave1);
          end;
        end;
        if (pnlCaptionRight.Color = ISMODIFIED_COLOR) then
        begin
          case application.MessageBox(pchar('Save changes to'#10 +
            pnlCaptionRight.Caption+' ?  '),pchar(application.title),
              MB_YESNOCANCEL or MB_ICONSTOP or MB_DEFBUTTON3) of
            IDCANCEL: exit;
            IDYES: SaveFileClick(MainForm.mnuSave2);
          end;
        end;
        //proceed to opening and comparing files ...
        DoOpenFile(appendSlash(LastOpenedFolder2)+
          PFolderRec(fFolder2StringList.objects[i]).Name, false);
        DoOpenFile(appendSlash(LastOpenedFolder1)+
          PFolderRec(fFolder1StringList.objects[i]).Name, true);
      end;
      MainForm.mnuCompare.Click;
    end;
end;
//------------------------------------------------------------------------------

end.
