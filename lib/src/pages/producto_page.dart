import 'dart:io';

import 'package:flutter/material.dart';
import 'package:formvalidation/src/models/producto_model.dart';
import 'package:formvalidation/src/bloc/provider.dart';
import 'package:formvalidation/src/utils/utils.dart' as utils;
import 'package:image_picker/image_picker.dart';


class ProductoPage extends StatefulWidget {
  
  @override
  _ProductoPageState createState() => _ProductoPageState();
}

class _ProductoPageState extends State<ProductoPage> {
  
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  // final productoProvider = new ProductosProvider(); ANTES DEL BLOC
  ProductosBloc productosBloc;
  ProductoModel producto = new ProductoModel();
  bool _guardando = false;
  File foto;

  @override
  Widget build(BuildContext context) {
    productosBloc = Provider.productosBloc(context);
    final ProductoModel prodData = ModalRoute.of(context).settings.arguments;
    if(prodData!=null) producto=prodData;

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Producto'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.photo_size_select_actual),
            onPressed: _seleccionarFoto,
          ),
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: _tomarFoto,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(15.0),
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                _mostrarFoto(),
                _crearNombre(),
                _crearPrecio(),
                _crearDisponible(),
                // SizedBox(height: 20.0,),
                _crearBoton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _crearNombre() {
    return TextFormField(
      initialValue: producto.titulo,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: 'Producto'
      ),
      onSaved: (value) => producto.titulo = value,
      validator: (value){
        if (value.length < 3){
          return 'Ingrese el nombre del producto';
        } else {
          return null;
        }
      },
    );
  }

  Widget _crearPrecio() {
    return TextFormField(
      initialValue: producto.valor.toString(),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'Precio'
      ),
      onSaved: (value) => producto.valor = double.parse(value),
      validator: (value) {
        if(utils.isNumeric(value)){
          return null;
        } else {
          return 'Ingresa solo números';
        }
      },
    );
  }

  Widget _crearBoton(BuildContext context){
    return RaisedButton.icon(
      icon: Icon(Icons.save),
      label: Text('Guardar'),
      color: Theme.of(context).primaryColor,
      textColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0)
        ),
      onPressed: (_guardando) ? null : _submit,
    );
  }

  void _submit() async {
    if(!formKey.currentState.validate()) return;
    
    formKey.currentState.save();
    setState(() {
    _guardando = true;
    });
    // print('Todo OK');
    // print(producto.titulo);
    // print(producto.valor);
    // print(producto.disponible);

    if (foto != null){
      producto.fotoUrl = await productosBloc.subirFoto(foto);
    }


    if(producto.id == null){
      productosBloc.agregarProducto(producto);
    }else{
      productosBloc.editarProducto(producto);
    }

    // setState(() {
    //   _guardando =false;
    // });
    mostrarSnackbar('Registro guardado');
    Navigator.pop(context);
  }

  Widget _crearDisponible() {
    return SwitchListTile(
      activeColor: Colors.deepPurple,
      value: producto.disponible,
      title: Text('Disponible'),
      onChanged: (value) => setState((){
        producto.disponible = value;
      }),
    );
  }

  void mostrarSnackbar(String mensaje){
    final snackbar = SnackBar(
      content: Text(mensaje),
      duration: Duration(milliseconds: 1500),
    );

    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  Widget _mostrarFoto(){
    if(producto.fotoUrl != null){
      return FadeInImage(
        image: NetworkImage(producto.fotoUrl),
        placeholder: AssetImage('assets/jar-loading.gif'),
        height: 300.0,
        fit: BoxFit.contain,
      );
    }else{
    return Image(
      image: AssetImage(foto?.path ?? 'assets/no-img.png'),
      height: 300.0,
      fit: BoxFit.cover,
    );
    }
    
  }

  _seleccionarFoto() async {
    _procesarImagen(ImageSource.gallery);
  }

  _tomarFoto() async {
    _procesarImagen(ImageSource.camera);
  }
  _procesarImagen(ImageSource tipo) async {
    foto = await ImagePicker.pickImage(
      source: tipo
    );
    if(foto != null){
      producto.fotoUrl = null;
    }
    setState(() {});
  }
}