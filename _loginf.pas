unit _loginf;

{$mode objfpc}{$H+}

interface

uses
  LCLIntf, SysUtils, Classes, Forms, Dialogs, StdCtrls, ExtCtrls, Buttons,
  Controls, EditBtn;

type

  { Tloginf }

  Tloginf = class(TForm)
    CancelB: TBitBtn;
    DBNameBox: TFileNameEdit;
    Label5: TLabel;
    OKB: TBitBtn;
    Panel2: TPanel;
    RoleBox: TComboBox;
    UsernameBox: TLabeledEdit;
    PasswordBox: TLabeledEdit;
    Panel1: TPanel;
    LoginGroupBox: TGroupBox;
    Label3: TLabel;
    ServerBox: TComboBox;
    Label4: TLabel;
    procedure DBNameBoxButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PasswordBoxKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
  public
  end;

var
  loginf: Tloginf;

implementation

uses _global, _mainf;

{$R *.lfm}

procedure Tloginf.FormShow(Sender: TObject);
begin
  ServerBox.Text := cnf.ServerName;
  DBNameBox.Text := cnf.DBFileName;
  RoleBox.Text := cnf.Role;
  PasswordBox.SetFocus;
end;

procedure Tloginf.DBNameBoxButtonClick(Sender: TObject);
begin
  mainf.OpenDialog1.Filter := 'Database files (*.fdb)|*.fdb';
  mainf.OpenDialog1.InitialDir := cnf.DBFileName;
  if mainf.OpenDialog1.Execute then
    DBNameBox.Text := LowerCase(mainf.OpenDialog1.FileName);
end;

procedure Tloginf.PasswordBoxKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 13 then
    ModalResult := mrOK;
end;

end.
