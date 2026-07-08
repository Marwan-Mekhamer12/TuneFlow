//
//  Validation .swift
//  TuneFlow
//
//  Created by Marwan Mekhamer on 28/06/2026.
//

import Foundation

struct Validation {
    
    static func validation(_ email: String,_ password: String) throws {
        let email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !email.isEmpty else {
            throw ErrorHandler.emptyEmail
        }
        
        guard isValidEmail(email) else {
            throw ErrorHandler.validEmail
        }
        
        guard !password.isEmpty else {
            throw ErrorHandler.emptyPassword
        }
        
        guard isValidPassword(password) else {
            throw ErrorHandler.validPassword
        }
    }
    
    private static func isValidEmail(_ email: String) -> Bool {
        let regex = #"^[A-Za-z0-9._%+\-$=#]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: email)
    }
    
    private static func isValidPassword(_ password: String) -> Bool {
           let regex = #"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*()_+\-=])[A-Za-z\d!@#$%^&*()_+\-=]{8,}$"#
           let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
           return predicate.evaluate(with: password)
       }
}
