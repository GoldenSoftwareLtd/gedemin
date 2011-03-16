unit gsMorph;

{  ������ ������ ��������� �������������� ������� ���.

  �������������� ���������� � ������� ��������� SetCase � �����������:
  - TheWord: �������� �������, ��� ��� ��������. ��������� �������
             �����������. ��������� ������ ���� ������� �� ����������
             �������;
  - TheCase: ����� (��������� csXXXX), � ������� ����� �������������
             �����;
  - Gender:  ��� (��������� gdXXXX). ������ ����������� ������� ���
             ������� ���;
  - Name:    ��������� nmXXXX ��������������� �� ��������� �����������:
             ��� ������� - ��� ����������� (nmOwn);
             ��� �����, �������� - ��� ������������� (nmNar);

  *** ������ ***

  ��������� ��� � ����������� ������:
  Answer := SetCase (Fam, csGenitive, Gnd, nmOwn) + ' ' +
            SetCase (Nam, csGenitive, Gnd, nmNar) + ' ' +
            SetCase (Ptn, csGenitive, Gnd, nmNar);    }

interface

const
  { ������ }
  csNominative     = 1;    { ������������ ���-��� }
  csGenitive       = 2;    { �����������  ����-���� }
  csDative         = 3;    { ���������    ����-���� }
  csAccusative     = 4;    { �����������  ����-��� }
  csInstrumentale  = 5;    { ������������ ���-��� }
  csPreposizionale = 6;    { ����������   � ���-� ��� }
  { ��� }
  gdMasculine = 0;         { ������� ��� }
  gdFeminine  = 1;         { ������� ��� }
  gdMedium    = 2;         { ������� ��� }
  gdPlural    = 3;         { ������������� ����� }
  { ��� }
  nmNar = 0;               { ��� ������������� }
  nmOwn = 1;               { ��� �����������   }

function GetCase(TheWord: String; Gender, TheCase, Name: Word): String;
function FIOCase(LastName, FirstName, MiddleName: String; Sex, TheCase: Word): String;
function ComplexCase(TheWord: String; TheCase: Word): String;

{
  ����� ����� ����� � ��� ����� �����, ��� ������, ���� � ���� ��������, � ���������� ���������� �����
  ������:
    -> 67, '������', '�������', '��������'
    <- ��������
    -> 51, '������', '�������', '��������'
    <- ������
}
function GetNumericWordForm(const ANum: Integer; const AStrForm1, AStrForm2, AStrForm5: String): String;

implementation

uses
  Sysutils;

type TNMSet = array[csNominative..csPreposizionale] of String[3];
const
  NMA: TNMSet = ('��', '��', '��', '��', '���', '��');
  NMB: TNMSet = ('��', '��', '��', '��', '���', '��');
  NMG: TNMSet = ('��', '��', '��', '��', 'ye�', '��');
  NMC: TNMSet = ('��', '��', '��', '��', '���', '��');
  NMD: TNMSet = ('��', '��', '��', '��', '���', '��');
  NME: TNMSet = ('�',  '�',  '�',  '�',  '��',  '�');
  NMF: TNMSet = ('',   '�',  '�',  '�',  '��',  '�');
  NMH: TNMSet = ('��', '��', '��', '��', '���', '��');

  NFA: TNMSet = ('�', '�', '�', '�', '��', '�');   { ...� }
  NFB: TNMSet = ('�', '�', '�', '�', '��', '�');   { ..�� }
  NFC: TNMSet = ('�', '�', '�', '�', '��', '�');   { ..�� }
  NFD: TNMSet = ('�', '�', '�', '�', '��', '�');
  NFE: TNMSet = ('�', '�', '�', '�', '��', '�');   { ..�� }

  OMA: TNMSet = ('��', '���', '���', '���', '��', '��');
  OMB: TNMSet = ('��', '���', '���', '���', '��', '��');
  OMC: TNMSet = ('��', '���', '���', '���', '��', '��');
  OMD: TNMSet = ('',   '�',   '�',   '�',   '��', '�');
  OME: TNMSet = ('�', '�', '�', '�', '��', '�');
  OMF: TNMSet = ('��', '���', '���', '���', '��', '��');

  OFA: TNMSet = ('��', '��', '��', '��', '��', '��');
  OFB: TNMSet = ('�',  '��', '��', '�',  '��', '��');

  gl: set of Char = ['�', '�', '�', '�', '�', '�', '�', '�', '�', '�'];
  r_sogl: set of Char = ['�', '�'];
  sogl: set of Char = ['�', '�', '�' , '�', '�', '�', '�', '�', '�', '�', '�',
    '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�', '�'];
  n_sogl: set of Char = ['�', '�', '�', '�', '�', '�', '�', 'x', '�', '�', '�', '�', '�', '�'];

{������� � ������� ����� �� -� �� ����������}

function NormaLizeWord(const TheWord: String): String;
begin
  Result := Trim(TheWord);
  Result := AnsiUpperCase(Copy(Result, 1, 1)) +
    AnsiLowerCase(Copy(Result, 2, Length(Result)));
end;

function SetCase_(TheWord: String; TheCase, Gender, Name: Word): String;
var
  str2, str3: String;
  str1: Char;
begin
  Result := TheWord;
  if TheCase = csNominative then
    Exit;
  str2 := Copy(TheWord, Length(TheWord) - 1, 2);
  str3 := Copy(TheWord, Length(TheWord) - 2, 3);
  str1 := TheWord[Length(TheWord) - 2];
  case Name of
    nmNar: begin                  { ��������� ����� �������������� }
      case Gender of
        gdMasculine: begin         { ������� ��� }
          { ..��, ..��, ..��, ..��, ..�, ��������� ��� ��������� }
          if str2 = '��' then begin
            Delete(TheWord, Length (TheWord) - 1, 2);
            TheWord := TheWord + NMA[TheCase];
          end else
          if str2 = '��' then begin
            Delete(TheWord, Length (TheWord) - 1, 2);
            TheWord := TheWord + OMB[TheCase];
          end else
          if str2 = '��' then begin
            Delete(TheWord, Length(TheWord) - 1, 2);
            TheWord := TheWord + OMB[TheCase];
          end else
          if str2 = '��' then begin
            Delete(TheWord, Length (TheWord) - 1, 2);
            TheWord := TheWord + NMB[TheCase];
          end else
          if str2 = '��' then begin
            Delete(TheWord, Length (TheWord) - 1, 2);
            TheWord := TheWord + NMC[TheCase];
          end else
          if str2 = '��' then begin
            Delete(TheWord, Length (TheWord) - 1, 2);
            TheWord := TheWord + NMD[TheCase];
          end else
          if TheWord[Length(TheWord)] = '�' then begin
            Delete(TheWord, Length (TheWord), 1);
            TheWord := TheWord + NME[TheCase];
          end else
          if (TheWord[Length(TheWord)] = '�') and (TheCase = csInstrumentale) then begin
            TheWord := TheWord + NME[TheCase];
          end else
          if TheWord[Length(TheWord)] = '�' then begin
            str1 := TheWord[Length(TheWord) -1];
            if str1 in sogl then
            begin
              if (TheCase = csGenitive) and
                ((str1 = '�') or (str1 = '�') or
                (str1 = '�') or (str1 = '�') or (str1 = '�') or
                (str1 = '�') or (str1 = '�')) then begin

                Delete(TheWord, Length(TheWord), 1);
                TheWord := TheWord + '�';
              end else
              if (TheCase = csInstrumentale) and
                ((str1 = '�') or (str1 = '�') or
                (str1 = '�') or (str1 = '�') or
                (str1 = '�')) then begin

                Delete(TheWord, Length(TheWord), 1);
                TheWord := TheWord + '��';
              end else begin
                Delete(TheWord, Length(TheWord), 1);
                TheWord := TheWord + NFA[TheCase];
              end;
            end else
              TheWord := TheWord + NMF[TheCase];
          end else
          if TheWord[Length(TheWord)] = '�' then begin
            Delete(TheWord, Length(TheWord), 1);
            TheWord := TheWord + NFC[TheCase];
          end else begin
            TheWord := TheWord + NMF[TheCase];
          end;
        end;
        gdFeminine: begin          { ������� ��� }
          { ..�, ..�, ..��, ��������� ��� ..�� }
            if (str2 = '��') or (str2 = '��') then begin
              Delete(TheWord, Length(TheWord), 1);
              TheWord := TheWord + NFD[TheCase];
            end else
            if str2 = '��' then begin
              Delete(TheWord, Length(TheWord), 1);
              TheWord := TheWord + NFE[TheCase];
            end else
            if TheWord[Length(TheWord)] = '�' then begin
              Delete(TheWord, Length(TheWord), 1);
              TheWord := TheWord + NFA[TheCase];
            end else
            if str2 = '��' then begin
              Delete(TheWord, Length(TheWord), 1);
              TheWord := TheWord + NFB[TheCase];
            end else
            if TheWord[Length(TheWord)] = '�' then begin
              Delete(TheWord, Length(TheWord), 1);
              TheWord := TheWord + OME[TheCase];
            end else
            if TheWord[Length(TheWord)] in sogl then begin
              Exit;
            end else begin
              Delete(TheWord, Length(TheWord), 1);
              TheWord := TheWord + NFC[TheCase];
            end;
        end;
      end;
    end;
    nmOwn: begin                  { ��������� ����� ������������ }
      case Gender of
        gdMasculine: begin         { ������� ��� }
          if TheCase <> csNominative then
          begin
            if (str3 = '���') or (str3 = '���') or (str3 = '���') or (str3 = '���') or
              (str3 = '���') or (str3 = '���') or (str3 = '���') then
              Delete(TheWord, Length (TheWord) - 1, 1);
            if (str3 = '���') then
            begin
              Delete(TheWord, Length (TheWord) - 1, 1);
              Insert('�', TheWord, Length (TheWord));
            end;
          end;
          { ..��, ..��, ..��, ��������� ��� ��������� }
          if (str3 = '���') or (str3 = '���') then begin
            Delete(TheWord, Length(TheWord) - 1, 2);
            TheWord := TheWord + OMF[TheCase];
          end else
          if str2 = '��' then begin
            Delete(TheWord, Length(TheWord) - 1, 2);
            TheWord := TheWord + OMA[TheCase];
          end else
          if str2 = '��' then begin
            Delete(TheWord, Length (TheWord) - 1, 2);
            TheWord := TheWord + OMB[TheCase];
          end else
          if str2 = '��' then begin
            Delete(TheWord, Length(TheWord) - 1, 2);
            TheWord := TheWord + OMB[TheCase];
          end else
          if (str2 = '��') and (str1 in gl) then begin
            Delete(TheWord, Length (TheWord) - 1, 2);
            TheWord := TheWord + '��' + NMF[TheCase];
          end else
          if str2 = '��' then begin
            Delete(TheWord, Length (TheWord) - 1, 2);
            TheWord := TheWord + NMB[TheCase];
          end else
          if str2 = '��' then begin
            Delete(TheWord, Length (TheWord) - 1, 2);
            TheWord := TheWord + NMG[TheCase];
          end else
          if str2 = '��' then begin
            Delete(TheWord, Length (TheWord) - 1, 2);
            TheWord := TheWord + NMH[TheCase];
          end else
          if TheWord[Length(TheWord)] = '�' then begin
            Delete(TheWord, Length (TheWord), 1);
            TheWord := TheWord + NME[TheCase];
          end else
          if TheWord[Length(TheWord)] = '�' then begin  //�������� ������
            Delete(TheWord, Length(TheWord), 1);
            TheWord := TheWord + NFB[TheCase];
          end else
          if (TheWord[Length(TheWord)] = '�') and (TheCase = csInstrumentale) then begin
            TheWord := TheWord + NME[TheCase];
          end else
          if (str2 = '��') or (str2 = '��') or (str2 = '��') or
            (str2 = '��') or (str2 = '��') or (str2 = '��') or (str2 = '��') then begin
            Exit;
          end else
          if (str3 = '���') or (str3 = '���') or (str3 = '���') then begin
            Exit;
          end else
          if TheWord[Length(TheWord)] = '�' then begin
            str1 := TheWord[Length(TheWord) -1];
            if str1 in sogl then
            begin
              if (TheCase = csGenitive) and
                ((str1 = '�') or (str1 = '�') or
                (str1 = '�') or (str1 = '�') or (str1 = '�') or
                (str1 = '�') or (str1 = '�')) then begin

                Delete(TheWord, Length(TheWord), 1);
                TheWord := TheWord + '�';
              end else
              if (TheCase = csInstrumentale) and
                ((str1 = '�') or (str1 = '�') or
                (str1 = '�') or (str1 = '�') or
                (str1 = '�')) then begin

                Delete(TheWord, Length(TheWord), 1);
                TheWord := TheWord + '��';
              end else begin
                Delete(TheWord, Length(TheWord), 1);
                TheWord := TheWord + NFA[TheCase];
              end;
            end else
              TheWord := TheWord + NMF[TheCase];
          end else
          if TheWord[Length(TheWord)] in n_sogl then begin
            TheWord := TheWord + NMF[TheCase];
          end else begin
            TheWord := TheWord + OMD[TheCase];
          end;
        end;
        gdFeminine: begin          { ������� ��� }
          { ..��, ��������� ��� ..� }
          if str3 = '���' then begin
            exit;   // ��. Issue 2333
          end else
          if str2 = '��' then begin
            Delete(TheWord, Length (TheWord) - 1, 2);
            TheWord := TheWord + OFA[TheCase];
          end else
          if (str2 = '��') or (str2 = '��') or (str2 = '��') or
            (str2 = '��') or (str2 = '��') or (str2 = '��') then begin
            Exit;
          end else
          if (str3 = '���') or (str3 = '���') or (str3 = '���') then begin
            Exit;
          end else
          if (str3 = '���') or (str3 = 'e��') or  (str3 = '���') or
            (str3 = '���') or (str3 = '���') then begin //����������
            Delete(TheWord, Length(TheWord), 1);
            TheWord := TheWord + OFB[TheCase];
          end else
          if TheWord[Length(TheWord)] = '�' then begin
            Delete(TheWord, Length(TheWord), 1);
            TheWord := TheWord + NFD[TheCase];
          end else
          if TheWord[Length(TheWord)] = '�' then begin  //�������� ������
            Delete(TheWord, Length(TheWord), 1);
            TheWord := TheWord + NFB[TheCase];
          end else
          if TheWord[Length(TheWord)] in sogl then begin
            exit;
          end else begin
            Delete(TheWord, Length(TheWord), 1);
            TheWord := TheWord + OFB[TheCase];
          end;
        end;
        else Exit;
      end;
    end;
    else Exit;
  end;
  Result := TheWord;
end;

function GetCase(TheWord: String; Gender, TheCase, Name: Word): String;
begin
  Result := TheWord;
  if TheWord <> '' then
    Result := SetCase_(NormaLizeWord(TheWord), TheCase, Gender, Name);
end;

function FIOCase(LastName, FirstName, MiddleName: String; Sex, TheCase: Word): String;
begin
  Result := Trim(GetCase(LastName, Sex, TheCase, nmOwn) + ' ' +
    GetCase(FirstName, Sex, TheCase, nmNar) + ' ' +
    GetCase(MiddleName, Sex, TheCase, nmNar));
end;

{
1. ������������ -- ��� ���� ����� ��� N ����, ���������� ����� �����.
2. ������������ �� ������ ����� ���������� �� �������� ���������.
3. � ������������ �� N ����, ���������� ����� �����, ���������� ������ ��
���� �� �������� ���������.
4. � ����� ������, ������� ��������� �� ���� ������ ���������� ����:
[[�����������] [�����������]...] ������������ [�������]

5. ����������� -- ��� ��������������: �������, �������, �������, �������, �
�.�. �� ����� ���� ���������.
6. ����������� ����������.
7. ������������ ����������.
8. ������� �� ����������.

����������� - ��� �������������� � ������������ ������, ������������ �����. �.�.
���������� ��� �� ����������: -��, -��, -��, -��.

}

function SetCase(TheWord: String; TheCase, Gender, Name: Word): String;
var
  str2, str3: String;
  str1: Char;
begin
  SetCase := TheWord;
  if TheCase = csNominative then
    Exit;
  str2 := Copy(TheWord, Length(TheWord) - 1, 2);
  str3 := Copy(TheWord, Length(TheWord) - 2, 3);
  str1 := TheWord[Length(TheWord) - 2];
  Case Name of
    nmNar: begin                  { ��������� ����� �������������� }
      Case Gender of
        gdMasculine: begin         { ������� ��� }
          if TheCase <> csNominative then
          begin
            if (str3 = '���') or (str3 = '���') or (str3 = '���') or (str3 = '���') or
              (str3 = '���') or (str3 = '���') or (str3 = '���') then
              Delete(TheWord, Length (TheWord) - 1, 1);
            if (str3 = '���') then
            begin
              Delete(TheWord, Length (TheWord) - 1, 1);
              Insert('�', TheWord, Length (TheWord));
            end;
          end;
          { ..��, ..��, ..��, ..��, ..�, ��������� ��� ��������� }
          if (str3 = '���') or (str3 = '���') then begin
            Delete(TheWord, Length(TheWord) - 1, 2);
            TheWord := TheWord + OMF[TheCase];
          end else            
          if str2 = '��' then begin
            Delete(TheWord, Length (TheWord) - 1, 2);
            TheWord := TheWord + NMA[TheCase];
          end else
          if str2 = '��' then begin
            Delete(TheWord, Length(TheWord) - 1, 2);
            TheWord := TheWord + OMB[TheCase];
          end else
          if str2 = '��' then begin
            Delete(TheWord, Length(TheWord) - 1, 2);
            TheWord := TheWord + OMB[TheCase];
          end else
          if str2 = '��' then begin
            Delete(TheWord, Length (TheWord) - 1, 2);
            TheWord := TheWord + NMB[TheCase];
          end else
          if str2 = '��' then begin
            Delete(TheWord, Length (TheWord) - 1, 2);
            TheWord := TheWord + NMC[TheCase];
          end else
          if str2 = '��' then begin
            Delete(TheWord, Length (TheWord) - 1, 2);
            TheWord := TheWord + NMD[TheCase];
          end else
          if (str2 = '��') and (str1 in gl) then begin
            Delete(TheWord, Length (TheWord) - 1, 2);
            TheWord := TheWord + '��' + NMF[TheCase];
          end else
          if TheWord [Length(TheWord)] = '�' then begin
            Delete(TheWord, Length (TheWord), 1);
            TheWord := TheWord + NME[TheCase];
          end else begin
            TheWord := TheWord + NMF[TheCase];
          end;
        end;
        gdFeminine: begin          { ������� ��� }
          { ..�, ..�, ..��, ��������� ��� ..�� }
          if TheWord [Length(TheWord)] <> '�' then { �� ���������� }
          if (str2 = '��') or (str2 = '��') then begin
            Delete(TheWord, Length(TheWord), 1);
            TheWord := TheWord + NFD[TheCase];
          end else
          if str2 = '��' then begin
            Delete(TheWord, Length(TheWord), 1);
            TheWord := TheWord + NFE[TheCase];
          end else
          if TheWord [Length(TheWord)] = '�' then begin
            Delete(TheWord, Length (TheWord), 1);
            TheWord := TheWord + NFA[TheCase];
          end else
          if Copy(TheWord, Length(TheWord) - 1, 2) = '��' then begin
            Delete(TheWord, Length (TheWord), 1);
            TheWord := TheWord + NFB[TheCase];
          end else begin
            Delete(TheWord, Length (TheWord), 1);
            TheWord := TheWord + NFC[TheCase];
          end;
        end;
        else Exit;
      end;
    end;
    nmOwn: begin                  { ��������� ����� ������������ }
      Case Gender of
        gdMasculine: begin         { ������� ��� }
          { ..��, ..��, ..��, ��������� ��� ��������� }
          if (str3 = '���') or (str3 = '���') then begin
            Delete(TheWord, Length(TheWord) - 1, 2);
            TheWord := TheWord + OMF[TheCase];
          end else
          if str2 = '��' then begin
            Delete(TheWord, Length (TheWord) - 1, 2);
            TheWord := TheWord + OMA[TheCase];
          end else
          if str2 = '��' then begin
            Delete(TheWord, Length(TheWord) - 1, 2);
            TheWord := TheWord + OMB[TheCase];
          end else
          if str2 = '��' then begin
            Delete(TheWord, Length(TheWord) - 1, 2);
            TheWord := TheWord + OMB[TheCase];
          end else
          if str2 = '��' then begin
            Delete(TheWord, Length (TheWord) - 1, 2);
            TheWord := TheWord + NMB[TheCase];
          end else
          if str2 = '��' then begin
            Delete(TheWord, Length (TheWord) - 1, 2);
            TheWord := TheWord + NMG[TheCase];
          end else
          if str2 = '��' then begin
            Delete(TheWord, Length (TheWord) - 1, 2);
            TheWord := TheWord + NMH[TheCase];
          end else
          if TheWord[Length(TheWord)] = '�' then begin
            Delete(TheWord, Length (TheWord), 1);
            TheWord := TheWord + NME[TheCase];
          end else begin
            TheWord := TheWord + OMD[TheCase];
          end;
        end;
        gdFeminine: begin          { ������� ��� }
          { ..��, ��������� ��� ..� }
          if str2 = '��' then begin
            Delete(TheWord, Length (TheWord) - 1, 2);
            TheWord := TheWord + OFA[TheCase];
          end else
          if (str3 = '���') or (str3 = 'e��') or  (str3 = '���') or
            (str3 = '���') or (str3 = '���') then begin //����������
            Delete(TheWord, Length(TheWord), 1);
            TheWord := TheWord + OFB[TheCase];
          end else          
          if TheWord[Length(TheWord)] = '�' then begin  //�������� ������
            Delete(TheWord, Length(TheWord), 1);
            TheWord := TheWord + NFB[TheCase];
          end else begin
            Delete(TheWord, Length (TheWord), 1);
            TheWord := TheWord + OFB[TheCase];
          end;
        end;
        else Exit;
      end;
    end;
    else Exit;
  end;
  SetCase := TheWord;
end;

function NameCase(TheWord: String; TheCase: Word): String;
var
  str1: Char;
  Text, StartText, EndText: String;
  PartText: String;
  FEnd: Boolean;
  Position, StartPos :Integer;
begin
  Position := Pos('-', TheWord);
  if Position > 0 then
  begin
    StartText := TheWord;
    FEnd := False;
    StartPos := 0;
    Text := '';
    while not FEnd do
    begin
      PartText := Copy(StartText, StartPos, Position - 1);
      EndText := Copy(StartText, Position, Length(StartText) - Position + 1);
      if PartText > '' then
        str1 := PartText[Length(PartText)]
      else
        str1 := #0;
      if (str1 = '�') or (str1 = '�') then //������� ���
        Text := Text + SetCase(PartText, TheCase, gdFeminine, nmNar)
      else if str1 in sogl then
        Text := Text + SetCase(PartText, TheCase, gdMasculine, nmNar)
      else
        Text := Text + StartText;
      //�������� ���������
      if (Pos('-', EndText) > 0) and (PartText > '') then
      begin
        Text := Text + '-';
        StartText := Copy(EndText, 2, Length(EndText)) + ' ';
        Position := Pos('-', StartText);
        if Position = 0 then
          Position := Length(StartText);
        StartPos := 0
      end else
      begin
        FEnd := True;
        Text := Text + EndText;
      end;
    end;
    Result := TrimRight(Text);
  end else
  begin
    if TheWord > '' then
    begin
      str1 := TheWord[Length(TheWord)];
      if (str1 = '�') or (str1 = '�') then //������� ���
        Result := SetCase(TheWord, TheCase, gdFeminine, nmNar)
      else if str1 in sogl then
        Result := SetCase(TheWord, TheCase, gdMasculine, nmNar)
      else
        Result := TheWord;
    end else
      Result := TheWord;
  end;
end;

function ComplexCase(TheWord: String; TheCase: Word): String;
var
  Position, StartPos :Integer;
  str2, Text, StartText: String;
  PartText, EndText: String;
  str1: Char;
  FEnd: Boolean;
begin
  Result := TheWord;
  StartText := AnsiLowerCase(Trim(TheWord));
  //������� �����������, ����� ������ �� ������� � ���������.
  Position := Pos(' ', StartText);
  if Position > 0 then
  begin
    FEnd := False;
    StartPos := 0;
    Text := '';
    while not FEnd do
    begin
      PartText := Copy(StartText, StartPos, Position - 1);

      if Length(PartText) = 1 then
      begin
        Text := TheWord;
        FEnd := True;
        continue;
      end;

      EndText := Copy(StartText, Position, Length(StartText) - Position + 1);
      str2 := Copy(PartText, Length(PartText) - 1, 2);
      if PartText > '' then
        str1 := PartText[Length(PartText)]
      else
        str1 := #0;  
      if (str2 = '��') or (str2 = '��') then
        Text := Text + SetCase(PartText, TheCase, gdFeminine, nmOwn) + ' '
      else if (str2 = '��') or (str2 = '��') then
        Text := Text + SetCase(PartText, TheCase, gdMasculine, nmOwn) + ' '
      //���� ������������, �� �������, �������� � �������
      else if (str1 = '�') or (str1 = '�') or (str1 in sogl) then //������� ���
      begin
        Text := Text + NameCase(PartText, TheCase) {+ ' '} + EndText;
        FEnd := True;
      end else
      begin
        if str1 = '.' then
        begin
          Text := TheWord;
          FEnd := True;
          continue;
        end else
        begin
          if Text > '' then
            Text := Text + ' ' + PartText
          else
            Text := PartText;
        end;
      end;

      //�������� ���������
      if (Pos(' ', EndText) > 0) and (Trim(EndText) <> '') then
      begin
        StartText := TrimLeft(EndText) + ' ';
        Position := Pos(' ', StartText);
        if Position = 0 then
          Position := Length(StartText);
        StartPos := 0
      end else
      begin
        FEnd := True;
        Text := Text + EndText;
      end;
    end;
    Result := TrimRight(Text);
  end else
    Result := NameCase(StartText, TheCase);
end;

function GetNumericWordForm(const ANum: Integer; const AStrForm1, AStrForm2, AStrForm5: String): String;
var
  Num100, Num10: Integer;
begin
  Num100 := Abs(ANum) mod 100;
  Num10 := Num100 mod 10;
  if (Num100 > 10) and (Num100 <= 20) then
    Result := AStrForm5
  else if (Num10 > 1) and (Num10 < 5) then
    Result := AStrForm2
  else if Num10 = 1 then
    Result := AStrForm1
  else
    Result := AStrForm5;
end;

end.
