import 'package:animate_do/animate_do.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';
import 'package:producto/app/modules/product/controllers/productsSearch_controller.dart';
import 'package:producto/app/utils/widgets_utils_app.dart';

class ProductsSearch extends GetView<ControllerProductsSearch> {
  const ProductsSearch({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.setColorFondo = controller.getproductDoesNotExist == true
        ? Get.theme.primaryColor
        : Colors.red;

    // TODO: cambiar el manejador de estado por un 'GetBuilder' y  quitrar en el controlador
    // todos los obs y manejar por key
    return GetBuilder<ControllerProductsSearch>(
      id: 'updateAll',
      init: ControllerProductsSearch(),
      initState: (_) {},
      builder: (_) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: controller.getColorFondo,
          appBar: appbar(),
          body: _body(),
        );
      },
    );
  }

  /* WIDGETS */
  PreferredSizeWidget appbar() {
    return AppBar(
      elevation: 0.0,
      backgroundColor: controller.getColorFondo,
      title:
          Text(controller.getproductDoesNotExist ? "Sin resultados" : "Buscar"),
      bottom: controller.getStateSearch
          ? linearProgressBarApp(color: Get.theme.primaryColor)
          : null,
    );
  }

  Widget _body() {
    return Center(
      child:
          ListView(padding: EdgeInsets.all(0.0), shrinkWrap: true, children: [
        FadeInRight(
          child: controller.getproductDoesNotExist
              ? Container()
              : WidgetOtrosProductosGlobal(),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              textField(),
              IconButton(
                padding: EdgeInsets.all(12.0),
                icon: Icon(Icons.content_copy),
                onPressed: () {
                  FlutterClipboard.paste().then((value) {
                    // Do what ever you want with the value.
                    controller.textEditingController.text = value;
                    controller.queryProduct(id: value);
                  });
                },
              ),
              SizedBox(height: 12.0),
              !controller.getStateSearch
                  ? FadeInRight(
                      child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => controller.queryProduct(
                            id: controller.textEditingController.value.text),
                        style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(12.0),
                            onPrimary: Colors.purple,
                            textStyle: TextStyle(color: Colors.black)),
                        icon: Icon(Icons.search,
                            color: Get.theme.primaryColorLight),
                        label: Text("Buscar",
                            style:
                                TextStyle(color: Get.theme.primaryColorLight)),
                      ),
                    ))
                  : Container(),
              !controller.getStateSearch
                  ? SizedBox(width: 12.0, height: 12.0)
                  : Container(),
              !controller.getStateSearch
                  ? FadeInLeft(
                      child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: scanBarcodeNormal,
                        style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(12.0),
                            onPrimary: Colors.purple,
                            textStyle: TextStyle(color: Colors.black)),
                        icon: Image(
                            color: Get.theme.primaryColorLight,
                            height: 20.0,
                            width: 20.0,
                            image: AssetImage('assets/barcode.png'),
                            fit: BoxFit.contain),
                        label: Text("Escanear código",
                            style:
                                TextStyle(color: Get.theme.primaryColorLight)),
                      ),
                    ))
                  : Container(),
              controller.getproductDoesNotExist
                  ? Container()
                  : SizedBox(width: 12.0, height: 12.0),
              controller.getproductDoesNotExist
                  ?Container()
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Si el producto aún no existe, ayúdenos con contribuciones de contenido para que esta aplicación sea aún más útil para la comunidad 💪",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ),
              controller.getproductDoesNotExist
                  ?Container()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Navigator.of(context).pushReplacement( MaterialPageRoute( builder: (BuildContext context) => ProductNew(id: this.codigoBar)));
                        },
                        style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(12.0),
                            onPrimary: Colors.purple,
                            textStyle: TextStyle(color: Colors.black)),
                        icon:
                            Icon(Icons.add, color: Get.theme.primaryColorLight),
                        label: Text("Agregar nuevo producto",
                            style:
                                TextStyle(color: Get.theme.primaryColorLight)),
                      ),
                    ),
              SizedBox(width: 50.0, height: 50.0),
            ],
          ),
        ),
      ] //your list view content here
              ),
    );
  }

  /* WIDGETS COMPONENT */
  Widget textField() {
    return TextField(
      controller: controller.textEditingController,
      keyboardType: TextInputType.numberWithOptions(decimal: false),
      inputFormatters: [
        FilteringTextInputFormatter.allow(new RegExp('[1234567890]'))
      ],
      onChanged: (value) {
        //controller.setCodeBar = value;
      },
      decoration: InputDecoration(
          suffixIcon: IconButton(
            onPressed: () {
              controller.clean();
            },
            icon: controller.textEditingController.value.text != ""
                ? Icon(Icons.clear, color: controller.getTextEditingColor)
                : Container(),
          ),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: controller.getTextEditingColor)),
          border: OutlineInputBorder(
              borderSide: BorderSide(color: controller.getTextEditingColor)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: controller.getTextEditingColor)),
          labelStyle: TextStyle(color: controller.getTextEditingColor),
          labelText: "Escribe el código",
          suffixStyle: TextStyle(color: controller.getTextEditingColor)),
      style: TextStyle(fontSize: 30.0, color: controller.getTextEditingColor),
      textInputAction: TextInputAction.search,
      onSubmitted: (value) {
        //  Se llama cuando el usuario indica que ha terminado de editar el texto en el campo
        //controller.getProduct(id: controller.textEditingController.value.text);
      },
    );
  }

  /* FUNCTIONS */
  Future<void> scanBarcodeNormal() async {
    // Escanner Code - Abre en pantalla completa la camara para escanear
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      late String barcodeScanRes;
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", true, ScanMode.BARCODE);
      controller.queryProduct(id: barcodeScanRes);
    } on PlatformException {
      Get.snackbar('scanBarcode', 'Failed to get platform version');
    }
  }
}

/* CLASS COMPONENTS */
class WidgetOtrosProductosGlobal extends StatelessWidget {
  const WidgetOtrosProductosGlobal();

  @override
  Widget build(BuildContext context) {
    return Container();
    /* return Container(
      width: double.infinity,
      height: 200.0,
      child: FutureBuilder(
        future: Global.getProductAll().getDataProductoAll(favorite: true),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Producto> listProductos = snapshot.data;
            if (listProductos.length == 0) return Container();
            return CarouselSlider.builder(
                itemCount: listProductos.length,
                options: CarouselOptions(
                    height: 200,
                    enableInfiniteScroll:
                        listProductos.length == 1 ? false : true,
                    autoPlay: listProductos.length == 1 ? false : true,
                    aspectRatio: 2.0,
                    enlargeCenterPage: true,
                    scrollDirection: Axis.horizontal,
                    viewportFraction: 0.8),
                itemBuilder: (BuildContext context, int itemIndex) {
                  return ProductoItemHorizontalSmall(
                      producto:
                          listProductos[itemIndex].convertProductoNegocio());
                });
          } else {
            return Container();
          }
        },
      ),
    ); */
  }
}
