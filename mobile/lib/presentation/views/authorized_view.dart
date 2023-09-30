import 'package:flutter/material.dart';

class AuthorizedView extends StatefulWidget {
  const AuthorizedView({Key? key}) : super(key: key);

  @override
  State<AuthorizedView> createState() => _AuthorizedViewState();
}

class _AuthorizedViewState extends State<AuthorizedView> {
  double fem = 1;
  double ffem = 1;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        // submittingviewZt6 (29:103)
        padding:  EdgeInsets.fromLTRB(82*fem, 161*fem, 83*fem, 105*fem),
        width:  double.infinity,
        decoration:  const BoxDecoration (
          color:  Color(0xffffffff),
        ),
        child:
        Center(
          child: Column(
            crossAxisAlignment:  CrossAxisAlignment.center,
            children:  [
              Icon(
                Icons.check_circle,
                color: Colors.grey.withOpacity(0.1),
                size: 250,
              ),
              Container(
                // formsubmittedMZ4 (32:145)
                margin:  EdgeInsets.fromLTRB(2*fem, 0*fem, 0*fem, 100*fem),
                child:
                Text(
                  textAlign: TextAlign.center,
                  'Credential presented!',
                ),
              ),
              GestureDetector(
                onTap: (){
                  Navigator.of(context).pop();
                },
                child: Container(
                  // autogroup2gnweHG (HqGhuvuHaAzwkH2iyk2gnW)
                  margin:  EdgeInsets.fromLTRB(0*fem, 0*fem, 1*fem, 19*fem),
                  width:  224*fem,
                  height:  48*fem,
                  decoration:  BoxDecoration (
                    color:  Colors.blue,
                    borderRadius:  BorderRadius.circular(10*fem),
                  ),
                  child:
                  Center(
                    child:
                    Text(
                      'Go back to menu\n',
                      textAlign:  TextAlign.center,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}