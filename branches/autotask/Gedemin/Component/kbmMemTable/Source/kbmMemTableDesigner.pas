unit kbmMemTableDesigner;

interface

{$I kbmMemTable.inc}

uses
{$ifdef LEVEL6}
 {$ifndef LINUX}
   {$IFDEF DOTNET}
    Borland.Vcl.Design.DesignEditors,
   {$ELSE}
    DesignEditors,
   {$ENDIF}
 {$endif}
{$else}
    Dsgnintf,
{$endif}
    db;

{$ifndef LINUX}
type
    TkbmMemTableDesigner = class(TComponentEditor)
    private
    public
    	procedure ExecuteVerb(Index: Integer); override;
    	function GetVerb(Index: Integer): string; override;
    	function GetVerbCount: Integer; override;
    	procedure TableDesigner;
    	procedure LoadPersistentFileBinary;
    	procedure LoadPersistentFileNormal;
    	procedure EmptyTable;
    end;
{$endif}

implementation

{$ifndef LINUX}
uses
  {$IFNDEF DOTNET}
    DSDesign,
  {$ENDIF}
    kbmMemTable,
    kbmMemCSVStreamFormat,
    kbmMemBinaryStreamFormat,
    kbmMemTableDesForm;

procedure TkbmMemTableDesigner.EmptyTable;
begin
     TkbmMemTable(Component).Active := True;
     TkbmMemTable(Component).EmptyTable;
end;

procedure TkbmMemTableDesigner.ExecuteVerb(Index: Integer);
begin
{$ifndef LEVEL5}
ShowMessage('5: Index='+inttostr(Index));
     inc(Index);
{$endif}

     case Index of
{$ifdef LEVEL5}
 {$ifdef DOTNET}
      	0: inherited ExecuteVerb(Index);
 {$else}
      	0: DSDesign.ShowFieldsEditor(Designer, TDataSet(Component),TDSDesigner);
 {$endif}
{$endif}
        1: TableDesigner;
        2: LoadPersistentFileBinary;
        3: LoadPersistentFileNormal;
        4: EmptyTable;
     end;
end;

function TkbmMemTableDesigner.GetVerb(Index: Integer): String;
begin
{$ifndef LEVEL5}
     inc(Index);
{$endif}
     case Index of
{$ifdef LEVEL5}
        0: Result:= '&Fields Editor';
{4endif}
     	  1: Result:= '&Table Designer';
     	  2: Result:= '&Load Persistent File (Binary)';
     	  3: Result:= '&Load Persistent File (Normal)';
     	  4: Result:= '&Empty Table';
     end;
end;

function TkbmMemTableDesigner.GetVerbCount: Integer;
begin
{$ifdef LEVEL5}
     Result:=5;
{$else}
     Result:=4;
{$endif}
end;

procedure TkbmMemTableDesigner.LoadPersistentFileBinary;
var
   DummyTable:TkbmMemTable;
   Fmt:TkbmCustomStreamFormat;
begin
     DummyTable:=TkbmMemTable.Create(nil);
     Fmt:=TkbmBinaryStreamFormat.Create(nil);
     try
        DummyTable.LoadFromFileViaFormat(TkbmMemTable(Component).PersistentFile,Fmt);
        DummyTable.Active:=True;
        TkbmMemTable(Component).Active:=True;
        TkbmMemTable(Component).EmptyTable;
        frmKbmMemTableDesigner.CopyDataSet(DummyTable,TDataSet(Component),False);
        DummyTable.Active:=False;
     finally
        Fmt.Free;
        DummyTable.Free;
     end;
end;

procedure TkbmMemTableDesigner.LoadPersistentFileNormal;
var
   DummyTable:TkbmMemTable;
   Fmt:TkbmCustomStreamFormat;
begin
     DummyTable:=TkbmMemTable.Create(nil);
     Fmt:=TkbmCSVStreamFormat.Create(nil);
     try
        DummyTable.LoadFromFileViaFormat(TkbmMemTable(Component).PersistentFile,Fmt);
        DummyTable.Active := True;
        TkbmMemTable(Component).Active:=True;
        TkbmMemTable(Component).EmptyTable;
        frmKbmMemTableDesigner.CopyDataSet(DummyTable,TDataSet(Component),False);
        DummyTable.Active := False;
     finally
        Fmt.Free;
        DummyTable.Free;
     end;
end;

procedure TkbmMemTableDesigner.TableDesigner;
var
   frmKbmMemTableDesigner:TfrmKbmMemTableDesigner;
begin
     frmKbmMemTableDesigner:=TfrmKbmMemTableDesigner.Create(nil);
     try
        frmkbmMemTableDesigner.Designer := Designer;
        frmKbmMemTableDesigner.MemTable:=TkbmMemTable(Component);
        frmKbmMemTableDesigner.ShowModal;
     finally
//        frmKbmMemTableDesigner.Free;
     end;
end;

 {$endif}
{$endif}

end.
