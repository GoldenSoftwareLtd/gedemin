unit rqoperation;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, BaseOperation, Windows;

const
  LoadPath = 'cl\';
  SavePath = 'ov\';
  DelayPath = 'dl\';

type
  TGoodInfo = class(TObject)
  private
    FBarCode, FName: String;
    FWeight: Double;
    FError: Double;
    FPosition: Integer;
  public
    constructor Create;

    property BarCode: String read FBarCode write FBarCode;
    property Weight: Double read FWeight write FWeight;
    property Error: Double read FError write FError;
    property Name: String read FName write FName;
    property Position: Integer read FPosition write FPosition;
  end;


  { TOperationRQ }

  TOperationRQ = class(TBaseOperation)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { private declarations }
    CurrGood: String;
  protected
    procedure SetBarCode(const AKey: String); override;
    procedure LoadDelayRequest(const AName: String);
    procedure NewMemo; override;
    procedure SaveToFile; override;
    procedure DeleteLastItem; override;
  public
    { public declarations }
    procedure LoadRequest(const AnUserID, AName: String);
    procedure Clear;
    procedure AddPositionToMemo(const AString: String); override;
  end;


implementation

{$R *.lfm}
uses
  JcfStringUtils, MessageForm, BaseAddInformation, terminal_common, ProjectCommon;

const
  InfoLine = 3;
  PrefixSave = 'ov';

 procedure TOperationRQ.FormCreate(Sender: TObject);
 begin
   inherited;
   mTP.Height := ((GetSystemMetrics(SM_CYSCREEN) - 2 * ChildSizing.TopBottomSpacing) * 81) div 100;
   CurrGood := '';
 end;

 procedure TOperationRQ.FormDestroy(Sender: TObject);
 begin
   Clear;
   inherited;
 end;

 procedure TOperationRQ.LoadRequest(const AnUserId, AName: String);
 var
   Request: TStringList;
   Temps: String;
   I, Temp, Index: Integer;
   Good: TGoodInfo;
 begin
   Request := TStringList.Create;
   try
     Request.Delimiter := ',';
     Request.QuoteChar := ';';
     Temps := Trim(ReadFileToString(ExtractFilePath(Application.ExeName) + LoadPath + AnUserId + '.TXT'));
     Temps := Copy(Temps, StrIPos(';', Temps), Length(Temps));
     Request.DelimitedText := Temps;

    {SHCODE := TStringList.Create;
    try
      SHCODE.Delimiter := ',';
      SHCODE.QuoteChar := ';';
      Temps := Trim(ReadFileToString(ExtractFilePath(Application.ExeName) + 'SHCODE_GOODS.TXT'));
      Temps := Copy(Temps, StrIPos(';', Temps), Length(Temps));
      SHCODE.DelimitedText := Temps; }

      for I := 0 to Request.Count - 1 do
      begin
        Index := FSHCODE.IndexOfName(Request.Names[I]);
        if Index <> - 1 then
        begin
          Good := TGoodInfo.Create;
          Good.BarCode := Request.Names[I];
          Good.Weight := StrToFloat(Request.ValueFromIndex[I]);
          Temp := StrIPos('=', FSHCODE.ValueFromIndex[Index]);
          Good.Name := Copy(FSHCODE.ValueFromIndex[Index], 1, Temp - 1);
          Good.Error := StrToFloat(Copy(FSHCODE.ValueFromIndex[Index], Temp + 1, Length(FSHCODE.ValueFromIndex[Index])));
          FMemoPositions.AddObject(Request.Names[I], Good);
        end else
        begin
          Good := TGoodInfo.Create;
          Good.BarCode := Request.Names[I];
          Good.Name := Request.Names[I];
          Good.Weight := StrToInt(Request.ValueFromIndex[I]);
          FMemoPositions.AddObject(Request.Names[I], Good);
        end;
      end;
    {finally
      SHCODE.Free;
    end;}
  finally
    Request.Free;
  end;

  if AName <> '' then
  begin
    LoadDelayRequest(AName);
  {  SysUtils.DeleteFile(ExtractFilePath(Application.ExeName) + DelayPath + AName + '.txt');  }
  end;
 end;

 procedure TOperationRQ.LoadDelayRequest(const AName: String);
 var
  Weight: Double;
  WeightInGram: Integer;
  WeightInGramT: Integer;
  Date: TDateTime;
  Number: Integer;
  NTara: Integer;
  Npart: String;
  StrTara: String;
  NumT: String;
  NameGoods, Code, Key: String;
  Index, I: Integer;
  SL: TStringList;
 begin
   SL := TStringList.Create;
   try
     SL.LoadFromFile(ExtractFilePath(Application.ExeName) + DelayPath + AName + '.TXT');
     FPosition.Clear;
     for I := 0 to DocumentLine - 1 do
       FPosition.Add(SL[I]);
     for I := DocumentLine to SL.Count - 1 do
     begin
       Key := Copy(SL[I], 1, Length(SL[I]) - 1);
       GetInfoGoods(Key, Code, NameGoods, WeightInGram, Date, Number, Npart, NTara, WeightInGramT, NumT);
       case NTara of
         0: StrTara := 'ящ';
         1: StrTara := 'общ';
         2: StrTara := 'тара';
         3: StrTara := 'уп';
       end;
       NameGoods := NameGoods + '('+ StrTara +')';
       Weight := WeightInGram/1000;
       if  NTara = 0 then
         Inc(FGoodsCount);
       if  NTara = 1 then
          Inc(FGoodsCount, (StrToInt(NumT) div Number));
       FTotalWeight := FTotalWeight + Weight;
       Index := FMemoPositions.IndexOf(Code);
       if (Index <> - 1) and ((FMemoPositions.Objects[Index] as TGoodInfo).Weight > (FMemoPositions.Objects[Index] as TGoodInfo).Error) then
       begin
         (FMemoPositions.Objects[Index] as TGoodInfo).Weight := (FMemoPositions.Objects[Index] as TGoodInfo).Weight - Weight;
         FPosition.Add(Key + Separator);
         CurrGood := NameGoods + '=' + FloatToStr(Weight) + 'кг';
       end else
       begin
         if Index <> - 1 then
           (FMemoPositions.Objects[Index] as TGoodInfo).Weight := (FMemoPositions.Objects[Index] as TGoodInfo).Weight - Weight;
         FPosition.Add(Key + Separator);
         CurrGood := NameGoods + '=' + FloatToStr(Weight) + 'кг';
       end;
     end;
   finally
     SL.Free;
   end
end;

 procedure TOperationRQ.DeleteLastItem;
 var
   Weight: Integer;
   WeightT: Integer;
   Date: TDateTime;
   Number: Integer;
   NameGoods, Code: String;
   Index: Integer;
   TempS: String;
   Npart: String;
   NumT: String;
   NTara: Integer;
 begin
   TempS := FPosition[FPosition.Count - 1];
   SetLength(TempS, Length(TempS) - 1);

   GetInfoGoods(TempS, Code, NameGoods, Weight, Date, Number, Npart, NTara, WeightT, NumT);
   Index := FMemoPositions.IndexOf(Code);

   if (Index <> - 1) then
     (FMemoPositions.Objects[Index] as TGoodInfo).Weight := (FMemoPositions.Objects[Index] as TGoodInfo).Weight + Weight/1000;
   FTotalWeight := FTotalWeight -  Weight/1000;
   FPosition.Delete(FPosition.Count - 1);

  { if (Weight > weight_for_checking_sites)
    and (Length(TempS) = length_code_for_checking_sites)
   then
     Dec(FGoodsCount, Number)
   else
     if  Number > 0  then Dec(FGoodsCount);}
   if  NTara = 0 then
     Dec(FGoodsCount);
   if  NTara = 1 then
      Dec(FGoodsCount, (StrToInt(NumT) div Number));
 end;

 procedure TOperationRQ.Clear;
 var
   I: Integer;
 begin
   for I := InfoLine to FMemoPositions.Count - 1 do
     FMemoPositions.Objects[I].Free;
   FMemoPositions.Clear;
 end;

 procedure TOperationRQ.SetBarCode(const AKey: String);
 var
  Weight: Double;
  NameGoods, Code: String;
  Index: Integer;
  WeightInGram, Number: Integer;
  WeightInGramT: Integer;
  Date: TDateTime;
  BarCode: String;
  TempS: String;
  Count: Integer;
  Npart: String;
  NumT: String;
  StrTara: String;
  NTara: Integer;
 begin
   FSetBarCode := True;
   try
     BarCode := Trim(AKey);
     if CheckBarCode(BarCode) then
     begin
       GetInfoGoods(AKey, Code, NameGoods, WeightInGram, Date, Number, Npart, Ntara, WeightInGramT, NumT);
       if not FEnterCount and
         (WeightInGram > weight_for_checking_sites) and
         (Length(BarCode) = length_code_for_checking_sites) then
       begin
         TempS := Trim(TBaseAddInformation.Execute('Введите кол-во мест: '));
         if (TempS > '')
           and (Length(TempS) <= 2)
           and TryStrToInt(TempS, Count)
         then
           BarCode := CreateBarCode(WeightInGram, Date, Code, Count, Npart, Ntara, WeightInGramT);
       end;
       Weight := WeightInGram/1000;

       Index := FMemoPositions.IndexOf(Code);
       if ((Index <> - 1) and ((FMemoPositions.Objects[Index] as TGoodInfo).Weight > (FMemoPositions.Objects[Index] as TGoodInfo).Error)) then
       begin
         (FMemoPositions.Objects[Index] as TGoodInfo).Weight := (FMemoPositions.Objects[Index] as TGoodInfo).Weight - Weight;
         {if (FMemoPositions.Objects[Index] as TGoodInfo).Weight <= (FMemoPositions.Objects[Index] as TGoodInfo).Error then
         begin
           FMemoPositions.Objects[Index].Free;
           FMemoPositions.Delete(Index);
         end; }
         AddPosition(BarCode);
         FTotalWeight := FTotalWeight + Weight;
         //FPosition.Add(AKey + Separator);
         case NTara of
           0: StrTara := 'ящ';
           1: StrTara := 'общ';
           2: StrTara := 'тара';
           3: StrTara := 'уп';
         end;
         NameGoods := NameGoods + '('+ StrTara +')';
         CurrGood := NameGoods + '=' + FloatToStr(Weight) + 'кг';
       end else
       begin
         if (Ntara = 2)  then
         begin
           if Index <> - 1 then
               (FMemoPositions.Objects[Index] as TGoodInfo).Weight := (FMemoPositions.Objects[Index] as TGoodInfo).Weight - Weight;
           AddPosition(BarCode);
           CurrGood := NameGoods + '=' + FloatToStr(Weight) + 'кг';
         end else
         case MessageForm.MessageDlg('Позиции нет в заявке! Добавить товар в документ?',
           'Внимание', mtInformation, [mbYes, mbNo]) of
           IDYES:
           begin
             if Index <> - 1 then
               (FMemoPositions.Objects[Index] as TGoodInfo).Weight := (FMemoPositions.Objects[Index] as TGoodInfo).Weight - Weight;
            // FPosition.Add(BarCode + Separator);
            FTotalWeight := FTotalWeight + Weight;
            AddPosition(BarCode);
            CurrGood := NameGoods + '=' + FloatToStr(Weight) + 'кг';
           end;
         end;
       end;
       NewMemo;
     end;
   finally
     FSetBarCode := False;
   end;
 end;

 procedure TOperationRQ.SaveToFile;
 var
   Temps: String;
   F: TextFile;
   I: Integer;
 begin
   Temps := PrefixSave;

   for I := 0 to DocumentLine - 3 do
     Temps := Temps + FPosition[I];
   //Удаляем отложенную заявку
   SysUtils.DeleteFile(ExtractFilePath(Application.ExeName) + DelayPath + StringReplace(Temps, Separator, '', [rfReplaceAll]) + '.txt');
   if (MessageForm.MessageDlg(PChar('Заявка сформирована полностью?'),
     'Внимание', mtInformation, [mbYes, mbNo]) = mrYes)
   then
     FPosition.SaveToFile(ExtractFilePath(Application.ExeName) + SavePath + StringReplace(Temps, Separator, '', [rfReplaceAll]) + '.txt')
   else
     FPosition.SaveToFile(ExtractFilePath(Application.ExeName) + DelayPath + StringReplace(Temps, Separator, '', [rfReplaceAll]) + '.txt');

   if not FileExists(ExtractFilePath(Application.ExeName) + 'OPERATIONLOG.TXT') then
   begin
     AssignFile(F, ExtractFilePath(Application.ExeName) + 'OPERATIONLOG.TXT');
     Rewrite(F);
     try
       WriteLn(F,  StringReplace(FPosition[4] + FPosition[5] + Copy(FPosition[0], 2, length(FPosition[0])) + '=' + Temps, ';', '', [rfReplaceAll]));
     finally
       CloseFile(F);
     end;
   end else
   begin
     AssignFile(F, ExtractFilePath(Application.ExeName) + 'OPERATIONLOG.TXT');
     Append(F);
     try
       WriteLn(F,  StringReplace(FPosition[4] + FPosition[5] + Copy(FPosition[0], 2, length(FPosition[0])) + '=' + Temps, ';', '', [rfReplaceAll]));
     finally
       CloseFile(F);
     end;
   end;
 end;

 procedure TOperationRQ.AddPositionToMemo(const AString: String);
 begin
   FMemoPositions.Add(AString);
 end;

 procedure TOperationRQ.NewMemo;
 const
   EndStr = #13#10;
 var
   I: Integer;
   Temps: String;

 begin
   Temps := '';
   mTP.Clear;
   for I := 0 to InfoLine - 1 do
     Temps := Temps + FMemoPositions[I] + EndStr;

   Temps := Temps + 'Кол-во коробок с товаром: ' + IntToStr(FGoodsCount) + EndStr;
   Temps := Temps + 'Общий вес: ' +  FloatToStrF(FTotalWeight, ffFixed, 6, 3) + 'кг' + EndStr;
   if CurrGood <> '' then
     begin
       Canvas.Font := mTP.Font;
       Temps := Temps + StrFillChar('-', (mTP.VertScrollBar.ClientSize div Canvas.TextWidth('-')));
       Temps := Temps + 'Добавлена позиция: ' + CurrGood +
         EndStr + StrFillChar('-', (mTP.VertScrollBar.ClientSize div Canvas.TextWidth('-')));
     end
   else
     begin
       Temps := Temps + StrFillChar('-', (mTP.VertScrollBar.ClientSize div Canvas.TextWidth('-')));
     end;

   for I := InfoLine to FMemoPositions.Count - 1 do
     if (FMemoPositions.Objects[I] as TGoodInfo).Weight > (FMemoPositions.Objects[I] as TGoodInfo).Error then
       Temps := Temps + (FMemoPositions.Objects[I] as TGoodInfo).Name + '=' + FloatToStr((FMemoPositions.Objects[I] as TGoodInfo).Weight) + 'кг' + EndStr;
   mTP.Lines.Text := Temps;

   CurrGood := '';
   {for I := 0 to InfoLine - 1 do
     mTP.Lines.Add(FMemoPositions[I]);
   for I := InfoLine to FMemoPositions.Count - 1 do
     mTP.Lines.Add((FMemoPositions.Objects[I] as TGoodInfo).Name + '=' + FloatToStr((FMemoPositions.Objects[I] as TGoodInfo).Weight) + 'кг'); }
 end;

 constructor TGoodInfo.Create;
 begin
   inherited;
   FPosition := -1;
   FBarCode := '';
   FName := '';
   FError := 0;
   FWeight := 0;
 end;

 procedure TOperationRQ.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
 var
   Code, NameGoods: String;
   Weight: Integer;
   WeightT: Integer;
   Date: TDateTime;
   Number: Integer;
   Npart: String;
   NumT: String;
   NTara: Integer;
 begin
    case Key of
      194:
      begin
        if (FPosition.Count > DocumentLine) then
        begin
          GetInfoGoods(FPosition[FPosition.Count - 1], Code, NameGoods, Weight, Date, Number,  Npart, NTara, WeightT, NumT);
          if (MessageForm.MessageDlg(PChar('Удалить последнюю позицию документа "' + NameGoods +
            '  ' + FloatToStr(Weight/1000) + 'кг "?'),
            'Внимание', mtInformation, [mbYes, mbNo]) = mrYes) then
          begin
            DeleteLastItem;
            Key := 0;
            NewMemo;
          end;
        end;
      end
    else
      inherited;
    end;
 end;

procedure TOperationRQ.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   inherited;
end;

end.

