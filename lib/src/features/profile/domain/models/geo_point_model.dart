/// Ponto no mapa. Usado só para localizar o endereço;
/// não faz parte dos dados salvos do perfil.
class GeoPointModel {
  final double latitude;
  final double longitude;

  const GeoPointModel({required this.latitude, required this.longitude});

  @override
  bool operator ==(Object other) =>
      other is GeoPointModel &&
      other.latitude == latitude &&
      other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);
}
