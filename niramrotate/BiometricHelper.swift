//
//  BiometricHelper.swift
//  niramrotate
//
//  Created by aravinthan.selvaraj on 17/12/25.
//


import LocalAuthentication

enum BiometricHelper {

    static func authenticate(
        reason: String = "Authenticate to access your Wallhaven API key"
    ) async throws {

        let context = LAContext()
        context.localizedFallbackTitle = "Use Passcode"

        var error: NSError?

        guard context.canEvaluatePolicy(
            .deviceOwnerAuthentication,
            error: &error
        ) else {
            throw error ?? NSError(
                domain: "Biometric",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Biometric authentication not available"]
            )
        }

        try await withCheckedThrowingContinuation { continuation in
            context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: reason
            ) { success, authError in
                if success {
                    continuation.resume()
                } else {
                    continuation.resume(
                        throwing: authError ?? NSError(
                            domain: "Biometric",
                            code: -2,
                            userInfo: [NSLocalizedDescriptionKey: "Authentication failed"]
                        )
                    )
                }
            }
        }
    }
}
