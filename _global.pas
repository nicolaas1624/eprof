unit _global;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, StrUtils, Graphics, IBQuery, Classes, Registry, db;

const
  pVersion = '07/07/2017';

  AppName = 'eProf';
  RegIniFileName = 'eprof';
  SMSFileName = 'eprof_sms_data';
  SMSRemoteHost = 'ftp.mymobileapi.com'; // '206.225.83.190';
  fbClientLib = 'gds32.dll';

  nbsystems_remotehost = '197.221.2.8';  //'nbsystems.co.za';
  nbsystems_username = 'nbsyst';
  nbsystems_password = 'suselna1';
  wateradmin_remotehost_ip = '197.221.14.220';    //'wateradmin.co.za';
  wateradmin_remotehost_name = 'wateradmin.co.za';
  wateradmin_username = 'watertwhaw';
  wateradmin_password = 'PMwJEinW';
  wateradmin_remotepath = '/public_html/';   //'http://www.wateradmin.co.za/schemes/invoices/';

type
  eprofErr = class(Exception);
  TCaptureState = (csInsert,csEdit,csDelete);

  cnftype = record
    ServerName: string;
    DBFileName: string;
    Role: string;
    UserName: string;
    PDFReader: string;
    SnapShotFileName: string;
    FirebirdPath: String;
    FromEmailAddr: string;
    SMTPHost: string;
    SMTPPort: integer;
    EmailUsername: string;
    EmailPassword: string;
    CurrentYr: Integer;
    DefPictId: Integer;
    DefComp: integer;
  end;

var
  ConfigFileName: String = 'eprof.cfg';
  fbPort: integer = 3050;

  cnf: cnftype;
  RegIni: TRegIniFile;
  PDFFileName: String;
  appPath: string;
  HelpfilesPath: String;  // ..\docs
  EmailFolder: string;    // ..\email
  SMSFolder: String;      // ..\sms
  ToEMailAddr: string;
  DefPrinterIndex: longint;

  // print preview variables
  bDefFontSize: Integer = 10;

  pXlargeFontSize: Integer;
  pLargeFontSize: Integer;
  pMedFontSize: Integer;
  pDefFontSize: Integer;

  pDefFontColor: TColor = clBlack;
  pDefFontStyle: TFontStyles = [];
  pDefPenWidth: Integer = 1;
  pDefPenColor: TColor = clBlack;
  pDefPenStyle: TPenStyle = psSolid;
  pDefBrushColor: TColor = clWhite;
  pDefFontName: String = 'Tahoma';
  ppWidth_mm: Integer = 210; // portrait: A4 page size = 210 x 297 mm
  ppHeight_mm: Integer = 297;
  pXf,
  pYf: Double;
  pLM,           // left margin
  pRM,           // right margin
  pTM,           // top margin
  pBM: Integer;  // bottom margin
  pPageNo,
  pnLines,
  pNoOfPages: Integer;

function pXmm(XVal: Double): Integer;
function pYmm(YVal: Double): Integer;
procedure pInit(pWidth, pHeight: Integer);
procedure ClearCanvas(DCanvas: TCanvas);
procedure DrawTemplate(DCanvas: TCanvas; pWidth, pHeight: Integer);
procedure SetFontSizes(DCanvas: TCanvas);
procedure pRect(DCanvas: TCanvas; x1, y1, x2, y2: Double; PenWidth: Integer; PenColor, BrushColor: TColor);
procedure pLine(DCanvas: TCanvas; x1, y1, x2, y2: Double; PenWidth: Integer; PenStyle: TPenStyle; PenColor: TColor);
procedure pText(DCanvas: TCanvas; x1, y1: Double; S, FontName: String; FontSize: Integer; FontColor, BrushColor: TColor; FontStyle: TFontStyles);
procedure pCText(DCanvas: TCanvas; x1, y1, x2: Double; S, FontName: String; FontSize: Integer; FontColor, BrushColor: TColor; FontStyle: TFontStyles);
procedure pRJText(DCanvas: TCanvas; x1, y1: Double; S, FontName: String; FontSize: Integer; FontColor, BrushColor: TColor; FontStyle: TFontStyles);
procedure pTextRect(DCanvas: TCanvas; x1, y1, x2, y2: Double; S: String; PenWidth: Integer; PenColor, BrushColor: TColor);
procedure pImage(DCanvas: TCanvas; Width_mm, Height_mm, X_mm, Y_mm: String; PICTIDVal, PICTNOVal: Integer);

procedure ReadCnfFile;
procedure WriteCnfFile;

implementation

uses _dm;

function pXmm(XVal: Double): Integer;
begin
  Result := Round(XVal * pXf);
end;

function pYmm(YVal: Double): Integer;
begin
  Result := Round(YVal * pYf);
end;

procedure pInit(pWidth, pHeight: Integer);
begin
  pXf := pWidth / ppWidth_mm;                    // X factor in Pixels per mm
  pYf := pHeight / ppHeight_mm;                  // Y factor in Pixels per mm
  pLM := pXmm(10);                               // left margin
  pTM := pYmm(10);                               // top margin
  pRM := pLM;                                    // right margin
  pBM := pYmm(10);                               // bottom margin
  pnLines := (pHeight - pTM - pBM) div pYmm(5);
  pNoOfPages := 1;
end;

procedure ClearCanvas(DCanvas: TCanvas);
begin
  DCanvas.Clear;
  DCanvas.FillRect(0, 0, DCanvas.Width, DCanvas.Height);
  DCanvas.Font.Size := bDefFontSize;
end;

procedure DrawTemplate(DCanvas: TCanvas; pWidth, pHeight: Integer);
var
  i: Integer;
begin
  DCanvas.Font.Size := 6;
  DCanvas.Pen.Style := psDot;
  i := 0;
  repeat
    DCanvas.MoveTo(0, pYmm(i));
    DCanvas.LineTo(pWidth, pYmm(i));
    if i > 0 then
      DCanvas.TextOut(pXmm(1), pYmm(i) - Abs(DCanvas.Font.Height) div 2, IntToStr(i));
    Inc(i, 5);
  until i >= 295;
  i := 0;
  repeat
    DCanvas.MoveTo(pXmm(i), 0);
    DCanvas.LineTo(pXmm(i), pHeight);
    if i > 0 then
      DCanvas.TextOut(pXmm(i) - DCanvas.TextWidth(IntToStr(i)) div 2, pYmm(1), IntToStr(i));
    Inc(i, 5);
  until i >= 210;
  DCanvas.Font.Size := bDefFontSize;
  DCanvas.Pen.Style := psSolid;
end;

procedure SetFontSizes(DCanvas: TCanvas);
begin
  pXlargeFontSize := Round(bDefFontSize * pYmm(4.5) / DCanvas.Font.Height);
  pLargeFontSize := Round(bDefFontSize * pYmm(4) / DCanvas.Font.Height);
  pMedFontSize := Round(bDefFontSize * pYmm(3.5) / DCanvas.Font.Height);
  pDefFontSize := Round(bDefFontSize * pYmm(3) / DCanvas.Font.Height);
end;

procedure pRect(DCanvas: TCanvas; x1, y1, x2, y2: Double; PenWidth: Integer; PenColor, BrushColor: TColor);
begin
  DCanvas.Pen.Width := PenWidth;
  DCanvas.Pen.Color := PenColor;
  DCanvas.Brush.Color := BrushColor;
  DCanvas.Rectangle(pXmm(x1), pYmm(y1), pXmm(x2), pYmm(y2));
  DCanvas.Pen.Width := pDefPenWidth;
  DCanvas.Pen.Color := pDefPenColor;
  DCanvas.Brush.Color := pDefBrushColor;
end;

procedure pLine(DCanvas: TCanvas; x1, y1, x2, y2: Double; PenWidth: Integer; PenStyle: TPenStyle; PenColor: TColor);
begin
  DCanvas.Pen.Width := PenWidth;
  DCanvas.Pen.Style := PenStyle;
  DCanvas.Pen.Color := PenColor;
  DCanvas.MoveTo(pXmm(x1), pYmm(y1));
  DCanvas.LineTo(pXmm(x2), pYmm(y2));
  DCanvas.Pen.Width := pDefPenWidth;
  DCanvas.Pen.Style := pDefPenStyle;
  DCanvas.Pen.Color := pDefPenColor;
end;

procedure pText(DCanvas: TCanvas; x1, y1: Double; S, FontName: String; FontSize: Integer; FontColor, BrushColor: TColor; FontStyle: TFontStyles);
begin
  DCanvas.Font.Name := FontName;
  DCanvas.Font.Size := FontSize;
  DCanvas.Font.Color := FontColor;
  DCanvas.Font.Style := FontStyle;
  DCanvas.Brush.Color := BrushColor;
  DCanvas.TextOut(pXmm(x1), pYmm(y1), S);
  DCanvas.Font.Name := pDefFontName;
  DCanvas.Font.Size := pDefFontSize;
  DCanvas.Font.Color := pDefFontColor;
  DCanvas.Font.Style := pDefFontStyle;
  DCanvas.Brush.Color := pDefBrushColor;
end;

procedure pCText(DCanvas: TCanvas; x1, y1, x2: Double; S, FontName: String; FontSize: Integer; FontColor, BrushColor: TColor; FontStyle: TFontStyles);
begin
  DCanvas.Font.Name := FontName;
  DCanvas.Font.Size := FontSize;
  DCanvas.Font.Color := FontColor;
  DCanvas.Font.Style := FontStyle;
  DCanvas.Brush.Color := BrushColor;
  DCanvas.TextOut(pXmm(x1 + (x2 - x1) / 2) - DCanvas.TextWidth(S) div 2, pYmm(y1), S);
  DCanvas.Font.Name := pDefFontName;
  DCanvas.Font.Size := pDefFontSize;
  DCanvas.Font.Color := pDefFontColor;
  DCanvas.Font.Style := pDefFontStyle;
  DCanvas.Brush.Color := pDefBrushColor;
end;

procedure pRJText(DCanvas: TCanvas; x1, y1: Double; S, FontName: String; FontSize: Integer; FontColor, BrushColor: TColor; FontStyle: TFontStyles);
begin
  DCanvas.Font.Name := FontName;
  DCanvas.Font.Size := FontSize;
  DCanvas.Font.Color := FontColor;
  DCanvas.Font.Style := FontStyle;
  DCanvas.Brush.Color := BrushColor;
  DCanvas.TextOut(pXmm(x1) - DCanvas.TextWidth(S), pYmm(y1), S);
  DCanvas.Font.Name := pDefFontName;
  DCanvas.Font.Size := pDefFontSize;
  DCanvas.Font.Color := pDefFontColor;
  DCanvas.Font.Style := pDefFontStyle;
  DCanvas.Brush.Color := pDefBrushColor;
end;

procedure pTextRect(DCanvas: TCanvas; x1, y1, x2, y2: Double; S: String; PenWidth: Integer; PenColor, BrushColor: TColor);
begin
  DCanvas.Pen.Width := PenWidth;
  DCanvas.Pen.Color := PenColor;
  DCanvas.Brush.Color := BrushColor;
  DCanvas.TextRect(Rect(pXmm(x1), pYmm(y1), pXmm(x2), pYmm(y2)), pXmm(x1), pYmm(y1), S);
  DCanvas.Pen.Width := pDefPenWidth;
  DCanvas.Pen.Color := pDefPenColor;
  DCanvas.Brush.Color := pDefBrushColor;
end;

procedure pImage(DCanvas: TCanvas; Width_mm, Height_mm, X_mm, Y_mm: String; PICTIDVal, PICTNOVal: Integer);
var
  Q: TIBQuery;
  Graphic: TGraphic;
  Stream: TMemoryStream;
  PICTFORMATVal: String;
  ImageWidth, ImageHeight, ImageX, ImageY: Integer;
begin
  ImageWidth := pXmm(StrToInt(dm.GetParamValue(Width_mm)));
  ImageHeight := pYmm(StrToInt(dm.GetParamValue(Height_mm)));
  ImageX := pXmm(StrToInt(dm.GetParamValue(X_mm)));
  ImageY := pYmm(StrToInt(dm.GetParamValue(Y_mm)));
  Q := TIBQuery.Create(nil);
  try
    Q.Database := dm.IBDatabase1;
    Q.Transaction := dm.IBTransaction1;
    Q.SQL.Add('SELECT PICTFORMAT, PICT FROM T_PICT WHERE PICTID = :PICTID AND PICTNO = :PICTNO');
    Q.ParamByName('PICTID').AsInteger := PICTIDVal;
    Q.ParamByName('PICTNO').AsInteger := PICTNOVal;
    Q.Prepare;
    Q.Open;
    Graphic := nil;
    PICTFORMATVal := Q.FieldByName('PICTFORMAT').AsString;
    if PICTFORMATVal = 'BMP' then
      Graphic := TBitMap.Create
    else if PICTFORMATVal = 'ICO' then
      Graphic := TIcon.Create
    else if (PICTFORMATVal = 'JPG') or (PICTFORMATVal = 'JPEG') then
      Graphic := TJPEGImage.Create;
    if Graphic <> nil then
    begin
      Stream := TMemoryStream.Create;
      try
        Stream.Position := 0;
        TBlobField(Q.FieldByName('PICT')).SaveToStream(Stream);
        Graphic.LoadFromStream(Stream);
        DCanvas.StretchDraw(Rect(ImageX, ImageY, ImageX + ImageWidth, ImageY + ImageHeight), Graphic);
      finally
        Stream.Free;
      end;
    end;
    Q.Close;
  finally
    Q.Free;
  end;
end;

procedure ReadCnfFile;

  function ReadCnfStr(StrId, DefStr: string): string;
  var
    FVar: TextFile;
    S, S1: string;
    StrIdExists: boolean;
  begin
    Result := '';
    if FileExists(ConfigFileName) then
    begin
      S1 := '';
      try
        AssignFile(FVar, ConfigFileName);
        Reset(FVar);
        while not EOF(FVar) do
        begin
          ReadLn(FVar, S);
          StrIdExists := AnsiStartsText(StrId, S);
          if StrIdExists then
          begin
            S1 := Copy(S, Pos(',', S) + 1, Length(S));
            if Trim(S1) <> '' then
            begin
              Result := Trim(S1);
              Exit;
            end;
          end;
        end;
        if not StrIdExists then
        begin
          Result := DefStr;
        end;
      finally
        CloseFile(FVar);
      end;
    end
    else
      Result := DefStr;
  end;

  function ReadCnfInt(StrId: string; DefInt: integer): integer;
  var
    S: string;
  begin
    Result := 0;
    S := ReadCnfStr(StrId, '');
    if S = '' then
      Result := DefInt
    else
      Result := StrToIntDef(S, 0);
  end;

  function ReadCnfDate(StrId: string; DefDate: TDate): TDate;
  var
    S: string;
  begin
    Result := 0;
    S := ReadCnfStr(StrId, '');
    if S = '' then
      Result := DefDate
    else
      Result := StrToDateDef(S, Date);
  end;

  function ReadCnfBool(StrId: string; DefBool: boolean): boolean;
  var
    S: string;
  begin
    Result := true;
    S := ReadCnfStr(StrId, '');
    if S = '' then
      Result := DefBool
    else
      Result := S = 'True';
  end;

begin
  cnf.ServerName := ReadCnfStr('ServerName', 'localhost');
  cnf.DBFileName := ReadCnfStr('DBFileName', '');
  cnf.Role := ReadCnfStr('Role', 'ADMIN');
  cnf.UserName := ReadCnfStr('UserName', 'sysdba');
  cnf.PDFReader := ReadCnfStr('PDFReader', 'SumatraPDF.exe');
  cnf.SnapShotFileName := ReadCnfStr('SnapShotFileName', '');
  cnf.FirebirdPath := ReadCnfStr('FirebirdPath', '');
  cnf.FromEmailAddr := ReadCnfStr('FromEmailAddr', '');
  cnf.SMTPHost := ReadCnfStr('SMTPHost', '');
  cnf.SMTPPort := ReadCnfInt('SMTPPort', 25);
  cnf.EmailUsername := ReadCnfStr('EmailUsername', '');
  cnf.EmailPassword := ReadCnfStr('EmailPassword', '');
  cnf.CurrentYr := ReadCnfInt('CurrentYr', 2016);
  cnf.DefPictId := ReadCnfInt('DefPictId', 0);
  cnf.DefComp := ReadCnfInt('DefComp', 0);
end;

procedure WriteCnfFile;
var
  FVar: TextFile;

  procedure WriteCnfStr(VarId: string; StrVal: String);
  begin
    WriteLn(FVar, VarId, ',', StrVal);
  end;

  procedure WriteCnfInt(VarId: string; IntVal: Integer);
  begin
    WriteLn(FVar, VarId, ',', IntVal);
  end;

  procedure WriteCnfDate(VarId: string; DateVal: TDate);
  begin
    WriteLn(FVar, VarId, ',', DateVal);
  end;

  procedure WriteCnfBool(VarId: string; BoolVal: Boolean);
  begin
    if BoolVal = True then
      WriteLn(FVar, VarId, ',', 'True')
    else
      WriteLn(FVar, VarId, ',', 'False');
  end;

begin
  try
    AssignFile(FVar, ConfigFileName);
    Rewrite(FVar);
    WriteCnfStr('ServerName', cnf.ServerName);
    WriteCnfStr('DBFileName', cnf.DBFileName);
    WriteCnfStr('Role', cnf.Role);
    WriteCnfStr('UserName', cnf.UserName);
    WriteCnfStr('PDFReader', cnf.PDFReader);
    WriteCnfStr('SnapShotFileName', cnf.SnapShotFileName);
    WriteCnfStr('FirebirdPath', cnf.FirebirdPath);
    WriteCnfStr('FromEmailAddr', cnf.FromEmailAddr);
    WriteCnfStr('SMTPHost', cnf.SMTPHost);
    WriteCnfInt('SMTPPort', cnf.SMTPPort);
    WriteCnfStr('EmailUsername', cnf.EmailUsername);
    WriteCnfStr('EmailPassword', cnf.EmailPassword);
    WriteCnfInt('CurrentYr', cnf.CurrentYr);
    WriteCnfInt('DefPictId', cnf.DefPictId);
    WriteCnfInt('DefComp', cnf.DefComp);
  finally
    CloseFile(FVar);
  end;
end;

begin
  ReadCnfFile;
  DefaultFormatSettings.ThousandSeparator := ' ';
end.

