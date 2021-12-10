import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:loadany/loadany.dart';
import 'package:producto/app/models/catalogo_model.dart';
import 'package:producto/app/modules/mainScreen/controllers/welcome_controller.dart';
import 'package:producto/app/routes/app_pages.dart';
import 'package:producto/app/utils/widgets_utils_app.dart';
import 'package:search_page/search_page.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'widgets/showDialog.dart';

class CatalogueScreenView extends StatelessWidget {
  CatalogueScreenView({Key? key}) : super(key: key);

  final WelcomeController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return scaffondCatalogo(buildContext: context);
  }

  Widget scaffondCatalogo({required BuildContext buildContext}) {
    return Scaffold(
      /* AppBar persistente que nunca se desplaza */
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Theme.of(buildContext).scaffoldBackgroundColor,
        iconTheme: Theme.of(buildContext)
            .iconTheme
            .copyWith(color: Theme.of(buildContext).textTheme.bodyText1!.color),
        title: InkWell(
          onTap: () => showModalBottomSheetSelectAccount(buildContext),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              children: <Widget>[
                Obx(() => Text(
                    controller.getProfileAccountSelected.id == ''
                        ? "Seleccionar cuenta"
                        : controller.getProfileAccountSelected.nombreNegocio !=
                                ""
                            ? controller.getProfileAccountSelected.nombreNegocio
                            : "Mi catalogo",
                    style: TextStyle(
                        color:
                            Theme.of(buildContext).textTheme.bodyText1!.color),
                    overflow: TextOverflow.fade,
                    softWrap: false)),
                Icon(Icons.keyboard_arrow_down)
              ],
            ),
          ),
        ),
        actions: <Widget>[
          IconButton(onPressed: () => Get.toNamed(Routes.PRODUCTS_SEARCH,arguments: {'idProduct': ''}), icon: Icon(Icons.add)),
          IconButton(
              onPressed: () {
                showSearch(
                  context: buildContext,
                  delegate: SearchPage<ProductoNegocio>(
                    items: controller.getCataloProducts,
                    searchLabel: 'Buscar producto',
                    suggestion: Center(
                      child: Text('ej. alfajor'),
                    ),
                    failure: Center(
                      child: Text('No se encontro :('),
                    ),
                    filter: (product) => [
                      product.titulo,
                      product.descripcion,
                    ],
                    builder: (product) => ListTile(
                      leading: FadeInImage(
                        image: NetworkImage(product.urlimagen),
                        placeholder: AssetImage("assets/loading.gif"),
                        fadeInDuration: Duration(milliseconds: 200),
                        fit: BoxFit.cover,
                        width: 50.0,
                      ),
                      title: Text(product.titulo),
                      subtitle: Text(product.descripcion),
                      onTap: () {
                        Get.toNamed(Routes.PRODUCT, arguments: {'product': product});
                      },
                    ),
                  ),
                );
              },
              icon: Icon(Icons.search)),
          Obx(() => controller.getProfileAccountSelected.id == ''
              ? Container()
              : Container(
                  padding: EdgeInsets.all(12.0),
                  child: InkWell(
                    customBorder: new CircleBorder(),
                    splashColor: Colors.grey,
                    onTap: () {
                      showModalBottomSheetSetting(buildContext);
                    },
                    child: Hero(
                      tag: "fotoperfiltoolbar",
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.grey,
                        backgroundImage: CachedNetworkImageProvider(
                          controller.getProfileAccountSelected.imagenPerfil,
                        ),
                      ),
                    ),
                  ),
                )),
        ],
      ),
      body: body(buildContext: buildContext),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Get.theme.primaryColor,
          heroTag: "Escanear codigo",
          child: Image(
              color: Colors.white,
              height: 30.0,
              width: 30.0,
              image: AssetImage('assets/barcode.png'),
              fit: BoxFit.contain),
          tooltip: 'Escanea el codigo del producto',
          onPressed: () {
            scanBarcodeNormal(context: buildContext);
          }),
    );
  }

  // Widgets
  Widget body({required BuildContext buildContext}) {
    return DefaultTabController(
      length: 1,
      child: NestedScrollView(
        /* le permite crear una lista de elementos que se desplazarían hasta que el cuerpo alcanzara la parte superior */
        floatHeaderSlivers: true,
        physics: BouncingScrollPhysics(),
        headerSliverBuilder: (context, _) {
          return [
            GetBuilder<WelcomeController>(
              id: 'marks',
              init: WelcomeController(),
              initState: (_) {},
              builder: (_) {
                return SliverList(
                  delegate: SliverChildListDelegate([
                    Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 0),
                        child: controller.getLoadDataCatalogueMarks
                            ? WidgetsListaHorizontalMarks()
                            : WidgetsListaHorizontalMarksLoadAnim()),
                  ]),
                );
              },
            ),
          ];
        },
        body: Column(
          children: <Widget>[
            Divider(height: 0.0),
            TabBar(
              indicatorColor: Theme.of(buildContext).primaryColor,
              indicatorWeight: 5.0,
              labelColor: Get.theme.brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
              onTap: (_) => ViewCategoria.show(buildContext: buildContext),
              tabs: [
                GetBuilder<WelcomeController>(
                  init: WelcomeController(),
                  id: 'tab',
                  builder: (_) => Tab(text: controller.getTextTab),
                )
              ],
            ),
            Divider(height: 0.0),
            Expanded(
              child: TabBarView(
                children: [
                  gridViewLoadAny(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget gridViewLoadAny() {
    return GetBuilder<WelcomeController>(
      id: 'catalogue',
      builder: (controller) {
        return LoadAny(
          onLoadMore: controller.getCatalogueMoreLoad,
          status: controller.getLoadGridCatalogueStatus,
          loadingMsg: 'Cargando...',
          errorMsg: 'errorMsg',
          finishMsg:
              controller.getCatalogueLoad.length.toString() + ' productos',
          child: CustomScrollView(
            slivers: <Widget>[
              SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 150,
                  childAspectRatio: 1/1.4,
                ),
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return ProductoItem(producto: controller.getCatalogueLoad[index]);
                  },
                  childCount: controller.getCatalogueLoad.length,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // BottomSheet - Getx
  void showModalBottomSheetSelectAccount(BuildContext buildContext) {
    // muestra las cuentas en el que este usuario tiene acceso
    Widget widget = controller.getManagedAccountData.length == 0
        ? WidgetButtonListTile(buildContext: buildContext)
            .buttonListTileCrearCuenta(context: buildContext)
        : ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 15.0),
            shrinkWrap: true,
            itemCount: controller.getManagedAccountData.length,
            itemBuilder: (BuildContext context, int index) {
              return WidgetButtonListTile(buildContext: buildContext)
                  .buttonListTileItemCuenta(
                      buildContext: buildContext,
                      perfilNegocio: controller.getManagedAccountData[index],
                      adminPropietario:
                          controller.getManagedAccountData[index].id ==
                              controller.getUserAccountAuth.uid);
            },
          );

    // muestre la hoja inferior modal de getx
    Get.bottomSheet(
      widget,
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      enableDrag: true,
      isDismissible: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
    );
  }

  // BottomSheet
  void showModalBottomSheetSetting(BuildContext buildContext) {
    Widget widget = ListView(
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(vertical: 15.0),
      children: <Widget>[
        ListTile(
          contentPadding: EdgeInsets.all(12.0),
          leading: controller.getProfileAccountSelected.imagenPerfil == ""
              ? CircleAvatar(
                  backgroundColor: Colors.black26,
                  radius: 18.0,
                  child: Text(
                      controller.getProfileAccountSelected.nombreNegocio
                          .substring(0, 1),
                      style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                )
              : CachedNetworkImage(
                  imageUrl: controller.getProfileAccountSelected.imagenPerfil,
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
            Navigator.pop(buildContext);
            Get.toNamed(Routes.ACCOUNT);
          },
        ),
        Divider(endIndent: 12.0, indent: 12.0, height: 0.0),
        ListTile(
          contentPadding: EdgeInsets.all(12.0),
          leading: Icon(Icons.logout),
          title: Text('Cerrar sesión'),
          onTap: controller.showDialogCerrarSesion,
        ),
        Divider(endIndent: 12.0, indent: 12.0, height: 0.0),
        ListTile(
          contentPadding: EdgeInsets.all(12.0),
          leading: Icon(Get.theme.brightness != Brightness.light
              ? Icons.brightness_high
              : Icons.brightness_3),
          title: Text(Get.theme.brightness == Brightness.light
              ? 'Aplicar de tema oscuro'
              : 'Aplicar de tema claro'),
          onTap: WidgetsUtilsApp().switchTheme(),
        ),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text("Contacto",
                  style:
                      TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
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

    // muestre la hoja inferior modal de getx
    Get.bottomSheet(
      widget,
      ignoreSafeArea: true,
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      enableDrag: true,
      isDismissible: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
    );
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
    try {
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
    late ProductoNegocio productoSelected;

    if (controller.getCataloProducts.length != 0) {
      for (ProductoNegocio producto in controller.getCataloProducts) {
        if (producto.codigo == barcodeScanRes) {
          productoSelected = producto;
          coincidencia = true;
          break;
        }
      }
    }

    if (coincidencia) {
      Get.toNamed(Routes.PRODUCT, arguments: {'product': productoSelected});
    } else {
      if (barcodeScanRes.toString() != "") {
        if (barcodeScanRes.toString() != "-1") {
          Get.toNamed(Routes.PRODUCTS_SEARCH,arguments: {'id':barcodeScanRes});
        }
      }
    }
  }
}

// WIDGET - Sujerencias de productos
class WidgetProductsSuggestions extends StatelessWidget {
  WidgetProductsSuggestions({required this.list});

  // var
  final WelcomeController controller = Get.find();
  final List<Producto> list;

  @override
  Widget build(BuildContext context) {
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
}

//  WIDGET - Marks list
//  readme
//  creamos un lista horizontal con las marcas de los productos que se muestran al usaurio
class WidgetsListaHorizontalMarks extends StatelessWidget {
  WidgetsListaHorizontalMarks({Key? key}) : super(key: key);

  // var
  final WelcomeController controller = Get.find();
  final List<Color> colorGradientInstagram = [
    Get.theme.primaryColor,
    Get.theme.primaryColor,
    Get.theme.primaryColor,
    Get.theme.primaryColor,
  ];

  @override
  Widget build(BuildContext context) {
    if (controller.getCatalogueMarksFilter.length == 0) return Container();
    return SizedBox(
      height: 110.0,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.getCatalogueMarksFilter.length,
          itemBuilder: (BuildContext c, int index) {
            // get
            Marca marca = controller.getCatalogueMarksFilter[index];
            if (marca.name == '') return Container();

            return Container(
              width: 81.0,
              height: 100.0,
              padding: EdgeInsets.all(5.0),
              child: GestureDetector(
                onTap: () {
                  controller.setMarkSelect = marca;
                },
                child: Column(
                  children: <Widget>[
                    DashedCircle(
                      dashes:
                          controller.getNumeroDeProductosDeMarca(id: marca.id),
                      gradientColor: colorGradientInstagram,
                      child: Padding(
                        padding: EdgeInsets.all(5.0),
                        child: viewCircleImage(
                            url: marca.urlImage,
                            texto: marca.name,
                            size: 50),
                      ),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Text(marca.name,
                        style: TextStyle(
                            fontSize: controller.getMarkSelect.id == marca.id
                                ? 14
                                : 12,
                            fontWeight: controller.getMarkSelect.id == marca.id
                                ? FontWeight.bold
                                : FontWeight.normal),
                        overflow: TextOverflow.fade,
                        softWrap: false)
                  ],
                ),
              ),
            );
          }),
    );
  }
}

class WidgetsListaHorizontalMarksLoadAnim extends StatelessWidget {
  WidgetsListaHorizontalMarksLoadAnim({Key? key}) : super(key: key);

  final Color color1 = Colors.black12;
  final Color color2 = Colors.grey;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110.0,
      child: Shimmer.fromColors(
        baseColor: color1,
        highlightColor: color2,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 7,
            itemBuilder: (BuildContext c, int index) {
              return Container(
                width: 81.0,
                height: 100.0,
                padding: EdgeInsets.all(5.0),
                child: GestureDetector(
                  onTap: () {},
                  child: Column(
                    children: <Widget>[
                      CircleAvatar(
                        backgroundColor: Colors.grey,
                        radius: 30,
                      ),
                      SizedBox(height: 8.0),
                      Container(
                        width: 30,
                        height: 10,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }
}
