unit DownloadLogDAO;

interface

uses
  DownloadLog,
  Generics.Collections;

type
  IDownloadLogDAO = interface
    procedure AddNewDownload(downloadLog : TDownloadLog);
    procedure UpdateDownloadEndDate(downloadLog : TDownloadLog);
    function ListDownloads : TOBjectList<TDownloadLog>;
  end;

implementation

end.
