
unit rp_fr_view_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  FR_View, Menus, StdCtrls, FR_Dock, FR_Ctrls, ExtCtrls, FR_Class, FileCtrl,
  OleServer, Word97, Excel97;

type
  Trp_fr_view = class(TfrPreviewForm)
    WordBtn: TfrTBButton;
    frTBSeparator4: TfrTBSeparator;
    ExcelBtn: TfrTBButton;
    procedure WordBtnClick(Sender: TObject);
    procedure PrintBtnClick(Sender: TObject);
    procedure ExcelBtnClick(Sender: TObject);

  private
    waWord: TWordApplication;

    procedure OnQuitWord(Sender: TObject);
  end;

var
  rp_fr_view: Trp_fr_view;

implementation

uses
  rp_report_const{, Storages, gd_security};

const
  fltClassName = 'TfrRtfAdvExport';//'TfrRTF_rsExport'; 
  fltExcelClassName = 'TfrXMLExcelExport';//'TfrExcelExport';

var
  TempFileList: TStringList;

{$R *.DFM}

procedure Trp_fr_view.OnQuitWord(Sender: TObject);
begin
  while TempFileList.Count > 0 do
  begin
    if FileExists(TempFileList[TempFileList.Count - 1]) then
      DeleteFile(TempFileList[TempFileList.Count - 1]);
    TempFileList.Delete(TempFileList.Count - 1);
  end;
  FreeAndNil(TempFileList);
end;

procedure Trp_fr_view.WordBtnClick(Sender: TObject);
var
  TempPath: array[0..256] of char;
  I: Integer;
  TempFileName: String;
  F: File;
  DocTemplate: OleVariant;
begin

  SetLength(TempFileName, 255);

  GetTempPath(sizeof(TempPath), TempPath);
  GetTempFileName(TempPath, PChar(rpTempPrefix), 0, PChar(TempFileName));

  Self.ConnectBack;
    
  for I := 0 to frFiltersCount - 1 do
    if frFilters[I].Filter.ClassName = fltClassName then
    begin
      TfrReport(Doc).ExportTo(frFilters[I].Filter,
         TempFileName);
      break;
    end;

  Connect(Doc);

  AssignFile(F, TempFileName);
  {$I-}
  Reset(F);
  if FileSize(F) = 0 then
  begin
    CloseFile(F);
    DeleteFile(TempFileName);
    Exit;
  end;

  CloseFile(F);
  {$I+}
  if not Assigned(TempFileList) then
    TempFileList := TStringList.Create;

  TempFileList.Add(TempFileName);

  DocTemplate := TempFileName;
  waWord := TWordApplication.Create(nil);
  try
    try
      waWord.OnQuit := OnQuitWord;

      waWord.Connect;
      waWord.Visible := True;
      waWord.Documents.Open(DocTemplate, EmptyParam,
        EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam,
        EmptyParam);
    except
      raise Exception.Create('Ошибка при открытии Word');
    end;
  finally
    waWord.Free;
  end;
end;

procedure Trp_fr_view.PrintBtnClick(Sender: TObject);
begin
  Enabled := False;
  try
    inherited;
  finally
    Enabled := True;
  end;
end;

procedure Trp_fr_view.ExcelBtnClick(Sender: TObject);
var
  TempPath: array[0..256] of char;
  I: Integer;
  TempFileName: String;
  F: File;
begin

  SetLength(TempFileName, 255);

  GetTempPath(sizeof(TempPath), TempPath);
  GetTempFileName(TempPath, PChar(rpTempPrefix), 0, PChar(TempFileName));

  Self.ConnectBack;

  for I := 0 to frFiltersCount - 1 do
    if frFilters[I].Filter.ClassName = fltExcelClassName then
    begin
      TfrReport(Doc).ExportTo(frFilters[I].Filter,
         TempFileName);
      break;
    end;

  Connect(Doc);

  AssignFile(F, TempFileName);
  {$I-}
  Reset(F);
  if FileSize(F) = 0 then
  begin
    CloseFile(F);
    DeleteFile(TempFileName);
    Exit;
  end;

  CloseFile(F);
  {$I+}
end;

end.
