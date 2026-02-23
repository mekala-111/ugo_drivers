import 'package:flutter/material.dart';
import '/models/transaction.dart';

class DriverTransactionsModel {
  // State variables
  int currentPage = 1;
  bool isLoading = false;
  bool hasError = false;
  String errorMessage = '';
  List<Transaction> transactions = [];
  TransactionResponse? transactionResponse;
  ScrollController? scrollController;

  void initState(BuildContext context) {
    scrollController = ScrollController();
    scrollController?.addListener(_onScroll);
  }

  void dispose() {
    scrollController?.dispose();
  }

  void _onScroll() {
    // Pagination logic - load more when scrolling to bottom
    if (scrollController!.position.pixels ==
        scrollController!.position.maxScrollExtent) {
      // trigger load more
    }
  }

  // Helper methods
  void setLoading(bool value) {
    isLoading = value;
  }

  void setError(bool hasError, String message) {
    this.hasError = hasError;
    this.errorMessage = message;
  }

  void setTransactions(List<Transaction> txns) {
    transactions = txns;
    hasError = false;
  }

  void addTransactions(List<Transaction> txns) {
    transactions.addAll(txns);
  }

  void setTransactionResponse(TransactionResponse? response) {
    transactionResponse = response;
    if (response != null) {
      setTransactions(response.transactions);
      currentPage = response.currentPage;
    }
  }

  void resetPage() {
    currentPage = 1;
    transactions.clear();
  }

  // Filter methods
  List<Transaction> get creditTransactions =>
      transactions.where((t) => t.isCredit).toList();

  List<Transaction> get debitTransactions =>
      transactions.where((t) => t.isDebit).toList();

  double get totalAmount => transactions.fold(
        0.0,
        (sum, transaction) =>
            sum +
            (transaction.isCredit ? transaction.amount : -transaction.amount),
      );

  double get creditsTotal =>
      creditTransactions.fold(0.0, (sum, t) => sum + t.amount);

  double get debitsTotal =>
      debitTransactions.fold(0.0, (sum, t) => sum + t.amount);
}
