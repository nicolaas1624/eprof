unit _t_subsf;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DB, Forms, Controls, Dialogs, ComCtrls, ExtCtrls,
  StdCtrls, DBCtrls, DBGrids, _global, IBQuery, IBCustomDataSet, Printers,
  Variants, Graphics;

type

  { Tt_subsf }

  Tt_subsf = class(TForm)
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    DBNavigator1: TDBNavigator;
    DeleteBtn: TToolButton;
    EditBtn: TToolButton;
    T_SUBSQ: TIBQuery;
    InsertBtn: TToolButton;
    Label1: TLabel;
    Panel1: TPanel;
    Panel3: TPanel;
    PrintBtn: TToolButton;
    SortBox: TComboBox;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    T_SUBSQDESCR: TIBStringField;
    T_SUBSQSERIALNO: TIBStringField;
    T_SUBSQSUBID: TIntegerField;
    procedure DeleteBtnClick(Sender: TObject);
    procedure EditBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure InsertBtnClick(Sender: TObject);
    procedure PrintBtnClick(Sender: TObject);
    procedure SortBoxChange(Sender: TObject);
  private
    SUBIDVal: integer;
    DESCRVal: string;
    SERIALNOVal: string;
    OLDSUBIDVal: integer;
    procedure InitGrid;
    procedure OpenT_SUBSQ(Order: string);
    procedure InsUpdDelT_SUBS(CaptureState: TCaptureState);
    procedure ShowCapT_SUBS(CaptureState: TCaptureState);
  public
  end;

var
  t_subsf: Tt_subsf;

implementation

uses _dm, _capt_subsf, _print, _mainf;

{$R *.lfm}

{ Tt_subsf }

procedure Tt_subsf.FormCreate(Sender: TObject);
begin
  Height := Trunc(Screen.Height * 0.6);
  InitGrid;
end;

procedure Tt_subsf.FormShow(Sender: TObject);
begin
  try
    Screen.Cursor := crHourglass;
    SortBox.Items.CommaText := 'Id, Description, "Serial No"';
    SortBox.Text := 'Id';
    SortBoxChange(Sender);
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure Tt_subsf.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  T_SUBSQ.Close;
  DM.IBTransaction1.CommitRetaining;
end;

procedure Tt_subsf.InitGrid;
begin
  DBGrid1.Options := [dgTitles,dgIndicator,dgColumnResize,dgColumnMove,dgColLines,dgRowLines,dgTabs,dgAlwaysShowSelection,dgCancelOnExit,dgAutoSizeColumns,dgRowHighlight];
  DBGrid1.Columns.Add;
  DBGrid1.Columns[DBGrid1.Columns.Count - 1].FieldName := 'SUBID';
  DBGrid1.Columns[DBGrid1.Columns.Count - 1].Title.Caption := 'Sub-id';
  DBGrid1.Columns[DBGrid1.Columns.Count - 1].DisplayFormat := '';
  DBGrid1.Columns[DBGrid1.Columns.Count - 1].Color := clWindow;
  DBGrid1.Columns.Add;
  DBGrid1.Columns[DBGrid1.Columns.Count - 1].FieldName := 'DESCR';
  DBGrid1.Columns[DBGrid1.Columns.Count - 1].Title.Caption := 'Description';
  DBGrid1.Columns[DBGrid1.Columns.Count - 1].DisplayFormat := '';
  DBGrid1.Columns[DBGrid1.Columns.Count - 1].Color := clWindow;
  DBGrid1.Columns.Add;
  DBGrid1.Columns[DBGrid1.Columns.Count - 1].FieldName := 'SERIALNO';
  DBGrid1.Columns[DBGrid1.Columns.Count - 1].Title.Caption := 'Serial no';
  DBGrid1.Columns[DBGrid1.Columns.Count - 1].DisplayFormat := '';
  DBGrid1.Columns[DBGrid1.Columns.Count - 1].Color := clWindow;
end;

procedure TT_SUBSF.OpenT_SUBSQ(Order: string);
begin
  T_SUBSQ.Close;
  T_SUBSQ.SQL.Clear;
  T_SUBSQ.SQL.Add('SELECT * FROM T_SUBS ORDER BY ' + Order);
  T_SUBSQ.Prepare;
  T_SUBSQ.Open;
end;

procedure TT_SUBSF.SortBoxChange(Sender: TObject);
var
  S: string;
begin
  try
    Screen.Cursor := crHourglass;
    if SortBox.Text = 'Description' then
      S := 'DESCR'
    else if SortBox.Text = 'Serial No' then
      S := 'SERIALNO'
    else
      S := 'SUBID';
    OpenT_SUBSQ(S);
    T_SUBSQ.Locate('SUBID', SUBIDVal, []);
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TT_SUBSF.InsUpdDelT_SUBS(CaptureState: TCaptureState);
var
  Q: TIBQuery;
begin
  Q := TIBQuery.Create(nil);
  try
    Q.Database := DM.IBDatabase1;
    Q.Transaction := DM.IBTransaction1;
    if CaptureState = csInsert then
    begin
      Q.SQL.Add('INSERT INTO T_SUBS(SUBID,DESCR,SERIALNO)');
      Q.SQL.Add('VALUES(:SUBID,:DESCR,:SERIALNO)');
    end
    else if CaptureState = csEdit then
    begin
      Q.SQL.Add('UPDATE T_SUBS SET SUBID = :SUBID,DESCR = :DESCR,SERIALNO = :SERIALNO');
      Q.SQL.Add('WHERE SUBID = :OLDSUBID');
      Q.ParamByName('OLDSUBID').AsInteger := OLDSUBIDVal;
    end
    else if CaptureState = csDelete then
      Q.SQL.Add('DELETE FROM T_SUBS WHERE SUBID = :SUBID');
    Q.ParamByName('SUBID').AsInteger := SUBIDVal;
    if CaptureState in [csInsert, csEdit] then
    begin
      Q.ParamByName('DESCR').AsString := DESCRVal;
      Q.ParamByName('SERIALNO').AsString := SERIALNOVal;
    end;
    Q.Prepare;
    Q.ExecSQL;
    Q.Close;
  finally
    Q.Free;
  end;
end;

procedure TT_SUBSF.ShowCapT_SUBS(CaptureState: TCaptureState);

  procedure AssignT_SUBSValues;
  begin
    SUBIDVal := StrToInt(CapT_SUBSF.SUBIDBox.Text);
    DESCRVal := CapT_SUBSF.DESCRBox.Text;
    SERIALNOVal := CapT_SUBSF.SERIALNOBox.Text;
  end;

begin
  CapT_SUBSF := TCapT_SUBSF.Create(Application);
  try
    if CaptureState = csInsert then
    begin
      CapT_SUBSF.Caption := 'Insert';
      CapT_SUBSF.OkBtn.Caption := '&Insert';
    end
    else if CaptureState = csEdit then
    begin
      CapT_SUBSF.Caption := 'Edit';
      CapT_SUBSF.OkBtn.Caption := '&Update';
      OLDSUBIDVal := T_SUBSQSUBID.Value;
    end;
    CapT_SUBSF.FillForm(CaptureState);
    if CapT_SUBSF.ShowModal = mrOk then
    begin
      AssignT_SUBSValues;
      InsUpdDelT_SUBS(CaptureState);
      SortBoxChange(T_SUBSF);
    end;
  finally
    FreeAndNil(CapT_SUBSF);
  end;
end;

procedure TT_SUBSF.InsertBtnClick(Sender: TObject);
begin
  ShowCapT_SUBS(csInsert);
end;

procedure TT_SUBSF.EditBtnClick(Sender: TObject);
begin
  if not T_SUBSQ.IsEmpty then
    ShowCapT_SUBS(csEdit);
end;

procedure TT_SUBSF.DeleteBtnClick(Sender: TObject);
begin
  if MessageDlg('Delete record?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    SUBIDVal := T_SUBSQSUBID.Value;
    InsUpdDelT_SUBS(csDelete);
    SortBoxChange(Sender);
  end;
end;

procedure TT_SUBSF.PrintBtnClick(Sender: TObject);

  procedure PrintT_SUBSData;

    procedure InitReport;
    begin
      with Prn do
      begin
        LJSet := [2, 3];
        Title := 'List of Substation';
        FooterStr := DateToStr(Date);
        Titles := 'Id  ;Description;Serial No;';
        ColWidths := VarArrayOf([0, 10, 60, 35]);
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
        T_SUBSQ.First;
        while not T_SUBSQ.EOF do
        begin
          ColDet[1] := T_SUBSQSUBID.AsString + '  ';
          ColDet[2] := T_SUBSQDESCR.AsString;
          ColDet[3] := T_SUBSQSERIALNO.AsString;
          PrnNextLine(Printer.Canvas, False, True);
          T_SUBSQ.Next;
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
        PrintT_SUBSData;
      finally
        Screen.Cursor := crDefault;
      end;
end;

end.
