/// Transaction model for driver payments/withdrawals
class Transaction {
  final String transactionId;
  final String type; // 'credit', 'debit', 'withdrawal', 'refund'
  final double amount;
  final String status; // 'completed', 'pending', 'failed'
  final String flow; // 'credit' | 'debit' (preferred from backend)
  final String description;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Transaction({
    required this.transactionId,
    required this.type,
    required this.amount,
    required this.status,
    required this.flow,
    required this.description,
    required this.createdAt,
    this.updatedAt,
  });

  /// Factory constructor from JSON response
  factory Transaction.fromJson(Map<String, dynamic> json) {
    final rawWhen = json['created_at'] ?? json['date'];
    DateTime when = DateTime.now();
    if (rawWhen != null) {
      if (rawWhen is String) {
        when = DateTime.tryParse(rawWhen) ?? when;
      } else if (rawWhen is DateTime) {
        when = rawWhen;
      }
    }
    return Transaction(
      transactionId: json['transaction_id'] ?? '',
      type: json['type'] ?? 'unknown',
      amount: (json['amount'] is String)
          ? double.tryParse(json['amount']) ?? 0.0
          : (json['amount'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'pending',
      flow: (json['flow'] ?? '').toString().toLowerCase(),
      description: json['description'] ?? '',
      createdAt: when,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
        'transaction_id': transactionId,
        'type': type,
        'amount': amount,
        'status': status,
        'flow': flow,
        'description': description,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  /// Money in vs out — wallet rows use signed amounts (e.g. ride wallet pay is negative).
  bool get isCredit {
    if (flow == 'credit') return true;
    if (flow == 'debit') return false;

    final normalizedType = type.toLowerCase();

    // Some backend rows send positive amount for withdrawals/debits.
    // For UI classification, transaction type must win over numeric sign.
    const debitTypes = {
      'withdrawal',
      'debit',
      'ride_payment',
      'payout',
      'withdraw',
    };
    const creditTypes = {
      'credit',
      'recharge',
      'refund',
      'referral_reward',
      'referral_commission',
      'referral_commission_daily',
      'ride_earning',
    };

    if (debitTypes.contains(normalizedType)) return false;
    if (creditTypes.contains(normalizedType)) return true;
    return amount >= 0;
  }

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
        return 'Credit';
      case 'debit':
        return 'Debit';
      case 'withdrawal':
        return 'Withdrawal';
      case 'refund':
        return 'Refund';
      case 'recharge':
        return 'Wallet top-up';
      case 'ride_payment':
        return amount >= 0 ? 'Ride earning' : 'Ride payment';
      default:
        return type.replaceAll('_', ' ');
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
