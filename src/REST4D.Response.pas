unit REST4D.Response;

interface

uses
  REST4D.interfaces,
  REST.Client;

type
  TResponse<T: IInterface> = Class(TinterfacedObject, IResponse<T>)
  private
    [weak]
    FParent  : T;
    FResponse: TRESTResponse;

  public
    function ContentType(const AValue: String): IResponse<T>; overload;
    function ContentType: String; overload;
    function &End: T;

    class function New(AParent: T; Response: TRESTResponse): IResponse<T>;
    constructor Create(AParent: T; Response: TRESTResponse);
    destructor Destroy; override;
  End;

implementation

{ TResponse<T> }

function TResponse<T>.ContentType(const AValue: String): IResponse<T>;
begin
  Result                := Self;
  FResponse.ContentType := AValue;
end;

function TResponse<T>.ContentType: String;
begin
  Result := FResponse.ContentType;
end;

constructor TResponse<T>.Create(AParent: T; Response: TRESTResponse);
begin
  FParent   := AParent;
  FResponse := Response;
end;

destructor TResponse<T>.Destroy;
begin

  inherited;
end;

function TResponse<T>.&End: T;
begin
  Result := FParent;
end;

class function TResponse<T>.New(AParent: T; Response: TRESTResponse): IResponse<T>;
begin
  Result := TResponse<T>.Create(AParent, Response);
end;

end.
