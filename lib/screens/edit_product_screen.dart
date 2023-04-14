import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = './edit-product';
  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _pricefocusNode = FocusNode();
  final _descriptionfocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlfocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var editedProduct =
      Product(id: null, title: '', price: 0, description: '', imageUrl: '');
  var _isInit = true;
  var _isLoading = false;
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': ''
  };
  @override
  void initState() {
    _imageUrlfocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        editedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _initValues = {
          'title': editedProduct.title,
          'description': editedProduct.description,
          'price': editedProduct.price.toString(),
          // 'imageUrl': editedProduct.imageUrl,
          'imageUrl': ''
        };
        _imageUrlController.text = editedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlfocusNode.removeListener(_updateImageUrl);
    _pricefocusNode.dispose();
    _descriptionfocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlfocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlfocusNode.hasFocus) {
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (editedProduct.id != null) {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(editedProduct.id, editedProduct);
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(editedProduct);
      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('An error occurred!'),
            content: Text('Something went wrong.'),
            actions: <Widget>[
              TextButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              )
            ],
          ),
        );
      }
      // finally {
      //   setState(() {
      //     _isLoading = false;
      //   });
      //   Navigator.of(context).pop();
      // }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
    // Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(15.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _initValues['title'],
                      enableInteractiveSelection: true,
                      decoration: InputDecoration(
                        labelText: 'Title',
                      ),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_pricefocusNode);
                      },
                      onSaved: (value) {
                        editedProduct = Product(
                            id: editedProduct.id,
                            title: value,
                            price: editedProduct.price,
                            description: editedProduct.description,
                            imageUrl: editedProduct.imageUrl,
                            isFavorite: editedProduct.isFavorite);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please give it a name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['price'],
                      decoration: InputDecoration(
                        labelText: 'Price',
                      ),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _pricefocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionfocusNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please rate a value';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        if (double.tryParse(value) <= 0) {
                          return 'Obv more than 0 u stupid son of a... ';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        editedProduct = Product(
                            id: editedProduct.id,
                            title: editedProduct.title,
                            price: double.parse(value),
                            description: editedProduct.description,
                            imageUrl: editedProduct.imageUrl,
                            isFavorite: editedProduct.isFavorite);
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['description'],
                      decoration: InputDecoration(
                        labelText: 'Description',
                      ),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionfocusNode,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please describe it';
                        }
                        if (value.length < 10) {
                          return 'Should be atleast 10 characters long';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        editedProduct = Product(
                            id: editedProduct.id,
                            title: editedProduct.title,
                            price: editedProduct.price,
                            description: value,
                            imageUrl: editedProduct.imageUrl,
                            isFavorite: editedProduct.isFavorite);
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(top: 8, right: 8),
                          decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.grey)),
                          child: _imageUrlController.text.isEmpty
                              ? Text('Enter a url')
                              : FittedBox(
                                  child: Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        Expanded(
                            child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Image URL',
                          ),
                          keyboardType: TextInputType.url,
                          textInputAction: TextInputAction.done,
                          controller: _imageUrlController,
                          focusNode: _imageUrlfocusNode,
                          onEditingComplete: () {
                            setState(() {});
                          },
                          // onFieldSubmitted: (_) {
                          //   _saveForm();
                          // },
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter a image url then hit enter';
                            }
                            if (!value.startsWith('http') &&
                                !value.startsWith('https')) {
                              return 'please enter a valid url';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            editedProduct = Product(
                                id: editedProduct.id,
                                title: editedProduct.title,
                                price: editedProduct.price,
                                description: editedProduct.description,
                                imageUrl: value,
                                isFavorite: editedProduct.isFavorite);
                          },
                        )),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: 20,
                        left: 150,
                      ),
                      child: ButtonTheme(
                        child: ElevatedButton(
                          onPressed: _saveForm,
                          child: Text("Submit",
                              style: TextStyle(color: Colors.black)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
