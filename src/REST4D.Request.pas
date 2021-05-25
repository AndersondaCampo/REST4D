unit REST4D.Request;

interface

uses
  REST4D.interfaces,
  REST.Client;

type
  TRequest<T: IInterface> = Class(TInterfacedObject, IRequest<T>)
  private
    [weak]
    FParent : T;
    FRequest: TRESTRequest;
  public
    function SynchronizedEvents(const AValue: Boolean): IRequest<T>;
    function AcceptEncoding(const AValue: String): IRequest<T>;
    function &End: T;

    class function New(AParent: T; Request: TRESTRequest): IRequest<T>;
    constructor Create(AParent: T; Request: TRESTRequest);
    destructor Destroy; override;
  End;

implementation

{ TRequest<T> }

function TRequest<T>.AcceptEncoding(const AValue: String): IRequest<T>;
begin
  Result                  := Self;
  FRequest.AcceptEncoding := AValue;
end;

constructor TRequest<T>.Create(AParent: T; Request: TRESTRequest);
begin
  FParent  := AParent;
  FRequest := Request;
end;

destructor TRequest<T>.Destroy;
begin

  inherited;
end;

function TRequest<T>.&End: T;
begin
  Result := FParent;
end;

class function TRequest<T>.New(AParent: T; Request: TRESTRequest): IRequest<T>;
begin
  Result := TRequest<T>.Create(AParent, Request);
end;

function TRequest<T>.SynchronizedEvents(const AValue: Boolean): IRequest<T>;
begin
  Result                      := Self;
  FRequest.SynchronizedEvents := AValue;
end;

end.
