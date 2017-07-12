program eprof;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, _mainf, _global, _dm, _loginf, _aboutf, _lookupf, _CapT_LOOKUPF,
  _print, _misc, _capt_pictf, _T_PICTF, _viewpictf, _SnapshotF, _RestoreF,
  _password, _printerinfof, _emailsetupf, _emaillogf, _initlookupsf,
  _usermanagerf, _capusermanager, _serverpropsf, _t_helpf, printer4lazarus,
  datetimectrls, _t_paramvaluesf, _capt_paramvaluesf, _zipfilef, _unzipfilef,
  _draw, _date, ibexpress, _t_loadf, _t_panelsf, _t_subsf, _CapT_SUBSF,
_capt_panelsf, _t_tmploadf, _t_tmpsubf
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(Tmainf, mainf);
  Application.CreateForm(Tdm, dm);
  Application.Run;
end.

