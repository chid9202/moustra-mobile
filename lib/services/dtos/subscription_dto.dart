class BillingHistoryItemDto {
  final String id;
  final String total;
  final String periodStart;
  final String periodEnd;
  final String status;
  final String hostedInvoiceUrl;
  final String invoicePdf;

  BillingHistoryItemDto({
    required this.id,
    required this.total,
    required this.periodStart,
    required this.periodEnd,
    required this.status,
    required this.hostedInvoiceUrl,
    required this.invoicePdf,
  });

  factory BillingHistoryItemDto.fromJson(Map<String, dynamic> json) {
    return BillingHistoryItemDto(
      id: json['id'] as String,
      total: json['total'] as String,
      periodStart: json['periodStart'] as String,
      periodEnd: json['periodEnd'] as String,
      status: json['status'] as String,
      hostedInvoiceUrl: json['hostedInvoiceUrl'] as String,
      invoicePdf: json['invoicePdf'] as String,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'total': total,
        'periodStart': periodStart,
        'periodEnd': periodEnd,
        'status': status,
        'hostedInvoiceUrl': hostedInvoiceUrl,
        'invoicePdf': invoicePdf,
      };
}

class SubscriptionResponseDto {
  final int seats;
  final String price;
  final String status;
  final String renewalDate;
  final List<BillingHistoryItemDto> billingHistory;

  SubscriptionResponseDto({
    required this.seats,
    required this.price,
    required this.status,
    required this.renewalDate,
    required this.billingHistory,
  });

  factory SubscriptionResponseDto.fromJson(Map<String, dynamic> json) {
    return SubscriptionResponseDto(
      seats: json['seats'] as int,
      price: json['price'] as String,
      status: json['status'] as String,
      renewalDate: json['renewalDate'] as String,
      billingHistory: (json['billingHistory'] as List<dynamic>)
          .map((item) => BillingHistoryItemDto.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'seats': seats,
        'price': price,
        'status': status,
        'renewalDate': renewalDate,
        'billingHistory': billingHistory.map((item) => item.toJson()).toList(),
      };
}







