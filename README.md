# duke-authentication-service
Authentication Microservice for the [Duke Data Service](https://github.com/Duke-Translational-Bioinformatics/duke-data-service)

The Duke Authentication Service is a microservice which allows a browser client
to utilize the service to allow it's users with Duke University and
Medical Center login privileges (netids) to authenticate securely through
the Duke Shibboleth system.

### Client User Authentication

This service is based on the [OAuth2 service provided by Google](https://developers.google.com/identity/protocols/OAuth2#clientside).
It currently only supports the implicit grant protocol.  Future changes may
be made to support other OAuth2 protocols.

#### Implicit Grant
 The system currently supports the [Implicit Grant](https://tools.ietf.org/html/draft-ietf-oauth-v2-31#section-4.2) protocol.

This protocol allows registered browser clients (see client registration) to
redirect users to the Authentication Service /authenticate endpoint, with the
following request parameters:

  - CLIENT_UUID: Must be registered with the Authentication
    Service.
  - state: random string that should be used by the client to prevent man in the
    middle attacks on the client's users.

When users are redirected to the service with a registered client_id and state,
the service creates a browser login session and redirects them to the Duke
Shibboleth login system. Once logged in, the users are redirected back to the
Authentication Service. Users logging in for the first time are given the
opportunity to allow or decline to allow the Client to access their Duke
information. If they decline, the system simply redirects them back to the
url registered for the client without an access_token. If they allow the
client to access their information it records their choice so that they
are not presented with this opportunity on subsequent logins from the
client.

Users that have allowed the client to access their information are redirected
back to the registered url for the client with the hash fragment with the
following parameters:

  - access_token: JSON Web Token signed by the Authentication Service
  - token_type: 'Bearer'
  - state: the state string passed in by the client
  - expires_in: A Time To Live in Seconds.  The access_token must be validated
    before this expires
  - scope: currently the service only supports one scope (see below)

The client can use the expires_in to determine if the token is valid, and
the state to prevent man in the middle attacks.  It should then make a GET
request to the Authentication Service /token_info endpoint to verify that
the token has actually been created by the Authentication Service, and not
a malicious service. If the access_token is one that has been created and
signed by the Authentication Service, this endpoint will respond with a JSON
object with the following paremeters:

{
 audience: Client UUID,
 uid: User.uid (netid),
 signed_info: JWT of user acct information signed with Client secret,
 expires_in: TTL
}

The client can use this information according to its needs. The most
important part of this is the signed_info. This is a JSON web token signed
by the CLIENT_SECRET, containing the following information:

{
  uid: User uid,
  first_name:  User first_name,
  last_name: User last_name,
  display_name: User display_name,
  email: User email,
  service_id: Authentication Service UUID
}

The client can use its secret to verify and decode the JSON web token,
and access the user credentials.

#### Authentication workflow

-  Client redirects user to
```
/authenticate?client_id=CLIENT_UUID&state=RANDOM
```

-  Authentication Service redirects user back to
```
  CLIENT_REDIRECT_URL#access_token=JWT&state=RANDOM&token_type='Bearer'&expires_in=TTL&scope=CSL
```

- Client requests token info for access_token
```
  GET /token_info?access_token=JWT
```

Client processes JSON response for signed_info, which is a JSON web token
signed by the Client secret containing the user credentials.

#### Registering a Client

Only registered clients can authenticate users through the
Duke Authentication Service. Currently Duke Authentication Service System
Administrators must register each service. Each service must provide the
following information to the system administrators to register their client:
  - CLIENT_UUID: a Universally Unique ID for the client.  This must be
    presented as the client_id parameter to the authenticate endpoint.
  - CLIENT_REDIRECT_URL: URL to redirect all users to after successful authentication. The Authentication Service will ALWAYS redirect to this
  URL with the hash fragment. For security purposes, this cannot be overridden
  by the client.
  - CLIENT_SECRET: This is a random string used to sign the JSON web token
  containing the users Duke credentials.

The following rake tasks have been created to make it easier for system
administrators to register clients with the service:

  consumer:create : Requires environment variables UUID, REDIRECT_URI, and
  SECRET. Uses these to create a new Consumer model for the Client.

  consumer:destroy: Requires environment variable UUID, destroys the Client
  Consumer model for the UUID if it exists.

#### Scope
The scope determines the user credential attributes which are passed back
to the client in the signed_info from token_info.  Currently the Duke
Authentication Service only supports one scope:
```
display_name first_name last_name mail uid
```
Future changes to the system may be made to support new scopes to request different user credential attributes.

### contributing
Developers should fork this repository, and submit pull requests to the develop branch.
Pull requests may be submitted to your forks by other developers to signal that changes
in the develop branch should be merged into your fork.

These pull requests can either be managed in the github UI, or ignored and managed
at the commandline. Here is how you can set up a clone of your fork to fetch
from the 'official' repo, but not allow pushes to this repo (which will also be prevented
by the official github repo):
```
git clone git@github.com:$USER/duke-authentication-service.git
cd duke-authentication-service
git remote add official git@github.com:Duke-Translational-Bioinformatics/duke-authentication-service.git
git remote add official git@github.com:Duke-Translational-Bioinformatics/duke-authentication-service.git
git remote set-url --push official donotpush
```

Then, you can do the following (assuming you are in your develop branch, or another
branch off develop that you intend to merge into develop):
```
git fetch official develop
git merge official/develop
git push
```
