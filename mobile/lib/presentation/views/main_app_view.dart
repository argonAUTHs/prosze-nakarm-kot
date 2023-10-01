import "package:flutter/material.dart";


class MainAppView extends StatefulWidget {
  const MainAppView({Key? key}) : super(key: key);

  @override
  State<MainAppView> createState() => _MainAppViewState();
}

class _MainAppViewState extends State<MainAppView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ListView(
              shrinkWrap: true,
              children: <Widget>[
                ListTile(
                  onTap: (){
                    Navigator.pushNamed(context, "/requestlist");
                  },
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1, color: Colors.grey),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  trailing: const Icon(Icons.arrow_right, color: Colors.blue, size: 25,),
                  leading: const Icon(Icons.home, color: Colors.blue, size: 30,),
                  title: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Text("Give access to your house"),
                  ),
                ),
                const SizedBox(height: 10,),
                ListTile(
                  onTap: (){
                    Navigator.pushNamed(context, "/request");
                  },
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1, color: Colors.grey),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  trailing: const Icon(Icons.arrow_right, color: Colors.blue, size: 25,),
                  leading: const Icon(Icons.home_work, color: Colors.blue, size: 30,),
                  title: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Text("Rent a house"),
                  ),
                ),
                const SizedBox(height: 10,),
                ListTile(
                  onTap: (){
                    Navigator.pushNamed(context, "/authorize");
                  },
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1, color: Colors.grey),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  trailing: const Icon(Icons.arrow_right, color: Colors.blue, size: 25,),
                  leading: const Icon(Icons.login, color: Colors.blue, size: 30,),
                  title: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Text("Enter the house"),
                  ),
                ),
              ],
            ),
          ],
        ),
        // child: Column(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   crossAxisAlignment: CrossAxisAlignment.center,
        //   children: [
        //     GestureDetector(
        //       onTap: (){
        //         Navigator.pushNamed(context, "/requestlist");
        //       },
        //       child: Container(
        //         decoration: BoxDecoration(
        //             borderRadius: BorderRadius.circular(20)
        //         ),
        //         child: Row(
        //           children: [
        //             Icon(
        //                 Icons.home,
        //               color: Colors.blue,
        //             ),
        //             Text("Give access to your house")
        //           ],
        //         ),
        //       ),
        //     ),
        //     GestureDetector(
        //       onTap: (){
        //         Navigator.pushNamed(context, "/request");
        //       },
        //       child: Container(
        //         decoration: BoxDecoration(
        //             borderRadius: BorderRadius.circular(20)
        //         ),
        //         child: Row(
        //           children: [
        //             Icon(
        //                 Icons.home_work,
        //               color: Colors.blue,
        //             ),
        //             Text("Rent a house")
        //           ],
        //         ),
        //       ),
        //     ),
        //     GestureDetector(
        //       onTap: (){
        //         Navigator.pushNamed(context, "/authorize");
        //       },
        //       child: Container(
        //         decoration: BoxDecoration(
        //             borderRadius: BorderRadius.circular(20)
        //         ),
        //         child: Row(
        //           children: [
        //             Icon(
        //                 Icons.login,
        //               color: Colors.blue,
        //             ),
        //             Text("Enter the house")
        //           ],
        //         ),
        //       ),
        //     )
        //   ],
        // ),
      ),
    );
  }
}
