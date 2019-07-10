import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class WidgetHelper {
  static void showFullScreenImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: PhotoView(
            initialScale: 0.65,
            minScale: 0.55,
            maxScale: 0.75,
            imageProvider: NetworkImage(imageUrl),
            enableRotation: false,
            backgroundDecoration: BoxDecoration(color: Colors.transparent),
          ),
        );
      },
    );
  }

  static SnackBar buildSnackbar(GlobalKey<ScaffoldState> scaffoldState,
      String title, Color color, IconData icon) {
    final snackbar = SnackBar(
      content: Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 10.0),
            child: Icon(
              icon,
              size: 20.0,
            ),
          ),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      duration: Duration(seconds: 2),
      backgroundColor: color,
    );
    return snackbar;
  }
}
