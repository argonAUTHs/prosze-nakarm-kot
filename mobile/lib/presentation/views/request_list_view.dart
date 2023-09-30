import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/request.dart';
import '../blocs/request_list_bloc/request_list_bloc.dart';
import '../blocs/request_list_bloc/request_list_event.dart';
import '../blocs/request_list_bloc/request_list_state.dart';
import '../widgets/request_list_widget.dart';

class RequestListView extends StatefulWidget {
  const RequestListView({Key? key}) : super(key: key);

  @override
  State<RequestListView> createState() => _RequestListViewState();
}

class _RequestListViewState extends State<RequestListView> {
  double fem = 1;
  double ffem = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_left, color: Colors.blue),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Access requests',
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.of(context).pushNamed("/scan");
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.qr_code_2_outlined, color: Colors.white,size: 40,),
      ),
      body: BlocProvider.value(
        value: BlocProvider.of<RequestListBloc>(context)..add(const GetRequestList()),
        child: SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width/35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 15,
                    child: BlocBuilder<RequestListBloc, RequestListState>(
                      builder: (_, state){
                        print("**********************************************");
                        print(state);
                        if(state is RequestListLoading){
                          return const Center(
                            child: CupertinoActivityIndicator(),
                          );
                        }if(state is RequestListDone){
                          return _buildList(state.requestList!);
                        }
                        else{
                          return const Center();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildList(List<Request> requests){
    return ListView(
      children: [
        ...requests.map((e) => RequestWidget(request: e)),
      ],
    );
  }

}