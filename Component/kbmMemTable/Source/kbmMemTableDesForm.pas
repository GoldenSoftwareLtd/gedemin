unit kbmMemTableDesForm;

interface

{$include kbmMemTable.inc}

{$IFNDEF LINUX}

uses



{$IFDEF CLX}
    QForms,
    QImgList, QDialogs, QGrids, QDBGrids, QStdCtrls, QCheckLst,
    QButtons, QControls, QComCtrls, QExtCtrls,
    TypInfo, ImgList, Controls, Dialogs, DB, DBTables, Grids, DBGrids,
  StdCtrls, CheckLst, Buttons, ComCtrls, ExtCtrls, Classes,
  System.ComponentModel
{$ELSE}
    Windows, Messages, Graphics, Controls, Forms, Dialogs,
    ComCtrls, ExtCtrls, StdCtrls,BDE,DBTables,typinfo,
    Grids, DBGrids, CheckLst, ImgList, Buttons, DB, Classes
 {$IFDEF LEVEL6}
   {$IFDEF DOTNET}
    ,Borland.Vcl.Design.DesignEditors
    ,Borland.Vcl.Design.DesignIntf
   {$ELSE}
    ,DesignEditors
    ,DesignIntf
   {$ENDIF}
 {$ELSE}
    ,DsgnIntf
 {$ENDIF}
{$ENDIF}
    ,SysUtils
    ,kbmMemTable
    ,kbmMemCSVStreamFormat
    ,kbmMemBinaryStreamFormat
    ;

type
    TfrmKbmMemTableDesigner = class(TForm)

{$IFNDEF LINUX}
      SES_Dummy: TSession;
      tsBDEAlias: TTabSheet;
      Label1: TLabel;
      Label2: TLabel;
      LTV_Alias: TListView;
      LTV_Tables: TListView;
{$ENDIF}
      StatusBar1: TStatusBar;
      DLG_SelectFile: TOpenDialog;
      DTS_DataDesign: TDataSource;
      DLG_SaveFile: TSaveDialog;
      IMG_LTV_Tables: TImageList;
      IMG_LTV_Alias: TImageList;
      IMG_LTV_Fields: TImageList;
      PGC_Options: TPageControl;
      TBS_ActualStructure: TTabSheet;
      PAN_ActualStructure: TPanel;
      LTV_Structure: TListView;
      TBS_BorrowStructure: TTabSheet;
      PAN_BorrowStructure: TPanel;
      BTN_Refresh: TButton;
      BTN_GetStructure: TButton;
      pcBorrowFrom: TPageControl;
      tsTDataset: TTabSheet;
      LTV_Datasets: TListView;
      TBS_Data: TTabSheet;
      PAN_Data: TPanel;
      LAB_Progress: TLabel;
      RBT_FromFile: TRadioButton;
      RBT_FromTable: TRadioButton;
      PAN_FromFile: TPanel;
      Label3: TLabel;
      EDT_File: TEdit;
      PAN_FromTable: TPanel;
      LTV_FromTable: TListView;
      BTN_Load: TButton;
      BTN_SelectFileName: TButton;
      BTN_Save: TButton;
      PRO_Records: TProgressBar;
      CHK_Binary: TCheckBox;
      CHK_OnlyData: TCheckBox;
      TBS_Sorting: TTabSheet;
      PAN_Sort: TPanel;
      Label4: TLabel;
      Label5: TLabel;
      BTN_SEL_All: TSpeedButton;
      BTN_SEL_Selected: TSpeedButton;
      BTN_UNS_Selected: TSpeedButton;
      BTN_UNS_All: TSpeedButton;
      BTN_ORD_First: TSpeedButton;
      BTN_ORD_Plus: TSpeedButton;
      BTN_ORD_Minus: TSpeedButton;
      BTN_ORD_Last: TSpeedButton;
      Label6: TLabel;
      LTV_Existing: TListView;
      LTV_Sort: TListView;
      BTN_Sort: TButton;
      LTB_SortOptions: TCheckListBox;
      TBS_DataDesign: TTabSheet;
      PAN_DataDesign: TPanel;
      DBG_DataDesign: TDBGrid;
      RBT_FromDataset: TRadioButton;
      PAN_FromDataset: TPanel;
      LTV_FromDataset: TListView;
      procedure FormCreate(Sender: TObject);
      procedure FormShow(Sender: TObject);
      procedure FormClose(Sender: TObject; var Action: TCloseAction);
{$IFNDEF LINUX}
      procedure LTV_AliasChange(Sender: TObject; Item: TListItem;Change: TItemChange);
      procedure LTV_TablesChange(Sender: TObject; Item: TListItem;Change: TItemChange);
{$ENDIF}
      procedure BTN_GetStructureClick(Sender: TObject);
      procedure RBT_FromFileClick(Sender: TObject);
      procedure RBT_FromTableClick(Sender: TObject);
      procedure LTV_FromTableChange(Sender: TObject; Item: TListItem;Change: TItemChange);
      procedure BTN_SelectFileNameClick(Sender: TObject);
      procedure BTN_LoadClick(Sender: TObject);
      procedure BTN_SaveClick(Sender: TObject);
      procedure BTN_RefreshClick(Sender: TObject);
      procedure LTV_ExistingChange(Sender: TObject; Item: TListItem;Change: TItemChange);
      procedure LTV_SortChange(Sender: TObject; Item: TListItem;Change: TItemChange);
      procedure BTN_SEL_AllClick(Sender: TObject);
      procedure BTN_UNS_AllClick(Sender: TObject);
      procedure BTN_SEL_SelectedClick(Sender: TObject);
      procedure BTN_UNS_SelectedClick(Sender: TObject);
      procedure BTN_ORD_LastClick(Sender: TObject);
      procedure BTN_ORD_FirstClick(Sender: TObject);
      procedure BTN_ORD_MinusClick(Sender: TObject);
      procedure BTN_ORD_PlusClick(Sender: TObject);
      procedure BTN_SortClick(Sender: TObject);
    procedure LTV_DatasetsChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure RBT_FromDatasetClick(Sender: TObject);
    procedure LTV_FromDatasetChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    private
      { Private declarations }
      IsFilling: boolean;
{$IFNDEF LINUX}
      procedure GetAliases;
      procedure GetTables(DatabaseName: string);
      procedure LoadStructure(TableName: string);
{$ENDIF}
      procedure GetDatasets;
      procedure GetActualStructure;
      procedure CheckAvailData;
      procedure TransAll(Source: TListView; Dest: TListView);
      procedure CopyItem(SourceItem: TListITem; Dest: TListView);
      procedure StoreSortSetup;

      {ListItems Handling functions and procedures }
      function SwapItems(ItemFrom:TListItem; ItemTo:TListItem):boolean;
      function MoveItem(Item:TListItem; DestinationIndex:integer):TListItem;
      procedure SelectFull(Item:TListItem);
      function DeleteItem(Item:TListItem): TListItem;
      function IsInFieldNames(FieldNames,FieldName:string):boolean;
      procedure CreateFields;
    public
      { Public declarations }
{$IFDEF LEVEL3}
      Designer:TFormDesigner;
{$ELSE}
 {$IFDEF LEVEL6}
      Designer:IDesigner;
 {$ELSE}
      Designer:IFormDesigner;
 {$ENDIF}
{$ENDIF}
      MemTable: TkbmMemTable;
      procedure CopyDataSet(Source: TDataSet; Dest: TDataSet;Visual: boolean);
    end;

var
   frmKbmMemTableDesigner:TfrmKbmMemTableDesigner;

const
     KbmMemTableDesignerVersion='Designer - TkbmMemTable v.'+COMPONENT_VERSION;

implementation

{$IFNDEF LINUX}
 {$R *.dfm}
{$ELSE}
 {$R *.xfm}
{$ENDIF}

// To use code completion, please remark the line further down (uses DSDesign)
// during designtime. Remember to remove the remark before compiletime.
// Kim Bo Madsen/Optical Services - Scandinavia
{$IFNDEF LINUX}
{$IFNDEF DOTNET}
   uses DSDesign;
{$ENDIF}
{$ENDIF}

function TfrmKbmMemTableDesigner.SwapItems(ItemFrom:TListItem; ItemTo:TListItem):boolean;
var
   ListView:TListView;
   i:integer;
   ItemDummy:TStringList;

   tmpCaption:string;
   tmpState:integer;
   tmpImageIndex:integer;
   ControlCheck:boolean;
begin
     Result:=false;

     if (ItemFrom = nil) or (ItemTo = nil) then exit;
     if TListView(ItemFrom.Owner.Owner) <> TListView(ItemTo.Owner.Owner) then exit;

     ListView:=TListView(ItemFrom.Owner.Owner);
     if ListView = nil then exit;

     ControlCheck:=ListView.CheckBoxes;

     ItemDummy:=TStringList.Create;
     try
        tmpCaption:=ItemFrom.Caption;
        tmpImageIndex:=ItemFrom.ImageIndex;

        if ControlCheck then
           tmpState:=ord(ItemFrom.Checked)
        else
{$IFNDEF LINUX}
            tmpState:=ItemFrom.StateIndex;
{$ELSE}
            tmpState:=0;
{$ENDIF}

        for i:=0 to ItemFrom.SubItems.Count-1 do
            ItemDummy.Add(ItemFrom.SubItems[i]);

        ItemFrom.Caption:=ItemTo.Caption;

        for i:=0 to ItemTo.SubItems.Count-1 do
            ItemFrom.SubItems[i]:=ItemTo.SubItems[i];

        ItemFrom.ImageIndex:=ItemTo.ImageIndex;
        if ControlCheck then
           ItemFrom.Checked:=ItemTo.Checked
{$IFNDEF LINUX}
        else
            ItemFrom.StateIndex:=ItemTo.StateIndex
{$ENDIF}
        ;


        ItemTo.Caption:=tmpCaption;
        for i:=0 to ItemDummy.Count-1 do
            ItemTo.SubItems[i]:=ItemDummy[i];
        ItemTo.ImageIndex:=tmpImageIndex;

        if ControlCheck then
           ItemTo.Checked:=boolean(tmpState)
{$IFNDEF LINUX}
        else
            ItemTo.StateIndex:=tmpState
{$ENDIF};
     finally
        ItemDummy.Free;
     end;
     Result:=true;
end;

function TfrmKbmMemTableDesigner.MoveItem(Item:TListItem; DestinationIndex:integer):TListItem;
var
   ListView:TListView;
   NewItem:TListItem;
   i:integer;
begin
     Result:=nil;

     if Item=nil then exit;

     ListView:=TListView(Item.Owner.Owner);
     if ListView = nil then exit;

     NewItem:=ListView.Items.Insert(DestinationIndex);
     NewItem.Caption:=Item.Caption;
     NewItem.ImageIndex:=Item.ImageIndex;
{$IFNDEF LINUX}
     NewItem.StateIndex:=Item.StateIndex;
{$ENDIF}
     NewItem.Checked:=Item.Checked;

     for i:=0 to Item.SubItems.Count - 1 do
         NewItem.SubItems.Add(Item.SubItems[i]);

     Item.Delete;
     Result:=NewItem;
end;

procedure TfrmKbmMemTableDesigner.SelectFull(Item:TListItem);
var
   ListView:TListView;
begin
     ListView:=TListView(Item.Owner.Owner);

     if ListView<>nil then
     begin
          if ListView.Selected<>nil then
          begin
               ListView.Selected.Focused:=false;
               ListView.Selected.Selected:=false;
          end;
     end;

     if Item<>nil then
     begin
          Item.Selected:=true;
          Item.Focused:=true;
          Item.MakeVisible{$IFNDEF LINUX}(false){$ENDIF};
     end;
end;

function TfrmKbmMemTableDesigner.DeleteItem(Item:TListItem):TListItem;
var
   Index:integer;
   ListView:TListView;
begin
     ListView:=TListView(Item.Owner.Owner);
     Index:=Item.Index;
     Item.Delete;

     Result:=nil;
     if ListView=nil then exit;
     if ListView.Items.Count=0 then exit;

     if Index>ListView.Items.Count-1 then
        SelectFull(ListView.Items[ListView.Items.Count-1])
     else
         SelectFull(ListView.Items[Index]);

     Result:=ListView.Selected;
end;

function TfrmKbmMemTableDesigner.IsInFieldNames(FieldNames,FieldName:string):boolean;
var
   p:integer;
   s:string;
begin
     Result:=false;
     p:=1;
     while p<=length(FieldNames) do
     begin
          s:=ExtractFieldName(FieldNames,p);
          if s=FieldName then
          begin
               Result:=true;
               break;
          end;
     end;
end;

procedure TfrmKbmMemTableDesigner.GetDatasets;
var
   I: Integer;
 procedure AddDatasetsFromForm(CurForm: TComponent);
 var
    I:integer;
    Item:TListItem;
    CurComp: TComponent;
 begin
{$IFDEF LEVEL6}
{$IFNDEF LINUX}
      if (CurForm is TCustomForm) then
      begin
           if TCustomForm(CurForm).Designer<>nil then
              CurForm:=TCustomForm(CurForm).designer.GetRoot;
      end;
{$ENDIF}
{$ENDIF}
      for i:=CurForm.ComponentCount-1 downto 0 do
      begin
           CurComp:=CurForm.Components[I];
           if (CurComp is TDataSet) and (CurComp<>MemTable) then
           begin
                Item:=LTV_Datasets.Items.Add;
                Item.Caption:= Format('%s.%s', [CurForm.Name, CurComp.Name]);
                Item.Data := CurComp;

                Item:=LTV_FromDataset.Items.Add;
                Item.Caption:= Format('%s.%s', [CurForm.Name, CurComp.Name]);
                Item.Data := CurComp;
           end;
      end;
 end;
begin
     // Mark as we are Filling the ListView
     IsFilling:=true;

     try
        // Build datasets Listview
        LTV_Datasets.Items.Clear;
        LTV_FromDataset.Items.Clear;
        for I := Screen.CustomFormCount - 1 downto 0 do
            AddDatasetsFromForm(Screen.CustomForms[I]);
{$IFNDEF LEVEL6}
        for I := Screen.DataModuleCount - 1 downto 0 do
            AddDatasetsFromForm(Screen.DataModules[I]);
{$ENDIF}
     finally
        //Un-Mark as we are Filling the ListView
        IsFilling:=false;
     end;
end;

{$IFNDEF LINUX}
procedure TfrmKbmMemTableDesigner.GetAliases;
var
   TempCursor:hDbiCur;
   DB_Description:DBDesc;
   Item:TListItem;
begin
     // Mark as we are Filling the ListView
     IsFilling:=true;

     try
        // Clear Alias Listview
        LTV_Alias.Items.Clear;

        Check(DbiOpenDatabaseList(TempCursor));
      {$IFDEF DOTNET}
        while (DbiGetNextRecord(TempCursor, dbiNOLOCK, DB_Description, nil) = DBIERR_NONE) do
        begin
             Item:=LTV_Alias.Items.Add;
             Item.Caption:=DB_Description.szName;
             Item.SubItems.Add(DB_Description.szPhyName);
        end;
      {$ELSE}
        while (DbiGetNextRecord(TempCursor, dbiNOLOCK, @DB_Description, nil) = DBIERR_NONE) do
        begin
             Item:=LTV_Alias.Items.Add;
             Item.Caption:=DB_Description.szName;
             Item.SubItems.Add(DB_Description.szPhyName);
        end;
       {$ENDIF}

        // Close the Cursor
        Check(DbiCloseCursor(TempCursor));
     finally
        //Un-Mark as we are Filling the ListView
        IsFilling:=false;
     end;

{
     // Selected first Item if Possible to fire the Onchange Event
     if LTV_Alias.Items.Count>0 then
     begin
          LTV_Alias.Items[0].Selected:=true;
          LTV_Alias.Items[0].Focused:=true;
     end;
}
end;
{$ENDIF}

{$IFNDEF LINUX}
procedure TfrmKbmMemTableDesigner.GetTables(DatabaseName: string);
var
   Tables:TStringList;
   Item:TListItem;
   TableNumber:integer;
begin
     //Mark as we are Filling the ListView
     IsFilling:=true;

     try
        //Clear Tables Listviews
        LTV_Tables.Items.Clear;
        LTV_FromTable.Items.Clear;

        //Tables Holder for GetTableNames
        Tables:=TStringList.Create;

        try
           //Get Table Names
           SES_Dummy.GetTableNames(DatabaseName,'',true,true, Tables);

           //Fill de Listview with the Tables Returned
           for TableNumber:=0 to Tables.Count-1 do
           begin
                Item:=LTV_Tables.Items.Add;
                Item.Caption:=Tables[TableNumber];

                Item:=LTV_FromTable.Items.Add;
                Item.Caption:=Tables[TableNumber];
           end;
        finally
           //Free the StringList
           Tables.Free;
        end;

     finally
        //Un-Mark as we are Filling the ListView
        IsFilling:=False;
     end;

     //Selected first ITem if Possible to fire the Onchange Event
     if LTV_Tables.Items.Count > 0 then
     begin
          LTV_Tables.Items[0].Selected:=true;
          LTV_Tables.Items[0].Focused:=true;

          LTV_FromTable.Items[0].Selected:=true;
          LTV_FromTable.Items[0].Focused:=true;
     end;

     RBT_FromTable.Enabled:=LTV_FromTable.Items.Count>0;
end;
{$ENDIF}

procedure TfrmKbmMemTableDesigner.GetActualStructure;
var
   i:integer;
   Item:TListItem;
begin
     //Mark As Filling
     IsFilling:=true;
     try
        //Clear the Listviews
        LTV_Structure.Items.Clear;
        LTV_Existing.Items.Clear;
        LTV_Sort.Items.Clear;

        //Fill the FieldDefs
        for i:=0 to MemTable.Fields.Count-1 do
        begin
             with LTV_Structure.Items.Add do
             begin
                  Caption:=MemTable.Fields.Fields[i].FieldName;
                  SubItems.Add(GetEnumName(Typeinfo(TFieldType),Ord(MemTable.Fields.Fields[i].DataType)));
                  SubItems.Add(IntToStr(MemTable.Fields.Fields[i].Size));
             end;

             // Possible sort fields not yet used.
             Item:=LTV_Existing.Items.Add;
             Item.Caption:=MemTable.Fields.Fields[i].FieldName;
             if IsInFieldNames(MemTable.SortFields,Item.Caption) then
             begin
                   with LTV_Sort.Items.Add do
                        Caption:=Item.Caption;
                   DeleteItem(Item);
             end;
        end;

     finally
        //Un-Mark As Filling
        IsFilling:=False;
     end;

     //Selected first Item if Possible to fire the Onchange Event
     if LTV_Structure.Items.Count>0 then
     begin
          LTV_Structure.Items[0].Selected:=true;
          LTV_Structure.Items[0].Focused:=true;

          LTV_Existing.Items[0].Selected:=true;
          LTV_Existing.Items[0].Focused:=true;
     end;

     //ActualStructure Panel
     PAN_ActualStructure.Enabled:=LTV_Structure.Items.Count>0;

     //Sort Panel
     PAN_Sort.Enabled:=LTV_Existing.Items.Count>0;
     BTN_Sort.Enabled:=false;

     //Force the Buttons Syncronization
     LTV_ExistingChange(Self,nil,ctState);
     LTV_SortChange(Self,nil,ctState);
end;

procedure TfrmKbmMemTableDesigner.CheckAvailData;
begin
     if MemTable.Fields.Count>0 then
        MemTable.Active:=true;

     //Sort Panel
     PAN_Sort.Enabled:=LTV_Existing.Items.Count>0;
     BTN_Sort.Enabled:=(LTV_Sort.Items.Count>0) and (MemTable.Active) and (MemTable.RecordCount>0);
     LTB_SortOptions.Enabled:=LTV_Sort.Items.Count>0;

     //Force the Buttons Synchronization
     LTV_ExistingChange(Self,nil,ctState);
     LTV_SortChange(Self,nil,ctState);

     if (MemTable.Active) and (MemTable.RecordCount>0) then
     begin
          PAN_DataDesign.Enabled:=true;
          DTS_DataDesign.DataSet:=MemTable;
          DTS_DataDesign.Enabled:=true;
          DTS_DataDesign.AutoEdit:=true;
          BTN_Save.Enabled:=true;
     end
     else
     begin
          PAN_DataDesign.Enabled:=false;
          DTS_DataDesign.DataSet:=nil;
          DTS_DataDesign.Enabled:=false;
          DTS_DataDesign.AutoEdit:=false;
          BTN_Save.Enabled:=false;
     end;
end;

{$IFDEF LINUX}
function CreateUniqueName(Dataset:TkbmCustomMemTable; FieldClass:TFIeldClass; FieldName:string; Field:TField):string;
var
   i1,i2:integer;
   s:string;
   unique:boolean;
begin
     for i1:=1 to MaxInt do
     begin
          s:=Format('%s%s%d',[FieldClass.ClassName,FieldName,i1]);

          // Check if unique.
          with Dataset.Owner do
          begin
               unique:=true;
               for i2:=0 to ComponentCount-1 do
               begin
                    if (Components[i2]<>Field) and (CompareText(Components[i2].Name,s)=0) then
                    begin
                         unique:=false;
                         break;
                    end;
               end;

               if unique then
               begin
                    Result:=s;
                    exit;
               end;
          end;
     end;
end;
{$ENDIF}


{$IFDEF DOTNET}

function GenerateName(Dataset: TDataset; FieldName: string;
  FieldClass: TFieldClass; Number: Integer): string;
var
  Fmt: string;

  procedure CrunchFieldName;
  var
    I: Integer;
  begin
    I := 1;
    while I <= Length(FieldName) do
    begin
      if FieldName[I] in ['A'..'Z','a'..'z','_','0'..'9'] then
        Inc(I)
      else if FieldName[I] in LeadBytes then
        Delete(FieldName, I, 2)
      else
        Delete(FieldName, I, 1);
    end;
  end;

begin
  CrunchFieldName;
  if (FieldName = '') or (FieldName[1] in ['0'..'9']) then
  begin
    if FieldClass <> nil then
      FieldName := FieldClass.ClassName + FieldName else
      FieldName := 'Field' + FieldName;
    if FieldName[1] = 'T' then Delete(FieldName, 1, 1);
    CrunchFieldName;
  end;
  Fmt := '%s%s%d';
  if Number < 2 then Fmt := '%s%s';
  Result := Format(Fmt, [Dataset.Name, FieldName, Number]);
end;


function CreateUniqueName(Dataset: TDataset; const FieldName: string;
  FieldClass: TFieldClass; Component: TComponent): string;
var
  I: Integer;

  function IsUnique(const AName: string): Boolean;
  var
    I: Integer;
  begin
    Result := False;
    with Dataset.Owner do
      for I := 0 to ComponentCount - 1 do
        if (Component <> Components[i]) and (CompareText(AName, Components[I].Name) = 0) then Exit;
    Result := True;
  end;

begin
  for I := 1 to MaxInt do
  begin
    Result := GenerateName(Dataset, FieldName, FieldClass, I);
    if IsUnique(Result) then Exit;
  end;
end;



{$ENDIF}

procedure TfrmKbmMemTableDesigner.CreateFields;
var
   i:integer;
   Field:TField;
begin
     MemTable.DeleteTable;
     with MemTable.FieldDefs do
     begin
          for i:=0 to Count-1 do
          begin
               Field:=Items[i].CreateField(MemTable.Owner,nil,Items[i].Name,false);
               try
                  Field.Origin:='';
{$IFNDEF LINUX}

                  Field.Name := {$IFNDEF DOTNET}DSDesign.{$ENDIF}CreateUniqueName(MemTable, Items[i].Name, TFieldClass(Items[i].ClassType), nil);
{$ELSE}
                  Field.Name := CreateUniqueName(MemTable, TFieldClass(Items[i].ClassType), Items[i].Name, nil);
{$ENDIF}
               except
                  Field.Free;
                  raise;
               end;
          end;
     end;
end;

{$IFNDEF LINUX}
procedure TfrmKbmMemTableDesigner.LoadStructure(TableName:string);
var
   Table:TTable;
begin
     //First We Create a Table that Will hold the Table
     Table:=TTable.Create(Self);
     try
        //Assign the Values to the Table
        Table.DatabaseName:=LTV_Alias.Selected.Caption;
        Table.TableName:=TableName;

        //Call the Procedure that Fills the fieldDefs
        with MemTable do
        begin
             MemTable.Active:=false;
             CreateTableAs(Table,[mtcpoStructure]);
        end;
        CreateFields;

     finally
        //Free the Table
        Table.Free;
     end;
     //Refresh the Actual Structure
     GetActualStructure;
end;
{$ENDIF}

procedure TfrmKbmMemTableDesigner.TransAll(Source,Dest:TListView);
var
   Item:TListItem;
   i:integer;
begin
     //Mark as filling
     IsFilling:=true;
     try
        for i:= 0 to Source.Items.Count-1 do
        begin
             Item:=Dest.Items.Add;
             Item.Caption := Source.Items[i].Caption;
        end;

        //Clear Existing
        Source.Items.Clear;
     finally
        //UnMark filling
        IsFilling:=false;
     end;

     if Dest.Items.Count > 0 then
     begin
          Dest.Items[0].Selected:=true;
          Dest.Items[0].Focused:=true;
     end;

     //Force the Buttons Syncronization
     LTV_ExistingChange(Self,nil,ctState);
     LTV_SortChange(Self,nil,ctState);
end;

procedure TfrmKbmMemTableDesigner.CopyItem(SourceItem:TListITem; Dest:TListView);
var
   Item:TListItem;
begin
     Item:=Dest.Items.Add;
     Item.Caption:=SourceItem.Caption;
     DeleteItem(SourceItem);

     Item.Selected:=true;
     Item.MakeVisible{$IFNDEF LINUX}(false){$ENDIF};

     //Force the Buttons Sincronization.
     LTV_ExistingChange(Self,nil,ctState);
     LTV_SortChange(Self,nil,ctState);
end;

procedure TfrmKbmMemTableDesigner.StoreSortSetup;
var
   i:integer;
   s,a:string;
   CompareOptions:TkbmMemTableCompareOptions;
begin
     // Store sort fields.
   try
     if LTV_Sort.Items.Count>0 then
     begin
          a:='';
          for i:=0 to LTV_Sort.Items.Count-1 do
          begin
               s:=s+a+LTV_Sort.Items[i].Caption;
               a:=';';
          end;
          MemTable.SortFields:=s;
     end;
    except
      showmessage ('err 1');
    end;

  try
     // Store sort options.
     CompareOptions := [];
     if LTB_SortOptions.Items.Count>0 then
     begin
          for i:=ord(Low(TkbmMemTableCompareOption)) to ord(High(TkbmMemTableCompareOption)) do
              if LTB_SortOptions.Checked[i] then
                 CompareOptions := CompareOptions + [TkbmMemTableCompareOption(i)];
          MemTable.SortOptions:=CompareOptions;
     end;
    except
      showmessage ('err 2');
    end;

   try
     {$IFDEF DOTNET}
     Designer.Modified;
     {$ELSE}
     Designer.Modified;
     {$ENDIF}
    except
      showmessage ('err 3');
    end;

end;

procedure TfrmKbmMemTableDesigner.CopyDataSet(Source: TDataSet; Dest: TDataSet;Visual: boolean);
var
   i:integer;
begin
     if Visual then
     begin
          //Progress
          LAB_Progress.Visible:=true;
          PRO_Records.Position:=0;
          PRO_Records.Max:=Source.RecordCount;
          PRO_Records.Visible:=true;
          Application.ProcessMessages;
     end;

     //First Record of Source
     Source.First;

     //Read all the Records
     TkbmMemTable(Dest).IgnoreReadOnly:=true;
     try
        while not Source.EOF do
        begin
             try
                Dest.Insert;
                for i:=0 to Source.Fields.Count-1 do
                begin
                     try
                        Dest.FieldByName(Source.Fields[i].FieldName).Value:=Source.Fields[i].Value;
                     except
                        on E: Exception do
                        begin
                             MessageDlg('An error ocurred while trying to append a tecord to the memory table: '+E.Message,mtError,[mbOk],0);
                             Dest.Cancel;
                             exit;
                        end;
                     end;
                end;
                Dest.Post;
             except
                on E: Exception do
                begin
                   MessageDlg('An error ocurred while trying to append a tecord to the memory table: '+E.Message,mtError,[mbOk],0);
                   Dest.Cancel;
                   exit;
                end;
             end;

             if Visual then PRO_Records.Position:=PRO_Records.Position + 1;

             //Next Record
             Source.Next;
        end;
     finally
        TkbmMemTable(Dest).IgnoreReadOnly:=false;
     end;

     If Visual then
     begin
          //Progress
          LAB_Progress.Visible:=false;
          PRO_Records.Visible:=false;
     end;
end;

procedure TfrmKbmMemTableDesigner.FormCreate(Sender: TObject);
begin
     //Set the Active Page
     PGC_Options.ActivePage := TBS_BorrowStructure;
end;

procedure TfrmKbmMemTableDesigner.FormShow(Sender: TObject);
var
   i:integer;
begin
     if MemTable <> nil then
     begin
          //PageControl
          PGC_Options.Enabled:=true;

          //Caption
          Caption:=Format('%s  [%s]',[KbmMemTableDesignerVersion,MemTable.Name]);

          //TBS_BorrowStructure
          //First We get the Aliases
{$IFNDEF LINUX}
          SES_Dummy.Active := True;
          GetAliases;

          {Depending on the Amount of Items}
          if LTV_Alias.Items.Count > 0 then
          begin
               //Panels
               PAN_BorrowStructure.Enabled := True;

               //ListViews
               //Tables ListView Filled on the Onchange Event of the LTV_Alias Listview
               //buttons Arranged by the Onchange Event Also
          end
          else
          begin
               //ListViews
               LTV_Alias.Items.Clear;
               LTV_Tables.Items.Clear;

               //Panels
               PAN_BorrowStructure.Enabled:=false;

               //Buttons
               BTN_GetStructure.Enabled:=false;
               BTN_Refresh.Enabled:=false;
          end;
{$ENDIF}

          GetDatasets;
          
          //TBS_ActualStructure
          GetActualStructure;

          //Panel Controled by the GetActualStructure Procedure

          //TBS_Data
          //Panels
          PAN_FromTable.Enabled:=false;

          //RadioButtons &checkBoxes
          RBT_FromFile.Checked:=true;
          CHK_Binary.Enabled:=true;
          CHK_Binary.Checked:=true;
          CHK_OnlyData.Enabled:=true;
          CHK_OnlyData.Checked:=true;

          //RBT_FromTable Set on the GetTables Procedure

          //Edits
          EDT_File.Text:=TKbmMemTable(MemTable).PersistentFile;

          //Buttons
          BTN_SelectFileName.Enabled:=true;
          BTN_Load.Enabled:=FileExists(EDT_File.Text);

          //ProgressBar
          PRO_Records.Visible:=false;
          LAB_Progress.Visible:=false;

          //TBS_DataDesign
          CheckAvailData;

          //TBS_Sort
          //Controled by the GetActualStructure

          //SortOptions
          LTB_SortOptions.Items.Clear;
          for i:=ord(Low(TkbmMemTableCompareOption)) to ord(High(TkbmMemTableCompareOption)) do
              LTB_SortOptions.Items.Add(GetEnumName(Typeinfo(TkbmMemTableCompareOption),i));
     end
     else
     begin
          //If the Owner is not correctly passed then Disable All
          //Caption
          Caption:=Format('%s  (MemTable not found)',[KbmMemTableDesignerVersion]);

          //PageControl
          PGC_Options.Enabled:=false;

          //TBS_BorrowStructure
          //ListViews}
{$IFNDEF LINUX}
          LTV_Alias.Items.Clear;
          LTV_Tables.Items.Clear;
{$ENDIF}

          //Panels
          PAN_BorrowStructure.Enabled:=false;

          //Buttons
          BTN_GetStructure.Enabled:=false;
          BTN_Refresh.Enabled:=false;

          //TBS_ActualStructure
          PAN_ActualStructure.Enabled:=false;

          //TBS_Data
          //Panels
          PAN_Data.Enabled:=false;

          //Edits
          EDT_File.Text:='';

          //CheckBoxes
          CHK_Binary.Checked:=false;
          CHK_Binary.Enabled:=false;
          CHK_OnlyData.Checked:=false;
          CHK_OnlyData.Enabled:=false;

          //Listviews
          LTV_FromTable.Items.Clear;

          //Buttons
          BTN_Load.Enabled:=false;
          BTN_SelectFileName.Enabled:=false;
          BTN_Save.Enabled:=false;

          //ProgressBar
          PRO_Records.Visible:=false;
          LAB_Progress.Visible:=false;

          //TBS_DataDesign
          PAN_DataDesign.Enabled:=false;
          DTS_DataDesign.DataSet:=nil;
          DTS_DataDesign.Enabled:=false;
          DTS_DataDesign.AutoEdit:=false;

          //TBS_Sort
          //Panels
          PAN_Sort.Enabled:=false;

          //Listviews
          LTV_Existing.Items.Clear;
          LTV_Sort.Items.Clear;

          //Listboxes
          LTB_SortOptions.Items.Clear;
          LTB_SortOptions.Enabled:=false;

          //Buttons
          BTN_Sort.Enabled:=false;
          BTN_SEL_All.Enabled:=false;
          BTN_SEL_Selected.Enabled:=false;
          BTN_UNS_Selected.Enabled:=false;
          BTN_UNS_All.Enabled:=false;
          BTN_ORD_First.Enabled:=false;
          BTN_ORD_Last.Enabled:=false;
          BTN_ORD_Plus.Enabled:=false;
          BTN_ORD_Minus.Enabled:=false;
     end;
end;

procedure TfrmKbmMemTableDesigner.FormClose(Sender: TObject;var Action: TCloseAction);
begin
     try
        //Close the Session
      try
        StoreSortSetup;
      except
        showmessage ('jup err');
      end;
{$IFNDEF LINUX}
        SES_Dummy.Active:=false;
{$ENDIF}
     finally
        Action:=caFree;
     end;
end;

{$IFNDEF LINUX}
procedure TfrmKbmMemTableDesigner.LTV_AliasChange(Sender: TObject;Item: TListItem; Change: TItemChange);
begin
     if IsFilling then exit;

     //If no Item Selected then Clear Tables Listview, Disable Button and Exit
     if LTV_Alias.Selected = nil then
     begin
          //Listview
          LTV_Tables.Items.Clear;

          //Buttons
          BTN_GetStructure.Enabled:=false;
          exit;
     end;

     //Fill the Tables Listview
     GetTables(LTV_Alias.Selected.Caption);

     //Button only Active if there is a Table Selected
     BTN_GetStructure.Enabled := LTV_Tables.Selected <> nil;
end;

procedure TfrmKbmMemTableDesigner.LTV_TablesChange(Sender: TObject;Item: TListItem; Change: TItemChange);
begin
     if IsFilling then exit;

     //Button only Active if there is a Table Selected
     BTN_GetStructure.Enabled := LTV_Tables.Selected <> nil;
end;
{$ENDIF}

procedure TfrmKbmMemTableDesigner.BTN_GetStructureClick(Sender: TObject);
var
   ds:TDataset;
begin
{$IFNDEF LINUX}
     if pcBorrowFrom.ActivePage=tsBDEAlias then
     begin
          //General Procedure for Loading a Structure
          if LTV_Tables.Selected<>nil then LoadStructure(LTV_Tables.Selected.Caption);
     end
     else
{$ENDIF}
     if pcBorrowFrom.ActivePage=tsTDataset then
     begin
          if LTV_Datasets.Selected<>nil then
          begin
               ds:=TDataSet(LTV_Datasets.Selected.Data);
               if ds<>nil then
               begin
	            Memtable.Active:=False;
                    Memtable.CreateTableAs(ds,[mtcpoStructure,mtcpoProperties,mtcpoLookup]);
                    CreateFields;
                    GetActualStructure;
               end;
          end;
     end;

     //Show the Active Structure
     PGC_Options.ActivePage := TBS_ActualStructure;
end;

procedure TfrmKbmMemTableDesigner.RBT_FromFileClick(Sender: TObject);
begin
     //Activate the Items
     PAN_FromTable.Enabled:=false;
     PAN_FromDataset.Enabled:=false;
     BTN_SelectFileName.Enabled:=true;
     BTN_Load.Enabled := FileExists(EDT_File.Text);
     CHK_Binary.Enabled:=true;
     CHK_OnlyData.Enabled:=true;
end;

procedure TfrmKbmMemTableDesigner.RBT_FromTableClick(Sender: TObject);
begin
     //Activate the Items
     PAN_FromTable.Enabled:=true;
     PAN_FromDataset.Enabled:=false;
     BTN_SelectFileName.Enabled:=false;
     BTN_Load.Enabled:=LTV_FromTable.Selected <> nil;
     CHK_Binary.Enabled:=false;
     CHK_OnlyData.Enabled:=false;
end;

procedure TfrmKbmMemTableDesigner.RBT_FromDatasetClick(Sender: TObject);
begin
     //Activate the Items
     PAN_FromDataset.Enabled:=true;
     BTN_SelectFileName.Enabled:=false;
     PAN_FromTable.Enabled:=false;
     BTN_Load.Enabled:=LTV_FromDataset.Selected <> nil;
     CHK_Binary.Enabled:=false;
     CHK_OnlyData.Enabled:=false;
end;

procedure TfrmKbmMemTableDesigner.LTV_FromTableChange(Sender: TObject;Item: TListItem; Change: TItemChange);
begin
     if (IsFilling) then exit;
     if not RBT_FromTable.Checked then exit;

     //Button only Active if there is a Table Selected
     BTN_Load.Enabled:=LTV_FromTable.Selected <> nil;
end;

procedure TfrmKbmMemTableDesigner.BTN_SelectFileNameClick(Sender: TObject);
begin
     DLG_SelectFile.InitialDir := ExtractFileDir(EDT_File.Text);
     DLG_SelectFile.FileName := ExtractFileName(EDT_File.Text);

     if DLG_SelectFile.Execute then
     begin
          EDT_File.Text := DLG_SelectFile.FileName;
          TkbmMemTable(MemTable).PersistentFile := DLG_SelectFile.FileName;
     end;

     BTN_Load.Enabled := FileExists(EDT_File.Text);
end;

procedure TfrmKbmMemTableDesigner.BTN_LoadClick(Sender: TObject);
var
{$IFNDEF LINUX}
   Table:TTable;
{$ENDIF}
   ds:TDataset;
   DummyTable:TKbmMemTable;
   Fmt:TkbmCustomStreamFormat;
begin
     //Depending on What method..
     if RBT_FromFile.Checked then
     begin
          //Empty the Table
          MemTable.Active:=true;
          TkbmMemTable(MemTable).EmptyTable;

          DummyTable:=TKbmMemTable.Create(Self);
          try
             if CHK_Binary.Checked then
                Fmt:=TkbmBinaryStreamFormat.Create(nil)
             else
                Fmt:=TkbmCSVStreamFormat.Create(nil);
             try
                DummyTable.LoadFromFileViaFormat(EDT_File.Text,Fmt);
             finally
                Fmt.Free;
             end;

             if not CHK_OnlyData.Checked then
             with Memtable do
             begin
                  Active := False;
                  CreateTableAs(DummyTable,[mtcpoStructure]);
                  CreateFields;
             end;

             //Activate the MemTable
             MemTable.Active:=true;

             //Copy the Table
             CopyDataSet(DummyTable,MemTable,True);
          finally
             //Free Dummy Table
             DummyTable.Free;
          end;

          //Get the Structure
          GetActualStructure;
          CheckAvailData;

          MemTable.First;

          //Activate de DataDesgin TabSheet
          PGC_Options.ActivePage := TBS_DataDesign;
     end
     else
     begin
          //Empty the Table
          if MemTable.active then
             TkbmMemTable(MemTable).EmptyTable;

{$IFNDEF LINUX}
          // Check if from table, then make table access.
          if RBT_FromTable.Checked then
          begin
               //Create a Table that will hold the Table
               Table:=TTable.Create(Self);
               try
                  //Assign the Values to the Table
                  Table.DatabaseName := LTV_Alias.Selected.Caption;
                  Table.TableName := LTV_FromTable.Selected.Caption;

                  //Load the Structure
                  LoadStructure(LTV_FromTable.Selected.Caption);

                  //Activate the MemTable
                  MemTable.Active:=true;

                  try
                     Table.Active:=true;
                     Table.First;
                  except
                     MessageDlg('An error ocurred while trying to open the source table.',mtError,[mbOk],0);
                     exit;
                  end;

                  //Copy the Table
                  CopyDataSet(Table,MemTable,True);

               finally
                  //Free the Table
                  Table.Free;
               end;
          end
          else
          begin
{$ENDIF}
               ds:=TDataSet(LTV_FromDataset.Selected.Data);
               if ds<>nil then
               begin
	            Memtable.Active:=False;
                    MemTable.LoadFromDataSet(ds,[mtcpoStructure,mtcpoProperties,mtcpoLookup]);
                    GetActualStructure;
               end;
{$IFNDEF LINUX}
          end;
{$ENDIF}

          CheckAvailData;
          MemTable.First;

          //Activate the DataDesgin TabSheet
          PGC_Options.ActivePage := TBS_DataDesign;
     end;
end;

procedure TfrmKbmMemTableDesigner.BTN_SaveClick(Sender: TObject);
var
   SaveBinary:boolean;
   Fmt:TkbmCustomStreamFormat;
begin
     if not DLG_SaveFile.Execute then exit;

     //Get binary Option
     SaveBinary:=CHK_Binary.Checked;

     //Saving the File
     if SaveBinary then
        Fmt:=TkbmBinaryStreamFormat.Create(nil)
     else
        Fmt:=TkbmCSVStreamFormat.Create(nil);
     try
        TkbmMemTable(MemTable).SaveToFileViaFormat(DLG_SaveFile.FileName,Fmt);
     finally
        Fmt.Free;
     end;

     //Refresh PersistentFile Values
     EDT_File.Text := DLG_SaveFile.FileName;
     TkbmMemTable(MemTable).PersistentFile := DLG_SaveFile.FileName;
end;

procedure TfrmKbmMemTableDesigner.BTN_RefreshClick(Sender: TObject);
begin
     FormShow(Self);
end;

procedure TfrmKbmMemTableDesigner.LTV_ExistingChange(Sender: TObject;Item: TListItem; Change: TItemChange);
var
   ListItem:TListItem;
begin
     if (IsFilling) then exit;

     BTN_Sort.Enabled := LTV_Sort.Items.Count > 0;
     LTB_SortOptions.Enabled := LTV_Sort.Items.Count > 0;

     //Get the Item Selected
     ListItem := LTV_Existing.Selected;
     if ListItem=nil then
     begin
          BTN_SEL_Selected.Enabled:=false;
          BTN_SEL_All.Enabled := LTV_Existing.Items.Count > 0;
          exit;
     end;

     //Adjust Buttons
     BTN_SEL_All.Enabled := LTV_Existing.Items.Count > 0;
     BTN_SEL_Selected.Enabled:=true;
end;

procedure TfrmKbmMemTableDesigner.LTV_SortChange(Sender: TObject;Item: TListItem; Change: TItemChange);
var
   ListItem:TListItem;
begin
     if (IsFilling) then exit;

     BTN_Sort.Enabled := LTV_Sort.Items.Count > 0;
     LTB_SortOptions.Enabled := LTV_Sort.Items.Count > 0;

     //Get the Item Selected
     ListItem:=LTV_Sort.Selected;
     if ListItem = nil then
     begin
          BTN_UNS_Selected.Enabled:=false;
          BTN_UNS_All.Enabled:=LTV_Sort.Items.Count > 0;
          BTN_ORD_First.Enabled:=false;
          BTN_ORD_Last.Enabled:=false;
          BTN_ORD_Plus.Enabled:=false;
          BTN_ORD_Minus.Enabled:=false;
          exit;
     end;

     //Adjust Buttons
     BTN_UNS_Selected.Enabled:=true;
     BTN_UNS_All.Enabled := LTV_Sort.Items.Count > 0;
     BTN_ORD_First.Enabled := ListItem.Index <> 0;
     BTN_ORD_Last.Enabled := (LTV_Sort.Items.Count > 0) and (ListItem.Index <> (LTV_Sort.Items.Count-1));
     BTN_ORD_Minus.Enabled := ListItem.Index < (LTV_Sort.Items.Count - 1);
     BTN_ORD_Plus.Enabled := ListItem.Index <> 0;
end;

procedure TfrmKbmMemTableDesigner.BTN_SEL_AllClick(Sender: TObject);
begin
     //Procedure To Copy All Items
     TransAll(LTV_Existing,LTV_Sort);
     StoreSortSetup;
end;

procedure TfrmKbmMemTableDesigner.BTN_UNS_AllClick(Sender: TObject);
begin
     //Procedure To Copy All Items
     TransAll(LTV_Sort,LTV_Existing);
     StoreSortSetup;
end;

procedure TfrmKbmMemTableDesigner.BTN_SEL_SelectedClick(Sender: TObject);
begin
     //Procedure To Copy One Item
     CopyItem(LTV_Existing.Selected,LTV_Sort);
     StoreSortSetup;
end;

procedure TfrmKbmMemTableDesigner.BTN_UNS_SelectedClick(Sender: TObject);
begin
     //Procedure To Copy One Item
     CopyItem(LTV_Sort.Selected,LTV_Existing);
     StoreSortSetup;
end;

procedure TfrmKbmMemTableDesigner.BTN_ORD_LastClick(Sender: TObject);
begin
     SelectFull(MoveItem(LTV_Sort.Selected,LTV_Sort.ITems.Count));
     StoreSortSetup;
end;

procedure TfrmKbmMemTableDesigner.BTN_ORD_FirstClick(Sender: TObject);
begin
     SelectFull(MoveItem(LTV_Sort.Selected,0));
     StoreSortSetup;
end;

procedure TfrmKbmMemTableDesigner.BTN_ORD_MinusClick(Sender: TObject);
var
   ItemDest:TListItem;
begin
     ItemDest := LTV_Sort.Items[LTV_Sort.Selected.Index + 1];
     SwapItems(LTV_Sort.Selected,ItemDest);
     SelectFull(ItemDest);
     StoreSortSetup;
end;

procedure TfrmKbmMemTableDesigner.BTN_ORD_PlusClick(Sender: TObject);
var
   ItemDest:TListItem;
begin
     ItemDest := LTV_Sort.Items[LTV_Sort.Selected.Index - 1];
     SwapItems(LTV_Sort.Selected,ItemDest);
     SelectFull(ItemDest);
     StoreSortSetup;
end;

procedure TfrmKbmMemTableDesigner.BTN_SortClick(Sender: TObject);
var
   i:integer;
   CompareOptions:TkbmMemTableCompareOptions;
   SortFields:string;
begin
     MemTable.Active:=true;

     //Init CompareOptions
     if LTB_SortOptions.Items.Count<=0 then exit;
     CompareOptions := [];
     for i:=ord(Low(TkbmMemTableCompareOption)) to ord(High(TkbmMemTableCompareOption)) do
         if LTB_SortOptions.Checked[i] then
            CompareOptions := CompareOptions + [TkbmMemTableCompareOption(i)];

     //Init Sort Fields
     SortFields := '';
     for i:=0 to LTV_Sort.Items.Count - 1 do
     begin
          SortFields := SortFields + LTV_Sort.Items[i].Caption;
          if i<>LTV_Sort.Items.Count - 1 then SortFields := SortFields + ';';
     end;

     //Sort the Table
     TKbmMemTable(MemTable).SortOn(SortFields,CompareOptions);
     MemTable.First;

     //Activate de DataDesgin TabSheet
     PGC_Options.ActivePage := TBS_DataDesign;
end;

procedure TfrmKbmMemTableDesigner.LTV_DatasetsChange(Sender: TObject;
  Item: TListItem; Change: TItemChange);
begin
     //Button only Active if there is a Table Selected
     BTN_GetStructure.Enabled := LTV_Datasets.Selected <> nil;
end;

procedure TfrmKbmMemTableDesigner.LTV_FromDatasetChange(Sender: TObject;
  Item: TListItem; Change: TItemChange);
begin
     if (IsFilling) then exit;
     if not RBT_FromDataset.Checked then exit;

     //Button only Active if there is a dataset Selected
     BTN_Load.Enabled:=LTV_FromDataset.Selected <> nil;
end;
{$ELSE}
implementation
{$ENDIF}

end.
