unit REST4D.OAuth2;

interface

uses
  REST4D.Interfaces,
  System.SysUtils;

type
  TOAuth2<T: IInterface> = Class(TInterfacedObject, IOAuth2<T>)
  private
    [weak]
    FParent: T;
    FOAuth2: TOAuth2Params;

  public
    function AuthorizationEndpoint(const AValue: String): IOAuth2<T>;
    function AccessTokenEndpoint(const AValue: String): IOAuth2<T>;
    function ClientID(const AValue: String): IOAuth2<T>;
    function ClientSecret(const AValue: String): IOAuth2<T>;
    function ResponseType(const AValue: String): IOAuth2<T>;
    function Props: TOAuth2Params;
    function &End: T;

    class function New(AParent: T): IOAuth2<T>;
    constructor Create(AParent: T);
    destructor Destroy; override;
  End;

implementation

{ TOAuth2<T> }

function TOAuth2<T>.AccessTokenEndpoint(const AValue: String): IOAuth2<T>;
begin
  Result                      := Self;
  FOAuth2.AccessTokenEndpoint := AValue;
end;

function TOAuth2<T>.AuthorizationEndpoint(const AValue: String): IOAuth2<T>;
begin
  Result                        := Self;
  FOAuth2.AuthorizationEndpoint := AValue;
end;

function TOAuth2<T>.ClientID(const AValue: String): IOAuth2<T>;
begin
  Result           := Self;
  FOAuth2.ClientID := AValue;
end;

function TOAuth2<T>.ClientSecret(const AValue: String): IOAuth2<T>;
begin
  Result               := Self;
  FOAuth2.ClientSecret := AValue;
end;

constructor TOAuth2<T>.Create(AParent: T);
begin
  FParent              := AParent;
  FOAuth2.ResponseType := 'token';
end;

destructor TOAuth2<T>.Destroy;
begin

  inherited;
end;

function TOAuth2<T>.&End: T;
begin
  Result := FParent;
end;

class function TOAuth2<T>.New(AParent: T): IOAuth2<T>;
begin
  Result := TOAuth2<T>.Create(AParent);
end;

function TOAuth2<T>.Props: TOAuth2Params;
begin
  Result := FOAuth2;
end;

function TOAuth2<T>.ResponseType(const AValue: String): IOAuth2<T>;
begin
  Result               := Self;
  FOAuth2.ResponseType := AValue;
end;

end.
