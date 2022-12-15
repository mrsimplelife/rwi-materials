/// Copyright (c) 2022 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation

protocol RequestProtocol {
  // 1
  var path: String { get }

  // 2
  var headers: [String: String] { get }
  var params: [String: Any] { get }

  // 3
  var urlParams: [String: String?] { get }

  // 4
  var addAuthorizationToken: Bool { get }

  // 5
  var requestType: RequestType { get }
}

extension RequestProtocol {
  // 1
  var host: String {
    APIConstants.host
  }

  // 2
  var addAuthorizationToken: Bool {
    true
  }

  // 3
  var params: [String: Any] {
    [:]
  }

  var urlParams: [String: String?] {
    [:]
  }

  var headers: [String: String] {
    [:]
  }

  // 1
  func createURLRequest(authToken: String) throws -> URLRequest {
    // 2
    var components = URLComponents()
    components.scheme = "https"
    components.host = self.host
    components.path = path
    // 3
    if !self.urlParams.isEmpty {
      components.queryItems = self.urlParams.map {
        URLQueryItem(name: $0, value: $1)
      }
    }

    guard let url = components.url else { throw NetworkError.invalidURL }

    // 4
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = requestType.rawValue
    // 5
    if !self.headers.isEmpty {
      urlRequest.allHTTPHeaderFields = self.headers
    }
    // 6
    if self.addAuthorizationToken {
      urlRequest.setValue(
        authToken,
        forHTTPHeaderField: "Authorization"
      )
    }
    // 7
    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
    // 8
    if !self.params.isEmpty {
      urlRequest.httpBody = try JSONSerialization.data(withJSONObject: self.params)
    }

    return urlRequest
  }

}
