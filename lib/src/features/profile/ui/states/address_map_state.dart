import '../../domain/models/geo_point_model.dart';

/// O que o mapa de endereço mostra.
class AddressMapState {
  /// Para onde a câmera aponta.
  final GeoPointModel centro;

  /// Pino do endereço. `null` quando o endereço não foi encontrado.
  final GeoPointModel? marcador;
  final bool isSearching;

  /// Mensagem curta abaixo do mapa (ex.: endereço não encontrado).
  final String? aviso;

  const AddressMapState({
    required this.centro,
    this.marcador,
    this.isSearching = false,
    this.aviso,
  });

  AddressMapState copyWith({bool? isSearching}) {
    return AddressMapState(
      centro: centro,
      marcador: marcador,
      isSearching: isSearching ?? this.isSearching,
      aviso: aviso,
    );
  }
}
