unit _zipfilef;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, Buttons, StdCtrls, EditBtn, ButtonPanel, Arrow, Calendar, FileCtrl;

type

  { Tzipfilef }

  Tzipfilef = class(TForm)
    CancelBtn: TBitBtn;
    InputFilenameBox: TFileNameEdit;
    OutputFilenameBox: TFileNameEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    OkBtn: TBitBtn;
    Panel1: TPanel;
    Panel2: TPanel;
    procedure InputFilenameBoxChange(Sender: TObject);
    procedure OkBtnClick(Sender: TObject);
  private
  public
  end;

var
  zipfilef: Tzipfilef;

implementation

uses zipper;

{$R *.lfm}

{ Tzipfilef }

procedure Tzipfilef.InputFilenameBoxChange(Sender: TObject);
begin
  OutputFilenameBox.Text := ChangeFileExt(InputFilenameBox.Text, '.zip');
end;

procedure Tzipfilef.OkBtnClick(Sender: TObject);
var
  OurZipper: TZipper;
begin
  OurZipper := TZipper.Create;
  try
    Screen.Cursor := crHourglass;
    OurZipper.FileName := OutputFilenameBox.Text;
    OurZipper.Entries.AddFileEntry(ExtractFileName(InputFilenameBox.Text));
    OurZipper.ZipAllFiles;
  finally
    OurZipper.Free;
    Screen.Cursor := crDefault;
  end;
end;

end.

