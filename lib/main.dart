import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import './widgets/new_transaction.dart';
import './widgets/transaction_list.dart';
import './widgets/chart.dart';
import './models/transaction.dart';

void main() {
  // SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  //   DeviceOrientation.portraitUp,
  // ]);
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Expenses',
      debugShowCheckedModeBanner: false,
      // theme: ThemeData(
      //     primarySwatch: Colors.purple,
      //     accentColor: Colors.amber,
      //     // errorColor: Colors.red,
      //     fontFamily: 'Quicksand',
      //     textTheme: ThemeData.light().textTheme.copyWith(
      //           titleLarge: TextStyle(
      //             fontFamily: 'OpenSans',
      //             fontWeight: FontWeight.bold,
      //             fontSize: 18,
      //           ),
      //           button: TextStyle(color: Colors.white),
      //         ),
      //     appBarTheme: AppBarTheme(
      //       textTheme: ThemeData.light().textTheme.copyWith(
      //             titleLarge: TextStyle(
      //               fontFamily: 'OpenSans',
      //               fontSize: 20,
      //               fontWeight: FontWeight.bold,
      //             ),
      //           ),
      //     )),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  // String titleInput;
  // String amountInput;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  // final List<Transaction> _userTransactions = [

  //   // Transaction(
  //   //   id: 't1',
  //   //   title: 'New Shoes',
  //   //   amount: 69.99,
  //   //   date: DateTime.now(),
  //   // ),
  //   // Transaction(
  //   //   id: 't2',
  //   //   title: 'Weekly Groceries',
  //   //   amount: 16.53,
  //   //   date: DateTime.now(),
  //   // ),
  // ];

  List<Transaction> _userTransactions = [];
  void loadData() async {
    var list = await DatabaseHelper.instance.getTransactions() ?? [];
    print("list: ${list[0].title}");
    //print(list.);
    list.forEach((trans) {
      print("printing: $trans");
      print(_userTransactions);
      return _userTransactions.add(trans);
    });
    setState(() {});
    //print("added from database");
  }

  // DatabaseHelper.instance.getTransactions() as List;

  // void loadData() {
  //   FutureBuilder<List<Transaction>>(
  //       future: DatabaseHelper.instance.getTransactions(),
  //       builder:
  //           (BuildContext context, AsyncSnapshot<List<Transaction>> snapshot) {
  //         if (!snapshot.hasData) {
  //           return;
  //         }
  //         snapshot.data
  //             .map((transaction) => _userTransactions.add(transaction));
  //       });
  // }

  // Future<List<Transaction>> loadData() async {
  //   final db = await Databs;

  //   final List<Map<String, dynamic>> maps = await db.query('expenses');
  // }

  bool _showChart = false;

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addObserver(this);
    //setState(() {
    loadData();
    //});

    print("init :$_userTransactions");
    super.initState();
  }

  // after writing a listner you need to disposer it
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(state);
    print('didChange $_userTransactions');
    //loadData();
  }

  @override
  dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  List<Transaction> get _recentTransactions {
    return _userTransactions.where((tx) {
      return tx.date.isAfter(
        DateTime.now().subtract(
          Duration(days: 7),
        ),
      );
    }).toList();
  }

  void _addNewTransaction(
      String txTitle, double txAmount, DateTime chosenDate) async {
    final newTx = Transaction(
      title: txTitle,
      amount: txAmount,
      date: chosenDate,
      id: DateTime.now().toString(),
    );
    await DatabaseHelper.instance.add(newTx);
    // final db = DatabaseHelper.instance.getTransactions();
    // print("Database please" + db.toString());
    setState(() {
      _userTransactions.add(newTx);
    });
  }

  void _startAddNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          child: NewTransaction(_addNewTransaction),
          behavior: HitTestBehavior.opaque,
        );
      },
    );
  }

  void _deleteTransaction(String id) async {
    await DatabaseHelper.instance.remove(id);

    setState(() {
      _userTransactions.removeWhere((tx) => tx.id == id);
    });
  }

  List<Widget> _buildLandscapeContent(
    MediaQueryData mediaQuery,
    AppBar appBar,
    Widget txListWidget,
  ) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Show Chart',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Switch.adaptive(
            activeColor: Theme.of(context).accentColor,
            value: _showChart,
            onChanged: (val) {
              setState(() {
                _showChart = val;
              });
            },
          ),
        ],
      ),
      _showChart
          ? Container(
              height: (mediaQuery.size.height -
                      appBar.preferredSize.height -
                      mediaQuery.padding.top) *
                  0.7,
              child: Chart(_recentTransactions),
            )
          : txListWidget
    ];
  }

  List<Widget> _buildPortraitContent(
    MediaQueryData mediaQuery,
    AppBar appBar,
    Widget txListWidget,
  ) {
    return [
      Container(
        height: (mediaQuery.size.height -
                appBar.preferredSize.height -
                mediaQuery.padding.top) *
            0.3,
        child: Chart(_recentTransactions),
      ),
      txListWidget
    ];
  }

  Widget _buildAppBar() {
    return Platform.isIOS
        ? CupertinoNavigationBar(
            middle: Text(
              'Personal Expenses',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                GestureDetector(
                  child: Icon(CupertinoIcons.add),
                  onTap: () {
                    print(_userTransactions);
                    return _startAddNewTransaction(context);
                  },
                ),
              ],
            ),
          )
        : AppBar(
            title: Text(
              'Personal Expenses',
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () => _startAddNewTransaction(context),
              ),
            ],
          );
  }

  @override
  Widget build(BuildContext context) {
    print('build() MyHomePageState');
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final PreferredSizeWidget appBar = _buildAppBar();
    final txListWidget = Container(
      height: (mediaQuery.size.height -
              appBar.preferredSize.height -
              mediaQuery.padding.top) *
          0.7,
      child: TransactionList(_userTransactions, _deleteTransaction),
    );
    final pageBody = SafeArea(
      child: SingleChildScrollView(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (isLandscape)
              ..._buildLandscapeContent(
                mediaQuery,
                appBar,
                txListWidget,
              ),
            if (!isLandscape)
              ..._buildPortraitContent(
                mediaQuery,
                appBar,
                txListWidget,
              ),
          ],
        ),
      ),
    );
    return Platform.isIOS
        ? CupertinoPageScaffold(
            child: pageBody,
            navigationBar: appBar,
          )
        : Scaffold(
            appBar: appBar,
            body: pageBody,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: Platform.isIOS
                ? Container()
                : FloatingActionButton(
                    child: Icon(Icons.add),
                    onPressed: () => _startAddNewTransaction(context),
                  ),
          );
  }
}
