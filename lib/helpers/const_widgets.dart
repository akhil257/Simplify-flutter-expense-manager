import 'package:flutter/material.dart';

class LoadButton extends StatefulWidget {
  LoadButton({required this.fun, required this.text});
  final Function fun;
  final String text;

  @override
  _LoadButtonState createState() => _LoadButtonState();
}

class _LoadButtonState extends State<LoadButton> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading
          ? () {}
          : () async {
              setState(() {
                isLoading = true;
              });
              try{
                await widget.fun();
              }catch(e){}
              setState(() {
                isLoading = false;
              });
            },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          isLoading
              ? Container(
                  width: 22,
                  height: 22,
                  padding: EdgeInsets.all(4),
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.white,
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                         Colors.green.shade600),
                  ))
              : Icon(
                  Icons.add,
                  size: 34,
                ),
          Text(
            "  " + widget.text,
          ),
        ],
      ),
    );
  }
}

class Pic extends StatelessWidget {
  Pic(this.imgUrl);
  final String imgUrl;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        width: double.infinity,
        child: SafeArea(
          child: InteractiveViewer(
            child: Center(child: Image.network(imgUrl)),
            clipBehavior: Clip.none,
          ),
        ),
      ),
    );
  }
}
