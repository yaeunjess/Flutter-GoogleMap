import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_android/geolocator_android.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatelessWidget {
  static final LatLng companyLatLng = LatLng(
    37.29803865, // 37.29803865920832,
    126.8394624, // 126.83946249393534,
  );
  static final Marker marker = Marker(
    markerId: MarkerId('company'),
    position: companyLatLng,
  );
  static final Circle circle = Circle(
    circleId: CircleId('chholCheckCircle'),
    center: companyLatLng,
    fillColor: Colors.blue.withOpacity(0.5),
    radius: 100,
    strokeColor: Colors.blue,
    strokeWidth: 1,
  );

  const HomeScreen({super.key});

  Future<String> checkPermission() async {
    final isLocationEnabled = await Geolocator //
        .isLocationServiceEnabled(); // 위치 서비스 활성화 여부 확인

    // 위치 서비스 활성화 안됐을때
    if (!isLocationEnabled) {
      return '위치 서비스를 활성화해주세요.';
    }

    LocationPermission checkedPermission = await Geolocator
        .checkPermission(); // 위치 권한 확인

    // 위치 권한 거절됐을때
    if (checkedPermission == LocationPermission.denied) {
      // 위치 권한 요청하기
      checkedPermission = await Geolocator.requestPermission();

      if (checkedPermission == LocationPermission.denied) {
        return '위치 권환을 허가해주세요.';
      }
    }

    // 위치 권한 거절됐을때 (앱에서 재요청 불가)
    if (checkedPermission == LocationPermission.deniedForever) {
      return '앱의 위치 권환을 설정에서 허가해주세요.';
    }

    // 위의 모든 조건이 통과되면 위치 권한 허가 완료
    return '위치 권한이 허가 되었습니다.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: renderAppBar(),
        body: FutureBuilder<String>(
          future: checkPermission(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            // 로딩 상태
            if (!snapshot.hasData &&
                snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: CircularProgressIndicator(color: Colors.indigo,)
              );
            }

            // 권한 허가된 상태
            if (snapshot.data == '위치 권한이 허가 되었습니다.') {
              return Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: companyLatLng,
                        zoom: 16,
                      ),
                      markers: Set.from([marker]),
                      circles: Set.from([circle]),
                      myLocationEnabled: true, // 나의 현재 위치 표시
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.timelapse_outlined,
                          color: Colors.indigo,
                          size: 50.0,
                        ),
                        SizedBox(height: 20.0),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo[500],
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.0)),
                          ),
                          onPressed: () async {
                            final curPosition = await Geolocator.getCurrentPosition();
                            final distance = Geolocator.distanceBetween(
                              curPosition.latitude,
                              curPosition.longitude,
                              companyLatLng.latitude,
                              companyLatLng.longitude,
                            );
                            bool canChoolCheck = distance < 100;

                            showDialog(
                              context: context,
                              builder: (_) {
                                return AlertDialog(
                                  title: Text('출근하기'),
                                  content: Text(
                                    canChoolCheck ? '출근을 하시겠습니까?' : '출근할 수 없는 위치입니다.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: (){
                                        Navigator.of(context).pop(false);
                                      },
                                      child: Text('취소', style: TextStyle(color: Colors.indigo)),
                                    ),
                                    if(canChoolCheck)
                                      TextButton(
                                        onPressed: (){
                                          Navigator.of(context).pop(true);
                                        },
                                        child: Text('출근하기', style: TextStyle(color: Colors.indigo)),
                                      ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text(
                            '출근하기',
                            style: TextStyle(
                              color: Colors.white,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            // 권한 없는 상태
            return Center(
              child: Text(
                snapshot.data.toString(),
              ),
            );
          },
        )
    );
  }

  AppBar renderAppBar() {
    return AppBar(
      centerTitle: true,
      backgroundColor: Colors.white,
      title: Text(
        '오늘도 출근',
        style: TextStyle(
          color: Colors.indigo,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
