import 'package:flutter/material.dart';
import 'package:flutter_stock/screens/addproduct/editproduct.dart';
import 'package:flutter_stock/services/rest_api.dart';
import 'package:flutter_stock/models/Product.dart';

class StockScreen extends StatefulWidget {
  StockScreen({Key key}) : super(key: key);

  @override
  _StockScreenState createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  //callAPI
  CallAPI callAPI;

  //สร้าง context
  BuildContext context;

  @override
  void initState() {
    super.initState();
    callAPI = CallAPI();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text('Product Listdd'),
        actions: <Widget>[
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/addproduct')
                  .then((value) => setState(() {
                        callAPI.getProducts();
                      }));
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 1, right: 1),
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder(
          future: callAPI.getProducts(),
          builder:
              (BuildContext context, AsyncSnapshot<List<Product>> snapshot) {
            if (snapshot.hasError) {
              return Center(
                child:
                    Text('sometihng wrong with ${snapshot.error.toString()}'),
              );
            } else if (snapshot.connectionState == ConnectionState.done) {
              List<Product> products = snapshot.data;
              return _buildListView(products);
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }

  //ListView Builder
  Widget _buildListView(List<Product> products) {
    return ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          Product product = products[index];
          return Card(
            child: InkWell(
              onTap: () {
                print('tab on card');
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Container(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: Image.network(product.productImage)),
                        ),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              product.productName,
                              style: TextStyle(fontSize: 24),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(product.productBarcode,
                                style: TextStyle(fontSize: 20)),
                            Text("THB " + product.productPrice)
                          ],
                        ))
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        RaisedButton(
                          color: Colors.green,
                          onPressed: () {
                            print('tab on edit');
                            Navigator.pushNamed(
                              context,
                              '/editproduct',
                              arguments: ScreenArguments(
                                  product.id.toString(),
                                  product.productName,
                                  product.productDetail,
                                  product.productBarcode,
                                  product.productImage,
                                  product.productQty.toString()),
                            ).then((value) => setState(() {
                                  callAPI.getProducts();
                                }));
                          },
                          child: Text('Edit',
                              style: TextStyle(color: Colors.blue)),
                        ),
                        FlatButton(
                          onPressed: () {
                            return showDialog<void>(
                              context: context,
                              barrierDismissible:
                                  false, // user must tap button!
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('AlertDialog Title'),
                                  content: SingleChildScrollView(
                                    child: ListBody(
                                      children: <Widget>[
                                        Text('This is a demo alert dialog.'),
                                        Text('Would you like to confirm?'),
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text('No'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    FlatButton(
                                      child: Text('Yes'),
                                      onPressed: () async {
                                        var response = await CallAPI()
                                            .deleteProduct(product.id);
                                        if (response == true) {
                                          //Navigator.pushNamed(context, '/stockscreen');
                                          Navigator.pop(context, true);
                                          setState(() {
                                            callAPI.getProducts();
                                          });
                                        }
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text('Delete',
                              style: TextStyle(color: Colors.red)),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
