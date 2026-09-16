import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'database/database_helper.dart';
import 'dart:io';


void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows ||
      Platform.isLinux ||
      Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //Remove a faixa DEBUG
      debugShowCheckedModeBanner: false,

      // theme: ThemeData(
      //   scaffoldBackgroundColor: const Color.fromARGB(255, 83, 40, 40),
      // ),

      //Título do App
      title: 'Lista de Tarefas',

      //Tela Inicial
      home: const HomePage(),
    );
  }
}

/// Nossa página principal.
///
/// Como os dados irão mudar (adicionar/remover tarefas),
/// precisamos utilizar StatefulWidget.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// Controller utilizado para capturar o texto digitado
  /// no campo de entrada.
  final TextEditingController controller = TextEditingController();

  /// Lista que armazenará as tarefas.
  ///
  /// Exemplo:
  /// [
  ///   "Estudar Flutter",
  ///   "Fazer exercícios",
  ///   "Ler documentação"
  /// ]
  // List<String> tarefas = [];

  List<Map<String, dynamic>> tarefas = [];
  @override
  void initState() {
    super.initState();
    carregarTarefas();
  }

  Future<void> carregarTarefas() async {
    final dados = await DatabaseHelper.instance.listarTarefas();

    setState(() {
      tarefas = dados;
    });
  }

  /// Função responsável por adicionar uma nova tarefa.
  // void adicionarTarefa() {
  //   /// Verifica se o usuário digitou algo.
  //   if (controller.text.isEmpty) {
  //     return;
  //   }

  //   /// setState informa ao Flutter que os dados mudaram.
  //   /// Sempre que chamamos setState, a tela é redesenhada.
  //   setState(() {
  //     /// Adiciona o texto digitado na lista.
  //     tarefas.add({'descricao': controller.text});
  //   });

  //   /// Limpa o campo após adicionar a tarefa.
  //   controller.clear();
  // }
  Future<void> adicionarTarefa() async {
    if (controller.text.trim().isEmpty) {
      return;
    }

    await DatabaseHelper.instance.inserirTarefa(controller.text);

    controller.clear();

    carregarTarefas();
  }

  // /// Remove uma tarefa da lista.
  // void removerTarefa(int index) {
  //   setState(() {
  //     /// Remove a tarefa pela posição.
  //     tarefas.removeAt(index);
  //   });
  // }

  Future<void> removerTarefa(int id) async {
    await DatabaseHelper.instance.removerTarefa(id);

    carregarTarefas();
  }

  Widget build(BuildContext context) {
    /// Método responsável por construir a interface da página inicial.
    return Scaffold(
      ///Barra superior do App
      ///
      ///
      backgroundColor: Colors.amber[100],
      appBar: AppBar(
        title: const Text(
          'Lista de Tarefas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.redAccent,
          ),
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Campo de texto para digitar a tarefa
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: 'Digite uma tarefa',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),
                // Botão para adicionar a tarefa
                ElevatedButton(
                  onPressed: () {
                    // Ação ao pressionar o botão
                    adicionarTarefa();
                  },
                  child: const Text('Adicionar'),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: tarefas.length, // Número de tarefas (exemplo)
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(tarefas[index]['descricao']),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          // Ação para remover a tarefa
                          removerTarefa(tarefas[index]['id']);
                        },
                      ),
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
