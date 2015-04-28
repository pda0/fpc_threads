(******************************************************************************
  ThreadsPlus - Threads exetender for Free Pascal 2.6.4+

  Written in 2015 by Dmitriy Pomerantsev pda2@yandex.ru

  To the extent possible under law, the author(s) have dedicated all copyright
  and related and neighboring rights to this software to the public domain
  worldwide. This software is distributed without any warranty.

  You should have received a copy of the CC0 Public Domain Dedication along
  with this software.
  If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
 ******************************************************************************)
unit ThreadsPlus;

interface

uses
{$IF FPC_FULlVERSION < 20701}
  {$IF DEFINED(WINDOWS)}
  Windows,
  {$ELSEIF DEFINED(UNIX)}
  ctypes,
  {$IF DEFINED(FREEBSD) OR DEFINED(DARWIN)}sysctl,{$IFEND}
  {$IFEND}
{$ENDIF}
  Classes, SysUtils;

{$IF FPC_FULlVERSION < 20701}
type
  TThread = class(Classes.TThread)
  private
    class var FProcessorCount: LongWord;
    class function GetIsSingleProcessor: Boolean; static; inline;
  public
    class property ProcessorCount: LongWord read FProcessorCount;
    class property IsSingleProcessor: Boolean read GetIsSingleProcessor;
  end;
{$ENDIF}

implementation

{$IF FPC_FULlVERSION < 20701}
{ TThread }
class function TThread.GetIsSingleProcessor: Boolean;
begin
  Result := TThread.FProcessorCount < 2;
end;

{$PUSH}
{$WARN SYMBOL_PLATFORM OFF}

{$IF DEFINED(LINUX)}
const
  _SC_NPROCESSORS_ONLN = 83;

function sysconf(i: cint): clong; cdecl; external 'c' name 'sysconf';
{$IFEND}

function GetCPUCount: LongWord;
{$IF DEFINED(WINDOWS)}
var
  SysInfo: TSystemInfo;
begin
  {$PUSH}
  {$HINTS OFF}
  FillChar(SysInfo, SizeOf(SysInfo), 0);
  {$POP}
  GetSystemInfo(@SysInfo);
  Result := SysInfo.dwNumberOfProcessors;
{$ELSEIF DEFINED(LINUX)}
begin
  Result := sysconf(_SC_NPROCESSORS_ONLN);
{$ELSEIF DEFINED(FREEBSD) OR DEFINED(DARWIN)}
var
  mib: array[0..1] of cint;
  len: cint;
  t: cint;
begin
  mib[0] := CTL_HW;
  mib[1] := HW_NCPU;
  len := SizeOf(t);
  fpsysctl(PChar(@mib), 2, @t, @len, nil, 0);
  Result := t;
{$ELSE}
  Result := 1;
{$IFEND}
end;
{$POP}
{$ENDIF}

initialization
  TThread.FProcessorCount := GetCPUCount;

end.