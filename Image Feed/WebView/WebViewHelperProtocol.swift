//
//  WebViewHelperProtocol.swift
//  Image Feed
//
//  Created by Дарья Савинкина on 18.02.2026.
//

import Foundation

protocol WebViewHelperProtocol {
    func authRequest() -> URLRequest?
    func code(from url: URL) -> String?
}

final class WebViewHelper: WebViewHelperProtocol {
    func authRequest() -> URLRequest? {
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else {
            return nil
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        guard let url = urlComponents.url else { return nil }
        return URLRequest(url: url)
    }

    func code(from url: URL) -> String? {
        if let urlComponents = URLComponents(string: url.absoluteString),
           urlComponents.path == "/oauth/authorize/native",
           let items = urlComponents.queryItems,
           let codeItem = items.first(where: { $0.name == "code" }) {
            return codeItem.value
        }
        return nil
    }
}
