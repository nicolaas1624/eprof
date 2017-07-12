unit _print;

{$mode objfpc}{$H+}

interface

uses SysUtils, Graphics, Printers, Variants,
  Classes;

const
  MaxCols = 150;

type
  TPrn = class(TObject)
  private
  public
    PageNr, NrOfTabs, TFSize, TLH, // title font size, title line height
    PH, LH, TW, // page height, line height & text width
    TM, BM, LM, // top, bottom, left & right margins
    Offset, TitleY, Y: Integer;
    LJSet: Set of 1 .. MaxCols; // left justification set
    Title, SubTitle, SubTitle2, Titles, Units, SubTitles, FooterStr: String;
    HeaderDet: Array [1 .. 10] of String;
    TitleTabs, ColWidths: Variant;
    ColX: Array [1 .. MaxCols] of Integer;
    ColS, ColU, ColDet, ColSubTit: Array [1 .. MaxCols] of String;
    TitleX: Array [0 .. 4] of Integer;
    TitleDet: Array [1 .. 15, 0 .. 4] of String;
    procedure SetReportParams(PrnCanvas: TCanvas; TFS, TMc, BMc, LMc: Integer;
      PrnFont: TFont);
    procedure PrintDetail(PrnCanvas: TCanvas; i1, i2: Integer; Bold: Boolean);
    procedure PrnDrawLine(PrnCanvas: TCanvas; X1, Y1, X2, Y2: Integer);
    procedure DrawColumnlines(PrnCanvas: TCanvas);
    procedure PrnHeader(PrnCanvas: TCanvas);
    procedure PrnFooter(PrnCanvas: TCanvas);
    procedure IncLine(PrnCanvas: TCanvas; var Y1: Integer; LH1: Integer);
    procedure PrnNextLine(PrnCanvas: TCanvas; Bold: Boolean; DrawLine: Boolean);
    procedure PrnFinish(PrnCanvas: TCanvas);
  private
    TitlesEmpty, ShowUnits, ShowSubTit: Boolean;
    procedure SetColTitles;
    procedure SetColWidths(PrnCanvas: TCanvas; TFS, TMc, BMc, LMc: Integer);
  end;

var
  Prn: TPrn;

procedure PrintMemo(MemoLines: TStrings; Fnt: TFont; TMVal, LMVal, HLineFrom, HLineTo: Integer);

implementation

uses _Misc;

procedure TPrn.PrnFinish(PrnCanvas: TCanvas);
begin
  PrnDrawLine(PrnCanvas, LM - Offset, Y - Offset, ColX[NrOfTabs] + Offset,
    Y - Offset);
  PrnFooter(PrnCanvas);
  Printer.EndDoc;
  Printer.Orientation := poPortrait;
end;

procedure TPrn.PrnNextLine(PrnCanvas: TCanvas; Bold: Boolean; DrawLine: Boolean);
begin
  PrintDetail(PrnCanvas, 1, NrOfTabs - 1, Bold);
  if DrawLine then
    PrnDrawLine(PrnCanvas, LM - Offset, Y - Offset, ColX[NrOfTabs] + Offset,
      Y - Offset);
  IncLine(PrnCanvas, Y, LH);
end;

procedure TPrn.SetColTitles;
var
  i: Integer;
begin
  FillChar(ColS, SizeOf(ColS), #0);
  FillChar(ColU, SizeOf(ColU), #0);
  FillChar(ColSubTit, SizeOf(ColSubTit), #0);
  for i := 1 to NrOfTabs do
  begin
    ColS[i] := Copy(Titles, 1, Pos(';', Titles) - 1);
    Delete(Titles, 1, Pos(';', Titles));
    ColU[i] := Copy(Units, 1, Pos(';', Units) - 1);
    Delete(Units, 1, Pos(';', Units));
    ColSubTit[i] := Copy(SubTitles, 1, Pos(';', SubTitles) - 1);
    Delete(SubTitles, 1, Pos(';', SubTitles));
  end;
end;

procedure TPrn.SetColWidths(PrnCanvas: TCanvas; TFS, TMc, BMc, LMc: Integer);
var
  i: Integer;

  procedure FillWidthArray;
  var
    i: Integer;
  begin
    ColX[1] := LM;
    for i := 2 to NrOfTabs do
      ColX[i] := ColX[i - 1] + (TW * ColWidths[i - 1]);
  end;

begin
  FillWidthArray;
  if ColX[NrOfTabs] > Printer.PageWidth then
  begin
    while ColX[NrOfTabs] > Printer.PageWidth do
    begin
      PrnCanvas.Font.Size := PrnCanvas.Font.Size - 1;
      TW := PrnCanvas.TextWidth('0');
      LH := Abs(Trunc(1.5 * PrnCanvas.Font.Height));
      Offset := Round(0.5 * TW);
      FillWidthArray;
    end;
    // MessageDlg('Font size too big. Font size has been set to '+IntToStr(PrnCanvas.Font.Size),mtInformation,[mbOk],0);
  end;
  if not VarIsEmpty(TitleTabs) then
  begin
    TitleX[0] := LM;
    for i := 1 to 4 do
      TitleX[i] := TitleX[i - 1] + (TW * TitleTabs[i]);
  end;
end;

procedure TPrn.SetReportParams(PrnCanvas: TCanvas; TFS, TMc, BMc, LMc: Integer;
  PrnFont: TFont);

  function GetNrOfTabs(S: String): Integer;
  var
    i: Integer;
  begin
    i := 1;
    while Pos(';', S) <> 0 do
    begin
      Delete(S, 1, Pos(';', S));
      Inc(i);
    end;
    Result := i;
  end;

begin
  PrnCanvas.Font := PrnFont;
  PrnCanvas.Pen.Width := 3;
  LH := Abs(Trunc(1.5 * PrnCanvas.Font.Height));
  PH := Printer.PageHeight;
  TW := PrnCanvas.TextWidth('0');
  TM := TMc * LH;
  BM := BMc * LH;
  LM := LMc * LH;
  Offset := Round(0.5 * TW);
  PageNr := 0;
  NrOfTabs := GetNrOfTabs(Titles);
  TFSize := TFS;
  TitlesEmpty := Titles = ';';
  ShowUnits := Units <> '';
  ShowSubTit := SubTitles <> '';
  SetColTitles;
  SetColWidths(PrnCanvas, TFS, TMc, BMc, LMc);
end;

procedure TPrn.PrintDetail(PrnCanvas: TCanvas; i1, i2: Integer; Bold: Boolean);
var
  i: Integer;
begin
  if Bold then
    PrnCanvas.Font.Style := [fsBold];
  for i := i1 to i2 do
    if i in LJSet then
      PrnCanvas.TextOut(ColX[i], Y, ColDet[i])
    else
      PrnCanvas.TextOut(ColX[i + 1] - PrnCanvas.TextWidth(ColDet[i]) - Offset,
        Y, ColDet[i]);
  if Bold then
    PrnCanvas.Font.Style := [];
end;

procedure TPrn.PrnDrawLine(PrnCanvas: TCanvas; X1, Y1, X2, Y2: Integer);
begin
  PrnCanvas.MoveTo(X1, Y1);
  PrnCanvas.LineTo(X2, Y2);
end;

procedure TPrn.DrawColumnlines(PrnCanvas: TCanvas);
var
  i: Integer;
begin
  if SubTitle2 <> '' then
    TLH := TLH * 2;
  for i := 1 to NrOfTabs - 1 do
    if i in LJSet then
    begin
      if i = 1 then
        PrnCanvas.Pen.Width := 3
      else
        PrnCanvas.Pen.Width := 1;
      PrnDrawLine(PrnCanvas, ColX[i] - Offset, TitleY, ColX[i] - Offset,
        Y { PH-BM } );
    end
    else
    begin
      if i = 1 then
      begin
        PrnCanvas.Pen.Width := 3;
        PrnDrawLine(PrnCanvas, ColX[i] - Offset, TitleY, ColX[i] - Offset,
          Y { PH-BM } );
      end
      else
      begin
        PrnCanvas.Pen.Width := 1;
        PrnDrawLine(PrnCanvas, ColX[i] + Offset, TitleY, ColX[i] + Offset,
          Y { PH-BM } );
      end;
    end;
  PrnCanvas.Pen.Width := 3;
  PrnDrawLine(PrnCanvas, ColX[NrOfTabs] + Offset, TitleY,
    ColX[NrOfTabs] + Offset, Y { PH-BM } );
  PrnDrawLine(PrnCanvas, LM - Offset, Y { PH-BM } , ColX[NrOfTabs] + Offset,
    Y { PH-BM } );
  PrnCanvas.Pen.Width := 1;
end;

procedure TPrn.PrnHeader(PrnCanvas: TCanvas);
var
  LF: Boolean;
  i, j, TmpFS: Integer;
begin
  Y := TM;
  PrnCanvas.Pen.Width := 3;
  PrnCanvas.Font.Style := [fsBold];
  Inc(PageNr);
  TmpFS := PrnCanvas.Font.Size;
  PrnCanvas.Font.Size := TFSize;
  TLH := Abs(Trunc(1.5 * PrnCanvas.Font.Height));
  if Title <> '' then
  begin
    PrnCanvas.TextOut(LM + ((ColX[NrOfTabs] - LM) div 2) -
      (PrnCanvas.TextWidth(Title) div 2), Y, Title);
    Inc(Y, TLH);
  end;

  if HeaderDet[1] <> '' then
  begin
    Dec(Y, TLH);
    PrnCanvas.Font.Size := TmpFS;
    Inc(Y, LH);
    for i := 1 to 10 do
      if HeaderDet[i] <> '' then
      begin
        PrnCanvas.TextOut(LM + ((ColX[NrOfTabs] - LM) div 2) -
          (PrnCanvas.TextWidth(HeaderDet[i]) div 2), Y, HeaderDet[i]);
        Inc(Y, LH);
      end;
    Inc(Y, LH);
    PrnCanvas.Font.Size := TFSize;
  end;

  if SubTitle <> '' then
  begin
    PrnCanvas.TextOut(LM + ((ColX[NrOfTabs] - LM) div 2) -
      (PrnCanvas.TextWidth(SubTitle) div 2), Y, SubTitle);
    Inc(Y, TLH);
  end;
  if SubTitle2 <> '' then
  begin
    PrnCanvas.TextOut(LM + ((ColX[NrOfTabs] - LM) div 2) -
      (PrnCanvas.TextWidth(SubTitle2) div 2), Y, SubTitle2);
    Inc(Y, TLH);
  end;

  PrnCanvas.Font.Size := TmpFS;
  for i := 1 to 15 do
  begin
    LF := False;
    for j := 0 to 4 do
      if TitleDet[i, j] <> '' then
      begin
        PrnCanvas.TextOut(TitleX[j], Y, TitleDet[i, j]);
        LF := True;
      end;
    if LF then
      Inc(Y, LH);
  end;
  if not VarIsEmpty(TitleTabs) then
    Inc(Y, LH div 2);

  TitleY := Y - Offset;
  if not TitlesEmpty then
    PrnDrawLine(PrnCanvas, LM - Offset, Y - Offset, ColX[NrOfTabs] + Offset,
      Y - Offset);

  if not ShowUnits then
    Inc(Y, Round(0.4 * LH));

  // Print column titles
  if not TitlesEmpty then
    for i := 1 to NrOfTabs - 1 do
      if i in LJSet then
        PrnCanvas.TextOut(ColX[i], Y, ColS[i])
      else
        PrnCanvas.TextOut(ColX[i + 1] - PrnCanvas.TextWidth(ColS[i]),
          Y, ColS[i]);

  if ShowUnits then
    Inc(Y, LH)
  else if not TitlesEmpty then
    Inc(Y, Round(1.4 * LH));

  // Print column units
  if ShowUnits then
  begin
    for i := 1 to NrOfTabs - 1 do
      if i in LJSet then
        PrnCanvas.TextOut(ColX[i], Y, ColU[i])
      else
        PrnCanvas.TextOut(ColX[i + 1] - PrnCanvas.TextWidth(ColU[i]),
          Y, ColU[i]);
    Inc(Y, LH);
  end;

  // Print column sub titles
  if ShowSubTit then
  begin
    for i := 1 to NrOfTabs - 1 do
      if i in LJSet then
        PrnCanvas.TextOut(ColX[i], Y, ColSubTit[i])
      else
        PrnCanvas.TextOut(ColX[i + 1] - PrnCanvas.TextWidth(ColSubTit[i]), Y,
          ColSubTit[i]);
    Inc(Y, LH);
  end;
  if not TitlesEmpty then
    PrnDrawLine(PrnCanvas, LM - Offset, Y - Offset, ColX[NrOfTabs] + Offset,
      Y - Offset);

  PrnCanvas.Pen.Width := 1;
  PrnCanvas.Font.Style := [];
end;

procedure TPrn.PrnFooter(PrnCanvas: TCanvas);
var
  PageStr: String;
begin
  DrawColumnlines(PrnCanvas);
  PrnCanvas.Pen.Width := 3;
  PageStr := 'Page ' + IntToStr(PageNr);
  PrnCanvas.TextOut(LM, PH - BM + LH div 3, FooterStr);
  PrnCanvas.TextOut(ColX[NrOfTabs] - PrnCanvas.TextWidth(PageStr),
    PH - BM + LH div 2, PageStr);
  PrnCanvas.Pen.Width := 1;
end;

procedure TPrn.IncLine(PrnCanvas: TCanvas; var Y1: Integer; LH1: Integer);
begin
  Inc(Y1, LH1);
  if Y1 > PH - BM - LH1 then
  begin
    PrnFooter(PrnCanvas);
    Printer.NewPage;
    PrnHeader(PrnCanvas);
  end;
end;

procedure PrintMemo(MemoLines: TStrings; Fnt: TFont; TMVal, LMVal, HLineFrom, HLineTo: Integer);
var
  S, LineStr: String;
  i, j, nLine, nPage, TW, LM, TM, LH: Integer;
begin
  Printer.Canvas.Font.Assign(Fnt);
  TW := Printer.Canvas.TextWidth('X');
  LH := Abs(Printer.Canvas.Font.Height);
  TM := LH * TMVal;
  LM := TW * LMVal;
  nPage := 1;
  nLine := 0;
  LineStr := PadLeft(LineStr, '-', 153);
  Printer.BeginDoc;
  for i := 0 to MemoLines.Count - 1 do
  begin
    if (LH * (nLine + 1)) + TM >= Printer.PageHeight - TM - LH then
    begin
      Printer.Canvas.TextOut(LM, (LH * nLine) + TM, LineStr);
      S := 'Page-' + IntToStr(nPage);
      Printer.Canvas.TextOut(Printer.PageWidth div 2 - Printer.Canvas.TextWidth(S) div 2, Printer.PageHeight - TM, S);
      Printer.NewPage;
      Inc(nPage);
      nLine := 0;
      for j := HLineFrom - 1 to HLineTo - 1 do
      begin
        Printer.Canvas.TextOut(LM, (LH * nLine) + TM, MemoLines[j]);
        Inc(nLine);
      end;
    end;
    Printer.Canvas.TextOut(LM, (LH * nLine) + TM, MemoLines[i]);
    Inc(nLine);
  end;
  S := 'Page-' + IntToStr(nPage);
  Printer.Canvas.TextOut(Printer.PageWidth div 2 - Printer.Canvas.TextWidth(S) div 2, Printer.PageHeight - TM, S);
  Printer.EndDoc;
end;

end.

procedure PrintMemo(MemoLines: TStrings; Fnt: TFont);
var
  nLine, nPage, TW, TH, LM, TM, BM, LH, i: Integer;
begin
  Printer.Canvas.Font.Assign(Fnt);
  TW := Printer.Canvas.TextWidth('X');
  LH := Abs(Printer.Canvas.Font.Height);
  LM := TW * 10;
  TM := LH * 5;
  nPage := 1;
  nLine := 0;
  Printer.BeginDoc;
  for i := 0 to MemoLines.Count - 1 do
  begin
    if (LH * nLine) + TM >= Printer.PageHeight - TM - LH then
    begin
      Inc(nPage);
      Printer.Canvas.TextOut(LM, Printer.PageHeight - TM, 'Page-' + IntToStr(nPage));
      nLine := 0;
      Printer.NewPage;
    end;
    Printer.Canvas.TextOut(LM, (LH * nLine) + TM, MemoLines[i]);
    Inc(nLine);
  end;
  Printer.EndDoc;
end;
