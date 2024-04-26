import 'dart:convert';

class BankTransactions {
  List<BankTransaction> booked;
  List<BankTransaction> pending;

  BankTransactions({
    required this.booked,
    required this.pending,
  });
}

class BankTransaction {
  String? transactionId;
  String? entryReference;
  String? endToEndId;
  String? mandateId;
  String? checkId;
  String? creditorId;
  String? bookingDate;
  String? valueDate;
  String? bookingDateTime;
  String? valueDateTime;
  BankTransactionAmount? transactionAmount;
  CurrencyExchange? currencyExchange;
  String? creditorName;
  BankAccount? creditorAccount;
  String? ultimateCreditor;
  String? debtorName;
  BankAccount? debtorAccount;
  String? ultimateDebtor;
  String? remittanceInformationUnstructured;
  List<String>? remittanceInformationUnstructuredArray;
  String? remittanceInformationStructured;
  List<String>? remittanceInformationStructuredArray;
  String? additionalInformation;
  String? purposeCode;
  String? bankTransactionCode;
  String? proprietaryBankTransactionCode;
  String? internalTransactionId;

  BankTransaction({
    this.transactionId,
    this.entryReference,
    this.endToEndId,
    this.mandateId,
    this.checkId,
    this.creditorId,
    this.bookingDate,
    this.valueDate,
    this.bookingDateTime,
    this.valueDateTime,
    this.transactionAmount,
    this.currencyExchange,
    this.creditorName,
    this.creditorAccount,
    this.ultimateCreditor,
    this.debtorName,
    this.debtorAccount,
    this.ultimateDebtor,
    this.remittanceInformationUnstructured,
    this.remittanceInformationUnstructuredArray,
    this.remittanceInformationStructured,
    this.remittanceInformationStructuredArray,
    this.additionalInformation,
    this.purposeCode,
    this.bankTransactionCode,
    this.proprietaryBankTransactionCode,
    this.internalTransactionId,
  });

  static BankTransaction fromJson(Map<String, dynamic> json) {
    var transactionAmount = json['transactionAmount'];
    var currencyExchange = json['currencyExchange'];
    var creditorAccount = json['creditorAccount'];
    var debtorAccount = json['debtorAccount'];
    var remittanceInformationUnstructuredArray =
        json['remittanceInformationUnstructuredArray'];
    var remittanceInformationStructuredArray =
        json['remittanceInformationStructuredArray'];

    return BankTransaction(
      transactionId: json['transactionId'],
      entryReference: json['entryReference'],
      endToEndId: json['endToEndId'],
      mandateId: json['mandateId'],
      checkId: json['checkId'],
      creditorId: json['creditorId'],
      bookingDate: json['bookingDate'],
      valueDate: json['valueDate'],
      bookingDateTime: json['bookingDateTime'],
      valueDateTime: json['valueDateTime'],
      transactionAmount: BankTransactionAmount.fromJson(transactionAmount),
      currencyExchange: CurrencyExchange.fromJson(currencyExchange),
      creditorName: json['creditorName'],
      creditorAccount: BankAccount.fromJson(creditorAccount),
      ultimateCreditor: json['ultimateCreditor'],
      debtorName: json['debtorName'],
      debtorAccount: BankAccount.fromJson(debtorAccount),
      ultimateDebtor: json['ultimateDebtor'],
      remittanceInformationUnstructured:
          json['remittanceInformationUnstructured'],
      remittanceInformationUnstructuredArray:
          remittanceInformationUnstructuredArray,
      remittanceInformationStructured: json['remittanceInformationStructured'],
      remittanceInformationStructuredArray:
          remittanceInformationStructuredArray,
      additionalInformation: json['additionalInformation'],
      purposeCode: json['purposeCode'],
      bankTransactionCode: json['bankTransactionCode'],
      proprietaryBankTransactionCode: json['proprietaryBankTransactionCode'],
      internalTransactionId: json['internalTransactionId'],
    );
  }

  static BankTransaction? fromString(String? json) {
    if (json == null) {
      return null;
    }

    return fromJson(jsonDecode(json));
  }
}

class BankTransactionAmount {
  String? amount;
  String? currency;

  BankTransactionAmount({
    this.amount,
    this.currency,
  });

  static BankTransactionAmount? fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }

    if (json
        case {
          'amount': String? amount,
          'currency': String? currency,
        }) {
      return BankTransactionAmount(
        amount: amount,
        currency: currency,
      );
    }

    print('! Failed to parse transaction amount');
    return null;
  }

  static BankTransactionAmount? fromString(String? json) {
    if (json == null) {
      return null;
    }

    return fromJson(jsonDecode(json));
  }
}

class CurrencyExchange {
  String? sourceCurrency;
  String? exchangeRate;
  String? unitCurrency;
  String? targetCurrency;
  String? quotationDate;
  String? contractIdentification;

  CurrencyExchange({
    this.sourceCurrency,
    this.exchangeRate,
    this.unitCurrency,
    this.targetCurrency,
    this.quotationDate,
    this.contractIdentification,
  });

  static CurrencyExchange? fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }

    if (json
        case {
          'sourceCurrency': String? sourceCurrency,
          'exchangeRate': String? exchangeRate,
          'unitCurrency': String? unitCurrency,
          'targetCurrency': String? targetCurrency,
          'quotationDate': String? quotationDate,
          'contractIdentification': String? contractIdentification,
        }) {
      return CurrencyExchange(
        sourceCurrency: sourceCurrency,
        exchangeRate: exchangeRate,
        unitCurrency: unitCurrency,
        targetCurrency: targetCurrency,
        quotationDate: quotationDate,
        contractIdentification: contractIdentification,
      );
    }

    print('! Failed to parse currency exchange');
    return null;
  }

  static CurrencyExchange? fromString(String? json) {
    if (json == null) {
      return null;
    }

    return fromJson(jsonDecode(json));
  }
}

class BankAccount {
  String? iban;
  String? bban;
  String? pan;
  String? maskedPan;
  String? msisdn;
  String? currency;

  BankAccount({
    this.iban,
    this.bban,
    this.pan,
    this.maskedPan,
    this.msisdn,
    this.currency,
  });

  static BankAccount? fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }

    return BankAccount(
      iban: json['iban'],
      bban: json['bban'],
      pan: json['pan'],
      maskedPan: json['maskedPan'],
      msisdn: json['msisdn'],
      currency: json['currency'],
    );
  }

  static BankAccount? fromString(String? json) {
    if (json == null) {
      return null;
    }

    return fromJson(jsonDecode(json));
  }
}
