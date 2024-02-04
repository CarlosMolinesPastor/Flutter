//Importaciones de librerías
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//Importamos la clase que hemos añadido en el archivo pubspec.yaml para poder utilizarla
//Es para poder realizar llamadas a paginas web
import 'package:url_launcher/url_launcher.dart';

//Librerías de clases
void main() {
  //Llamada al método runApp
  runApp(MyApp());
}

//Clase MyApp que extiende widget de estado
class MyApp extends StatelessWidget {
  //Método build de la clase MyApp
  const MyApp({super.key});

  //widget build de la clase MyApp
  @override
  Widget build(BuildContext context) {
    //Crea una instancia de la clase MyAppState que leemos desde el contexto
    //devolviendo un ChangeNotifierProvider que es el encargado de notificar a los widgets
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        //Le ponemos un título
        title: 'Mi proyecto de Lenguajes de Programación',
        //Le ponemos un tema
        theme: ThemeData(
          //usamos Material 3 y le damos un color
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        //Le ponemos un widget de inicio
        home: MyHomePage(),
      ),
    );
  }
}

//Clase MyAppState que extiende el change notifier que es el encargado de notificar a los widgets
class MyAppState extends ChangeNotifier {
  //Variables de la clase
  //Se declaran dos listas una para la lista de historial, lenguajes y otra para la lista de favoritos
  var history = <String>[];
  var lenguajes = <String>[];
  //Variable nextLenguaje que almacena el primer elemento de la lista
  var nextLenguaje = "";
  var favorites = <String>[];

  //Variable historyListKey que almacena la clave de la lista
  GlobalKey? historyListKey;

  //Metodo añadir lenguaje a la lista lenguajes
  void addLenguaje(String lenguaje) {
    lenguajes.add(lenguaje);
    //Se notifica a los widgets los cambios
    notifyListeners();
  }

  //Metodo que hace la magia
  void getNext() {
    //Declaramos la variable nextLenguaje
    String nextLenguaje;
    //Si la lista lenguajes que es la que vamos añadiendo desde Introducir los datos no esta vacía
    if (lenguajes.isNotEmpty) {
      //Le damos el valor del primer elemento de la lista que lo quitamos y la insertamos en la lista de historial
      nextLenguaje = lenguajes.removeAt(0);
      history.insert(0, nextLenguaje);
      // Actualizamos la lista animada insertando el nuevo elemento
      var animatedList = historyListKey?.currentState as AnimatedListState?;
      // Se inserta el nuevo elemento
      animatedList?.insertItem(0);
      //Si no hay elementos en la lista se muestra un mensaje de error
    } else {
      nextLenguaje = "La lista está vacía";
    }
    //Se notifica a los widgets los cambios
    notifyListeners();
  }

  //Metodo por el que se agrega y elimina elementos en la lista de favoritos
  void toggleFavorite([String? lenguaje]) {
    if (lenguaje == "La lista está vacía") {
      return;
    }
    //Si el elemento no es favorito se añade y si es favorito se elimina
    if (favorites.contains(lenguaje)) {
      favorites.remove(lenguaje);
    } else {
      favorites.add(lenguaje!);
    }
    //Se notifica a los widgets los cambios
    notifyListeners();
  }

  //Metodo que elimina un elemento de la lista favoritos
  void removeFavorite(String lenguaje) {
    favorites.remove(lenguaje);
    notifyListeners();
  }
}

//Clase MyHomePage que extiende widget de estado
// que es el inicio de la aplicación
class MyHomePage extends StatefulWidget {
  @override
  //Crea un estado para la clase MyHomePage
  State<MyHomePage> createState() => _MyHomePageState();
}

//Clase _MyHomePageState que extiende widget de estado
class _MyHomePageState extends State<MyHomePage> {
  // Se crea la variable selectedIndex que almacena el indice de la barra de navegación
  var selectedIndex = 0;

  // El metodo build de la clase _MyHomePageState devuelve un widget Scaffold
  @override
  Widget build(BuildContext context) {
    // Se crea una variable para el tema
    var colorScheme = Theme.of(context).colorScheme;

    //Tiene un widget de seleccion de pagina con tres botones
    //que redirigiran a los tres apartados de la aplicación
    //segun el indice de la pagina
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      //Caso implementado para introduucir los datos de la lista anidada
      case 2:
        page = IntroducirDatos();
        break;
      //Caso por defecto
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    // Se define el area de contenido con un hijo que es la pagina
    var mainArea = ColoredBox(
      color: colorScheme.surfaceVariant,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        child: page,
      ),
    );

    // Devuelve un widget Scaffold con un area de contenido
    return Scaffold(
      // Se define la barra de navegación
      extendBodyBehindAppBar: false,
      body: LayoutBuilder(
        // Se define el tamanio de la pantalla
        builder: (context, constraints) {
          // Si la pantalla es menor  a 450 pixeles devuelve el area de contenido
          //con los iconos, si no lo devuelve con los nombres e iconos
          if (constraints.maxWidth < 450) {
            // Se muestra el area de contenido en una columna con una barra de navegación con 3 botones
            return Column(
              children: [
                Expanded(child: mainArea),
                SafeArea(
                  child: BottomNavigationBar(
                    items: [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home, color: Colors.pink),
                        label: 'Inicio',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.favorite, color: Colors.green),
                        label: 'Favoritos',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(
                          Icons.add,
                          color: Colors.blue,
                        ),
                        label: 'Añadir',
                      )
                    ],
                    // Se define el indice de la barra de navegación
                    currentIndex: selectedIndex,
                    // Se define el evento de cambio de indice
                    onTap: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  ),
                )
              ],
            );
            // Si la pantalla es mayor a 450 pixeles devuelve el area de contenido con iconos
          } else {
            return Row(
              children: [
                SafeArea(
                  // Se muestra el area de contenido en una columna con una barra de navegación y los iconos
                  child: NavigationRail(
                    extended: constraints.maxWidth >= 600,
                    destinations: [
                      NavigationRailDestination(
                        icon: Icon(Icons.home, color: Colors.pink),
                        label: Text('Inicio'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.favorite, color: Colors.green),
                        label: Text('Favoritos'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.add, color: Colors.blue),
                        label: Text('Añadir'),
                      )
                    ],
                    selectedIndex: selectedIndex,
                    onDestinationSelected: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  ),
                ),
                Expanded(child: mainArea),
              ],
            );
          }
        },
      ),
    );
  }
}

//Clase GeneratorPage que extiende widget de estado que es la pagina 1 es decir Inicio
class GeneratorPage extends StatelessWidget {
  @override
  //Crea un estado para la clase GeneratorPage
  Widget build(BuildContext context) {
    //Se crea un contexto de lectura para la clase MyAppState ya que en flutter hay que leer los estados
    var appState = context.watch<MyAppState>();
    //Se obtiene el primer elemento de la lista y si esta vacio se le asigna un valor "No hay lenguajes"
    var lenguaje = appState.history.isNotEmpty
        ? appState.history.first
        : "No hay lenguajes";
    //Se crea una variable para el icono de favorito que se le indica que que hay algun lenguaje en favoritos
    //seelcciones el icono y si no hay seleccione el icono donde solo hay un borde
    IconData icon;
    if (appState.favorites.contains(lenguaje)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }
    //devuelve un widget Center con un widget Column que contiene el titulo y los dos botones
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 50), // Añade un espacio de 50 píxeles de altura
          Text(
            'PROYECTO FLUTTER 2 EVA\nCarlos Molines Pastor\nMi proyecto de Lenguajes de Programación',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 0, 0, 0), // color del texto
            ),
            textAlign: TextAlign.center,
            maxLines: null,
          ),
          Padding(
            padding: EdgeInsets.all(20),
            //He creado el tyitulo en un boton que le da un estilo y un tamanio
            child: ElevatedButton(
              //Utilizamos un dialog para mostrar IntroducirDatos y que se puede salir dandole a escape.
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    child: IntroducirDatos(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 0, 0, 0),
                //theme.colorScheme.primary, // color de fondo del botón
              ),
              //El boton tiene un hijo que es un texto con un tamanio de 40 y un color blanco
              //que es el color del texto
              child: Text(
                'LENGUAJES DE PROGRAMACIÓN',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // color del texto
                ),
              ),
            ),
          ),
          //Se crea un widget Expanded con un widget Column que contiene el historial de lenguajes
          //y el widget BigCard que contiene el lenguaje seleccionado, ademas contiene los dos botones de me gusta y siguiente
          // con los que controlamos el flujo de la lista
          Expanded(
            flex: 3,
            child: HistoryListView(),
          ),
          SizedBox(height: 10),
          BigCard(lenguaje: lenguaje),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              //Se crea un widget Expanded con un widget Row que contiene el icono de
              //favorito y el botón de siguiente
              ElevatedButton.icon(
                onPressed: () {
                  if (appState.history.isNotEmpty) {
                    appState.toggleFavorite(appState.history.first);
                  }
                },
                icon: Icon(
                  icon,
                  color: Color.fromARGB(255, 255, 0, 76),
                ),
                label: Text('Me Gusta'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Siguiente'),
              ),
            ],
          ),
          //Se crea un widget Spacer con un tamanio de flex de 2
          Spacer(flex: 2),
        ],
      ),
    );
  }
}

//Clase BigCard que extiende widget de estado y sirve para mostrar
//el lenguaje seleccionado dentro de una tarjeta
class BigCard extends StatelessWidget {
  const BigCard({
    Key? key,
    required this.lenguaje,
  }) : super(key: key);
  //Variable que almacenara el lenguaje que se muestra en la tarjeta
  final String lenguaje;
  //Metodo para contruir el widget que devuelve un widget card que contiene el lenguaje
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    //Estilo basado en el tema displayMedium, pero con el tema de color cambiado a onPrimary
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary, // Tema de color
    );

    return Card(
      //color: theme.colorScheme.primary, // Tema de color
      color: Color.fromARGB(255, 163, 8, 253),
      child: Padding(
        padding: const EdgeInsets.all(
            20), // Relleno de 20 píxeles alrededor del texto
        child: AnimatedSize(
          // Anima el tamanio de la tarjeta
          duration: Duration(milliseconds: 200),
          //Cambia el tamanio de la tarjeta
          child: MergeSemantics(
            //Organiza a los elementos de la tarjeta en filas o columnas
            child: Wrap(
              children: [
                Text(
                  lenguaje,
                  style: style.copyWith(fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//Muestra la lista de lenguajes favoritos
class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //variables de tema y appState
    var theme = Theme.of(context);
    var appState = context.watch<MyAppState>();
    //Si la lista de favoritos esta vacia muestra un texto indicando que no hay favoritos
    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('NO EXISTEN FAVORITOS ACTUALMENTE',
            //Estilo texto
            style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 255, 0, 0))),
        //Estilo de fuente
      );
    }
    //Si la lista de favoritos no esta vacia muestra una lista de lenguajes favoritos
    //Devuelve un widget Column con un texto y  un widget Expanded que contiene un widget LayoutBuilder en lugar
    // de un GridView que tenia al principio, esta hecho con LayoutBuilder para que se adapte al tamanio de la pantalla
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(30),
          child: Text('Tienes '
              '${appState.favorites.length} lenguajes favoritos:'),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Calcula el margen basado en el ancho de la pantalla
              final double horizontalMargin =
                  constraints.maxWidth * 0.1; // 10% del ancho de la pantalla

              return Container(
                margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
                child: Wrap(
                  children: [
                    for (var pair in appState.favorites)
                      ListTile(
                        leading: IconButton(
                          icon: Icon(Icons.delete_outline,
                              semanticLabel: 'Delete'),
                          color: theme.colorScheme.primary,
                          onPressed: () {
                            appState.removeFavorite(pair);
                          },
                        ),
                        title: ElevatedButton(
                          onPressed: () async {
                            String language = pair;
                            String url;
                            //Podemos crear una url con el nombre del lenguaje por si hubiera problemas a la hora de la traduccion
                            switch (language.toLowerCase()) {
                              case 'flutter':
                                url =
                                    'https://es.wikipedia.org/wiki/Flutter_(software)';
                                break;
                              case 'c':
                                url =
                                    'https://es.wikipedia.org/wiki/C_(lenguaje_de_programación)';
                                break;
                              case 'c++':
                                url =
                                    'https://es.wikipedia.org/wiki/C%2B%2B_(lenguaje_de_programación)';
                                break;
                              case "c#":
                                url = 'https://es.wikipedia.org/wiki/C_Sharp';
                                break;
                              case 'kotlin':
                                url =
                                    'https://es.wikipedia.org/wiki/Kotlin_(lenguaje_de_programación)';
                                break;
                              case 'java':
                                url =
                                    'https://es.wikipedia.org/wiki/Java_(lenguaje_de_programación)';
                                break;
                              case 'python':
                                url =
                                    'https://es.wikipedia.org/wiki/Python_(lenguaje_de_programación)';
                                break;
                              default:
                                url = 'https://es.wikipedia.org/wiki/$language';
                            }

                            if (await canLaunchUrl(Uri.parse(url))) {
                              await launchUrl(Uri.parse(url));
                            } else {
                              throw 'Could not launch $url';
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.red, // este es el nuevo color del botón
                          ),
                          child: Text(
                              //MAyusculas
                              pair.toUpperCase(),
                              style: TextStyle(
                                color: Colors.white,
                              )),
                        ),
                      )
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

//Clase HistoryListView que extiende widget de estado y sirve para mostrar la lista de historial
class HistoryListView extends StatefulWidget {
  const HistoryListView({Key? key}) : super(key: key);

  @override
  State<HistoryListView> createState() => _HistoryListViewState();
}

//extiende el estado de la clase HistoryListView
class _HistoryListViewState extends State<HistoryListView> {
  //Crea una instancia de la clase GlobalKey para  identificar la lista animada
  final _key = GlobalKey();

  //Efecto de desvanecimiento de la lista animada
  static const Gradient _maskingGradient = LinearGradient(
    //gradiente de desvanecido
    colors: [Colors.transparent, Colors.black],
    // Desvanecido de 0.0 a 0.5
    stops: [0.0, 0.5],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  //Cambia el estado de la lista animada
  //Contruye el widget, utiliza el estado de la aplicacione para determinar cuantos
  //elementos hay en la lista del historial y para construir el elemnto de la lista.
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    appState.historyListKey = _key;
    //Aplica el gradiente de la lista
    return ShaderMask(
      shaderCallback: (bounds) => _maskingGradient.createShader(bounds),
      //Desvanecido de la lista
      blendMode: BlendMode.dstIn,
      child: AnimatedList(
        key: _key,
        reverse: true,
        padding: EdgeInsets.only(top: 100),
        initialItemCount: appState.history.length,
        itemBuilder: (context, index, animation) {
          final pair = appState.history[index];
          return SizeTransition(
            sizeFactor: animation,
            child: Center(
              child: TextButton.icon(
                onPressed: () {
                  appState.toggleFavorite(pair);
                },
                icon: appState.favorites.contains(pair)
                    ? Icon(Icons.favorite,
                        size: 12, color: Color.fromARGB(255, 255, 0, 76))
                    : SizedBox(),
                label: Text(
                  pair.toUpperCase(),
                  //semanticsLabel: pair.asPascalCase,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

//Creamos la clase IntroducirDatos para leer los datos introducidos por el usuario
//Es un widget que puede cambiar de estado
class IntroducirDatos extends StatefulWidget {
  @override
  //Directiva para ignorar una advertencia de privacidad de la biblioteca
  // ignore: library_private_types_in_public_api
  _IntroducirDatosState createState() =>
      _IntroducirDatosState(); //Creamos el estado
}

//Clase _IntroducirDatosState que extiende widget de estado de la clase IntroducirDatos
//
class _IntroducirDatosState extends State<IntroducirDatos> {
  final TextEditingController controller = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // Limpia el controlador cuando el Widget se descarte
    controller.dispose();
    super.dispose();
  }

  //Metodo que construye el widget
  @override
  Widget build(BuildContext context) {
    //Crea una instancia de la clase MyAppState que leemos desde el contexto
    var appState = context.read<MyAppState>();
    //Crea una instancia de la clase Theme
    var theme = Theme.of(context);
    //Devuelve un widget Scaffold con un widget Center que contiene un widget Column donde se crean los botones
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: theme.colorScheme.surfaceVariant,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(20),
              //Crteamos un boton para alojar el texto y que se vea mas bonito, por ello no tiene funcion
              child: ElevatedButton(
                onPressed: () {
                  //Boton sin funcion
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 0, 0, 0),
                  //theme.colorScheme.primary, // color de fondo del botón
                ),
                child: Text(
                  'LENGUAJE DE PROGRAMACIÓN',
                  style: TextStyle(
                    fontSize: 44, // Ajusta el tamaño del texto
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.surfaceVariant,
                  ),
                ),
              ),
            ),
            Form(
              key: formKey,
              child: SizedBox(
                width: 300, // Establece el ancho  para el TextFormField
                child: TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelStyle: TextStyle(color: theme.colorScheme.primary),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor introduce un lenguaje';
                    }
                    return null;
                  },
                  onFieldSubmitted: (value) {
                    if (formKey.currentState!.validate()) {
                      appState.addLenguaje(value);
                      controller.clear();
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 50), // Añade un espacio de 20 píxeles de altura
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  appState.addLenguaje(controller.text);
                  controller.clear();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 163, 8, 253),
              ),
              child: Text('Añadir lenguaje',
                  style: TextStyle(
                    color: Colors.white,
                  )),
            ),
            // Aquí van los demás widgets de tu columna
          ],
        ),
      ),
    );
  }
}

//Clase LenguajesModel para la lista de lenguajes y la notificación
// cuando la lista cambia
class LenguajesModel extends ChangeNotifier {
  final List<String> _lenguajes = [];

  List<String> get lenguajes => _lenguajes;

  void add(String lenguaje) {
    _lenguajes.add(lenguaje);
    notifyListeners();
  }
}
