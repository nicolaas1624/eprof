unit _t_pictf;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls,
  ExtCtrls, ComCtrls, DBCtrls, DBGrids, DB, Printers, ExtDlgs, Buttons, _Global,
  IBQuery, IBCustomDataSet, IBSQL;

type

  { Tt_pictf }

  Tt_pictf = class(TForm)
    DBMemo1: TDBMemo;
    GroupBox1: TGroupBox;
    T_PICTQ: TIBQuery;
    T_PICTQDESCR: TIBStringField;
    T_PICTQDTE: TDateField;
    T_PICTQNOTE: TIBStringField;
    T_PICTQPICT: TBlobField;
    T_PICTQPICTFORMAT: TIBStringField;
    T_PICTQPICTGRP: TIntegerField;
    T_PICTQPICTGRPDESCR: TIBStringField;
    T_PICTQPICTID: TIntegerField;
    T_PICTQPICTNO: TIntegerField;
    T_PICTQPICTSIZE: TIBBCDField;
    Panel4: TPanel;
    PICTBox: TImage;
    ScrollBox1: TScrollBox;
    SpeedButton2: TSpeedButton;
    Splitter2: TSplitter;
    ToolBar1: TToolBar;
    InsertBtn: TToolButton;
    EditBtn: TToolButton;
    DeleteBtn: TToolButton;
    ToolButton1: TToolButton;
    PrintBtn: TToolButton;
    DBNavigator1: TDBNavigator;
    Panel1: TPanel;
    DBGrid1: TDBGrid;
    ToolButton2: TToolButton;
    DataSource1: TDataSource;
    HelpBtn: TToolButton;
    OpenPictureDialog1: TOpenPictureDialog;
    ExportBtn: TToolButton;
    SavePictureDialog1: TSavePictureDialog;
    Panel3: TPanel;
    Label5: TLabel;
    StretchCheck: TCheckBox;
    DATEBox: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    SortBox: TComboBox;
    GroupBox: TComboBox;
    FormatBox: TComboBox;
    SearchBox: TLabeledEdit;
    PictIdBox: TComboBox;
    SpeedButton1: TSpeedButton;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure HelpBtnClick(Sender: TObject);
    procedure InsertBtnClick(Sender: TObject);
    procedure EditBtnClick(Sender: TObject);
    procedure DeleteBtnClick(Sender: TObject);
    procedure PrintBtnClick(Sender: TObject);
    procedure SortBoxChange(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
    procedure DataSource1DataChange(Sender: TObject; Field: TField);
    procedure StretchCheckClick(Sender: TObject);
    procedure ExportBtnClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    Graphic: TGraphic;
    Stream: TMemoryStream;
    PICTIDVal: integer;
    PICTNOVal: integer;
    PICTGRPVal: integer;
    PICTFORMATVal: string;
    PICTSIZEVal: double;
    DESCRVal: string;
    NOTEVal: string;
    DTEVal: TDate;
    OLDPICTIDVal: integer;
    OLDPICTNOVal: integer;
    procedure InsUpdDelT_PICT(CaptureState: TCaptureState);
    procedure ShowCapT_PICT(CaptureState: TCaptureState);
  public
    procedure OpenT_PICTQ(Order: string);
  end;

var
  t_pictf: Tt_pictf;

implementation

uses _dm, _mainf, _capt_pictf, _lookupf, _viewpictf;

{$R *.lfm}

procedure Tt_pictf.FormShow(Sender: TObject);
begin
  try
    Screen.Cursor := crHourglass;

    SortBox.Items.CommaText := 'Image-id, Date, Group, Format, Size, Description';
    SortBox.Text := 'Image-id';

    DATEBox.Items.Add('*ALL*');
    dm.OpenQ('SELECT DISTINCT DTE FROM T_PICT ORDER BY DTE');
    while not dm.XQ.EOF do
    begin
      DATEBox.Items.Add(dm.XQ.FieldByName('DTE').AsString);
      dm.XQ.Next;
    end;
    dm.XQ.Close;
    DATEBox.Text := '*ALL*';

    PictIdBox.Items.Add('*ALL*');
    dm.OpenQ('SELECT DISTINCT PICTID FROM T_PICT ORDER BY PICTID');
    while not dm.XQ.EOF do
    begin
      PictIdBox.Items.Add(dm.XQ.FieldByName('PICTID').AsString);
      dm.XQ.Next;
    end;
    dm.XQ.Close;
    if PictIdBox.Text = '' then
      PictIdBox.Text := '*ALL*';

    GroupBox.Items.CommaText := dm.GetLookupItems(1, 'PICT_GROUP', 'DESCR');
    if GroupBox.Text = '' then
      GroupBox.Text := '*ALL*';

    FormatBox.Items.CommaText := '*ALL*, JPG, BMP, ICO';
    FormatBox.Text := '*ALL*';

    OpenT_PICTQ('PICTID,PICTNO');
    T_PICTQ.Locate('PICTID', cnf.DefPictId, []);
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure Tt_pictf.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  cnf.DefPictId := T_PICTQPICTID.AsInteger;
  T_PICTQ.Close;
  dm.IBTransaction1.CommitRetaining;
end;

procedure Tt_pictf.HelpBtnClick(Sender: TObject);
begin
  mainf.ShowPDFHelp(10);
end;

procedure Tt_pictf.OpenT_PICTQ(Order: string);
begin
  T_PICTQ.Close;
  T_PICTQ.SQL.Clear;
  T_PICTQ.SQL.Add('SELECT * FROM V_PICT WHERE PICTID IS NOT NULL');
  if DATEBox.Text <> '*ALL*' then
    T_PICTQ.SQL.Add('AND DTE = :DTE');
  if PictIdBox.Text <> '*ALL*' then
    T_PICTQ.SQL.Add('AND PICTID = :PICTID');
  if GroupBox.Text <> '*ALL*' then
    T_PICTQ.SQL.Add('AND PICTGRPDESCR = :PICTGRPDESCR');
  if FormatBox.Text <> '*ALL*' then
    T_PICTQ.SQL.Add('AND PICTFORMAT = :PICTFORMAT');
  if SearchBox.Text <> '' then
    T_PICTQ.SQL.Add('AND DESCR CONTAINING :DESCR');
  T_PICTQ.SQL.Add('ORDER BY ' + Order);

  if DATEBox.Text <> '*ALL*' then
    T_PICTQ.ParamByName('DTE').AsDate := StrToDate(DATEBox.Text);
  if PictIdBox.Text <> '*ALL*' then
    T_PICTQ.ParamByName('PICTID').AsInteger := StrToInt(PictIdBox.Text);
  if GroupBox.Text <> '*ALL*' then
    T_PICTQ.ParamByName('PICTGRPDESCR').AsString := GroupBox.Text;
  if FormatBox.Text <> '*ALL*' then
    T_PICTQ.ParamByName('PICTFORMAT').AsString := FormatBox.Text;
  if SearchBox.Text <> '' then
    T_PICTQ.ParamByName('DESCR').AsString := SearchBox.Text;

  T_PICTQ.Prepare;
  T_PICTQ.Open;
end;

procedure Tt_pictf.SortBoxChange(Sender: TObject);
var
  S: string;
begin
  try
    Screen.Cursor := crHourglass;
    if SortBox.Text = 'Group' then
      S := 'PICTGRPDESCR, PICTID, PICTNO'
    else if SortBox.Text = 'Date' then
      S := 'DTE, PICTID, PICTNO'
    else if SortBox.Text = 'Format' then
      S := 'PICTFORMAT, PICTID, PICTNO'
    else if SortBox.Text = 'Size' then
      S := 'PICTSIZE'
    else if SortBox.Text = 'Description' then
      S := 'DESCR'
    else
      S := 'PICTID, PICTNO';
    OpenT_PICTQ(S);
    T_PICTQ.Locate('PICTID;PICTNO', VarArrayOf([PICTIDVal, PICTNOVal]), []);
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure Tt_pictf.SpeedButton2Click(Sender: TObject);
begin
  LOOKUPF := TLOOKUPF.Create(Application);
  try
    LOOKUPF.DefGRP := 'PICT_GROUP';
    LOOKUPF.GRPBox.Enabled := False;
    LOOKUPF.ShowModal;
  finally
    FreeAndNil(LOOKUPF);
  end;
  GroupBox.Items.CommaText := dm.GetLookupItems(1, 'PICT_GROUP', 'DESCR');
end;

procedure Tt_pictf.SpeedButton1Click(Sender: TObject);
begin
  SearchBox.Text := '';
end;

procedure Tt_pictf.InsUpdDelT_PICT(CaptureState: TCaptureState);
var
  Q: TIBQuery;
begin
  Q := TIBQuery.Create(nil);
  try
    Q.DataBase := dm.IBDatabase1;
    Q.Transaction := dm.IBTransaction1;
    if CaptureState = csInsert then
    begin
      Q.SQL.Add('INSERT INTO T_PICT(PICTID,PICTNO,PICTGRP,PICTFORMAT,PICTSIZE,DESCR,NOTE,PICT,DTE)');
      Q.SQL.Add('VALUES(:PICTID,:PICTNO,:PICTGRP,:PICTFORMAT,:PICTSIZE,:DESCR,:NOTE,:PICT,:DTE)');
    end
    else if CaptureState = csEdit then
    begin
      Q.SQL.Add('UPDATE T_PICT SET PICTID = :PICTID,PICTNO = :PICTNO,PICTGRP = :PICTGRP,PICTFORMAT = :PICTFORMAT,');
      Q.SQL.Add('PICTSIZE = :PICTSIZE,DESCR = :DESCR,NOTE = :NOTE,');
      if PICTFORMATVal = '' then
        Q.SQL.Add('PICT = NULL,')
      else
        Q.SQL.Add('PICT = :PICT,');
      Q.SQL.Add('DTE = :DTE WHERE PICTID = :OLDPICTID AND PICTNO = :OLDPICTNO');
      Q.ParamByName('OLDPICTID').AsInteger := OLDPICTIDVal;
      Q.ParamByName('OLDPICTNO').AsInteger := OLDPICTNOVal;
    end
    else if CaptureState = csDelete then
      Q.SQL.Add('DELETE FROM T_PICT WHERE PICTID = :PICTID AND PICTNO = :PICTNO');
    Q.ParamByName('PICTID').AsInteger := PICTIDVal;
    Q.ParamByName('PICTNO').AsInteger := PICTNOVal;
    if CaptureState in [csInsert, csEdit] then
    begin
      Q.ParamByName('PICTGRP').AsInteger := PICTGRPVal;
      Q.ParamByName('PICTFORMAT').AsString := PICTFORMATVal;
      Q.ParamByName('PICTSIZE').AsFloat := PICTSIZEVal;
      Q.ParamByName('DESCR').AsString := DESCRVal;
      Q.ParamByName('NOTE').AsString := NOTEVal;
      Q.ParamByName('DTE').AsDate := DTEVal;
      if PICTFORMATVal <> '' then
      begin
        Stream := TMemoryStream.Create;
        try
          Graphic.SaveToStream(Stream);
          Stream.Position := 0;
          Q.ParamByName('PICTSIZE').AsFloat := Stream.Size div 1024;
          Q.ParamByName('PICT').LoadFromStream(Stream, ftBlob);
        finally
          Stream.Free;
        end;
      end;
    end;
    Q.Prepare;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure Tt_pictf.ShowCapT_PICT(CaptureState: TCaptureState);

  procedure AssignT_PICTValues;
  begin
    PICTIDVal := StrToInt(cap_t_pictf.PICTIDBox.Text);
    PICTNOVal := StrToInt(cap_t_pictf.PICTNOBox.Text);
    PICTGRPVal := dm.GetT_LOOKUPID('PICT_GROUP', cap_t_pictf.PICTGRPBox.Text);
    PICTFORMATVal := cap_t_pictf.PICTFORMATBox.Text;
    PICTSIZEVal := StrToFloat(cap_t_pictf.PICTSIZEBox.Text);
    DESCRVal := cap_t_pictf.DESCRBox.Text;
    NOTEVal := cap_t_pictf.NOTEBox.Text;
    DTEVal := cap_t_pictf.DTEBox.Date;

    Graphic := cap_t_pictf.PictBox.Picture.Graphic;
    if (Graphic = nil) or (Graphic.Empty) then
      PICTFORMATVal := ''
    else
    begin
      if Graphic is TBitMap then
        PICTFORMATVal := 'BMP';
      if Graphic is TIcon then
        PICTFORMATVal := 'ICO';
      if Graphic is TJPEGImage then
        PICTFORMATVal := 'JPG';
    end;
  end;

begin
  cap_t_pictf := Tcap_t_pictf.Create(Application);
  try
    if CaptureState = csInsert then
    begin
      cap_t_pictf.Caption := 'Insert';
      cap_t_pictf.OkBtn.Caption := '&Insert';
    end
    else if CaptureState = csEdit then
    begin
      cap_t_pictf.Caption := 'Edit';
      cap_t_pictf.OkBtn.Caption := '&Update';
      OLDPICTIDVal := T_PICTQPICTID.Value;
      OLDPICTNOVal := T_PICTQPICTNO.Value;
    end;
    cap_t_pictf.FillForm(CaptureState);
    if cap_t_pictf.ShowModal = mrOk then
    begin
      AssignT_PICTValues;
      InsUpdDelT_PICT(CaptureState);
      SortBoxChange(t_pictf);
    end;
  finally
    FreeAndNil(cap_t_pictf);
  end;
end;

procedure Tt_pictf.InsertBtnClick(Sender: TObject);
begin
  ShowCapT_PICT(csInsert);
end;

procedure Tt_pictf.EditBtnClick(Sender: TObject);
begin
  if not T_PICTQ.IsEmpty then
    ShowCapT_PICT(csEdit);
end;

procedure Tt_pictf.DeleteBtnClick(Sender: TObject);
begin
  if MessageDlg('Delete record?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    PICTIDVal := T_PICTQPICTID.Value;
    PICTNOVal := T_PICTQPICTNO.Value;
    InsUpdDelT_PICT(csDelete);
    SortBoxChange(Sender);
  end;
end;

procedure Tt_pictf.PrintBtnClick(Sender: TObject);
begin
  if mainf.PrintDialog1.Execute then
    try
      Screen.Cursor := crHourglass;
      Printer.BeginDoc;
      Printer.Canvas.StretchDraw(Rect(0, 0, PICTBox.Picture.Width, PICTBox.Picture.Height),
        PICTBox.Picture.Graphic);
      Printer.EndDoc;
    finally
      Screen.Cursor := crDefault;
    end;
end;

procedure Tt_pictf.ToolButton2Click(Sender: TObject);
begin
  ViewPictF := TViewPictF.Create(Application);
  try
    ViewPictF.WindowState := wsNormal;
    ViewPictF.HorzScrollBar.Range := PICTBox.Picture.Width;
    ViewPictF.VertScrollBar.Range := PICTBox.Picture.Height;
    if (ViewPictF.HorzScrollBar.Range >= (Screen.Width - 10)) or
      (ViewPictF.VertScrollBar.Range >= (Screen.Height - 10)) then
      ViewPictF.WindowState := wsMaximized
    else
    begin
      ViewPictF.Width := ViewPictF.HorzScrollBar.Range + 15;
      ViewPictF.Height := ViewPictF.VertScrollBar.Range + 35;
      ViewPictF.WindowState := wsNormal;
      ViewPictF.Position := poScreenCenter;
    end;
    ViewPictF.Caption := Caption;
    ViewPictF.Image1.Picture := PICTBox.Picture;
    ViewPictF.ShowModal;
  finally
    FreeAndNil(ViewPictF);
  end;
end;

procedure Tt_pictf.DataSource1DataChange(Sender: TObject; Field: TField);
begin
  Graphic := nil;
  PICTFORMATVal := UpperCase(TrimRight(Trim(T_PICTQPICTFORMAT.AsString)));
  if PICTFORMATVal = '' then
  begin
    PICTBox.Picture.Assign(nil);
    Exit;
  end;
  if PICTFORMATVal = 'BMP' then
    Graphic := TBitMap.Create;
  if PICTFORMATVal = 'ICO' then
    Graphic := TIcon.Create;
  if (PICTFORMATVal = 'JPG') or (PICTFORMATVal = 'JPEG') then
    Graphic := TJPEGImage.Create;
  if Graphic <> nil then
  begin
    //  Grootte := Ceil(dm.T_PICTQPICT.BlobSize/1024);
    Stream := TMemoryStream.Create;
    try
      T_PICTQPICT.SaveToStream(Stream);
      Stream.Position := 0;
      Graphic.LoadFromStream(Stream);
      PICTBox.Picture.Graphic := Graphic;
    finally
      Stream.Free;
    end;
  end;
end;

procedure Tt_pictf.StretchCheckClick(Sender: TObject);
begin
  if (T_PICTQPICTFORMAT.Value = 'ICO') and StretchCheck.Checked then
  begin
    MessageDlg('The picture is an icon. It cannot be resized/stretched',
      mtWarning, [mbOK], 0);
    PICTBox.AutoSize := True;
    PICTBox.Stretch := False;
  end
  else
  begin
    if StretchCheck.Checked then
    begin
      PICTBox.AutoSize := False;
      PICTBox.Stretch := True;
    end
    else
    begin
      PICTBox.AutoSize := True;
      PICTBox.Stretch := False;
    end;
    DataSource1DataChange(t_pictf, T_PICTQPICT);
  end;
end;

procedure Tt_pictf.ExportBtnClick(Sender: TObject);
begin
  if SavePictureDialog1.Execute then
  begin
    SavePictureDialog1.DefaultExt := GraphicExtension(TJPEGImage);
    PICTBox.Picture.SaveToFile(SavePictureDialog1.FileName);
  end;
end;

end.
