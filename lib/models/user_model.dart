// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  final String? id;
  final String? firstName;
  final String? fullName;
  final String? authenticationId;
  final String? emailId;
  final String? phoneCode;
  final String? ticket;
  final String? authentication;
  final String? event;
  final FormData? formData;
  final bool? paymentStatus;
  final int? orderNumber;
  final bool? synced;
  final bool? sendCard;
  final bool? attendance;
  final bool? approve;
  final String? franchise;
  final String? userModelAbstract;
  final bool? abstractUploaded;
  final bool? isVerified;
  final List<dynamic>? features;
  // final DateTime? lastFaceMatchDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;
  final String? awsKeyImage;
  final String? keyImage;
  final String? profileImage;
  final bool? instarecap;
  final bool? instasnap;
  final String? userType;
  final String? error;
  final bool? reject;
  final bool? regInProgress;
  final int? token;
  final String? bio;
  final bool? isReturnee;
  final DateTime? attendanceDate;

  UserModel({
    this.id,
    this.firstName,
    this.fullName,
    this.authenticationId,
    this.emailId,
    this.phoneCode,
    this.ticket,
    this.authentication,
    this.event,
    this.formData,
    this.paymentStatus,
    this.orderNumber,
    this.synced,
    this.sendCard,
    this.attendance,
    this.approve,
    this.franchise,
    this.userModelAbstract,
    this.abstractUploaded,
    this.isVerified,
    this.features,
    // this.lastFaceMatchDate,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.awsKeyImage,
    this.keyImage,
    this.profileImage,
    this.instarecap,
    this.instasnap,
    this.userType,
    this.error,
    this.reject,
    this.regInProgress,
    this.token,
    this.bio,
    this.isReturnee,
    this.attendanceDate,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json["_id"],
    firstName: json["firstName"],
    fullName: json["fullName"],
    authenticationId: json["authenticationId"],
    emailId: json["emailId"],
    phoneCode: json["phoneCode"],
    ticket: json["ticket"],
    authentication: json["authentication"],
    event: json["event"],
    formData:
        json["formData"] == null ? null : FormData.fromJson(json["formData"]),
    paymentStatus: json["paymentStatus"],
    orderNumber: json["orderNumber"],
    synced: json["synced"],
    sendCard: json["sendCard"],
    attendance: json["attendance"],
    approve: json["approve"],
    franchise: json["franchise"],
    userModelAbstract: json["abstract"],
    abstractUploaded: json["abstractUploaded"],
    isVerified: json["isVerified"],
    features:
        json["features"] == null
            ? []
            : List<dynamic>.from(json["features"]!.map((x) => x)),
    // lastFaceMatchDate: json["lastFaceMatchDate"],
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt:
        json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
    awsKeyImage: json["awsKeyImage"],
    keyImage: json["keyImage"],
    profileImage: json["profileImage"],
    instarecap: json["instarecap"],
    instasnap: json["instasnap"],
    userType: json["userType"],
    error: json["error"],
    reject: json["reject"],
    regInProgress: json["regInProgress"],
    token: json["token"],
    bio: json["bio"],
    isReturnee: json["isReturnee"],
    attendanceDate:
        json["attendanceDate"] == null
            ? null
            : DateTime.parse(json["attendanceDate"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "firstName": firstName,
    "fullName": fullName,
    "authenticationId": authenticationId,
    "emailId": emailId,
    "phoneCode": phoneCode,
    "ticket": ticket,
    "authentication": authentication,
    "event": event,
    "formData": formData?.toJson(),
    "paymentStatus": paymentStatus,
    "orderNumber": orderNumber,
    "synced": synced,
    "sendCard": sendCard,
    "attendance": attendance,
    "approve": approve,
    "franchise": franchise,
    "abstract": userModelAbstract,
    "abstractUploaded": abstractUploaded,
    "isVerified": isVerified,
    "features":
        features == null ? [] : List<dynamic>.from(features!.map((x) => x)),
    // "lastFaceMatchDate": lastFaceMatchDate,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
    "awsKeyImage": awsKeyImage,
    "keyImage": keyImage,
    "profileImage": profileImage,
    "instarecap": instarecap,
    "instasnap": instasnap,
    "userType": userType,
    "error": error,
    "reject": reject,
    "regInProgress": regInProgress,
    "token": token,
    "bio": bio,
    "isReturnee": isReturnee,
    "attendanceDate": attendanceDate?.toIso8601String(),
  };
}

class FormData {
  final String? authenticationType;
  final String? phoneNumberLength;

  FormData({this.authenticationType, this.phoneNumberLength});

  factory FormData.fromJson(Map<String, dynamic> json) => FormData(
    authenticationType: json["authenticationType"],
    phoneNumberLength: json["PhoneNumberLength"],
  );

  Map<String, dynamic> toJson() => {
    "authenticationType": authenticationType,
    "PhoneNumberLength": phoneNumberLength,
  };
}
