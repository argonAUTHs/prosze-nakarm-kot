import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  DatabaseService._();

  static final DatabaseService db = DatabaseService._();
  static Database? _database;

  Future<Database?> get database async {
    _database = await initDB();
    return _database;
  }

  initDB() async{
    return await openDatabase(
      join(await getDatabasesPath(), 'acdc_db.db'),
      onCreate: (db, version) async {
        await db.execute('CREATE TABLE acdc(issuer TEXT, data TEXT, schema TEXT, signature TEXT, date_issued TEXT, meta_description TEXT)');
        await db.execute('ALTER TABLE acdc ADD COLUMN oobi TEXT');
        await db.execute('ALTER TABLE acdc ADD COLUMN profile TEXT');
        await db.execute('ALTER TABLE acdc ADD COLUMN issued TEXT');
        await db.execute('ALTER TABLE acdc ADD COLUMN acdcJson TEXT');
      },
      version: 11,
    );
  }
}