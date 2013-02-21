unit GsFDBDataMigration;

interface

uses
  IBDatabase, IBDatabaseInfo, IBSQL, Classes, Windows, SysUtils, gsHugeIntSet;

//const  
 
type

TgsFDBDataMigration = class(TObject)
  private
    FDatabase: TIBDatabase;
    FDatabaseInfo: TIBDatabaseInfo;
    ReadTransaction: TIBTransaction;
    WriteTransaction: TIBTransaction; 
  
  
  
    FDatabaseName: String;
    FDatabaseOriginalName: String;
    FDatabaseCopyName: String;
   
    procedure SetDatabaseName(const Value: String);  ?
    function GetDatabaseName: String;  ?
   
    IBSQLRead: TIBSQL;
    IBSQLWrite: TIBSQL;
  //  slActivTriggers: TStringList; 
   
    function h_GetActivTriggers: TStringList;
    function h_GetActivIndices: TStringList;
   
    procedure h_SwitchActivityTriggers(const ADisableFlag: integer, const ATriggers: TStringList, AIBSQL: TIBSQL); 
    procedure h_SwitchActivityIndices(const ADisableFlag: integer, const AIndices: TStringList, AIBSQL: TIBSQL);
   
    procedure h_DeleteAllConstraints;
    procedure h_RecreateAllConstraints;
   
   
     X: TIntList  														              /// ���������� � TIntList
	 slPkFk: TStringList //ListPkFk
   
    procedure h_MigrateMasterTbls(const AMastersTblsPK: TIntList);
    procedure h_Migrate1to1DetailTbls(const A1to1DetailTblsPK: TIntList);
    procedure h_MigrateMasterkeyTbls(const AMasterkeyTblsPK: TIntList, const AMasterkeys: TIntList); 

///
	
  public
  
    constructor Create;
    destructor Destroy; override;

    // ����������� � ��
    procedure Connect;
    // ���������� �� ��
    procedure Disconnect;

    // ���������� ���� ��
    procedure CopyFile(const ADatabaseOriginalPath, ADatabaseCopyPath: String);
	
	procedure MigrateTbls; //-
    procedure BeforeMigrationPrepareDB; //-
	procedure AfterMigrationPrepareDB; //-
	
  	property Database: TIBDatabase read FDatabase;
    property DatabaseName: String read GetDatabaseName write SetDatabaseName;
    property DatabaseOriginalName: String read FDatabaseOriginalName write FDatabaseOriginalName;
    property DatabaseCopyName: String read FDatabaseCopyName write FDatabaseCopyName;
	
end;
  
implementation

uses
  SysUtils, IB, IBIntf, IBServices, IBHeader, IBErrorCodes,
  gsSysUtils, JclStrings, gsFDBConvertLocalization_unit, forms;

const
  DEFAULT_IB_USER_NAME = 'SYSDBA';
  DEFAULT_IB_USER_PASSWORD = 'masterkey';
  DEFAULT_CHARACTER_SET = 'WIN1251';
//DEFAULT_PAGE_SIZE = 8192;
//DEFAULT_NUM_BUFFERS = 8192;  
 
//============================= CONSTRUCTOR CREATE =============================
constructor TgsFDBDataMigration.Create;
begin
 // �������� ������� ���� ������, � ���������� � �� � ������ ��
  FDatabase := TIBDatabase.Create(nil);
  FDatabaseInfo := TIBDatabaseInfo.Create(nil);
  FDatabaseInfo.Database := Database;
  // �������� ����������
  ReadTransaction := TIBTransaction.Create(nil);
  ReadTransaction.DefaultDatabase := Database;
 
  // ��������� �������� ����������, ��� ���������� �� ��������� ��� ��
  FDatabase.DefaultTransaction := ReadTransaction;
  // ���������� �� ������ �� ���������
  WriteTransaction := TIBTransaction.Create(nil);
  WriteTransaction.DefaultDatabase := Database;

  FDatabaseCopyName := '';

   M := TgsHugeIntSet.Create;
   M2 := TgsHugeIntSet.Create;
   {  IBSQLRead.SQL.Text := ' SELECT GEN_ID(gd_g_unique, 1) as ID_UNIQUE ' +
     ' FROM RDB$DATABASE ';
   try
     IBSQLRead.ExecQuery;
	 SIZE_SET := IBSQLRead.FieldByName('ID_UNIQUE').AsInteger - 147000000;    

	 M.Include(SIZE_SET); 
	 M2.Include(SIZE_SET);
   finally
     IBSQLRead.Close;
   end;
    }
end; 

//============================= DECTRUCTOR DESTROY =============================
destructor TgsFDBDataMigration.Destroy;
begin
  inherited;
  if Assigned(WriteTransaction) and WriteTransaction.InTransaction then
    WriteTransaction.Commit;
  FreeAndNil(WriteTransaction);
  if Assigned(ReadTransaction) and ReadTransaction.InTransaction then
    ReadTransaction.Commit;
  FreeAndNil(ReadTransaction);
  FreeAndNil(DatabaseInfo);
  FreeAndNil(Database);

  
end;

//============================= GET DB NAME ================================
function TgsFDBDataMigration.GetDatabaseName: String;
begin
  Result := FDatabaseName;
end;
//============================= SET DB NAME ================================
procedure TgsFDBDataMigration.SetDatabaseName(const Value: String);
begin
  FDatabaseName := ExpandFileName(Value);               ������� ����� ������ ���� ������� ����������    /////////////////////////////////////////////// ! 
end;


//============================= COPY DB FILE ================================
procedure TgsFDBDataMigration.CopyFile(const ADatabaseOriginalPath, ADatabaseCopyPath: String);
const
  BUFFER_SIZE = 10240;  /// ?
var
  Buffer: array[0..BUFFER_SIZE - 1] of byte;
  NumRead: Integer;
  FromFile, ToFile: TFileStream;
begin
  if FileExists(ADatabaseOriginalPath) then
  begin
    FromFile := TFileStream.Create(ADatabaseOriginalPath, fmOpenRead or fmShareDenyNone);
    try
      if FileExists(ADatabaseCopyPath) then
        ToFile := TFileStream.Create(ADatabaseCopyPath, fmOpenWrite or fmShareDenyWrite);
      else
        ToFile := TFileStream.Create(ADatabaseCopyPath, fmCreate);
      try
        ToFile.Size := FromFile.Size; /// ?
        ToFile.Position := 0;
        FromFile.Position := 0;
        NumRead := FromFile.Read(Buffer[0], BUFFER_SIZE);
        while NumRead > 0 do
        begin
          ToFile.Write(Buffer[0], NumRead);
          NumRead := FromFile.Read(Buffer[0], BUFFER_SIZE);
        end;
      finally
        FreeAndNil(ToFile);
      end;
    finally
      FreeAndNil(FromFile);       //Stream.Free
    end;
   end;
end;

//=============================== CONNECT ==================================
procedure TgsFDBDataMigration.Connect;
begin
  // �������� ���������� ������
  LoadIBLibrary;
  // ����������� � ��
  FDatabase.DatabaseName := FDatabaseName;    // *.fdb
  FDatabase.Params.Clear;
  FDatabase.Params.Add('user_name=' + DEFAULT_IB_USER_NAME);
  if ConnectionInformation.CharacterSet <> '' then                                                    //=========================== !!!!!!!!!!
    FDatabase.Params.Add('lc_ctype=' + ConnectionInformation.CharacterSet); //��������� ��� ����
  FDatabase.LoginPrompt := False;
  //Database.SQLDialect := 3; // 3-�� �������
  FDatabase.Open;
  
  FReadTransaction.StartTransaction; //������ �������� ����������
end;

//============================== DISCONNECT ================================
procedure TgsFDBDataMigration.Disconnect;
begin
  if Assigned(FDatabase) then
    if FDatabase.Connected  then
    begin
      if Assigned(FReadTransaction) and FReadTransaction.InTransaction then
        FReadTransaction.Commit;
      FDatabase.Close;
      // �������� ���������� ������
      FreeIBLibrary;
    end;
end;

//========================== GET ACTIV TRIGGERS ============================     ///���������� � SAVE ACTIV TRIGGERS (�������� private property slActivTriggers)
  {Result: ������ ���� rdb$trigger_name ���� �������� ���������}
function TgsFDBDataMigration.h_GetActivTriggers: TStringList;
var slActivTriggers: TStringList 
begin
  ///IBSQLRead.Close;
  
  IBSQLRead.SQL.Text := ' SELECT g.Rdb$trigger_name AS trigger_name ' +
    ' FROM Rdb$triggers g ' +
    ' WHERE rdb$trigger_inactive = 0 ';
  try
	IBSQLRead.ExecQuery;
	if IBSQLRead.RecordCount > 0 then
    begin
	   slActivTriggers:= TStringList.Create;
	   while not IBSQLRead.Eof do
       begin
		 slActivTriggers.Add(IBSQLRead.FieldByName('trigger_name').AsString);
		 IBSQLRead.Next;
	   end;
  finally
    IBSQLRead.Close;
  end;
  Result := slActivTriggers;
end;

//======================= SWITCH ACTIVITY TRIGGERS =========================
  {ATriggers: ������� �� rdb$trigger_name
   ADisableFlag:  1-��������������, 0-������������ }
procedure TgsFDBDataMigration.h_SwitchActivityTriggers(const ADisableFlag: integer, const ATriggers: TStringList, AIBSQL: TIBSQL);
var i: integer;
begin
  AIBSQL.Close;
  for i:=0 to ATriggers.Count-1 do
  begin
    AIBSQL.ParamCheck := True;
    AIBSQL.SQL.Text := ' UPDATE rdb$triggers ' + 
      ' SET rdb$trigger_inactive = :disableFlag ' +
      ' WHERE rdb$trigger_name = :trig_name ';
    AIBSQL.Prepare;
    try
      AIBSQL.ExecQuery;
	  AIBSQL.ParamByName('disableFlag').AsInteger := ADisableFlag;
	  AIBSQL.ParamByName('trig_name').AsString := ATriggers[i];
	finally
      AIBSQL.Close;
    end;
end;

//========================== GET ACTIV INDICES ============================        ///���������� � SAVE ACTIV INDICES (�������� private property slActivIndices)
  {Result: ������ ���� rdb$index_name ���� �������� ��������}
function TgsFDBDataMigration.h_GetActivIndices: TStringList;
var slActivIndices: TStringList
begin
  ///IBSQLRead.Close;
  IBSQLRead.SQL.Text := ' SELECT I.RDB$INDEX_NAME AS index_name ' +
    ' FROM RDB$INDICES I ' +
    ' WHERE I.RDB$INDEX_INACTIVE = 0 ';
  try
	IBSQLRead.ExecQuery;
	if IBSQLRead.RecordCount > 0 then
    begin
	  slActivIndices:= TStringList.Create;
      while not IBSQLRead.Eof do
      begin
		slActivIndices.Add(IBSQLRead.FieldByName('index_name').AsString);
		IBSQLRead.Next;
	  end;
  finally
    IBSQLRead.Close;
  end;
  Result := slActivTriggers;
end;  

//======================= SWITCH ACTIVITY INDICES =========================
  {AIndices: ������� �� rdb$index_name
   ADisableFlag:  1-��������������, 0-������������ }
procedure TgsFDBDataMigration.h_SwitchActivityIndices(const ADisableFlag: integer, const AIndices: TStringList, AIBSQL: TIBSQL);
var i: integer;
begin
  AIBSQL.Close;
  for i:=0 to AIndices.Count-1 do
  begin
    AIBSQL.ParamCheck := True;
    AIBSQL.SQL.Text := ' UPDATE RDB$INDICES ' +
      ' SET I.RDB$INDEX_INACTIVE =  :disableFlag ' +
      ' WHERE I.RDB$INDEX_NAME = :index_name ';
    AIBSQL.Prepare;
    try
      AIBSQL.ExecQuery;
	  AIBSQL.ParamByName('disableFlag').AsInteger := ADisableFlag;
	  AIBSQL.ParamByName('index_name').AsString := AIndices[i];
	finally
      AIBSQL.Close;
    end;
end;

//========================= SAVE ALL CONSTRAINTS ==========================                    ///////////////////////     �������� !

//��� ����������� (PK,FK,UNIC,CHEK,NOT NULL)
IBSQLRead.SQL.Text := ' SELECT r.RDB$CONSTRAINT_TYPE as type, r.RDB$CONSTRAINT_NAME as name, ' +
  ' r.RDB$INDEX_NAME as index, r.RDB$RELATION_NAME as relation ' +
  ' FROM RDB$RELATION_CONSTRAINTS r '
  ' ORDER BY RDB$CONSTRAINT_TYPE ';                                                         /// �� �����������
try
  IBSQLRead.ExecQuery;
  if IBSQLRead.RecordCount > 0 then
  begin
    //������: ���, ��� �����������, ��� �������, ��� �������    (��������������)            /// ����� ������� �������� ������� � ���� ��������� ?
	ConstrTypeList := TStringList.Create;
	ConstraintNameList := TStringList.Create;
    IndexNameList := TStringList.Create;
	RelationNameList := TStringList.Create;

	while not IBSQLRead.Eof do
    begin
     ConstrTypeList.Add(IBSQLRead.FieldByName('type').AsString);
	 ConstraintNameList.Add(IBSQLRead.FieldByName('name').AsString);
	 IndexNameList.Add(IBSQLRead.FieldByName('index').AsString);
	 RelationNameList.Add(IBSQLRead.FieldByName('relation').AsString);
	 

	 { case IBSQLRead.FieldByName('type').AsString of
        'UNIC' : begin
		.Add(IBSQLRead.FieldByName('').AsString);
		  end;
		'PRIMARY KEY':
		'FOREIGN KEY':
        'CHECK':
        'NOT NULL':
	  }
      IBSQLRead.Next;
	end;
  end;
finally
  IBSQLRead.Close;
end;

//======================== DELETE ALL CONSTRAINTS =========================
procedure TgsFDBDataMigration.h_DeleteAllConstraints;
begin
///IBSQLWrite.Close;
  IBSQLWrite.SQL.Text := ' DELETE FROM RDB$RELATION_CONSTRAINTS ';
  try
    IBSQLWrite.ExecQuery;
  finally
    IBSQLWrite.Close;
  end;
end; 

//======================= RECREATE ALL CONSTRAINTS ========================
procedure TgsFDBDataMigration.h_RecreateAllConstraints;
var i: integer
begin
  for i:=0 to ConstraintNameList.Count-1 do
  begin
    IBSQLRead.ParamCheck := True;
    IBSQLRead.SQL.Text := ' INSERT INTO RDB$RELATION_CONSTRAINTS ' +
      ' (RDB$CONSTRAINT_TYPE, RDB$CONSTRAINT_NAME, RDB$INDEX_NAME, RDB$RELATION_NAME) ' +
      ' VALUES (:constraint_type, :constraint_name, :inx_name, :relation_name) ';
    IBSQLRead.Prepare;
    try
      IBSQLRead.ExecQuery;
	  IBSQLRead.ParamByName('constraint_type').AsString := ConstrTypeList[i];
      IBSQLRead.ParamByName('constraint_name').AsString := ConstraintNameList[i];
      IBSQLRead.ParamByName('inx_name').AsString := IndexNameList[i];
      IBSQLRead.ParamByName('relation_name').AsString := RelationNameList[i];
    finally
      IBSQLRead.Close;
    end;
end;  
  
//===================  ListPkFk  
//===========================================================[temp2] ListPkFk, master tables, detail tables, 1to1 master tables     /// �������� !
    var
    textSQL: String;
    i: integer;
    master_table_name: TStringList;
    master_field_name: TStringList;
	master_pk_field_name: TStringList;
    detail_table_name: TStringList;   
    detail_field_name: TStringList; 
    ///IntList  !
	GD_DOCUMENT_pk_field: TStringList; 
	masterkey_table_pk_field: TStringList; //���������� masterkey ��� masterdockey
	
	
    IBSQLRead.SQL.Text := ' SELECT I.rdb$relation_name   as Master_Table_Name ' +
       ' I_S.rdb$field_name    as Master_Field_Name, ' +
       ' F.rdb$field_name      as Master_PK_Field_Name, ' +
       ' I1.rdb$relation_name  as Detail_Table_Name, ' +
       ' I_S1.rdb$field_name   as Detail_Field_Name ';
     ' FROM rdb$indices I ' +
       ' JOIN rdb$index_segments I_S on I.rdb$index_name = I_S.rdb$index_name ' +
       ' JOIN rdb$indices I1 on I1.rdb$index_name = I.rdb$foreign_key ' +
       ' JOIN rdb$index_segments I_S1 on I1.rdb$index_name = I_S1.rdb$index_name ' +
       ' JOIN RDB$RELATION_CONSTRAINTS C on I.rdb$relation_name = C.RDB$RELATION_NAME ' +
       ' JOIN rdb$index_segments F on C.RDB$INDEX_NAME = F.RDB$INDEX_NAME ' +
       ' WHERE  I.rdb$foreign_key is not null ' +
       ' AND (C.RDB$CONSTRAINT_TYPE IN ('PRIMARY KEY')) ';

    try
      IBSQLRead.ExecQuery;

      if IBSQLRead.RecordCount > 0 then
      begin
	    master_table_name:= TStringList.Create;
		master_field_name:= TStringList.Create;
		master_pk_field_name:= TStringList.Create;
		detail_table_name:= TStringList.Create;
		detail_field_name:= TStringList.Create;
        
		
		
		///��� �� ����???
		var 
		field_master_table_name : string;
		field_master_field_name : string;
		
		
		i := 0;
        // ������� �� ������
        while not IBSQLRead.Eof do
        begin
		  field_master_table_name := IBSQLRead.FieldByName('Master_Table_Name').AsString; 
		  field_master_field_name := IBSQLRead.FieldByName('Master_Field_Name').AsString;
		  	  
		  
		 
		  else 
		  begin
		 
	//	  else //� ����� ������  
	//	   begin
			master_pk_field_name.Add(IBSQLRead.FieldByName('Master_PK_Field_Name').AsString);   //.Add()
            master_table_name.Add(IBSQLRead.FieldByName('Master_Table_Name').AsString;
            master_field_name.Add(IBSQLRead.FieldByName('Master_Field_Name').AsString;
		// ���� �� ����������	
            detail_table_name.Add(IBSQLRead.FieldByName('Detail_Table_Name').AsString;   
            detail_field_name[i] := IBSQLRead.FieldByName('Detail_Field_Name').AsString; 
    //     end;
		  end;
           i := i+1;
           IBSQLRead.Next;
        end;
        //Result := List.Text;

       end;
     finally
         IBSQLRead.Close;
     end;


    
    List: TStringList;
    ElementStr: String;
    Result := '';

	//TablesNameList.Delete('GD_DOCUMENT'); 
		  
	  
  /// try
   for i := 0 to master_field_name.Count-1 do
   begin
     textSQL := 'SELECT '+master_pk_field_name[i]+' as Master_PK, '+master_field_name[i]+'as Master_FK FROM '+master_table_name[i] ;
  
     IBSQLRead.SQL.Text := textSQL;

     try
     IBSQLRead.ExecQuery;
     if IBSQLRead.RecordCount > 0 then
     begin
	 ///Int !
	 GD_DOCUMENT_pk := TStringList.Create;
     //GD_RUID_pk := TStringList.Create;	 
     masterkey_table_pk:= TStringList.Create
	 
	 //���������� ������ pk ������          /// ��������� �������-������! (�� ����� ������ ������ ����)
	 if(master_table_name[i] <> 'GD_RUID') then 
	 begin

	   //[1]������ pk ��������� ������
	   if (master_pk_field_name[i] = 'MASTERKEY') 
	    or (master_pk_field_name[i] = 'MASTERDOCKEY') then 
	   begin 
         masterkey_table_pk.Add(IBSQLRead.FieldByName('Master_PK').AsInteger);
	     TablesNameList.Values[master_table_name[i]] := IntToStr(StrToInt(TablesNameList.Values[master_table_name[i]]) + 1);//����� fk ++
	   end;
	   else begin
	     //[2] c����� pk GD_DOCUMENT
		 if(master_table_name[i] = 'GD_DOCUMENT') then
		 begin
		   GD_DOCUMENT_pk.Add(IBSQLRead.FieldByName('Master_PK').AsInteger);
	       //TablesNameList.Values['GD_DOCUMENT'] := IntToStr(StrToInt(TablesNameList.Values['GD_DOCUMENT']) + 1); //����� fk ++
         end; 
         else begin
		   //[4]������ ������ 1-�-1 (�� �������)                     ///������� �������� !
		   if (master_field_name[i] = master_pk_field_name[i]) then
		   begin
		     master_1to1_pk.Add(IBSQLRead.FieldByName('Master_PK').AsInteger);
			 TablesNameList.Values[master_table_name[i]] := IntToStr(StrToInt(TablesNameList.Values[master_table_name[i]]) + 1);//����� fk ++
		   end;
		   else begin
		     //[3]������ ������-������ 
//			 ID	         FIELDNAME	        RELATIONNAME	FIELDSOURCE	        CROSSTABLE	           CROSSFIELD	RELATIONKEY	FIELDSOURCEKEY	CROSSTABLEKEY	CROSSFIELDKEY	
//            147084221	USR$TESTTEST_FIELD	USR$TESTTEST	USR$ACC_DACCOUNTSET	USR$CROSS1045_2012822647	ALIAS	147084216	147039906		
 
		   end;
		 end;
	   end;
		
		 

	 end;
	  
	 
       ListPkFk := TStringList.Create;
       
	   var commaTextPkFk : String  //����������!
	   
	   commaTextPkFk := '';
		while not IBSQLRead.Eof do
        begin 
		  commaTextPkFk := IBSQLRead.FieldByName('Master_PK').AsString + '=' + IBSQLRead.FieldByName('Master_FK').AsString ; 
          
		  IBSQLRead.Next;
		  if not IBSQLRead.Eof then commaTextPkFk := commaTextPkFk + ', '; 
        end;
     
        //Result := List.Text;
    
	    ListPkFk.CommaText := commaTextPkFk; ///for i := 0 to ListPkFk.Count-1 do begin ShowMessage(ListPkFk.Names[i]+' - ��� PK '+ListPkFk.ValueFromIndex[i] + ' - ��� FK'); end;
     end;
	 finally
       IBSQLRead.Close;
     end;
	end;
     

   ///
  //finally
  //  FreeAndNil(List);
  //end; 


//=============================== MIGRATE MASTER TABLES ================================
                                 /// X : TgsHugeIntSet   ���������� � TIntList, X - ������ id ������� �� ������� �� ������������� ������ ����������
  {AMastersTblsPK: c����� �������� PK ������� ������ }  
procedure TgsFDBDataMigration.h_MigrateMasterTbls(const AMastersTblsPK: TIntList);   
var iValue, i, ii: integer; 
begin    
  for i:=0 to AMastersTblsPK.Count-1 do
  begin
    //���� ������������� �������
    if (not X.Has(AMastersTblsPK[i]-147000000)) then
    begin
      M.Include(AMastersTblsPK[i]-147000000);
	  //���������� � ��� �� FK
	  for ii:=0 to ListPkFk.Count-1 do
	  begin
        if (ListPkFk.Names[ii] = AMastersTblsPK[i]) then
	    begin
	      iValue := ListPkFk.ValueFromIndex[ii]-147000000; 
		  //while masFK[i] = NULL do i=i+1;  //�� ������������ FK � NULL           /// ? 
		  M.Include(iValue);
		  if (M2.Has(iValue)) then
		  begin 
	        M2.Exclude(iValue);
		  end;
	    end;
	  end;
	  //�� L ������� ��� ������������ => �������� ������
	  for ii := 0 to ListPkFk.Count-1 do   
	  begin
        if (ListPkFk.Names[ii] = AMastersTblsPK[i])  then 
          //������� ��������-���� �� ������
	      ListPkFk.Delete(ii);                         ///??
	  end;
    end;
    else begin //������ �� ������������� �������
      M2.Include(AMastersTblsPK[i]-147000000);
	  for ii:=0 to ListPkFk.Count-1 do
	  begin
        if (ListPkFk.Names[ii] = AMastersTblsPK[i]) then
	    begin
	      iValue := ListPkFk.ValueFromIndex[ii]-147000000; 
		  //while iValue = NULL do i=i+1;  //�� ������������ FK � NULL        /// ?
		  if (not M.Has(iValue)) then
          begin
		  //�������� ��������-���� � ListPkFk
            commaTextPkFk := commaTextPkFk + ', ' + IntToStr(AMastersTblsPK[i]) + '=' + IntToStr(iValue);
          end;			   
	    end;  
	  end;
	  ListPkFk.CommaText := commaTextPkFk;
    end;
  end;	 
end;

//=============================== MIGRATE 1-TO-1 DETAIL TABLES ================================
procedure TgsFDBDataMigration.h_Migrate1to1DetailTbls(const A1to1DetailTblsPK: TIntList);           /// ��������! ����� ������ ������� � �����
var i, ii: integer;
begin 
  //�������� �������-������ ��� ���� ������� �� �� ��������� � M
  for i:=0 to A1to1DetailTblsPK.Count-1 do
  begin
    i2:=0;
    while(ListPkFk.Values[i2] <> A1to1DetailTblsPK[i]) then
	begin
	  i2 := i2+1; 
	end;
	if (M.Has(ListPkFk.Names[i2]-147000000)) then //������ �������  pk
	begin
	//��������� �����
	  M.Include(A1to1DetailTblsPK[i]-147000000);
	  
	end;
  end;
end;

//============================= MIGRATE TABLES WITH MASTERKEY ==================================     ///��������
procedure TgsFDBDataMigration.h_MigrateMasterkeyTbls(const AMasterkeyTblsPK: TIntList, const AMasterkeys: TIntList);   
var i: integer;
begin
  for i:=0 to AMasterkeyTblsPK.Count-1 do
  begin
    if (M.Has(AMasterkeys[i]-147000000)) then //������ �������  pk
	begin
	//��������� 
	  M.Include(AMasterkeyTblsPK[i]-147000000);
	                                                     /// ? 
	end;
  end;


 //=================================[temp] private procedure ������� �������-������_migration (TIntList ACrossList, TIntList masterPK)  //������ �� ������ � ������ �� ������ ���������� ���������

  for i:=0 to list.Count-1 do
  begin
    if (M.Has(masterPK[i]-147000000)) then //������ �������  pk
	begin
	//��������� ������
	  M.Include(list[i]-147000000);
	                                                     /// ? 
	end;
  end;

//======================================================== temp [���������  gd_document], c��������� X: TList c ID  ������������������ �������  

procedure 
   var id, i: integer;   
   masFK: array[1..7] of integer;
begin   
  // ��������� �����
   IBSQLRead.SQL.Text := ' SELECT doc.ID, doc.DOCUMENTTYPEKEY, doc.TRTYPEKEY, doc.TRANSACTIONKEY, ' + 
   ' doc.COMPANYKEY, doc.CREATORKEY, doc.CURRKEY, doc.EDITORKEY ' +
   ' FROM GD_DOCUMENT doc ' +
   ' WHERE doc.PARENT is NULL ';
   try
	 IBSQLRead.ExecQuery;
	 if IBSQLRead.RecordCount > 0 then
     begin
		while not IBSQLRead.Eof do
        begin
		  masFK[0] := IBSQLRead.FieldByName('DOCUMENTTYPEKEY').AsInteger;
		  masFK[1] := IBSQLRead.FieldByName('TRTYPEKEY').AsInteger;      //null??
		  masFK[2] := IBSQLRead.FieldByName('COMPANYKEY').AsInteger;
		  masFK[3] := IBSQLRead.FieldByName('CREATORKEY').AsInteger;
		  masFK[4] := IBSQLRead.FieldByName('CURRKEY').AsInteger;        //null??
		  masFK[5] := IBSQLRead.FieldByName('EDITORKEY').AsInteger;
		  masFK[6] := IBSQLRead.FieldByName('TRANSACTIONKEY').AsInteger; //null??
		
          id = IBSQLRead.FieldByName('ID').AsInteger;		
	      //���� ������������� �������
	      if ( X.IndexOf(id)<> -1) then //����� ��� ������������������ ������  (-1 ���� �����������)
	      begin
            M[id-147000000] := 1;

	        for i:=0 to masFK.Count-1 do
			begin
			  while masFK[i] = NULL do i=i+1;  //�� ������������ FK � NULL
			  M[masFK[i]-147000000] := 1;
			  if (M2[masFK[i]-147000000] = 1) then // M2.Has(...)
			  begin 
			    M2.Exclude(...);  //
			  end;
	        end;
			 //�� L ������� ��� fk ������ �����
			 for i := 0 to ListPkFk.Count-1 do   
			 begin 
			 if (ListPkFk.Names[i]= id )  then //PK GD_DOCUMENT
			 //������� ��������-���� �� ������          //  ListPkFk.ValueFromIndex[i]  //ListPkFk.Value - ��� FK 
			 ListPkFk.Delete(i);                         ///??
			 end;
	      end;
	      //���� ������ �� ������������� �������
		  else 
		  begin
		    M2[id-147000000] := 1;
			
			for i:=0 to masFK.Count-1 do
			begin
			  while masFK[i] = NULL do i=i+1;  //�� ������������ FK � NULL
              if(M[masFK[i]-147000000] = 0) then
              begin
			   //�������� ��������-���� � ListPkFk
               commaTextPkFk := commaTextPkFk + ', ' + id +'=' + masFK[i];
              end;			   
			end; 
			ListPkFk.CommaText := commaTextPkFk;
		  end;
		  
	      IBSQLRead.Next;
	    end;
   finally
     IBSQLRead.Close;
   end;
   
   //��������� �������
   IBSQLRead.SQL.Text := ' SELECT doc.ID, doc.PARENT, doc.DOCUMENTTYPEKEY, doc.TRTYPEKEY, doc.TRANSACTIONKEY, ' + 
   ' doc.COMPANYKEY, doc.CREATORKEY, doc.CURRKEY, doc.EDITORKEY ' +
   ' FROM GD_DOCUMENT doc ' +
   ' WHERE doc.PARENT is NOT NULL ';
   try
	 IBSQLRead.ExecQuery;
	 if IBSQLRead.RecordCount > 0 then
     begin
		while not IBSQLRead.Eof do
        begin
          if (M[IBSQLRead.FieldByName('PARENT').AsInteger - 147000000] = 1) then // M.Has(...)
		  begin 
			M[IBSQLRead.FieldByName('ID').AsInteger - 147000000] = 1;
			
			/// � FK ����??
		  end;
   
          IBSQLRead.Next;
	    end;
   finally
     IBSQLRead.Close;
   end;
   
end;
  
  
//========================================================[temp]end : ������� �� GD_RUID ������������ ������ (id)
procedure 
//....
begin
    for i:=0 to M.Count-1  do 
	begin 
	 if(M[i]=0) then  
       IBSQLWrite.SQL.Text := ' DELETE FROM  GD_RUID ' +
	    ' WHERE id = :id ';
	   try
         IBSQLWrite.ExecQuery;
         IBSQLWrite.ParamByName('id').AsInteger := i + 147000000 + 1;
	   finally
         IBSQLWrite.Close;
       end;
    end;
 end;

 
end.