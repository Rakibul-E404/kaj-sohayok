class ServiceWalletTransactionModel {
  final String walletId;
  final String userId;
  final String? paymentTransactionId; // Nullable field
  final String type;
  final double amount;
  final String currency;
  final double balanceBefore;
  final double balanceAfter;
  final String status;
  final String referenceFor;
  final String referenceId;
  final int v;
  final String walletTransactionHistoryId;
  final String createdAt; // Add createdAt as a String to store the date

  // Constructor
  ServiceWalletTransactionModel({
    required this.walletId,
    required this.userId,
    this.paymentTransactionId,  // Optional argument, can be null
    required this.type,
    required this.amount,
    required this.currency,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.status,
    required this.referenceFor,
    required this.referenceId,
    required this.v,
    required this.walletTransactionHistoryId,
    required this.createdAt,  // Make sure it's passed as required
  });

  // Factory method to create an instance from a JSON object
  factory ServiceWalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return ServiceWalletTransactionModel(
      walletId: json['walletId'],
      userId: json['userId'],
      paymentTransactionId: json['paymentTransactionId'],  // Can be null
      type: json['type'],
      amount: json['amount'].toDouble(),  // Handle conversion to double
      currency: json['currency'],
      balanceBefore: json['balanceBefore'].toDouble(),
      balanceAfter: json['balanceAfter'].toDouble(),
      status: json['status'],
      referenceFor: json['referenceFor'],
      referenceId: json['referenceId'],
      v: json['__v'],
      walletTransactionHistoryId: json['_WalletTransactionHistoryId'],
      createdAt: json['createdAt'], // Parsing the createdAt field
    );
  }

  // Alternative constructor: from a Map
  factory ServiceWalletTransactionModel.fromMap(Map<String, dynamic> map) {
    return ServiceWalletTransactionModel(
      walletId: map['walletId'],
      userId: map['userId'],
      paymentTransactionId: map['paymentTransactionId'],  // Can be null
      type: map['type'],
      amount: map['amount'].toDouble(),
      currency: map['currency'],
      balanceBefore: map['balanceBefore'].toDouble(),
      balanceAfter: map['balanceAfter'].toDouble(),
      status: map['status'],
      referenceFor: map['referenceFor'],
      referenceId: map['referenceId'],
      v: map['__v'],
      walletTransactionHistoryId: map['_WalletTransactionHistoryId'],
      createdAt: map['createdAt'],  // Parsing the createdAt field
    );
  }

  // Method to convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'walletId': walletId,
      'userId': userId,
      'paymentTransactionId': paymentTransactionId,  // Can be null
      'type': type,
      'amount': amount,
      'currency': currency,
      'balanceBefore': balanceBefore,
      'balanceAfter': balanceAfter,
      'status': status,
      'referenceFor': referenceFor,
      'referenceId': referenceId,
      '__v': v,
      '_WalletTransactionHistoryId': walletTransactionHistoryId,
      'createdAt': createdAt,  // Convert to JSON
    };
  }
}


class ServiceWalletAccount {
  final String userId;
  final double amount;
  final String currency;
  final String status;
  final bool isDeleted;
  final String createdAt;  // Assuming it's a String in ISO8601 format
  final String updatedAt;  // Assuming it's a String in ISO8601 format
  final int v;
  final double totalBalance;
  final String walletId;

  // Constructor
  ServiceWalletAccount({
    required this.userId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    required this.totalBalance,
    required this.walletId,
  });

  // Factory method to create an instance from a JSON object
  factory ServiceWalletAccount.fromJson(Map<String, dynamic> json) {
    return ServiceWalletAccount(
      userId: json['userId'],
      amount: json['amount'].toDouble(),
      currency: json['currency'],
      status: json['status'],
      isDeleted: json['isDeleted'],
      createdAt: json['createdAt'],  // String representation of DateTime
      updatedAt: json['updatedAt'],  // String representation of DateTime
      v: json['__v'],
      totalBalance: json['totalBalance'].toDouble(),
      walletId: json['_WalletId'],
    );
  }

  // Alternative constructor: from a Map
  factory ServiceWalletAccount.fromMap(Map<String, dynamic> map) {
    return ServiceWalletAccount(
      userId: map['userId'],
      amount: map['amount'].toDouble(),
      currency: map['currency'],
      status: map['status'],
      isDeleted: map['isDeleted'],
      createdAt: map['createdAt'],  // String representation of DateTime
      updatedAt: map['updatedAt'],  // String representation of DateTime
      v: map['__v'],
      totalBalance: map['totalBalance'].toDouble(),
      walletId: map['_WalletId'],
    );
  }

  // Method to convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'amount': amount,
      'currency': currency,
      'status': status,
      'isDeleted': isDeleted,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
      'totalBalance': totalBalance,
      '_WalletId': walletId,
    };
  }
}
