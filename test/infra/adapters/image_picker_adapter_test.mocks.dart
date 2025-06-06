// Mocks generated by Mockito 5.4.5 from annotations
// in minitok_test/test/infra/adapters/image_picker_adapter_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;
import 'dart:convert' as _i6;
import 'dart:typed_data' as _i7;

import 'package:image_picker/image_picker.dart' as _i3;
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart'
    as _i2;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i5;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: must_be_immutable
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeLostDataResponse_0 extends _i1.SmartFake
    implements _i2.LostDataResponse {
  _FakeLostDataResponse_0(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeDateTime_1 extends _i1.SmartFake implements DateTime {
  _FakeDateTime_1(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

/// A class which mocks [ImagePicker].
///
/// See the documentation for Mockito's code generation for more information.
class MockImagePicker extends _i1.Mock implements _i3.ImagePicker {
  MockImagePicker() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<_i2.XFile?> pickImage({
    required _i2.ImageSource? source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    _i2.CameraDevice? preferredCameraDevice = _i2.CameraDevice.rear,
    bool? requestFullMetadata = true,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#pickImage, [], {
              #source: source,
              #maxWidth: maxWidth,
              #maxHeight: maxHeight,
              #imageQuality: imageQuality,
              #preferredCameraDevice: preferredCameraDevice,
              #requestFullMetadata: requestFullMetadata,
            }),
            returnValue: _i4.Future<_i2.XFile?>.value(),
          )
          as _i4.Future<_i2.XFile?>);

  @override
  _i4.Future<List<_i2.XFile>> pickMultiImage({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    int? limit,
    bool? requestFullMetadata = true,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#pickMultiImage, [], {
              #maxWidth: maxWidth,
              #maxHeight: maxHeight,
              #imageQuality: imageQuality,
              #limit: limit,
              #requestFullMetadata: requestFullMetadata,
            }),
            returnValue: _i4.Future<List<_i2.XFile>>.value(<_i2.XFile>[]),
          )
          as _i4.Future<List<_i2.XFile>>);

  @override
  _i4.Future<_i2.XFile?> pickMedia({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    bool? requestFullMetadata = true,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#pickMedia, [], {
              #maxWidth: maxWidth,
              #maxHeight: maxHeight,
              #imageQuality: imageQuality,
              #requestFullMetadata: requestFullMetadata,
            }),
            returnValue: _i4.Future<_i2.XFile?>.value(),
          )
          as _i4.Future<_i2.XFile?>);

  @override
  _i4.Future<List<_i2.XFile>> pickMultipleMedia({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    int? limit,
    bool? requestFullMetadata = true,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#pickMultipleMedia, [], {
              #maxWidth: maxWidth,
              #maxHeight: maxHeight,
              #imageQuality: imageQuality,
              #limit: limit,
              #requestFullMetadata: requestFullMetadata,
            }),
            returnValue: _i4.Future<List<_i2.XFile>>.value(<_i2.XFile>[]),
          )
          as _i4.Future<List<_i2.XFile>>);

  @override
  _i4.Future<_i2.XFile?> pickVideo({
    required _i2.ImageSource? source,
    _i2.CameraDevice? preferredCameraDevice = _i2.CameraDevice.rear,
    Duration? maxDuration,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#pickVideo, [], {
              #source: source,
              #preferredCameraDevice: preferredCameraDevice,
              #maxDuration: maxDuration,
            }),
            returnValue: _i4.Future<_i2.XFile?>.value(),
          )
          as _i4.Future<_i2.XFile?>);

  @override
  _i4.Future<_i2.LostDataResponse> retrieveLostData() =>
      (super.noSuchMethod(
            Invocation.method(#retrieveLostData, []),
            returnValue: _i4.Future<_i2.LostDataResponse>.value(
              _FakeLostDataResponse_0(
                this,
                Invocation.method(#retrieveLostData, []),
              ),
            ),
          )
          as _i4.Future<_i2.LostDataResponse>);

  @override
  bool supportsImageSource(_i2.ImageSource? source) =>
      (super.noSuchMethod(
            Invocation.method(#supportsImageSource, [source]),
            returnValue: false,
          )
          as bool);
}

/// A class which mocks [XFile].
///
/// See the documentation for Mockito's code generation for more information.
class MockXFile extends _i1.Mock implements _i2.XFile {
  MockXFile() {
    _i1.throwOnMissingStub(this);
  }

  @override
  String get path =>
      (super.noSuchMethod(
            Invocation.getter(#path),
            returnValue: _i5.dummyValue<String>(this, Invocation.getter(#path)),
          )
          as String);

  @override
  String get name =>
      (super.noSuchMethod(
            Invocation.getter(#name),
            returnValue: _i5.dummyValue<String>(this, Invocation.getter(#name)),
          )
          as String);

  @override
  _i4.Future<void> saveTo(String? path) =>
      (super.noSuchMethod(
            Invocation.method(#saveTo, [path]),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  _i4.Future<int> length() =>
      (super.noSuchMethod(
            Invocation.method(#length, []),
            returnValue: _i4.Future<int>.value(0),
          )
          as _i4.Future<int>);

  @override
  _i4.Future<String> readAsString({
    _i6.Encoding? encoding = const _i6.Utf8Codec(),
  }) =>
      (super.noSuchMethod(
            Invocation.method(#readAsString, [], {#encoding: encoding}),
            returnValue: _i4.Future<String>.value(
              _i5.dummyValue<String>(
                this,
                Invocation.method(#readAsString, [], {#encoding: encoding}),
              ),
            ),
          )
          as _i4.Future<String>);

  @override
  _i4.Future<_i7.Uint8List> readAsBytes() =>
      (super.noSuchMethod(
            Invocation.method(#readAsBytes, []),
            returnValue: _i4.Future<_i7.Uint8List>.value(_i7.Uint8List(0)),
          )
          as _i4.Future<_i7.Uint8List>);

  @override
  _i4.Stream<_i7.Uint8List> openRead([int? start, int? end]) =>
      (super.noSuchMethod(
            Invocation.method(#openRead, [start, end]),
            returnValue: _i4.Stream<_i7.Uint8List>.empty(),
          )
          as _i4.Stream<_i7.Uint8List>);

  @override
  _i4.Future<DateTime> lastModified() =>
      (super.noSuchMethod(
            Invocation.method(#lastModified, []),
            returnValue: _i4.Future<DateTime>.value(
              _FakeDateTime_1(this, Invocation.method(#lastModified, [])),
            ),
          )
          as _i4.Future<DateTime>);
}
