///Section : Use Types
enum UserType { normalUser, serviceProvider }

///Section : My Bookings Screen Enums
enum BookingStatusEnum {
  pending,
  acceptedBooking,
  inProgress,
  paymentRequest,
  canceled,
  workCompleted,
}

/// FaceVerificationState states
enum FaceVerificationStatus { initial, capture, verifying, done }

///Section : Job Request Status
enum JobRequestStatusEnum { pending, accepted, completed }
