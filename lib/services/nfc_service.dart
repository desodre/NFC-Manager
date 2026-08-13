import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:nfc_manager/ndef_record.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager_android.dart';

import '../models/tag_action.dart';
import '../models/tag_result.dart';

class NfcService {
  Completer<TagResult>? _pending;

  Future<NfcAvailability> availability() =>
      NfcManager.instance.checkAvailability();

  Future<TagResult> run(
    NfcAction action, {
    String? text,
    bool asUrl = false,
  }) async {
    if (await availability() != NfcAvailability.enabled) {
      throw Exception(
        'NFC não está disponível ou está desativado neste dispositivo.',
      );
    }
    final completer = Completer<TagResult>();
    _pending = completer;
    try {
      await NfcManager.instance.startSession(
        pollingOptions: {NfcPollingOption.iso14443, NfcPollingOption.iso15693},
        noPlatformSoundsAndroid: true,
        onDiscovered: (tag) async {
          try {
            final ndef = NdefAndroid.from(tag);
            if (ndef == null)
              throw Exception('Esta tag não possui suporte a NDEF.');
            final message = await ndef.getNdefMessage();
            final records =
                message?.records.map(_decodeRecord).toList() ?? <String>[];
            if (action == NfcAction.read) {
              completer.complete(
                TagResult(
                  type: ndef.type,
                  capacity: ndef.maxSize,
                  writable: ndef.isWritable,
                  records: records,
                ),
              );
            } else {
              if (!ndef.isWritable)
                throw Exception('Esta tag é somente leitura.');
              final newMessage = action == NfcAction.clean
                  ? NdefMessage(records: [])
                  : NdefMessage(
                      records: [_makeRecord(text ?? '', asUrl: asUrl)],
                    );
              if (newMessage.byteLength > ndef.maxSize)
                throw Exception('O conteúdo excede a capacidade da tag.');
              await ndef.writeNdefMessage(newMessage);
              completer.complete(
                TagResult(
                  type: ndef.type,
                  capacity: ndef.maxSize,
                  writable: ndef.isWritable,
                  records: action == NfcAction.clean ? [] : [text ?? ''],
                ),
              );
            }
          } catch (error, stackTrace) {
            if (!completer.isCompleted)
              completer.completeError(error, stackTrace);
          } finally {
            await NfcManager.instance.stopSession();
          }
        },
      );
      return await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () async {
          await NfcManager.instance.stopSession();
          throw Exception('Nenhuma tag foi detectada em 5 segundos.');
        },
      );
    } finally {
      if (identical(_pending, completer)) _pending = null;
    }
  }

  Future<void> cancel() async {
    await NfcManager.instance.stopSession();
    if (_pending != null && !_pending!.isCompleted)
      _pending!.completeError(Exception('Operação cancelada.'));
  }

  static NdefRecord _makeRecord(String value, {required bool asUrl}) {
    if (asUrl) {
      final uri = Uri.parse(value);
      const prefixes = ['http://www.', 'https://www.', 'http://', 'https://'];
      var prefix = 0;
      var rest = value;
      for (var i = 0; i < prefixes.length; i++) {
        if (value.startsWith(prefixes[i])) {
          prefix = i + 1;
          rest = value.substring(prefixes[i].length);
          break;
        }
      }
      if (!uri.hasScheme)
        throw Exception('Informe uma URL válida, incluindo https://.');
      return NdefRecord(
        typeNameFormat: TypeNameFormat.wellKnown,
        type: Uint8List.fromList([0x55]),
        identifier: Uint8List(0),
        payload: Uint8List.fromList([prefix, ...utf8.encode(rest)]),
      );
    }
    return NdefRecord(
      typeNameFormat: TypeNameFormat.wellKnown,
      type: Uint8List.fromList([0x54]),
      identifier: Uint8List(0),
      payload: Uint8List.fromList([0x02, 0x70, 0x74, ...utf8.encode(value)]),
    );
  }

  static String _decodeRecord(NdefRecord record) {
    if (record.typeNameFormat == TypeNameFormat.wellKnown &&
        record.type.length == 1 &&
        record.type.first == 0x54 &&
        record.payload.length >= 3) {
      return utf8.decode(
        record.payload.sublist((record.payload[0] & 0x3f) + 1),
        allowMalformed: true,
      );
    }
    if (record.typeNameFormat == TypeNameFormat.wellKnown &&
        record.type.length == 1 &&
        record.type.first == 0x55 &&
        record.payload.isNotEmpty) {
      const prefixes = [
        '',
        'http://www.',
        'https://www.',
        'http://',
        'https://',
      ];
      return '${prefixes[record.payload.first]}${utf8.decode(record.payload.sublist(1), allowMalformed: true)}';
    }
    return 'Registro ${record.typeNameFormat.name}: ${base64Encode(record.payload)}';
  }
}
