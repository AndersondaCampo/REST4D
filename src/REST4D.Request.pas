unit REST4D.Request;

interface

uses
  REST4D.interfaces;

type
  TRequest<T: IInterface> = Class(TInterfacedObject, IRequest<T>)
  private
    [weak]
    FParent            : T;
    FSynchronizedEvents: Boolean;
    FAcceptEncoding    : String;
  public
    function SynchronizedEvents(const AValue: Boolean): IRequest<T>; overload;
    function SynchronizedEvents: Boolean; overload;
    function AcceptEncoding(const AValue: String): IRequest<T>; overload;
    function AcceptEncoding: String; overload;
    function &End: T;

    class function New(AParent: T): IRequest<T>;
    constructor Create(AParent: T);
    destructor Destroy; override;
  End;

implementation

{ TRequest<T> }

function TRequest<T>.AcceptEncoding: String;
begin
  Result := FAcceptEncoding;
end;

function TRequest<T>.AcceptEncoding(const AValue: String): IRequest<T>;
begin
  Result          := Self;
  FAcceptEncoding := AValue;
end;

constructor TRequest<T>.Create(AParent: T);
begin
  FParent := AParent;
end;

destructor TRequest<T>.Destroy;
begin

  inherited;
end;

function TRequest<T>.&End: T;
begin
  Result := FParent;
end;

class function TRequest<T>.New(AParent: T): IRequest<T>;
begin
  Result := TRequest<T>.Create(AParent);
end;

function TRequest<T>.SynchronizedEvents(const AValue: Boolean): IRequest<T>;
begin
  Result              := Self;
  FSynchronizedEvents := AValue;
end;

function TRequest<T>.SynchronizedEvents: Boolean;
begin
  Result := FSynchronizedEvents
end;

end.
