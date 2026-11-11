import '../local/catalogo_json.dart';
import '../local/daos.dart';
import '../models/materia.dart';
import '../services/recordatorios_service.dart';

class MateriasRepository {
  MateriasRepository(this._dao, this._tareaDao, this._catalogo, this._recordatorios);
  final MateriaDao _dao;
  final TareaDao _tareaDao;
  final CatalogoJson _catalogo;
  final RecordatoriosService _recordatorios;

  Future<List<Materia>> listar(int usuarioId) => _dao.listar(usuarioId);

  Future<void> guardar(Materia m) async {
    if (m.id == null) {
      await _dao.insertar(m);
    } else {
      await _dao.actualizar(m);
    }
  }

  Future<void> eliminar(Materia m) async {
    if (m.id == null) return;
    // Sus tareas se borran en cascada; antes se cancelan sus recordatorios.
    for (final idTarea in await _tareaDao.idsDeMateria(m.id!)) {
      await _recordatorios.cancelar(idTarea);
    }
    await _dao.eliminar(m.id!);
  }

  Future<List<MateriaSugerida>> catalogoSugerido() => _catalogo.leer();
}
