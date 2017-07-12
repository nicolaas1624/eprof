unit _capt_pictf;

{$mode objfpc}{$H+}

interface

uses
  LCLType, SysUtils, Graphics, Controls, Forms, Dialogs, StdCtrls, Buttons,
  ComCtrls, ExtCtrls, _Global, DateTimePicker, Classes;

type

  { Tcap_t_pictf }

  Tcap_t_pictf = class(TForm)
    Panel1: TPanel;
    OkBtn: TBitBtn;
    CancelBtn: TBitBtn;
    Panel2: TPanel;
    Picture: TGroupBox;
    PICTBox: TImage;
    GroupBox4: TGroupBox;
    NOTEBox: TMemo;
    GroupBox1: TGroupBox;
    ToolBar2: TToolBar;
    LoadBtn: TToolButton;
    DeleteBtn: TToolButton;
    FullViewBtn: TToolButton;
    PICTIDBox: TLabeledEdit;
    PICTNOBox: TLabeledEdit;
    PICTGRPBox: TComboBox;
    Label1: TLabel;
    DESCRBox: TLabeledEdit;
    DTEBox: TDateTimePicker;
    Label2: TLabel;
    Panel3: TPanel;
    StretchCheck: TCheckBox;
    PICTFORMATBox: TLabeledEdit;
    PICTSIZEBox: TLabeledEdit;
    procedure LoadPhotoBtnClick(Sender: TObject);
    procedure ClearPhotoBtnClick(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
    procedure StretchCheckClick(Sender: TObject);
  private
  public
    FName: TFileName;
    procedure FillForm(CaptureState: TCaptureState);
  end;

var
  cap_t_pictf: Tcap_t_pictf;

implementation

{$R *.lfm}

uses _viewpictf, _t_pictf;

procedure Tcap_t_pictf.FillForm(CaptureState: TCaptureState);
begin
  PICTGRPBox.Items := t_pictf.GroupBox.Items;
  PICTGRPBox.Items.Delete(0);
  StretchCheck.Checked := t_pictf.StretchCheck.Checked;

  if CaptureState = csInsert then
  begin
    if t_pictf.PictIdBox.Text <> '*ALL*' then
      PICTIDBox.Text := t_pictf.PictIdBox.Text;
    PICTNOBox.Text := '1';
    DTEBox.Date := Date;
    if t_pictf.GroupBox.Text <> '*ALL*' then
      PICTGRPBox.Text := t_pictf.GroupBox.Text
    else
      PICTGRPBox.Text := t_pictf.GroupBox.Items[1];
    PICTSIZEBox.Text := '0';
  end
  else if CaptureState = csEdit then
  begin
    PICTIDBox.Text := t_pictf.T_PICTQPICTID.AsString;
    PICTNOBox.Text := t_pictf.T_PICTQPICTNO.AsString;
    DTEBox.Date := t_pictf.T_PICTQDTE.AsDateTime;
    PICTGRPBox.Text := t_pictf.T_PICTQPICTGRPDESCR.AsString;
    PICTFORMATBox.Text := t_pictf.T_PICTQPICTFORMAT.AsString;
    PICTSIZEBox.Text := t_pictf.T_PICTQPICTSIZE.AsString;
    DESCRBox.Text := t_pictf.T_PICTQDESCR.AsString;
    NOTEBox.Text := t_pictf.T_PICTQNOTE.AsString;
    if t_pictf.T_PICTQPICT.AsString <> '' then
      PICTBox.Picture := t_pictf.PICTBox.Picture;
  end;
end;

procedure Tcap_t_pictf.LoadPhotoBtnClick(Sender: TObject);
begin
  if t_pictf.OpenPictureDialog1.Execute then
  begin
    FName := t_pictf.OpenPictureDialog1.FileName;
    if FName <> '' then
    try
      StretchCheckClick(Sender);
      PICTBox.Picture.LoadFromFile(FName);
    except
    on EInvalidGraphic do
      PICTBox.Picture.Graphic := nil;
    end;
  end;
end;

procedure Tcap_t_pictf.ClearPhotoBtnClick(Sender: TObject);
begin
  if MessageDlg('Clear current picture?',mtConfirmation,[mbYes,mbNo],0) = mrYes then
    PictBox.Picture.Graphic := nil;
end;

procedure Tcap_t_pictf.ToolButton1Click(Sender: TObject);
begin
  ViewPictF := TViewPictF.Create(Application);
  try
    ViewPictF.WindowState := wsNormal;
    ViewPictF.HorzScrollBar.Range := PICTBox.Picture.Width;
    ViewPictF.VertScrollBar.Range := PICTBox.Picture.Height;
    if (ViewPictF.HorzScrollBar.Range >= (Screen.Width-10)) or (ViewPictF.VertScrollBar.Range >= (Screen.Height-10)) then
       ViewPictF.WindowState := wsMaximized
    else
    begin
      ViewPictF.Width := ViewPictF.HorzScrollBar.Range + 10;
      ViewPictF.Height := ViewPictF.VertScrollBar.Range + 30;
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

procedure Tcap_t_pictf.StretchCheckClick(Sender: TObject);
begin
  if (PICTBox.Picture.Graphic is TIcon) and StretchCheck.Checked then
  begin
    MessageDlg('The picture is an icon. It cannot be resized/stretched',mtWarning,[mbOK],0);
    PICTBox.AutoSize := True;
    PICTBox.Stretch := False;
  end
  else
  begin
    if StretchCheck.Checked then
    begin
      PICTBox.AutoSize := False;
      PICTBox.Stretch := True
    end
    else
    begin
      PICTBox.AutoSize := True;
      PICTBox.Stretch := False;
    end;
  end;
end;

end.


