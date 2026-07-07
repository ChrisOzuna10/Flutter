import 'package:flutter/material.dart';
import '../controllers/bitacora_controller.dart';
import '../../../data/repositories/local_storage_service.dart';
import '../../../data/repositories/auth_repository.dart';

class BitacoraTab extends StatefulWidget {
  const BitacoraTab({Key? key}) : super(key: key);

  @override
  State<BitacoraTab> createState() => _BitacoraTabState();
}

class _BitacoraTabState extends State<BitacoraTab> {
  final BitacoraController _ctrl = BitacoraController();

  @override
  void initState() {
    super.initState();
    _ctrl.load();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        if (_ctrl.isLoading) return const Center(child: CircularProgressIndicator());
        if (_ctrl.entries.isEmpty) return const Center(child: Text('No hay entradas'));

        return RefreshIndicator(
          onRefresh: _ctrl.refresh,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20,20,20,24),
            itemCount: _ctrl.entries.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final text = _ctrl.entries[index];
              return ListTile(
                title: Text(text),
                leading: const Icon(Icons.note_rounded),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _onEdit(index),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _onEdit(int index) async {
    final editCtrl = TextEditingController(text: _ctrl.entries[index]);
    final passCtrl = TextEditingController();
    final storage = LocalStorageService();
    final userEmail = await storage.getUserEmail();

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar entrada'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: editCtrl,
              decoration: const InputDecoration(labelText: 'Contenido'),
            ),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final password = passCtrl.text;
              if (userEmail == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se encontró email para re-autenticación')));
                return;
              }
              final repo = AuthRepository();
              try {
                await repo.signIn(email: userEmail, password: password);
                _ctrl.updateEntry(index, editCtrl.text);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Entrada actualizada')));
                }
                Navigator.of(ctx).pop();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Autenticación fallida')));
                }
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
