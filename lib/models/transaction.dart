/// Transaction model for driver payments/withdrawals
class Transaction {
  final String transactionId;
  final String type; // 'credit', 'debit', 'withdrawal', 'refund'
  final double amount;
  final String status; // 'completed', 'pending', 'failed'
  final String description;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Transaction({
    required this.transactionId,
    required this.type,
    required this.amount,
    required this.status,
    required this.description,
    required this.createdAt,
    this.updatedAt,
  });

  /// Factory constructor from JSON response
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      transactionId: json['transaction_id'] ?? '',
      type: json['type'] ?? 'unknown',
      amount: (json['amount'] is String)
          ? double.tryParse(json['amount']) ?? 0.0
          : (json['amount'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'pending',
      description: json['description'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
        'transaction_id': transactionId,
        'type': type,
        'amount': amount,
        'status': status,
        'description': description,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  /// Check if transaction is a credit (money in)
  bool get isCredit =>
      type.toLowerCase() == 'credit' || type.toLowerCase() == 'refund';

  /// Check if transaction is a debit (money out)
  bool get isDebit => !isCredit;

  /// Get formatted amount with sign
  String get formattedAmount {
    final prefix = isCredit ? '+ ' : '- ';
    return '$prefix₹${amount.abs().toStringAsFixed(2)}';
  }

  /// Get readable status
  String get readableStatus {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Completed';
      case 'pending':
        return 'Pending';
      case 'failed':
        return 'Failed';
      default:
        return status;
    }
  }

  /// Get readable type
  String get readableType {
    switch (type.toLowerCase()) {
      case 'credit':
        return 'Earning';
      case 'debit':
        return 'Debit';
      case 'withdrawal':
        return 'Withdrawal';
      case 'refund':
        return 'Refund';
      default:
        return type;
    }
  }
}

/// Transaction response for API pagination
class TransactionResponse {
  final bool success;
  final int statusCode;
  final String message;
  final int total;
  final int currentPage;
  final int pageSize;
  final DateTime startDate;
  final DateTime endDate;
  final int statementId;
  final List<Transaction> transactions;

  TransactionResponse({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.total,
    required this.currentPage,
    required this.pageSize,
    required this.startDate,
    required this.endDate,
    required this.statementId,
    required this.transactions,
  });

  /// Factory constructor from JSON response
  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final transactionsList = (data['transactions'] as List?)
            ?.map((item) => Transaction.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];

    return TransactionResponse(
      success: json['success'] ?? false,
      statusCode: json['statusCode'] ?? 0,
      message: json['message'] ?? '',
      total: data['total'] ?? 0,
      currentPage: data['page'] ?? 1,
      pageSize: data['pageSize'] ?? 20,
      startDate: data['range'] != null && data['range']['start_date'] != null
          ? DateTime.parse(data['range']['start_date'] as String)
          : DateTime.now(),
      endDate: data['range'] != null && data['range']['end_date'] != null
          ? DateTime.parse(data['range']['end_date'] as String)
          : DateTime.now(),
      statementId: data['statement_id'] ?? 0,
      transactions: transactionsList,
    );
  }

  /// Check if there are more pages
  bool get hasMorePages => (currentPage * pageSize) < total;

  /// Next page number
  int get nextPage => currentPage + 1;
}
