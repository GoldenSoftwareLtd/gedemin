unit replace_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    chbxSubFolders: TCheckBox;
    edFile: TEdit;
    edWhat: TEdit;
    edFor: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Button2: TButton;
    Label4: TLabel;
    edBefore: TEdit;
    Label5: TLabel;
    edNotBefore: TEdit;
    Label6: TLabel;
    edNotBefore2: TEdit;
    edLinesBefore: TEdit;
    edNotInLinesBefore: TEdit;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    edExcludeFiles: TEdit;
    Label10: TLabel;
    Label11: TLabel;
    edNotAfter: TEdit;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

uses
  jclFileUtils, jclStrings;

procedure TForm1.Button1Click(Sender: TObject);
var
  LFile, LSource, LExcludeFile: TStringList;
  I, P, K, WasError, Processed, Removed, LinesBefore: Integer;
  FLOpt: TFileListOptions;
  S, BackupFileName: String;
begin
  LFile := TStringList.Create;
  LExcludeFile := TStringList.Create;
  LSource := TStringList.Create;
  try
    if chbxSubFolders.Checked then
      FLOpt := [flFullNames, flRecursive]
    else
      FLOpt := [flFullNames];

    if not AdvBuildFileList(edFile.Text, faAnyFile, LFile, amAny, FLOpt, '*.*', nil) then
    begin
      MessageBox(Handle,
        'Invalid path specified. Can not process.',
        'Warning',
        MB_OK or MB_ICONEXCLAMATION);
      exit;
    end;

    if edExcludeFiles.Text > '' then
      AdvBuildFileList(edExcludeFiles.Text, faAnyFile, LExcludeFile, amAny, FLOpt,
        '*.*', nil);

    Processed := 0;
    WasError := 0;

    for I := 0 to LFile.Count - 1 do
    begin
      if StrIPos(LFile[I], LExcludeFile.Text) > 0 then
        continue;

      LSource.LoadFromFile(LFile[I]);
      Removed := 0;
      LinesBefore := -1000000;

      for K := 0 to LSource.Count - 1 do
      begin
        if edNotInLinesBefore.Text > '' then
          if (StrIPos(edNotInLinesBefore.Text, LSource[K]) > 0) then LinesBefore := K;

        while StrIPos(edWhat.Text, LSource[K]) > 0 do
        begin
          S := LSource[K];
          P := StrIPos(edWhat.Text, S);

          if edBefore.Text > '' then
            if (StrIPos(edBefore.Text, S) = 0) or (StrIPos(edBefore.Text, S) >= P) then
              break;

          if edNotBefore.Text > '' then
            if (StrIPos(edNotBefore.Text , S) > 0) and (StrIPos(edNotBefore.Text, S) < P) then
              break;

          if edNotBefore2.Text > '' then
            if (StrIPos(edNotBefore2.Text , S) > 0) and (StrIPos(edNotBefore2.Text, S) < P) then
              break;

          if edNotAfter.Text > '' then
            if (StrIPos(edNotAfter.Text, Copy(S, P + Length(edWhat.Text), 2048)) > 0) then
                break;

          if edLinesBefore.Text > '' then
            if StrToIntDef(edLinesBefore.Text, -1) >= (K - LinesBefore) then break;

          Delete(S, P, Length(edWhat.Text));
          Insert(edFor.Text, S, P);
          LSource[K] := S;
          Inc(Removed);

          if StrIPos(edWhat.Text, edFor.Text) > 0 then
            break;
        end;
      end;

      if Removed > 0 then
      begin
        BackupFileName := ChangeFileExt(LFile[I], '.BAK');

        if FileExists(BackupFileName) then
          DeleteFile(BackupFileName);

        if RenameFile(LFile[I], BackupFileName) then
        begin
          LSource.SaveToFile(LFile[I]);
          Processed := Processed + 1;
        end else
        begin
          MessageBox(Handle,
            PChar('Can not create back up copy for file: ' + LFile[I] + #13#10'File is not processed.'),
            'Warning',
            MB_OK or MB_ICONEXCLAMATION);
          WasError := WasError + 1;
        end;
      end;
    end;

    MessageBox(Handle,
      PChar(Format('Total files found: %d'#13#10'Strings were replaced in: %d'#13#10'Error files: %d',
        [LFile.Count, Processed, WasError])),
      'Statistics',
      MB_OK or MB_ICONINFORMATION);
  finally
    LFile.Free;
    LExcludeFile.Free;
    LSource.Free;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Close;
end;

end.
