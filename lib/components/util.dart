import "package:flutter/material.dart";
import '../service.dart';

class ErrorText extends StatelessWidget {
  final Object error;
  final TextStyle style = TextStyle(color: Color(0xffcc0000), inherit: true);

  ErrorText(this.error);

  @override
  Widget build(BuildContext context) {
    return Text(
      _renderError(error),
      style: style,
    );
  }
  
  String _renderError(Object error) {
    if (error == null) {
      return "";
    }
    if (error is ServiceException) {
      return error.response;
    } else if (error is String) {
      return error;
    } else {
      return "Something went wrong";
    }
  }
}
