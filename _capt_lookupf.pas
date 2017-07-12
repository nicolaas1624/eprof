unit _capt_lookupf;

{$mode objfpc}{$H+}

interface

uses
  LCLType, SysUtils, Forms, StdCtrls, Buttons, ExtCtrls, _Global, _LOOKUPF;

type
  Tcapt_lookupf = class(TForm)
    Panel2: TPanel;
    GroupBox1: TGroupBox;
    Panel1: TPanel;
    OkBtn: TBitBtn;
    CancelBtn: TBitBtn;
    IDBox: TLabeledEdit;
    DESCRBox: TLabeledEdit;
  private
  public
    procedure FillForm(CapState: TCaptureState);
  end;

var
  capt_lookupf: Tcapt_lookupf;

implementation


{$R *.lfm}

procedure Tcapt_lookupf.FillForm(CapState: TCaptureState);
begin
  if CapState = csEdit then
  begin
    IDBox.Text := IntToStr(LOOKUPF.T_LOOKUPQID.AsInteger);
    DESCRBox.Text := LOOKUPF.T_LOOKUPQDESCR.AsString;
  end;
end;

end.
