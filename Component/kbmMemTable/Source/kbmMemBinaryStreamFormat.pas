unit kbmMemBinaryStreamFormat;

interface

{$include kbmMemTable.inc}

// =========================================================================
// Binary stream format for kbmMemTable v. 3.xx+
//
// Copyright 1999-2005 Kim Bo Madsen/Optical Services - Scandinavia
// All rights reserved.
//
// LICENSE AGREEMENT
// PLEASE NOTE THAT THE LICENSE AGREEMENT HAS CHANGED!!! 16. Feb. 2000
//
// You are allowed to use this component in any project for free.
// You are NOT allowed to claim that you have created this component or to
// copy its code into your own component and claim that it was your idea.
//
// -----------------------------------------------------------------------------------
// IM OFFERING THIS FOR FREE FOR YOUR CONVINIENCE, BUT
// YOU ARE REQUIRED TO SEND AN E-MAIL ABOUT WHAT PROJECT THIS COMPONENT (OR DERIVED VERSIONS)
// IS USED FOR !
// -----------------------------------------------------------------------------------
//
// -----------------------------------------------------------------------------------
// PLEASE NOTE THE FOLLOWING ADDITION TO THE LICENSE AGREEMENT:
// If you choose to use this component for generating middleware libraries (with similar
// functionality as dbOvernet, Midas, Asta etc.), those libraries MUST be released as
// Open Source and Freeware!
// -----------------------------------------------------------------------------------
//
// You dont need to state my name in your software, although it would be
// appreciated if you do.
//
// If you find bugs or alter the component (f.ex. see suggested enhancements
// further down), please DONT just send the corrected/new code out on the internet,
// but instead send it to me, so I can put it into the official version. You will
// be acredited if you do so.
//
//
// DISCLAIMER
// By using this component or parts theirof you are accepting the full
// responsibility of the use. You are understanding that the author cant be
// made responsible in any way for any problems occuring using this component.
// You also recognize the author as the creator of this component and agrees
// not to claim otherwize!
//
// Please forward corrected versions (source code ONLY!), comments,
// and emails saying you are using it for this or that project to:
//            kbm@optical.dk
//
// Latest version can be found at:
//            http://www.onelist.com/community/memtable

//=============================================================================
// Remove the remark on the next lines if to keep binary file compatibility
// between different versions of TkbmMemTable.
//{$define BINARY_FILE_230_COMPATIBILITY}
//{$define BINARY_FILE_200_COMPATIBILITY}
//{$define BINARY_FILE_1XX_COMPATIBILITY}
//=============================================================================

// History.
// Per v. 3.00, the stream formats will each have their own history.
//
// 3.00a alpha
//       Initial v. 3.00 binary stream format release based on the sources of v. 2.53b.
//
// 3.00b beta
//       Fixed Floating point error in calculation of progress.
//       Bug reported by Fred Schetterer (yahoogroups@shaw.ca)
//
// 3.00c beta
//       Fixed bug not setting record flag to record being part of table.
//       This would result in massive memory leaks.
//
// 3.00  Final
//       Added BufferSize property (default 16384) which controls the internal
//       read and write buffer size. Suggested by Ken Schafer (prez@write-brain.com)

uses
  kbmMemTable,Classes,DB,
{$include kbmMemRes.inc}
{$IFDEF DOTNET}
  System.Runtime.InteropServices,
{$ENDIF}
  SysUtils;

type
  TkbmStreamFlagUsingIndex  = (sfSaveUsingIndex);
  TkbmStreamFlagUsingIndexs = set of TkbmStreamFlagUsingIndex;

  TkbmStreamFlagDataTypeHeader = (sfSaveDataTypeHeader,sfLoadDataTypeHeader);
  TkbmStreamFlagDataTypeHeaders = set of TkbmStreamFlagDataTypeHeader;

  TkbmCustomBinaryStreamFormat = class(TkbmCustomStreamFormat)
  private
     Writer:TWriter;
     Reader:TReader;

     FUsingIndex:TkbmStreamFlagUsingIndexs;
     FDataTypeHeader:TkbmStreamFlagDataTypeHeaders;
     FBuffSize:LongInt;

     FileVersion:integer;
     InitIndexDef:boolean;

     ProgressCnt:integer;
     StreamSize:longint;
     procedure SetBuffSize(ABuffSize:LongInt);
  protected
     function GetVersion:string; override;

     procedure BeforeSave(ADataset:TkbmCustomMemTable); override;
     procedure SaveDef(ADataset:TkbmCustomMemTable); override;
     procedure SaveData(ADataset:TkbmCustomMemTable); override;
     procedure AfterSave(ADataset:TkbmCustomMemTable); override;

     procedure BeforeLoad(ADataset:TkbmCustomMemTable); override;
     procedure LoadDef(ADataset:TkbmCustomMemTable); override;
     procedure LoadData(ADataset:TkbmCustomMemTable); override;
     procedure AfterLoad(ADataset:TkbmCustomMemTable); override;

     procedure DetermineLoadFieldIndex(ADataset:TkbmCustomMemTable; ID:string; FieldCount:integer; OrigIndex:integer; var NewIndex:integer; Situation:TkbmDetermineLoadFieldsSituation); override;
     
     property sfUsingIndex:TkbmStreamFlagUsingIndexs read FUsingIndex write FUsingIndex;
     property sfDataTypeHeader:TkbmStreamFlagDataTypeHeaders read FDataTypeHeader write FDataTypeHeader;
     property BufferSize:LongInt read FBuffSize write SetBuffSize;
  public
     constructor Create(AOwner:TComponent); override;
  end;

  TkbmBinaryStreamFormat = class(TkbmCustomBinaryStreamFormat)
  published
     property Version;
     property sfUsingIndex;
     property sfData;
     property sfCalculated;
     property sfLookup;
     property sfNonVisible;
     property sfBlobs;
     property sfDef;
     property sfIndexDef;
     property sfFiltered;
     property sfIgnoreRange;
     property sfIgnoreMasterDetail;
     property sfDeltas;
     property sfDontFilterDeltas;
     property sfAppend;
     property sfFieldKind;
     property sfFromStart;
     property sfDataTypeHeader;

     property OnBeforeLoad;
     property OnAfterLoad;
     property OnBeforeSave;
     property OnAfterSave;
     property OnCompress;
     property OnDeCompress;

     property BufferSize;
  end;

{$ifdef LEVEL3}
procedure Register;
{$endif}

implementation

const
  // Binary file magic word.
  kbmBinaryMagic = '@@BINARY@@';

  // Current file versions. V. 1.xx file versions are considered 100, 2.xx are considered 2xx etc.
  kbmBinaryFileVersion = 251;
  kbmDeltaVersion = 200;

type
  TkbmProtCustomMemTable = class(TkbmCustomMemTable);
  TkbmProtCommon = class(TkbmCommon);

function TkbmCustomBinaryStreamFormat.GetVersion:string;
begin
     Result:='3.00';
end;

constructor TkbmCustomBinaryStreamFormat.Create(AOwner:TComponent);
begin
     inherited;
     FUsingIndex:=[sfSaveUsingIndex];
     FDataTypeHeader:=[sfSaveDataTypeHeader,sfLoadDataTypeHeader];
     FBuffSize:=16384;
end;

procedure TkbmCustomBinaryStreamFormat.SetBuffSize(ABuffSize:LongInt);
begin
     if ABuffSize<16384 then ABuffSize:=16384;
     FBuffSize:=ABuffSize;
end;

procedure TkbmCustomBinaryStreamFormat.BeforeSave(ADataset:TkbmCustomMemTable);
begin
     inherited;

     Writer:=TWriter.Create(WorkStream,FBuffSize);
     Writer.WriteSignature;

{$IFNDEF BINARY_FILE_1XX_COMPATIBILITY}
     Writer.WriteInteger(kbmBinaryFileVersion);
{$ENDIF}
end;

procedure TkbmCustomBinaryStreamFormat.AfterSave(ADataset:TkbmCustomMemTable);
begin
     Writer.FlushBuffer;
     Writer.Free;
     Writer:=nil;
     ADataset.OverrideActiveRecordBuffer:=nil;
     inherited;
end;

procedure TkbmCustomBinaryStreamFormat.SaveDef(ADataset:TkbmCustomMemTable);
var
   i:integer;
   nf:integer;
begin
     // Write fielddefinitions.
     nf:=ADataSet.FieldCount;

     Writer.WriteListBegin;
     if (sfSaveDef in sfDef) then
     begin
          for i:=0 to nf-1 do
          begin
               if SaveFields[i]>=0 then
               begin
                    Writer.WriteString(ADataSet.Fields[i].FieldName);
                    Writer.WriteString(FieldTypeNames[ADataSet.Fields[i].DataType]);
                    Writer.WriteInteger(ADataSet.Fields[i].Size);
                    Writer.WriteString(ADataSet.Fields[i].DisplayName);
{$IFDEF DOTNET}
                    if ADataSet.Fields[i].EditMask = nil then
                       Writer.WriteString('')
                    else
{$ENDIF}
                        Writer.WriteString(ADataSet.Fields[i].EditMask);
                    Writer.WriteInteger(ADataSet.Fields[i].DisplayWidth);
                    Writer.WriteBoolean(ADataSet.Fields[i].Required);
                    Writer.WriteBoolean(ADataSet.Fields[i].ReadOnly);

                    // New for 2.50i BinaryFileVersion 250
                    if sfSaveFieldKind in sfFieldKind then
                       Writer.WriteString(FieldKindNames[ord(ADataSet.Fields[i].FieldKind)])
                    else
                        Writer.WriteString(FieldKindNames[0]); //fkData.

                    // New for 2.50o2 BinaryFileVersion 251
{$IFDEF LEVEL4}
 {$IFDEF DOTNET}
                    if ADataSet.Fields[i].DefaultExpression = nil then
                       Writer.WriteString('')
                    else
 {$ENDIF}
                        Writer.WriteString(ADataSet.Fields[i].DefaultExpression);
{$ELSE}
                    Writer.WriteString('');
{$ENDIF}
               end;
          end;
     end;
     Writer.WriteListEnd;

{$IFNDEF BINARY_FILE_1XX_COMPATIBILITY}
     // Save index definitions.
     Writer.WriteListBegin;
     if sfSaveIndexDef in sfIndexDef then
     begin
          for i:=0 to ADataSet.IndexDefs.Count-1 do
              with ADataSet.IndexDefs.Items[i] do
              begin
                   Writer.WriteString(Name);
                   Writer.WriteString(Fields);
 {$IFNDEF LEVEL3}
                   Writer.WriteString(DisplayName);
 {$ELSE}
                   Writer.WriteString(Name);
 {$ENDIF}
                   Writer.WriteBoolean(ixDescending in Options);
                   Writer.WriteBoolean(ixCaseInSensitive in Options);
 {$IFNDEF LEVEL3}
                   Writer.WriteBoolean(ixNonMaintained in Options);
 {$ELSE}
                   Writer.WriteBoolean(false);
 {$ENDIF}
                   Writer.WriteBoolean(ixUnique in Options);
              end;
     end;
     Writer.WriteListEnd;
{$ENDIF}
end;

procedure TkbmCustomBinaryStreamFormat.SaveData(ADataset:TkbmCustomMemTable);
var
   i,j,cnt:integer;
   nf:integer;
   Accept:boolean;
   NewestVersion:boolean;
   pRec:PkbmRecord;
   UsingIndex:boolean;
{$IFDEF DOTNET}
   ARec,Rec:TKbmRecord;
{$ENDIF}
begin
     // Write fielddefinitions.
     nf:=ADataSet.FieldCount;

     // Write datatypes as a kind of header.
     if sfSaveDataTypeHeader in sfDataTypeHeader then
     begin
          // Count number of fields actually saved.
          j:=0;
          for i:=0 to nf-1 do
              if SaveFields[i]>=0 then inc(j);

          // Start writing header.
          Writer.WriteListBegin;
          Writer.WriteInteger(j);
          for i:=0 to nf-1 do
          begin
               if SaveFields[i]>=0 then
                  Writer.WriteInteger(ord(ADataSet.Fields[i].DataType));
          end;
          Writer.WriteListEnd;
     end;

     // Write all records
     ADataSet.SaveCount := 0;
     ADataSet.SavedCompletely:=true;
     Writer.WriteListBegin;

     // Check if to write according to current index or not.
     UsingIndex:=sfSaveUsingIndex in FUsingIndex;
     if UsingIndex then
        cnt:=ADataSet.CurIndex.References.Count
     else
         cnt:=TkbmProtCommon(ADataSet.Common).FRecords.Count;

     for j:=0 to cnt-1 do
     begin
          // Check if to save more.
          if (ADataSet.SaveLimit>0) and (ADataSet.SaveCount>=ADataSet.SaveLimit) then
          begin
               ADataSet.SavedCompletely:=false;
               break;
          end;

          // Check if to invoke progress event if any.
          if (j mod 100)=0 then ADataSet.Progress(trunc((j/cnt)*100),mtpcSave);

          // Setup which record to look at.
          if UsingIndex then
             ADataSet.OverrideActiveRecordBuffer:=PkbmRecord(ADataSet.CurIndex.References.Items[j])
          else
             ADataSet.OverrideActiveRecordBuffer:=PkbmRecord(TkbmProtCommon(ADataSet.Common).FRecords.Items[j]);
          if (ADataSet.OverrideActiveRecordBuffer=nil) then continue;

          // Calculate fields.
          ADataSet.__ClearCalcFields({$IFNDEF DOTNET}PChar(ADataSet.OverrideActiveRecordBuffer){$ELSE}ADataSet.OverrideActiveRecordBuffer{$ENDIF});
          ADataSet.__GetCalcFields({$IFNDEF DOTNET}PChar(ADataSet.OverrideActiveRecordBuffer){$ELSE}ADataSet.OverrideActiveRecordBuffer{$ENDIF});

          // Check filter of record.
          Accept:=ADataSet.FilterRecord(ADataSet.OverrideActiveRecordBuffer,false);
          if not Accept then continue;

          // Check accept of saving this record.
          Accept:=true;
          if Assigned(ADataSet.OnSaveRecord) then ADataSet.OnSaveRecord(ADataset,Accept);
          if not Accept then continue;

          // Write current record.
          NewestVersion:=true;
{$IFNDEF BINARY_FILE_1XX_COMPATIBILITY}
 {$IFNDEF BINARY_FILE_200_COMPATIBILITY}
          // New for v. 2.24.

  {$IFDEF DOTNET}
          ARec := TKbmRecord (Marshal.PtrToStructure(ADataSet.OverrideActiveRecordBuffer,TypeOf(TKbmRecord) ));

          if (not (sfSaveData in sfData)) and (ARec.UpdateStatus=usUnmodified) then continue;

          // New for v. 2.30b
          if (not (sfSaveDontFilterDeltas in sfDontFilterDeltas)) and (ARec.UpdateStatus=usDeleted) then
          begin
               // Make sure record has not been inserted and deleted again.
               pRec:=ARec.PrevRecordVersion;
               Rec := TKbmRecord (Marshal.PtrToStructure(pRec,TypeOf(TKbmRecord)));
               while Rec.PrevRecordVersion<>nil do
               begin
                  pRec:=Rec.PrevRecordVersion;
                  Rec := TKbmRecord (Marshal.PtrToStructure(pRec,TypeOf(TKbmRecord)));
               end;
               if Rec.UpdateStatus=usInserted then continue;
          end;
  {$ELSE}
          if (not (sfSaveData in sfData)) and (ADataSet.OverrideActiveRecordBuffer^.UpdateStatus=usUnmodified) then continue;

          // New for v. 2.30b
          if (not (sfSaveDontFilterDeltas in sfDontFilterDeltas)) and (ADataSet.OverrideActiveRecordBuffer^.UpdateStatus=usDeleted) then
          begin
               // Make sure record has not been inserted and deleted again.
               pRec:=ADataSet.OverrideActiveRecordBuffer^.PrevRecordVersion;
               while pRec^.PrevRecordVersion<>nil do pRec:=pRec^.PrevRecordVersion;
               if pRec^.UpdateStatus=usInserted then continue;
          end;
  {$ENDIF}

          // Write record versions in a list starting with Updatestatus.
          Writer.WriteListBegin;
          while ADataSet.OverrideActiveRecordBuffer<>nil do
          begin
  {$IFDEF DOTNET}
               ARec:=TKbmRecord (Marshal.PtrToStructure(ADataSet.OverrideActiveRecordBuffer,TypeOf(TKbmRecord) ));
               Writer.WriteInteger(ord(ARec.UpdateStatus));
  {$ELSE}
               Writer.WriteInteger(ord(ADataSet.OverrideActiveRecordBuffer^.UpdateStatus));
  {$ENDIF}
 {$ENDIF}
{$ENDIF}
               for i:=0 to nf-1 do
               begin
                    if SaveFields[i]>=0 then
                    begin
                         if NewestVersion and Assigned(ADataSet.OnSaveField) then ADataSet.OnSaveField(ADataset,i,ADataSet.Fields[i]);

{$IFNDEF BINARY_FILE_1XX_COMPATIBILITY}
 {$IFNDEF BINARY_FILE_200_COMPATIBILITY}
  {$IFNDEF BINARY_FILE_230_COMPATIBILITY}
                         Writer.WriteBoolean(ADataSet.Fields[i].IsNull);
                         if not ADataSet.Fields[i].IsNull then
                         begin
  {$ENDIF}
 {$ENDIF}
{$ENDIF}
                              case ADataSet.Fields[i].DataType of
                                   ftBoolean : Writer.WriteBoolean(ADataSet.Fields[i].AsBoolean);

{$IFNDEF LEVEL3}
                                   ftLargeInt: Writer.WriteFloat(ADataSet.Fields[i].AsFloat);
 {$IFDEF DOTNET}
                                   ftWideString: Writer.WriteString(ADataSet.Fields[i].AsString);
 {$ELSE}
                                   ftWideString: Writer.WriteString({$IFDEF LEVEL6}UTF8Encode(ADataSet.Fields[i].Value){$ELSE}ADataSet.Fields[i].AsString{$ENDIF});
 {$ENDIF}
{$ENDIF}

                                   ftSmallInt,
                                   ftInteger,
                                   ftWord,
                                   ftAutoInc : Writer.WriteInteger(ADataSet.Fields[i].AsInteger);

                                   ftFloat : Writer.WriteFloat(ADataSet.Fields[i].AsFloat);

                                   ftBCD,
                                   ftCurrency : Writer.WriteFloat(ADataSet.Fields[i].AsCurrency);

                                   ftDate,
                                   ftTime,ftDateTime: Writer.WriteFloat(ADataSet.Fields[i].AsFloat);
                              else
                                  Writer.WriteString(ADataSet.Fields[i].AsString);
                              end;
{$IFNDEF BINARY_FILE_1XX_COMPATIBILITY}
 {$IFNDEF BINARY_FILE_200_COMPATIBILITY}
  {$IFNDEF BINARY_FILE_230_COMPATIBILITY}
                         end;
  {$ENDIF}
 {$ENDIF}
{$ENDIF}
                    end;
               end;
{$IFNDEF BINARY_FILE_1XX_COMPATIBILITY}
 {$IFNDEF BINARY_FILE_200_COMPATIBILITY}                         // New for v. 2.24.

               // Only write newest version (current data).
               if not (sfSaveDeltas in sfDeltas) then break;

               // Prepare writing next older version of record.
  {$IFDEF DOTNET}
               ARec:=TKbmRecord(Marshal.PtrToStructure(ADataSet.OverrideActiveRecordBuffer,TypeOf(TKbmRecord)));
               ADataSet.OverrideActiveRecordBuffer:=ARec.PrevRecordVersion;
  {$ELSE}
               ADataSet.OverrideActiveRecordBuffer:=ADataSet.OverrideActiveRecordBuffer^.PrevRecordVersion;
  {$ENDIF}
               NewestVersion:=false;
          end;
          Writer.WriteListEnd;
 {$ENDIF}
{$ENDIF}

          // Increment save count.
          ADataSet.SaveCount:=ADataSet.SaveCount + 1;
     end;
     Writer.WriteListEnd;
end;

procedure TkbmCustomBinaryStreamFormat.BeforeLoad(ADataset:TkbmCustomMemTable);
begin
     inherited;

     StreamSize:=WorkStream.Size;
     ProgressCnt:=0;

     Reader:=TReader.Create(WorkStream,FBuffSize);
     Reader.ReadSignature;

     InitIndexDef:=false;

{$IFNDEF BINARY_FILE_1XX_COMPATIBILITY}
     if Reader.NextValue = vaList then       // A hack since vaList only exists in >= v. 2.xx.
       FileVersion := 100
     else
       FileVersion:=Reader.ReadInteger;
{$ELSE}
     FileVersion:=0;
{$ENDIF}
end;

procedure TkbmCustomBinaryStreamFormat.AfterLoad(ADataset:TkbmCustomMemTable);
begin
     Reader.Free;

     // Now create indexes as defined.
     if InitIndexDef then ADataset.CreateIndexes;
     ADataset.OverrideActiveRecordBuffer:=nil;
     inherited;
end;

procedure TkbmCustomBinaryStreamFormat.DetermineLoadFieldIndex(ADataset:TkbmCustomMemTable; ID:string; FieldCount:integer; OrigIndex:integer; var NewIndex:integer; Situation:TkbmDetermineLoadFieldsSituation);
begin
     NewIndex:=OrigIndex;
end;

procedure TkbmCustomBinaryStreamFormat.LoadDef(ADataset:TkbmCustomMemTable);
var
   i:integer;
   FName,KName,TName,DName,EMask,DExpr:string;
   FSize,DSize:integer;
   REQ,RO:boolean;
   FT:TFieldType;
   FK:TFieldKind;
   InitTableDef:boolean;
   ld,ldidx:boolean;
{$IFNDEF BINARY_FILE_1XX_COMPATIBILITY}
   ioptions:TIndexOptions;
   FFields:string;
{$ENDIF}
  aField:TField;
  aIndexDef:TIndexDef;
begin
     if (StreamSize = 0) then exit;
     ld:=sfLoadDef in sfDef;
     ldidx:=sfLoadIndexDef in sfIndexDef;

     // Read all definitions if any saved.
     InitTableDef:=false;
     InitIndexDef:=false;
     try
        Reader.ReadListBegin;

        while not(Reader.EndofList) do
        begin
             // Clear previous setup if not cleared yet.
             if not InitTableDef then
             begin
                  if ld then
                  begin
                       ADataSet.Close;
                       ADataSet.FieldDefs.clear;
                       ADataSet.DeleteTable;
                  end;
                  InitTableDef:=true;
             end;

             // read field definition.
             FName := Reader.ReadString;
             TName := Reader.ReadString;
             FSize := Reader.ReadInteger;
             DName := Reader.ReadString;
             EMask := Reader.ReadString;
             DSize := Reader.ReadInteger;
             REQ := Reader.ReadBoolean;
             RO := Reader.ReadBoolean;
             if FileVersion>=250 then KName:=Reader.ReadString
             else KName:=FieldKindNames[0]; // fkData
             if FileVersion>=251 then DExpr:=Reader.ReadString
             else DExpr:='';

             // Find fieldtype from fieldtypename.
             for i:=0 to ord(High(FieldTypeNames)) do
                 if FieldTypeNames[TFieldType(i)]=TName then break;
             FT:=TFieldType(i);
             if not (FT in kbmSupportedFieldTypes) then
                raise EMemTableError.Create(Format(kbmUnknownFieldErr1,[TName]));

             // Find fieldkind from fieldkindname.
             FK:=fkData;
             for i:=0 to ord(High(FieldKindNames)) do
                 if FieldKindNames[i]=KName then
                 begin
                      FK:=TFieldKind(i);
                      break;
                 end;

            if ld then
            begin
                 // Add field definition.
                 ADataSet.FieldDefs.Add(FName,FT,FSize,REQ);

                 // Setup other properties.
                 i:=ADataSet.FieldDefs.IndexOf(FName);

                 AField := ADataSet.FieldDefs.Items[i].CreateField(ADataset);
                 AField.FieldKind:=FK;
                 AField.DisplayLabel:=DName;
                 AField.EditMask:=EMask;
                 AField.ReadOnly:=RO;
                 AField.DisplayWidth:=DSize;
{$IFDEF LEVEL4}
                 AField.DefaultExpression:=DExpr;
{$ENDIF}
             end;
        end;
        Reader.ReadListEnd;

        // Indexes introduced in file version 2.00
        if FileVersion>=200 then
        begin
             // Read all index definitions if any saved.
             Reader.ReadListBegin;

             while not(Reader.EndofList) do
             begin
                  // Clear previous setup if not cleared yet.
                  if not InitIndexDef then
                  begin
                       if ld and ldidx then
                       begin
                            ADataSet.DestroyIndexes;
                            ADataSet.IndexDefs.Clear;
                       end;
                       InitIndexDef:=true;
                  end;

                  // read index definition.
                  FName := Reader.ReadString;
                  FFields := Reader.ReadString;
                  DName := Reader.ReadString;

                  ioptions:=[];
                  if Reader.ReadBoolean then ioptions:=ioptions+[ixDescending];
                  if Reader.ReadBoolean then ioptions:=ioptions+[ixCaseInSensitive];

{$IFNDEF LEVEL3}
                  if Reader.ReadBoolean then ioptions:=ioptions+[ixNonMaintained];
{$ELSE}
                  Reader.ReadBoolean;     // Skip ixNonMaintained info since not supported for D3/BCB3.
{$ENDIF}
                  if Reader.ReadBoolean then ioptions:=ioptions+[ixUnique];

                  // Add index definition.
                  if ld and ldidx then
                  begin
{$IFNDEF LEVEL3}
                       aIndexDef := ADataSet.IndexDefs.AddIndexDef;
                       aIndexDef.Name:=FName;
                       aIndexDef.Fields:=FFields;
                       aIndexDef.Options:=ioptions;
                       aIndexDef.DisplayName:=DName;
{$ELSE}
                       IndexDefs.Add(FName,FFields,ioptions);
{$ENDIF}
                  end;
             end;
             Reader.ReadListEnd;
        end;
     finally
        if InitTableDef then ADataSet.Open;
     end;
     if not (ld and ldidx) then InitIndexDef:=false;
end;

procedure TkbmCustomBinaryStreamFormat.LoadData(ADataset:TkbmCustomMemTable);
   procedure SkipField(AFieldType:TFieldType);
   begin
        case AFieldType of
          ftBoolean :   Reader.ReadBoolean;

{$IFNDEF LEVEL3}
          ftLargeInt:   Reader.ReadFloat;
          ftWideString: Reader.ReadString;
{$ENDIF}

          ftSmallInt,
          ftInteger,
          ftWord :      Reader.ReadInteger;

          ftAutoInc :   Reader.ReadInteger;

          ftFloat :     Reader.ReadFloat;

          ftBCD,
          ftCurrency :  Reader.ReadFloat;

          ftDate,
          ftTime,
          ftDateTime : Reader.ReadFloat;
        else
          Reader.ReadString;
        end;
   end;
var
   i,j:integer;
   nf:integer;
   Accept:boolean;
   bNull:boolean;
   Date:double;
   NewestVersion:boolean;
   pRec:PkbmRecord;
   ApproxRecs:integer;
   fc,fno:integer;
   ftypes:array of TFieldType;
{$IFDEF DOTNET}
   ARec,Rec:TKbmRecord;
{$ENDIF}
begin
     if (StreamSize = 0) then exit;

     ADataSet.__SetTempState(dsinsert);
     try
        ADataSet.ResetAutoInc;

        // Try to determine approx how many records in stream + add some slack.
        if ADataSet.RecordSize>0 then
        begin
             ApproxRecs:=StreamSize div ADataSet.Common.DataRecordSize;
             ApproxRecs:=ApproxRecs + (ApproxRecs div 50) + ADataSet.RecordCount;
        end
        else
            ApproxRecs:=0;

{$IFDEF LEVEL4}
        nf:=length(LoadFields);
{$ELSE}
        nf:=LoadFieldsCount;
{$ENDIF}

        // Load datatypes from header.
        fc:=0;
        if sfLoadDataTypeHeader in sfDataTypeHeader then
        begin
             Reader.ReadListBegin;
             fc:=Reader.ReadInteger;
             SetLength(ftypes,fc);
             for i:=0 to fc-1 do
                 ftypes[i]:=TFieldType(Reader.ReadInteger);
             Reader.ReadListEnd;
        end;

        // Read all records.
        ADataSet.LoadCount:=0;
        ADataSet.LoadedCompletely:=true;

        if ApproxRecs>0 then ADataSet.Common.Records.Capacity:=ApproxRecs; // For speed reason try to preallocate room for all records.

        Reader.ReadListBegin;
        while not(Reader.EndofList) do
        begin
             // Show progress.
             inc(ProgressCnt);
             ProgressCnt:=ProgressCnt mod 100;
             if (ProgressCnt=0) then
                ADataSet.Progress(trunc((WorkStream.Position / StreamSize) * 100),mtpcLoad);

             if (ADataSet.LoadLimit>0) and (ADataSet.LoadCount>=ADataSet.LoadLimit) then
             begin
                  ADataSet.LoadedCompletely:=false;
                  break;
             end;

             pRec:=ADataSet.Common._InternalAllocRecord;
             ADataSet.OverrideActiveRecordBuffer:=pRec;

             NewestVersion:=true;
{$IFNDEF BINARY_FILE_1XX_COMPATIBILITY}
 {$IFNDEF BINARY_FILE_200_COMPATIBILITY}                         // New for v. 2.24.

             // Loop for all versions of record if versioning is used (2.30 and forth).
             if FileVersion>=230 then Reader.ReadListBegin;
             while true do
             begin
  {$IFDEF DOTNET}
                  ARec := TKbmRecord (Marshal.PtrToStructure(ADataSet.OverrideActiveRecordBuffer,TypeOf(TKbmRecord)));
                  if FileVersion>=230 then ARec.UpdateStatus:=TUpdateStatus(Reader.ReadInteger);
                  Marshal.StructureToPtr(ARec,ADataSet.OverrideActiveRecordBuffer,False);
  {$ELSE}
                  if FileVersion>=230 then ADataSet.OverrideActiveRecordBuffer^.UpdateStatus:=TUpdateStatus(Reader.ReadInteger);
  {$ENDIF}
 {$ENDIF}
{$ENDIF}

                  // Read fields for current record version.
                  fno:=0;
                  for i:=0 to nf-1 do
                  begin
                       if LoadFields[i]<0 then
                       begin
                            // Check if to skip.
                            if fc>0 then SkipField(ftypes[fno]);
                            continue;
                       end;
                       j:=LoadFields[i];

                       //2.50i                          if Fields[i].FieldKind<>fkData then continue;

{$IFNDEF BINARY_FILE_1XX_COMPATIBILITY}
 {$IFNDEF BINARY_FILE_200_COMPATIBILITY}
  {$IFNDEF BINARY_FILE_230_COMPATIBILITY}                     // New for v. 2.49.
                       // Check if null values saved in binary file.
                       if (FileVersion>=249) then
                          bNull:=Reader.ReadBoolean
                       else
  {$ENDIF}
 {$ENDIF}
{$ENDIF}
                          bNull:=false;

                       // Check if null field.
                       if bNull then
                          ADataSet.Fields[j].Clear
                       else
                       begin
                            // Not null, load data.
                            case ADataSet.Fields[j].DataType of
                                 ftBoolean : ADataSet.Fields[j].AsBoolean := Reader.ReadBoolean;

{$IFNDEF LEVEL3}
                                 ftLargeInt: ADataSet.Fields[j].AsFloat:=Reader.ReadFloat;
 {$IFDEF DOTNET}
                                 ftWideString: ADataSet.Fields[j].AsString:=Reader.ReadString;
 {$ELSE}
                                 ftWideString: ADataSet.Fields[j].Value:={$IFDEF LEVEL6}UTF8Decode(Reader.ReadString){$ELSE}Reader.ReadString{$ENDIF};
 {$ENDIF}
{$ENDIF}

                                 ftSmallInt,
                                 ftInteger,
                                 ftWord : ADataSet.Fields[j].AsInteger := Reader.ReadInteger;

                                 ftAutoInc :begin
                                                 ADataSet.Fields[j].AsInteger:=Reader.ReadInteger;
                                                 if ADataSet.Common.AutoIncMax<ADataSet.Fields[j].AsInteger then
                                                    ADataSet.Common.AutoIncMax:=ADataSet.Fields[j].AsInteger;
                                            end;

                                 ftFloat : ADataSet.Fields[j].AsFloat := Reader.ReadFloat;

                                 ftBCD,
                                 ftCurrency : ADataSet.Fields[j].AsCurrency := Reader.ReadFloat;

                                 ftDate,
                                 ftTime,
                                 ftDateTime : begin
                                                   Date:=Reader.ReadFloat;
                                                   if Date=0 then ADataSet.Fields[j].Clear
                                                   else ADataSet.Fields[j].AsFloat:=Date;
                                              end;
                            else
                                ADataSet.Fields[j].AsString := Reader.ReadString;
                            end;
                       end;

                       if NewestVersion and Assigned(ADataSet.OnLoad) then ADataSet.OnLoadField(ADataset,i,ADataSet.Fields[i]);
{$IFNDEF BINARY_FILE_1XX_COMPATIBILITY}
 {$IFNDEF BINARY_FILE_200_COMPATIBILITY}                         // New for v. 2.24.
                  end;

                  // Previous file versions didnt contain versions, so just break loop.
                  if FileVersion<230 then break;

                  // Prepare for reading next version if any. (introduced in v. 2.30)
                  if Reader.EndOfList then break;

                  // Prepare next version.
                  NewestVersion:=false;
  {$IFDEF DOTNET}
                  ARec := TKbmRecord (Marshal.PtrToStructure(ADataSet.OverrideActiveRecordBuffer,TypeOf(TKbmRecord) ));
                  ARec.PrevRecordVersion:=ADataSet.Common._InternalAllocRecord;
                  Marshal.StructureToPtr(ARec,ADataSet.OverrideActiveRecordBuffer,False);
                  ADataSet.OverrideActiveRecordBuffer:=ARec.PrevRecordVersion;
  {$ELSE}
                  ADataSet.OverrideActiveRecordBuffer^.PrevRecordVersion:=ADataSet.Common._InternalAllocRecord;
                  ADataSet.OverrideActiveRecordBuffer:=ADataSet.OverrideActiveRecordBuffer^.PrevRecordVersion;
  {$ENDIF}

             end;
             if FileVersion>=230 then Reader.ReadListEnd;
 {$ENDIF}
{$ENDIF}

             Accept:=true;
             if Assigned(ADataSet.OnLoadRecord) then ADataSet.OnLoadRecord(ADataset,Accept);
             if Accept then
             begin
{$IFDEF DOTNET}
                  Rec:=TKbmRecord(Marshal.PtrToStructure(pRec,TypeOf(TKbmRecord)));
                  Rec.RecordID:=ADataSet.Common.RecordID;
                  ADataSet.Common.RecordID:=ADataSet.Common.RecordID+1;
                  Rec.UniqueRecordID:=ADataSet.Common.UniqueRecordID;
                  ADataSet.Common.UniqueRecordID:=ADataSet.Common.UniqueRecordID+1;
                  Rec.Flag:=kbmrfInTable;
                  if Rec.UpdateStatus=usDeleted then
                     ADataSet.Common.deletedCount:=ADataSet.Common.DeletedCount+1;
                  Marshal.StructureToPtr(Rec,pRec,False);
                  ADataSet.Common.Records.Add(pRec);
{$ELSE}
                  pRec^.RecordID:=ADataset.Common.RecordID;
                  ADataSet.Common.RecordID:=ADataSet.Common.RecordID+1;
                  pRec^.UniqueRecordID:=ADataSet.Common.UniqueRecordID;
                  ADataSet.Common.UniqueRecordID:=ADataSet.Common.UniqueRecordID+1;
                  pRec^.Flag:=kbmrfInTable;
                  ADataSet.Common.Records.Add(pRec);
                  if pRec^.UpdateStatus=usDeleted then
                     ADataSet.Common.deletedCount:=ADataSet.Common.DeletedCount+1;
{$ENDIF}
                  ADataSet.LoadCount:=ADataSet.LoadCount+1;
             end
             else
                 ADataSet.Common._InternalFreeRecord(pRec,true,true);
        end;
        Reader.ReadListEnd;
     finally
        ADataSet.__RestoreState(dsBrowse);
     end;
end;

// -----------------------------------------------------------------------------------
// Registration for Delphi 3 / C++ Builder 3
// -----------------------------------------------------------------------------------

{$ifdef LEVEL3}
procedure Register;
begin
     RegisterComponents('kbmMemTable', [TkbmBinaryStreamFormat]);
end;
{$endif}

end.
