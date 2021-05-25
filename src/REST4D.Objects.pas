unit REST4D.Objects;

interface

uses
  REST.Client,
  REST.Response.Adapter,
  REST4D.Interfaces;

type
  TREST4DObjects = Class(TInterfacedObject, IREST4DObjects)
  private
    FRESTClient        : TRESTClient;
    FRESTResponse      : TRESTResponse;
    FRESTRequest       : TRESTRequest;
    FRESTDatasetAdapter: TRESTResponseDataSetAdapter;

    procedure JoinObjects;
  public
    function Client: TRESTClient;
    function Request: TRESTRequest;
    function Response: TRESTResponse;
    function Adapter: TRESTResponseDataSetAdapter;

    class function New: IREST4DObjects;
    constructor Create;
    destructor Destroy; override;
  End;

implementation

{ TREST4DObjects }

function TREST4DObjects.Adapter: TRESTResponseDataSetAdapter;
begin
  Result := FRESTDatasetAdapter;
end;

function TREST4DObjects.Client: TRESTClient;
begin
  Result := FRESTClient;
end;

constructor TREST4DObjects.Create;
begin
  FRESTClient         := TRESTClient.Create(nil);
  FRESTResponse       := TRESTResponse.Create(nil);
  FRESTRequest        := TRESTRequest.Create(nil);
  FRESTDatasetAdapter := TRESTResponseDataSetAdapter.Create(nil);

  JoinObjects;
end;

destructor TREST4DObjects.Destroy;
begin
  FRESTClient.DisposeOf;
  FRESTResponse.DisposeOf;
  FRESTRequest.DisposeOf;
  FRESTDatasetAdapter.DisposeOf;

  inherited;
end;

procedure TREST4DObjects.JoinObjects;
begin
  FRESTRequest.Client   := FRESTClient;
  FRESTRequest.Response := FRESTResponse;
end;

class function TREST4DObjects.New: IREST4DObjects;
begin
  Result := TREST4DObjects.Create;
end;

function TREST4DObjects.Request: TRESTRequest;
begin
  Result := FRESTRequest;
end;

function TREST4DObjects.Response: TRESTResponse;
begin
  Result := FRESTResponse;
end;

end.
