// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserInfo {

 String get id; String get name; String get email; String get role; String get dashboard;@JsonKey(name: 'tenant_id') String? get tenantId;@JsonKey(name: 'tenant_code') String? get tenantCode;@JsonKey(name: 'tenant_name') String? get tenantName; List<String> get permissions;
/// Create a copy of UserInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserInfoCopyWith<UserInfo> get copyWith => _$UserInfoCopyWithImpl<UserInfo>(this as UserInfo, _$identity);

  /// Serializes this UserInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.role, role) || other.role == role)&&(identical(other.dashboard, dashboard) || other.dashboard == dashboard)&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.tenantCode, tenantCode) || other.tenantCode == tenantCode)&&(identical(other.tenantName, tenantName) || other.tenantName == tenantName)&&const DeepCollectionEquality().equals(other.permissions, permissions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,email,role,dashboard,tenantId,tenantCode,tenantName,const DeepCollectionEquality().hash(permissions));

@override
String toString() {
  return 'UserInfo(id: $id, name: $name, email: $email, role: $role, dashboard: $dashboard, tenantId: $tenantId, tenantCode: $tenantCode, tenantName: $tenantName, permissions: $permissions)';
}


}

/// @nodoc
abstract mixin class $UserInfoCopyWith<$Res>  {
  factory $UserInfoCopyWith(UserInfo value, $Res Function(UserInfo) _then) = _$UserInfoCopyWithImpl;
@useResult
$Res call({
 String id, String name, String email, String role, String dashboard,@JsonKey(name: 'tenant_id') String? tenantId,@JsonKey(name: 'tenant_code') String? tenantCode,@JsonKey(name: 'tenant_name') String? tenantName, List<String> permissions
});




}
/// @nodoc
class _$UserInfoCopyWithImpl<$Res>
    implements $UserInfoCopyWith<$Res> {
  _$UserInfoCopyWithImpl(this._self, this._then);

  final UserInfo _self;
  final $Res Function(UserInfo) _then;

/// Create a copy of UserInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? email = null,Object? role = null,Object? dashboard = null,Object? tenantId = freezed,Object? tenantCode = freezed,Object? tenantName = freezed,Object? permissions = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,dashboard: null == dashboard ? _self.dashboard : dashboard // ignore: cast_nullable_to_non_nullable
as String,tenantId: freezed == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String?,tenantCode: freezed == tenantCode ? _self.tenantCode : tenantCode // ignore: cast_nullable_to_non_nullable
as String?,tenantName: freezed == tenantName ? _self.tenantName : tenantName // ignore: cast_nullable_to_non_nullable
as String?,permissions: null == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [UserInfo].
extension UserInfoPatterns on UserInfo {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserInfo() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserInfo value)  $default,){
final _that = this;
switch (_that) {
case _UserInfo():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserInfo value)?  $default,){
final _that = this;
switch (_that) {
case _UserInfo() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String email,  String role,  String dashboard, @JsonKey(name: 'tenant_id')  String? tenantId, @JsonKey(name: 'tenant_code')  String? tenantCode, @JsonKey(name: 'tenant_name')  String? tenantName,  List<String> permissions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserInfo() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.role,_that.dashboard,_that.tenantId,_that.tenantCode,_that.tenantName,_that.permissions);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String email,  String role,  String dashboard, @JsonKey(name: 'tenant_id')  String? tenantId, @JsonKey(name: 'tenant_code')  String? tenantCode, @JsonKey(name: 'tenant_name')  String? tenantName,  List<String> permissions)  $default,) {final _that = this;
switch (_that) {
case _UserInfo():
return $default(_that.id,_that.name,_that.email,_that.role,_that.dashboard,_that.tenantId,_that.tenantCode,_that.tenantName,_that.permissions);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String email,  String role,  String dashboard, @JsonKey(name: 'tenant_id')  String? tenantId, @JsonKey(name: 'tenant_code')  String? tenantCode, @JsonKey(name: 'tenant_name')  String? tenantName,  List<String> permissions)?  $default,) {final _that = this;
switch (_that) {
case _UserInfo() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.role,_that.dashboard,_that.tenantId,_that.tenantCode,_that.tenantName,_that.permissions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserInfo implements UserInfo {
  const _UserInfo({required this.id, required this.name, required this.email, required this.role, required this.dashboard, @JsonKey(name: 'tenant_id') this.tenantId, @JsonKey(name: 'tenant_code') this.tenantCode, @JsonKey(name: 'tenant_name') this.tenantName, required this.permissions});
  factory _UserInfo.fromJson(Map<String, dynamic> json) => _$UserInfoFromJson(json);

@override final  String id;
@override final  String name;
@override final  String email;
@override final  String role;
@override final  String dashboard;
@override@JsonKey(name: 'tenant_id') final  String? tenantId;
@override@JsonKey(name: 'tenant_code') final  String? tenantCode;
@override@JsonKey(name: 'tenant_name') final  String? tenantName;
@override final  List<String> permissions;

/// Create a copy of UserInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserInfoCopyWith<_UserInfo> get copyWith => __$UserInfoCopyWithImpl<_UserInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.role, role) || other.role == role)&&(identical(other.dashboard, dashboard) || other.dashboard == dashboard)&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.tenantCode, tenantCode) || other.tenantCode == tenantCode)&&(identical(other.tenantName, tenantName) || other.tenantName == tenantName)&&const DeepCollectionEquality().equals(other.permissions, permissions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,email,role,dashboard,tenantId,tenantCode,tenantName,const DeepCollectionEquality().hash(permissions));

@override
String toString() {
  return 'UserInfo(id: $id, name: $name, email: $email, role: $role, dashboard: $dashboard, tenantId: $tenantId, tenantCode: $tenantCode, tenantName: $tenantName, permissions: $permissions)';
}


}

/// @nodoc
abstract mixin class _$UserInfoCopyWith<$Res> implements $UserInfoCopyWith<$Res> {
  factory _$UserInfoCopyWith(_UserInfo value, $Res Function(_UserInfo) _then) = __$UserInfoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String email, String role, String dashboard,@JsonKey(name: 'tenant_id') String? tenantId,@JsonKey(name: 'tenant_code') String? tenantCode,@JsonKey(name: 'tenant_name') String? tenantName, List<String> permissions
});




}
/// @nodoc
class __$UserInfoCopyWithImpl<$Res>
    implements _$UserInfoCopyWith<$Res> {
  __$UserInfoCopyWithImpl(this._self, this._then);

  final _UserInfo _self;
  final $Res Function(_UserInfo) _then;

/// Create a copy of UserInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? email = null,Object? role = null,Object? dashboard = null,Object? tenantId = freezed,Object? tenantCode = freezed,Object? tenantName = freezed,Object? permissions = null,}) {
  return _then(_UserInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,dashboard: null == dashboard ? _self.dashboard : dashboard // ignore: cast_nullable_to_non_nullable
as String,tenantId: freezed == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String?,tenantCode: freezed == tenantCode ? _self.tenantCode : tenantCode // ignore: cast_nullable_to_non_nullable
as String?,tenantName: freezed == tenantName ? _self.tenantName : tenantName // ignore: cast_nullable_to_non_nullable
as String?,permissions: null == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$Session {

@JsonKey(name: 'access_token') String get accessToken;@JsonKey(name: 'refresh_token') String get refreshToken;@JsonKey(name: 'token_type') String get tokenType;@JsonKey(name: 'expires_in') int get expiresIn; UserInfo get user;
/// Create a copy of Session
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionCopyWith<Session> get copyWith => _$SessionCopyWithImpl<Session>(this as Session, _$identity);

  /// Serializes this Session to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Session&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken)&&(identical(other.tokenType, tokenType) || other.tokenType == tokenType)&&(identical(other.expiresIn, expiresIn) || other.expiresIn == expiresIn)&&(identical(other.user, user) || other.user == user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accessToken,refreshToken,tokenType,expiresIn,user);

@override
String toString() {
  return 'Session(accessToken: $accessToken, refreshToken: $refreshToken, tokenType: $tokenType, expiresIn: $expiresIn, user: $user)';
}


}

/// @nodoc
abstract mixin class $SessionCopyWith<$Res>  {
  factory $SessionCopyWith(Session value, $Res Function(Session) _then) = _$SessionCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'access_token') String accessToken,@JsonKey(name: 'refresh_token') String refreshToken,@JsonKey(name: 'token_type') String tokenType,@JsonKey(name: 'expires_in') int expiresIn, UserInfo user
});


$UserInfoCopyWith<$Res> get user;

}
/// @nodoc
class _$SessionCopyWithImpl<$Res>
    implements $SessionCopyWith<$Res> {
  _$SessionCopyWithImpl(this._self, this._then);

  final Session _self;
  final $Res Function(Session) _then;

/// Create a copy of Session
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accessToken = null,Object? refreshToken = null,Object? tokenType = null,Object? expiresIn = null,Object? user = null,}) {
  return _then(_self.copyWith(
accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,tokenType: null == tokenType ? _self.tokenType : tokenType // ignore: cast_nullable_to_non_nullable
as String,expiresIn: null == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserInfo,
  ));
}
/// Create a copy of Session
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserInfoCopyWith<$Res> get user {
  
  return $UserInfoCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [Session].
extension SessionPatterns on Session {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Session value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Session() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Session value)  $default,){
final _that = this;
switch (_that) {
case _Session():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Session value)?  $default,){
final _that = this;
switch (_that) {
case _Session() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'access_token')  String accessToken, @JsonKey(name: 'refresh_token')  String refreshToken, @JsonKey(name: 'token_type')  String tokenType, @JsonKey(name: 'expires_in')  int expiresIn,  UserInfo user)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Session() when $default != null:
return $default(_that.accessToken,_that.refreshToken,_that.tokenType,_that.expiresIn,_that.user);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'access_token')  String accessToken, @JsonKey(name: 'refresh_token')  String refreshToken, @JsonKey(name: 'token_type')  String tokenType, @JsonKey(name: 'expires_in')  int expiresIn,  UserInfo user)  $default,) {final _that = this;
switch (_that) {
case _Session():
return $default(_that.accessToken,_that.refreshToken,_that.tokenType,_that.expiresIn,_that.user);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'access_token')  String accessToken, @JsonKey(name: 'refresh_token')  String refreshToken, @JsonKey(name: 'token_type')  String tokenType, @JsonKey(name: 'expires_in')  int expiresIn,  UserInfo user)?  $default,) {final _that = this;
switch (_that) {
case _Session() when $default != null:
return $default(_that.accessToken,_that.refreshToken,_that.tokenType,_that.expiresIn,_that.user);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Session implements Session {
  const _Session({@JsonKey(name: 'access_token') required this.accessToken, @JsonKey(name: 'refresh_token') required this.refreshToken, @JsonKey(name: 'token_type') required this.tokenType, @JsonKey(name: 'expires_in') required this.expiresIn, required this.user});
  factory _Session.fromJson(Map<String, dynamic> json) => _$SessionFromJson(json);

@override@JsonKey(name: 'access_token') final  String accessToken;
@override@JsonKey(name: 'refresh_token') final  String refreshToken;
@override@JsonKey(name: 'token_type') final  String tokenType;
@override@JsonKey(name: 'expires_in') final  int expiresIn;
@override final  UserInfo user;

/// Create a copy of Session
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionCopyWith<_Session> get copyWith => __$SessionCopyWithImpl<_Session>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SessionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Session&&(identical(other.accessToken, accessToken) || other.accessToken == accessToken)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken)&&(identical(other.tokenType, tokenType) || other.tokenType == tokenType)&&(identical(other.expiresIn, expiresIn) || other.expiresIn == expiresIn)&&(identical(other.user, user) || other.user == user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accessToken,refreshToken,tokenType,expiresIn,user);

@override
String toString() {
  return 'Session(accessToken: $accessToken, refreshToken: $refreshToken, tokenType: $tokenType, expiresIn: $expiresIn, user: $user)';
}


}

/// @nodoc
abstract mixin class _$SessionCopyWith<$Res> implements $SessionCopyWith<$Res> {
  factory _$SessionCopyWith(_Session value, $Res Function(_Session) _then) = __$SessionCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'access_token') String accessToken,@JsonKey(name: 'refresh_token') String refreshToken,@JsonKey(name: 'token_type') String tokenType,@JsonKey(name: 'expires_in') int expiresIn, UserInfo user
});


@override $UserInfoCopyWith<$Res> get user;

}
/// @nodoc
class __$SessionCopyWithImpl<$Res>
    implements _$SessionCopyWith<$Res> {
  __$SessionCopyWithImpl(this._self, this._then);

  final _Session _self;
  final $Res Function(_Session) _then;

/// Create a copy of Session
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accessToken = null,Object? refreshToken = null,Object? tokenType = null,Object? expiresIn = null,Object? user = null,}) {
  return _then(_Session(
accessToken: null == accessToken ? _self.accessToken : accessToken // ignore: cast_nullable_to_non_nullable
as String,refreshToken: null == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String,tokenType: null == tokenType ? _self.tokenType : tokenType // ignore: cast_nullable_to_non_nullable
as String,expiresIn: null == expiresIn ? _self.expiresIn : expiresIn // ignore: cast_nullable_to_non_nullable
as int,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserInfo,
  ));
}

/// Create a copy of Session
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserInfoCopyWith<$Res> get user {
  
  return $UserInfoCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// @nodoc
mixin _$PageResult {

 List<Map<String, dynamic>> get items; int get total; int get page;@JsonKey(name: 'page_size') int get pageSize;
/// Create a copy of PageResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PageResultCopyWith<PageResult> get copyWith => _$PageResultCopyWithImpl<PageResult>(this as PageResult, _$identity);

  /// Serializes this PageResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PageResult&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),total,page,pageSize);

@override
String toString() {
  return 'PageResult(items: $items, total: $total, page: $page, pageSize: $pageSize)';
}


}

/// @nodoc
abstract mixin class $PageResultCopyWith<$Res>  {
  factory $PageResultCopyWith(PageResult value, $Res Function(PageResult) _then) = _$PageResultCopyWithImpl;
@useResult
$Res call({
 List<Map<String, dynamic>> items, int total, int page,@JsonKey(name: 'page_size') int pageSize
});




}
/// @nodoc
class _$PageResultCopyWithImpl<$Res>
    implements $PageResultCopyWith<$Res> {
  _$PageResultCopyWithImpl(this._self, this._then);

  final PageResult _self;
  final $Res Function(PageResult) _then;

/// Create a copy of PageResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? total = null,Object? page = null,Object? pageSize = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PageResult].
extension PageResultPatterns on PageResult {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PageResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PageResult() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PageResult value)  $default,){
final _that = this;
switch (_that) {
case _PageResult():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PageResult value)?  $default,){
final _that = this;
switch (_that) {
case _PageResult() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Map<String, dynamic>> items,  int total,  int page, @JsonKey(name: 'page_size')  int pageSize)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PageResult() when $default != null:
return $default(_that.items,_that.total,_that.page,_that.pageSize);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Map<String, dynamic>> items,  int total,  int page, @JsonKey(name: 'page_size')  int pageSize)  $default,) {final _that = this;
switch (_that) {
case _PageResult():
return $default(_that.items,_that.total,_that.page,_that.pageSize);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Map<String, dynamic>> items,  int total,  int page, @JsonKey(name: 'page_size')  int pageSize)?  $default,) {final _that = this;
switch (_that) {
case _PageResult() when $default != null:
return $default(_that.items,_that.total,_that.page,_that.pageSize);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PageResult implements PageResult {
  const _PageResult({required this.items, this.total = 0, this.page = 1, @JsonKey(name: 'page_size') this.pageSize = 20});
  factory _PageResult.fromJson(Map<String, dynamic> json) => _$PageResultFromJson(json);

@override final  List<Map<String, dynamic>> items;
@override@JsonKey() final  int total;
@override@JsonKey() final  int page;
@override@JsonKey(name: 'page_size') final  int pageSize;

/// Create a copy of PageResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PageResultCopyWith<_PageResult> get copyWith => __$PageResultCopyWithImpl<_PageResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PageResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PageResult&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),total,page,pageSize);

@override
String toString() {
  return 'PageResult(items: $items, total: $total, page: $page, pageSize: $pageSize)';
}


}

/// @nodoc
abstract mixin class _$PageResultCopyWith<$Res> implements $PageResultCopyWith<$Res> {
  factory _$PageResultCopyWith(_PageResult value, $Res Function(_PageResult) _then) = __$PageResultCopyWithImpl;
@override @useResult
$Res call({
 List<Map<String, dynamic>> items, int total, int page,@JsonKey(name: 'page_size') int pageSize
});




}
/// @nodoc
class __$PageResultCopyWithImpl<$Res>
    implements _$PageResultCopyWith<$Res> {
  __$PageResultCopyWithImpl(this._self, this._then);

  final _PageResult _self;
  final $Res Function(_PageResult) _then;

/// Create a copy of PageResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? total = null,Object? page = null,Object? pageSize = null,}) {
  return _then(_PageResult(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$TenantSummary {

 String get id; String get code; String get name;@JsonKey(name: 'owner_name') String get ownerName;@JsonKey(name: 'contact_number') String get contactNumber; String get email; String get city; String get status;@JsonKey(name: 'user_count') int get userCount;@JsonKey(name: 'member_count') int get memberCount;@JsonKey(name: 'whatsapp_status') String get whatsappStatus;
/// Create a copy of TenantSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TenantSummaryCopyWith<TenantSummary> get copyWith => _$TenantSummaryCopyWithImpl<TenantSummary>(this as TenantSummary, _$identity);

  /// Serializes this TenantSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TenantSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.contactNumber, contactNumber) || other.contactNumber == contactNumber)&&(identical(other.email, email) || other.email == email)&&(identical(other.city, city) || other.city == city)&&(identical(other.status, status) || other.status == status)&&(identical(other.userCount, userCount) || other.userCount == userCount)&&(identical(other.memberCount, memberCount) || other.memberCount == memberCount)&&(identical(other.whatsappStatus, whatsappStatus) || other.whatsappStatus == whatsappStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,code,name,ownerName,contactNumber,email,city,status,userCount,memberCount,whatsappStatus);

@override
String toString() {
  return 'TenantSummary(id: $id, code: $code, name: $name, ownerName: $ownerName, contactNumber: $contactNumber, email: $email, city: $city, status: $status, userCount: $userCount, memberCount: $memberCount, whatsappStatus: $whatsappStatus)';
}


}

/// @nodoc
abstract mixin class $TenantSummaryCopyWith<$Res>  {
  factory $TenantSummaryCopyWith(TenantSummary value, $Res Function(TenantSummary) _then) = _$TenantSummaryCopyWithImpl;
@useResult
$Res call({
 String id, String code, String name,@JsonKey(name: 'owner_name') String ownerName,@JsonKey(name: 'contact_number') String contactNumber, String email, String city, String status,@JsonKey(name: 'user_count') int userCount,@JsonKey(name: 'member_count') int memberCount,@JsonKey(name: 'whatsapp_status') String whatsappStatus
});




}
/// @nodoc
class _$TenantSummaryCopyWithImpl<$Res>
    implements $TenantSummaryCopyWith<$Res> {
  _$TenantSummaryCopyWithImpl(this._self, this._then);

  final TenantSummary _self;
  final $Res Function(TenantSummary) _then;

/// Create a copy of TenantSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = null,Object? name = null,Object? ownerName = null,Object? contactNumber = null,Object? email = null,Object? city = null,Object? status = null,Object? userCount = null,Object? memberCount = null,Object? whatsappStatus = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,contactNumber: null == contactNumber ? _self.contactNumber : contactNumber // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,userCount: null == userCount ? _self.userCount : userCount // ignore: cast_nullable_to_non_nullable
as int,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,whatsappStatus: null == whatsappStatus ? _self.whatsappStatus : whatsappStatus // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TenantSummary].
extension TenantSummaryPatterns on TenantSummary {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TenantSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TenantSummary() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TenantSummary value)  $default,){
final _that = this;
switch (_that) {
case _TenantSummary():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TenantSummary value)?  $default,){
final _that = this;
switch (_that) {
case _TenantSummary() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String code,  String name, @JsonKey(name: 'owner_name')  String ownerName, @JsonKey(name: 'contact_number')  String contactNumber,  String email,  String city,  String status, @JsonKey(name: 'user_count')  int userCount, @JsonKey(name: 'member_count')  int memberCount, @JsonKey(name: 'whatsapp_status')  String whatsappStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TenantSummary() when $default != null:
return $default(_that.id,_that.code,_that.name,_that.ownerName,_that.contactNumber,_that.email,_that.city,_that.status,_that.userCount,_that.memberCount,_that.whatsappStatus);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String code,  String name, @JsonKey(name: 'owner_name')  String ownerName, @JsonKey(name: 'contact_number')  String contactNumber,  String email,  String city,  String status, @JsonKey(name: 'user_count')  int userCount, @JsonKey(name: 'member_count')  int memberCount, @JsonKey(name: 'whatsapp_status')  String whatsappStatus)  $default,) {final _that = this;
switch (_that) {
case _TenantSummary():
return $default(_that.id,_that.code,_that.name,_that.ownerName,_that.contactNumber,_that.email,_that.city,_that.status,_that.userCount,_that.memberCount,_that.whatsappStatus);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String code,  String name, @JsonKey(name: 'owner_name')  String ownerName, @JsonKey(name: 'contact_number')  String contactNumber,  String email,  String city,  String status, @JsonKey(name: 'user_count')  int userCount, @JsonKey(name: 'member_count')  int memberCount, @JsonKey(name: 'whatsapp_status')  String whatsappStatus)?  $default,) {final _that = this;
switch (_that) {
case _TenantSummary() when $default != null:
return $default(_that.id,_that.code,_that.name,_that.ownerName,_that.contactNumber,_that.email,_that.city,_that.status,_that.userCount,_that.memberCount,_that.whatsappStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TenantSummary implements TenantSummary {
  const _TenantSummary({required this.id, required this.code, required this.name, @JsonKey(name: 'owner_name') this.ownerName = '', @JsonKey(name: 'contact_number') this.contactNumber = '', this.email = '', this.city = '', this.status = 'ACTIVE', @JsonKey(name: 'user_count') this.userCount = 0, @JsonKey(name: 'member_count') this.memberCount = 0, @JsonKey(name: 'whatsapp_status') this.whatsappStatus = 'NOT_CONNECTED'});
  factory _TenantSummary.fromJson(Map<String, dynamic> json) => _$TenantSummaryFromJson(json);

@override final  String id;
@override final  String code;
@override final  String name;
@override@JsonKey(name: 'owner_name') final  String ownerName;
@override@JsonKey(name: 'contact_number') final  String contactNumber;
@override@JsonKey() final  String email;
@override@JsonKey() final  String city;
@override@JsonKey() final  String status;
@override@JsonKey(name: 'user_count') final  int userCount;
@override@JsonKey(name: 'member_count') final  int memberCount;
@override@JsonKey(name: 'whatsapp_status') final  String whatsappStatus;

/// Create a copy of TenantSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TenantSummaryCopyWith<_TenantSummary> get copyWith => __$TenantSummaryCopyWithImpl<_TenantSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TenantSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TenantSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.ownerName, ownerName) || other.ownerName == ownerName)&&(identical(other.contactNumber, contactNumber) || other.contactNumber == contactNumber)&&(identical(other.email, email) || other.email == email)&&(identical(other.city, city) || other.city == city)&&(identical(other.status, status) || other.status == status)&&(identical(other.userCount, userCount) || other.userCount == userCount)&&(identical(other.memberCount, memberCount) || other.memberCount == memberCount)&&(identical(other.whatsappStatus, whatsappStatus) || other.whatsappStatus == whatsappStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,code,name,ownerName,contactNumber,email,city,status,userCount,memberCount,whatsappStatus);

@override
String toString() {
  return 'TenantSummary(id: $id, code: $code, name: $name, ownerName: $ownerName, contactNumber: $contactNumber, email: $email, city: $city, status: $status, userCount: $userCount, memberCount: $memberCount, whatsappStatus: $whatsappStatus)';
}


}

/// @nodoc
abstract mixin class _$TenantSummaryCopyWith<$Res> implements $TenantSummaryCopyWith<$Res> {
  factory _$TenantSummaryCopyWith(_TenantSummary value, $Res Function(_TenantSummary) _then) = __$TenantSummaryCopyWithImpl;
@override @useResult
$Res call({
 String id, String code, String name,@JsonKey(name: 'owner_name') String ownerName,@JsonKey(name: 'contact_number') String contactNumber, String email, String city, String status,@JsonKey(name: 'user_count') int userCount,@JsonKey(name: 'member_count') int memberCount,@JsonKey(name: 'whatsapp_status') String whatsappStatus
});




}
/// @nodoc
class __$TenantSummaryCopyWithImpl<$Res>
    implements _$TenantSummaryCopyWith<$Res> {
  __$TenantSummaryCopyWithImpl(this._self, this._then);

  final _TenantSummary _self;
  final $Res Function(_TenantSummary) _then;

/// Create a copy of TenantSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = null,Object? name = null,Object? ownerName = null,Object? contactNumber = null,Object? email = null,Object? city = null,Object? status = null,Object? userCount = null,Object? memberCount = null,Object? whatsappStatus = null,}) {
  return _then(_TenantSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,ownerName: null == ownerName ? _self.ownerName : ownerName // ignore: cast_nullable_to_non_nullable
as String,contactNumber: null == contactNumber ? _self.contactNumber : contactNumber // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,userCount: null == userCount ? _self.userCount : userCount // ignore: cast_nullable_to_non_nullable
as int,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,whatsappStatus: null == whatsappStatus ? _self.whatsappStatus : whatsappStatus // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$PlatformStats {

@JsonKey(name: 'total_tenants') int get totalTenants;@JsonKey(name: 'active_tenants') int get activeTenants;@JsonKey(name: 'total_users') int get totalUsers;@JsonKey(name: 'total_members') int get totalMembers;@JsonKey(name: 'whatsapp_connected') int get whatsappConnected;@JsonKey(name: 'messages_last_30_days') int get messagesLast30Days;
/// Create a copy of PlatformStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlatformStatsCopyWith<PlatformStats> get copyWith => _$PlatformStatsCopyWithImpl<PlatformStats>(this as PlatformStats, _$identity);

  /// Serializes this PlatformStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlatformStats&&(identical(other.totalTenants, totalTenants) || other.totalTenants == totalTenants)&&(identical(other.activeTenants, activeTenants) || other.activeTenants == activeTenants)&&(identical(other.totalUsers, totalUsers) || other.totalUsers == totalUsers)&&(identical(other.totalMembers, totalMembers) || other.totalMembers == totalMembers)&&(identical(other.whatsappConnected, whatsappConnected) || other.whatsappConnected == whatsappConnected)&&(identical(other.messagesLast30Days, messagesLast30Days) || other.messagesLast30Days == messagesLast30Days));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalTenants,activeTenants,totalUsers,totalMembers,whatsappConnected,messagesLast30Days);

@override
String toString() {
  return 'PlatformStats(totalTenants: $totalTenants, activeTenants: $activeTenants, totalUsers: $totalUsers, totalMembers: $totalMembers, whatsappConnected: $whatsappConnected, messagesLast30Days: $messagesLast30Days)';
}


}

/// @nodoc
abstract mixin class $PlatformStatsCopyWith<$Res>  {
  factory $PlatformStatsCopyWith(PlatformStats value, $Res Function(PlatformStats) _then) = _$PlatformStatsCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'total_tenants') int totalTenants,@JsonKey(name: 'active_tenants') int activeTenants,@JsonKey(name: 'total_users') int totalUsers,@JsonKey(name: 'total_members') int totalMembers,@JsonKey(name: 'whatsapp_connected') int whatsappConnected,@JsonKey(name: 'messages_last_30_days') int messagesLast30Days
});




}
/// @nodoc
class _$PlatformStatsCopyWithImpl<$Res>
    implements $PlatformStatsCopyWith<$Res> {
  _$PlatformStatsCopyWithImpl(this._self, this._then);

  final PlatformStats _self;
  final $Res Function(PlatformStats) _then;

/// Create a copy of PlatformStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalTenants = null,Object? activeTenants = null,Object? totalUsers = null,Object? totalMembers = null,Object? whatsappConnected = null,Object? messagesLast30Days = null,}) {
  return _then(_self.copyWith(
totalTenants: null == totalTenants ? _self.totalTenants : totalTenants // ignore: cast_nullable_to_non_nullable
as int,activeTenants: null == activeTenants ? _self.activeTenants : activeTenants // ignore: cast_nullable_to_non_nullable
as int,totalUsers: null == totalUsers ? _self.totalUsers : totalUsers // ignore: cast_nullable_to_non_nullable
as int,totalMembers: null == totalMembers ? _self.totalMembers : totalMembers // ignore: cast_nullable_to_non_nullable
as int,whatsappConnected: null == whatsappConnected ? _self.whatsappConnected : whatsappConnected // ignore: cast_nullable_to_non_nullable
as int,messagesLast30Days: null == messagesLast30Days ? _self.messagesLast30Days : messagesLast30Days // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PlatformStats].
extension PlatformStatsPatterns on PlatformStats {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlatformStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlatformStats() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlatformStats value)  $default,){
final _that = this;
switch (_that) {
case _PlatformStats():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlatformStats value)?  $default,){
final _that = this;
switch (_that) {
case _PlatformStats() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'total_tenants')  int totalTenants, @JsonKey(name: 'active_tenants')  int activeTenants, @JsonKey(name: 'total_users')  int totalUsers, @JsonKey(name: 'total_members')  int totalMembers, @JsonKey(name: 'whatsapp_connected')  int whatsappConnected, @JsonKey(name: 'messages_last_30_days')  int messagesLast30Days)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlatformStats() when $default != null:
return $default(_that.totalTenants,_that.activeTenants,_that.totalUsers,_that.totalMembers,_that.whatsappConnected,_that.messagesLast30Days);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'total_tenants')  int totalTenants, @JsonKey(name: 'active_tenants')  int activeTenants, @JsonKey(name: 'total_users')  int totalUsers, @JsonKey(name: 'total_members')  int totalMembers, @JsonKey(name: 'whatsapp_connected')  int whatsappConnected, @JsonKey(name: 'messages_last_30_days')  int messagesLast30Days)  $default,) {final _that = this;
switch (_that) {
case _PlatformStats():
return $default(_that.totalTenants,_that.activeTenants,_that.totalUsers,_that.totalMembers,_that.whatsappConnected,_that.messagesLast30Days);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'total_tenants')  int totalTenants, @JsonKey(name: 'active_tenants')  int activeTenants, @JsonKey(name: 'total_users')  int totalUsers, @JsonKey(name: 'total_members')  int totalMembers, @JsonKey(name: 'whatsapp_connected')  int whatsappConnected, @JsonKey(name: 'messages_last_30_days')  int messagesLast30Days)?  $default,) {final _that = this;
switch (_that) {
case _PlatformStats() when $default != null:
return $default(_that.totalTenants,_that.activeTenants,_that.totalUsers,_that.totalMembers,_that.whatsappConnected,_that.messagesLast30Days);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlatformStats implements PlatformStats {
  const _PlatformStats({@JsonKey(name: 'total_tenants') this.totalTenants = 0, @JsonKey(name: 'active_tenants') this.activeTenants = 0, @JsonKey(name: 'total_users') this.totalUsers = 0, @JsonKey(name: 'total_members') this.totalMembers = 0, @JsonKey(name: 'whatsapp_connected') this.whatsappConnected = 0, @JsonKey(name: 'messages_last_30_days') this.messagesLast30Days = 0});
  factory _PlatformStats.fromJson(Map<String, dynamic> json) => _$PlatformStatsFromJson(json);

@override@JsonKey(name: 'total_tenants') final  int totalTenants;
@override@JsonKey(name: 'active_tenants') final  int activeTenants;
@override@JsonKey(name: 'total_users') final  int totalUsers;
@override@JsonKey(name: 'total_members') final  int totalMembers;
@override@JsonKey(name: 'whatsapp_connected') final  int whatsappConnected;
@override@JsonKey(name: 'messages_last_30_days') final  int messagesLast30Days;

/// Create a copy of PlatformStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlatformStatsCopyWith<_PlatformStats> get copyWith => __$PlatformStatsCopyWithImpl<_PlatformStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlatformStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlatformStats&&(identical(other.totalTenants, totalTenants) || other.totalTenants == totalTenants)&&(identical(other.activeTenants, activeTenants) || other.activeTenants == activeTenants)&&(identical(other.totalUsers, totalUsers) || other.totalUsers == totalUsers)&&(identical(other.totalMembers, totalMembers) || other.totalMembers == totalMembers)&&(identical(other.whatsappConnected, whatsappConnected) || other.whatsappConnected == whatsappConnected)&&(identical(other.messagesLast30Days, messagesLast30Days) || other.messagesLast30Days == messagesLast30Days));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalTenants,activeTenants,totalUsers,totalMembers,whatsappConnected,messagesLast30Days);

@override
String toString() {
  return 'PlatformStats(totalTenants: $totalTenants, activeTenants: $activeTenants, totalUsers: $totalUsers, totalMembers: $totalMembers, whatsappConnected: $whatsappConnected, messagesLast30Days: $messagesLast30Days)';
}


}

/// @nodoc
abstract mixin class _$PlatformStatsCopyWith<$Res> implements $PlatformStatsCopyWith<$Res> {
  factory _$PlatformStatsCopyWith(_PlatformStats value, $Res Function(_PlatformStats) _then) = __$PlatformStatsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'total_tenants') int totalTenants,@JsonKey(name: 'active_tenants') int activeTenants,@JsonKey(name: 'total_users') int totalUsers,@JsonKey(name: 'total_members') int totalMembers,@JsonKey(name: 'whatsapp_connected') int whatsappConnected,@JsonKey(name: 'messages_last_30_days') int messagesLast30Days
});




}
/// @nodoc
class __$PlatformStatsCopyWithImpl<$Res>
    implements _$PlatformStatsCopyWith<$Res> {
  __$PlatformStatsCopyWithImpl(this._self, this._then);

  final _PlatformStats _self;
  final $Res Function(_PlatformStats) _then;

/// Create a copy of PlatformStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalTenants = null,Object? activeTenants = null,Object? totalUsers = null,Object? totalMembers = null,Object? whatsappConnected = null,Object? messagesLast30Days = null,}) {
  return _then(_PlatformStats(
totalTenants: null == totalTenants ? _self.totalTenants : totalTenants // ignore: cast_nullable_to_non_nullable
as int,activeTenants: null == activeTenants ? _self.activeTenants : activeTenants // ignore: cast_nullable_to_non_nullable
as int,totalUsers: null == totalUsers ? _self.totalUsers : totalUsers // ignore: cast_nullable_to_non_nullable
as int,totalMembers: null == totalMembers ? _self.totalMembers : totalMembers // ignore: cast_nullable_to_non_nullable
as int,whatsappConnected: null == whatsappConnected ? _self.whatsappConnected : whatsappConnected // ignore: cast_nullable_to_non_nullable
as int,messagesLast30Days: null == messagesLast30Days ? _self.messagesLast30Days : messagesLast30Days // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$Member {

 String get id;@JsonKey(name: 'full_name') String get fullName; String get phone; String get email; String get status;@JsonKey(name: 'whatsapp_opt_in') bool get whatsappOptIn;@JsonKey(name: 'marketing_opt_in') bool get marketingOptIn;@JsonKey(name: 'membership_status') String get membershipStatus;@JsonKey(name: 'current_plan') String get currentPlan;@JsonKey(name: 'expires_on') String? get expiresOn;
/// Create a copy of Member
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MemberCopyWith<Member> get copyWith => _$MemberCopyWithImpl<Member>(this as Member, _$identity);

  /// Serializes this Member to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Member&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.status, status) || other.status == status)&&(identical(other.whatsappOptIn, whatsappOptIn) || other.whatsappOptIn == whatsappOptIn)&&(identical(other.marketingOptIn, marketingOptIn) || other.marketingOptIn == marketingOptIn)&&(identical(other.membershipStatus, membershipStatus) || other.membershipStatus == membershipStatus)&&(identical(other.currentPlan, currentPlan) || other.currentPlan == currentPlan)&&(identical(other.expiresOn, expiresOn) || other.expiresOn == expiresOn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,phone,email,status,whatsappOptIn,marketingOptIn,membershipStatus,currentPlan,expiresOn);

@override
String toString() {
  return 'Member(id: $id, fullName: $fullName, phone: $phone, email: $email, status: $status, whatsappOptIn: $whatsappOptIn, marketingOptIn: $marketingOptIn, membershipStatus: $membershipStatus, currentPlan: $currentPlan, expiresOn: $expiresOn)';
}


}

/// @nodoc
abstract mixin class $MemberCopyWith<$Res>  {
  factory $MemberCopyWith(Member value, $Res Function(Member) _then) = _$MemberCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'full_name') String fullName, String phone, String email, String status,@JsonKey(name: 'whatsapp_opt_in') bool whatsappOptIn,@JsonKey(name: 'marketing_opt_in') bool marketingOptIn,@JsonKey(name: 'membership_status') String membershipStatus,@JsonKey(name: 'current_plan') String currentPlan,@JsonKey(name: 'expires_on') String? expiresOn
});




}
/// @nodoc
class _$MemberCopyWithImpl<$Res>
    implements $MemberCopyWith<$Res> {
  _$MemberCopyWithImpl(this._self, this._then);

  final Member _self;
  final $Res Function(Member) _then;

/// Create a copy of Member
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fullName = null,Object? phone = null,Object? email = null,Object? status = null,Object? whatsappOptIn = null,Object? marketingOptIn = null,Object? membershipStatus = null,Object? currentPlan = null,Object? expiresOn = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,whatsappOptIn: null == whatsappOptIn ? _self.whatsappOptIn : whatsappOptIn // ignore: cast_nullable_to_non_nullable
as bool,marketingOptIn: null == marketingOptIn ? _self.marketingOptIn : marketingOptIn // ignore: cast_nullable_to_non_nullable
as bool,membershipStatus: null == membershipStatus ? _self.membershipStatus : membershipStatus // ignore: cast_nullable_to_non_nullable
as String,currentPlan: null == currentPlan ? _self.currentPlan : currentPlan // ignore: cast_nullable_to_non_nullable
as String,expiresOn: freezed == expiresOn ? _self.expiresOn : expiresOn // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Member].
extension MemberPatterns on Member {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Member value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Member() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Member value)  $default,){
final _that = this;
switch (_that) {
case _Member():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Member value)?  $default,){
final _that = this;
switch (_that) {
case _Member() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'full_name')  String fullName,  String phone,  String email,  String status, @JsonKey(name: 'whatsapp_opt_in')  bool whatsappOptIn, @JsonKey(name: 'marketing_opt_in')  bool marketingOptIn, @JsonKey(name: 'membership_status')  String membershipStatus, @JsonKey(name: 'current_plan')  String currentPlan, @JsonKey(name: 'expires_on')  String? expiresOn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Member() when $default != null:
return $default(_that.id,_that.fullName,_that.phone,_that.email,_that.status,_that.whatsappOptIn,_that.marketingOptIn,_that.membershipStatus,_that.currentPlan,_that.expiresOn);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'full_name')  String fullName,  String phone,  String email,  String status, @JsonKey(name: 'whatsapp_opt_in')  bool whatsappOptIn, @JsonKey(name: 'marketing_opt_in')  bool marketingOptIn, @JsonKey(name: 'membership_status')  String membershipStatus, @JsonKey(name: 'current_plan')  String currentPlan, @JsonKey(name: 'expires_on')  String? expiresOn)  $default,) {final _that = this;
switch (_that) {
case _Member():
return $default(_that.id,_that.fullName,_that.phone,_that.email,_that.status,_that.whatsappOptIn,_that.marketingOptIn,_that.membershipStatus,_that.currentPlan,_that.expiresOn);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'full_name')  String fullName,  String phone,  String email,  String status, @JsonKey(name: 'whatsapp_opt_in')  bool whatsappOptIn, @JsonKey(name: 'marketing_opt_in')  bool marketingOptIn, @JsonKey(name: 'membership_status')  String membershipStatus, @JsonKey(name: 'current_plan')  String currentPlan, @JsonKey(name: 'expires_on')  String? expiresOn)?  $default,) {final _that = this;
switch (_that) {
case _Member() when $default != null:
return $default(_that.id,_that.fullName,_that.phone,_that.email,_that.status,_that.whatsappOptIn,_that.marketingOptIn,_that.membershipStatus,_that.currentPlan,_that.expiresOn);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Member implements Member {
  const _Member({required this.id, @JsonKey(name: 'full_name') required this.fullName, required this.phone, this.email = '', this.status = 'ACTIVE', @JsonKey(name: 'whatsapp_opt_in') this.whatsappOptIn = false, @JsonKey(name: 'marketing_opt_in') this.marketingOptIn = false, @JsonKey(name: 'membership_status') this.membershipStatus = 'NONE', @JsonKey(name: 'current_plan') this.currentPlan = '', @JsonKey(name: 'expires_on') this.expiresOn});
  factory _Member.fromJson(Map<String, dynamic> json) => _$MemberFromJson(json);

@override final  String id;
@override@JsonKey(name: 'full_name') final  String fullName;
@override final  String phone;
@override@JsonKey() final  String email;
@override@JsonKey() final  String status;
@override@JsonKey(name: 'whatsapp_opt_in') final  bool whatsappOptIn;
@override@JsonKey(name: 'marketing_opt_in') final  bool marketingOptIn;
@override@JsonKey(name: 'membership_status') final  String membershipStatus;
@override@JsonKey(name: 'current_plan') final  String currentPlan;
@override@JsonKey(name: 'expires_on') final  String? expiresOn;

/// Create a copy of Member
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MemberCopyWith<_Member> get copyWith => __$MemberCopyWithImpl<_Member>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MemberToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Member&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.status, status) || other.status == status)&&(identical(other.whatsappOptIn, whatsappOptIn) || other.whatsappOptIn == whatsappOptIn)&&(identical(other.marketingOptIn, marketingOptIn) || other.marketingOptIn == marketingOptIn)&&(identical(other.membershipStatus, membershipStatus) || other.membershipStatus == membershipStatus)&&(identical(other.currentPlan, currentPlan) || other.currentPlan == currentPlan)&&(identical(other.expiresOn, expiresOn) || other.expiresOn == expiresOn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,phone,email,status,whatsappOptIn,marketingOptIn,membershipStatus,currentPlan,expiresOn);

@override
String toString() {
  return 'Member(id: $id, fullName: $fullName, phone: $phone, email: $email, status: $status, whatsappOptIn: $whatsappOptIn, marketingOptIn: $marketingOptIn, membershipStatus: $membershipStatus, currentPlan: $currentPlan, expiresOn: $expiresOn)';
}


}

/// @nodoc
abstract mixin class _$MemberCopyWith<$Res> implements $MemberCopyWith<$Res> {
  factory _$MemberCopyWith(_Member value, $Res Function(_Member) _then) = __$MemberCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'full_name') String fullName, String phone, String email, String status,@JsonKey(name: 'whatsapp_opt_in') bool whatsappOptIn,@JsonKey(name: 'marketing_opt_in') bool marketingOptIn,@JsonKey(name: 'membership_status') String membershipStatus,@JsonKey(name: 'current_plan') String currentPlan,@JsonKey(name: 'expires_on') String? expiresOn
});




}
/// @nodoc
class __$MemberCopyWithImpl<$Res>
    implements _$MemberCopyWith<$Res> {
  __$MemberCopyWithImpl(this._self, this._then);

  final _Member _self;
  final $Res Function(_Member) _then;

/// Create a copy of Member
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fullName = null,Object? phone = null,Object? email = null,Object? status = null,Object? whatsappOptIn = null,Object? marketingOptIn = null,Object? membershipStatus = null,Object? currentPlan = null,Object? expiresOn = freezed,}) {
  return _then(_Member(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,whatsappOptIn: null == whatsappOptIn ? _self.whatsappOptIn : whatsappOptIn // ignore: cast_nullable_to_non_nullable
as bool,marketingOptIn: null == marketingOptIn ? _self.marketingOptIn : marketingOptIn // ignore: cast_nullable_to_non_nullable
as bool,membershipStatus: null == membershipStatus ? _self.membershipStatus : membershipStatus // ignore: cast_nullable_to_non_nullable
as String,currentPlan: null == currentPlan ? _self.currentPlan : currentPlan // ignore: cast_nullable_to_non_nullable
as String,expiresOn: freezed == expiresOn ? _self.expiresOn : expiresOn // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$MembershipPlan {

 String get id; String get name; String get description;@JsonKey(name: 'duration_type') String get durationType;@JsonKey(name: 'duration_days') int? get durationDays;@JsonKey(name: 'price_minor') int get priceMinor;@JsonKey(name: 'is_active') bool get isActive;
/// Create a copy of MembershipPlan
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MembershipPlanCopyWith<MembershipPlan> get copyWith => _$MembershipPlanCopyWithImpl<MembershipPlan>(this as MembershipPlan, _$identity);

  /// Serializes this MembershipPlan to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MembershipPlan&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.durationType, durationType) || other.durationType == durationType)&&(identical(other.durationDays, durationDays) || other.durationDays == durationDays)&&(identical(other.priceMinor, priceMinor) || other.priceMinor == priceMinor)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,durationType,durationDays,priceMinor,isActive);

@override
String toString() {
  return 'MembershipPlan(id: $id, name: $name, description: $description, durationType: $durationType, durationDays: $durationDays, priceMinor: $priceMinor, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class $MembershipPlanCopyWith<$Res>  {
  factory $MembershipPlanCopyWith(MembershipPlan value, $Res Function(MembershipPlan) _then) = _$MembershipPlanCopyWithImpl;
@useResult
$Res call({
 String id, String name, String description,@JsonKey(name: 'duration_type') String durationType,@JsonKey(name: 'duration_days') int? durationDays,@JsonKey(name: 'price_minor') int priceMinor,@JsonKey(name: 'is_active') bool isActive
});




}
/// @nodoc
class _$MembershipPlanCopyWithImpl<$Res>
    implements $MembershipPlanCopyWith<$Res> {
  _$MembershipPlanCopyWithImpl(this._self, this._then);

  final MembershipPlan _self;
  final $Res Function(MembershipPlan) _then;

/// Create a copy of MembershipPlan
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? durationType = null,Object? durationDays = freezed,Object? priceMinor = null,Object? isActive = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,durationType: null == durationType ? _self.durationType : durationType // ignore: cast_nullable_to_non_nullable
as String,durationDays: freezed == durationDays ? _self.durationDays : durationDays // ignore: cast_nullable_to_non_nullable
as int?,priceMinor: null == priceMinor ? _self.priceMinor : priceMinor // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MembershipPlan].
extension MembershipPlanPatterns on MembershipPlan {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MembershipPlan value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MembershipPlan() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MembershipPlan value)  $default,){
final _that = this;
switch (_that) {
case _MembershipPlan():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MembershipPlan value)?  $default,){
final _that = this;
switch (_that) {
case _MembershipPlan() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String description, @JsonKey(name: 'duration_type')  String durationType, @JsonKey(name: 'duration_days')  int? durationDays, @JsonKey(name: 'price_minor')  int priceMinor, @JsonKey(name: 'is_active')  bool isActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MembershipPlan() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.durationType,_that.durationDays,_that.priceMinor,_that.isActive);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String description, @JsonKey(name: 'duration_type')  String durationType, @JsonKey(name: 'duration_days')  int? durationDays, @JsonKey(name: 'price_minor')  int priceMinor, @JsonKey(name: 'is_active')  bool isActive)  $default,) {final _that = this;
switch (_that) {
case _MembershipPlan():
return $default(_that.id,_that.name,_that.description,_that.durationType,_that.durationDays,_that.priceMinor,_that.isActive);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String description, @JsonKey(name: 'duration_type')  String durationType, @JsonKey(name: 'duration_days')  int? durationDays, @JsonKey(name: 'price_minor')  int priceMinor, @JsonKey(name: 'is_active')  bool isActive)?  $default,) {final _that = this;
switch (_that) {
case _MembershipPlan() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.durationType,_that.durationDays,_that.priceMinor,_that.isActive);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MembershipPlan implements MembershipPlan {
  const _MembershipPlan({required this.id, required this.name, this.description = '', @JsonKey(name: 'duration_type') required this.durationType, @JsonKey(name: 'duration_days') this.durationDays, @JsonKey(name: 'price_minor') this.priceMinor = 0, @JsonKey(name: 'is_active') this.isActive = true});
  factory _MembershipPlan.fromJson(Map<String, dynamic> json) => _$MembershipPlanFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey() final  String description;
@override@JsonKey(name: 'duration_type') final  String durationType;
@override@JsonKey(name: 'duration_days') final  int? durationDays;
@override@JsonKey(name: 'price_minor') final  int priceMinor;
@override@JsonKey(name: 'is_active') final  bool isActive;

/// Create a copy of MembershipPlan
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MembershipPlanCopyWith<_MembershipPlan> get copyWith => __$MembershipPlanCopyWithImpl<_MembershipPlan>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MembershipPlanToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MembershipPlan&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.durationType, durationType) || other.durationType == durationType)&&(identical(other.durationDays, durationDays) || other.durationDays == durationDays)&&(identical(other.priceMinor, priceMinor) || other.priceMinor == priceMinor)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,durationType,durationDays,priceMinor,isActive);

@override
String toString() {
  return 'MembershipPlan(id: $id, name: $name, description: $description, durationType: $durationType, durationDays: $durationDays, priceMinor: $priceMinor, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class _$MembershipPlanCopyWith<$Res> implements $MembershipPlanCopyWith<$Res> {
  factory _$MembershipPlanCopyWith(_MembershipPlan value, $Res Function(_MembershipPlan) _then) = __$MembershipPlanCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String description,@JsonKey(name: 'duration_type') String durationType,@JsonKey(name: 'duration_days') int? durationDays,@JsonKey(name: 'price_minor') int priceMinor,@JsonKey(name: 'is_active') bool isActive
});




}
/// @nodoc
class __$MembershipPlanCopyWithImpl<$Res>
    implements _$MembershipPlanCopyWith<$Res> {
  __$MembershipPlanCopyWithImpl(this._self, this._then);

  final _MembershipPlan _self;
  final $Res Function(_MembershipPlan) _then;

/// Create a copy of MembershipPlan
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? durationType = null,Object? durationDays = freezed,Object? priceMinor = null,Object? isActive = null,}) {
  return _then(_MembershipPlan(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,durationType: null == durationType ? _self.durationType : durationType // ignore: cast_nullable_to_non_nullable
as String,durationDays: freezed == durationDays ? _self.durationDays : durationDays // ignore: cast_nullable_to_non_nullable
as int?,priceMinor: null == priceMinor ? _self.priceMinor : priceMinor // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$Membership {

 String get id;@JsonKey(name: 'member_id') String get memberId;@JsonKey(name: 'member_name') String get memberName;@JsonKey(name: 'plan_id') String get planId;@JsonKey(name: 'plan_name') String get planName;@JsonKey(name: 'start_date') String get startDate;@JsonKey(name: 'end_date') String get endDate;@JsonKey(name: 'total_amount_minor') int get totalAmountMinor;@JsonKey(name: 'paid_amount_minor') int get paidAmountMinor;@JsonKey(name: 'pending_amount_minor') int get pendingAmountMinor; String get status;@JsonKey(name: 'payment_status') String get paymentStatus;
/// Create a copy of Membership
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MembershipCopyWith<Membership> get copyWith => _$MembershipCopyWithImpl<Membership>(this as Membership, _$identity);

  /// Serializes this Membership to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Membership&&(identical(other.id, id) || other.id == id)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.memberName, memberName) || other.memberName == memberName)&&(identical(other.planId, planId) || other.planId == planId)&&(identical(other.planName, planName) || other.planName == planName)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.totalAmountMinor, totalAmountMinor) || other.totalAmountMinor == totalAmountMinor)&&(identical(other.paidAmountMinor, paidAmountMinor) || other.paidAmountMinor == paidAmountMinor)&&(identical(other.pendingAmountMinor, pendingAmountMinor) || other.pendingAmountMinor == pendingAmountMinor)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,memberId,memberName,planId,planName,startDate,endDate,totalAmountMinor,paidAmountMinor,pendingAmountMinor,status,paymentStatus);

@override
String toString() {
  return 'Membership(id: $id, memberId: $memberId, memberName: $memberName, planId: $planId, planName: $planName, startDate: $startDate, endDate: $endDate, totalAmountMinor: $totalAmountMinor, paidAmountMinor: $paidAmountMinor, pendingAmountMinor: $pendingAmountMinor, status: $status, paymentStatus: $paymentStatus)';
}


}

/// @nodoc
abstract mixin class $MembershipCopyWith<$Res>  {
  factory $MembershipCopyWith(Membership value, $Res Function(Membership) _then) = _$MembershipCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'member_id') String memberId,@JsonKey(name: 'member_name') String memberName,@JsonKey(name: 'plan_id') String planId,@JsonKey(name: 'plan_name') String planName,@JsonKey(name: 'start_date') String startDate,@JsonKey(name: 'end_date') String endDate,@JsonKey(name: 'total_amount_minor') int totalAmountMinor,@JsonKey(name: 'paid_amount_minor') int paidAmountMinor,@JsonKey(name: 'pending_amount_minor') int pendingAmountMinor, String status,@JsonKey(name: 'payment_status') String paymentStatus
});




}
/// @nodoc
class _$MembershipCopyWithImpl<$Res>
    implements $MembershipCopyWith<$Res> {
  _$MembershipCopyWithImpl(this._self, this._then);

  final Membership _self;
  final $Res Function(Membership) _then;

/// Create a copy of Membership
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? memberId = null,Object? memberName = null,Object? planId = null,Object? planName = null,Object? startDate = null,Object? endDate = null,Object? totalAmountMinor = null,Object? paidAmountMinor = null,Object? pendingAmountMinor = null,Object? status = null,Object? paymentStatus = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,memberName: null == memberName ? _self.memberName : memberName // ignore: cast_nullable_to_non_nullable
as String,planId: null == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as String,planName: null == planName ? _self.planName : planName // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String,totalAmountMinor: null == totalAmountMinor ? _self.totalAmountMinor : totalAmountMinor // ignore: cast_nullable_to_non_nullable
as int,paidAmountMinor: null == paidAmountMinor ? _self.paidAmountMinor : paidAmountMinor // ignore: cast_nullable_to_non_nullable
as int,pendingAmountMinor: null == pendingAmountMinor ? _self.pendingAmountMinor : pendingAmountMinor // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,paymentStatus: null == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Membership].
extension MembershipPatterns on Membership {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Membership value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Membership() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Membership value)  $default,){
final _that = this;
switch (_that) {
case _Membership():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Membership value)?  $default,){
final _that = this;
switch (_that) {
case _Membership() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'member_id')  String memberId, @JsonKey(name: 'member_name')  String memberName, @JsonKey(name: 'plan_id')  String planId, @JsonKey(name: 'plan_name')  String planName, @JsonKey(name: 'start_date')  String startDate, @JsonKey(name: 'end_date')  String endDate, @JsonKey(name: 'total_amount_minor')  int totalAmountMinor, @JsonKey(name: 'paid_amount_minor')  int paidAmountMinor, @JsonKey(name: 'pending_amount_minor')  int pendingAmountMinor,  String status, @JsonKey(name: 'payment_status')  String paymentStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Membership() when $default != null:
return $default(_that.id,_that.memberId,_that.memberName,_that.planId,_that.planName,_that.startDate,_that.endDate,_that.totalAmountMinor,_that.paidAmountMinor,_that.pendingAmountMinor,_that.status,_that.paymentStatus);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'member_id')  String memberId, @JsonKey(name: 'member_name')  String memberName, @JsonKey(name: 'plan_id')  String planId, @JsonKey(name: 'plan_name')  String planName, @JsonKey(name: 'start_date')  String startDate, @JsonKey(name: 'end_date')  String endDate, @JsonKey(name: 'total_amount_minor')  int totalAmountMinor, @JsonKey(name: 'paid_amount_minor')  int paidAmountMinor, @JsonKey(name: 'pending_amount_minor')  int pendingAmountMinor,  String status, @JsonKey(name: 'payment_status')  String paymentStatus)  $default,) {final _that = this;
switch (_that) {
case _Membership():
return $default(_that.id,_that.memberId,_that.memberName,_that.planId,_that.planName,_that.startDate,_that.endDate,_that.totalAmountMinor,_that.paidAmountMinor,_that.pendingAmountMinor,_that.status,_that.paymentStatus);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'member_id')  String memberId, @JsonKey(name: 'member_name')  String memberName, @JsonKey(name: 'plan_id')  String planId, @JsonKey(name: 'plan_name')  String planName, @JsonKey(name: 'start_date')  String startDate, @JsonKey(name: 'end_date')  String endDate, @JsonKey(name: 'total_amount_minor')  int totalAmountMinor, @JsonKey(name: 'paid_amount_minor')  int paidAmountMinor, @JsonKey(name: 'pending_amount_minor')  int pendingAmountMinor,  String status, @JsonKey(name: 'payment_status')  String paymentStatus)?  $default,) {final _that = this;
switch (_that) {
case _Membership() when $default != null:
return $default(_that.id,_that.memberId,_that.memberName,_that.planId,_that.planName,_that.startDate,_that.endDate,_that.totalAmountMinor,_that.paidAmountMinor,_that.pendingAmountMinor,_that.status,_that.paymentStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Membership implements Membership {
  const _Membership({required this.id, @JsonKey(name: 'member_id') required this.memberId, @JsonKey(name: 'member_name') this.memberName = '', @JsonKey(name: 'plan_id') required this.planId, @JsonKey(name: 'plan_name') this.planName = '', @JsonKey(name: 'start_date') required this.startDate, @JsonKey(name: 'end_date') required this.endDate, @JsonKey(name: 'total_amount_minor') this.totalAmountMinor = 0, @JsonKey(name: 'paid_amount_minor') this.paidAmountMinor = 0, @JsonKey(name: 'pending_amount_minor') this.pendingAmountMinor = 0, this.status = 'ACTIVE', @JsonKey(name: 'payment_status') this.paymentStatus = 'UNPAID'});
  factory _Membership.fromJson(Map<String, dynamic> json) => _$MembershipFromJson(json);

@override final  String id;
@override@JsonKey(name: 'member_id') final  String memberId;
@override@JsonKey(name: 'member_name') final  String memberName;
@override@JsonKey(name: 'plan_id') final  String planId;
@override@JsonKey(name: 'plan_name') final  String planName;
@override@JsonKey(name: 'start_date') final  String startDate;
@override@JsonKey(name: 'end_date') final  String endDate;
@override@JsonKey(name: 'total_amount_minor') final  int totalAmountMinor;
@override@JsonKey(name: 'paid_amount_minor') final  int paidAmountMinor;
@override@JsonKey(name: 'pending_amount_minor') final  int pendingAmountMinor;
@override@JsonKey() final  String status;
@override@JsonKey(name: 'payment_status') final  String paymentStatus;

/// Create a copy of Membership
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MembershipCopyWith<_Membership> get copyWith => __$MembershipCopyWithImpl<_Membership>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MembershipToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Membership&&(identical(other.id, id) || other.id == id)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.memberName, memberName) || other.memberName == memberName)&&(identical(other.planId, planId) || other.planId == planId)&&(identical(other.planName, planName) || other.planName == planName)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.totalAmountMinor, totalAmountMinor) || other.totalAmountMinor == totalAmountMinor)&&(identical(other.paidAmountMinor, paidAmountMinor) || other.paidAmountMinor == paidAmountMinor)&&(identical(other.pendingAmountMinor, pendingAmountMinor) || other.pendingAmountMinor == pendingAmountMinor)&&(identical(other.status, status) || other.status == status)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,memberId,memberName,planId,planName,startDate,endDate,totalAmountMinor,paidAmountMinor,pendingAmountMinor,status,paymentStatus);

@override
String toString() {
  return 'Membership(id: $id, memberId: $memberId, memberName: $memberName, planId: $planId, planName: $planName, startDate: $startDate, endDate: $endDate, totalAmountMinor: $totalAmountMinor, paidAmountMinor: $paidAmountMinor, pendingAmountMinor: $pendingAmountMinor, status: $status, paymentStatus: $paymentStatus)';
}


}

/// @nodoc
abstract mixin class _$MembershipCopyWith<$Res> implements $MembershipCopyWith<$Res> {
  factory _$MembershipCopyWith(_Membership value, $Res Function(_Membership) _then) = __$MembershipCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'member_id') String memberId,@JsonKey(name: 'member_name') String memberName,@JsonKey(name: 'plan_id') String planId,@JsonKey(name: 'plan_name') String planName,@JsonKey(name: 'start_date') String startDate,@JsonKey(name: 'end_date') String endDate,@JsonKey(name: 'total_amount_minor') int totalAmountMinor,@JsonKey(name: 'paid_amount_minor') int paidAmountMinor,@JsonKey(name: 'pending_amount_minor') int pendingAmountMinor, String status,@JsonKey(name: 'payment_status') String paymentStatus
});




}
/// @nodoc
class __$MembershipCopyWithImpl<$Res>
    implements _$MembershipCopyWith<$Res> {
  __$MembershipCopyWithImpl(this._self, this._then);

  final _Membership _self;
  final $Res Function(_Membership) _then;

/// Create a copy of Membership
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? memberId = null,Object? memberName = null,Object? planId = null,Object? planName = null,Object? startDate = null,Object? endDate = null,Object? totalAmountMinor = null,Object? paidAmountMinor = null,Object? pendingAmountMinor = null,Object? status = null,Object? paymentStatus = null,}) {
  return _then(_Membership(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,memberName: null == memberName ? _self.memberName : memberName // ignore: cast_nullable_to_non_nullable
as String,planId: null == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as String,planName: null == planName ? _self.planName : planName // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String,totalAmountMinor: null == totalAmountMinor ? _self.totalAmountMinor : totalAmountMinor // ignore: cast_nullable_to_non_nullable
as int,paidAmountMinor: null == paidAmountMinor ? _self.paidAmountMinor : paidAmountMinor // ignore: cast_nullable_to_non_nullable
as int,pendingAmountMinor: null == pendingAmountMinor ? _self.pendingAmountMinor : pendingAmountMinor // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,paymentStatus: null == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Payment {

 String get id;@JsonKey(name: 'member_id') String get memberId;@JsonKey(name: 'member_name') String get memberName;@JsonKey(name: 'amount_minor') int get amountMinor; String get method; String get reference;@JsonKey(name: 'paid_at') String get paidAt;
/// Create a copy of Payment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentCopyWith<Payment> get copyWith => _$PaymentCopyWithImpl<Payment>(this as Payment, _$identity);

  /// Serializes this Payment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Payment&&(identical(other.id, id) || other.id == id)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.memberName, memberName) || other.memberName == memberName)&&(identical(other.amountMinor, amountMinor) || other.amountMinor == amountMinor)&&(identical(other.method, method) || other.method == method)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,memberId,memberName,amountMinor,method,reference,paidAt);

@override
String toString() {
  return 'Payment(id: $id, memberId: $memberId, memberName: $memberName, amountMinor: $amountMinor, method: $method, reference: $reference, paidAt: $paidAt)';
}


}

/// @nodoc
abstract mixin class $PaymentCopyWith<$Res>  {
  factory $PaymentCopyWith(Payment value, $Res Function(Payment) _then) = _$PaymentCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'member_id') String memberId,@JsonKey(name: 'member_name') String memberName,@JsonKey(name: 'amount_minor') int amountMinor, String method, String reference,@JsonKey(name: 'paid_at') String paidAt
});




}
/// @nodoc
class _$PaymentCopyWithImpl<$Res>
    implements $PaymentCopyWith<$Res> {
  _$PaymentCopyWithImpl(this._self, this._then);

  final Payment _self;
  final $Res Function(Payment) _then;

/// Create a copy of Payment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? memberId = null,Object? memberName = null,Object? amountMinor = null,Object? method = null,Object? reference = null,Object? paidAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,memberName: null == memberName ? _self.memberName : memberName // ignore: cast_nullable_to_non_nullable
as String,amountMinor: null == amountMinor ? _self.amountMinor : amountMinor // ignore: cast_nullable_to_non_nullable
as int,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,reference: null == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String,paidAt: null == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Payment].
extension PaymentPatterns on Payment {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Payment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Payment() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Payment value)  $default,){
final _that = this;
switch (_that) {
case _Payment():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Payment value)?  $default,){
final _that = this;
switch (_that) {
case _Payment() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'member_id')  String memberId, @JsonKey(name: 'member_name')  String memberName, @JsonKey(name: 'amount_minor')  int amountMinor,  String method,  String reference, @JsonKey(name: 'paid_at')  String paidAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Payment() when $default != null:
return $default(_that.id,_that.memberId,_that.memberName,_that.amountMinor,_that.method,_that.reference,_that.paidAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'member_id')  String memberId, @JsonKey(name: 'member_name')  String memberName, @JsonKey(name: 'amount_minor')  int amountMinor,  String method,  String reference, @JsonKey(name: 'paid_at')  String paidAt)  $default,) {final _that = this;
switch (_that) {
case _Payment():
return $default(_that.id,_that.memberId,_that.memberName,_that.amountMinor,_that.method,_that.reference,_that.paidAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'member_id')  String memberId, @JsonKey(name: 'member_name')  String memberName, @JsonKey(name: 'amount_minor')  int amountMinor,  String method,  String reference, @JsonKey(name: 'paid_at')  String paidAt)?  $default,) {final _that = this;
switch (_that) {
case _Payment() when $default != null:
return $default(_that.id,_that.memberId,_that.memberName,_that.amountMinor,_that.method,_that.reference,_that.paidAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Payment implements Payment {
  const _Payment({required this.id, @JsonKey(name: 'member_id') required this.memberId, @JsonKey(name: 'member_name') this.memberName = '', @JsonKey(name: 'amount_minor') required this.amountMinor, required this.method, this.reference = '', @JsonKey(name: 'paid_at') required this.paidAt});
  factory _Payment.fromJson(Map<String, dynamic> json) => _$PaymentFromJson(json);

@override final  String id;
@override@JsonKey(name: 'member_id') final  String memberId;
@override@JsonKey(name: 'member_name') final  String memberName;
@override@JsonKey(name: 'amount_minor') final  int amountMinor;
@override final  String method;
@override@JsonKey() final  String reference;
@override@JsonKey(name: 'paid_at') final  String paidAt;

/// Create a copy of Payment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentCopyWith<_Payment> get copyWith => __$PaymentCopyWithImpl<_Payment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Payment&&(identical(other.id, id) || other.id == id)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.memberName, memberName) || other.memberName == memberName)&&(identical(other.amountMinor, amountMinor) || other.amountMinor == amountMinor)&&(identical(other.method, method) || other.method == method)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,memberId,memberName,amountMinor,method,reference,paidAt);

@override
String toString() {
  return 'Payment(id: $id, memberId: $memberId, memberName: $memberName, amountMinor: $amountMinor, method: $method, reference: $reference, paidAt: $paidAt)';
}


}

/// @nodoc
abstract mixin class _$PaymentCopyWith<$Res> implements $PaymentCopyWith<$Res> {
  factory _$PaymentCopyWith(_Payment value, $Res Function(_Payment) _then) = __$PaymentCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'member_id') String memberId,@JsonKey(name: 'member_name') String memberName,@JsonKey(name: 'amount_minor') int amountMinor, String method, String reference,@JsonKey(name: 'paid_at') String paidAt
});




}
/// @nodoc
class __$PaymentCopyWithImpl<$Res>
    implements _$PaymentCopyWith<$Res> {
  __$PaymentCopyWithImpl(this._self, this._then);

  final _Payment _self;
  final $Res Function(_Payment) _then;

/// Create a copy of Payment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? memberId = null,Object? memberName = null,Object? amountMinor = null,Object? method = null,Object? reference = null,Object? paidAt = null,}) {
  return _then(_Payment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,memberName: null == memberName ? _self.memberName : memberName // ignore: cast_nullable_to_non_nullable
as String,amountMinor: null == amountMinor ? _self.amountMinor : amountMinor // ignore: cast_nullable_to_non_nullable
as int,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,reference: null == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String,paidAt: null == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Attendance {

 String get id;@JsonKey(name: 'member_id') String get memberId;@JsonKey(name: 'member_name') String get memberName;@JsonKey(name: 'attendance_date') String get attendanceDate;@JsonKey(name: 'check_in_at') String get checkInAt;
/// Create a copy of Attendance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttendanceCopyWith<Attendance> get copyWith => _$AttendanceCopyWithImpl<Attendance>(this as Attendance, _$identity);

  /// Serializes this Attendance to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Attendance&&(identical(other.id, id) || other.id == id)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.memberName, memberName) || other.memberName == memberName)&&(identical(other.attendanceDate, attendanceDate) || other.attendanceDate == attendanceDate)&&(identical(other.checkInAt, checkInAt) || other.checkInAt == checkInAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,memberId,memberName,attendanceDate,checkInAt);

@override
String toString() {
  return 'Attendance(id: $id, memberId: $memberId, memberName: $memberName, attendanceDate: $attendanceDate, checkInAt: $checkInAt)';
}


}

/// @nodoc
abstract mixin class $AttendanceCopyWith<$Res>  {
  factory $AttendanceCopyWith(Attendance value, $Res Function(Attendance) _then) = _$AttendanceCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'member_id') String memberId,@JsonKey(name: 'member_name') String memberName,@JsonKey(name: 'attendance_date') String attendanceDate,@JsonKey(name: 'check_in_at') String checkInAt
});




}
/// @nodoc
class _$AttendanceCopyWithImpl<$Res>
    implements $AttendanceCopyWith<$Res> {
  _$AttendanceCopyWithImpl(this._self, this._then);

  final Attendance _self;
  final $Res Function(Attendance) _then;

/// Create a copy of Attendance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? memberId = null,Object? memberName = null,Object? attendanceDate = null,Object? checkInAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,memberName: null == memberName ? _self.memberName : memberName // ignore: cast_nullable_to_non_nullable
as String,attendanceDate: null == attendanceDate ? _self.attendanceDate : attendanceDate // ignore: cast_nullable_to_non_nullable
as String,checkInAt: null == checkInAt ? _self.checkInAt : checkInAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Attendance].
extension AttendancePatterns on Attendance {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Attendance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Attendance() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Attendance value)  $default,){
final _that = this;
switch (_that) {
case _Attendance():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Attendance value)?  $default,){
final _that = this;
switch (_that) {
case _Attendance() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'member_id')  String memberId, @JsonKey(name: 'member_name')  String memberName, @JsonKey(name: 'attendance_date')  String attendanceDate, @JsonKey(name: 'check_in_at')  String checkInAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Attendance() when $default != null:
return $default(_that.id,_that.memberId,_that.memberName,_that.attendanceDate,_that.checkInAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'member_id')  String memberId, @JsonKey(name: 'member_name')  String memberName, @JsonKey(name: 'attendance_date')  String attendanceDate, @JsonKey(name: 'check_in_at')  String checkInAt)  $default,) {final _that = this;
switch (_that) {
case _Attendance():
return $default(_that.id,_that.memberId,_that.memberName,_that.attendanceDate,_that.checkInAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'member_id')  String memberId, @JsonKey(name: 'member_name')  String memberName, @JsonKey(name: 'attendance_date')  String attendanceDate, @JsonKey(name: 'check_in_at')  String checkInAt)?  $default,) {final _that = this;
switch (_that) {
case _Attendance() when $default != null:
return $default(_that.id,_that.memberId,_that.memberName,_that.attendanceDate,_that.checkInAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Attendance implements Attendance {
  const _Attendance({required this.id, @JsonKey(name: 'member_id') required this.memberId, @JsonKey(name: 'member_name') this.memberName = '', @JsonKey(name: 'attendance_date') required this.attendanceDate, @JsonKey(name: 'check_in_at') required this.checkInAt});
  factory _Attendance.fromJson(Map<String, dynamic> json) => _$AttendanceFromJson(json);

@override final  String id;
@override@JsonKey(name: 'member_id') final  String memberId;
@override@JsonKey(name: 'member_name') final  String memberName;
@override@JsonKey(name: 'attendance_date') final  String attendanceDate;
@override@JsonKey(name: 'check_in_at') final  String checkInAt;

/// Create a copy of Attendance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttendanceCopyWith<_Attendance> get copyWith => __$AttendanceCopyWithImpl<_Attendance>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttendanceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Attendance&&(identical(other.id, id) || other.id == id)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.memberName, memberName) || other.memberName == memberName)&&(identical(other.attendanceDate, attendanceDate) || other.attendanceDate == attendanceDate)&&(identical(other.checkInAt, checkInAt) || other.checkInAt == checkInAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,memberId,memberName,attendanceDate,checkInAt);

@override
String toString() {
  return 'Attendance(id: $id, memberId: $memberId, memberName: $memberName, attendanceDate: $attendanceDate, checkInAt: $checkInAt)';
}


}

/// @nodoc
abstract mixin class _$AttendanceCopyWith<$Res> implements $AttendanceCopyWith<$Res> {
  factory _$AttendanceCopyWith(_Attendance value, $Res Function(_Attendance) _then) = __$AttendanceCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'member_id') String memberId,@JsonKey(name: 'member_name') String memberName,@JsonKey(name: 'attendance_date') String attendanceDate,@JsonKey(name: 'check_in_at') String checkInAt
});




}
/// @nodoc
class __$AttendanceCopyWithImpl<$Res>
    implements _$AttendanceCopyWith<$Res> {
  __$AttendanceCopyWithImpl(this._self, this._then);

  final _Attendance _self;
  final $Res Function(_Attendance) _then;

/// Create a copy of Attendance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? memberId = null,Object? memberName = null,Object? attendanceDate = null,Object? checkInAt = null,}) {
  return _then(_Attendance(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,memberName: null == memberName ? _self.memberName : memberName // ignore: cast_nullable_to_non_nullable
as String,attendanceDate: null == attendanceDate ? _self.attendanceDate : attendanceDate // ignore: cast_nullable_to_non_nullable
as String,checkInAt: null == checkInAt ? _self.checkInAt : checkInAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$Holiday {

 String get id; String get title; String get description;@JsonKey(name: 'holiday_date') String get holidayDate;@JsonKey(name: 'notify_enabled') bool get notifyEnabled;@JsonKey(name: 'notify_days_before') List<int> get notifyDaysBefore;
/// Create a copy of Holiday
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HolidayCopyWith<Holiday> get copyWith => _$HolidayCopyWithImpl<Holiday>(this as Holiday, _$identity);

  /// Serializes this Holiday to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Holiday&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.holidayDate, holidayDate) || other.holidayDate == holidayDate)&&(identical(other.notifyEnabled, notifyEnabled) || other.notifyEnabled == notifyEnabled)&&const DeepCollectionEquality().equals(other.notifyDaysBefore, notifyDaysBefore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,holidayDate,notifyEnabled,const DeepCollectionEquality().hash(notifyDaysBefore));

@override
String toString() {
  return 'Holiday(id: $id, title: $title, description: $description, holidayDate: $holidayDate, notifyEnabled: $notifyEnabled, notifyDaysBefore: $notifyDaysBefore)';
}


}

/// @nodoc
abstract mixin class $HolidayCopyWith<$Res>  {
  factory $HolidayCopyWith(Holiday value, $Res Function(Holiday) _then) = _$HolidayCopyWithImpl;
@useResult
$Res call({
 String id, String title, String description,@JsonKey(name: 'holiday_date') String holidayDate,@JsonKey(name: 'notify_enabled') bool notifyEnabled,@JsonKey(name: 'notify_days_before') List<int> notifyDaysBefore
});




}
/// @nodoc
class _$HolidayCopyWithImpl<$Res>
    implements $HolidayCopyWith<$Res> {
  _$HolidayCopyWithImpl(this._self, this._then);

  final Holiday _self;
  final $Res Function(Holiday) _then;

/// Create a copy of Holiday
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? holidayDate = null,Object? notifyEnabled = null,Object? notifyDaysBefore = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,holidayDate: null == holidayDate ? _self.holidayDate : holidayDate // ignore: cast_nullable_to_non_nullable
as String,notifyEnabled: null == notifyEnabled ? _self.notifyEnabled : notifyEnabled // ignore: cast_nullable_to_non_nullable
as bool,notifyDaysBefore: null == notifyDaysBefore ? _self.notifyDaysBefore : notifyDaysBefore // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}

}


/// Adds pattern-matching-related methods to [Holiday].
extension HolidayPatterns on Holiday {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Holiday value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Holiday() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Holiday value)  $default,){
final _that = this;
switch (_that) {
case _Holiday():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Holiday value)?  $default,){
final _that = this;
switch (_that) {
case _Holiday() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String description, @JsonKey(name: 'holiday_date')  String holidayDate, @JsonKey(name: 'notify_enabled')  bool notifyEnabled, @JsonKey(name: 'notify_days_before')  List<int> notifyDaysBefore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Holiday() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.holidayDate,_that.notifyEnabled,_that.notifyDaysBefore);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String description, @JsonKey(name: 'holiday_date')  String holidayDate, @JsonKey(name: 'notify_enabled')  bool notifyEnabled, @JsonKey(name: 'notify_days_before')  List<int> notifyDaysBefore)  $default,) {final _that = this;
switch (_that) {
case _Holiday():
return $default(_that.id,_that.title,_that.description,_that.holidayDate,_that.notifyEnabled,_that.notifyDaysBefore);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String description, @JsonKey(name: 'holiday_date')  String holidayDate, @JsonKey(name: 'notify_enabled')  bool notifyEnabled, @JsonKey(name: 'notify_days_before')  List<int> notifyDaysBefore)?  $default,) {final _that = this;
switch (_that) {
case _Holiday() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.holidayDate,_that.notifyEnabled,_that.notifyDaysBefore);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Holiday implements Holiday {
  const _Holiday({required this.id, required this.title, this.description = '', @JsonKey(name: 'holiday_date') required this.holidayDate, @JsonKey(name: 'notify_enabled') this.notifyEnabled = true, @JsonKey(name: 'notify_days_before') required this.notifyDaysBefore});
  factory _Holiday.fromJson(Map<String, dynamic> json) => _$HolidayFromJson(json);

@override final  String id;
@override final  String title;
@override@JsonKey() final  String description;
@override@JsonKey(name: 'holiday_date') final  String holidayDate;
@override@JsonKey(name: 'notify_enabled') final  bool notifyEnabled;
@override@JsonKey(name: 'notify_days_before') final  List<int> notifyDaysBefore;

/// Create a copy of Holiday
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HolidayCopyWith<_Holiday> get copyWith => __$HolidayCopyWithImpl<_Holiday>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HolidayToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Holiday&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.holidayDate, holidayDate) || other.holidayDate == holidayDate)&&(identical(other.notifyEnabled, notifyEnabled) || other.notifyEnabled == notifyEnabled)&&const DeepCollectionEquality().equals(other.notifyDaysBefore, notifyDaysBefore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,holidayDate,notifyEnabled,const DeepCollectionEquality().hash(notifyDaysBefore));

@override
String toString() {
  return 'Holiday(id: $id, title: $title, description: $description, holidayDate: $holidayDate, notifyEnabled: $notifyEnabled, notifyDaysBefore: $notifyDaysBefore)';
}


}

/// @nodoc
abstract mixin class _$HolidayCopyWith<$Res> implements $HolidayCopyWith<$Res> {
  factory _$HolidayCopyWith(_Holiday value, $Res Function(_Holiday) _then) = __$HolidayCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String description,@JsonKey(name: 'holiday_date') String holidayDate,@JsonKey(name: 'notify_enabled') bool notifyEnabled,@JsonKey(name: 'notify_days_before') List<int> notifyDaysBefore
});




}
/// @nodoc
class __$HolidayCopyWithImpl<$Res>
    implements _$HolidayCopyWith<$Res> {
  __$HolidayCopyWithImpl(this._self, this._then);

  final _Holiday _self;
  final $Res Function(_Holiday) _then;

/// Create a copy of Holiday
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? holidayDate = null,Object? notifyEnabled = null,Object? notifyDaysBefore = null,}) {
  return _then(_Holiday(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,holidayDate: null == holidayDate ? _self.holidayDate : holidayDate // ignore: cast_nullable_to_non_nullable
as String,notifyEnabled: null == notifyEnabled ? _self.notifyEnabled : notifyEnabled // ignore: cast_nullable_to_non_nullable
as bool,notifyDaysBefore: null == notifyDaysBefore ? _self.notifyDaysBefore : notifyDaysBefore // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}


}


/// @nodoc
mixin _$Lead {

 String get id;@JsonKey(name: 'full_name') String get fullName; String get phone; String get email; String get source; String get status;@JsonKey(name: 'whatsapp_opt_in') bool get whatsappOptIn;@JsonKey(name: 'marketing_opt_in') bool get marketingOptIn;
/// Create a copy of Lead
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeadCopyWith<Lead> get copyWith => _$LeadCopyWithImpl<Lead>(this as Lead, _$identity);

  /// Serializes this Lead to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Lead&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.source, source) || other.source == source)&&(identical(other.status, status) || other.status == status)&&(identical(other.whatsappOptIn, whatsappOptIn) || other.whatsappOptIn == whatsappOptIn)&&(identical(other.marketingOptIn, marketingOptIn) || other.marketingOptIn == marketingOptIn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,phone,email,source,status,whatsappOptIn,marketingOptIn);

@override
String toString() {
  return 'Lead(id: $id, fullName: $fullName, phone: $phone, email: $email, source: $source, status: $status, whatsappOptIn: $whatsappOptIn, marketingOptIn: $marketingOptIn)';
}


}

/// @nodoc
abstract mixin class $LeadCopyWith<$Res>  {
  factory $LeadCopyWith(Lead value, $Res Function(Lead) _then) = _$LeadCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'full_name') String fullName, String phone, String email, String source, String status,@JsonKey(name: 'whatsapp_opt_in') bool whatsappOptIn,@JsonKey(name: 'marketing_opt_in') bool marketingOptIn
});




}
/// @nodoc
class _$LeadCopyWithImpl<$Res>
    implements $LeadCopyWith<$Res> {
  _$LeadCopyWithImpl(this._self, this._then);

  final Lead _self;
  final $Res Function(Lead) _then;

/// Create a copy of Lead
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fullName = null,Object? phone = null,Object? email = null,Object? source = null,Object? status = null,Object? whatsappOptIn = null,Object? marketingOptIn = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,whatsappOptIn: null == whatsappOptIn ? _self.whatsappOptIn : whatsappOptIn // ignore: cast_nullable_to_non_nullable
as bool,marketingOptIn: null == marketingOptIn ? _self.marketingOptIn : marketingOptIn // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Lead].
extension LeadPatterns on Lead {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Lead value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Lead() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Lead value)  $default,){
final _that = this;
switch (_that) {
case _Lead():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Lead value)?  $default,){
final _that = this;
switch (_that) {
case _Lead() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'full_name')  String fullName,  String phone,  String email,  String source,  String status, @JsonKey(name: 'whatsapp_opt_in')  bool whatsappOptIn, @JsonKey(name: 'marketing_opt_in')  bool marketingOptIn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Lead() when $default != null:
return $default(_that.id,_that.fullName,_that.phone,_that.email,_that.source,_that.status,_that.whatsappOptIn,_that.marketingOptIn);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'full_name')  String fullName,  String phone,  String email,  String source,  String status, @JsonKey(name: 'whatsapp_opt_in')  bool whatsappOptIn, @JsonKey(name: 'marketing_opt_in')  bool marketingOptIn)  $default,) {final _that = this;
switch (_that) {
case _Lead():
return $default(_that.id,_that.fullName,_that.phone,_that.email,_that.source,_that.status,_that.whatsappOptIn,_that.marketingOptIn);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'full_name')  String fullName,  String phone,  String email,  String source,  String status, @JsonKey(name: 'whatsapp_opt_in')  bool whatsappOptIn, @JsonKey(name: 'marketing_opt_in')  bool marketingOptIn)?  $default,) {final _that = this;
switch (_that) {
case _Lead() when $default != null:
return $default(_that.id,_that.fullName,_that.phone,_that.email,_that.source,_that.status,_that.whatsappOptIn,_that.marketingOptIn);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Lead implements Lead {
  const _Lead({required this.id, @JsonKey(name: 'full_name') required this.fullName, required this.phone, this.email = '', this.source = '', this.status = 'NEW', @JsonKey(name: 'whatsapp_opt_in') this.whatsappOptIn = false, @JsonKey(name: 'marketing_opt_in') this.marketingOptIn = false});
  factory _Lead.fromJson(Map<String, dynamic> json) => _$LeadFromJson(json);

@override final  String id;
@override@JsonKey(name: 'full_name') final  String fullName;
@override final  String phone;
@override@JsonKey() final  String email;
@override@JsonKey() final  String source;
@override@JsonKey() final  String status;
@override@JsonKey(name: 'whatsapp_opt_in') final  bool whatsappOptIn;
@override@JsonKey(name: 'marketing_opt_in') final  bool marketingOptIn;

/// Create a copy of Lead
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeadCopyWith<_Lead> get copyWith => __$LeadCopyWithImpl<_Lead>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LeadToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Lead&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email)&&(identical(other.source, source) || other.source == source)&&(identical(other.status, status) || other.status == status)&&(identical(other.whatsappOptIn, whatsappOptIn) || other.whatsappOptIn == whatsappOptIn)&&(identical(other.marketingOptIn, marketingOptIn) || other.marketingOptIn == marketingOptIn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,phone,email,source,status,whatsappOptIn,marketingOptIn);

@override
String toString() {
  return 'Lead(id: $id, fullName: $fullName, phone: $phone, email: $email, source: $source, status: $status, whatsappOptIn: $whatsappOptIn, marketingOptIn: $marketingOptIn)';
}


}

/// @nodoc
abstract mixin class _$LeadCopyWith<$Res> implements $LeadCopyWith<$Res> {
  factory _$LeadCopyWith(_Lead value, $Res Function(_Lead) _then) = __$LeadCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'full_name') String fullName, String phone, String email, String source, String status,@JsonKey(name: 'whatsapp_opt_in') bool whatsappOptIn,@JsonKey(name: 'marketing_opt_in') bool marketingOptIn
});




}
/// @nodoc
class __$LeadCopyWithImpl<$Res>
    implements _$LeadCopyWith<$Res> {
  __$LeadCopyWithImpl(this._self, this._then);

  final _Lead _self;
  final $Res Function(_Lead) _then;

/// Create a copy of Lead
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fullName = null,Object? phone = null,Object? email = null,Object? source = null,Object? status = null,Object? whatsappOptIn = null,Object? marketingOptIn = null,}) {
  return _then(_Lead(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,whatsappOptIn: null == whatsappOptIn ? _self.whatsappOptIn : whatsappOptIn // ignore: cast_nullable_to_non_nullable
as bool,marketingOptIn: null == marketingOptIn ? _self.marketingOptIn : marketingOptIn // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$Campaign {

 String get id; String get name; String get message; String get audience; String get status;@JsonKey(name: 'recipients_total') int get recipientsTotal;@JsonKey(name: 'sent_count') int get sentCount;@JsonKey(name: 'failed_count') int get failedCount;
/// Create a copy of Campaign
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CampaignCopyWith<Campaign> get copyWith => _$CampaignCopyWithImpl<Campaign>(this as Campaign, _$identity);

  /// Serializes this Campaign to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Campaign&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.message, message) || other.message == message)&&(identical(other.audience, audience) || other.audience == audience)&&(identical(other.status, status) || other.status == status)&&(identical(other.recipientsTotal, recipientsTotal) || other.recipientsTotal == recipientsTotal)&&(identical(other.sentCount, sentCount) || other.sentCount == sentCount)&&(identical(other.failedCount, failedCount) || other.failedCount == failedCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,message,audience,status,recipientsTotal,sentCount,failedCount);

@override
String toString() {
  return 'Campaign(id: $id, name: $name, message: $message, audience: $audience, status: $status, recipientsTotal: $recipientsTotal, sentCount: $sentCount, failedCount: $failedCount)';
}


}

/// @nodoc
abstract mixin class $CampaignCopyWith<$Res>  {
  factory $CampaignCopyWith(Campaign value, $Res Function(Campaign) _then) = _$CampaignCopyWithImpl;
@useResult
$Res call({
 String id, String name, String message, String audience, String status,@JsonKey(name: 'recipients_total') int recipientsTotal,@JsonKey(name: 'sent_count') int sentCount,@JsonKey(name: 'failed_count') int failedCount
});




}
/// @nodoc
class _$CampaignCopyWithImpl<$Res>
    implements $CampaignCopyWith<$Res> {
  _$CampaignCopyWithImpl(this._self, this._then);

  final Campaign _self;
  final $Res Function(Campaign) _then;

/// Create a copy of Campaign
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? message = null,Object? audience = null,Object? status = null,Object? recipientsTotal = null,Object? sentCount = null,Object? failedCount = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,audience: null == audience ? _self.audience : audience // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,recipientsTotal: null == recipientsTotal ? _self.recipientsTotal : recipientsTotal // ignore: cast_nullable_to_non_nullable
as int,sentCount: null == sentCount ? _self.sentCount : sentCount // ignore: cast_nullable_to_non_nullable
as int,failedCount: null == failedCount ? _self.failedCount : failedCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Campaign].
extension CampaignPatterns on Campaign {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Campaign value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Campaign() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Campaign value)  $default,){
final _that = this;
switch (_that) {
case _Campaign():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Campaign value)?  $default,){
final _that = this;
switch (_that) {
case _Campaign() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String message,  String audience,  String status, @JsonKey(name: 'recipients_total')  int recipientsTotal, @JsonKey(name: 'sent_count')  int sentCount, @JsonKey(name: 'failed_count')  int failedCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Campaign() when $default != null:
return $default(_that.id,_that.name,_that.message,_that.audience,_that.status,_that.recipientsTotal,_that.sentCount,_that.failedCount);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String message,  String audience,  String status, @JsonKey(name: 'recipients_total')  int recipientsTotal, @JsonKey(name: 'sent_count')  int sentCount, @JsonKey(name: 'failed_count')  int failedCount)  $default,) {final _that = this;
switch (_that) {
case _Campaign():
return $default(_that.id,_that.name,_that.message,_that.audience,_that.status,_that.recipientsTotal,_that.sentCount,_that.failedCount);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String message,  String audience,  String status, @JsonKey(name: 'recipients_total')  int recipientsTotal, @JsonKey(name: 'sent_count')  int sentCount, @JsonKey(name: 'failed_count')  int failedCount)?  $default,) {final _that = this;
switch (_that) {
case _Campaign() when $default != null:
return $default(_that.id,_that.name,_that.message,_that.audience,_that.status,_that.recipientsTotal,_that.sentCount,_that.failedCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Campaign implements Campaign {
  const _Campaign({required this.id, required this.name, required this.message, required this.audience, this.status = 'DRAFT', @JsonKey(name: 'recipients_total') this.recipientsTotal = 0, @JsonKey(name: 'sent_count') this.sentCount = 0, @JsonKey(name: 'failed_count') this.failedCount = 0});
  factory _Campaign.fromJson(Map<String, dynamic> json) => _$CampaignFromJson(json);

@override final  String id;
@override final  String name;
@override final  String message;
@override final  String audience;
@override@JsonKey() final  String status;
@override@JsonKey(name: 'recipients_total') final  int recipientsTotal;
@override@JsonKey(name: 'sent_count') final  int sentCount;
@override@JsonKey(name: 'failed_count') final  int failedCount;

/// Create a copy of Campaign
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CampaignCopyWith<_Campaign> get copyWith => __$CampaignCopyWithImpl<_Campaign>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CampaignToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Campaign&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.message, message) || other.message == message)&&(identical(other.audience, audience) || other.audience == audience)&&(identical(other.status, status) || other.status == status)&&(identical(other.recipientsTotal, recipientsTotal) || other.recipientsTotal == recipientsTotal)&&(identical(other.sentCount, sentCount) || other.sentCount == sentCount)&&(identical(other.failedCount, failedCount) || other.failedCount == failedCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,message,audience,status,recipientsTotal,sentCount,failedCount);

@override
String toString() {
  return 'Campaign(id: $id, name: $name, message: $message, audience: $audience, status: $status, recipientsTotal: $recipientsTotal, sentCount: $sentCount, failedCount: $failedCount)';
}


}

/// @nodoc
abstract mixin class _$CampaignCopyWith<$Res> implements $CampaignCopyWith<$Res> {
  factory _$CampaignCopyWith(_Campaign value, $Res Function(_Campaign) _then) = __$CampaignCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String message, String audience, String status,@JsonKey(name: 'recipients_total') int recipientsTotal,@JsonKey(name: 'sent_count') int sentCount,@JsonKey(name: 'failed_count') int failedCount
});




}
/// @nodoc
class __$CampaignCopyWithImpl<$Res>
    implements _$CampaignCopyWith<$Res> {
  __$CampaignCopyWithImpl(this._self, this._then);

  final _Campaign _self;
  final $Res Function(_Campaign) _then;

/// Create a copy of Campaign
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? message = null,Object? audience = null,Object? status = null,Object? recipientsTotal = null,Object? sentCount = null,Object? failedCount = null,}) {
  return _then(_Campaign(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,audience: null == audience ? _self.audience : audience // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,recipientsTotal: null == recipientsTotal ? _self.recipientsTotal : recipientsTotal // ignore: cast_nullable_to_non_nullable
as int,sentCount: null == sentCount ? _self.sentCount : sentCount // ignore: cast_nullable_to_non_nullable
as int,failedCount: null == failedCount ? _self.failedCount : failedCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$WhatsAppSession {

@JsonKey(name: 'tenant_id') String get tenantId;@JsonKey(name: 'tenant_name') String get tenantName;@JsonKey(name: 'session_name') String get sessionName;@JsonKey(name: 'phone_number') String get phoneNumber; String get status;
/// Create a copy of WhatsAppSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WhatsAppSessionCopyWith<WhatsAppSession> get copyWith => _$WhatsAppSessionCopyWithImpl<WhatsAppSession>(this as WhatsAppSession, _$identity);

  /// Serializes this WhatsAppSession to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WhatsAppSession&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.tenantName, tenantName) || other.tenantName == tenantName)&&(identical(other.sessionName, sessionName) || other.sessionName == sessionName)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tenantId,tenantName,sessionName,phoneNumber,status);

@override
String toString() {
  return 'WhatsAppSession(tenantId: $tenantId, tenantName: $tenantName, sessionName: $sessionName, phoneNumber: $phoneNumber, status: $status)';
}


}

/// @nodoc
abstract mixin class $WhatsAppSessionCopyWith<$Res>  {
  factory $WhatsAppSessionCopyWith(WhatsAppSession value, $Res Function(WhatsAppSession) _then) = _$WhatsAppSessionCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'tenant_id') String tenantId,@JsonKey(name: 'tenant_name') String tenantName,@JsonKey(name: 'session_name') String sessionName,@JsonKey(name: 'phone_number') String phoneNumber, String status
});




}
/// @nodoc
class _$WhatsAppSessionCopyWithImpl<$Res>
    implements $WhatsAppSessionCopyWith<$Res> {
  _$WhatsAppSessionCopyWithImpl(this._self, this._then);

  final WhatsAppSession _self;
  final $Res Function(WhatsAppSession) _then;

/// Create a copy of WhatsAppSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tenantId = null,Object? tenantName = null,Object? sessionName = null,Object? phoneNumber = null,Object? status = null,}) {
  return _then(_self.copyWith(
tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,tenantName: null == tenantName ? _self.tenantName : tenantName // ignore: cast_nullable_to_non_nullable
as String,sessionName: null == sessionName ? _self.sessionName : sessionName // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [WhatsAppSession].
extension WhatsAppSessionPatterns on WhatsAppSession {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WhatsAppSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WhatsAppSession() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WhatsAppSession value)  $default,){
final _that = this;
switch (_that) {
case _WhatsAppSession():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WhatsAppSession value)?  $default,){
final _that = this;
switch (_that) {
case _WhatsAppSession() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'tenant_id')  String tenantId, @JsonKey(name: 'tenant_name')  String tenantName, @JsonKey(name: 'session_name')  String sessionName, @JsonKey(name: 'phone_number')  String phoneNumber,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WhatsAppSession() when $default != null:
return $default(_that.tenantId,_that.tenantName,_that.sessionName,_that.phoneNumber,_that.status);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'tenant_id')  String tenantId, @JsonKey(name: 'tenant_name')  String tenantName, @JsonKey(name: 'session_name')  String sessionName, @JsonKey(name: 'phone_number')  String phoneNumber,  String status)  $default,) {final _that = this;
switch (_that) {
case _WhatsAppSession():
return $default(_that.tenantId,_that.tenantName,_that.sessionName,_that.phoneNumber,_that.status);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'tenant_id')  String tenantId, @JsonKey(name: 'tenant_name')  String tenantName, @JsonKey(name: 'session_name')  String sessionName, @JsonKey(name: 'phone_number')  String phoneNumber,  String status)?  $default,) {final _that = this;
switch (_that) {
case _WhatsAppSession() when $default != null:
return $default(_that.tenantId,_that.tenantName,_that.sessionName,_that.phoneNumber,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WhatsAppSession implements WhatsAppSession {
  const _WhatsAppSession({@JsonKey(name: 'tenant_id') this.tenantId = '', @JsonKey(name: 'tenant_name') this.tenantName = '', @JsonKey(name: 'session_name') this.sessionName = '', @JsonKey(name: 'phone_number') this.phoneNumber = '', this.status = 'NOT_CONNECTED'});
  factory _WhatsAppSession.fromJson(Map<String, dynamic> json) => _$WhatsAppSessionFromJson(json);

@override@JsonKey(name: 'tenant_id') final  String tenantId;
@override@JsonKey(name: 'tenant_name') final  String tenantName;
@override@JsonKey(name: 'session_name') final  String sessionName;
@override@JsonKey(name: 'phone_number') final  String phoneNumber;
@override@JsonKey() final  String status;

/// Create a copy of WhatsAppSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WhatsAppSessionCopyWith<_WhatsAppSession> get copyWith => __$WhatsAppSessionCopyWithImpl<_WhatsAppSession>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WhatsAppSessionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WhatsAppSession&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.tenantName, tenantName) || other.tenantName == tenantName)&&(identical(other.sessionName, sessionName) || other.sessionName == sessionName)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tenantId,tenantName,sessionName,phoneNumber,status);

@override
String toString() {
  return 'WhatsAppSession(tenantId: $tenantId, tenantName: $tenantName, sessionName: $sessionName, phoneNumber: $phoneNumber, status: $status)';
}


}

/// @nodoc
abstract mixin class _$WhatsAppSessionCopyWith<$Res> implements $WhatsAppSessionCopyWith<$Res> {
  factory _$WhatsAppSessionCopyWith(_WhatsAppSession value, $Res Function(_WhatsAppSession) _then) = __$WhatsAppSessionCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'tenant_id') String tenantId,@JsonKey(name: 'tenant_name') String tenantName,@JsonKey(name: 'session_name') String sessionName,@JsonKey(name: 'phone_number') String phoneNumber, String status
});




}
/// @nodoc
class __$WhatsAppSessionCopyWithImpl<$Res>
    implements _$WhatsAppSessionCopyWith<$Res> {
  __$WhatsAppSessionCopyWithImpl(this._self, this._then);

  final _WhatsAppSession _self;
  final $Res Function(_WhatsAppSession) _then;

/// Create a copy of WhatsAppSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tenantId = null,Object? tenantName = null,Object? sessionName = null,Object? phoneNumber = null,Object? status = null,}) {
  return _then(_WhatsAppSession(
tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,tenantName: null == tenantName ? _self.tenantName : tenantName // ignore: cast_nullable_to_non_nullable
as String,sessionName: null == sessionName ? _self.sessionName : sessionName // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$QRCode {

 String get mimetype; String get data;
/// Create a copy of QRCode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QRCodeCopyWith<QRCode> get copyWith => _$QRCodeCopyWithImpl<QRCode>(this as QRCode, _$identity);

  /// Serializes this QRCode to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QRCode&&(identical(other.mimetype, mimetype) || other.mimetype == mimetype)&&(identical(other.data, data) || other.data == data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mimetype,data);

@override
String toString() {
  return 'QRCode(mimetype: $mimetype, data: $data)';
}


}

/// @nodoc
abstract mixin class $QRCodeCopyWith<$Res>  {
  factory $QRCodeCopyWith(QRCode value, $Res Function(QRCode) _then) = _$QRCodeCopyWithImpl;
@useResult
$Res call({
 String mimetype, String data
});




}
/// @nodoc
class _$QRCodeCopyWithImpl<$Res>
    implements $QRCodeCopyWith<$Res> {
  _$QRCodeCopyWithImpl(this._self, this._then);

  final QRCode _self;
  final $Res Function(QRCode) _then;

/// Create a copy of QRCode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mimetype = null,Object? data = null,}) {
  return _then(_self.copyWith(
mimetype: null == mimetype ? _self.mimetype : mimetype // ignore: cast_nullable_to_non_nullable
as String,data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [QRCode].
extension QRCodePatterns on QRCode {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QRCode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QRCode() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QRCode value)  $default,){
final _that = this;
switch (_that) {
case _QRCode():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QRCode value)?  $default,){
final _that = this;
switch (_that) {
case _QRCode() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String mimetype,  String data)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QRCode() when $default != null:
return $default(_that.mimetype,_that.data);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String mimetype,  String data)  $default,) {final _that = this;
switch (_that) {
case _QRCode():
return $default(_that.mimetype,_that.data);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String mimetype,  String data)?  $default,) {final _that = this;
switch (_that) {
case _QRCode() when $default != null:
return $default(_that.mimetype,_that.data);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _QRCode implements QRCode {
  const _QRCode({this.mimetype = 'image/png', this.data = ''});
  factory _QRCode.fromJson(Map<String, dynamic> json) => _$QRCodeFromJson(json);

@override@JsonKey() final  String mimetype;
@override@JsonKey() final  String data;

/// Create a copy of QRCode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QRCodeCopyWith<_QRCode> get copyWith => __$QRCodeCopyWithImpl<_QRCode>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QRCodeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QRCode&&(identical(other.mimetype, mimetype) || other.mimetype == mimetype)&&(identical(other.data, data) || other.data == data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mimetype,data);

@override
String toString() {
  return 'QRCode(mimetype: $mimetype, data: $data)';
}


}

/// @nodoc
abstract mixin class _$QRCodeCopyWith<$Res> implements $QRCodeCopyWith<$Res> {
  factory _$QRCodeCopyWith(_QRCode value, $Res Function(_QRCode) _then) = __$QRCodeCopyWithImpl;
@override @useResult
$Res call({
 String mimetype, String data
});




}
/// @nodoc
class __$QRCodeCopyWithImpl<$Res>
    implements _$QRCodeCopyWith<$Res> {
  __$QRCodeCopyWithImpl(this._self, this._then);

  final _QRCode _self;
  final $Res Function(_QRCode) _then;

/// Create a copy of QRCode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mimetype = null,Object? data = null,}) {
  return _then(_QRCode(
mimetype: null == mimetype ? _self.mimetype : mimetype // ignore: cast_nullable_to_non_nullable
as String,data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$DailyReport {

 String get date;@JsonKey(name: 'active_members') int get activeMembers;@JsonKey(name: 'new_members') int get newMembers;@JsonKey(name: 'expiring_next_7_days') int get expiringNext7Days;@JsonKey(name: 'expired_today') int get expiredToday; int get renewals;@JsonKey(name: 'pending_payments_minor') int get pendingPaymentsMinor;@JsonKey(name: 'revenue_minor') int get revenueMinor; int get attendance;
/// Create a copy of DailyReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyReportCopyWith<DailyReport> get copyWith => _$DailyReportCopyWithImpl<DailyReport>(this as DailyReport, _$identity);

  /// Serializes this DailyReport to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyReport&&(identical(other.date, date) || other.date == date)&&(identical(other.activeMembers, activeMembers) || other.activeMembers == activeMembers)&&(identical(other.newMembers, newMembers) || other.newMembers == newMembers)&&(identical(other.expiringNext7Days, expiringNext7Days) || other.expiringNext7Days == expiringNext7Days)&&(identical(other.expiredToday, expiredToday) || other.expiredToday == expiredToday)&&(identical(other.renewals, renewals) || other.renewals == renewals)&&(identical(other.pendingPaymentsMinor, pendingPaymentsMinor) || other.pendingPaymentsMinor == pendingPaymentsMinor)&&(identical(other.revenueMinor, revenueMinor) || other.revenueMinor == revenueMinor)&&(identical(other.attendance, attendance) || other.attendance == attendance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,activeMembers,newMembers,expiringNext7Days,expiredToday,renewals,pendingPaymentsMinor,revenueMinor,attendance);

@override
String toString() {
  return 'DailyReport(date: $date, activeMembers: $activeMembers, newMembers: $newMembers, expiringNext7Days: $expiringNext7Days, expiredToday: $expiredToday, renewals: $renewals, pendingPaymentsMinor: $pendingPaymentsMinor, revenueMinor: $revenueMinor, attendance: $attendance)';
}


}

/// @nodoc
abstract mixin class $DailyReportCopyWith<$Res>  {
  factory $DailyReportCopyWith(DailyReport value, $Res Function(DailyReport) _then) = _$DailyReportCopyWithImpl;
@useResult
$Res call({
 String date,@JsonKey(name: 'active_members') int activeMembers,@JsonKey(name: 'new_members') int newMembers,@JsonKey(name: 'expiring_next_7_days') int expiringNext7Days,@JsonKey(name: 'expired_today') int expiredToday, int renewals,@JsonKey(name: 'pending_payments_minor') int pendingPaymentsMinor,@JsonKey(name: 'revenue_minor') int revenueMinor, int attendance
});




}
/// @nodoc
class _$DailyReportCopyWithImpl<$Res>
    implements $DailyReportCopyWith<$Res> {
  _$DailyReportCopyWithImpl(this._self, this._then);

  final DailyReport _self;
  final $Res Function(DailyReport) _then;

/// Create a copy of DailyReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? activeMembers = null,Object? newMembers = null,Object? expiringNext7Days = null,Object? expiredToday = null,Object? renewals = null,Object? pendingPaymentsMinor = null,Object? revenueMinor = null,Object? attendance = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,activeMembers: null == activeMembers ? _self.activeMembers : activeMembers // ignore: cast_nullable_to_non_nullable
as int,newMembers: null == newMembers ? _self.newMembers : newMembers // ignore: cast_nullable_to_non_nullable
as int,expiringNext7Days: null == expiringNext7Days ? _self.expiringNext7Days : expiringNext7Days // ignore: cast_nullable_to_non_nullable
as int,expiredToday: null == expiredToday ? _self.expiredToday : expiredToday // ignore: cast_nullable_to_non_nullable
as int,renewals: null == renewals ? _self.renewals : renewals // ignore: cast_nullable_to_non_nullable
as int,pendingPaymentsMinor: null == pendingPaymentsMinor ? _self.pendingPaymentsMinor : pendingPaymentsMinor // ignore: cast_nullable_to_non_nullable
as int,revenueMinor: null == revenueMinor ? _self.revenueMinor : revenueMinor // ignore: cast_nullable_to_non_nullable
as int,attendance: null == attendance ? _self.attendance : attendance // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DailyReport].
extension DailyReportPatterns on DailyReport {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyReport() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyReport value)  $default,){
final _that = this;
switch (_that) {
case _DailyReport():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyReport value)?  $default,){
final _that = this;
switch (_that) {
case _DailyReport() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String date, @JsonKey(name: 'active_members')  int activeMembers, @JsonKey(name: 'new_members')  int newMembers, @JsonKey(name: 'expiring_next_7_days')  int expiringNext7Days, @JsonKey(name: 'expired_today')  int expiredToday,  int renewals, @JsonKey(name: 'pending_payments_minor')  int pendingPaymentsMinor, @JsonKey(name: 'revenue_minor')  int revenueMinor,  int attendance)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyReport() when $default != null:
return $default(_that.date,_that.activeMembers,_that.newMembers,_that.expiringNext7Days,_that.expiredToday,_that.renewals,_that.pendingPaymentsMinor,_that.revenueMinor,_that.attendance);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String date, @JsonKey(name: 'active_members')  int activeMembers, @JsonKey(name: 'new_members')  int newMembers, @JsonKey(name: 'expiring_next_7_days')  int expiringNext7Days, @JsonKey(name: 'expired_today')  int expiredToday,  int renewals, @JsonKey(name: 'pending_payments_minor')  int pendingPaymentsMinor, @JsonKey(name: 'revenue_minor')  int revenueMinor,  int attendance)  $default,) {final _that = this;
switch (_that) {
case _DailyReport():
return $default(_that.date,_that.activeMembers,_that.newMembers,_that.expiringNext7Days,_that.expiredToday,_that.renewals,_that.pendingPaymentsMinor,_that.revenueMinor,_that.attendance);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String date, @JsonKey(name: 'active_members')  int activeMembers, @JsonKey(name: 'new_members')  int newMembers, @JsonKey(name: 'expiring_next_7_days')  int expiringNext7Days, @JsonKey(name: 'expired_today')  int expiredToday,  int renewals, @JsonKey(name: 'pending_payments_minor')  int pendingPaymentsMinor, @JsonKey(name: 'revenue_minor')  int revenueMinor,  int attendance)?  $default,) {final _that = this;
switch (_that) {
case _DailyReport() when $default != null:
return $default(_that.date,_that.activeMembers,_that.newMembers,_that.expiringNext7Days,_that.expiredToday,_that.renewals,_that.pendingPaymentsMinor,_that.revenueMinor,_that.attendance);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DailyReport implements DailyReport {
  const _DailyReport({required this.date, @JsonKey(name: 'active_members') this.activeMembers = 0, @JsonKey(name: 'new_members') this.newMembers = 0, @JsonKey(name: 'expiring_next_7_days') this.expiringNext7Days = 0, @JsonKey(name: 'expired_today') this.expiredToday = 0, this.renewals = 0, @JsonKey(name: 'pending_payments_minor') this.pendingPaymentsMinor = 0, @JsonKey(name: 'revenue_minor') this.revenueMinor = 0, this.attendance = 0});
  factory _DailyReport.fromJson(Map<String, dynamic> json) => _$DailyReportFromJson(json);

@override final  String date;
@override@JsonKey(name: 'active_members') final  int activeMembers;
@override@JsonKey(name: 'new_members') final  int newMembers;
@override@JsonKey(name: 'expiring_next_7_days') final  int expiringNext7Days;
@override@JsonKey(name: 'expired_today') final  int expiredToday;
@override@JsonKey() final  int renewals;
@override@JsonKey(name: 'pending_payments_minor') final  int pendingPaymentsMinor;
@override@JsonKey(name: 'revenue_minor') final  int revenueMinor;
@override@JsonKey() final  int attendance;

/// Create a copy of DailyReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyReportCopyWith<_DailyReport> get copyWith => __$DailyReportCopyWithImpl<_DailyReport>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DailyReportToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyReport&&(identical(other.date, date) || other.date == date)&&(identical(other.activeMembers, activeMembers) || other.activeMembers == activeMembers)&&(identical(other.newMembers, newMembers) || other.newMembers == newMembers)&&(identical(other.expiringNext7Days, expiringNext7Days) || other.expiringNext7Days == expiringNext7Days)&&(identical(other.expiredToday, expiredToday) || other.expiredToday == expiredToday)&&(identical(other.renewals, renewals) || other.renewals == renewals)&&(identical(other.pendingPaymentsMinor, pendingPaymentsMinor) || other.pendingPaymentsMinor == pendingPaymentsMinor)&&(identical(other.revenueMinor, revenueMinor) || other.revenueMinor == revenueMinor)&&(identical(other.attendance, attendance) || other.attendance == attendance));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,activeMembers,newMembers,expiringNext7Days,expiredToday,renewals,pendingPaymentsMinor,revenueMinor,attendance);

@override
String toString() {
  return 'DailyReport(date: $date, activeMembers: $activeMembers, newMembers: $newMembers, expiringNext7Days: $expiringNext7Days, expiredToday: $expiredToday, renewals: $renewals, pendingPaymentsMinor: $pendingPaymentsMinor, revenueMinor: $revenueMinor, attendance: $attendance)';
}


}

/// @nodoc
abstract mixin class _$DailyReportCopyWith<$Res> implements $DailyReportCopyWith<$Res> {
  factory _$DailyReportCopyWith(_DailyReport value, $Res Function(_DailyReport) _then) = __$DailyReportCopyWithImpl;
@override @useResult
$Res call({
 String date,@JsonKey(name: 'active_members') int activeMembers,@JsonKey(name: 'new_members') int newMembers,@JsonKey(name: 'expiring_next_7_days') int expiringNext7Days,@JsonKey(name: 'expired_today') int expiredToday, int renewals,@JsonKey(name: 'pending_payments_minor') int pendingPaymentsMinor,@JsonKey(name: 'revenue_minor') int revenueMinor, int attendance
});




}
/// @nodoc
class __$DailyReportCopyWithImpl<$Res>
    implements _$DailyReportCopyWith<$Res> {
  __$DailyReportCopyWithImpl(this._self, this._then);

  final _DailyReport _self;
  final $Res Function(_DailyReport) _then;

/// Create a copy of DailyReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? activeMembers = null,Object? newMembers = null,Object? expiringNext7Days = null,Object? expiredToday = null,Object? renewals = null,Object? pendingPaymentsMinor = null,Object? revenueMinor = null,Object? attendance = null,}) {
  return _then(_DailyReport(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,activeMembers: null == activeMembers ? _self.activeMembers : activeMembers // ignore: cast_nullable_to_non_nullable
as int,newMembers: null == newMembers ? _self.newMembers : newMembers // ignore: cast_nullable_to_non_nullable
as int,expiringNext7Days: null == expiringNext7Days ? _self.expiringNext7Days : expiringNext7Days // ignore: cast_nullable_to_non_nullable
as int,expiredToday: null == expiredToday ? _self.expiredToday : expiredToday // ignore: cast_nullable_to_non_nullable
as int,renewals: null == renewals ? _self.renewals : renewals // ignore: cast_nullable_to_non_nullable
as int,pendingPaymentsMinor: null == pendingPaymentsMinor ? _self.pendingPaymentsMinor : pendingPaymentsMinor // ignore: cast_nullable_to_non_nullable
as int,revenueMinor: null == revenueMinor ? _self.revenueMinor : revenueMinor // ignore: cast_nullable_to_non_nullable
as int,attendance: null == attendance ? _self.attendance : attendance // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$TenantUser {

 String get id; String get name; String get email; String get phone; String get role; String get status;@JsonKey(name: 'is_primary') bool get isPrimary;
/// Create a copy of TenantUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TenantUserCopyWith<TenantUser> get copyWith => _$TenantUserCopyWithImpl<TenantUser>(this as TenantUser, _$identity);

  /// Serializes this TenantUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TenantUser&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.role, role) || other.role == role)&&(identical(other.status, status) || other.status == status)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,email,phone,role,status,isPrimary);

@override
String toString() {
  return 'TenantUser(id: $id, name: $name, email: $email, phone: $phone, role: $role, status: $status, isPrimary: $isPrimary)';
}


}

/// @nodoc
abstract mixin class $TenantUserCopyWith<$Res>  {
  factory $TenantUserCopyWith(TenantUser value, $Res Function(TenantUser) _then) = _$TenantUserCopyWithImpl;
@useResult
$Res call({
 String id, String name, String email, String phone, String role, String status,@JsonKey(name: 'is_primary') bool isPrimary
});




}
/// @nodoc
class _$TenantUserCopyWithImpl<$Res>
    implements $TenantUserCopyWith<$Res> {
  _$TenantUserCopyWithImpl(this._self, this._then);

  final TenantUser _self;
  final $Res Function(TenantUser) _then;

/// Create a copy of TenantUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? email = null,Object? phone = null,Object? role = null,Object? status = null,Object? isPrimary = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TenantUser].
extension TenantUserPatterns on TenantUser {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TenantUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TenantUser() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TenantUser value)  $default,){
final _that = this;
switch (_that) {
case _TenantUser():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TenantUser value)?  $default,){
final _that = this;
switch (_that) {
case _TenantUser() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String email,  String phone,  String role,  String status, @JsonKey(name: 'is_primary')  bool isPrimary)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TenantUser() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.phone,_that.role,_that.status,_that.isPrimary);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String email,  String phone,  String role,  String status, @JsonKey(name: 'is_primary')  bool isPrimary)  $default,) {final _that = this;
switch (_that) {
case _TenantUser():
return $default(_that.id,_that.name,_that.email,_that.phone,_that.role,_that.status,_that.isPrimary);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String email,  String phone,  String role,  String status, @JsonKey(name: 'is_primary')  bool isPrimary)?  $default,) {final _that = this;
switch (_that) {
case _TenantUser() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.phone,_that.role,_that.status,_that.isPrimary);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TenantUser implements TenantUser {
  const _TenantUser({required this.id, required this.name, required this.email, this.phone = '', required this.role, this.status = 'ACTIVE', @JsonKey(name: 'is_primary') this.isPrimary = false});
  factory _TenantUser.fromJson(Map<String, dynamic> json) => _$TenantUserFromJson(json);

@override final  String id;
@override final  String name;
@override final  String email;
@override@JsonKey() final  String phone;
@override final  String role;
@override@JsonKey() final  String status;
@override@JsonKey(name: 'is_primary') final  bool isPrimary;

/// Create a copy of TenantUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TenantUserCopyWith<_TenantUser> get copyWith => __$TenantUserCopyWithImpl<_TenantUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TenantUserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TenantUser&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.role, role) || other.role == role)&&(identical(other.status, status) || other.status == status)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,email,phone,role,status,isPrimary);

@override
String toString() {
  return 'TenantUser(id: $id, name: $name, email: $email, phone: $phone, role: $role, status: $status, isPrimary: $isPrimary)';
}


}

/// @nodoc
abstract mixin class _$TenantUserCopyWith<$Res> implements $TenantUserCopyWith<$Res> {
  factory _$TenantUserCopyWith(_TenantUser value, $Res Function(_TenantUser) _then) = __$TenantUserCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String email, String phone, String role, String status,@JsonKey(name: 'is_primary') bool isPrimary
});




}
/// @nodoc
class __$TenantUserCopyWithImpl<$Res>
    implements _$TenantUserCopyWith<$Res> {
  __$TenantUserCopyWithImpl(this._self, this._then);

  final _TenantUser _self;
  final $Res Function(_TenantUser) _then;

/// Create a copy of TenantUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? email = null,Object? phone = null,Object? role = null,Object? status = null,Object? isPrimary = null,}) {
  return _then(_TenantUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$MessageLog {

 String get id;@JsonKey(name: 'recipient_phone') String get recipientPhone;@JsonKey(name: 'recipient_name') String get recipientName; String get category; String get body; String get status;@JsonKey(name: 'created_at') String get createdAt;
/// Create a copy of MessageLog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageLogCopyWith<MessageLog> get copyWith => _$MessageLogCopyWithImpl<MessageLog>(this as MessageLog, _$identity);

  /// Serializes this MessageLog to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageLog&&(identical(other.id, id) || other.id == id)&&(identical(other.recipientPhone, recipientPhone) || other.recipientPhone == recipientPhone)&&(identical(other.recipientName, recipientName) || other.recipientName == recipientName)&&(identical(other.category, category) || other.category == category)&&(identical(other.body, body) || other.body == body)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,recipientPhone,recipientName,category,body,status,createdAt);

@override
String toString() {
  return 'MessageLog(id: $id, recipientPhone: $recipientPhone, recipientName: $recipientName, category: $category, body: $body, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $MessageLogCopyWith<$Res>  {
  factory $MessageLogCopyWith(MessageLog value, $Res Function(MessageLog) _then) = _$MessageLogCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'recipient_phone') String recipientPhone,@JsonKey(name: 'recipient_name') String recipientName, String category, String body, String status,@JsonKey(name: 'created_at') String createdAt
});




}
/// @nodoc
class _$MessageLogCopyWithImpl<$Res>
    implements $MessageLogCopyWith<$Res> {
  _$MessageLogCopyWithImpl(this._self, this._then);

  final MessageLog _self;
  final $Res Function(MessageLog) _then;

/// Create a copy of MessageLog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? recipientPhone = null,Object? recipientName = null,Object? category = null,Object? body = null,Object? status = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,recipientPhone: null == recipientPhone ? _self.recipientPhone : recipientPhone // ignore: cast_nullable_to_non_nullable
as String,recipientName: null == recipientName ? _self.recipientName : recipientName // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [MessageLog].
extension MessageLogPatterns on MessageLog {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MessageLog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessageLog() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MessageLog value)  $default,){
final _that = this;
switch (_that) {
case _MessageLog():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MessageLog value)?  $default,){
final _that = this;
switch (_that) {
case _MessageLog() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'recipient_phone')  String recipientPhone, @JsonKey(name: 'recipient_name')  String recipientName,  String category,  String body,  String status, @JsonKey(name: 'created_at')  String createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessageLog() when $default != null:
return $default(_that.id,_that.recipientPhone,_that.recipientName,_that.category,_that.body,_that.status,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'recipient_phone')  String recipientPhone, @JsonKey(name: 'recipient_name')  String recipientName,  String category,  String body,  String status, @JsonKey(name: 'created_at')  String createdAt)  $default,) {final _that = this;
switch (_that) {
case _MessageLog():
return $default(_that.id,_that.recipientPhone,_that.recipientName,_that.category,_that.body,_that.status,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'recipient_phone')  String recipientPhone, @JsonKey(name: 'recipient_name')  String recipientName,  String category,  String body,  String status, @JsonKey(name: 'created_at')  String createdAt)?  $default,) {final _that = this;
switch (_that) {
case _MessageLog() when $default != null:
return $default(_that.id,_that.recipientPhone,_that.recipientName,_that.category,_that.body,_that.status,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MessageLog implements MessageLog {
  const _MessageLog({required this.id, @JsonKey(name: 'recipient_phone') required this.recipientPhone, @JsonKey(name: 'recipient_name') this.recipientName = '', required this.category, required this.body, required this.status, @JsonKey(name: 'created_at') required this.createdAt});
  factory _MessageLog.fromJson(Map<String, dynamic> json) => _$MessageLogFromJson(json);

@override final  String id;
@override@JsonKey(name: 'recipient_phone') final  String recipientPhone;
@override@JsonKey(name: 'recipient_name') final  String recipientName;
@override final  String category;
@override final  String body;
@override final  String status;
@override@JsonKey(name: 'created_at') final  String createdAt;

/// Create a copy of MessageLog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageLogCopyWith<_MessageLog> get copyWith => __$MessageLogCopyWithImpl<_MessageLog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MessageLogToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessageLog&&(identical(other.id, id) || other.id == id)&&(identical(other.recipientPhone, recipientPhone) || other.recipientPhone == recipientPhone)&&(identical(other.recipientName, recipientName) || other.recipientName == recipientName)&&(identical(other.category, category) || other.category == category)&&(identical(other.body, body) || other.body == body)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,recipientPhone,recipientName,category,body,status,createdAt);

@override
String toString() {
  return 'MessageLog(id: $id, recipientPhone: $recipientPhone, recipientName: $recipientName, category: $category, body: $body, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$MessageLogCopyWith<$Res> implements $MessageLogCopyWith<$Res> {
  factory _$MessageLogCopyWith(_MessageLog value, $Res Function(_MessageLog) _then) = __$MessageLogCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'recipient_phone') String recipientPhone,@JsonKey(name: 'recipient_name') String recipientName, String category, String body, String status,@JsonKey(name: 'created_at') String createdAt
});




}
/// @nodoc
class __$MessageLogCopyWithImpl<$Res>
    implements _$MessageLogCopyWith<$Res> {
  __$MessageLogCopyWithImpl(this._self, this._then);

  final _MessageLog _self;
  final $Res Function(_MessageLog) _then;

/// Create a copy of MessageLog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? recipientPhone = null,Object? recipientName = null,Object? category = null,Object? body = null,Object? status = null,Object? createdAt = null,}) {
  return _then(_MessageLog(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,recipientPhone: null == recipientPhone ? _self.recipientPhone : recipientPhone // ignore: cast_nullable_to_non_nullable
as String,recipientName: null == recipientName ? _self.recipientName : recipientName // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$AutomationSettings {

@JsonKey(name: 'expiry_enabled') bool get expiryEnabled;@JsonKey(name: 'expiry_days_before') List<int> get expiryDaysBefore;@JsonKey(name: 'holiday_enabled') bool get holidayEnabled;@JsonKey(name: 'birthday_enabled') bool get birthdayEnabled;@JsonKey(name: 'campaigns_enabled') bool get campaignsEnabled;@JsonKey(name: 'daily_report_enabled') bool get dailyReportEnabled;@JsonKey(name: 'daily_report_phone') String get dailyReportPhone;
/// Create a copy of AutomationSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AutomationSettingsCopyWith<AutomationSettings> get copyWith => _$AutomationSettingsCopyWithImpl<AutomationSettings>(this as AutomationSettings, _$identity);

  /// Serializes this AutomationSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AutomationSettings&&(identical(other.expiryEnabled, expiryEnabled) || other.expiryEnabled == expiryEnabled)&&const DeepCollectionEquality().equals(other.expiryDaysBefore, expiryDaysBefore)&&(identical(other.holidayEnabled, holidayEnabled) || other.holidayEnabled == holidayEnabled)&&(identical(other.birthdayEnabled, birthdayEnabled) || other.birthdayEnabled == birthdayEnabled)&&(identical(other.campaignsEnabled, campaignsEnabled) || other.campaignsEnabled == campaignsEnabled)&&(identical(other.dailyReportEnabled, dailyReportEnabled) || other.dailyReportEnabled == dailyReportEnabled)&&(identical(other.dailyReportPhone, dailyReportPhone) || other.dailyReportPhone == dailyReportPhone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,expiryEnabled,const DeepCollectionEquality().hash(expiryDaysBefore),holidayEnabled,birthdayEnabled,campaignsEnabled,dailyReportEnabled,dailyReportPhone);

@override
String toString() {
  return 'AutomationSettings(expiryEnabled: $expiryEnabled, expiryDaysBefore: $expiryDaysBefore, holidayEnabled: $holidayEnabled, birthdayEnabled: $birthdayEnabled, campaignsEnabled: $campaignsEnabled, dailyReportEnabled: $dailyReportEnabled, dailyReportPhone: $dailyReportPhone)';
}


}

/// @nodoc
abstract mixin class $AutomationSettingsCopyWith<$Res>  {
  factory $AutomationSettingsCopyWith(AutomationSettings value, $Res Function(AutomationSettings) _then) = _$AutomationSettingsCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'expiry_enabled') bool expiryEnabled,@JsonKey(name: 'expiry_days_before') List<int> expiryDaysBefore,@JsonKey(name: 'holiday_enabled') bool holidayEnabled,@JsonKey(name: 'birthday_enabled') bool birthdayEnabled,@JsonKey(name: 'campaigns_enabled') bool campaignsEnabled,@JsonKey(name: 'daily_report_enabled') bool dailyReportEnabled,@JsonKey(name: 'daily_report_phone') String dailyReportPhone
});




}
/// @nodoc
class _$AutomationSettingsCopyWithImpl<$Res>
    implements $AutomationSettingsCopyWith<$Res> {
  _$AutomationSettingsCopyWithImpl(this._self, this._then);

  final AutomationSettings _self;
  final $Res Function(AutomationSettings) _then;

/// Create a copy of AutomationSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? expiryEnabled = null,Object? expiryDaysBefore = null,Object? holidayEnabled = null,Object? birthdayEnabled = null,Object? campaignsEnabled = null,Object? dailyReportEnabled = null,Object? dailyReportPhone = null,}) {
  return _then(_self.copyWith(
expiryEnabled: null == expiryEnabled ? _self.expiryEnabled : expiryEnabled // ignore: cast_nullable_to_non_nullable
as bool,expiryDaysBefore: null == expiryDaysBefore ? _self.expiryDaysBefore : expiryDaysBefore // ignore: cast_nullable_to_non_nullable
as List<int>,holidayEnabled: null == holidayEnabled ? _self.holidayEnabled : holidayEnabled // ignore: cast_nullable_to_non_nullable
as bool,birthdayEnabled: null == birthdayEnabled ? _self.birthdayEnabled : birthdayEnabled // ignore: cast_nullable_to_non_nullable
as bool,campaignsEnabled: null == campaignsEnabled ? _self.campaignsEnabled : campaignsEnabled // ignore: cast_nullable_to_non_nullable
as bool,dailyReportEnabled: null == dailyReportEnabled ? _self.dailyReportEnabled : dailyReportEnabled // ignore: cast_nullable_to_non_nullable
as bool,dailyReportPhone: null == dailyReportPhone ? _self.dailyReportPhone : dailyReportPhone // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AutomationSettings].
extension AutomationSettingsPatterns on AutomationSettings {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AutomationSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AutomationSettings() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AutomationSettings value)  $default,){
final _that = this;
switch (_that) {
case _AutomationSettings():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AutomationSettings value)?  $default,){
final _that = this;
switch (_that) {
case _AutomationSettings() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'expiry_enabled')  bool expiryEnabled, @JsonKey(name: 'expiry_days_before')  List<int> expiryDaysBefore, @JsonKey(name: 'holiday_enabled')  bool holidayEnabled, @JsonKey(name: 'birthday_enabled')  bool birthdayEnabled, @JsonKey(name: 'campaigns_enabled')  bool campaignsEnabled, @JsonKey(name: 'daily_report_enabled')  bool dailyReportEnabled, @JsonKey(name: 'daily_report_phone')  String dailyReportPhone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AutomationSettings() when $default != null:
return $default(_that.expiryEnabled,_that.expiryDaysBefore,_that.holidayEnabled,_that.birthdayEnabled,_that.campaignsEnabled,_that.dailyReportEnabled,_that.dailyReportPhone);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'expiry_enabled')  bool expiryEnabled, @JsonKey(name: 'expiry_days_before')  List<int> expiryDaysBefore, @JsonKey(name: 'holiday_enabled')  bool holidayEnabled, @JsonKey(name: 'birthday_enabled')  bool birthdayEnabled, @JsonKey(name: 'campaigns_enabled')  bool campaignsEnabled, @JsonKey(name: 'daily_report_enabled')  bool dailyReportEnabled, @JsonKey(name: 'daily_report_phone')  String dailyReportPhone)  $default,) {final _that = this;
switch (_that) {
case _AutomationSettings():
return $default(_that.expiryEnabled,_that.expiryDaysBefore,_that.holidayEnabled,_that.birthdayEnabled,_that.campaignsEnabled,_that.dailyReportEnabled,_that.dailyReportPhone);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'expiry_enabled')  bool expiryEnabled, @JsonKey(name: 'expiry_days_before')  List<int> expiryDaysBefore, @JsonKey(name: 'holiday_enabled')  bool holidayEnabled, @JsonKey(name: 'birthday_enabled')  bool birthdayEnabled, @JsonKey(name: 'campaigns_enabled')  bool campaignsEnabled, @JsonKey(name: 'daily_report_enabled')  bool dailyReportEnabled, @JsonKey(name: 'daily_report_phone')  String dailyReportPhone)?  $default,) {final _that = this;
switch (_that) {
case _AutomationSettings() when $default != null:
return $default(_that.expiryEnabled,_that.expiryDaysBefore,_that.holidayEnabled,_that.birthdayEnabled,_that.campaignsEnabled,_that.dailyReportEnabled,_that.dailyReportPhone);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AutomationSettings implements AutomationSettings {
  const _AutomationSettings({@JsonKey(name: 'expiry_enabled') this.expiryEnabled = true, @JsonKey(name: 'expiry_days_before') required this.expiryDaysBefore, @JsonKey(name: 'holiday_enabled') this.holidayEnabled = true, @JsonKey(name: 'birthday_enabled') this.birthdayEnabled = true, @JsonKey(name: 'campaigns_enabled') this.campaignsEnabled = true, @JsonKey(name: 'daily_report_enabled') this.dailyReportEnabled = true, @JsonKey(name: 'daily_report_phone') this.dailyReportPhone = ''});
  factory _AutomationSettings.fromJson(Map<String, dynamic> json) => _$AutomationSettingsFromJson(json);

@override@JsonKey(name: 'expiry_enabled') final  bool expiryEnabled;
@override@JsonKey(name: 'expiry_days_before') final  List<int> expiryDaysBefore;
@override@JsonKey(name: 'holiday_enabled') final  bool holidayEnabled;
@override@JsonKey(name: 'birthday_enabled') final  bool birthdayEnabled;
@override@JsonKey(name: 'campaigns_enabled') final  bool campaignsEnabled;
@override@JsonKey(name: 'daily_report_enabled') final  bool dailyReportEnabled;
@override@JsonKey(name: 'daily_report_phone') final  String dailyReportPhone;

/// Create a copy of AutomationSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AutomationSettingsCopyWith<_AutomationSettings> get copyWith => __$AutomationSettingsCopyWithImpl<_AutomationSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AutomationSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AutomationSettings&&(identical(other.expiryEnabled, expiryEnabled) || other.expiryEnabled == expiryEnabled)&&const DeepCollectionEquality().equals(other.expiryDaysBefore, expiryDaysBefore)&&(identical(other.holidayEnabled, holidayEnabled) || other.holidayEnabled == holidayEnabled)&&(identical(other.birthdayEnabled, birthdayEnabled) || other.birthdayEnabled == birthdayEnabled)&&(identical(other.campaignsEnabled, campaignsEnabled) || other.campaignsEnabled == campaignsEnabled)&&(identical(other.dailyReportEnabled, dailyReportEnabled) || other.dailyReportEnabled == dailyReportEnabled)&&(identical(other.dailyReportPhone, dailyReportPhone) || other.dailyReportPhone == dailyReportPhone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,expiryEnabled,const DeepCollectionEquality().hash(expiryDaysBefore),holidayEnabled,birthdayEnabled,campaignsEnabled,dailyReportEnabled,dailyReportPhone);

@override
String toString() {
  return 'AutomationSettings(expiryEnabled: $expiryEnabled, expiryDaysBefore: $expiryDaysBefore, holidayEnabled: $holidayEnabled, birthdayEnabled: $birthdayEnabled, campaignsEnabled: $campaignsEnabled, dailyReportEnabled: $dailyReportEnabled, dailyReportPhone: $dailyReportPhone)';
}


}

/// @nodoc
abstract mixin class _$AutomationSettingsCopyWith<$Res> implements $AutomationSettingsCopyWith<$Res> {
  factory _$AutomationSettingsCopyWith(_AutomationSettings value, $Res Function(_AutomationSettings) _then) = __$AutomationSettingsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'expiry_enabled') bool expiryEnabled,@JsonKey(name: 'expiry_days_before') List<int> expiryDaysBefore,@JsonKey(name: 'holiday_enabled') bool holidayEnabled,@JsonKey(name: 'birthday_enabled') bool birthdayEnabled,@JsonKey(name: 'campaigns_enabled') bool campaignsEnabled,@JsonKey(name: 'daily_report_enabled') bool dailyReportEnabled,@JsonKey(name: 'daily_report_phone') String dailyReportPhone
});




}
/// @nodoc
class __$AutomationSettingsCopyWithImpl<$Res>
    implements _$AutomationSettingsCopyWith<$Res> {
  __$AutomationSettingsCopyWithImpl(this._self, this._then);

  final _AutomationSettings _self;
  final $Res Function(_AutomationSettings) _then;

/// Create a copy of AutomationSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? expiryEnabled = null,Object? expiryDaysBefore = null,Object? holidayEnabled = null,Object? birthdayEnabled = null,Object? campaignsEnabled = null,Object? dailyReportEnabled = null,Object? dailyReportPhone = null,}) {
  return _then(_AutomationSettings(
expiryEnabled: null == expiryEnabled ? _self.expiryEnabled : expiryEnabled // ignore: cast_nullable_to_non_nullable
as bool,expiryDaysBefore: null == expiryDaysBefore ? _self.expiryDaysBefore : expiryDaysBefore // ignore: cast_nullable_to_non_nullable
as List<int>,holidayEnabled: null == holidayEnabled ? _self.holidayEnabled : holidayEnabled // ignore: cast_nullable_to_non_nullable
as bool,birthdayEnabled: null == birthdayEnabled ? _self.birthdayEnabled : birthdayEnabled // ignore: cast_nullable_to_non_nullable
as bool,campaignsEnabled: null == campaignsEnabled ? _self.campaignsEnabled : campaignsEnabled // ignore: cast_nullable_to_non_nullable
as bool,dailyReportEnabled: null == dailyReportEnabled ? _self.dailyReportEnabled : dailyReportEnabled // ignore: cast_nullable_to_non_nullable
as bool,dailyReportPhone: null == dailyReportPhone ? _self.dailyReportPhone : dailyReportPhone // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
