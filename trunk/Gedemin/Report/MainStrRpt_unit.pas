unit MainStrRpt_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  xReport, IBDatabase, Db, IBCustomDataSet, IBQuery, StdCtrls, rp_ClassReportFactory,
  FR_Class, FR_DSet, FR_DBSet, FR_Desgn, DBCtrls, Provider, DBClient,
  Grids, DBGrids, IBTable;

type
  TForm1 = class(TForm)
    xReport1: TxReport;
    dsResult: TDataSource;
    IBQuery1: TIBQuery;
    IBDatabase1: TIBDatabase;
    IBTransaction1: TIBTransaction;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    frReport1: TfrReport;
    Button6: TButton;
    frCompositeReport1: TfrCompositeReport;
    IBQuery2: TIBQuery;
    frDesigner1: TfrDesigner;
    frDBDataSet1: TfrDBDataSet;
    frDBDataSet2: TfrDBDataSet;
    Button7: TButton;
    ClientDataSet1: TClientDataSet;
    DataSetProvider1: TDataSetProvider;
    IBQuery3: TIBQuery;
    Button8: TButton;
    Button9: TButton;
    Button10: TButton;
    Button11: TButton;
    DataSource1: TDataSource;
    DataSource2: TDataSource;
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
    Button12: TButton;
    IBTable1: TIBTable;
    Button13: TButton;
    Button14: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure Button13Click(Sender: TObject);
    procedure Button14Click(Sender: TObject);
  private
    FReportFactory: TReportFactory;
    procedure CompliteDataSetStream(const AnStream: TStream;
     const AnDataSet: TDataSet; const AnFetchBlob: Boolean = False);
  public
    { Public declarations }
  end;

type
  TUpdateClientDS = class(TClientDataSet)
  private
    FDataSet: TDataSet;
  public
    constructor Create(AnDataSet: TDataSet);
  end;

var
  Form1: TForm1;

implementation

uses
  rp_StreamRTF, rp_BaseReport_unit, rp_report_const, gd_SetDatabase;

{$R *.DFM}

procedure TForm1.FormCreate(Sender: TObject);
begin
  FReportFactory := TReportFactory.Create(Self);
  IBQuery1.Open;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  xReport1.Execute;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  DD: TxReportStream;
  Str: TReportTemplate;
  RptResult: TReportResult;
begin
  DD := TxReportStream.Create(Self);
  try
    Str := TReportTemplate.Create;
    try
      RptResult := TReportResult.Create;
      try
        Str.LoadFromFile('temp.rtf');
        DD.ReportResult.LoadFromFile('555.cds');
        DD.ReportTemplate := Str;
        DD.Execute;
      finally
        RptResult.Free;
      end;
    finally
      Str.Free;
    end;
  finally
    DD.Free;
  end;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
  Str: TReportTemplate;
  ddd: TRTFReportInterface;
begin
  ddd := TRTFReportInterface.Create;
  Str := TReportTemplate.Create;
  try
    Str.LoadFromFile('temp.rtf');
    ddd.ReportResult.LoadFromFile('555.cds');
    ddd.ReportTemplate := Str;
  finally
    Str.Free;
  end;
  with TrpBuildReportThread.Create(ddd) do
  begin
 //   Resume;
  end;
  ddd := nil;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FReportFactory.Free;
end;

procedure TForm1.Button4Click(Sender: TObject);
var
  TemplateStructure: TTemplateStructure;
  ReportResult: TReportResult;
  Par: Variant;
begin
  TemplateStructure := TTemplateStructure.Create;
  try
    ReportResult := TReportResult.Create;
    try
      ReportResult.LoadFromFile('555.cds');
      TemplateStructure.ReportTemplate.LoadFromFile('StreamTest.rtf');
      TemplateStructure.TemplateType := 'RTF';
      Par := VarArrayOf([10, 12, 20, VarArrayOf([1, 2, 3])]);
      FReportFactory.CreateReport(TemplateStructure, ReportResult, Par);
    finally
      ReportResult.Free;
    end;
  finally
    TemplateStructure.Free;
  end;
end;

procedure TForm1.Button5Click(Sender: TObject);
var
  TemplateStructure: TTemplateStructure;
  ReportResult: TReportResult;
  Par: Variant;
begin
  TemplateStructure := TTemplateStructure.Create;
  try
    ReportResult := TReportResult.Create;
    try
      ReportResult.LoadFromFile('555.cds');
      Par := VarArrayOf([10, 12, 20]);
      FReportFactory.CreateReport(TemplateStructure, ReportResult, Par);
    finally
      ReportResult.Free;
    end;
  finally
    TemplateStructure.Free;
  end;
end;

procedure TForm1.Button6Click(Sender: TObject);
var
  TemplateStructure: TTemplateStructure;
  ReportResult: TReportResult;
  Par: Variant;
  I: Integer;
begin
  TemplateStructure := TTemplateStructure.Create;
  try
    TemplateStructure.ReportTemplate.LoadFromFile('fastreport\test.frf');
    TemplateStructure.RealTemplateType := ttFR;
    ReportResult := TReportResult.Create;
    try
      I := ReportResult.AddDataSet('MyTable');
      ReportResult.DataSet[I].LoadFromFile('fastreport\fastreport_data.cds');
      Par := VarArrayOf([10, 12, 20]);
      FReportFactory.CreateReport(TemplateStructure, ReportResult, Par);
    finally
      ReportResult.Free;
    end;
  finally
    TemplateStructure.Free;
  end;
end;

procedure TForm1.Button7Click(Sender: TObject);
var
  StartTime: TDateTime;
  Buf: Pointer;
  I: Integer;
  FT: TFieldType;
begin
  StartTime := Now;
  ClientDataSet1.SetProvider(DataSetProvider1);
  DataSetProvider1.DataSet := IBQuery3;
  IBQuery3.Open;
  GetMem(Buf, 1000);
  try
{    FillChar(Buf^, 1000, 0);
    IBQuery3.FieldByName('loctimestamp').GetData(Buf);
    FT := IBQuery3.FieldByName('loctimestamp').DataType;}
    IBQuery3.DisableControls;
    try
//      IBQuery3.Last;
      ClientDataSet1.Open;
    finally
      IBQuery3.EnableControls;
    end;
{    FillChar(Buf^, 1000, 0);
    ClientDataSet1.FieldByName('loctimestamp').GetData(Buf);
    I := ClientDataSet1.FieldByName('loctimestamp').DataSize;
//    ClientDataSet1.FieldByName('loctimestamp').Required;
    FT := ClientDataSet1.FieldByName('loctimestamp').DataType;}
  finally
    FreeMem(Buf);
  end;
  ShowMessage(TimeToStr(Now - StartTime));
  ClientDataSet1.SaveToFile('Message.cds');
end;

procedure TForm1.Button8Click(Sender: TObject);
var
  FStr, FTrgStr: TFileStream;
  I: Integer;
  Str: String;
  Bt: Byte;
begin
  FStr := TFileStream.Create('Message.cds', fmOpenRead);
  try
    FTrgStr := TFileStream.Create('Message_txt.cds', fmCreate);
    try
      while FStr.Position < FStr.Size do
      begin
        I := 0;
        Str := IntToHex(FStr.Position, 8);
        FTrgStr.Write(Str[1], Length(Str));
        FTrgStr.Write(#0#0, 2);
        while  (I < 16) and (FStr.Position < FStr.Size) do
        begin
          FStr.ReadBuffer(Bt, SizeOf(Bt));
          Str := IntToHex(Bt, 2) + ' ';
          FTrgStr.Write(Str[1], Length(Str));

          Inc(I);
        end;
        FStr.Position := FStr.Position - 16;
        FTrgStr.Write(#0#0, 2);
        SetLength(Str, 16);
        FStr.ReadBuffer(Str[1], 16);
        FTrgStr.Write(Str[1], Length(Str));
        FTrgStr.Write(#13#10, 2);
      end;
    finally
      FTrgStr.Free;
    end;
  finally
    FStr.Free;
  end;
end;

procedure TForm1.Button9Click(Sender: TObject);
var
  Buf: Pointer;
//  LocNum: Numeric
begin
  IBQuery3.Open;
  GetMem(Buf, 1000);
  try
    FillChar(Buf^, 1000, 0);
    IBQuery3.Fields.FieldByName('locnumeric').GetData(Buf);
  finally
    FreeMem(Buf);
  end;
end;

procedure TForm1.Button10Click(Sender: TObject);
var
  StartTime: TDateTime;
  I: Integer;
  Buf: Pointer;
begin
  ClientDataSet1.Close;
  ClientDataSet1.Fields.Clear;
  StartTime := Now;
  ClientDataSet1.SetProvider(DataSetProvider1);
  DataSetProvider1.DataSet := IBQuery3;
  IBQuery3.Open;
  IBQuery3.Last;
  IBQuery3.First;
  for I := 0 to IBQuery3.FieldCount - 1 do
  begin
    ClientDataSet1.Fields.Add(IBQuery3.Fields[I]);
//    ClientDataSet1.Fields.Assign(IBQuery3.Fields[I]);
//    ClientDataSet1.FieldDefs.Add(IBQuery3.Fields[I].FieldName, IBQuery3.Fields[I].DataType,
//     IBQuery3.Fields[I].Size, False);
  end;

  ClientDataSet1.CreateDataSet;
{  GetMem(Buf, 10000);
  try
    while not IBQuery3.Eof do
    begin
      ClientDataSet1.Insert;
      for I := 0 to IBQuery3.FieldCount - 1 do
      begin
        case IBQuery3.Fields[I].DataType of
          ftBCD, ftBlob, ftMemo, ftGraphic, ftFmtMemo:
          ClientDataSet1.Fields[I].Assign(IBQuery3.Fields[I]);
        else
          IBQuery3.Fields[I].GetData(Buf);
          ClientDataSet1.Fields[I].SetData(Buf);
        end;
      end;
//        ClientDataSet1.Fields[I].Value := IBQuery3.Fields[I].Value;
      ClientDataSet1.Post;
//      ClientDataSet1.Cancel;
      IBQuery3.Next;
    end;
  finally
    FreeMem(Buf);
  end;                                    }
  ShowMessage(TimeToStr(Now - StartTime));
  ClientDataSet1.SaveToFile('Message2.cds');
  for I := 0 to IBQuery3.FieldCount - 1 do
    ClientDataSet1.Fields.Remove(IBQuery3.Fields[I]);
  ClientDataSet1.Close;
end;

{ TUpdateClientDS }

constructor TUpdateClientDS.Create(AnDataSet: TDataSet);
begin
  inherited Create(nil);

  FDataSet := AnDataSet;
end;

procedure TForm1.Button11Click(Sender: TObject);
begin
  if ClientDataSet1.Active then
    ClientDataSet1.SaveToFile('Message.cds');
  ClientDataSet1.Close;
  ClientDataSet1.LoadFromFile('Message.cds');
end;

procedure TForm1.Button12Click(Sender: TObject);
var
  StartTime: TDateTime;
  I: Integer;
  Buf: Pointer;
  FStr: TStream;
  BArray: array of Byte;
  LBArray: Word;
begin
  ClientDataSet1.Close;
  ClientDataSet1.Fields.Clear;
  StartTime := Now;
  IBQuery3.Open;
  FStr := TMemoryStream.Create;//TFileStream.Create('Message3.cds', fmCreate);
  try
    CompliteDataSetStream(FStr, IBQuery3);
    FStr.Position := 0;
    ClientDataSet1.SetProvider(nil);
    ClientDataSet1.LoadFromStream(FStr);
  finally
    FStr.Free;
  end;
  ShowMessage(TimeToStr(Now - StartTime));
end;

procedure TForm1.CompliteDataSetStream(const AnStream: TStream;
  const AnDataSet: TDataSet; const AnFetchBlob: Boolean = False);
const
  LEmptyByte = 1;
  LEmptyFormat = SizeOf(Byte) * 8 div 2;
  SizePosition = 14;
  FreeBufferDelta = $A00000;
var
  TempClientDS: TClientDataSet;
  I, L, OldPosition: Integer;
  BArray: array of Byte;
  LBArray: Word;
  Buffer: Pointer;
  FiedNameSize: Byte;

  procedure WriteRecord;
  var
    J, K : Integer;
    TempStr: TStream;
    TempField: TField;
  begin
    FillChar(BArray[0], LBArray, 0);
    for K := 0 to AnDataSet.FieldCount - 1 do
    begin
      TempField := AnDataSet.Fields[K];
      if (TempField.IsNull) or (not AnFetchBlob and
       (TempField.DataType in [ftBlob, ftMemo, ftGraphic, ftFmtMemo])) then
      begin
        J := (K div LEmptyFormat + 1);
        BArray[J] := BArray[J] or (1 shl (K mod 4 * 2));
      end;
    end;

    AnStream.Write(BArray[0], LBArray);

    for K := 0 to AnDataSet.FieldCount - 1 do
    begin
      TempField := AnDataSet.Fields[K];
      if not TempField.IsNull then
        case TempField.DataType of
          ftBlob, ftMemo, ftGraphic, ftFmtMemo:
          begin
            if AnFetchBlob then
            begin
              TempStr := AnDataSet.CreateBlobStream(TempField, bmRead);
              try
                J := TempStr.Size;
                AnStream.Write(J, TempField.Tag);
                if J > 0 then
                  AnStream.CopyFrom(TempStr, J);
              finally
                TempStr.Free;
              end;
            end;
          end;
          ftBCD:
          begin
            TempClientDS.Fields[K].Assign(TempField);
            TempClientDS.Fields[K].GetData(Buffer);
            AnStream.Write(Buffer^, TempField.Tag);
          end;
          ftWideString, ftString:
          begin
            TempField.GetData(Buffer);
            J := Length(TempField.AsString);
            AnStream.Write(J, TempField.Tag);
            AnStream.Write(Buffer^, J);
          end
        else
          TempField.GetData(Buffer);
          AnStream.Write(Buffer^, TempField.Tag);
        end;
    end;
  end;
begin
  AnStream.Position := 0;
  AnStream.Size := 0;
  if not AnDataSet.Active then
    Exit;

  AnDataSet.DisableControls;
  try
    AnDataSet.Last;
    TempClientDS := TClientDataSet.Create(nil);
    try
      LBArray := LEmptyByte + (AnDataSet.FieldCount - 1) div LEmptyFormat + 1;
      SetLength(BArray, LBArray);

      for I := 0 to AnDataSet.FieldCount - 1 do
        TempClientDS.FieldDefs.Add(AnDataSet.Fields[I].FieldName, AnDataSet.Fields[I].DataType,
         AnDataSet.Fields[I].Size, AnDataSet.Fields[I].Required);{}
//        TempClientDS.Fields.Add(AnDataSet.Fields[I]);

      TempClientDS.CreateDataSet;
      TempClientDS.SaveToStream(AnStream);

      GetMem(Buffer, 10000);
      FillChar(Buffer^, 10000, 0);
      try
        AnStream.Position := 0;
        AnStream.ReadBuffer(Buffer^, AnStream.Size);
        for I := 0 to AnDataSet.FieldCount - 1 do
        begin
          FiedNameSize := Length(AnDataSet.Fields[I].FieldName);
          L := Pos(Char(FiedNameSize) + AnDataSet.Fields[I].FieldName, PString(@Buffer)^);
          AnDataSet.Fields[I].Tag := SmallInt(TDnByteArray(Buffer)[L + FiedNameSize + SizeOf(FiedNameSize) - 1]);
        end;

        TempClientDS.Insert;
        AnDataSet.First;
        while not AnDataSet.Eof do
        begin
          if AnStream.Size = AnStream.Position then
          begin
            OldPosition := AnStream.Position;
            AnStream.Size := AnStream.Size + FreeBufferDelta;
            AnStream.Position := OldPosition;
          end;
          WriteRecord;

          AnDataSet.Next;
        end;
        TempClientDS.Cancel;
        AnStream.Size := AnStream.Position;
        AnStream.Position := SizePosition;
        L := AnDataSet.RecordCount;
        AnStream.Write(L, SizeOf(L));
      finally
        FreeMem(Buffer);
      end;
    finally
      TempClientDS.FieldDefs.Clear;
{      for I := 0 to AnDataSet.FieldCount - 1 do
        TempClientDS.Fields.Remove(AnDataSet.Fields[I]);{}
      TempClientDS.Free;
    end;
  finally
    AnDataSet.EnableControls;
  end;
end;

procedure TForm1.Button13Click(Sender: TObject);
var
  I, J, K: Integer;
  StTime1, StTime2: TDateTime;
  Str: TStream;
  MStr: TMemoryStream;
  M: Integer;
begin
  IBTable1.Open;
  IBQuery3.Open;
  IBTable1.Insert;
  I := IBTable1.FieldByName('locblob').Index;
  J := IBQuery3.FieldByName('locblob').Index;
  MStr := TMemoryStream.Create;
  try
    StTime1 := Now;
    for K := 1 to 10000 do
    begin
//      IBTable1.Fields[I].Assign(IBQuery3.Fields[J]);
      if MStr.Size = MStr.Position then
        MStr.Size := MStr.Size + 10000000;
      Str := IBQuery3.CreateBlobStream(IBQuery3.Fields[J], bmRead);
      try
        M := Str.Size;
        MStr.Write(M, SizeOf(M));
        MStr.CopyFrom(Str, M);
      finally
        Str.Free;
      end;
    end;
    StTime1 := Now - StTime1;
  finally
    MStr.Free;
  end;
  IBTable1.Cancel;
  ClientDataSet1.Close;
  ClientDataSet1.FieldDefs.Clear;
  ClientDataSet1.FieldDefs.Add(IBQuery3.FieldByName('locblob').FieldName,
   IBQuery3.FieldByName('locblob').DataType, IBQuery3.FieldByName('locblob').Size,
   IBQuery3.FieldByName('locblob').Required);
  ClientDataSet1.CreateDataSet;
  ClientDataSet1.Insert;
  StTime2 := Now;
  for K := 1 to 10000 do
    ClientDataSet1.Fields[0].Assign(IBQuery3.Fields[J]);
  StTime2 := Now - StTime2;
  ClientDataSet1.Cancel;
  ShowMessage(TimeToStr(StTime1) + '  ' + TimeToStr(StTime2));
end;

procedure TForm1.Button14Click(Sender: TObject);
var
  MStr, Str: TStream;
  I, J, M, K: Integer;
  StTime1: TDateTime;
begin
  IBTable1.Open;
  IBQuery3.Open;
  IBTable1.Insert;
  J := IBQuery3.FieldByName('body').Index;
  IBQuery3.DisableControls;
  MStr := TMemoryStream.Create;
  try
    StTime1 := Now;
    for K := 1 to 10000 do
//    while not IBQuery3.Eof do
    begin
//      IBTable1.Fields[I].Assign(IBQuery3.Fields[J]);
      if MStr.Size = MStr.Position then
        MStr.Size := MStr.Size + 10000000;
      Str := IBQuery3.CreateBlobStream(IBQuery3.Fields[J], bmRead);
      try
{        M := Str.Size;
        MStr.Write(M, SizeOf(M));
        MStr.CopyFrom(Str, M);
 }     finally
        Str.Free;
      end;
      IBQuery3.Next;
    end;
    StTime1 := Now - StTime1;
  finally
    MStr.Free;
  end;
  ShowMessage(TimeToStr(StTime1));
  IBQuery3.EnableControls;
end;

end.

