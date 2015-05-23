unit DeleteProp_MainForm_Unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TfrmDeleteProp_MainForm = class(TForm)
    edPath: TEdit;
    Label1: TLabel;
    mPropList: TMemo;
    Button2: TButton;
    chbxSubFolders: TCheckBox;
    Memo1: TMemo;
    Label2: TLabel;
    Button1: TButton;
    Shape1: TShape;
    Shape2: TShape;
    Shape3: TShape;
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
  public
  end;

var
  frmDeleteProp_MainForm: TfrmDeleteProp_MainForm;

implementation

{$R *.DFM}

uses
  jclFileUtils, jclStrings;

procedure TfrmDeleteProp_MainForm.Button2Click(Sender: TObject);
var
  LFile, LSource, LResult: TStringList;
  I, J, K, Processed, WasError, Removed: Integer;
  SkipPropData: Boolean;
  FLOpt: TFileListOptions;
  S, BackupFileName: String;
begin
  LFile := TStringList.Create;
  LSource := TStringList.Create;
  LResult := TStringList.Create;
  try
    if chbxSubFolders.Checked then
      FLOpt := [flFullNames, flRecursive]
    else
      FLOpt := [flFullNames];

    if not AdvBuildFileList(IncludeTrailingBackslash(edPath.Text) + '*.DFM', faAnyFile, LFile, FLOpt) then
    begin
      MessageBox(Handle,
        'Invalid path specified. Can not process.',
        'Warning',
        MB_OK or MB_ICONEXCLAMATION);
      exit;
    end;

    Processed := 0;
    WasError := 0;

    for I := 0 to LFile.Count - 1 do
    begin
      LSource.LoadFromFile(LFile[I]);
      Removed := 0;

      for K := 0 to mPropList.Lines.Count - 1 do
      begin
        if K > 0 then
          LSource.Assign(LResult);

        if Trim(mPropList.Lines[K]) = '' then
          continue;

        LResult.Clear;
        SkipPropData := False;

        for J := 0 to LSource.Count - 1 do
        begin
          S := Trim(LSource[J]);

          if SkipPropData then
          begin
            if (S > '') and (S[Length(S)] in [')', '}']) then
              SkipPropData := False;
            continue;
          end;

          if StrIPos(mPropList.Lines[K] + ' =', S) = 0 then
          begin
            LResult.Add(LSource[J]);
            continue;
          end;

          if (S > '') and (S[Length(S)] in ['(', '{']) then
            SkipPropData := True;

          Removed := Removed + 1;
        end;
      end;

      if Removed > 0 then
      begin
        BackupFileName := ChangeFileExt(LFile[I], '.BAK');

        if FileExists(BackupFileName) then
          DeleteFile(BackupFileName);

        if RenameFile(LFile[I], BackupFileName) then
        begin
          LResult.SaveToFile(LFile[I]);
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
      PChar(Format('Total files found: %d'#13#10'Properties were removed from: %d'#13#10'Error files: %d',
        [LFile.Count, Processed, WasError])),
      'Statistics',
      MB_OK or MB_ICONINFORMATION);
  finally
    LFile.Free;
    LSource.Free;
    LResult.Free;
  end;
end;

procedure TfrmDeleteProp_MainForm.Button1Click(Sender: TObject);
begin
  Close;
end;

end.
