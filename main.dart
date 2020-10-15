
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
//import 'package:geolocator/geolocator.dart';   //  for gps location
import 'package:flutter/services.dart';   //  for vibration
import 'package:flutter_map/flutter_map.dart';   //  for map
import 'package:latlong/latlong.dart';   //  for latitude longitude
import 'package:location/location.dart';   //  for gps location

void main() {
  runApp(
    MyApp()
 //     ChangeNotifierProvider(
 //         create: (context) => UserSelections(),
 //         child: MyApp()
 //     ),
  );
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserSelections(),
      child: MaterialApp(
//      title: 'BSR Raptor Canyon Track',
          theme: ThemeData(
            primarySwatch: Colors.red,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: AppFrame()
      )
    );
  }
}

final pageController = PageController(
  initialPage: 0,
);


class UserSelections extends ChangeNotifier {
  TeamChoice _selectedTeam;
  PlayerMarker _selectedMarker;

  void selectTeam(TeamChoice teamChoice) {
    _selectedTeam = teamChoice;
    notifyListeners();
    HapticFeedback.vibrate();
  }

  void selectMarker(PlayerMarker marker) {
    _selectedMarker = marker;
    notifyListeners();
    HapticFeedback.vibrate();
  }
}

// ---------- AppFrame ---------- //
class AppFrame extends StatefulWidget {
  AppFrame({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _AppFrameState createState() => _AppFrameState();
}

class _AppFrameState extends State<AppFrame> {

  List<Widget> pages = [
    HomePage(),
    MapPage(),
    ReplayPage(),
  ];

  var _selectedIndex = 0;
  void _onNavBarTapped(int index) {
    HapticFeedback.vibrate();
    setState(() {
      _selectedIndex = index;
    });
    if (index % 3 == 0) {
      pageController.animateToPage(0, duration: Duration(milliseconds: 400), curve: Curves.ease);
    } else if (index % 3 == 1) {
      pageController.animateToPage(1, duration: Duration(milliseconds: 400), curve: Curves.ease);
    } else {
      pageController.animateToPage(2, duration: Duration(milliseconds: 400), curve: Curves.ease);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: pageController,
        children: pages,
      ),
        bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                title: Text('Home'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.map),
                title: Text('Map'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.video_library),
                title: Text('Replay'),
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: _onNavBarTapped
        )
    );
  }
}

// ---------- HomePage ---------- //
class HomePage extends StatefulWidget {

  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  //------------------ Initiate TextEditingController and dispose
  TextEditingController _textEditingController;
  String _playerName;

  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
  }

  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserSelections>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('BSR Raptor Canyon Tracker'),
        backgroundColor: Colors.black,
        actions: <Widget>[
          Image(image: AssetImage('assets/BSR_Full_Logo.jpg')),
          SizedBox(width: 20)
        ],
      ),
      body: Container(
        child: Row(
          children: <Widget>[
            SizedBox(width: 30),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 20),
                Container(
                  width: 380,
                  child: Padding( //-------------------  Player Name TextField
                    padding: EdgeInsets.fromLTRB(0, 20, 30, 10),
                    child: TextField(
                      controller: _textEditingController,
                      style: TextStyle(fontSize: 30,),
                      onSubmitted: (String value) {
                        _playerName = value;
                        print(_playerName);
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Player Name',
                        labelStyle: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row( //-------------------  Select Team Button
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text('Team/Color:  ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500,)),
                    PopupMenuButton<TeamChoice>(
                      onCanceled: HapticFeedback.vibrate,
                      onSelected: user.selectTeam,
                      color: Colors.grey[300],
                      itemBuilder: (BuildContext context) {
                        return _teams.map((TeamChoice teamChoice) {
                          return PopupMenuItem<TeamChoice>(
                            value: teamChoice,
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.stop, color: teamChoice.color, size: 40),
                                Text(teamChoice.title, style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500,)),
                            ]),
                          );
                        }).toList();
                      },
                      child: Card(
                        child: InkWell(
                          splashColor: Colors.red.withAlpha(40),
                          child: Container(
                            color: Colors.black.withAlpha(20),
                            padding: EdgeInsets.fromLTRB(5, 5, 10, 5),
                            child: Consumer<UserSelections>(
                              builder: (context, user, child) {
                                return Row(
                                  children: user._selectedTeam == null ?
                                  <Widget>[Text(' No Team Selected', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500,),)] :
                                  <Widget>[
                                    Icon(Icons.stop, color: user._selectedTeam.color, size: 40,),
                                    Text(user._selectedTeam.title, style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500,)),
                                  ]
                                );
                              }
                            )
                          ),
                        ),
                      )
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row( //-------------------  Select Player Icon
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text('Player Marker:  ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500,)),
                    PopupMenuButton<PlayerMarker>(
                      onCanceled: HapticFeedback.vibrate,
                      onSelected: user.selectMarker,
                      color: Colors.grey[300],
                      itemBuilder: (BuildContext context) {
                        return _markers.map((PlayerMarker marker) {
                          return PopupMenuItem<PlayerMarker>(
                            value: marker,
                            height: 75,
                            child: Center(
                              child: user._selectedTeam != null
                              ? Icon(marker.marker, color: user._selectedTeam.color, size: 50,)
                              : Icon(marker.marker, color: Colors.black, size: 50,)
                            )
                          );
                        }).toList();
                      },
                      child: Card(
                        child: InkWell(
                          splashColor: Colors.red.withAlpha(40),
                          child: Container(
                            color: Colors.black.withAlpha(20),
                            padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                            child: Consumer<UserSelections>(
                              builder: (context, user, child) {
                                return Row(
                                    children: user._selectedMarker == null
                                      ? <Widget>[Text('No Marker Selected', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500,),),]
                                      : user._selectedTeam == null
                                        ? <Widget>[Icon(user._selectedMarker.marker, color: Colors.black, size: 40,),]
                                        : <Widget>[Icon(user._selectedMarker.marker, color: user._selectedTeam.color, size: 40,),]
                                );
                              }
                            )
                          ),
                        ),
                      )
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row( //-------------------  Select Option 3
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    //               SizedBox(width: 30),
                    Text('Available Games:  ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500,)),
                    RaisedButton(
                      onPressed: () {},
                      color: Colors.white70,
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                          'Scan for Games', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500,)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TeamChoice {
  TeamChoice({this.title, this.color});
  final String title;
  final Color color;
}

final List<TeamChoice> _teams = <TeamChoice>[
  TeamChoice(title: 'Red Eagles', color: Colors.red),
  TeamChoice(title: 'Blue Falcons', color: Colors.blue),
  TeamChoice(title: 'Green Hawks', color: Colors.green),
  TeamChoice(title: 'Orange Ospreys', color: Colors.orange),
  TeamChoice(title: 'Yellow Vultures', color: Colors.yellow),
  TeamChoice(title: 'Brown Buzzards', color: Colors.brown),
  TeamChoice(title: 'White Owls', color: Colors.white),
  TeamChoice(title: 'Black Kites', color: Colors.black),
];

class PlayerMarker {
  PlayerMarker({this.marker});
  final IconData marker;
}

final List<PlayerMarker> _markers = <PlayerMarker>[
  PlayerMarker(marker: Icons.navigation),
//  PlayerMarker(marker: Icons.close),
  PlayerMarker(marker: Icons.stop),
  PlayerMarker(marker: Icons.brightness_1),
  PlayerMarker(marker: Icons.adjust),
  PlayerMarker(marker: Icons.star),
  PlayerMarker(marker: Icons.favorite),
  PlayerMarker(marker: Icons.arrow_drop_down),
  PlayerMarker(marker: Icons.change_history),
  PlayerMarker(marker: Icons.details),
  PlayerMarker(marker: Icons.whatshot),
  PlayerMarker(marker: Icons.audiotrack),
  PlayerMarker(marker: Icons.attach_money),
  PlayerMarker(marker: Icons.casino),
  PlayerMarker(marker: Icons.remove_red_eye),
  PlayerMarker(marker: Icons.school),
  PlayerMarker(marker: Icons.security),
  PlayerMarker(marker: Icons.cloud),
  PlayerMarker(marker: Icons.cloud_queue),
  PlayerMarker(marker: Icons.public),
  PlayerMarker(marker: Icons.flash_on),
  PlayerMarker(marker: Icons.delete),
  PlayerMarker(marker: Icons.person),
  PlayerMarker(marker: Icons.directions_run),
  PlayerMarker(marker: Icons.directions_bike),
  PlayerMarker(marker: Icons.child_care),
  PlayerMarker(marker: Icons.pets),
  PlayerMarker(marker: Icons.landscape),
  PlayerMarker(marker: Icons.looks_one),
  PlayerMarker(marker: Icons.looks_two),
  PlayerMarker(marker: Icons.looks_3),
  PlayerMarker(marker: Icons.looks_4),
  PlayerMarker(marker: Icons.looks_5),
  PlayerMarker(marker: Icons.looks_6),
];

final raptorCanyonMBTiles = MBTilesImageProvider.fromAsset('assets/map/RaptorCanyonMap3.mbtiles');

// ---------- MapPage ---------- //
class MapPage extends StatefulWidget {
  MapPage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  //Position position;
  //Position displayPosition;

  MapController mapController;
  LocationData currentLocation;

  bool liveUpdate = false;
  bool permission = false;
  bool showBases = true;

  //final raptorCanyonMBTiles = MBTilesImageProvider.fromAsset('assets/map/RaptorCanyonMap3.mbtiles');

  String serviceError = '';

  final Location locationService = Location();

  //final List<LocationData> locationData = [
  //  LocationData(45.6672929,-111.0605085),
  //];

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    initLocationService();
  }

  void initLocationService() async {
    await locationService.changeSettings(
      accuracy: LocationAccuracy.high,
      interval: 1000,
    );

    LocationData location;
    bool serviceEnabled;
    bool serviceRequestResult;
    //PermissionStatus permissionGranted;

    try {
      serviceEnabled = await locationService.serviceEnabled();

      if (serviceEnabled) {
        var permissionGranted = await locationService.requestPermission();
        permission = permissionGranted == PermissionStatus.granted;

        if (permission) {
          location = await locationService.getLocation();
          currentLocation = location;
          locationService
              .onLocationChanged
              .listen((LocationData result) async {
            if (mounted) {
              setState(() {
                currentLocation = result;

                // If Live Update is enabled, move map center
                if (liveUpdate) {
                  mapController.move(
                      LatLng(currentLocation.latitude,
                          currentLocation.longitude),
                      mapController.zoom);
                }
              });
            }
          });
        }
      } else {
        serviceRequestResult = await locationService.requestService();
        if (serviceRequestResult) {
          initLocationService();
          return;
        }
      }
    } on PlatformException catch (e) {
      print(e);
      if (e.code == 'PERMISSION_DENIED') {
        serviceError = e.message;
      } else if (e.code == 'SERVICE_STATUS_ERROR') {
        serviceError = e.message;
      }
      location = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    LatLng currentLatLng;

    currentLocation == null
    ? currentLatLng = LatLng(45.848881, -108.382856)
    : currentLatLng = LatLng(currentLocation.latitude, currentLocation.longitude);

    var markers = <Marker>[
      Marker(
        width: 80.0,
        height: 80.0,
        point: currentLatLng,
        builder: (context) => Container(
          child: Consumer<UserSelections>(
            builder: (context, user, child) {
              return user._selectedMarker == null
                  ? Icon(Icons.navigation)
                  : user._selectedTeam == null
                  ? Icon(user._selectedMarker.marker)
                  : Icon(user._selectedMarker.marker, color: user._selectedTeam.color,);
            },
          ),
        ),
      ),
      Marker( //---------------- Red Fort
        width: 80.0,
        height: 80.0,
        point: LatLng(45.848897, -108.383625),
        builder: (context) => Container(
          child: Icon(Icons.stop, color: Colors.red,),
        ),
      ),
      Marker( //---------------- Yellow Fort
        width: 80.0,
        height: 80.0,
        point: LatLng(45.847557, -108.383735),
        builder: (context) => Container(
          child: Icon(Icons.stop, color: Colors.yellow,),
        ),
      ),
      Marker( //---------------- White Fort
        width: 80.0,
        height: 80.0,
        point: LatLng(45.848301, -108.382415),
        builder: (context) => Container(
          child: Icon(Icons.stop, color: Colors.grey[200],),
        ),
      ),
      Marker( //---------------- Blue Fort
        width: 80.0,
        height: 80.0,
        point: LatLng(45.846842, -108.384243),
        builder: (context) => Container(
          child: Icon(Icons.stop, color: Colors.blue,),
        ),
      ),
      Marker( //---------------- Green Fort
        width: 80.0,
        height: 80.0,
        point: LatLng(45.850040, -108.383225),
        builder: (context) => Container(
          child: Icon(Icons.stop, color: Colors.green,),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          FloatingActionButton(
            onPressed: () => liveUpdate = !liveUpdate,
            child: liveUpdate ? Icon(Icons.location_on) : Icon(Icons.location_off),
          ),
        ],
      ),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          center: LatLng(45.849125, -108.384470),//LatLng(currentLatLng.latitude, currentLatLng.longitude),//LatLng(45.848881, -108.382856),
          zoom: 18.0,
          maxZoom: 20.0,
          minZoom: 17.0,
          //bounds: LatLngBounds(LatLng(45.851813,-108.385835),LatLng(45.845929,-108.379195)),
          swPanBoundary: LatLng(45.84695,-108.385),//45.845929,-108.385835.. .001021, .000385
          nePanBoundary: LatLng(45.850792,-108.38003),//45.851813,-108.379195
        ),
        layers: [
          //TileLayerOptions(
              //urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              //subdomains: ['a','b','c']
          //   ),
          MarkerLayerOptions(markers: markers),
        ],
        children: <Widget>[
          TileLayerWidget(
            options: TileLayerOptions(
              tileProvider: raptorCanyonMBTiles,
              maxZoom: 20.0,
              minZoom: 17.0,
              tms: true,
            ),
          )
        ],
      )
    );
  }
}

// ---------- ReplayPage ---------- //
class ReplayPage extends StatefulWidget {
  @override
  _ReplayPageState createState() => _ReplayPageState();
}

class _ReplayPageState extends State<ReplayPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Replay Page'),
            Icon(Icons.build),
            Text('Under Construction')
          ],
        ),
      ),
    );
  }
}
