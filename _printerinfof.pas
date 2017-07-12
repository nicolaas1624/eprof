unit _printerinfof;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Forms, Grids, Printers, LCLType, ExtCtrls, StdCtrls, Classes;

type

  { Tprinterinfof }

  Tprinterinfof = class(TForm)
    Label1: TLabel;
    PrintersBox: TComboBox;
    Panel1: TPanel;
    SGrid: TStringGrid;
    procedure FormShow(Sender: TObject);
    procedure PrintersBoxChange(Sender: TObject);
  private
    ck: integer;
    procedure AddInfo(const Desc: string; const Info: string);
    procedure UpdatePrinterInfo;
    function FormatDots(Dots: integer): string;
  public
  end;

var
  printerinfof: Tprinterinfof;

implementation

uses _dm;

{$R *.lfm}

{ Tprinterinfof }

procedure Tprinterinfof.FormShow(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to Printer.Printers.Count - 1 do
    PrintersBox.Items.Add(Printer.Printers[i]);
  PrintersBox.Text := Printer.Printers[Printer.PrinterIndex];
  PrintersBoxChange(Sender);
end;

procedure Tprinterinfof.PrintersBoxChange(Sender: TObject);
begin
  Printer.PrinterIndex := dm.GetPrinterIndex(PrintersBox.Text);
  UpdatePrinterInfo;
end;

procedure Tprinterinfof.AddInfo(const Desc: string; const Info: string);
begin
  SGrid.Cells[0, ck] := Desc;
  SGrid.Cells[1, ck] := Info;
  Inc(ck);
end;

function Tprinterinfof.FormatDots(Dots: integer): string;
begin
  Result := format('%d dots (%f mm, %f in)', [Dots, Dots * 25.4 / Printer.YDPI, Dots / Printer.YDPI]);
end;

procedure Tprinterinfof.UpdatePrinterInfo;
var
  hRes, vRes: integer;
begin
  try
    ck := SGrid.FixedRows;
    SGrid.Clean;
    with Printer do
    begin
      if Printers.Count = 0 then
      begin
        AddInfo('printer', 'no printers are installed');
        exit;
      end;
      AddInfo('Printer', Printers[PrinterIndex]);
      case Orientation of
        poPortrait: AddInfo('Orientation', 'Portrait');
        poLandscape: AddInfo('Orientation', 'Landscape');
        poReverseLandscape: AddInfo('Orientation', 'ReverseLandscape');
        poReversePortrait: AddInfo('Orientation', 'ReversePortrait');
      end;
      case PrinterType of
        ptLocal: AddInfo('PrinterType', 'Local');
        ptNetWork: AddInfo('PrinterType', 'Network');
      end;
      case PrinterState of
        psNoDefine: AddInfo('PrinterState', 'Undefined');
        psReady: AddInfo('PrinterState', 'Ready');
        psPrinting: AddInfo('PrinterState', 'Printing');
        psStopped: AddInfo('PrinterState', 'Stopped');
      end;
      hRes := XDPI;
      vRes := YDPI;
      AddInfo('Resolution X,Y', format('%d,%d dpi', [hRes, vRes]));
      AddInfo('PaperSize', PaperSize.PaperName);
      with Printer.PaperSize.PaperRect.PhysicalRect do
      begin
        AddInfo('Paper Width', FormatDots(Right - Left));
        AddInfo('Paper Height', FormatDots(Bottom - Top));
      end;
      AddInfo('Printable Width', FormatDots(PageWidth));
      AddInfo('Printable Height', FormatDots(PageHeight));
      AddInfo('Copies', IntToStr(Copies));
      if CanRenderCopies then
        AddInfo('CanRenderCopies', 'true')
      else
        AddInfo('CanRenderCopies', 'false');
      if not CanPrint then
        Application.MessageBox('Selected printer cannot print currently!',
          'Warning', mb_iconexclamation);
    end;
  except
    on E: Exception do
      Application.MessageBox(PChar(e.message), 'Error', mb_iconhand);
  end;
end;

end.
