unit _t_paramvaluesf;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, DB, Forms, Controls, Dialogs, ComCtrls, ExtCtrls, DBGrids, DBCtrls,
  _global, IBSQL, IBQuery, IBCustomDataSet, Printers, Variants;

type

  { Tt_paramvaluesf }

  Tt_paramvaluesf = class(TForm)
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    DBNavigator1: TDBNavigator;
    DeleteBtn: TToolButton;
    EditBtn: TToolButton;
    HelpBtn: TToolButton;
    T_PARAMVALUESQ: TIBQuery;
    T_PARAMVALUESQPARAMID: TIBStringField;
    T_PARAMVALUESQPARAMVALUE: TIBStringField;
    InsertBtn: TToolButton;
    Panel1: TPanel;
    PrintBtn: TToolButton;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    procedure DeleteBtnClick(Sender: TObject);
    procedure EditBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure InsertBtnClick(Sender: TObject);
    procedure PrintBtnClick(Sender: TObject);
  private
    PARAMIDVal: string;
    PARAMVALUEVal: string;
    OLDPARAMIDVal: string;
    procedure OpenT_PARAMVALUESQ;
    procedure InsUpdDelT_PARAMVALUES(CaptureState: TCaptureState);
    procedure ShowCapT_PARAMVALUES(CaptureState: TCaptureState);
  public
  end;

var
  t_paramvaluesf: Tt_paramvaluesf;

implementation

uses _mainf, _dm, _capt_paramvaluesf, _print;

{$R *.lfm}

{ Tt_paramvaluesf }

procedure Tt_paramvaluesf.FormShow(Sender: TObject);
begin
  try
    Screen.Cursor := crHourglass;
    OpenT_PARAMVALUESQ;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure Tt_paramvaluesf.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  T_PARAMVALUESQ.Close;
end;

procedure TT_PARAMVALUESF.OpenT_PARAMVALUESQ;
begin
  T_PARAMVALUESQ.Close;
  T_PARAMVALUESQ.SQL.Clear;
  T_PARAMVALUESQ.SQL.Add('SELECT * FROM T_PARAMVALUES ORDER BY PARAMID');
  T_PARAMVALUESQ.Prepare;
  T_PARAMVALUESQ.Open;
end;

procedure Tt_paramvaluesf.InsUpdDelT_PARAMVALUES(CaptureState: TCaptureState);
var
  Q: TIBSQL;
begin
  Q := TIBSQL.Create(nil);
  try
    Q.Database := dm.IBDatabase1;
    Q.Transaction := dm.IBTransaction1;
    if CaptureState = csInsert then
    begin
      Q.SQL.Add('INSERT INTO T_PARAMVALUES(PARAMID,PARAMVALUE)');
      Q.SQL.Add('VALUES(:PARAMID,:PARAMVALUE)');
    end
    else if CaptureState = csEdit then
    begin
      Q.SQL.Add('UPDATE T_PARAMVALUES SET PARAMID = :PARAMID,PARAMVALUE = :PARAMVALUE');
      Q.SQL.Add('WHERE PARAMID = :OLDPARAMID');
      Q.ParamByName('OLDPARAMID').AsString := OLDPARAMIDVal;
    end
    else if CaptureState = csDelete then
      Q.SQL.Add('DELETE FROM T_PARAMVALUES WHERE PARAMID = :PARAMID');
    Q.ParamByName('PARAMID').AsString := PARAMIDVal;
    if CaptureState in [csInsert, csEdit] then
    begin
      Q.ParamByName('PARAMID').AsString := PARAMIDVal;
      Q.ParamByName('PARAMVALUE').AsString := PARAMVALUEVal;
    end;
    Q.Prepare;
    Q.ExecQuery;
    Q.Close;
  finally
    Q.Free;
  end;
end;

procedure Tt_paramvaluesf.ShowCapT_PARAMVALUES(CaptureState: TCaptureState);

  procedure AssignT_PARAMVALUESValues;
  begin
    PARAMIDVal := CapT_PARAMVALUESF.PARAMIDBox.Text;
    PARAMVALUEVal := CapT_PARAMVALUESF.PARAMVALUEBox.Text;
  end;

begin
  CapT_PARAMVALUESF := TCapT_PARAMVALUESF.Create(Application);
  try
    if CaptureState = csInsert then
    begin
      CapT_PARAMVALUESF.Caption := 'Insert';
      CapT_PARAMVALUESF.OkBtn.Caption := '&Insert';
    end
    else if CaptureState = csEdit then
    begin
      CapT_PARAMVALUESF.Caption := 'Edit';
      CapT_PARAMVALUESF.OkBtn.Caption := '&Update';
      OLDPARAMIDVal := T_PARAMVALUESQPARAMID.Value;
    end;
    CapT_PARAMVALUESF.FillForm(CaptureState);
    if CapT_PARAMVALUESF.ShowModal = mrOk then
    begin
      AssignT_PARAMVALUESValues;
      InsUpdDelT_PARAMVALUES(CaptureState);
      OpenT_PARAMVALUESQ;
      T_PARAMVALUESQ.Locate('PARAMID', PARAMIDVal, []);
    end;
  finally
    FreeAndNil(CapT_PARAMVALUESF);
  end;
end;

procedure Tt_paramvaluesf.InsertBtnClick(Sender: TObject);
begin
  ShowCapT_PARAMVALUES(csInsert);
end;

procedure Tt_paramvaluesf.EditBtnClick(Sender: TObject);
begin
  if not T_PARAMVALUESQ.IsEmpty then
  begin
    PARAMIDVal := T_PARAMVALUESQPARAMID.Value;
    ShowCapT_PARAMVALUES(csEdit);
  end;
end;

procedure Tt_paramvaluesf.DeleteBtnClick(Sender: TObject);
begin
  if MessageDlg('Delete record?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    PARAMIDVal := T_PARAMVALUESQPARAMID.Value;
    InsUpdDelT_PARAMVALUES(csDelete);
    OpenT_PARAMVALUESQ;
  end;
end;

procedure Tt_paramvaluesf.PrintBtnClick(Sender: TObject);

  procedure PrintT_PARAMVALUESData;

    procedure InitReport;
    begin
      with Prn do
      begin
        LJSet := [1, 2];
        Title := 'Setup parameters';
        FooterStr := DateToStr(Date);
        Titles := 'Parameter-id;Parameter value;';
        ColWidths := VarArrayOf([0, 25, 60]);
        SetReportParams(Printer.Canvas, 10, 2, 3, 4, mainf.FontDialog1.Font);
      end;
    end;

  begin
    Prn := TPrn.Create;
    with Prn do
      try
        Printer.Orientation := poPortrait;
        Printer.BeginDoc;
        InitReport;
        PrnHeader(Printer.Canvas);
        T_PARAMVALUESQ.First;
        while not T_PARAMVALUESQ.EOF do
        begin
          ColDet[1] := T_PARAMVALUESQPARAMID.AsString;
          ColDet[2] := T_PARAMVALUESQPARAMVALUE.AsString;
          PrnNextLine(Printer.Canvas, False, True);
          T_PARAMVALUESQ.Next;
        end;
        PrnFinish(Printer.Canvas);
      finally
        Prn.Free;
      end;
  end;

begin
  if mainf.PrintDialog1.Execute then
    if mainf.FontDialog1.Execute then
      try
        Screen.Cursor := crHourglass;
        PrintT_PARAMVALUESData;
      finally
        Screen.Cursor := crDefault;
      end;
end;

procedure Tt_paramvaluesf.HelpBtnClick(Sender: TObject);
begin
  mainf.ShowPDFHelp(150);
end;

end.


