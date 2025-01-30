// lib/src/services/firebase_error_handler.dart

import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseErrorHandler {
  // Custom exception for Firebase operations
  static Exception handleError(Object error, String operation) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return Exception(
              'Access denied: Insufficient permissions for $operation');
        case 'not-found':
          return Exception('Resource not found for $operation');
        case 'already-exists':
          return Exception('Resource already exists for $operation');
        case 'cancelled':
          return Exception('Operation cancelled: $operation');
        case 'deadline-exceeded':
          return Exception('Operation timed out: $operation');
        case 'unavailable':
          return Exception('Service unavailable. Please try again later');
        case 'unauthenticated':
          return Exception('Authentication required for $operation');
        case 'internal':
          return Exception('Internal error occurred. Please try again');
        default:
          return Exception(
              'Firebase error during $operation: ${error.message}');
      }
    }

    // Handle network errors
    if (error is SocketException || error is TimeoutException) {
      return Exception(
          'Network error during $operation. Please check your connection.');
    }

    // Handle format errors
    if (error is FormatException) {
      return Exception('Data format error during $operation');
    }

    // Default error handling
    return Exception('Error during $operation: $error');
  }

  // Wrapper function for Firebase operations
  static Future<T> wrap<T>({
    required String operation,
    required Future<T> Function() action,
    T Function(Exception error)? errorHandler,
  }) async {
    try {
      return await action();
    } catch (error) {
      final exception = handleError(error, operation);

      // Log error for debugging
      print('Firebase Error in $operation: $error');

      // Use custom error handler if provided, otherwise throw
      if (errorHandler != null) {
        return errorHandler(exception as Exception);
      }
      throw exception;
    }
  }

  // Wrapper for Firebase streams
  static Stream<T> wrapStream<T>({
    required String operation,
    required Stream<T> Function() streamAction,
  }) {
    return streamAction().handleError((error) {
      throw handleError(error, operation);
    });
  }
}
