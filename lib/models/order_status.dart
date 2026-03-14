enum OrderStatus {
  pending,
  delivering,
  delivered,
  cancelled,
}

extension OrderStatusX on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Cho xac nhan';
      case OrderStatus.delivering:
        return 'Dang giao';
      case OrderStatus.delivered:
        return 'Da giao';
      case OrderStatus.cancelled:
        return 'Da huy';
    }
  }
}
