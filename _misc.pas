unit _misc;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, DateUtils, Graphics;

function PadLeft(StrVar, PadStr: string; W: integer): string;
function ParseStrLeft(S, Chrs: string): string;
function ParseStrRight(S, Chrs: string): string;
function TrimSpaces(S: string): string;
function GenBackupFilename(FileName, Ext: string): string;
function GetSubStr(S, Delim1: string; No1, OffSet1: smallint;
  Delim2: string; No2, OffSet2: smallint): string;
procedure Wrap(Gcvs: TCanvas; Txt: String; var Tx: Array of String; W: Integer);
function StripIllegalChars(Filename: String): String;
function GetShortMonth(ShortMonthVal: String): Integer;
function PrevMonth(MonthVal: Integer): Integer;
function NextMonth(MonthVal: Integer): Integer;
function GetSubStr1(S, Delim1: String; No1: SmallInt; Delim2: String; No2: SmallInt): String;
function ShortMnthToInt(MonthName: String): Integer;
procedure DecodeDateStr(FormatStr, DateStr: String; YearVal, DOYVal: Integer; var Year, Month, Day: Word);
function FormatByteSize(const bytes: Int64): string;

implementation

function PadLeft(StrVar, PadStr: string; W: integer): string;
var
  i, j: integer;
  S: string;
begin
  Result := '';
  S := Trim(StrVar);
  j := Length(S);
  for i := 1 to W - j do
    Result := Result + PadStr;
  Result := Result + S;
end;

function ParseStrLeft(S, Chrs: string): string;
begin
  Result := Copy(S, 0, Pos(Chrs, S) - 1);
end;

function ParseStrRight(S, Chrs: string): string;
begin
  Result := Copy(S, Pos(Chrs, S) + Length(Chrs), Length(S));
end;

function TrimSpaces(S: string): string;
begin
  repeat
    S := StringReplace(S, '  ', ' ', [rfReplaceAll, rfIgnoreCase]);
  until Pos('  ', S) = 0;
  Result := Trim(S);
end;

function GenBackupFilename(FileName, Ext: string): string;
var
  DBFileName, DStr, MStr, YStr, HStr, MinStr: string;
  AYear, AMonth, ADay, AHour, AMinute, ASecond, AMilliSecond: word;
begin
  DecodeDateTime(Now, AYear, AMonth, ADay, AHour, AMinute, ASecond, AMilliSecond);
  DStr := PadLeft(IntToStr(ADay), '0', 2);
  MStr := PadLeft(IntToStr(AMonth), '0', 2);
  YStr := IntToStr(AYear);
  HStr := PadLeft(IntToStr(AHour), '0', 2);
  MinStr := PadLeft(IntToStr(AMinute), '0', 2);
  DBFileName := Copy(FileName, 0, LastDelimiter('.', FileName) - 1);
  Result := DBFileName + DStr + '_' + MStr + '_' + YStr + '_' + HStr +
    MinStr + '.' + Ext;
end;

function GetSubStr(S, Delim1: string; No1, OffSet1: smallint;
  Delim2: string; No2, OffSet2: smallint): string;
var
  P1, P2, i: integer;
  TmpS: string;
begin
  if Delim1 = 'Tab' then
    Delim1 := #09
  else if Delim1 = 'Space' then
    Delim1 := ' ';
  if Delim2 = 'Tab' then
    Delim2 := #09
  else if Delim2 = 'Space' then
    Delim2 := ' ';

  P1 := OffSet1;
  TmpS := S;
  for i := 1 to No1 do
  begin
    P1 := P1 + Pos(Delim1, TmpS);
    TmpS := Copy(S, P1 + 1, Length(S) - P1);
  end;
  P2 := OffSet2;
  TmpS := S;
  for i := 1 to No2 do
  begin
    P2 := P2 + Pos(Delim2, TmpS);
    TmpS := Copy(S, P2 + 1, Length(S) - P2);
  end;
  if No2 > 0 then
  begin
    TmpS := Copy(S, P1 + 1, P2 - P1 - 1);
    Result := Trim(TmpS);
  end
  else
  begin
    Result := Copy(S, P1 + 1, P2 - P1);
    // if Result = '' then
    // Result := Copy(S, P1 + 1, Length(S) - P1);
  end;
end;

procedure Wrap(Gcvs: TCanvas; Txt: String; var Tx: Array of String; W: Integer);
var
  i: Integer;
begin
  FillChar(Tx, SizeOf(Tx), #0);
  i := 0;
  if Pos(';', Txt) > 0 then
    while Pos(';', Txt) > 0 do
    begin
      Tx[i] := Copy(Txt, 1, Pos(';', Txt) - 1);
      Delete(Txt, 1, Pos(';', Txt));
      Inc(i);
    end
  else
    while (Gcvs.TextWidth(Txt) > W) and (Pos(' ', Txt) > 0) do
    begin
      Tx[i] := Copy(Txt, 1, Pos(' ', Txt) - 1);
      Delete(Txt, 1, Pos(' ', Txt));
      while (Pos(' ', Txt) > 0) and
        (Gcvs.TextWidth(Tx[i] + ' ' + Copy(Txt, 1, Pos(' ', Txt) - 1)) < W) do
      begin
        Tx[i] := Tx[i] + ' ' + Copy(Txt, 1, Pos(' ', Txt) - 1);
        Delete(Txt, 1, Pos(' ', Txt));
      end;
      Inc(i);
    end;
  Tx[i] := Txt;
end;

function StripIllegalChars(Filename: String): String;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(Filename) do
    if Filename[i] in ['/', '.', '\', ':', '?', '*', ',', '<', '>', '|', #34] then
      Result := Result + '_'
    else
      Result := Result + Filename[i];
end;

function GetShortMonth(ShortMonthVal: String): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 1 to 12 do
  begin
    if ShortMonthVal = ShortMonthNames[i] then
    begin
      Result := i;
      Exit;
    end;
  end;
end;

function PrevMonth(MonthVal: Integer): Integer;
begin
  Result := MonthVal - 1;
  if Result < 1 then
    Result := 12;
end;

function NextMonth(MonthVal: Integer): Integer;
begin
  Result := MonthVal + 1;
  if Result > 12 then
    Result := 1;
end;

function GetSubStr1(S, Delim1: String; No1: SmallInt; Delim2: String;
  No2: SmallInt): String;
var
  P1, P2, i: Integer;
  TmpS: String;
begin
  if Delim1 = 'Tab' then
    Delim1 := #09
  else if Delim1 = 'Space' then
    Delim1 := ' ';
  if Delim2 = 'Tab' then
    Delim2 := #09
  else if Delim2 = 'Space' then
    Delim2 := ' ';
  P1 := 0;
  TmpS := S;
  for i := 1 to No1 do
  begin
    P1 := P1 + Pos(Delim1, TmpS);
    TmpS := Copy(S, P1 + 1, Length(S) - P1);
  end;
  P2 := 0;
  TmpS := S;
  for i := 1 to No2 do
  begin
    P2 := P2 + Pos(Delim2, TmpS);
    TmpS := Copy(S, P2 + 1, Length(S) - P2);
  end;
  if No2 > 0 then
  begin
    TmpS := Copy(S, P1 + 1, P2 - P1 - 1);
    Result := Trim(TmpS);
  end
  else
  begin
    Result := Copy(S, P1 + 1, P2 - P1);
    if Result = '' then
      Result := Copy(S, P1 + 1, Length(S) - P1);
  end;
end;

function ShortMnthToInt(MonthName: String): Integer;
var
  i: Integer;
begin
  Result := 1;
  for i := 1 to 12 do
    if MonthName = FormatSettings.ShortMonthNames[i] then
    begin
      Result := i;
      Break;
    end;
end;

procedure DecodeDateStr(FormatStr, DateStr: String; YearVal, DOYVal: Integer; var Year, Month, Day: Word);
var
  P1, P2: Integer;
  TmpDate: TDateTime;
begin
  if FormatStr <> '' then
  begin
    if FormatStr = 'dd/mm/yyyy' then
    begin
      P1 := Pos('/', DateStr);
      P2 := LastDelimiter('/', DateStr);
      Year := StrToInt(Copy(DateStr, P2 + 1, 4));
      Month := StrToInt(Copy(DateStr, P1 + 1, P2 - P1 - 1));
      Day := StrToInt(Copy(DateStr, 1, P1 - 1));
    end
    else if FormatStr = 'dd.mm.yyyy' then
    begin
      P1 := Pos('.', DateStr);
      P2 := LastDelimiter('.', DateStr);
      Year := StrToInt(Copy(DateStr, P2 + 1, 4));
      Month := StrToInt(Copy(DateStr, P1 + 1, P2 - P1 - 1));
      Day := StrToInt(Copy(DateStr, 1, P1 - 1));
    end
    else if FormatStr = 'dd-mm-yyyy' then
    begin
      P1 := Pos('-', DateStr);
      P2 := LastDelimiter('-', DateStr);
      Year := StrToInt(Copy(DateStr, P2 + 1, 4));
      Month := StrToInt(Copy(DateStr, P1 + 1, P2 - P1 - 1));
      Day := StrToInt(Copy(DateStr, 1, P1 - 1));
    end
    else if FormatStr = 'mm/dd/yyyy' then
    begin
      P1 := Pos('/', DateStr);
      P2 := LastDelimiter('/', DateStr);
      Year := StrToInt(Copy(DateStr, P2 + 1, 4));
      Month := StrToInt(Copy(DateStr, 1, P1 - 1));
      Day := StrToInt(Copy(DateStr, P1 + 1, P2 - P1 - 1));
    end
    else if FormatStr = 'mm.dd.yyyy' then
    begin
      P1 := Pos('.', DateStr);
      P2 := LastDelimiter('.', DateStr);
      Year := StrToInt(Copy(DateStr, P2 + 1, 4));
      Month := StrToInt(Copy(DateStr, 1, P1 - 1));
      Day := StrToInt(Copy(DateStr, P1 + 1, P2 - P1 - 1));
    end
    else if FormatStr = 'dd/mm/yy' then
    begin
      P1 := Pos('/', DateStr);
      P2 := LastDelimiter('/', DateStr);
      Year := StrToInt(Copy(DateStr, P2 + 1, 4)) + 2000;
      Month := StrToInt(Copy(DateStr, P1 + 1, P2 - P1 - 1));
      Day := StrToInt(Copy(DateStr, 1, P1 - 1));
    end
    else if FormatStr = 'dd.mm.yy' then
    begin
      P1 := Pos('.', DateStr);
      P2 := LastDelimiter('.', DateStr);
      Year := StrToInt(Copy(DateStr, P2 + 1, 4)) + 2000;
      Month := StrToInt(Copy(DateStr, P1 + 1, P2 - P1 - 1));
      Day := StrToInt(Copy(DateStr, 1, P1 - 1));
    end
    else if FormatStr = 'yyyy/mm/dd' then
    begin
      P1 := Pos('/', DateStr);
      P2 := LastDelimiter('/', DateStr);
      Year := StrToInt(Copy(DateStr, 1, P1 - 1));
      Month := StrToInt(Copy(DateStr, P1 + 1, P2 - P1 - 1));
      Day := StrToInt(Copy(DateStr, P2 + 1, Length(DateStr) - P2));
    end
    else if FormatStr = 'yyyy.mm.dd' then
    begin
      P1 := Pos('.', DateStr);
      P2 := LastDelimiter('.', DateStr);
      Year := StrToInt(Copy(DateStr, 1, P1 - 1));
      Month := StrToInt(Copy(DateStr, P1 + 1, P2 - P1 - 1));
      Day := StrToInt(Copy(DateStr, P2 + 1, Length(DateStr) - P2));
    end
    else if FormatStr = 'yyyy-mm-dd' then
    begin
      P1 := Pos('-', DateStr);
      P2 := LastDelimiter('-', DateStr);
      Year := StrToInt(Copy(DateStr, 1, P1 - 1));
      Month := StrToInt(Copy(DateStr, P1 + 1, P2 - P1 - 1));
      Day := StrToInt(Copy(DateStr, P2 + 1, Length(DateStr) - P2));
    end
    else if FormatStr = 'yy/mm/dd' then
    begin
      P1 := Pos('/', DateStr);
      P2 := LastDelimiter('/', DateStr);
      Year := StrToInt(Copy(DateStr, 1, P1 - 1)) + 2000;
      Month := StrToInt(Copy(DateStr, P1 + 1, P2 - P1 - 1));
      Day := StrToInt(Copy(DateStr, P2 + 1, Length(DateStr) - P2));
    end
    else if FormatStr = 'yy.mm.dd' then
    begin
      P1 := Pos('.', DateStr);
      P2 := LastDelimiter('.', DateStr);
      Year := StrToInt(Copy(DateStr, 1, P1 - 1)) + 2000;
      Month := StrToInt(Copy(DateStr, P1 + 1, P2 - P1 - 1));
      Day := StrToInt(Copy(DateStr, P2 + 1, Length(DateStr) - P2));
    end
    else if FormatStr = 'ddmmyyyy' then
    begin
      Year := StrToInt(Copy(DateStr, 5, 4));
      Month := StrToInt(Copy(DateStr, 3, 2));
      Day := StrToInt(Copy(DateStr, 1, 2));
    end
    else if FormatStr = 'ddmmyy' then
    begin
      Year := StrToInt(Copy(DateStr, 5, 2)) + 2000;
      Month := StrToInt(Copy(DateStr, 3, 2));
      Day := StrToInt(Copy(DateStr, 1, 2));
    end
    else if FormatStr = 'ddmmmyyyy' then
    begin
      if Length(DateStr) = 8 then
      begin
        Year := StrToInt(Copy(DateStr, 5, 4));
        Month := ShortMnthToInt(Copy(DateStr, 2, 3));
        Day := StrToInt(Copy(DateStr, 1, 1));
      end
      else
      begin
        Year := StrToInt(Copy(DateStr, 6, 4));
        Month := ShortMnthToInt(Copy(DateStr, 3, 3));
        Day := StrToInt(Copy(DateStr, 1, 2));
      end
    end
    else if FormatStr = 'yyyymmdd' then
    begin
      Year := StrToInt(Copy(DateStr, 1, 4));
      Month := StrToInt(Copy(DateStr, 5, 2));
      Day := StrToInt(Copy(DateStr, 7, 2));
    end
    else if FormatStr = 'yymmdd' then
    begin
      Year := StrToInt(Copy(DateStr, 1, 2)) + 2000;
      Month := StrToInt(Copy(DateStr, 3, 2));
      Day := StrToInt(Copy(DateStr, 5, 2));
    end
    else if FormatStr = 'DOY' then
    begin
      TmpDate := EncodeDate(YearVal, 1, 1) + DOYVal - 1;
      DecodeDate(TmpDate, Year, Month, Day);
    end;
  end;
end;

function FormatByteSize(const bytes: Int64): string;
const
  B = 1; // byte
  KB = 1024 * B; // kilobyte
  MB = 1024 * KB; // megabyte
  GB = 1024 * MB; // gigabyte
begin
  if bytes > GB then
    Result := FormatFloat('#.## GB', bytes / GB)
  else if bytes > MB then
    Result := FormatFloat('#.## MB', bytes / MB)
  else if bytes > KB then
    Result := FormatFloat('#.## KB', bytes / KB)
  else
    Result := FormatFloat('#.## bytes', bytes);
end;

end.
