unit _lookupf;

{$mode objfpc}{$H+}

interface

uses
  LCLType, SysUtils, Variants, Controls, Forms, Dialogs, DB, DBGrids,
  ExtCtrls, StdCtrls, ComCtrls, Printers, _global, IBQuery, IBCustomDataSet,
  IBSQL, DBCtrls;

type

  { Tlookupf }

  Tlookupf = class(TForm)
    T_LOOKUPQ: TIBQuery;
    T_LOOKUPQDESCR: TIBStringField;
    T_LOOKUPQGRP: TIBStringField;
    T_LOOKUPQID: TIntegerField;
    Panel1: TPanel;
    DBGrid1: TDBGrid;
    DataSource1: TDataSource;
    ShowAllBtn: TToolButton;
    ToolBar1: TToolBar;
    InsertBtn: TToolButton;
    EditBtn: TToolButton;
    DeleteBtn: TToolButton;
    ToolButton1: TToolButton;
    PrintBtn: TToolButton;
    Panel3: TPanel;
    Label1: TLabel;
    SortBox: TComboBox;
    Label2: TLabel;
    GRPBox: TComboBox;
    DBNavigator1: TDBNavigator;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var CLoseAction: TCloseAction);
    procedure ShowAllBtnClick(Sender: TObject);
    procedure SortBoxChange(Sender: TObject);
    procedure InsertBtnClick(Sender: TObject);
    procedure EditBtnClick(Sender: TObject);
    procedure DeleteBtnClick(Sender: TObject);
    procedure PrintBtnClick(Sender: TObject);
    procedure DBGrid1DblClick(Sender: TObject);
  private
    GRPVal: String;
    IDVal: Integer;
    DESCRVal: String;
    OLDGRPVal: String;
    OLDIDVal: Integer;
    procedure OpenT_LOOKUPQ(GRPVal1, Order: String);
    procedure InsUpdDelT_LOOKUP(CaptureState: TCaptureState);
    procedure ShowCapT_LOOKUP(CaptureState: TCaptureState);
    procedure PrintT_LOOKUPData;
  public
    DefGRP: String;
  end;

var
  lookupf: Tlookupf;

implementation

uses _dm, _print, _capt_lookupf, _mainf;

{$R *.lfm}

procedure Tlookupf.FormShow(Sender: TObject);
begin
  try
    Screen.Cursor := crHourglass;
    SortBox.Items.CommaText := 'Id, Description';
    SortBox.Text := 'Id';

    GRPBox.Items.Add('*ALL*');
    dm.OpenQ('SELECT DISTINCT GRP FROM T_LOOKUP ORDER BY GRP');
    while not dm.XQ.Eof do
    begin
      GRPBox.Items.Add(dm.XQ.FieldByName('GRP').AsString);
      dm.XQ.Next;
    end;
    dm.XQ.Close;
    if DefGRP = '' then
      GRPBox.Text := '*ALL*'
    else
      GRPBox.Text := DefGRP;

    SortBoxChange(Sender);
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure Tlookupf.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  T_LOOKUPQ.Close;
  dm.IBTransaction1.CommitRetaining;
end;

procedure Tlookupf.ShowAllBtnClick(Sender: TObject);
begin
  GRPVal := T_LOOKUPQGRP.AsString;
  IDVal := T_LOOKUPQID.AsInteger;
  GRPBox.Text := '*ALL*';
  SortBoxChange(Sender);
end;

procedure Tlookupf.OpenT_LOOKUPQ(GRPVal1, Order: String);
begin
  T_LOOKUPQ.Close;
  T_LOOKUPQ.SQL.Clear;
  T_LOOKUPQ.SQL.Add('SELECT * FROM T_LOOKUP');
  if GRPVal1 <> '*ALL*' then
    T_LOOKUPQ.SQL.Add('WHERE GRP = :GRP');
  T_LOOKUPQ.SQL.Add('ORDER BY ' + Order);
  if GRPVal1 <> '*ALL*' then
    T_LOOKUPQ.ParamByName('GRP').AsString := GRPVal1;
  T_LOOKUPQ.Prepare;
  T_LOOKUPQ.Open;
end;

procedure Tlookupf.SortBoxChange(Sender: TObject);
var
  S: String;
begin
  try
    Screen.Cursor := crHourglass;
    InsertBtn.Enabled := GRPBox.Text <> '*ALL*';
    EditBtn.Enabled := GRPBox.Text <> '*ALL*';
    if SortBox.Text = 'Description' then
      S := 'GRP,DESCR'
    else
      S := 'GRP,ID';
    OpenT_LOOKUPQ(GRPBox.Text, S);
    T_LOOKUPQ.Locate('GRP;ID', VarArrayOf([GRPVal, IDVal]), []);
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure Tlookupf.InsUpdDelT_LOOKUP(CaptureState: TCaptureState);
var
  Q: TIBSQL;
begin
  Q := TIBSQL.Create(nil);
  try
    Q.Database := dm.IBDatabase1;
    Q.Transaction := dm.IBTransaction1;
    if CaptureState = csInsert then
    begin
      Q.SQL.Add('INSERT INTO T_LOOKUP(GRP,ID,DESCR)');
      Q.SQL.Add('VALUES(:GRP,:ID,:DESCR)');
    end
    else if CaptureState = csEdit then
    begin
      Q.SQL.Add('UPDATE T_LOOKUP SET GRP = :GRP,ID = :ID,DESCR = :DESCR');
      Q.SQL.Add('WHERE GRP = :OLDGRP AND ID = :OLDID');
      Q.ParamByName('OLDGRP').AsString := OLDGRPVal;
      Q.ParamByName('OLDID').AsInteger := OLDIDVal;
    end
    else if CaptureState = csDelete then
      Q.SQL.Add('DELETE FROM T_LOOKUP WHERE GRP = :GRP AND ID = :ID');
    Q.ParamByName('GRP').AsString := GRPVal;
    Q.ParamByName('ID').AsInteger := IDVal;
    if CaptureState in [csInsert, csEdit] then
      Q.ParamByName('DESCR').AsString := DESCRVal;
    Q.Prepare;
    Q.ExecQuery;
    Q.Close;
  finally
    FreeAndNil(Q);
  end;
end;

procedure Tlookupf.ShowCapT_LOOKUP(CaptureState: TCaptureState);

  procedure AssignT_LOOKUPValues;
  begin
    GRPVal := GRPBox.Text;
    IDVal := StrToInt(CapT_LOOKUPF.IDBox.Text);
    DESCRVal := CapT_LOOKUPF.DESCRBox.Text;
  end;

begin
  CapT_LOOKUPF := TCapT_LOOKUPF.Create(Application);
  try
    if CaptureState = csInsert then
    begin
      CapT_LOOKUPF.Caption := 'Insert';
      CapT_LOOKUPF.OkBtn.Caption := '&Insert';
    end
    else if CaptureState = csEdit then
    begin
      CapT_LOOKUPF.Caption := 'Edit';
      CapT_LOOKUPF.OkBtn.Caption := '&Update';
      OLDGRPVal := T_LOOKUPQGRP.Value;
      OLDIDVal := T_LOOKUPQID.Value;
    end;
    CapT_LOOKUPF.FillForm(CaptureState);
    if CapT_LOOKUPF.ShowModal = mrOk then
    begin
      AssignT_LOOKUPValues;
      InsUpdDelT_LOOKUP(CaptureState);
      SortBoxChange(lookupf);
    end;
  finally
    FreeAndNil(CapT_LOOKUPF);
  end;
end;

procedure Tlookupf.InsertBtnClick(Sender: TObject);
begin
  ShowCapT_LOOKUP(csInsert);
end;

procedure Tlookupf.EditBtnClick(Sender: TObject);
begin
  if not T_LOOKUPQ.IsEmpty then
    ShowCapT_LOOKUP(csEdit);
end;

procedure Tlookupf.DeleteBtnClick(Sender: TObject);
begin
  if MessageDlg('Delete record?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    GRPVal := T_LOOKUPQGRP.AsString;
    IDVal := T_LOOKUPQID.AsInteger;
    InsUpdDelT_LOOKUP(csDelete);
    SortBoxChange(Sender);
  end;
end;

procedure Tlookupf.PrintT_LOOKUPData;

  procedure InitReport;
  begin
    with Prn do
    begin
      LJSet := [1..3];
      Title := 'Lookup Data';
      FooterStr := DateToStr(Date);
      Titles := 'Group;Id;Description;';
      ColWidths := VarArrayOf([0, 25, 6, 60]);
      SetReportParams(Printer.Canvas, 10, 2, 3, 3, mainf.FontDialog1.Font);
    end;
  end;

begin
  Prn := TPrn.Create;
  with Prn do
    try
      Printer.BeginDoc;
      InitReport;
      PrnHeader(Printer.Canvas);
      T_LOOKUPQ.First;
      while not T_LOOKUPQ.Eof do
      begin
        ColDet[1] := T_LOOKUPQGRP.AsString;
        ColDet[2] := T_LOOKUPQID.AsString;
        ColDet[3] := T_LOOKUPQDESCR.AsString;
        PrnNextLine(Printer.Canvas, False, True);
        T_LOOKUPQ.Next;
      end;
      PrnFinish(Printer.Canvas);
    finally
      Prn.Free;
    end;
end;

procedure Tlookupf.PrintBtnClick(Sender: TObject);
begin
  if mainf.PrintDialog1.Execute then
    if mainf.FontDialog1.Execute then
      try
        Screen.Cursor := crHourglass;
        PrintT_LOOKUPData;
      finally
        Screen.Cursor := crDefault;
      end;
end;

procedure Tlookupf.DBGrid1DblClick(Sender: TObject);
begin
  GRPBox.Text := T_LOOKUPQGRP.AsString;
  SortBoxChange(Sender);
end;

end.
