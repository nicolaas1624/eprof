unit _capusermanager;

interface

uses
  LCLIntf, Classes, Forms, Dialogs, StdCtrls, Buttons, ExtCtrls, maskedit;

type
  Tcapusermanager = class(TForm)
    Panel1: TPanel;
    OkBtn: TBitBtn;
    CancelBtn: TBitBtn;
    Panel2: TPanel;
    GroupBox1: TGroupBox;
    FirstNameBox: TLabeledEdit;
    MiddleNameBox: TLabeledEdit;
    LastNameBox: TLabeledEdit;
    GroupBox2: TGroupBox;
    UsernameBox: TLabeledEdit;
    PasswordBox: TMaskEdit;
    Label1: TLabel;
    ConfirmPasswordBox: TMaskEdit;
    Label2: TLabel;
    RoleBox: TComboBox;
    Label3: TLabel;
    procedure ConfirmPasswordBoxExit(Sender: TObject);
    procedure OkBtnClick(Sender: TObject);
  private
  public
  end;

var
  capusermanager: Tcapusermanager;

implementation

{$R *.lfm}

procedure Tcapusermanager.ConfirmPasswordBoxExit(Sender: TObject);
begin
  if PasswordBox.Text <> ConfirmPasswordBox.Text then
  begin
    MessageDlg('Passwords do not match, re-enter pasword.', mtInformation, [mbOK], 0);
    PasswordBox.SetFocus;
  end;
end;

procedure Tcapusermanager.OkBtnClick(Sender: TObject);
begin
  ConfirmPasswordBoxExit(Sender);
end;

end.
