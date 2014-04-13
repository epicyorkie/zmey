# Zmey API Documentation

Zmey has a REST API that returns data in JSON format.

## Authentication

Requests are made using HTTP basic authentication over SSL, providing an API
key as the username and a blank password.

## Failure responses

* **401 Unauthorized** — the key is invalid.
* **403 Forbidden** — the key is not associated with a website or the object is
owned by another website.
* **426 Upgrade Required** — you are trying to access the API over an
unencrypted connection but SSL should be used.

## Retrieving an API key for client applications

Client applications can exchange a manager or admin's username and password
for an API key. A GET request can be sent to `/admin/api_keys/retrieve/:name`
where `:name` is the name of the API key belonging to the user. The user's
credentials should be supplied using HTTP basic authentication over SSL.

The API key must be created in advance.

A failed authentication will result in an empty response with 401 status.

A 404 status is returned if an API key matching `:name` is not found.

An example curl request:

`curl https://example.com/admin/api_keys/retrieve/ios -u ianf@yesl.co.uk:secret`

A successful retrieval will return JSON similar to the example:

```json
{
  "api_key": {
    "id":1,
    "name":"ios",
    "key":"450dfd180007bf5d66af756c6b5b6805",
    "user_id":1,
    "created_at":"2014-04-07T17:22:56.000+01:00",
    "updated_at":"2014-04-07T17:22:56.000+01:00"
  }
}
```

## Endpoints

### Orders

* [`GET` api/admin/orders](endpoints/admin/orders/GET_index.md)

### Pages

* [`GET` api/admin/pages](endpoints/admin/pages/GET_index.md)
* [`POST` api/admin/pages](endpoints/admin/pages/POST_create.md)

### Products

* [`POST` api/admin/products](endpoints/admin/products/POST_create.md)
* [`DELETE` api/admin/products](endpoints/admin/products/DELETE_delete_all.md)