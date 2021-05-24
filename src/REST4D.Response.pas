unit REST4D.Response;

interface

uses
  REST4D.interfaces;

type
  TResponse<T: IInterface> = Class(TinterfacedObject, IResponse<T>)
  private
    [weak]
    FParent     : T;
    FContentType: String;

  public
    function ContentType(const AValue: String): IResponse<T>; overload;
    function ContentType: String; overload;
    function &End: T;

    class function New(AParent: T): IResponse<T>;
    constructor Create(AParent: T);
    destructor Destroy; override;
  End;

implementation

{ TResponse<T> }

function TResponse<T>.ContentType(const AValue: String): IResponse<T>;
begin
  Result       := Self;
  FContentType := AValue;
end;

function TResponse<T>.ContentType: String;
begin
  Result := FContentType;
end;

constructor TResponse<T>.Create(AParent: T);
begin
  FParent := AParent;
end;

destructor TResponse<T>.Destroy;
begin

  inherited;
end;

function TResponse<T>.&End: T;
begin
  Result := FParent;
end;

class function TResponse<T>.New(AParent: T): IResponse<T>;
begin
  Result := TResponse<T>.Create(AParent);
end;

end.
