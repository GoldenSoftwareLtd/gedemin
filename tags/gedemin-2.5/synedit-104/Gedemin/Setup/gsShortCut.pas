unit gsShortCut;

interface

function CreateLink(AnPathObj, AnPathLink, AnDescription: String): Boolean;

implementation

uses
  ShlObj, ActiveX, Windows, JclShell;

function CreateLink(AnPathObj, AnPathLink, AnDescription: String): Boolean;
const
  IID_IPersistFile: TGUID = '{0000010B-0000-0000-C000-000000000046}';
var
  hres: HRESULT;
  psl: IShellLink;
  wsz: PWideChar;
begin

  // Get a pointer to the IShellLink interface.
  hres := CoCreateInstance(CLSID_ShellLink, nil,
      CLSCTX_INPROC_SERVER, IID_IShellLinkA, psl);
  if (SUCCEEDED(hres)) then
  begin
    // Set the path to the shortcut target, and add the
    // description.
    psl.SetPath(PChar(AnPathObj));

    psl.SetDescription(PChar(AnDescription));

    GetMem(wsz, MAX_PATH);
    try
      // Ensure that the string is ANSI.
      MultiByteToWideChar(CP_ACP, 0, PChar(AnPathLink), -1, wsz, MAX_PATH);
      // Save the link by calling IPersistFile::Save.
      hres := (psl as IPersistFile).Save(wsz, TRUE);
    finally
      FreeMem(wsz);
    end;
    // Release
    psl := nil;
  end;
  Result := SUCCEEDED(hres);
end;

end.
