import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poti_5f/src/features/profile/application/address_map_controller.dart';
import 'package:poti_5f/src/features/profile/domain/models/address_model.dart';
import 'package:poti_5f/src/features/profile/domain/models/geo_point_model.dart';

import 'fake_geocoding_repository.dart';

void main() {
  const endereco = AddressModel(street: 'Rua A', city: 'Teresina', state: 'PI');

  late FakeGeocodingRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeGeocodingRepository();
    container = ProviderContainer.test(
      overrides: [geocodingRepositoryProvider.overrideWithValue(repository)],
    );
    // Mantém vivo o provider autoDispose durante o teste.
    container.listen(addressMapControllerProvider, (_, _) {});
  });

  AddressMapController controller() =>
      container.read(addressMapControllerProvider.notifier);

  test('começa em Belém, sem pino', () {
    final mapa = container.read(addressMapControllerProvider);
    expect(mapa.centro, AddressMapController.belem);
    expect(mapa.marcador, isNull);
  });

  test('endereço encontrado: centraliza e marca o ponto', () async {
    await controller().buscarEndereco(endereco);

    final mapa = container.read(addressMapControllerProvider);
    expect(mapa.marcador, repository.pontoEncontrado);
    expect(mapa.centro, repository.pontoEncontrado);
    expect(mapa.aviso, isNull);
  });

  test('endereço não encontrado: volta para Belém com aviso', () async {
    await controller().buscarEndereco(endereco);
    repository.pontoEncontrado = null;
    await controller().buscarEndereco(endereco);

    final mapa = container.read(addressMapControllerProvider);
    expect(mapa.centro, AddressMapController.belem);
    expect(mapa.marcador, isNull);
    expect(mapa.aviso, contains('não encontrado'));
  });

  test('erro de rede: Belém com aviso', () async {
    repository.deveFalhar = true;
    await controller().buscarEndereco(endereco);

    final mapa = container.read(addressMapControllerProvider);
    expect(mapa.centro, AddressMapController.belem);
    expect(mapa.aviso, isNotNull);
  });

  test('toque no mapa: marca o ponto e devolve o endereço', () async {
    const ponto = GeoPointModel(latitude: -1.45, longitude: -48.49);

    final resultado = await controller().selecionarPonto(ponto);

    expect(resultado, repository.enderecoDoPonto);
    final mapa = container.read(addressMapControllerProvider);
    expect(mapa.marcador, ponto);
    // A câmera não pula: fica onde o usuário tocou.
    expect(mapa.centro, AddressMapController.belem);
  });

  test('agendarBusca espera a pausa e busca só o último endereço', () {
    fakeAsync((async) {
      controller().agendarBusca(const AddressModel(street: 'R', city: 'T'));
      async.elapse(const Duration(milliseconds: 500));
      controller().agendarBusca(endereco);

      async.elapse(AddressMapController.atrasoBusca);
      async.flushMicrotasks();

      expect(repository.buscas, [endereco]);
    });
  });
}
