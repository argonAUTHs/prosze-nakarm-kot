import "package:flutter/material.dart";


class MainAppView extends StatefulWidget {
  const MainAppView({Key? key}) : super(key: key);

  @override
  State<MainAppView> createState() => _MainAppViewState();
}

class _MainAppViewState extends State<MainAppView> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: (){
              Navigator.pushNamed(context, "/requestlist");
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20)
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.home
                  ),
                  Text("Give access to your house")
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: (){
              Navigator.pushNamed(context, "/request");
            },
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20)
              ),
              child: Row(
                children: [
                  Icon(
                      Icons.home
                  ),
                  Text("Rent a house")
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: (){
              Navigator.pushNamed(context, "/authorize");
            },
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20)
              ),
              child: Row(
                children: [
                  Icon(
                      Icons.home
                  ),
                  Text("Enter the house")
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
