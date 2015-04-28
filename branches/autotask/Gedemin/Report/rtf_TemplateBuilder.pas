unit rtf_TemplateBuilder;

interface

uses
  Word97, Windows, SysUtils, Classes, Forms;

type
  TgsWord97 = class(TComponent)
  private
    FWordApplication: TWordApplication;
    FWordDocument: TWordDocument;
    FWordAppl, FTemplateBuild: Boolean;
    FWorkFileName: OleVariant;

    procedure WordApplicationQuit(Sender: TObject);
    procedure WordDocumentClose(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function Execute(const AnStream: TStream): Boolean;
  end;

implementation

uses
  gd_SetDatabase;

{ TgsWord97 }

constructor TgsWord97.Create(AOwner: TComponent);
begin
  inherited Create(Owner);

  FWordApplication := TWordApplication.Create(nil);
  FWordApplication.OnQuit := WordApplicationQuit;
  FWordDocument := TWordDocument.Create(nil);
  FWordDocument.OnClose := WordDocumentClose;
end;

destructor TgsWord97.Destroy;
begin
  FreeAndNil(FWordDocument);
  FreeAndNil(FWordApplication);

  inherited Destroy;
end;

procedure TgsWord97.WordApplicationQuit(Sender: TObject);
begin
  FWordApplication.Disconnect;
  FTemplateBuild := False;
  FWordAppl := False;
end;

procedure TgsWord97.WordDocumentClose(Sender: TObject);
var
  FileFormat: OleVariant;
begin
  FileFormat := wdFormatRTF;
  if not FWordDocument.Saved then
  begin
    FWordDocument.SaveAs(FWorkFileName, FileFormat);
  end;
//  FWordDocument.Disconnect;
  FTemplateBuild := False;
end;

function TgsWord97.Execute(const AnStream: TStream): Boolean;
var
  FWorkFile: TFileStream;
  Template, NewTemplate: OleVariant;
  WindowList: Pointer;
begin
  // ����� ��� ���� �� ��������. ���� ��� �� ���������.
  if FTemplateBuild then
    MessageBox(0,
      '������ ��� �������������.', '��������', MB_OK or MB_ICONWARNING or MB_TASKMODAL);

  FTemplateBuild := True;
  try
    // ������� ���� ���� ��� �������������� �������
    FWorkFileName := rpGetTempFileName('rtftmp');
    try
      // �������� � ���� ������
      FWorkFile := TFileStream.Create(FWorkFileName, fmCreate);
      try
        FWorkFile.CopyFrom(AnStream, AnStream.Size);
      finally
        FWorkFile.Free;
      end;

      // ������������ � Word
      FWordApplication.Connect;
      FWordApplication.Visible := True;
      FWordApplication.Caption := '�������������� ������� RTF';
      FWordAppl := True;

      // ��������� ��� �������� ������ ���������
      Template := EmptyParam;
      NewTemplate := False;

      FWordDocument.ConnectTo(FWordApplication.Documents.Open(FWorkFileName, EmptyParam,
       EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam,
       EmptyParam));

      // ������� �� ���� �� z
      FWordApplication.Activate;
      FWordDocument.Activate;

      // ������������ ��� ���� ����������
      WindowList := DisableTaskWindows(0);
      try
        // ����. ������� �������� Word.
        while FTemplateBuild do
        begin
          Application.ProcessMessages;
          Sleep(50);
        end;

        // �������� ������� ��������. ������������ ������� ����� �� �������.
        // ������� � ����������� �� ������� �������� ����� ��������� ������.
        // ���� ������ �� �������� ��������� ���� (� ����������� �� ������� ��������).
        try
          FWordDocument.Close;
        except
        end;
        FWordDocument.Disconnect;

        // ���� ��� �������� ����������, �� ��������� Word.
        if FWordAppl then
        begin
          if FWordApplication.Documents.Count = 0 then
            FWordApplication.Quit;
          FWordApplication.Disconnect;
        end;

      finally
        Result := (MessageBox(0, '��������� ��������� � �������?',
         '������', MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL) = IDYES);
        // ���������� ��� ����
        EnableTaskWindows(WindowList);
      end;

      if Result then
      begin
        // ��������� ���� � ��������� �� ���� ������.
        FWorkFile := TFileStream.Create(FWorkFileName, fmOpenRead);
        try
          AnStream.Position := 0;
          AnStream.Size := 0;
          AnStream.CopyFrom(FWorkFile, FWorkFile.Size);
        finally
          FWorkFile.Free;
        end;
      end;
    finally
      // ������� ���� ����.
      DeleteFile(FWorkFileName);
    end;
  finally
    // �������� �����.
    FWordAppl := False;
    FTemplateBuild := False;
  end;
end;

end.
