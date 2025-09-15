---
title: HTTPChannel
slug: playerio/utils/httpchannel
description: HTTP Channel
---

PlayerIO networking utilities, often used to make network request.

## Request

Request method is the main point of `HTTPChannel` class. It initiates a network request and also handle any errors. PlayerIO utilize RPC calls for networking. A request is sent in HTTP POST request with headers, endpoint, and RPC method. It may also include player token in the header if available. The serialization format is protobuf.

The endpoint is hardcoded to a particular domain. In our private server, it is hardcoded to `http://127.0.0.1:5000/api`.

It also sets up event listeners for I/O errors, security errors, and successful responses. These will trigger the callbacks given in the request method (parameters 5 and 6 for success and error).
