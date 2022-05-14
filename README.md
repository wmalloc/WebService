


# WebService

A lightweight Web API for [Apple](https://www.apple.com) devices, written in [Swift](https://swift.org) 5.x and using [Combine](https://developer.apple.com/documentation/combine).

## Features

| |Features |
--------------------------|------------------------------------------------------------
`Request` | Build your `URLRequest` to make a call
`WebService` | Main object you can subclass to create an API client.
`URLRequestEncodable` Protocol | If you would like to provide your own request builder


## Usage

There are three libraries that you can use.

1. `WebService` is the core library that provides the closure base APIs to fetch data.
Just import `WebService` at the top of the Swift file that will interact create the API for web call.
2. `WebServiceCombine` provides the `Combine` based API.
3. `WebServiceConcurrency` provides the structured concurrecny based api that is backwards compatiable.


``` swift
import WebService
```

You now make your client 

``` swift
class APIClient {
    let webService: WebService

    init(baseURLString: String, session: URLSession = .shared) {
        webService = WebService(baseURLString: baseURLString, session: session)
    }
}
```

Once you have setup the service you can start to add your APIs for your backend service. This is hypothetical search call to get your search Data

``` swift
func search(query: String, limit: UInt) -> AnyPublisher<SearchResponse, Error>? {
    let queryParameters: [String: Any] = ["query": query, "limit": limit]
    return webService.GET("/search").setQueryParameters(query)
        .tryMap { (result) -> Data in
            let validData = try result.data.ws_validate(result.response).ws_validateNotEmptyData()
            return validData
    }
    .decode(type: SearchResponse.self, decoder: JSONDecoder())
    .receive(on: queue)
    .eraseToAnyPublisher()
}
```

## Request
If you did not want the service to build your `URLRequest` you can build your request using the `Request` structure.

``` swift
func search<ObjectType: Decodable>(query: String, limit: UInt) -> AnyPublisher<SearchResponse, Error>? {
    let request = Request(.GET, url: webService.baseURLString + "/search")
        .setQueryParameters(query)
        .setHeaders([Request.Header.contentType: Request.ContentType.json])

    return webService.servicePublisher(request: request)
        .tryMap { (result) -> Data in
            let validData = try result.data.ws_validate(result.response).ws_validateNotEmptyData()
            return validData
    }
    .decode(type: ObjectType.self, decoder: JSONDecoder())
    .receive(on: queue)
    .eraseToAnyPublisher()
}
```

## async/await

``` swift
func search<ObjectType: Decodable>(query: String, limit: UInt) async throws -> SearchResponse {
    let request = Request(.GET, url: webService.baseURLString + "/search")
        .setQueryParameters(query)
        .setHeaders([Request.Header.contentType: Request.ContentType.json])
    return try await webService.decodable(request)
}
```
