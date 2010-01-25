unit inst_OpenDir_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, FileCtrl;

type
  TOpenDir = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    edPath: TEdit;
    DirectoryListBox1: TDirectoryListBox;
    DriveComboBox1: TDriveComboBox;
    procedure DriveComboBox1Change(Sender: TObject);
    procedure DirectoryListBox1Change(Sender: TObject);
  private
    function GetDirectory: String;
  public
    function Execute(AnDirectory: String): Boolean;
    property Directory: String read GetDirectory;
  end;

var
  OpenDir: TOpenDir;

implementation

{$R *.DFM}

procedure TOpenDir.DriveComboBox1Change(Sender: TObject);
begin
  DirectoryListBox1.Directory := DriveComboBox1.Drive + ':\';
end;

procedure TOpenDir.DirectoryListBox1Change(Sender: TObject);
begin
  edPath.Text := DirectoryListBox1.Directory;
end;

function TOpenDir.Execute(AnDirectory: String): Boolean;
begin
  try
    if Trim(AnDirectory) <> '' then
    begin
      DriveComboBox1.Drive := ExtractFileDrive(AnDirectory)[1];
      DirectoryListBox1.Directory := AnDirectory;
    end;
  except
    edPath.Text := AnDirectory;
  end;
  Result := ShowModal = mrOk;
end;

function TOpenDir.GetDirectory: String;
begin
  Result := edPath.Text;
  if (Length(Result) > 0) and (Result[Length(Result)] <> '\') then
    Result := ExpandFileName(Result) + '\';
end;


end.
