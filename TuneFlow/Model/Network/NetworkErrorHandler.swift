//
//  NetworkErrorHandler.swift
//  TuneFlow
//
//  Created by Marwan Mekhamer on 28/06/2026.
//

import Foundation

enum ErrorHandler: LocalizedError {
    case emptyEmail
    case emptyPassword
    case validEmail
    case validPassword
    case inValidUserCreateUser
    case inValidationLogin
    
    var errorDescription: String? {
        switch self {
        case .emptyEmail:
            return "Please Enter Your Email"
        case .emptyPassword:
            return "Please Enter Your Password"
        case .validEmail:
            return "Please Valid Your Email"
        case .validPassword:
            return "Please Valid Your Password"
        case .inValidUserCreateUser:
            return "The user is not completed!"
        case .inValidationLogin:
            return "Can not logIn!"
        }
    }
}
