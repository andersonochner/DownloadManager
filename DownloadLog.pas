unit DownloadLog;

interface

uses
  Generics.Collections;

type
  TDownloadLog = class
  private
    fCodigo : Int64;
    fUrl : String;
    fDataInicio : TDateTime;
    fDataFim : TDateTime;

    function getCodigo : Int64;
    function getDataFim: TDateTime;
    function getDataInicio: TDateTime;
    function getUrl: String;
    procedure setDataFim(const Value: TDateTime);
    procedure setDataInicio(const Value: TDateTime);
    procedure setUrl(const Value: String);

  public
    property URL : String read getUrl write setUrl;
    property DataInicio : TDateTime read getDataInicio write setDataInicio;
    property DataFim : TDateTime read getDataFim write setDataFim;
    property Codigo : Int64 read getCodigo;

  end;

implementation

{ TDownloadLog }

function TDownloadLog.getCodigo: Int64;
begin
  result := fCodigo;
end;

function TDownloadLog.getDataFim: TDateTime;
begin
  result := fDataFim;
end;

function TDownloadLog.getDataInicio: TDateTime;
begin
  result := fDataInicio;
end;

function TDownloadLog.getUrl: String;
begin
  result := fURL;
end;

procedure TDownloadLog.setDataFim(const Value: TDateTime);
begin
  if   Value > DataInicio then
       fDataFim := Value;
end;

procedure TDownloadLog.setDataInicio(const Value: TDateTime);
begin
  fDataInicio := Value;
end;

procedure TDownloadLog.setUrl(const Value: String);
begin
  fURL := Value;
end;

end.
