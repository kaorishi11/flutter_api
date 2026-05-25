import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'models/pokemon.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pokédex',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
      ),
      home: const MyHomePage(
        title: 'Pokemons',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<MyHomePage> createState() =>
      _MyHomePageState();
}

class _MyHomePageState
    extends State<MyHomePage> {

  final TextEditingController controller =
      TextEditingController();

  bool carregando = false;
  String? erro;

  List<Pokemon> pokemons = [];

  @override
  void initState() {
    super.initState();
    carregar20Pokemons();
  }

  Future<void> carregar20Pokemons() async {
    setState(() {
      carregando = true;
      erro = null;
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://pokeapi.co/api/v2/pokemon?limit=20',
        ),
      );

      final dados =
          jsonDecode(response.body);

      final results =
          dados['results'] as List;

      List<Pokemon> lista = [];

      for (var item in results) {
        final detalheResponse =
            await http.get(
          Uri.parse(item['url']),
        );

        final detalhe =
            jsonDecode(
          detalheResponse.body,
        );

        lista.add(
          Pokemon.fromJson(
            detalhe,
          ),
        );
      }

      setState(() {
        pokemons = lista;
      });
    } catch (e) {
      setState(() {
        erro =
            'Sem internet ou erro ao carregar Pokémon.';
      });
    }

    setState(() {
      carregando = false;
    });
  }

  Future<void> buscarPokemon() async {
    final texto = controller.text
        .trim()
        .toLowerCase();

    if (texto.isEmpty) {
      carregar20Pokemons();
      return;
    }

    setState(() {
      carregando = true;
      erro = null;
    });

    try {
      final response =
          await http.get(
        Uri.parse(
          'https://pokeapi.co/api/v2/pokemon/$texto',
        ),
      );

      if (response.statusCode == 404) {
        setState(() {
          erro =
              'Pokémon não encontrado.';
          pokemons = [];
        });
        return;
      }

      final dados =
          jsonDecode(response.body);

      setState(() {
        pokemons = [
          Pokemon.fromJson(
            dados,
          ),
        ];
      });
    } catch (e) {
      setState(() {
        erro =
            'Sem internet ou erro ao buscar Pokémon.';
      });
    }

    setState(() {
      carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Theme.of(context)
                .colorScheme
                .inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller:
                  controller,
              decoration:
                  const InputDecoration(
                labelText:
                    'Digite nome ou ID',
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            ElevatedButton(
              onPressed:
                  buscarPokemon,
              child: const Text(
                'Buscar',
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            Expanded(
              child: carregando
                  ? const Center(
                      child:
                          CircularProgressIndicator(),
                    )
                  : erro != null
                      ? Center(
                          child:
                              Text(
                            erro!,
                            style:
                                const TextStyle(
                              fontSize:
                                  18,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount:
                              pokemons
                                  .length,
                          itemBuilder:
                              (context,
                                  index) {

                            final pokemon =
                                pokemons[
                                    index];

                            return ListTile(
                              leading:
                                  Image.network(
                                pokemon
                                    .urlImage,
                                width:
                                    60,
                                height:
                                    60,
                              ),
                              title:
                                  Text(
                                pokemon
                                    .name
                                    .toUpperCase(),
                              ),
                              subtitle:
                                  Text(
                                'Nº ${pokemon.id}',
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}