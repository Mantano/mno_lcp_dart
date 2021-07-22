// Copyright (c) 2021 Mantano. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mno_shared_dart/publication.dart';
import 'package:universal_io/io.dart';

class LcpException extends UserException {
  final String message;

  static const LicenseStatus licenseStatus = LicenseStatus._("");
  static const Renew renew = Renew._("");
  static const Return return_ = Return._("");
  static const Parsing parsing = Parsing._();
  static const ContainerException container = ContainerException._("");
  static const LicenseIntegrity licenseIntegrity = LicenseIntegrity._("");
  static const Decryption decryption = Decryption._("");

  const LcpException(String userMessageId,
      {List<dynamic> args = const [],
      int quantity,
      this.message,
      Exception cause})
      : super(userMessageId, args: args, quantity: quantity, cause: cause);

  static LcpException wrap(dynamic e) {
    if (e is LcpException) {
      return e;
    }
    if (e is SocketException) {
      return network(e);
    }
    return unknown;
  }

  /// The interaction is not available with this License.
  static LcpException get licenseInteractionNotAvailable =>
      const LcpException("r2_lcp_exception_license_interaction_not_available");

  /// This License's profile is not supported by liblcp.
  static LcpException get licenseProfileNotSupported =>
      const LcpException("r2_lcp_exception_license_profile_not_supported");

  /// Failed to retrieve the Certificate Revocation List.
  static LcpException get crlFetching =>
      const LcpException("r2_lcp_exception_crl_fetching");

  /// A network request failed with the given exception.
  static LcpException network(Exception cause) =>
      LcpException("r2_lcp_exception_network", cause: cause);

  /// An unexpected LCP exception occurred. Please post an issue on r2-lcp-kotlin with the error
  /// message and how to reproduce it.
  static LcpException runtime(String message) =>
      LcpException("r2_lcp_exception_runtime", message: message);

  /// An unknown low-level exception was reported.
  static LcpException get unknown =>
      const LcpException("r2_lcp_exception_unknown");
}

/// Errors while checking the status of the License, using the Status Document.
///
/// The app should notify the user and stop there. The message to the user must be clear about
/// the status of the license: don't display "expired" if the status is "revoked". The date and
/// time corresponding to the new status should be displayed (e.g. "The license expired on 01
/// January 2018").
class LicenseStatus extends LcpException {
  const LicenseStatus._(String userMessageId,
      {List<dynamic> args = const [], int quantity, String message})
      : super(userMessageId, args: args, quantity: quantity, message: message);

  LicenseStatus cancelled(DateTime date) =>
      LicenseStatus._("r2_lcp_exception_license_status_cancelled",
          args: [date]);

  LicenseStatus returned(DateTime date) =>
      LicenseStatus._("r2_lcp_exception_license_status_returned", args: [date]);

  LicenseStatus notStarted(DateTime start) =>
      LicenseStatus._("r2_lcp_exception_license_status_not_started",
          args: [start]);

  LicenseStatus expired(DateTime end) =>
      LicenseStatus._("r2_lcp_exception_license_status_expired", args: [end]);

  /// If the license has been revoked, the user message should display the number of devices which
  /// registered to the server. This count can be calculated from the number of "register" events
  /// in the status document. If no event is logged in the status document, no such message should
  /// appear (certainly not "The license was registered by 0 devices").
  LicenseStatus revoked(DateTime date, int devicesCount) =>
      LicenseStatus._("r2_lcp_exception_license_status_revoked",
          quantity: devicesCount, args: [date, devicesCount]);
}

/// Errors while renewing a loan.
class Renew extends LcpException {
  const Renew._(String userMessageId) : super(userMessageId);

  /// Your publication could not be renewed properly.
  Renew get renewFailed => const Renew._("r2_lcp_exception_renew_renew_failed");

  InvalidRenewalPeriod invalidRenewalPeriod(DateTime maxRenewDate) =>
      InvalidRenewalPeriod._(maxRenewDate);

  /// An unexpected error has occurred on the licensing server.
  Renew get unexpectedServerError =>
      const Renew._("r2_lcp_exception_renew_unexpected_server_error");
}

/// Incorrect renewal period, your publication could not be renewed.
class InvalidRenewalPeriod extends Renew {
  final DateTime maxRenewDate;

  const InvalidRenewalPeriod._(this.maxRenewDate)
      : super._("r2_lcp_exception_renew_invalid_renewal_period");
}

/// Errors while returning a loan.
class Return extends LcpException {
  const Return._(String userMessageId) : super(userMessageId);

  /// Your publication could not be returned properly.
  Return get returnFailed =>
      const Return._("r2_lcp_exception_return_return_failed");

  /// Your publication has already been returned before or is expired.
  Return get alreadyReturnedOrExpired =>
      const Return._("r2_lcp_exception_return_already_returned_or_expired");

  /// An unexpected error has occurred on the licensing server.
  Return get unexpectedServerError =>
      const Return._("r2_lcp_exception_return_unexpected_server_error");
}

/// Errors while parsing the License or Status JSON Documents.
class Parsing extends LcpException {
  const Parsing._([String userMessageId])
      : super(userMessageId ?? "r2_lcp_exception_parsing");

  /// The JSON is malformed and can't be parsed.
  Parsing get malformedJSON =>
      const Parsing._("r2_lcp_exception_parsing_malformed_json");

  /// The JSON is not representing a valid License Document.
  Parsing get licenseDocument =>
      const Parsing._("r2_lcp_exception_parsing_license_document");

  /// The JSON is not representing a valid Status Document.
  Parsing get statusDocument =>
      const Parsing._("r2_lcp_exception_parsing_status_document");

  /// Invalid Link.
  Parsing get link => const Parsing._();

  /// Invalid Encryption.
  Parsing get encryption => const Parsing._();

  /// Invalid License Document Signature.
  Parsing get signature => const Parsing._();

// /// Invalid URL for link with [rel].
  Url url(String rel) => Url._(rel);
}

class Url extends Parsing {
  final String rel;

  const Url._(this.rel) : super._();
}

/// Errors while reading or writing a LCP container (LCPL, EPUB, LCPDF, etc.)
class ContainerException extends LcpException {
  final String path;
  const ContainerException._(String userMessageId, {this.path})
      : super(userMessageId);

  /// Can't access the container, it's format is wrong.
  ContainerException get openFailed =>
      const ContainerException._("r2_lcp_exception_container_open_failed");

  /// The file at given relative path is not found in the Container.
  ContainerException fileNotFound(String path) =>
      ContainerException._("r2_lcp_exception_container_file_not_found",
          path: path);

  /// Can't read the file at given relative path in the Container.
  ContainerException readFailed(String path) =>
      ContainerException._("r2_lcp_exception_container_read_failed",
          path: path);

  /// Can't write the file at given relative path in the Container.
  ContainerException writeFailed(String path) =>
      ContainerException._("r2_lcp_exception_container_write_failed",
          path: path);
}

/// An error occurred while checking the integrity of the License, it can't be retrieved.
class LicenseIntegrity extends LcpException {
  const LicenseIntegrity._(String userMessageId) : super(userMessageId);

  LicenseIntegrity get certificateRevoked => const LicenseIntegrity._(
      "r2_lcp_exception_license_integrity_certificate_revoked");

  LicenseIntegrity get invalidCertificateSignature => const LicenseIntegrity._(
      "r2_lcp_exception_license_integrity_invalid_certificate_signature");

  LicenseIntegrity get invalidLicenseSignatureDate => const LicenseIntegrity._(
      "r2_lcp_exception_license_integrity_invalid_license_signature_date");

  LicenseIntegrity get invalidLicenseSignature => const LicenseIntegrity._(
      "r2_lcp_exception_license_integrity_invalid_license_signature");

  LicenseIntegrity get invalidUserKeyCheck => const LicenseIntegrity._(
      "r2_lcp_exception_license_integrity_invalid_user_key_check");
}

class Decryption extends LcpException {
  const Decryption._(String userMessageId) : super(userMessageId);

  Decryption get contentKeyDecryptError => const Decryption._(
      "r2_lcp_exception_decryption_content_key_decrypt_error");

  Decryption get contentDecryptError =>
      const Decryption._("r2_lcp_exception_decryption_content_decrypt_error");
}
