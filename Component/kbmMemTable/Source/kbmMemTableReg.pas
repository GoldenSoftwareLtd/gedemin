unit kbmMemTableReg;

interface

{$I kbmMemTable.inc}

uses Classes
{$ifdef LEVEL6}
 {$ifndef LINUX}
  {$IFNDEF DOTNET}
  ,PropertyCategories
  {$ENDIF}
 {$endif}
{$else}
 ,DsgnIntf
{$endif}
{$ifdef LEVEL5}
 {$ifndef LINUX}
 {$IFNDEF DOTNET}
 ,FldLinks
 {$ENDIF}
 {$endif}
 ,DB,Sysutils
{$endif};

procedure Register;
// =========================================================================
// Registration for kbmMemTable extended by Chris G. Royle to support
// Delphi 5 Categories.
//
// Between versions 1.37 and the current version, many new features / properties have
// been added. Categorisation helps newbies & upgraders make the transition.
//
// Note that the Advanced, and File Categories default to being non-visible after a build.
// =========================================================================
implementation

uses
  kbmMemTable,kbmMemBinaryStreamFormat,kbmMemCSVStreamFormat
{$ifdef LEVEL5}
 ,kbmMemTableDesigner
{$endif}
{$ifdef LEVEL6}
 {$ifndef LINUX}
 {$IFDEF DOTNET}
 ,Borland.Vcl.Design.DesignEditors
 ,Borland.Vcl.Design.DesignIntf
 {$ELSE}
 ,DesignEditors
 ,DesignIntf
 {$ENDIF}
 {$endif}
{$endif}
;

{$ifdef DOTNET}
 {$R icons\kbmMemTable.TkbmMemTable.bmp}
 {$R icons\kbmMemTable.TkbmThreadDataSet.bmp}
 {$R icons\kbmMemBinaryStreamFormat.TkbmBinaryStreamFormat.bmp}
 {$R icons\kbmMemCSVStreamFormat.TkbmCSVStreamFormat.bmp}
{$endif}

{$ifdef LEVEL5}
type
  T__Dummy = class(TObject); // To make sure compilation will be ok even if all ifdefs fail.

{$ifndef LINUX}
  TkbmMemTableLocaleIDProperty = class(TIntegerProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure GetValues(Proc: TGetStrProc); override;
    procedure SetValue(const Value: string); override;
  end;

 {$ifndef LEVEL6}
  TkbmMemTableBasicCategory = class(TPropertyCategory)
  public
    class function Name: string; override;
    class function Description: string; override;
  end;
  TkbmMemTableAdvancedCategory = class(TPropertyCategory)
  public
    class function Name: string; override;
    class function Description: string; override;
    procedure AfterConstruction; override;
  end;
  TkbmMemTableIndexCategory = class(TPropertyCategory)
  public
    class function Name: string; override;
    class function Description: string; override;
  end;
  TkbmMemTableFileCategory = class(TPropertyCategory)
  public
    class function Name: string; override;
    class function Description: string; override;
    procedure AfterConstruction; override;
  end;
  TkbmMemTableLocaleCategory = class(TPropertyCategory)
  public
    class function Name: string; override;
    class function Description: string; override;
    procedure AfterConstruction; override;
  end;
 {$endif} // LEVEL6

 {$ifdef LEVEL5}
   {$IFNDEF DOTNET}
{ TkbmMemTableFieldLinkProperty }
  TkbmMemTableFieldLinkProperty = class(TFieldLinkProperty)
  private
    FTable: TkbmCustomMemTable;
  protected
    procedure GetFieldNamesForIndex(List: TStrings); override;
    function GetIndexBased: Boolean; override;
    function GetIndexDefs: TIndexDefs; override;
    function GetIndexFieldNames: string; override;
    function GetIndexName: string; override;
    function GetMasterFields: string; override;
    procedure SetIndexFieldNames(const Value: string); override;
    procedure SetIndexName(const Value: string); override;
    procedure SetMasterFields(const Value: string); override;
  public
    property IndexBased: Boolean read GetIndexBased;
    property IndexDefs: TIndexDefs read GetIndexDefs;
    property IndexFieldNames: string read GetIndexFieldNames write SetIndexFieldNames;
    property IndexName: string read GetIndexName write SetIndexName;
    property MasterFields: string read GetMasterFields write SetMasterFields;

    procedure Edit; override;
  end;
 {$ENDIF}

  TkbmIndexNameProperty = class(TStringProperty)
  public
    procedure GetValues(Proc: TGetStrProc); override;
    function GetAttributes: TPropertyAttributes; override;
  end;

  TkbmIndexFieldNamesProperty = class(TStringProperty)
  public
    procedure GetValues(Proc: TGetStrProc); override;
    function GetAttributes: TPropertyAttributes; override;
  end;
 {$endif}
{$endif} // LINUX

const
  CBasicName    = 'Basic';
  CBasicDesc    = 'TkbmMemTable Basic';
  CFileName     = 'File Access';
  CFileDesc     = 'TkbmMemTable File Access';
  CIndexName    = 'Indexing';
  CIndexDesc    = 'TkbmMemTable Indexing';
  CAdvancedName = 'Advanced';
  CAdvancedDesc = 'TkbmMemTable Advanced';
  CLocaleName   = 'Locale';
  CLocaleDesc   = 'TkbmMemTable Locale';
{$endif} // LEVEL5


procedure Register;
begin
  RegisterComponents('kbmMemTable', [TkbmMemTable,{$ifndef LINUX}TkbmThreadDataSet,{$endif}TkbmBinaryStreamFormat,TkbmCSVStreamFormat]);



{$ifndef LINUX}
 {$ifdef LEVEL5}
  {$IFNDEF DOTNET}
  RegisterComponentEditor(TkbmMemTable, TkbmMemTableDesigner);
  RegisterPropertyEditor(TypeInfo(string), TkbmCustomMemTable, 'MasterFields', TkbmMemTableFieldLinkProperty);
  {$ENDIF}
  RegisterPropertyEditor(TypeInfo(TkbmLocaleID), TkbmCustomMemTable, 'LocaleID', TkbmMemTableLocaleIDProperty);
  RegisterPropertyEditor(TypeInfo(string), TkbmCustomMemTable, 'IndexName', TkbmIndexNameProperty);
  RegisterPropertyEditor(TypeInfo(string), TkbmCustomMemTable, 'IndexFieldNames', TkbmIndexFieldNamesProperty);

  {$ifdef LEVEL6}
  RegisterPropertiesInCategory(CBasicName, TkbmMemTable,
    ['Active','DesignActivation',
     'FieldDefs',
     'EnableIndexes', 'IndexDefs', 'IndexFieldNames', 'IndexName', 'AutoReposition',
     'Filter', 'Filtered', 'FilterOptions',
     'Persistent', 'PersistentFile','PersistentFormat','CommaTextFormat','DefaultFormat',
     'ProgressFlags',
     'MasterFields', 'MasterSource', 'DetailFields', 'Name',
     'ReadOnly', 'SortFields', 'SortOptions',
     'Tag', 'Version',
     'OnFilterRecord', 'OnCalcFields', 'OnProgress']);
  RegisterPropertiesInCategory(CFileName, TkbmMemTable,
    ['Persistent', 'PersistentFile', 'PersistentSaveFormat', 'PersistentSaveOptions',
     'PersistentBackup', 'PersistentBackupExt',
     'PersistentFormat', 'CommaTextFormat', 'DefaultFormat',
     'OnLoad', 'OnLoadRecord', 'OnSave', 'OnSaveRecord']);
  RegisterPropertiesInCategory(CIndexName, TkbmMemTable,
    ['EnableIndexes', 'IndexDefs', 'IndexFieldNames', 'IndexName', 'OnFilterIndex']);
  RegisterPropertiesInCategory(CAdvancedName, TkbmMemTable,
    ['AllDataOptions',
     'AttachedAutoRefresh', 'AttachedTo',
     'AutoIncMinValue', 'EnableJournal',
     'EnableVersioning',
     'DeltaHandler',
     'LoadLimit',
     'RecalcOnFetch', 'RecalcOnIndex', 'StoreDataOnForm', 'FormFormat',
     'Performance', 'Standalone',
     'VersioningMode',
     'OnLoadField', 'OnSaveField', 'OnCompareFields',
     'OnCompressBlobStream', 'OnDecompressBlobStream',
     'OnCompressField','OnDecompressField','OnSetupField']);
  RegisterPropertiesInCategory(CLocaleName, TkbmMemTable,
    ['LocaleID',
     'LanguageID', 'SubLanguageID',
     'SortID']);
  {$else} // LEVEL6
  RegisterPropertiesInCategory(TkbmMemTableBasicCategory, TkbmMemTable,
    ['Active','DesignActivation',
     'FieldDefs',
     'EnableIndexes', 'IndexDefs', 'IndexFieldNames', 'IndexName', 'AutoReposition',
     'Filter', 'Filtered', 'FilterOptions',
     'Persistent', 'PersistentFile','PersistentFormat','CommaTextFormat','DefaultFormat',
     'ProgressFlags',
     'MasterFields', 'MasterSource', 'DetailFields', 'Name',
     'ReadOnly', 'SortFields', 'SortOptions',
     'Tag', 'Version',
     'OnFilterRecord', 'OnCalcFields', 'OnProgress']);
  RegisterPropertiesInCategory(TkbmMemTableFileCategory, TkbmMemTable,
    ['Persistent', 'PersistentFile', 'PersistentSaveFormat', 'PersistentSaveOptions',
     'PersistentBackup', 'PersistentBackupExt',
     'PersistentFormat', 'CommaTextFormat', 'DefaultFormat',
     'OnLoad', 'OnLoadRecord', 'OnSave', 'OnSaveRecord']);
  RegisterPropertiesInCategory(TkbmMemTableIndexCategory, TkbmMemTable,
    ['EnableIndexes', 'IndexDefs', 'IndexFieldNames', 'IndexName', 'OnFilterIndex']);
  RegisterPropertiesInCategory(TkbmMemTableAdvancedCategory, TkbmMemTable,
    ['AllDataOptions',
     'AttachedAutoRefresh', 'AttachedTo',
     'AutoIncMinValue', 'EnableJournal',
     'EnableVersioning',
     'DeltaHandler',
     'LoadLimit',
     'RecalcOnFetch', 'RecalcOnIndex', 'StoreDataOnForm', 'FormFormat',
     'Performance', 'Standalone',
     'VersioningMode',
     'OnLoadField', 'OnSaveField', 'OnCompareFields',
     'OnCompressBlobStream', 'OnDecompressBlobStream',
     'OnCompressField','OnDecompressField','OnSetupField']);
  RegisterPropertiesInCategory(TkbmMemTableLocaleCategory, TkbmMemTable,
    ['LocaleID',
     'LanguageID', 'SubLanguageID',
     'SortID']);
  {$endif} // LEVEL6
 {$endif} // LEVEL5
{$endif} // LINUX



end;

{$ifndef LINUX}
 {$ifdef LEVEL5}
function TkbmMemTableLocaleIDProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paMultiSelect, paValueList, paSortList, paRevertable];
end;

procedure TkbmMemTableLocaleIDProperty.GetValues(Proc: TGetStrProc);
var
   l:TLanguages;
   i:integer;
begin
     l:=Languages;
     for i:=0 to l.Count-1 do Proc(l.Name[i]);
end;

procedure TkbmMemTableLocaleIDProperty.SetValue(const Value: string);
var
   l:TLanguages;
   i:integer;
begin
     l:=Languages;
     for i:=0 to l.Count-1 do
         if l.Name[i]=Value then
         begin
              SetOrdValue(l.LocaleID[i]);
              break;
         end;
end;
 {$endif} // LEVEL5

 {$ifdef LEVEL5}
  {$ifndef LEVEL6}
class function TkbmMemTableBasicCategory.Name: string;
begin
  Result := CBasicName;
end;

class function TkbmMemTableBasicCategory.Description: string;
begin
  Result := CBasicDesc;
end;

class function TkbmMemTableFileCategory.Name: string;
begin
  Result := CFileName;
end;

class function TkbmMemTableFileCategory.Description: string;
begin
  Result := CFileDesc;
end;

procedure TkbmMemTableFileCategory.AfterConstruction;
begin
  inherited;
  Visible:= False;
end;

class function TkbmMemTableIndexCategory.Name: string;
begin
  Result := CIndexName;
end;

class function TkbmMemTableIndexCategory.Description: string;
begin
  Result := CIndexDesc;
end;

class function TkbmMemTableAdvancedCategory.Name: string;
begin
  Result := CAdvancedName;
end;

procedure TkbmMemTableAdvancedCategory.AfterConstruction;
begin
  inherited;
  Visible:= False;
end;

class function TkbmMemTableAdvancedCategory.Description: string;
begin
  Result := CAdvancedDesc;
end;

class function TkbmMemTableLocaleCategory.Name: string;
begin
  Result := CLocaleName;
end;

class function TkbmMemTableLocaleCategory.Description: string;
begin
  Result := CLocaleDesc;
end;

procedure TkbmMemTableLocaleCategory.AfterConstruction;
begin
  inherited;
  Visible:= False;
end;
  {$endif} // LEVEL6

{ TkbmMemTableFieldLinkProperty }
{$IFNDEF DOTNET}
procedure TkbmMemTableFieldLinkProperty.Edit;
var
  Table: TkbmCustomMemTable;
begin
  Table := TkbmCustomMemTable(DataSet);
  FTable := TkbmCustomMemTable.Create(nil);
  FTable.Name:='__PROXY_MT';
  try
     FTable.CreateTableAs(Table,[]);
     FTable.IndexDefs.assign(Table.IndexDefs);
     FTable.MasterFields := Table.MasterFields;

     if Table.IndexFieldNames <> '' then
        FTable.IndexFieldNames := Table.IndexFieldNames
     else
         FTable.IndexName := Table.IndexName;

     FTable.Open;
     inherited Edit;
     if Changed then
     begin
          Table.MasterFields := FTable.MasterFields;
          if FTable.IndexFieldNames <> '' then
             Table.IndexFieldNames := FTable.IndexFieldNames
          else
              Table.IndexName := FTable.IndexName;
     end;
  finally
     FTable.Free;
  end;
end;

procedure TkbmMemTableFieldLinkProperty.GetFieldNamesForIndex(List: TStrings);
var
  i: Integer;
begin
  for i := 0 to FTable.IndexFieldCount - 1 do
      List.Add(FTable.IndexFields[i].FieldName);
end;

function TkbmMemTableFieldLinkProperty.GetIndexBased: Boolean;
begin
  Result := not IProviderSupport(FTable).PSIsSQLBased;
end;

function TkbmMemTableFieldLinkProperty.GetIndexDefs: TIndexDefs;
begin
  Result := FTable.IndexDefs;
end;

function TkbmMemTableFieldLinkProperty.GetIndexFieldNames: string;
begin
  Result := FTable.IndexFieldNames;
end;

function TkbmMemTableFieldLinkProperty.GetIndexName: string;
begin
  Result := FTable.IndexName;
end;

function TkbmMemTableFieldLinkProperty.GetMasterFields: string;
begin
  Result := FTable.MasterFields;
end;

procedure TkbmMemTableFieldLinkProperty.SetIndexFieldNames(const Value: string);
begin
  FTable.IndexFieldNames := Value;
end;

procedure TkbmMemTableFieldLinkProperty.SetIndexName(const Value: string);
begin
     FTable.IndexName := Value;
end;

procedure TkbmMemTableFieldLinkProperty.SetMasterFields(const Value: string);
begin
  FTable.MasterFields := Value;
end;

{$ENDIF}

procedure TkbmIndexNameProperty.GetValues(Proc: TGetStrProc);
var
   i:integer;
   mt:TkbmCustomMemTable;
begin
     mt:=TkbmCustomMemTable(GetComponent(0));
     for i:=0 to mt.IndexDefs.Count-1 do
         Proc(mt.IndexDefs.Items[i].Name);
end;

function TkbmIndexNameProperty.GetAttributes: TPropertyAttributes;
begin
     Result:=[paMultiSelect,paSortList,paValueList];
end;

procedure TkbmIndexFieldNamesProperty.GetValues(Proc: TGetStrProc);
var
   i:integer;
   mt:TkbmCustomMemTable;
begin
     mt:=TkbmCustomMemTable(GetComponent(0));
     for i:=0 to mt.IndexDefs.Count-1 do
         Proc(mt.IndexDefs.Items[i].Fields);
end;

function TkbmIndexFieldNamesProperty.GetAttributes: TPropertyAttributes;
begin
     Result:=[paMultiSelect,paSortList,paValueList];
end;
 {$endif} // LEVEL5
{$endif} // LINUX

end.


