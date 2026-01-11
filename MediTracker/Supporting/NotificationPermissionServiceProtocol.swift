//
//  NotificationPermissionServiceProtocol.swift
//  MediTracker
//
//  Created by Igor Gorelik on 11/1/2026.
//


import Foundation
import UserNotifications

public protocol NotificationPermissionServiceProtocol {
    /// Requests notification permission; calls completion with `true` if granted.
    func requestAuthorization(completion: @escaping (Bool) -> Void)
    /// Gets current authorization status asynchronously.
    func getAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void)
}