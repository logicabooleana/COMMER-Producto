import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:producto/app/models/catalogo_model.dart';
import 'package:producto/app/modules/mainScreen/controllers/welcome_controller.dart';
import 'package:producto/app/utils/widgets_utils_app.dart';
import 'package:url_launcher/url_launcher.dart';

class ScanScreenView extends StatelessWidget {
  ScanScreenView({Key? key});

  final WelcomeController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return scaffoldScan(buildContext: context);
  }

  Scaffold scaffoldScan({required BuildContext buildContext}) {
    Color color = Theme.of(buildContext).brightness == Brightness.dark
        ? Colors.white54
        : Colors.black38;
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Theme.of(buildContext).scaffoldBackgroundColor,
        iconTheme: Theme.of(buildContext)
            .iconTheme
            .copyWith(color: Theme.of(buildContext).textTheme.bodyText1!.color),
        title: TextButton(
          onPressed: () => showModalBottomSheetSetting(buildContext),
          child: Text(
            "Crear mi catálogo",
            style: TextStyle(
                fontSize: 16,
                color: Theme.of(buildContext).textTheme.bodyText1!.color),
          ),
        ),
        actions: <Widget>[
          WidgetsUtilsApp().buttonThemeBrightness(context: buildContext),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            InkWell(
              borderRadius: BorderRadius.all(Radius.circular(30.0)),
              splashColor: Theme.of(buildContext).primaryColor,
              onTap: () => scanBarcodeNormal(context: buildContext),
              child: Container(
                margin: const EdgeInsets.all(0.0),
                padding: const EdgeInsets.all(30.0),
                decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(width: 0.5, color: color),
                    borderRadius: BorderRadius.all(Radius.circular(30.0))),
                child: Image(
                    color: color,
                    height: 200.0,
                    width: 200.0,
                    image: AssetImage('assets/barcode.png'),
                    fit: BoxFit.contain),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 40.0),
              child: Text("Escanea un producto para conocer su precio",
                  style: TextStyle(
                      fontFamily: "POPPINS_FONT",
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 24.0),
                  textAlign: TextAlign.center),
            ),
            Obx(() =>
                widgetSuggestions(list: controller.getListSuggestedProducts)),
          ],
        ),
      ),
    );
  }

  Widget widgetSuggestions({required List<Producto> list}) {
    if (list.length == 0) return Container();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text("sugerencias para ti"),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(50),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: FadeInLeft(
                  child: CircleAvatar(
                      child: CircleAvatar(
                          child:
                              Icon(Icons.search, color: Get.theme.primaryColor),
                          radius: 24,
                          backgroundColor: Colors.white),
                      radius: 26,
                      backgroundColor: Get.theme.primaryColor),
                ),
              ),
            ),
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: InkWell(
                    onTap: () => controller.toProductView(porduct: list[0]),
                    borderRadius: BorderRadius.circular(50),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: FadeInRight(
                        child: CircleAvatar(
                            child: CircleAvatar(
                                child: ClipRRect(
                                  child: CachedNetworkImage(
                                      imageUrl: list[0].urlImagen,
                                      fit: BoxFit.cover),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                radius: 24),
                            radius: 26,
                            backgroundColor: Get.theme.primaryColor),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: InkWell(
                    onTap: () => controller.toProductView(porduct: list[1]),
                    borderRadius: BorderRadius.circular(50),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: FadeInRight(
                        child: CircleAvatar(
                            child: CircleAvatar(
                                child: ClipRRect(
                                  child: CachedNetworkImage(
                                      imageUrl: list[1].urlImagen,
                                      fit: BoxFit.cover),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                radius: 24),
                            radius: 26,
                            backgroundColor: Get.theme.primaryColor),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 80),
                  child: InkWell(
                    onTap: () => controller.toProductView(porduct: list[2]),
                    borderRadius: BorderRadius.circular(50),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: FadeInRight(
                        child: CircleAvatar(
                            child: CircleAvatar(
                                child: ClipRRect(
                                  child: CachedNetworkImage(
                                      imageUrl: list[2].urlImagen,
                                      fit: BoxFit.cover),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                radius: 24),
                            radius: 26,
                            backgroundColor: Get.theme.primaryColor),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // ShowModalBottomSheet
  void showModalBottomSheetSetting(BuildContext buildContext) {
    showModalBottomSheet(
        context: buildContext,
        clipBehavior: Clip.antiAlias,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        builder: (context) {
          return ListView(
            children: <Widget>[
              ListTile(
                contentPadding: EdgeInsets.all(12.0),
                leading: controller.profileBusiness.imagenPerfil == ""
                    ? CircleAvatar(
                        backgroundColor: Colors.black26,
                        radius: 18.0,
                        child: Text(
                            controller.profileBusiness.nombreNegocio
                                .substring(0, 1),
                            style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      )
                    : CachedNetworkImage(
                        imageUrl: controller.profileBusiness.imagenPerfil,
                        placeholder: (context, url) => const CircleAvatar(
                          backgroundColor: Colors.grey,
                          radius: 18.0,
                        ),
                        imageBuilder: (context, image) => CircleAvatar(
                          backgroundImage: image,
                          radius: 18.0,
                        ),
                      ),
                title: Text('Editar perfil'),
                onTap: () {
                  //Get.to(ProfileCuenta(perfilNegocio: Global.oPerfilNegocio));
                },
              ),
              Divider(endIndent: 12.0, indent: 12.0, height: 0.0),
              ListTile(
                contentPadding: EdgeInsets.all(12.0),
                leading: Icon(Theme.of(context).brightness != Brightness.light
                    ? Icons.brightness_high
                    : Icons.brightness_3),
                title: Text(Theme.of(context).brightness == Brightness.light
                    ? 'Aplicar de tema oscuro'
                    : 'Aplicar de tema claro'),
                onTap: WidgetsUtilsApp().switchTheme(),
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text("Contacto",
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: Divider(
                      endIndent: 12.0,
                      indent: 12.0,
                      height: 2.0,
                      thickness: 2.0,
                    ),
                  ),
                ],
              ),
              ListTile(
                contentPadding: EdgeInsets.all(12.0),
                leading: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.0),
                    child: FaIcon(FontAwesomeIcons.instagram)),
                title: Text('Instagram'),
                subtitle: Text('Contacta con el desarrollador 👨‍💻'),
                onTap: () async {
                  String url = "https://www.instagram.com/logica.booleana/";
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'Could not launch $url';
                  }
                },
              ),
              Divider(endIndent: 12.0, indent: 12.0, height: 0.0),
              ListTile(
                contentPadding: EdgeInsets.all(12.0),
                leading: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.0),
                    child: FaIcon(FontAwesomeIcons.googlePlay)),
                title: Text(
                  'Déjanos un comentario o sugerencia',
                ),
                onTap: () async {
                  String url =
                      "https://play.google.com/store/apps/details?id=com.logicabooleana.commer.producto";
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'Could not launch $url';
                  }
                },
              ),
              Divider(endIndent: 12.0, indent: 12.0, height: 0.0),
              ListTile(
                contentPadding: EdgeInsets.all(12.0),
                leading: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.0),
                    child: FaIcon(FontAwesomeIcons.blogger)),
                title: Text(
                  'Más información',
                ),
                onTap: () async {
                  String url = "https://logicabooleanaapps.blogspot.com/";
                  /* if (await canLaunch(url)) {
              await launch(url);
            } else {
              throw 'Could not launch $url';
            } */
                },
              ),
              SizedBox(width: 50.0, height: 50.0),
            ],
          );
        });
  }

  showAlertDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(margin: EdgeInsets.only(left: 5), child: Text("Loading")),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  // Function
  Future<void> scanBarcodeNormal({required BuildContext context}) async {
    /*Platform messages are asynchronous, so we initialize in an async method */

    String barcodeScanRes = "";
    // Platform messages may fail, so we use a try/catch PlatformException.
    /* try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", true, ScanMode.BARCODE);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    //if (!mounted) return;
    bool coincidencia = false;
    ProductoNegocio productoSelected;

    if (Global.listProudctosNegocio.length != 0) {
      for (ProductoNegocio producto in Global.listProudctosNegocio) {
        if (producto.codigo == barcodeScanRes) {
          productoSelected = producto;
          coincidencia = true;
          break;
        }
      }
    }

    if (coincidencia) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) =>
              ProductScreen(producto: productoSelected)));
    } else {
      if (barcodeScanRes.toString() != "") {
        if (barcodeScanRes.toString() != "-1") {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) =>
                  WidgetSeachProduct(codigo: barcodeScanRes)));
        }
      }
    } */
  }
}