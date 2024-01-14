import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

//Aplicacion principal
void main() {
  //Inicializa la aplicacion MyApp
  runApp(MyApp());
}

//Clase MyApp extiende de StatelessWidget es decir de un widget sin estado que no cambia
class MyApp extends StatelessWidget {
  //Mi app es la aplicacion principal que es un widget sin estado
  const MyApp({super.key});
  //Metodo build que retorna un widget
  @override
  Widget build(BuildContext context) {
    //Retorna un widget que es el widget ChangeNotifierProvider que es el que permite que
    //los widgets hijos puedan escuchar los cambios de estado
    return ChangeNotifierProvider(
      //Crea un estado inicial de la aplicacion
      create: (context) => MyAppState(),
      child: MaterialApp(
        //Crea un nombre de la aplicacion
        title: 'Namer App',
        //Crea un tema de la aplicacion
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        // Establece widget principal de la app que sirve de punto de partida
        home: MyHomePage(),
      ),
    );
  }
}

//LA clase MyAppState extiende de ChangeNotifier que es el que define los datos que la app necvesita para
//funcionar, como extiene de ChangeNotifier puede notificar a los widgets hijos cuando cambia el estado.
//Como se crea con ChangeNotifierProvider, en MyApp le brinda a todos los widgets conocer su estado actual.
class MyAppState extends ChangeNotifier {
  //Tiene una variable ccon el par de palabras aleatorias.
  var current = WordPair.random();
  //El nuevo método getNext() reasignará el elemento current con un nuevo WordPair aleatorio. También llamará a notifyListeners() (un método de ChangeNotifier) que garantiza que se notifique
  //a todo elemento que esté mirando a MyAppState.
  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  // Creamos lista vacia de palabras
  var favorites = <WordPair>[];

  // Mewtodo toggleFavorite que agrega o quita el par de palabras de la lista de favoritos
  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    //Notifica a todos los elementos que estén mirando a MyAppState
    notifyListeners();
  }
}

//Clase MyHomePage que extiende de StatelessWidget
class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    //Crea un Scaffold
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        //Creamos unas filas una safe area y el widget GeneratorPage
        body: Row(
          children: [
            // SafeArea asegura que el contenido no se salga del area visible y
            //garantiza que sus elementos secundarios no se muestren oscurecidos
            //por un recorte de hardware o una barra de estado
            SafeArea(
              child: NavigationRail(
                //En false no muestra las etiquetas al lado de los iconos y en true si
                extended: constraints.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                //child: GeneratorPage(),
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${appState.favorites.length} favorites:'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}

//Clase BigCard que extiende de StatelessWidget, refractorizado de text
class BigCard extends StatelessWidget {
  //Indica que el constructor requiere un par de palabras
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    //Solicita el tema actual de la app y lo asigna a la variable theme
    final theme = Theme.of(context);
    //Accedemos a textTheme de la variable theme para definir el estilo del texto
    //copywith muestra una copia del estilo del texto con los cambios que definimos
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    //Devolvemos una tarjeta con un color y de texto llamamos a la variable pair de
    //MyHomePage que a su vez consigue el estado de la app.
    return Card(
      //elevation define la elevación de la tarjeta,
      elevation: style.fontSize! * 0.75,
      //Color de la trjeta, primary es el mas destacado y define el color
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          pair.asLowerCase,
          //copywith muestra una copia del estilo del texto con los cambios que definimos
          style: style,
          // Anulamos el contenido visual del widget de texto con un contenido semántico
          //que es más apropiado para los lectores de pantalla:
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}
