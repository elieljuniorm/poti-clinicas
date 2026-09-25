import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../data/data_sources/geocoding_remote_data_source.dart';
import '../data/repository/geocoding_repository_impl.dart';
import '../domain/models/address_model.dart';
import '../domain/models/geo_point_model.dart';
import '../domain/repositories/geocoding_repository.dart';
import '../ui/states/address_map_state.dart';

/// Liga o endereço do formulário ao mapa, nos dois sentidos:
/// digitar move o pino; tocar no mapa devolve o endereço do ponto.
class AddressMapController extends Notifier<AddressMapState> {
  /// Centro de Belém (PA): usado quando o endereço não é encontrado.
  static const belem = GeoPointModel(latitude: -1.4558, longitude: -48.4902);

  /// Espera o usuário parar de digitar antes de buscar.
  static const atrasoBusca = Duration(milliseconds: 1200);

  static const _avisoNaoEncontrado =
      'Endereço não encontrado. Toque no mapa para escolher o local.';

  GeocodingRepository get _repository => ref.read(geocodingRepositoryProvider);

  Timer? _espera;

  // Cada busca recebe um número; respostas de buscas antigas são descartadas.
  int _buscaAtual = 0;

  @override
  AddressMapState build() {
    ref.onDispose(() => _espera?.cancel());
    return const AddressMapState(centro: belem);
  }

  /// Chamado a cada alteração no formulário: busca só depois da pausa.
  void agendarBusca(AddressModel endereco) {
    _espera?.cancel();
    _espera = Timer(atrasoBusca, () => buscarEndereco(endereco));
  }

  /// Procura o endereço digitado e posiciona o pino.
  /// Sem resultado, o mapa volta para Belém.
  Future<void> buscarEndereco(AddressModel endereco) async {
    _espera?.cancel();
    final busca = ++_buscaAtual;
    state = state.copyWith(isSearching: true);

    try {
      final ponto = await _repository.buscarCoordenadas(endereco);
      if (!ref.mounted || busca != _buscaAtual) return;

      state = ponto == null
          ? const AddressMapState(centro: belem, aviso: _avisoNaoEncontrado)
          : AddressMapState(centro: ponto, marcador: ponto);
    } catch (e) {
      if (!ref.mounted || busca != _buscaAtual) return;
      state = const AddressMapState(
        centro: belem,
        aviso: 'Não foi possível buscar o endereço agora.',
      );
    }
  }

  /// Toque no mapa: move o pino para o [ponto] e devolve o endereço dele
  /// (ou `null` se não houver endereço ali). A câmera fica onde está.
  Future<AddressModel?> selecionarPonto(GeoPointModel ponto) async {
    _espera?.cancel();
    final busca = ++_buscaAtual;
    state = AddressMapState(
      centro: state.centro,
      marcador: ponto,
      isSearching: true,
    );

    try {
      final endereco = await _repository.buscarEndereco(ponto);
      if (!ref.mounted || busca != _buscaAtual) return null;

      state = AddressMapState(
        centro: state.centro,
        marcador: ponto,
        aviso: endereco == null
            ? 'Nenhum endereço encontrado neste ponto.'
            : null,
      );
      return endereco;
    } catch (e) {
      if (!ref.mounted || busca != _buscaAtual) return null;
      state = AddressMapState(
        centro: state.centro,
        marcador: ponto,
        aviso: 'Não foi possível buscar o endereço agora.',
      );
      return null;
    }
  }
}

// ============================================================
// Providers
// ============================================================

final geocodingDataSourceProvider = Provider<GeocodingDataSource>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return GeocodingDataSource(client);
});

final geocodingRepositoryProvider = Provider<GeocodingRepository>((ref) {
  return GeocodingRepositoryImpl(ref.watch(geocodingDataSourceProvider));
});

/// `autoDispose`: o mapa recomeça em Belém a cada abertura da edição.
final addressMapControllerProvider =
    NotifierProvider.autoDispose<AddressMapController, AddressMapState>(
      AddressMapController.new,
    );
