const String apiVersion = 'v1';
const String port = '3000';
final Uri url = Uri.parse('http://192.168.1.170:$port');
final Uri baseUrl = Uri.parse('$url/$apiVersion');
final String socketUrl = '$url';

// GET IPADDRESS MAC - ipconfig getifaddr en0
