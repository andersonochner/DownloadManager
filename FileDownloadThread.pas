unit FileDownloadThread;

interface

uses
  System.Classes, ObserverInterface, ShellApi, UrlMon, System.Types, Windows,
  ActiveX, System.SyncObjs;

type

  TFileDownloadThread = class(TThread, IBindStatusCallback,IInterface)
  private
    fDownloadCanceled : Boolean;
    fDownloadLink,
    fDirectory : String;
    fCriticalSectionCancellDownload : TCriticalSection;

  protected
    fObserverList : TInterfaceList;
    function QueryInterface(const IID: TGUID; out Obj): Integer; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;

    // IBindStatusCallback
    function OnStartBinding(dwReserved: DWORD; pib: IBinding): HResult; stdcall;
    function GetPriority(out nPriority): HResult; stdcall;
    function OnLowResource(reserved: DWORD): HResult; stdcall;
    function OnProgress(ulProgress, ulProgressMax, ulStatusCode: ULONG;
      szStatusText: LPCWSTR): HResult; stdcall;
    function OnStopBinding(hresult: HResult; szError: LPCWSTR): HResult; stdcall;
    function GetBindInfo(out grfBINDF: DWORD; var bindinfo: TBindInfo): HResult; stdcall;
    function OnDataAvailable(grfBSCF: DWORD; dwSize: DWORD; formatetc: PFormatEtc;
      stgmed: PStgMedium): HResult; stdcall;
    function OnObjectAvailable(const iid: TGUID; punk: IUnknown): HResult; stdcall;


    function CheckDownloadCancelled : Boolean;
    function GetDownloadedFilePath : String;
    function GetRemoteFileName : String;
    procedure RenameFileWithResponseHeader(ResponseHeader : PWideChar);
    procedure Execute; override;
    procedure NotifyObservers(Progress : Integer);
  public
    constructor Create(const Directory, DownloadLink : String);
    destructor Destroy; override;

    procedure CancelDownload; virtual;

    procedure AddObserver(observer : IObserver);
    procedure RemoveObserver(observer : IObserver);
  end;

implementation

uses
  IdGlobal, Math, System.SysUtils, IdURI, IdHttp, IdSSLOpenSSL;

const
  CNT_TEMPFILENAME = 'download.tmp';

{ TFileDownloadThread }

procedure TFileDownloadThread.CancelDownload;
begin
  fCriticalSectionCancellDownload.Acquire;
  try
    fDownloadCanceled := true;
  finally
    fCriticalSectionCancellDownload.Release;
  end;
end;

function TFileDownloadThread.CheckDownloadCancelled: Boolean;
begin
  try
    fCriticalSectionCancellDownload.Acquire;
    result := fDownloadCanceled;
  finally
    fCriticalSectionCancellDownload.Release;
  end;
end;

constructor TFileDownloadThread.Create(const Directory, DownloadLink : String);
begin
  inherited Create(True);
//  FreeOnTerminate := true;
  fCriticalSectionCancellDownload := TCriticalSection.Create;


  fDirectory := Directory;
  fDownloadLink := DownloadLink;

  fDownloadCanceled := false;
  fObserverList := nil;

end;

destructor TFileDownloadThread.Destroy;
begin
  fCriticalSectionCancellDownload.Free;

  inherited;
end;

procedure TFileDownloadThread.Execute;
begin
  inherited;

  URLDownloadToFile(nil, PWideChar(fDownloadLink), pWideChar(GetDownloadedFilePath), 0, Self);
end;

function TFileDownloadThread.GetBindInfo(out grfBINDF: DWORD;
  var bindinfo: TBindInfo): HResult;
begin
  Result := E_NOTIMPL;
end;

function TFileDownloadThread.GetDownloadedFilePath: String;
begin
  result := IncludeTrailingPathDelimiter(fDirectory)+GetRemoteFileName;
end;

function TFileDownloadThread.GetPriority(out nPriority): HResult;
begin
  Result := E_NOTIMPL;
end;

function TFileDownloadThread.GetRemoteFileName: String;
var
  loStrings : TStringList;
begin
//Retorna o texto depois da ultima barra
  loStrings := TStringList.Create;
  try
    loStrings.Delimiter := '/';
    loStrings.StrictDelimiter := true;
    loStrings.DelimitedText := fDownloadLink;
    if   loStrings.Count > 0 then
         result := loStrings[loStrings.Count -1];
  finally
    loStrings.Free;
  end;
end;

procedure TFileDownloadThread.NotifyObservers(Progress: Integer);
var
  observer : IInterface;
begin
  for observer in fObserverList do
      with observer as ObserverInterface.IObserver do
           UpdateProgress(Progress);
end;

function TFileDownloadThread.OnDataAvailable(grfBSCF: DWORD; dwSize: DWORD; formatetc: PFormatEtc;
      stgmed: PStgMedium): HResult;
begin
  Result := E_NOTIMPL;
end;

function TFileDownloadThread.OnLowResource(reserved: DWORD): HResult;
begin
  Result := E_NOTIMPL;
end;

function TFileDownloadThread.OnObjectAvailable(const iid: TGUID; punk: IUnknown): HResult;
begin
  Result := E_NOTIMPL;
end;

function TFileDownloadThread.OnStartBinding(dwReserved: DWORD;
  pib: IBinding): HResult;
begin
  Result := E_NOTIMPL;
end;

function TFileDownloadThread.OnStopBinding(hresult: HResult;
  szError: LPCWSTR): HResult;
begin
  Result := E_NOTIMPL;
end;

function TFileDownloadThread.OnProgress(ulProgress, ulProgressMax,
  ulStatusCode: ULONG; szStatusText: LPCWSTR): HResult;
begin
  if   CheckDownloadCancelled then
       result := E_ABORT
  else
       result := S_OK;

  if   ulProgressMax > 0 then
       begin
         NotifyObservers(Max(1, Trunc(ulProgress / ulProgressMax * 100)));
       end;
end;

function TFileDownloadThread.QueryInterface(const IID: TGUID; out Obj): Integer;
begin
  if GetInterface(IID, Obj) then
     Result := S_OK
  else
     Result := E_NOINTERFACE;
end;

procedure TFileDownloadThread.RemoveObserver(observer: IObserver);
begin
  if   not Assigned(fObserverList) then
       fObserverList := TInterfaceList.Create;
  fObserverList.Remove(observer);
end;

procedure TFileDownloadThread.RenameFileWithResponseHeader(
  ResponseHeader: PWideChar);
var
  NewFileName : String;
begin
  RenameFile(GetDownloadedFilePath, NewFileName);
end;

function TFileDownloadThread._AddRef: Integer;
begin
  result := -1;
end;

function TFileDownloadThread._Release: Integer;
begin
  result := -1;
end;

procedure TFileDownloadThread.AddObserver(observer: IObserver);
begin
  if   not Assigned(fObserverList) then
       fObserverList := TInterfaceList.Create;

  if  (fObserverList.IndexOf(observer) = -1) then
       fObserverList.Add(observer);
end;

end.
