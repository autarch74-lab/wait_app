# run_tests.ps1 예시
New-Item -ItemType Directory -Path C:\flutter_temp -Force
$env:TEMP = 'C:\flutter_temp'
$env:TMP  = 'C:\flutter_temp'
flutter clean
flutter pub get
flutter test -v
