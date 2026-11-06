// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $RoomsTable extends Rooms with TableInfo<$RoomsTable, Room> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoomsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, note, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rooms';
  @override
  VerificationContext validateIntegrity(
    Insertable<Room> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Room map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Room(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $RoomsTable createAlias(String alias) {
    return $RoomsTable(attachedDatabase, alias);
  }
}

class Room extends DataClass implements Insertable<Room> {
  final int id;
  final String name;
  final String note;
  final int sortOrder;
  const Room({
    required this.id,
    required this.name,
    required this.note,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['note'] = Variable<String>(note);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  RoomsCompanion toCompanion(bool nullToAbsent) {
    return RoomsCompanion(
      id: Value(id),
      name: Value(name),
      note: Value(note),
      sortOrder: Value(sortOrder),
    );
  }

  factory Room.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Room(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      note: serializer.fromJson<String>(json['note']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'note': serializer.toJson<String>(note),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Room copyWith({int? id, String? name, String? note, int? sortOrder}) => Room(
    id: id ?? this.id,
    name: name ?? this.name,
    note: note ?? this.note,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  Room copyWithCompanion(RoomsCompanion data) {
    return Room(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      note: data.note.present ? data.note.value : this.note,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Room(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('note: $note, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, note, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Room &&
          other.id == this.id &&
          other.name == this.name &&
          other.note == this.note &&
          other.sortOrder == this.sortOrder);
}

class RoomsCompanion extends UpdateCompanion<Room> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> note;
  final Value<int> sortOrder;
  const RoomsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.note = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  RoomsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.note = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Room> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? note,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (note != null) 'note': note,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  RoomsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? note,
    Value<int>? sortOrder,
  }) {
    return RoomsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      note: note ?? this.note,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoomsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('note: $note, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $CabinetsTable extends Cabinets with TableInfo<$CabinetsTable, Cabinet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CabinetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  @override
  late final GeneratedColumn<int> roomId = GeneratedColumn<int>(
    'room_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES rooms (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, roomId, name, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cabinets';
  @override
  VerificationContext validateIntegrity(
    Insertable<Cabinet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('room_id')) {
      context.handle(
        _roomIdMeta,
        roomId.isAcceptableOrUnknown(data['room_id']!, _roomIdMeta),
      );
    } else if (isInserting) {
      context.missing(_roomIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Cabinet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Cabinet(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      roomId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}room_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $CabinetsTable createAlias(String alias) {
    return $CabinetsTable(attachedDatabase, alias);
  }
}

class Cabinet extends DataClass implements Insertable<Cabinet> {
  final int id;
  final int roomId;
  final String name;
  final int sortOrder;
  const Cabinet({
    required this.id,
    required this.roomId,
    required this.name,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['room_id'] = Variable<int>(roomId);
    map['name'] = Variable<String>(name);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  CabinetsCompanion toCompanion(bool nullToAbsent) {
    return CabinetsCompanion(
      id: Value(id),
      roomId: Value(roomId),
      name: Value(name),
      sortOrder: Value(sortOrder),
    );
  }

  factory Cabinet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Cabinet(
      id: serializer.fromJson<int>(json['id']),
      roomId: serializer.fromJson<int>(json['roomId']),
      name: serializer.fromJson<String>(json['name']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'roomId': serializer.toJson<int>(roomId),
      'name': serializer.toJson<String>(name),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Cabinet copyWith({int? id, int? roomId, String? name, int? sortOrder}) =>
      Cabinet(
        id: id ?? this.id,
        roomId: roomId ?? this.roomId,
        name: name ?? this.name,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  Cabinet copyWithCompanion(CabinetsCompanion data) {
    return Cabinet(
      id: data.id.present ? data.id.value : this.id,
      roomId: data.roomId.present ? data.roomId.value : this.roomId,
      name: data.name.present ? data.name.value : this.name,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Cabinet(')
          ..write('id: $id, ')
          ..write('roomId: $roomId, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, roomId, name, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Cabinet &&
          other.id == this.id &&
          other.roomId == this.roomId &&
          other.name == this.name &&
          other.sortOrder == this.sortOrder);
}

class CabinetsCompanion extends UpdateCompanion<Cabinet> {
  final Value<int> id;
  final Value<int> roomId;
  final Value<String> name;
  final Value<int> sortOrder;
  const CabinetsCompanion({
    this.id = const Value.absent(),
    this.roomId = const Value.absent(),
    this.name = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  CabinetsCompanion.insert({
    this.id = const Value.absent(),
    required int roomId,
    required String name,
    this.sortOrder = const Value.absent(),
  }) : roomId = Value(roomId),
       name = Value(name);
  static Insertable<Cabinet> custom({
    Expression<int>? id,
    Expression<int>? roomId,
    Expression<String>? name,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (roomId != null) 'room_id': roomId,
      if (name != null) 'name': name,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  CabinetsCompanion copyWith({
    Value<int>? id,
    Value<int>? roomId,
    Value<String>? name,
    Value<int>? sortOrder,
  }) {
    return CabinetsCompanion(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<int>(roomId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CabinetsCompanion(')
          ..write('id: $id, ')
          ..write('roomId: $roomId, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $ShelvesTable extends Shelves with TableInfo<$ShelvesTable, Shelf> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShelvesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _cabinetIdMeta = const VerificationMeta(
    'cabinetId',
  );
  @override
  late final GeneratedColumn<int> cabinetId = GeneratedColumn<int>(
    'cabinet_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cabinets (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _shelfIndexMeta = const VerificationMeta(
    'shelfIndex',
  );
  @override
  late final GeneratedColumn<int> shelfIndex = GeneratedColumn<int>(
    'shelf_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _filledMeta = const VerificationMeta('filled');
  @override
  late final GeneratedColumn<bool> filled = GeneratedColumn<bool>(
    'filled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("filled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cabinetId,
    shelfIndex,
    label,
    filled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shelves';
  @override
  VerificationContext validateIntegrity(
    Insertable<Shelf> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cabinet_id')) {
      context.handle(
        _cabinetIdMeta,
        cabinetId.isAcceptableOrUnknown(data['cabinet_id']!, _cabinetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cabinetIdMeta);
    }
    if (data.containsKey('shelf_index')) {
      context.handle(
        _shelfIndexMeta,
        shelfIndex.isAcceptableOrUnknown(data['shelf_index']!, _shelfIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_shelfIndexMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('filled')) {
      context.handle(
        _filledMeta,
        filled.isAcceptableOrUnknown(data['filled']!, _filledMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Shelf map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Shelf(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cabinetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cabinet_id'],
      )!,
      shelfIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}shelf_index'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
      filled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}filled'],
      )!,
    );
  }

  @override
  $ShelvesTable createAlias(String alias) {
    return $ShelvesTable(attachedDatabase, alias);
  }
}

class Shelf extends DataClass implements Insertable<Shelf> {
  final int id;
  final int cabinetId;
  final int shelfIndex;
  final String? label;
  final bool filled;
  const Shelf({
    required this.id,
    required this.cabinetId,
    required this.shelfIndex,
    this.label,
    required this.filled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cabinet_id'] = Variable<int>(cabinetId);
    map['shelf_index'] = Variable<int>(shelfIndex);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    map['filled'] = Variable<bool>(filled);
    return map;
  }

  ShelvesCompanion toCompanion(bool nullToAbsent) {
    return ShelvesCompanion(
      id: Value(id),
      cabinetId: Value(cabinetId),
      shelfIndex: Value(shelfIndex),
      label: label == null && nullToAbsent
          ? const Value.absent()
          : Value(label),
      filled: Value(filled),
    );
  }

  factory Shelf.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Shelf(
      id: serializer.fromJson<int>(json['id']),
      cabinetId: serializer.fromJson<int>(json['cabinetId']),
      shelfIndex: serializer.fromJson<int>(json['shelfIndex']),
      label: serializer.fromJson<String?>(json['label']),
      filled: serializer.fromJson<bool>(json['filled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cabinetId': serializer.toJson<int>(cabinetId),
      'shelfIndex': serializer.toJson<int>(shelfIndex),
      'label': serializer.toJson<String?>(label),
      'filled': serializer.toJson<bool>(filled),
    };
  }

  Shelf copyWith({
    int? id,
    int? cabinetId,
    int? shelfIndex,
    Value<String?> label = const Value.absent(),
    bool? filled,
  }) => Shelf(
    id: id ?? this.id,
    cabinetId: cabinetId ?? this.cabinetId,
    shelfIndex: shelfIndex ?? this.shelfIndex,
    label: label.present ? label.value : this.label,
    filled: filled ?? this.filled,
  );
  Shelf copyWithCompanion(ShelvesCompanion data) {
    return Shelf(
      id: data.id.present ? data.id.value : this.id,
      cabinetId: data.cabinetId.present ? data.cabinetId.value : this.cabinetId,
      shelfIndex: data.shelfIndex.present
          ? data.shelfIndex.value
          : this.shelfIndex,
      label: data.label.present ? data.label.value : this.label,
      filled: data.filled.present ? data.filled.value : this.filled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Shelf(')
          ..write('id: $id, ')
          ..write('cabinetId: $cabinetId, ')
          ..write('shelfIndex: $shelfIndex, ')
          ..write('label: $label, ')
          ..write('filled: $filled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, cabinetId, shelfIndex, label, filled);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Shelf &&
          other.id == this.id &&
          other.cabinetId == this.cabinetId &&
          other.shelfIndex == this.shelfIndex &&
          other.label == this.label &&
          other.filled == this.filled);
}

class ShelvesCompanion extends UpdateCompanion<Shelf> {
  final Value<int> id;
  final Value<int> cabinetId;
  final Value<int> shelfIndex;
  final Value<String?> label;
  final Value<bool> filled;
  const ShelvesCompanion({
    this.id = const Value.absent(),
    this.cabinetId = const Value.absent(),
    this.shelfIndex = const Value.absent(),
    this.label = const Value.absent(),
    this.filled = const Value.absent(),
  });
  ShelvesCompanion.insert({
    this.id = const Value.absent(),
    required int cabinetId,
    required int shelfIndex,
    this.label = const Value.absent(),
    this.filled = const Value.absent(),
  }) : cabinetId = Value(cabinetId),
       shelfIndex = Value(shelfIndex);
  static Insertable<Shelf> custom({
    Expression<int>? id,
    Expression<int>? cabinetId,
    Expression<int>? shelfIndex,
    Expression<String>? label,
    Expression<bool>? filled,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cabinetId != null) 'cabinet_id': cabinetId,
      if (shelfIndex != null) 'shelf_index': shelfIndex,
      if (label != null) 'label': label,
      if (filled != null) 'filled': filled,
    });
  }

  ShelvesCompanion copyWith({
    Value<int>? id,
    Value<int>? cabinetId,
    Value<int>? shelfIndex,
    Value<String?>? label,
    Value<bool>? filled,
  }) {
    return ShelvesCompanion(
      id: id ?? this.id,
      cabinetId: cabinetId ?? this.cabinetId,
      shelfIndex: shelfIndex ?? this.shelfIndex,
      label: label ?? this.label,
      filled: filled ?? this.filled,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cabinetId.present) {
      map['cabinet_id'] = Variable<int>(cabinetId.value);
    }
    if (shelfIndex.present) {
      map['shelf_index'] = Variable<int>(shelfIndex.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (filled.present) {
      map['filled'] = Variable<bool>(filled.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShelvesCompanion(')
          ..write('id: $id, ')
          ..write('cabinetId: $cabinetId, ')
          ..write('shelfIndex: $shelfIndex, ')
          ..write('label: $label, ')
          ..write('filled: $filled')
          ..write(')'))
        .toString();
  }
}

class $ShelfRowsTable extends ShelfRows
    with TableInfo<$ShelfRowsTable, ShelfRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShelfRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _shelfIdMeta = const VerificationMeta(
    'shelfId',
  );
  @override
  late final GeneratedColumn<int> shelfId = GeneratedColumn<int>(
    'shelf_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES shelves (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _rowIndexMeta = const VerificationMeta(
    'rowIndex',
  );
  @override
  late final GeneratedColumn<int> rowIndex = GeneratedColumn<int>(
    'row_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _capacityMeta = const VerificationMeta(
    'capacity',
  );
  @override
  late final GeneratedColumn<int> capacity = GeneratedColumn<int>(
    'capacity',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shelfId,
    rowIndex,
    label,
    capacity,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shelf_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShelfRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('shelf_id')) {
      context.handle(
        _shelfIdMeta,
        shelfId.isAcceptableOrUnknown(data['shelf_id']!, _shelfIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shelfIdMeta);
    }
    if (data.containsKey('row_index')) {
      context.handle(
        _rowIndexMeta,
        rowIndex.isAcceptableOrUnknown(data['row_index']!, _rowIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_rowIndexMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('capacity')) {
      context.handle(
        _capacityMeta,
        capacity.isAcceptableOrUnknown(data['capacity']!, _capacityMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShelfRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShelfRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      shelfId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}shelf_id'],
      )!,
      rowIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}row_index'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
      capacity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}capacity'],
      ),
    );
  }

  @override
  $ShelfRowsTable createAlias(String alias) {
    return $ShelfRowsTable(attachedDatabase, alias);
  }
}

class ShelfRow extends DataClass implements Insertable<ShelfRow> {
  final int id;
  final int shelfId;
  final int rowIndex;
  final String? label;
  final int? capacity;
  const ShelfRow({
    required this.id,
    required this.shelfId,
    required this.rowIndex,
    this.label,
    this.capacity,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['shelf_id'] = Variable<int>(shelfId);
    map['row_index'] = Variable<int>(rowIndex);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    if (!nullToAbsent || capacity != null) {
      map['capacity'] = Variable<int>(capacity);
    }
    return map;
  }

  ShelfRowsCompanion toCompanion(bool nullToAbsent) {
    return ShelfRowsCompanion(
      id: Value(id),
      shelfId: Value(shelfId),
      rowIndex: Value(rowIndex),
      label: label == null && nullToAbsent
          ? const Value.absent()
          : Value(label),
      capacity: capacity == null && nullToAbsent
          ? const Value.absent()
          : Value(capacity),
    );
  }

  factory ShelfRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShelfRow(
      id: serializer.fromJson<int>(json['id']),
      shelfId: serializer.fromJson<int>(json['shelfId']),
      rowIndex: serializer.fromJson<int>(json['rowIndex']),
      label: serializer.fromJson<String?>(json['label']),
      capacity: serializer.fromJson<int?>(json['capacity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'shelfId': serializer.toJson<int>(shelfId),
      'rowIndex': serializer.toJson<int>(rowIndex),
      'label': serializer.toJson<String?>(label),
      'capacity': serializer.toJson<int?>(capacity),
    };
  }

  ShelfRow copyWith({
    int? id,
    int? shelfId,
    int? rowIndex,
    Value<String?> label = const Value.absent(),
    Value<int?> capacity = const Value.absent(),
  }) => ShelfRow(
    id: id ?? this.id,
    shelfId: shelfId ?? this.shelfId,
    rowIndex: rowIndex ?? this.rowIndex,
    label: label.present ? label.value : this.label,
    capacity: capacity.present ? capacity.value : this.capacity,
  );
  ShelfRow copyWithCompanion(ShelfRowsCompanion data) {
    return ShelfRow(
      id: data.id.present ? data.id.value : this.id,
      shelfId: data.shelfId.present ? data.shelfId.value : this.shelfId,
      rowIndex: data.rowIndex.present ? data.rowIndex.value : this.rowIndex,
      label: data.label.present ? data.label.value : this.label,
      capacity: data.capacity.present ? data.capacity.value : this.capacity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShelfRow(')
          ..write('id: $id, ')
          ..write('shelfId: $shelfId, ')
          ..write('rowIndex: $rowIndex, ')
          ..write('label: $label, ')
          ..write('capacity: $capacity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, shelfId, rowIndex, label, capacity);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShelfRow &&
          other.id == this.id &&
          other.shelfId == this.shelfId &&
          other.rowIndex == this.rowIndex &&
          other.label == this.label &&
          other.capacity == this.capacity);
}

class ShelfRowsCompanion extends UpdateCompanion<ShelfRow> {
  final Value<int> id;
  final Value<int> shelfId;
  final Value<int> rowIndex;
  final Value<String?> label;
  final Value<int?> capacity;
  const ShelfRowsCompanion({
    this.id = const Value.absent(),
    this.shelfId = const Value.absent(),
    this.rowIndex = const Value.absent(),
    this.label = const Value.absent(),
    this.capacity = const Value.absent(),
  });
  ShelfRowsCompanion.insert({
    this.id = const Value.absent(),
    required int shelfId,
    required int rowIndex,
    this.label = const Value.absent(),
    this.capacity = const Value.absent(),
  }) : shelfId = Value(shelfId),
       rowIndex = Value(rowIndex);
  static Insertable<ShelfRow> custom({
    Expression<int>? id,
    Expression<int>? shelfId,
    Expression<int>? rowIndex,
    Expression<String>? label,
    Expression<int>? capacity,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shelfId != null) 'shelf_id': shelfId,
      if (rowIndex != null) 'row_index': rowIndex,
      if (label != null) 'label': label,
      if (capacity != null) 'capacity': capacity,
    });
  }

  ShelfRowsCompanion copyWith({
    Value<int>? id,
    Value<int>? shelfId,
    Value<int>? rowIndex,
    Value<String?>? label,
    Value<int?>? capacity,
  }) {
    return ShelfRowsCompanion(
      id: id ?? this.id,
      shelfId: shelfId ?? this.shelfId,
      rowIndex: rowIndex ?? this.rowIndex,
      label: label ?? this.label,
      capacity: capacity ?? this.capacity,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (shelfId.present) {
      map['shelf_id'] = Variable<int>(shelfId.value);
    }
    if (rowIndex.present) {
      map['row_index'] = Variable<int>(rowIndex.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (capacity.present) {
      map['capacity'] = Variable<int>(capacity.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShelfRowsCompanion(')
          ..write('id: $id, ')
          ..write('shelfId: $shelfId, ')
          ..write('rowIndex: $rowIndex, ')
          ..write('label: $label, ')
          ..write('capacity: $capacity')
          ..write(')'))
        .toString();
  }
}

class $BooksTable extends Books with TableInfo<$BooksTable, Book> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subtitleMeta = const VerificationMeta(
    'subtitle',
  );
  @override
  late final GeneratedColumn<String> subtitle = GeneratedColumn<String>(
    'subtitle',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _personalNoteMeta = const VerificationMeta(
    'personalNote',
  );
  @override
  late final GeneratedColumn<String> personalNote = GeneratedColumn<String>(
    'personal_note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isbnMeta = const VerificationMeta('isbn');
  @override
  late final GeneratedColumn<String> isbn = GeneratedColumn<String>(
    'isbn',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverPathMeta = const VerificationMeta(
    'coverPath',
  );
  @override
  late final GeneratedColumn<String> coverPath = GeneratedColumn<String>(
    'cover_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceUrlMeta = const VerificationMeta(
    'sourceUrl',
  );
  @override
  late final GeneratedColumn<String> sourceUrl = GeneratedColumn<String>(
    'source_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _shelfIdMeta = const VerificationMeta(
    'shelfId',
  );
  @override
  late final GeneratedColumn<int> shelfId = GeneratedColumn<int>(
    'shelf_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES shelves (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _rowIdMeta = const VerificationMeta('rowId');
  @override
  late final GeneratedColumn<int> rowId = GeneratedColumn<int>(
    'row_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES shelf_rows (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _positionIndexMeta = const VerificationMeta(
    'positionIndex',
  );
  @override
  late final GeneratedColumn<int> positionIndex = GeneratedColumn<int>(
    'position_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _readingStatusMeta = const VerificationMeta(
    'readingStatus',
  );
  @override
  late final GeneratedColumn<String> readingStatus = GeneratedColumn<String>(
    'reading_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('wantToRead'),
  );
  static const VerificationMeta _statusChangedAtMeta = const VerificationMeta(
    'statusChangedAt',
  );
  @override
  late final GeneratedColumn<DateTime> statusChangedAt =
      GeneratedColumn<DateTime>(
        'status_changed_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _seriesNameMeta = const VerificationMeta(
    'seriesName',
  );
  @override
  late final GeneratedColumn<String> seriesName = GeneratedColumn<String>(
    'series_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _seriesVolumeMeta = const VerificationMeta(
    'seriesVolume',
  );
  @override
  late final GeneratedColumn<int> seriesVolume = GeneratedColumn<int>(
    'series_volume',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _loanPersonMeta = const VerificationMeta(
    'loanPerson',
  );
  @override
  late final GeneratedColumn<String> loanPerson = GeneratedColumn<String>(
    'loan_person',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _loanDueAtMeta = const VerificationMeta(
    'loanDueAt',
  );
  @override
  late final GeneratedColumn<DateTime> loanDueAt = GeneratedColumn<DateTime>(
    'loan_due_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _bookFormatMeta = const VerificationMeta(
    'bookFormat',
  );
  @override
  late final GeneratedColumn<String> bookFormat = GeneratedColumn<String>(
    'book_format',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('print'),
  );
  static const VerificationMeta _placementMeta = const VerificationMeta(
    'placement',
  );
  @override
  late final GeneratedColumn<String> placement = GeneratedColumn<String>(
    'placement',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('shelf'),
  );
  static const VerificationMeta _yandexIdMeta = const VerificationMeta(
    'yandexId',
  );
  @override
  late final GeneratedColumn<String> yandexId = GeneratedColumn<String>(
    'yandex_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _narratorMeta = const VerificationMeta(
    'narrator',
  );
  @override
  late final GeneratedColumn<String> narrator = GeneratedColumn<String>(
    'narrator',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _libraryDueAtMeta = const VerificationMeta(
    'libraryDueAt',
  );
  @override
  late final GeneratedColumn<DateTime> libraryDueAt = GeneratedColumn<DateTime>(
    'library_due_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _readerRatingMeta = const VerificationMeta(
    'readerRating',
  );
  @override
  late final GeneratedColumn<int> readerRating = GeneratedColumn<int>(
    'reader_rating',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reminderSentForDueMeta =
      const VerificationMeta('reminderSentForDue');
  @override
  late final GeneratedColumn<DateTime> reminderSentForDue =
      GeneratedColumn<DateTime>(
        'reminder_sent_for_due',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    subtitle,
    description,
    personalNote,
    isbn,
    coverPath,
    sourceUrl,
    shelfId,
    rowId,
    positionIndex,
    readingStatus,
    statusChangedAt,
    seriesName,
    seriesVolume,
    loanPerson,
    loanDueAt,
    createdAt,
    bookFormat,
    placement,
    yandexId,
    narrator,
    durationSeconds,
    libraryDueAt,
    readerRating,
    reminderSentForDue,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'books';
  @override
  VerificationContext validateIntegrity(
    Insertable<Book> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('subtitle')) {
      context.handle(
        _subtitleMeta,
        subtitle.isAcceptableOrUnknown(data['subtitle']!, _subtitleMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('personal_note')) {
      context.handle(
        _personalNoteMeta,
        personalNote.isAcceptableOrUnknown(
          data['personal_note']!,
          _personalNoteMeta,
        ),
      );
    }
    if (data.containsKey('isbn')) {
      context.handle(
        _isbnMeta,
        isbn.isAcceptableOrUnknown(data['isbn']!, _isbnMeta),
      );
    }
    if (data.containsKey('cover_path')) {
      context.handle(
        _coverPathMeta,
        coverPath.isAcceptableOrUnknown(data['cover_path']!, _coverPathMeta),
      );
    }
    if (data.containsKey('source_url')) {
      context.handle(
        _sourceUrlMeta,
        sourceUrl.isAcceptableOrUnknown(data['source_url']!, _sourceUrlMeta),
      );
    }
    if (data.containsKey('shelf_id')) {
      context.handle(
        _shelfIdMeta,
        shelfId.isAcceptableOrUnknown(data['shelf_id']!, _shelfIdMeta),
      );
    }
    if (data.containsKey('row_id')) {
      context.handle(
        _rowIdMeta,
        rowId.isAcceptableOrUnknown(data['row_id']!, _rowIdMeta),
      );
    }
    if (data.containsKey('position_index')) {
      context.handle(
        _positionIndexMeta,
        positionIndex.isAcceptableOrUnknown(
          data['position_index']!,
          _positionIndexMeta,
        ),
      );
    }
    if (data.containsKey('reading_status')) {
      context.handle(
        _readingStatusMeta,
        readingStatus.isAcceptableOrUnknown(
          data['reading_status']!,
          _readingStatusMeta,
        ),
      );
    }
    if (data.containsKey('status_changed_at')) {
      context.handle(
        _statusChangedAtMeta,
        statusChangedAt.isAcceptableOrUnknown(
          data['status_changed_at']!,
          _statusChangedAtMeta,
        ),
      );
    }
    if (data.containsKey('series_name')) {
      context.handle(
        _seriesNameMeta,
        seriesName.isAcceptableOrUnknown(data['series_name']!, _seriesNameMeta),
      );
    }
    if (data.containsKey('series_volume')) {
      context.handle(
        _seriesVolumeMeta,
        seriesVolume.isAcceptableOrUnknown(
          data['series_volume']!,
          _seriesVolumeMeta,
        ),
      );
    }
    if (data.containsKey('loan_person')) {
      context.handle(
        _loanPersonMeta,
        loanPerson.isAcceptableOrUnknown(data['loan_person']!, _loanPersonMeta),
      );
    }
    if (data.containsKey('loan_due_at')) {
      context.handle(
        _loanDueAtMeta,
        loanDueAt.isAcceptableOrUnknown(data['loan_due_at']!, _loanDueAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('book_format')) {
      context.handle(
        _bookFormatMeta,
        bookFormat.isAcceptableOrUnknown(data['book_format']!, _bookFormatMeta),
      );
    }
    if (data.containsKey('placement')) {
      context.handle(
        _placementMeta,
        placement.isAcceptableOrUnknown(data['placement']!, _placementMeta),
      );
    }
    if (data.containsKey('yandex_id')) {
      context.handle(
        _yandexIdMeta,
        yandexId.isAcceptableOrUnknown(data['yandex_id']!, _yandexIdMeta),
      );
    }
    if (data.containsKey('narrator')) {
      context.handle(
        _narratorMeta,
        narrator.isAcceptableOrUnknown(data['narrator']!, _narratorMeta),
      );
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('library_due_at')) {
      context.handle(
        _libraryDueAtMeta,
        libraryDueAt.isAcceptableOrUnknown(
          data['library_due_at']!,
          _libraryDueAtMeta,
        ),
      );
    }
    if (data.containsKey('reader_rating')) {
      context.handle(
        _readerRatingMeta,
        readerRating.isAcceptableOrUnknown(
          data['reader_rating']!,
          _readerRatingMeta,
        ),
      );
    }
    if (data.containsKey('reminder_sent_for_due')) {
      context.handle(
        _reminderSentForDueMeta,
        reminderSentForDue.isAcceptableOrUnknown(
          data['reminder_sent_for_due']!,
          _reminderSentForDueMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Book map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Book(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      subtitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subtitle'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      personalNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}personal_note'],
      )!,
      isbn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}isbn'],
      ),
      coverPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_path'],
      ),
      sourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_url'],
      ),
      shelfId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}shelf_id'],
      ),
      rowId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}row_id'],
      ),
      positionIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position_index'],
      )!,
      readingStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reading_status'],
      )!,
      statusChangedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}status_changed_at'],
      )!,
      seriesName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}series_name'],
      ),
      seriesVolume: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}series_volume'],
      ),
      loanPerson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}loan_person'],
      ),
      loanDueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}loan_due_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      bookFormat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_format'],
      )!,
      placement: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}placement'],
      )!,
      yandexId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}yandex_id'],
      ),
      narrator: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}narrator'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      ),
      libraryDueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}library_due_at'],
      ),
      readerRating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reader_rating'],
      ),
      reminderSentForDue: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}reminder_sent_for_due'],
      ),
    );
  }

  @override
  $BooksTable createAlias(String alias) {
    return $BooksTable(attachedDatabase, alias);
  }
}

class Book extends DataClass implements Insertable<Book> {
  final int id;
  final String title;
  final String subtitle;
  final String description;
  final String personalNote;
  final String? isbn;
  final String? coverPath;
  final String? sourceUrl;
  final int? shelfId;
  final int? rowId;
  final int positionIndex;
  final String readingStatus;
  final DateTime statusChangedAt;
  final String? seriesName;
  final int? seriesVolume;
  final String? loanPerson;
  final DateTime? loanDueAt;
  final DateTime createdAt;
  final String bookFormat;
  final String placement;
  final String? yandexId;
  final String narrator;
  final int? durationSeconds;
  final DateTime? libraryDueAt;
  final int? readerRating;
  final DateTime? reminderSentForDue;
  const Book({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.personalNote,
    this.isbn,
    this.coverPath,
    this.sourceUrl,
    this.shelfId,
    this.rowId,
    required this.positionIndex,
    required this.readingStatus,
    required this.statusChangedAt,
    this.seriesName,
    this.seriesVolume,
    this.loanPerson,
    this.loanDueAt,
    required this.createdAt,
    required this.bookFormat,
    required this.placement,
    this.yandexId,
    required this.narrator,
    this.durationSeconds,
    this.libraryDueAt,
    this.readerRating,
    this.reminderSentForDue,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['subtitle'] = Variable<String>(subtitle);
    map['description'] = Variable<String>(description);
    map['personal_note'] = Variable<String>(personalNote);
    if (!nullToAbsent || isbn != null) {
      map['isbn'] = Variable<String>(isbn);
    }
    if (!nullToAbsent || coverPath != null) {
      map['cover_path'] = Variable<String>(coverPath);
    }
    if (!nullToAbsent || sourceUrl != null) {
      map['source_url'] = Variable<String>(sourceUrl);
    }
    if (!nullToAbsent || shelfId != null) {
      map['shelf_id'] = Variable<int>(shelfId);
    }
    if (!nullToAbsent || rowId != null) {
      map['row_id'] = Variable<int>(rowId);
    }
    map['position_index'] = Variable<int>(positionIndex);
    map['reading_status'] = Variable<String>(readingStatus);
    map['status_changed_at'] = Variable<DateTime>(statusChangedAt);
    if (!nullToAbsent || seriesName != null) {
      map['series_name'] = Variable<String>(seriesName);
    }
    if (!nullToAbsent || seriesVolume != null) {
      map['series_volume'] = Variable<int>(seriesVolume);
    }
    if (!nullToAbsent || loanPerson != null) {
      map['loan_person'] = Variable<String>(loanPerson);
    }
    if (!nullToAbsent || loanDueAt != null) {
      map['loan_due_at'] = Variable<DateTime>(loanDueAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['book_format'] = Variable<String>(bookFormat);
    map['placement'] = Variable<String>(placement);
    if (!nullToAbsent || yandexId != null) {
      map['yandex_id'] = Variable<String>(yandexId);
    }
    map['narrator'] = Variable<String>(narrator);
    if (!nullToAbsent || durationSeconds != null) {
      map['duration_seconds'] = Variable<int>(durationSeconds);
    }
    if (!nullToAbsent || libraryDueAt != null) {
      map['library_due_at'] = Variable<DateTime>(libraryDueAt);
    }
    if (!nullToAbsent || readerRating != null) {
      map['reader_rating'] = Variable<int>(readerRating);
    }
    if (!nullToAbsent || reminderSentForDue != null) {
      map['reminder_sent_for_due'] = Variable<DateTime>(reminderSentForDue);
    }
    return map;
  }

  BooksCompanion toCompanion(bool nullToAbsent) {
    return BooksCompanion(
      id: Value(id),
      title: Value(title),
      subtitle: Value(subtitle),
      description: Value(description),
      personalNote: Value(personalNote),
      isbn: isbn == null && nullToAbsent ? const Value.absent() : Value(isbn),
      coverPath: coverPath == null && nullToAbsent
          ? const Value.absent()
          : Value(coverPath),
      sourceUrl: sourceUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceUrl),
      shelfId: shelfId == null && nullToAbsent
          ? const Value.absent()
          : Value(shelfId),
      rowId: rowId == null && nullToAbsent
          ? const Value.absent()
          : Value(rowId),
      positionIndex: Value(positionIndex),
      readingStatus: Value(readingStatus),
      statusChangedAt: Value(statusChangedAt),
      seriesName: seriesName == null && nullToAbsent
          ? const Value.absent()
          : Value(seriesName),
      seriesVolume: seriesVolume == null && nullToAbsent
          ? const Value.absent()
          : Value(seriesVolume),
      loanPerson: loanPerson == null && nullToAbsent
          ? const Value.absent()
          : Value(loanPerson),
      loanDueAt: loanDueAt == null && nullToAbsent
          ? const Value.absent()
          : Value(loanDueAt),
      createdAt: Value(createdAt),
      bookFormat: Value(bookFormat),
      placement: Value(placement),
      yandexId: yandexId == null && nullToAbsent
          ? const Value.absent()
          : Value(yandexId),
      narrator: Value(narrator),
      durationSeconds: durationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(durationSeconds),
      libraryDueAt: libraryDueAt == null && nullToAbsent
          ? const Value.absent()
          : Value(libraryDueAt),
      readerRating: readerRating == null && nullToAbsent
          ? const Value.absent()
          : Value(readerRating),
      reminderSentForDue: reminderSentForDue == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderSentForDue),
    );
  }

  factory Book.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Book(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      subtitle: serializer.fromJson<String>(json['subtitle']),
      description: serializer.fromJson<String>(json['description']),
      personalNote: serializer.fromJson<String>(json['personalNote']),
      isbn: serializer.fromJson<String?>(json['isbn']),
      coverPath: serializer.fromJson<String?>(json['coverPath']),
      sourceUrl: serializer.fromJson<String?>(json['sourceUrl']),
      shelfId: serializer.fromJson<int?>(json['shelfId']),
      rowId: serializer.fromJson<int?>(json['rowId']),
      positionIndex: serializer.fromJson<int>(json['positionIndex']),
      readingStatus: serializer.fromJson<String>(json['readingStatus']),
      statusChangedAt: serializer.fromJson<DateTime>(json['statusChangedAt']),
      seriesName: serializer.fromJson<String?>(json['seriesName']),
      seriesVolume: serializer.fromJson<int?>(json['seriesVolume']),
      loanPerson: serializer.fromJson<String?>(json['loanPerson']),
      loanDueAt: serializer.fromJson<DateTime?>(json['loanDueAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      bookFormat: serializer.fromJson<String>(json['bookFormat']),
      placement: serializer.fromJson<String>(json['placement']),
      yandexId: serializer.fromJson<String?>(json['yandexId']),
      narrator: serializer.fromJson<String>(json['narrator']),
      durationSeconds: serializer.fromJson<int?>(json['durationSeconds']),
      libraryDueAt: serializer.fromJson<DateTime?>(json['libraryDueAt']),
      readerRating: serializer.fromJson<int?>(json['readerRating']),
      reminderSentForDue: serializer.fromJson<DateTime?>(
        json['reminderSentForDue'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'subtitle': serializer.toJson<String>(subtitle),
      'description': serializer.toJson<String>(description),
      'personalNote': serializer.toJson<String>(personalNote),
      'isbn': serializer.toJson<String?>(isbn),
      'coverPath': serializer.toJson<String?>(coverPath),
      'sourceUrl': serializer.toJson<String?>(sourceUrl),
      'shelfId': serializer.toJson<int?>(shelfId),
      'rowId': serializer.toJson<int?>(rowId),
      'positionIndex': serializer.toJson<int>(positionIndex),
      'readingStatus': serializer.toJson<String>(readingStatus),
      'statusChangedAt': serializer.toJson<DateTime>(statusChangedAt),
      'seriesName': serializer.toJson<String?>(seriesName),
      'seriesVolume': serializer.toJson<int?>(seriesVolume),
      'loanPerson': serializer.toJson<String?>(loanPerson),
      'loanDueAt': serializer.toJson<DateTime?>(loanDueAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'bookFormat': serializer.toJson<String>(bookFormat),
      'placement': serializer.toJson<String>(placement),
      'yandexId': serializer.toJson<String?>(yandexId),
      'narrator': serializer.toJson<String>(narrator),
      'durationSeconds': serializer.toJson<int?>(durationSeconds),
      'libraryDueAt': serializer.toJson<DateTime?>(libraryDueAt),
      'readerRating': serializer.toJson<int?>(readerRating),
      'reminderSentForDue': serializer.toJson<DateTime?>(reminderSentForDue),
    };
  }

  Book copyWith({
    int? id,
    String? title,
    String? subtitle,
    String? description,
    String? personalNote,
    Value<String?> isbn = const Value.absent(),
    Value<String?> coverPath = const Value.absent(),
    Value<String?> sourceUrl = const Value.absent(),
    Value<int?> shelfId = const Value.absent(),
    Value<int?> rowId = const Value.absent(),
    int? positionIndex,
    String? readingStatus,
    DateTime? statusChangedAt,
    Value<String?> seriesName = const Value.absent(),
    Value<int?> seriesVolume = const Value.absent(),
    Value<String?> loanPerson = const Value.absent(),
    Value<DateTime?> loanDueAt = const Value.absent(),
    DateTime? createdAt,
    String? bookFormat,
    String? placement,
    Value<String?> yandexId = const Value.absent(),
    String? narrator,
    Value<int?> durationSeconds = const Value.absent(),
    Value<DateTime?> libraryDueAt = const Value.absent(),
    Value<int?> readerRating = const Value.absent(),
    Value<DateTime?> reminderSentForDue = const Value.absent(),
  }) => Book(
    id: id ?? this.id,
    title: title ?? this.title,
    subtitle: subtitle ?? this.subtitle,
    description: description ?? this.description,
    personalNote: personalNote ?? this.personalNote,
    isbn: isbn.present ? isbn.value : this.isbn,
    coverPath: coverPath.present ? coverPath.value : this.coverPath,
    sourceUrl: sourceUrl.present ? sourceUrl.value : this.sourceUrl,
    shelfId: shelfId.present ? shelfId.value : this.shelfId,
    rowId: rowId.present ? rowId.value : this.rowId,
    positionIndex: positionIndex ?? this.positionIndex,
    readingStatus: readingStatus ?? this.readingStatus,
    statusChangedAt: statusChangedAt ?? this.statusChangedAt,
    seriesName: seriesName.present ? seriesName.value : this.seriesName,
    seriesVolume: seriesVolume.present ? seriesVolume.value : this.seriesVolume,
    loanPerson: loanPerson.present ? loanPerson.value : this.loanPerson,
    loanDueAt: loanDueAt.present ? loanDueAt.value : this.loanDueAt,
    createdAt: createdAt ?? this.createdAt,
    bookFormat: bookFormat ?? this.bookFormat,
    placement: placement ?? this.placement,
    yandexId: yandexId.present ? yandexId.value : this.yandexId,
    narrator: narrator ?? this.narrator,
    durationSeconds: durationSeconds.present
        ? durationSeconds.value
        : this.durationSeconds,
    libraryDueAt: libraryDueAt.present ? libraryDueAt.value : this.libraryDueAt,
    readerRating: readerRating.present ? readerRating.value : this.readerRating,
    reminderSentForDue: reminderSentForDue.present
        ? reminderSentForDue.value
        : this.reminderSentForDue,
  );
  Book copyWithCompanion(BooksCompanion data) {
    return Book(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      subtitle: data.subtitle.present ? data.subtitle.value : this.subtitle,
      description: data.description.present
          ? data.description.value
          : this.description,
      personalNote: data.personalNote.present
          ? data.personalNote.value
          : this.personalNote,
      isbn: data.isbn.present ? data.isbn.value : this.isbn,
      coverPath: data.coverPath.present ? data.coverPath.value : this.coverPath,
      sourceUrl: data.sourceUrl.present ? data.sourceUrl.value : this.sourceUrl,
      shelfId: data.shelfId.present ? data.shelfId.value : this.shelfId,
      rowId: data.rowId.present ? data.rowId.value : this.rowId,
      positionIndex: data.positionIndex.present
          ? data.positionIndex.value
          : this.positionIndex,
      readingStatus: data.readingStatus.present
          ? data.readingStatus.value
          : this.readingStatus,
      statusChangedAt: data.statusChangedAt.present
          ? data.statusChangedAt.value
          : this.statusChangedAt,
      seriesName: data.seriesName.present
          ? data.seriesName.value
          : this.seriesName,
      seriesVolume: data.seriesVolume.present
          ? data.seriesVolume.value
          : this.seriesVolume,
      loanPerson: data.loanPerson.present
          ? data.loanPerson.value
          : this.loanPerson,
      loanDueAt: data.loanDueAt.present ? data.loanDueAt.value : this.loanDueAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      bookFormat: data.bookFormat.present
          ? data.bookFormat.value
          : this.bookFormat,
      placement: data.placement.present ? data.placement.value : this.placement,
      yandexId: data.yandexId.present ? data.yandexId.value : this.yandexId,
      narrator: data.narrator.present ? data.narrator.value : this.narrator,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      libraryDueAt: data.libraryDueAt.present
          ? data.libraryDueAt.value
          : this.libraryDueAt,
      readerRating: data.readerRating.present
          ? data.readerRating.value
          : this.readerRating,
      reminderSentForDue: data.reminderSentForDue.present
          ? data.reminderSentForDue.value
          : this.reminderSentForDue,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Book(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle, ')
          ..write('description: $description, ')
          ..write('personalNote: $personalNote, ')
          ..write('isbn: $isbn, ')
          ..write('coverPath: $coverPath, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('shelfId: $shelfId, ')
          ..write('rowId: $rowId, ')
          ..write('positionIndex: $positionIndex, ')
          ..write('readingStatus: $readingStatus, ')
          ..write('statusChangedAt: $statusChangedAt, ')
          ..write('seriesName: $seriesName, ')
          ..write('seriesVolume: $seriesVolume, ')
          ..write('loanPerson: $loanPerson, ')
          ..write('loanDueAt: $loanDueAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('bookFormat: $bookFormat, ')
          ..write('placement: $placement, ')
          ..write('yandexId: $yandexId, ')
          ..write('narrator: $narrator, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('libraryDueAt: $libraryDueAt, ')
          ..write('readerRating: $readerRating, ')
          ..write('reminderSentForDue: $reminderSentForDue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    title,
    subtitle,
    description,
    personalNote,
    isbn,
    coverPath,
    sourceUrl,
    shelfId,
    rowId,
    positionIndex,
    readingStatus,
    statusChangedAt,
    seriesName,
    seriesVolume,
    loanPerson,
    loanDueAt,
    createdAt,
    bookFormat,
    placement,
    yandexId,
    narrator,
    durationSeconds,
    libraryDueAt,
    readerRating,
    reminderSentForDue,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Book &&
          other.id == this.id &&
          other.title == this.title &&
          other.subtitle == this.subtitle &&
          other.description == this.description &&
          other.personalNote == this.personalNote &&
          other.isbn == this.isbn &&
          other.coverPath == this.coverPath &&
          other.sourceUrl == this.sourceUrl &&
          other.shelfId == this.shelfId &&
          other.rowId == this.rowId &&
          other.positionIndex == this.positionIndex &&
          other.readingStatus == this.readingStatus &&
          other.statusChangedAt == this.statusChangedAt &&
          other.seriesName == this.seriesName &&
          other.seriesVolume == this.seriesVolume &&
          other.loanPerson == this.loanPerson &&
          other.loanDueAt == this.loanDueAt &&
          other.createdAt == this.createdAt &&
          other.bookFormat == this.bookFormat &&
          other.placement == this.placement &&
          other.yandexId == this.yandexId &&
          other.narrator == this.narrator &&
          other.durationSeconds == this.durationSeconds &&
          other.libraryDueAt == this.libraryDueAt &&
          other.readerRating == this.readerRating &&
          other.reminderSentForDue == this.reminderSentForDue);
}

class BooksCompanion extends UpdateCompanion<Book> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> subtitle;
  final Value<String> description;
  final Value<String> personalNote;
  final Value<String?> isbn;
  final Value<String?> coverPath;
  final Value<String?> sourceUrl;
  final Value<int?> shelfId;
  final Value<int?> rowId;
  final Value<int> positionIndex;
  final Value<String> readingStatus;
  final Value<DateTime> statusChangedAt;
  final Value<String?> seriesName;
  final Value<int?> seriesVolume;
  final Value<String?> loanPerson;
  final Value<DateTime?> loanDueAt;
  final Value<DateTime> createdAt;
  final Value<String> bookFormat;
  final Value<String> placement;
  final Value<String?> yandexId;
  final Value<String> narrator;
  final Value<int?> durationSeconds;
  final Value<DateTime?> libraryDueAt;
  final Value<int?> readerRating;
  final Value<DateTime?> reminderSentForDue;
  const BooksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.subtitle = const Value.absent(),
    this.description = const Value.absent(),
    this.personalNote = const Value.absent(),
    this.isbn = const Value.absent(),
    this.coverPath = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.shelfId = const Value.absent(),
    this.rowId = const Value.absent(),
    this.positionIndex = const Value.absent(),
    this.readingStatus = const Value.absent(),
    this.statusChangedAt = const Value.absent(),
    this.seriesName = const Value.absent(),
    this.seriesVolume = const Value.absent(),
    this.loanPerson = const Value.absent(),
    this.loanDueAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.bookFormat = const Value.absent(),
    this.placement = const Value.absent(),
    this.yandexId = const Value.absent(),
    this.narrator = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.libraryDueAt = const Value.absent(),
    this.readerRating = const Value.absent(),
    this.reminderSentForDue = const Value.absent(),
  });
  BooksCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.subtitle = const Value.absent(),
    this.description = const Value.absent(),
    this.personalNote = const Value.absent(),
    this.isbn = const Value.absent(),
    this.coverPath = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.shelfId = const Value.absent(),
    this.rowId = const Value.absent(),
    this.positionIndex = const Value.absent(),
    this.readingStatus = const Value.absent(),
    this.statusChangedAt = const Value.absent(),
    this.seriesName = const Value.absent(),
    this.seriesVolume = const Value.absent(),
    this.loanPerson = const Value.absent(),
    this.loanDueAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.bookFormat = const Value.absent(),
    this.placement = const Value.absent(),
    this.yandexId = const Value.absent(),
    this.narrator = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.libraryDueAt = const Value.absent(),
    this.readerRating = const Value.absent(),
    this.reminderSentForDue = const Value.absent(),
  }) : title = Value(title);
  static Insertable<Book> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? subtitle,
    Expression<String>? description,
    Expression<String>? personalNote,
    Expression<String>? isbn,
    Expression<String>? coverPath,
    Expression<String>? sourceUrl,
    Expression<int>? shelfId,
    Expression<int>? rowId,
    Expression<int>? positionIndex,
    Expression<String>? readingStatus,
    Expression<DateTime>? statusChangedAt,
    Expression<String>? seriesName,
    Expression<int>? seriesVolume,
    Expression<String>? loanPerson,
    Expression<DateTime>? loanDueAt,
    Expression<DateTime>? createdAt,
    Expression<String>? bookFormat,
    Expression<String>? placement,
    Expression<String>? yandexId,
    Expression<String>? narrator,
    Expression<int>? durationSeconds,
    Expression<DateTime>? libraryDueAt,
    Expression<int>? readerRating,
    Expression<DateTime>? reminderSentForDue,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (subtitle != null) 'subtitle': subtitle,
      if (description != null) 'description': description,
      if (personalNote != null) 'personal_note': personalNote,
      if (isbn != null) 'isbn': isbn,
      if (coverPath != null) 'cover_path': coverPath,
      if (sourceUrl != null) 'source_url': sourceUrl,
      if (shelfId != null) 'shelf_id': shelfId,
      if (rowId != null) 'row_id': rowId,
      if (positionIndex != null) 'position_index': positionIndex,
      if (readingStatus != null) 'reading_status': readingStatus,
      if (statusChangedAt != null) 'status_changed_at': statusChangedAt,
      if (seriesName != null) 'series_name': seriesName,
      if (seriesVolume != null) 'series_volume': seriesVolume,
      if (loanPerson != null) 'loan_person': loanPerson,
      if (loanDueAt != null) 'loan_due_at': loanDueAt,
      if (createdAt != null) 'created_at': createdAt,
      if (bookFormat != null) 'book_format': bookFormat,
      if (placement != null) 'placement': placement,
      if (yandexId != null) 'yandex_id': yandexId,
      if (narrator != null) 'narrator': narrator,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (libraryDueAt != null) 'library_due_at': libraryDueAt,
      if (readerRating != null) 'reader_rating': readerRating,
      if (reminderSentForDue != null)
        'reminder_sent_for_due': reminderSentForDue,
    });
  }

  BooksCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? subtitle,
    Value<String>? description,
    Value<String>? personalNote,
    Value<String?>? isbn,
    Value<String?>? coverPath,
    Value<String?>? sourceUrl,
    Value<int?>? shelfId,
    Value<int?>? rowId,
    Value<int>? positionIndex,
    Value<String>? readingStatus,
    Value<DateTime>? statusChangedAt,
    Value<String?>? seriesName,
    Value<int?>? seriesVolume,
    Value<String?>? loanPerson,
    Value<DateTime?>? loanDueAt,
    Value<DateTime>? createdAt,
    Value<String>? bookFormat,
    Value<String>? placement,
    Value<String?>? yandexId,
    Value<String>? narrator,
    Value<int?>? durationSeconds,
    Value<DateTime?>? libraryDueAt,
    Value<int?>? readerRating,
    Value<DateTime?>? reminderSentForDue,
  }) {
    return BooksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      personalNote: personalNote ?? this.personalNote,
      isbn: isbn ?? this.isbn,
      coverPath: coverPath ?? this.coverPath,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      shelfId: shelfId ?? this.shelfId,
      rowId: rowId ?? this.rowId,
      positionIndex: positionIndex ?? this.positionIndex,
      readingStatus: readingStatus ?? this.readingStatus,
      statusChangedAt: statusChangedAt ?? this.statusChangedAt,
      seriesName: seriesName ?? this.seriesName,
      seriesVolume: seriesVolume ?? this.seriesVolume,
      loanPerson: loanPerson ?? this.loanPerson,
      loanDueAt: loanDueAt ?? this.loanDueAt,
      createdAt: createdAt ?? this.createdAt,
      bookFormat: bookFormat ?? this.bookFormat,
      placement: placement ?? this.placement,
      yandexId: yandexId ?? this.yandexId,
      narrator: narrator ?? this.narrator,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      libraryDueAt: libraryDueAt ?? this.libraryDueAt,
      readerRating: readerRating ?? this.readerRating,
      reminderSentForDue: reminderSentForDue ?? this.reminderSentForDue,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (subtitle.present) {
      map['subtitle'] = Variable<String>(subtitle.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (personalNote.present) {
      map['personal_note'] = Variable<String>(personalNote.value);
    }
    if (isbn.present) {
      map['isbn'] = Variable<String>(isbn.value);
    }
    if (coverPath.present) {
      map['cover_path'] = Variable<String>(coverPath.value);
    }
    if (sourceUrl.present) {
      map['source_url'] = Variable<String>(sourceUrl.value);
    }
    if (shelfId.present) {
      map['shelf_id'] = Variable<int>(shelfId.value);
    }
    if (rowId.present) {
      map['row_id'] = Variable<int>(rowId.value);
    }
    if (positionIndex.present) {
      map['position_index'] = Variable<int>(positionIndex.value);
    }
    if (readingStatus.present) {
      map['reading_status'] = Variable<String>(readingStatus.value);
    }
    if (statusChangedAt.present) {
      map['status_changed_at'] = Variable<DateTime>(statusChangedAt.value);
    }
    if (seriesName.present) {
      map['series_name'] = Variable<String>(seriesName.value);
    }
    if (seriesVolume.present) {
      map['series_volume'] = Variable<int>(seriesVolume.value);
    }
    if (loanPerson.present) {
      map['loan_person'] = Variable<String>(loanPerson.value);
    }
    if (loanDueAt.present) {
      map['loan_due_at'] = Variable<DateTime>(loanDueAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (bookFormat.present) {
      map['book_format'] = Variable<String>(bookFormat.value);
    }
    if (placement.present) {
      map['placement'] = Variable<String>(placement.value);
    }
    if (yandexId.present) {
      map['yandex_id'] = Variable<String>(yandexId.value);
    }
    if (narrator.present) {
      map['narrator'] = Variable<String>(narrator.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (libraryDueAt.present) {
      map['library_due_at'] = Variable<DateTime>(libraryDueAt.value);
    }
    if (readerRating.present) {
      map['reader_rating'] = Variable<int>(readerRating.value);
    }
    if (reminderSentForDue.present) {
      map['reminder_sent_for_due'] = Variable<DateTime>(
        reminderSentForDue.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BooksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle, ')
          ..write('description: $description, ')
          ..write('personalNote: $personalNote, ')
          ..write('isbn: $isbn, ')
          ..write('coverPath: $coverPath, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('shelfId: $shelfId, ')
          ..write('rowId: $rowId, ')
          ..write('positionIndex: $positionIndex, ')
          ..write('readingStatus: $readingStatus, ')
          ..write('statusChangedAt: $statusChangedAt, ')
          ..write('seriesName: $seriesName, ')
          ..write('seriesVolume: $seriesVolume, ')
          ..write('loanPerson: $loanPerson, ')
          ..write('loanDueAt: $loanDueAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('bookFormat: $bookFormat, ')
          ..write('placement: $placement, ')
          ..write('yandexId: $yandexId, ')
          ..write('narrator: $narrator, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('libraryDueAt: $libraryDueAt, ')
          ..write('readerRating: $readerRating, ')
          ..write('reminderSentForDue: $reminderSentForDue')
          ..write(')'))
        .toString();
  }
}

class $BookPhotosTable extends BookPhotos
    with TableInfo<$BookPhotosTable, BookPhoto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookPhotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES books (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, bookId, path, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'book_photos';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookPhoto> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookPhoto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookPhoto(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_id'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $BookPhotosTable createAlias(String alias) {
    return $BookPhotosTable(attachedDatabase, alias);
  }
}

class BookPhoto extends DataClass implements Insertable<BookPhoto> {
  final int id;
  final int bookId;
  final String path;
  final int sortOrder;
  const BookPhoto({
    required this.id,
    required this.bookId,
    required this.path,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_id'] = Variable<int>(bookId);
    map['path'] = Variable<String>(path);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  BookPhotosCompanion toCompanion(bool nullToAbsent) {
    return BookPhotosCompanion(
      id: Value(id),
      bookId: Value(bookId),
      path: Value(path),
      sortOrder: Value(sortOrder),
    );
  }

  factory BookPhoto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookPhoto(
      id: serializer.fromJson<int>(json['id']),
      bookId: serializer.fromJson<int>(json['bookId']),
      path: serializer.fromJson<String>(json['path']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookId': serializer.toJson<int>(bookId),
      'path': serializer.toJson<String>(path),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  BookPhoto copyWith({int? id, int? bookId, String? path, int? sortOrder}) =>
      BookPhoto(
        id: id ?? this.id,
        bookId: bookId ?? this.bookId,
        path: path ?? this.path,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  BookPhoto copyWithCompanion(BookPhotosCompanion data) {
    return BookPhoto(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      path: data.path.present ? data.path.value : this.path,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookPhoto(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('path: $path, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, bookId, path, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookPhoto &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.path == this.path &&
          other.sortOrder == this.sortOrder);
}

class BookPhotosCompanion extends UpdateCompanion<BookPhoto> {
  final Value<int> id;
  final Value<int> bookId;
  final Value<String> path;
  final Value<int> sortOrder;
  const BookPhotosCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.path = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  BookPhotosCompanion.insert({
    this.id = const Value.absent(),
    required int bookId,
    required String path,
    this.sortOrder = const Value.absent(),
  }) : bookId = Value(bookId),
       path = Value(path);
  static Insertable<BookPhoto> custom({
    Expression<int>? id,
    Expression<int>? bookId,
    Expression<String>? path,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (path != null) 'path': path,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  BookPhotosCompanion copyWith({
    Value<int>? id,
    Value<int>? bookId,
    Value<String>? path,
    Value<int>? sortOrder,
  }) {
    return BookPhotosCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      path: path ?? this.path,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookPhotosCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('path: $path, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $AuthorsTable extends Authors with TableInfo<$AuthorsTable, Author> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuthorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameKeyMeta = const VerificationMeta(
    'nameKey',
  );
  @override
  late final GeneratedColumn<String> nameKey = GeneratedColumn<String>(
    'name_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, nameKey];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'authors';
  @override
  VerificationContext validateIntegrity(
    Insertable<Author> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('name_key')) {
      context.handle(
        _nameKeyMeta,
        nameKey.isAcceptableOrUnknown(data['name_key']!, _nameKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_nameKeyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Author map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Author(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      nameKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_key'],
      )!,
    );
  }

  @override
  $AuthorsTable createAlias(String alias) {
    return $AuthorsTable(attachedDatabase, alias);
  }
}

class Author extends DataClass implements Insertable<Author> {
  final int id;
  final String name;
  final String nameKey;
  const Author({required this.id, required this.name, required this.nameKey});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['name_key'] = Variable<String>(nameKey);
    return map;
  }

  AuthorsCompanion toCompanion(bool nullToAbsent) {
    return AuthorsCompanion(
      id: Value(id),
      name: Value(name),
      nameKey: Value(nameKey),
    );
  }

  factory Author.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Author(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      nameKey: serializer.fromJson<String>(json['nameKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'nameKey': serializer.toJson<String>(nameKey),
    };
  }

  Author copyWith({int? id, String? name, String? nameKey}) => Author(
    id: id ?? this.id,
    name: name ?? this.name,
    nameKey: nameKey ?? this.nameKey,
  );
  Author copyWithCompanion(AuthorsCompanion data) {
    return Author(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      nameKey: data.nameKey.present ? data.nameKey.value : this.nameKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Author(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameKey: $nameKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, nameKey);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Author &&
          other.id == this.id &&
          other.name == this.name &&
          other.nameKey == this.nameKey);
}

class AuthorsCompanion extends UpdateCompanion<Author> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> nameKey;
  const AuthorsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.nameKey = const Value.absent(),
  });
  AuthorsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String nameKey,
  }) : name = Value(name),
       nameKey = Value(nameKey);
  static Insertable<Author> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? nameKey,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (nameKey != null) 'name_key': nameKey,
    });
  }

  AuthorsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? nameKey,
  }) {
    return AuthorsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      nameKey: nameKey ?? this.nameKey,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nameKey.present) {
      map['name_key'] = Variable<String>(nameKey.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuthorsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameKey: $nameKey')
          ..write(')'))
        .toString();
  }
}

class $GenresTable extends Genres with TableInfo<$GenresTable, Genre> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GenresTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameKeyMeta = const VerificationMeta(
    'nameKey',
  );
  @override
  late final GeneratedColumn<String> nameKey = GeneratedColumn<String>(
    'name_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, nameKey];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'genres';
  @override
  VerificationContext validateIntegrity(
    Insertable<Genre> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('name_key')) {
      context.handle(
        _nameKeyMeta,
        nameKey.isAcceptableOrUnknown(data['name_key']!, _nameKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_nameKeyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Genre map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Genre(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      nameKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_key'],
      )!,
    );
  }

  @override
  $GenresTable createAlias(String alias) {
    return $GenresTable(attachedDatabase, alias);
  }
}

class Genre extends DataClass implements Insertable<Genre> {
  final int id;
  final String name;
  final String nameKey;
  const Genre({required this.id, required this.name, required this.nameKey});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['name_key'] = Variable<String>(nameKey);
    return map;
  }

  GenresCompanion toCompanion(bool nullToAbsent) {
    return GenresCompanion(
      id: Value(id),
      name: Value(name),
      nameKey: Value(nameKey),
    );
  }

  factory Genre.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Genre(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      nameKey: serializer.fromJson<String>(json['nameKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'nameKey': serializer.toJson<String>(nameKey),
    };
  }

  Genre copyWith({int? id, String? name, String? nameKey}) => Genre(
    id: id ?? this.id,
    name: name ?? this.name,
    nameKey: nameKey ?? this.nameKey,
  );
  Genre copyWithCompanion(GenresCompanion data) {
    return Genre(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      nameKey: data.nameKey.present ? data.nameKey.value : this.nameKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Genre(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameKey: $nameKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, nameKey);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Genre &&
          other.id == this.id &&
          other.name == this.name &&
          other.nameKey == this.nameKey);
}

class GenresCompanion extends UpdateCompanion<Genre> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> nameKey;
  const GenresCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.nameKey = const Value.absent(),
  });
  GenresCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String nameKey,
  }) : name = Value(name),
       nameKey = Value(nameKey);
  static Insertable<Genre> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? nameKey,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (nameKey != null) 'name_key': nameKey,
    });
  }

  GenresCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? nameKey,
  }) {
    return GenresCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      nameKey: nameKey ?? this.nameKey,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nameKey.present) {
      map['name_key'] = Variable<String>(nameKey.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GenresCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameKey: $nameKey')
          ..write(')'))
        .toString();
  }
}

class $PublishersTable extends Publishers
    with TableInfo<$PublishersTable, Publisher> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PublishersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameKeyMeta = const VerificationMeta(
    'nameKey',
  );
  @override
  late final GeneratedColumn<String> nameKey = GeneratedColumn<String>(
    'name_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, nameKey];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'publishers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Publisher> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('name_key')) {
      context.handle(
        _nameKeyMeta,
        nameKey.isAcceptableOrUnknown(data['name_key']!, _nameKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_nameKeyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Publisher map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Publisher(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      nameKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_key'],
      )!,
    );
  }

  @override
  $PublishersTable createAlias(String alias) {
    return $PublishersTable(attachedDatabase, alias);
  }
}

class Publisher extends DataClass implements Insertable<Publisher> {
  final int id;
  final String name;
  final String nameKey;
  const Publisher({
    required this.id,
    required this.name,
    required this.nameKey,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['name_key'] = Variable<String>(nameKey);
    return map;
  }

  PublishersCompanion toCompanion(bool nullToAbsent) {
    return PublishersCompanion(
      id: Value(id),
      name: Value(name),
      nameKey: Value(nameKey),
    );
  }

  factory Publisher.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Publisher(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      nameKey: serializer.fromJson<String>(json['nameKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'nameKey': serializer.toJson<String>(nameKey),
    };
  }

  Publisher copyWith({int? id, String? name, String? nameKey}) => Publisher(
    id: id ?? this.id,
    name: name ?? this.name,
    nameKey: nameKey ?? this.nameKey,
  );
  Publisher copyWithCompanion(PublishersCompanion data) {
    return Publisher(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      nameKey: data.nameKey.present ? data.nameKey.value : this.nameKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Publisher(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameKey: $nameKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, nameKey);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Publisher &&
          other.id == this.id &&
          other.name == this.name &&
          other.nameKey == this.nameKey);
}

class PublishersCompanion extends UpdateCompanion<Publisher> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> nameKey;
  const PublishersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.nameKey = const Value.absent(),
  });
  PublishersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String nameKey,
  }) : name = Value(name),
       nameKey = Value(nameKey);
  static Insertable<Publisher> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? nameKey,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (nameKey != null) 'name_key': nameKey,
    });
  }

  PublishersCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? nameKey,
  }) {
    return PublishersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      nameKey: nameKey ?? this.nameKey,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nameKey.present) {
      map['name_key'] = Variable<String>(nameKey.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PublishersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameKey: $nameKey')
          ..write(')'))
        .toString();
  }
}

class $HashtagsTable extends Hashtags with TableInfo<$HashtagsTable, Hashtag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HashtagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameKeyMeta = const VerificationMeta(
    'nameKey',
  );
  @override
  late final GeneratedColumn<String> nameKey = GeneratedColumn<String>(
    'name_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, nameKey, displayName];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hashtags';
  @override
  VerificationContext validateIntegrity(
    Insertable<Hashtag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name_key')) {
      context.handle(
        _nameKeyMeta,
        nameKey.isAcceptableOrUnknown(data['name_key']!, _nameKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_nameKeyMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Hashtag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Hashtag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nameKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_key'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
    );
  }

  @override
  $HashtagsTable createAlias(String alias) {
    return $HashtagsTable(attachedDatabase, alias);
  }
}

class Hashtag extends DataClass implements Insertable<Hashtag> {
  final int id;
  final String nameKey;
  final String displayName;
  const Hashtag({
    required this.id,
    required this.nameKey,
    required this.displayName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name_key'] = Variable<String>(nameKey);
    map['display_name'] = Variable<String>(displayName);
    return map;
  }

  HashtagsCompanion toCompanion(bool nullToAbsent) {
    return HashtagsCompanion(
      id: Value(id),
      nameKey: Value(nameKey),
      displayName: Value(displayName),
    );
  }

  factory Hashtag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Hashtag(
      id: serializer.fromJson<int>(json['id']),
      nameKey: serializer.fromJson<String>(json['nameKey']),
      displayName: serializer.fromJson<String>(json['displayName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nameKey': serializer.toJson<String>(nameKey),
      'displayName': serializer.toJson<String>(displayName),
    };
  }

  Hashtag copyWith({int? id, String? nameKey, String? displayName}) => Hashtag(
    id: id ?? this.id,
    nameKey: nameKey ?? this.nameKey,
    displayName: displayName ?? this.displayName,
  );
  Hashtag copyWithCompanion(HashtagsCompanion data) {
    return Hashtag(
      id: data.id.present ? data.id.value : this.id,
      nameKey: data.nameKey.present ? data.nameKey.value : this.nameKey,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Hashtag(')
          ..write('id: $id, ')
          ..write('nameKey: $nameKey, ')
          ..write('displayName: $displayName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nameKey, displayName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Hashtag &&
          other.id == this.id &&
          other.nameKey == this.nameKey &&
          other.displayName == this.displayName);
}

class HashtagsCompanion extends UpdateCompanion<Hashtag> {
  final Value<int> id;
  final Value<String> nameKey;
  final Value<String> displayName;
  const HashtagsCompanion({
    this.id = const Value.absent(),
    this.nameKey = const Value.absent(),
    this.displayName = const Value.absent(),
  });
  HashtagsCompanion.insert({
    this.id = const Value.absent(),
    required String nameKey,
    required String displayName,
  }) : nameKey = Value(nameKey),
       displayName = Value(displayName);
  static Insertable<Hashtag> custom({
    Expression<int>? id,
    Expression<String>? nameKey,
    Expression<String>? displayName,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nameKey != null) 'name_key': nameKey,
      if (displayName != null) 'display_name': displayName,
    });
  }

  HashtagsCompanion copyWith({
    Value<int>? id,
    Value<String>? nameKey,
    Value<String>? displayName,
  }) {
    return HashtagsCompanion(
      id: id ?? this.id,
      nameKey: nameKey ?? this.nameKey,
      displayName: displayName ?? this.displayName,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nameKey.present) {
      map['name_key'] = Variable<String>(nameKey.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HashtagsCompanion(')
          ..write('id: $id, ')
          ..write('nameKey: $nameKey, ')
          ..write('displayName: $displayName')
          ..write(')'))
        .toString();
  }
}

class $BookAuthorsTable extends BookAuthors
    with TableInfo<$BookAuthorsTable, BookAuthorLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookAuthorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES books (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _authorIdMeta = const VerificationMeta(
    'authorId',
  );
  @override
  late final GeneratedColumn<int> authorId = GeneratedColumn<int>(
    'author_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES authors (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [bookId, authorId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'book_authors';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookAuthorLink> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('author_id')) {
      context.handle(
        _authorIdMeta,
        authorId.isAcceptableOrUnknown(data['author_id']!, _authorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_authorIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bookId, authorId};
  @override
  BookAuthorLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookAuthorLink(
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_id'],
      )!,
      authorId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}author_id'],
      )!,
    );
  }

  @override
  $BookAuthorsTable createAlias(String alias) {
    return $BookAuthorsTable(attachedDatabase, alias);
  }
}

class BookAuthorLink extends DataClass implements Insertable<BookAuthorLink> {
  final int bookId;
  final int authorId;
  const BookAuthorLink({required this.bookId, required this.authorId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['book_id'] = Variable<int>(bookId);
    map['author_id'] = Variable<int>(authorId);
    return map;
  }

  BookAuthorsCompanion toCompanion(bool nullToAbsent) {
    return BookAuthorsCompanion(
      bookId: Value(bookId),
      authorId: Value(authorId),
    );
  }

  factory BookAuthorLink.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookAuthorLink(
      bookId: serializer.fromJson<int>(json['bookId']),
      authorId: serializer.fromJson<int>(json['authorId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bookId': serializer.toJson<int>(bookId),
      'authorId': serializer.toJson<int>(authorId),
    };
  }

  BookAuthorLink copyWith({int? bookId, int? authorId}) => BookAuthorLink(
    bookId: bookId ?? this.bookId,
    authorId: authorId ?? this.authorId,
  );
  BookAuthorLink copyWithCompanion(BookAuthorsCompanion data) {
    return BookAuthorLink(
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      authorId: data.authorId.present ? data.authorId.value : this.authorId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookAuthorLink(')
          ..write('bookId: $bookId, ')
          ..write('authorId: $authorId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(bookId, authorId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookAuthorLink &&
          other.bookId == this.bookId &&
          other.authorId == this.authorId);
}

class BookAuthorsCompanion extends UpdateCompanion<BookAuthorLink> {
  final Value<int> bookId;
  final Value<int> authorId;
  final Value<int> rowid;
  const BookAuthorsCompanion({
    this.bookId = const Value.absent(),
    this.authorId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookAuthorsCompanion.insert({
    required int bookId,
    required int authorId,
    this.rowid = const Value.absent(),
  }) : bookId = Value(bookId),
       authorId = Value(authorId);
  static Insertable<BookAuthorLink> custom({
    Expression<int>? bookId,
    Expression<int>? authorId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bookId != null) 'book_id': bookId,
      if (authorId != null) 'author_id': authorId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookAuthorsCompanion copyWith({
    Value<int>? bookId,
    Value<int>? authorId,
    Value<int>? rowid,
  }) {
    return BookAuthorsCompanion(
      bookId: bookId ?? this.bookId,
      authorId: authorId ?? this.authorId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (authorId.present) {
      map['author_id'] = Variable<int>(authorId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookAuthorsCompanion(')
          ..write('bookId: $bookId, ')
          ..write('authorId: $authorId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookGenresTable extends BookGenres
    with TableInfo<$BookGenresTable, BookGenreLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookGenresTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES books (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _genreIdMeta = const VerificationMeta(
    'genreId',
  );
  @override
  late final GeneratedColumn<int> genreId = GeneratedColumn<int>(
    'genre_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES genres (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [bookId, genreId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'book_genres';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookGenreLink> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('genre_id')) {
      context.handle(
        _genreIdMeta,
        genreId.isAcceptableOrUnknown(data['genre_id']!, _genreIdMeta),
      );
    } else if (isInserting) {
      context.missing(_genreIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bookId, genreId};
  @override
  BookGenreLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookGenreLink(
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_id'],
      )!,
      genreId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}genre_id'],
      )!,
    );
  }

  @override
  $BookGenresTable createAlias(String alias) {
    return $BookGenresTable(attachedDatabase, alias);
  }
}

class BookGenreLink extends DataClass implements Insertable<BookGenreLink> {
  final int bookId;
  final int genreId;
  const BookGenreLink({required this.bookId, required this.genreId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['book_id'] = Variable<int>(bookId);
    map['genre_id'] = Variable<int>(genreId);
    return map;
  }

  BookGenresCompanion toCompanion(bool nullToAbsent) {
    return BookGenresCompanion(bookId: Value(bookId), genreId: Value(genreId));
  }

  factory BookGenreLink.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookGenreLink(
      bookId: serializer.fromJson<int>(json['bookId']),
      genreId: serializer.fromJson<int>(json['genreId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bookId': serializer.toJson<int>(bookId),
      'genreId': serializer.toJson<int>(genreId),
    };
  }

  BookGenreLink copyWith({int? bookId, int? genreId}) => BookGenreLink(
    bookId: bookId ?? this.bookId,
    genreId: genreId ?? this.genreId,
  );
  BookGenreLink copyWithCompanion(BookGenresCompanion data) {
    return BookGenreLink(
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      genreId: data.genreId.present ? data.genreId.value : this.genreId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookGenreLink(')
          ..write('bookId: $bookId, ')
          ..write('genreId: $genreId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(bookId, genreId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookGenreLink &&
          other.bookId == this.bookId &&
          other.genreId == this.genreId);
}

class BookGenresCompanion extends UpdateCompanion<BookGenreLink> {
  final Value<int> bookId;
  final Value<int> genreId;
  final Value<int> rowid;
  const BookGenresCompanion({
    this.bookId = const Value.absent(),
    this.genreId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookGenresCompanion.insert({
    required int bookId,
    required int genreId,
    this.rowid = const Value.absent(),
  }) : bookId = Value(bookId),
       genreId = Value(genreId);
  static Insertable<BookGenreLink> custom({
    Expression<int>? bookId,
    Expression<int>? genreId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bookId != null) 'book_id': bookId,
      if (genreId != null) 'genre_id': genreId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookGenresCompanion copyWith({
    Value<int>? bookId,
    Value<int>? genreId,
    Value<int>? rowid,
  }) {
    return BookGenresCompanion(
      bookId: bookId ?? this.bookId,
      genreId: genreId ?? this.genreId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (genreId.present) {
      map['genre_id'] = Variable<int>(genreId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookGenresCompanion(')
          ..write('bookId: $bookId, ')
          ..write('genreId: $genreId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookPublishersTable extends BookPublishers
    with TableInfo<$BookPublishersTable, BookPublisherLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookPublishersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES books (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _publisherIdMeta = const VerificationMeta(
    'publisherId',
  );
  @override
  late final GeneratedColumn<int> publisherId = GeneratedColumn<int>(
    'publisher_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES publishers (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [bookId, publisherId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'book_publishers';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookPublisherLink> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('publisher_id')) {
      context.handle(
        _publisherIdMeta,
        publisherId.isAcceptableOrUnknown(
          data['publisher_id']!,
          _publisherIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_publisherIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bookId, publisherId};
  @override
  BookPublisherLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookPublisherLink(
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_id'],
      )!,
      publisherId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}publisher_id'],
      )!,
    );
  }

  @override
  $BookPublishersTable createAlias(String alias) {
    return $BookPublishersTable(attachedDatabase, alias);
  }
}

class BookPublisherLink extends DataClass
    implements Insertable<BookPublisherLink> {
  final int bookId;
  final int publisherId;
  const BookPublisherLink({required this.bookId, required this.publisherId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['book_id'] = Variable<int>(bookId);
    map['publisher_id'] = Variable<int>(publisherId);
    return map;
  }

  BookPublishersCompanion toCompanion(bool nullToAbsent) {
    return BookPublishersCompanion(
      bookId: Value(bookId),
      publisherId: Value(publisherId),
    );
  }

  factory BookPublisherLink.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookPublisherLink(
      bookId: serializer.fromJson<int>(json['bookId']),
      publisherId: serializer.fromJson<int>(json['publisherId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bookId': serializer.toJson<int>(bookId),
      'publisherId': serializer.toJson<int>(publisherId),
    };
  }

  BookPublisherLink copyWith({int? bookId, int? publisherId}) =>
      BookPublisherLink(
        bookId: bookId ?? this.bookId,
        publisherId: publisherId ?? this.publisherId,
      );
  BookPublisherLink copyWithCompanion(BookPublishersCompanion data) {
    return BookPublisherLink(
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      publisherId: data.publisherId.present
          ? data.publisherId.value
          : this.publisherId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookPublisherLink(')
          ..write('bookId: $bookId, ')
          ..write('publisherId: $publisherId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(bookId, publisherId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookPublisherLink &&
          other.bookId == this.bookId &&
          other.publisherId == this.publisherId);
}

class BookPublishersCompanion extends UpdateCompanion<BookPublisherLink> {
  final Value<int> bookId;
  final Value<int> publisherId;
  final Value<int> rowid;
  const BookPublishersCompanion({
    this.bookId = const Value.absent(),
    this.publisherId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookPublishersCompanion.insert({
    required int bookId,
    required int publisherId,
    this.rowid = const Value.absent(),
  }) : bookId = Value(bookId),
       publisherId = Value(publisherId);
  static Insertable<BookPublisherLink> custom({
    Expression<int>? bookId,
    Expression<int>? publisherId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bookId != null) 'book_id': bookId,
      if (publisherId != null) 'publisher_id': publisherId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookPublishersCompanion copyWith({
    Value<int>? bookId,
    Value<int>? publisherId,
    Value<int>? rowid,
  }) {
    return BookPublishersCompanion(
      bookId: bookId ?? this.bookId,
      publisherId: publisherId ?? this.publisherId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (publisherId.present) {
      map['publisher_id'] = Variable<int>(publisherId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookPublishersCompanion(')
          ..write('bookId: $bookId, ')
          ..write('publisherId: $publisherId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookHashtagsTable extends BookHashtags
    with TableInfo<$BookHashtagsTable, BookHashtagLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookHashtagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES books (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _hashtagIdMeta = const VerificationMeta(
    'hashtagId',
  );
  @override
  late final GeneratedColumn<int> hashtagId = GeneratedColumn<int>(
    'hashtag_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES hashtags (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [bookId, hashtagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'book_hashtags';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookHashtagLink> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('hashtag_id')) {
      context.handle(
        _hashtagIdMeta,
        hashtagId.isAcceptableOrUnknown(data['hashtag_id']!, _hashtagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_hashtagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bookId, hashtagId};
  @override
  BookHashtagLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookHashtagLink(
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_id'],
      )!,
      hashtagId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hashtag_id'],
      )!,
    );
  }

  @override
  $BookHashtagsTable createAlias(String alias) {
    return $BookHashtagsTable(attachedDatabase, alias);
  }
}

class BookHashtagLink extends DataClass implements Insertable<BookHashtagLink> {
  final int bookId;
  final int hashtagId;
  const BookHashtagLink({required this.bookId, required this.hashtagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['book_id'] = Variable<int>(bookId);
    map['hashtag_id'] = Variable<int>(hashtagId);
    return map;
  }

  BookHashtagsCompanion toCompanion(bool nullToAbsent) {
    return BookHashtagsCompanion(
      bookId: Value(bookId),
      hashtagId: Value(hashtagId),
    );
  }

  factory BookHashtagLink.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookHashtagLink(
      bookId: serializer.fromJson<int>(json['bookId']),
      hashtagId: serializer.fromJson<int>(json['hashtagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bookId': serializer.toJson<int>(bookId),
      'hashtagId': serializer.toJson<int>(hashtagId),
    };
  }

  BookHashtagLink copyWith({int? bookId, int? hashtagId}) => BookHashtagLink(
    bookId: bookId ?? this.bookId,
    hashtagId: hashtagId ?? this.hashtagId,
  );
  BookHashtagLink copyWithCompanion(BookHashtagsCompanion data) {
    return BookHashtagLink(
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      hashtagId: data.hashtagId.present ? data.hashtagId.value : this.hashtagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookHashtagLink(')
          ..write('bookId: $bookId, ')
          ..write('hashtagId: $hashtagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(bookId, hashtagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookHashtagLink &&
          other.bookId == this.bookId &&
          other.hashtagId == this.hashtagId);
}

class BookHashtagsCompanion extends UpdateCompanion<BookHashtagLink> {
  final Value<int> bookId;
  final Value<int> hashtagId;
  final Value<int> rowid;
  const BookHashtagsCompanion({
    this.bookId = const Value.absent(),
    this.hashtagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookHashtagsCompanion.insert({
    required int bookId,
    required int hashtagId,
    this.rowid = const Value.absent(),
  }) : bookId = Value(bookId),
       hashtagId = Value(hashtagId);
  static Insertable<BookHashtagLink> custom({
    Expression<int>? bookId,
    Expression<int>? hashtagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bookId != null) 'book_id': bookId,
      if (hashtagId != null) 'hashtag_id': hashtagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookHashtagsCompanion copyWith({
    Value<int>? bookId,
    Value<int>? hashtagId,
    Value<int>? rowid,
  }) {
    return BookHashtagsCompanion(
      bookId: bookId ?? this.bookId,
      hashtagId: hashtagId ?? this.hashtagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (hashtagId.present) {
      map['hashtag_id'] = Variable<int>(hashtagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookHashtagsCompanion(')
          ..write('bookId: $bookId, ')
          ..write('hashtagId: $hashtagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSetting copyWith({String? key, String? value}) =>
      AppSetting(key: key ?? this.key, value: value ?? this.value);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RoomsTable rooms = $RoomsTable(this);
  late final $CabinetsTable cabinets = $CabinetsTable(this);
  late final $ShelvesTable shelves = $ShelvesTable(this);
  late final $ShelfRowsTable shelfRows = $ShelfRowsTable(this);
  late final $BooksTable books = $BooksTable(this);
  late final $BookPhotosTable bookPhotos = $BookPhotosTable(this);
  late final $AuthorsTable authors = $AuthorsTable(this);
  late final $GenresTable genres = $GenresTable(this);
  late final $PublishersTable publishers = $PublishersTable(this);
  late final $HashtagsTable hashtags = $HashtagsTable(this);
  late final $BookAuthorsTable bookAuthors = $BookAuthorsTable(this);
  late final $BookGenresTable bookGenres = $BookGenresTable(this);
  late final $BookPublishersTable bookPublishers = $BookPublishersTable(this);
  late final $BookHashtagsTable bookHashtags = $BookHashtagsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    rooms,
    cabinets,
    shelves,
    shelfRows,
    books,
    bookPhotos,
    authors,
    genres,
    publishers,
    hashtags,
    bookAuthors,
    bookGenres,
    bookPublishers,
    bookHashtags,
    appSettings,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'rooms',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('cabinets', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'cabinets',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('shelves', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'shelves',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('shelf_rows', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'shelves',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('books', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'shelf_rows',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('books', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'books',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('book_photos', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'books',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('book_authors', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'authors',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('book_authors', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'books',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('book_genres', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'genres',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('book_genres', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'books',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('book_publishers', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'publishers',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('book_publishers', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'books',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('book_hashtags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'hashtags',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('book_hashtags', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$RoomsTableCreateCompanionBuilder = RoomsCompanion Function({
  Value<int> id,
  required String name,
  Value<String> note,
  Value<int> sortOrder,
});
typedef $$RoomsTableUpdateCompanionBuilder = RoomsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> note,
  Value<int> sortOrder,
});

final class $$RoomsTableReferences
    extends BaseReferences<_$AppDatabase, $RoomsTable, Room> {
  $$RoomsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CabinetsTable, List<Cabinet>> _cabinetsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.cabinets,
    aliasName: 'rooms__id__cabinets__room_id',
  );

  $$CabinetsTableProcessedTableManager get cabinetsRefs {
    final manager = $$CabinetsTableTableManager(
      $_db,
      $_db.cabinets,
    ).filter((f) => f.roomId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_cabinetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RoomsTableFilterComposer extends Composer<_$AppDatabase, $RoomsTable> {
  $$RoomsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> cabinetsRefs(
    Expression<bool> Function($$CabinetsTableFilterComposer f) f,
  ) {
    final $$CabinetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cabinets,
      getReferencedColumn: (t) => t.roomId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CabinetsTableFilterComposer(
            $db: $db,
            $table: $db.cabinets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoomsTableOrderingComposer
    extends Composer<_$AppDatabase, $RoomsTable> {
  $$RoomsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RoomsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoomsTable> {
  $$RoomsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> cabinetsRefs<T extends Object>(
    Expression<T> Function($$CabinetsTableAnnotationComposer a) f,
  ) {
    final $$CabinetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cabinets,
      getReferencedColumn: (t) => t.roomId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CabinetsTableAnnotationComposer(
            $db: $db,
            $table: $db.cabinets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoomsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoomsTable,
          Room,
          $$RoomsTableFilterComposer,
          $$RoomsTableOrderingComposer,
          $$RoomsTableAnnotationComposer,
          $$RoomsTableCreateCompanionBuilder,
          $$RoomsTableUpdateCompanionBuilder,
          (Room, $$RoomsTableReferences),
          Room,
          PrefetchHooks Function({bool cabinetsRefs})
        > {
  $$RoomsTableTableManager(_$AppDatabase db, $RoomsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoomsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoomsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoomsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => RoomsCompanion(
                id: id,
                name: name,
                note: note,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String> note = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => RoomsCompanion.insert(
                id: id,
                name: name,
                note: note,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RoomsTable, Room>(table),
                  $$RoomsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cabinetsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (cabinetsRefs) db.cabinets],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (cabinetsRefs)
                    await $_getPrefetchedDataByColumns<
                      Room,
                      $RoomsTable,
                      Cabinet,
                      $CabinetsTable
                    >(
                      currentTable: table,
                      referencedTable: $$RoomsTableReferences
                          ._cabinetsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$RoomsTableReferences(db, table, p0).cabinetsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'room_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$RoomsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoomsTable,
      Room,
      $$RoomsTableFilterComposer,
      $$RoomsTableOrderingComposer,
      $$RoomsTableAnnotationComposer,
      $$RoomsTableCreateCompanionBuilder,
      $$RoomsTableUpdateCompanionBuilder,
      (Room, $$RoomsTableReferences),
      Room,
      PrefetchHooks Function({bool cabinetsRefs})
    >;
typedef $$CabinetsTableCreateCompanionBuilder = CabinetsCompanion Function({
  Value<int> id,
  required int roomId,
  required String name,
  Value<int> sortOrder,
});
typedef $$CabinetsTableUpdateCompanionBuilder = CabinetsCompanion Function({
  Value<int> id,
  Value<int> roomId,
  Value<String> name,
  Value<int> sortOrder,
});

final class $$CabinetsTableReferences
    extends BaseReferences<_$AppDatabase, $CabinetsTable, Cabinet> {
  $$CabinetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RoomsTable _roomIdTable(_$AppDatabase db) =>
      db.rooms.createAlias('cabinets__room_id__rooms__id');

  $$RoomsTableProcessedTableManager get roomId {
    final $_column = $_itemColumn<int>('room_id')!;

    final manager = $$RoomsTableTableManager(
      $_db,
      $_db.rooms,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_roomIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ShelvesTable, List<Shelf>> _shelvesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.shelves,
    aliasName: 'cabinets__id__shelves__cabinet_id',
  );

  $$ShelvesTableProcessedTableManager get shelvesRefs {
    final manager = $$ShelvesTableTableManager(
      $_db,
      $_db.shelves,
    ).filter((f) => f.cabinetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_shelvesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CabinetsTableFilterComposer
    extends Composer<_$AppDatabase, $CabinetsTable> {
  $$CabinetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$RoomsTableFilterComposer get roomId {
    final $$RoomsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roomId,
      referencedTable: $db.rooms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoomsTableFilterComposer(
            $db: $db,
            $table: $db.rooms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> shelvesRefs(
    Expression<bool> Function($$ShelvesTableFilterComposer f) f,
  ) {
    final $$ShelvesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.shelves,
      getReferencedColumn: (t) => t.cabinetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShelvesTableFilterComposer(
            $db: $db,
            $table: $db.shelves,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CabinetsTableOrderingComposer
    extends Composer<_$AppDatabase, $CabinetsTable> {
  $$CabinetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$RoomsTableOrderingComposer get roomId {
    final $$RoomsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roomId,
      referencedTable: $db.rooms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoomsTableOrderingComposer(
            $db: $db,
            $table: $db.rooms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CabinetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CabinetsTable> {
  $$CabinetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$RoomsTableAnnotationComposer get roomId {
    final $$RoomsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roomId,
      referencedTable: $db.rooms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoomsTableAnnotationComposer(
            $db: $db,
            $table: $db.rooms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> shelvesRefs<T extends Object>(
    Expression<T> Function($$ShelvesTableAnnotationComposer a) f,
  ) {
    final $$ShelvesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.shelves,
      getReferencedColumn: (t) => t.cabinetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShelvesTableAnnotationComposer(
            $db: $db,
            $table: $db.shelves,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CabinetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CabinetsTable,
          Cabinet,
          $$CabinetsTableFilterComposer,
          $$CabinetsTableOrderingComposer,
          $$CabinetsTableAnnotationComposer,
          $$CabinetsTableCreateCompanionBuilder,
          $$CabinetsTableUpdateCompanionBuilder,
          (Cabinet, $$CabinetsTableReferences),
          Cabinet,
          PrefetchHooks Function({bool roomId, bool shelvesRefs})
        > {
  $$CabinetsTableTableManager(_$AppDatabase db, $CabinetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CabinetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CabinetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CabinetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> roomId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => CabinetsCompanion(
                id: id,
                roomId: roomId,
                name: name,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int roomId,
                required String name,
                Value<int> sortOrder = const Value.absent(),
              }) => CabinetsCompanion.insert(
                id: id,
                roomId: roomId,
                name: name,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CabinetsTable, Cabinet>(table),
                  $$CabinetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({roomId = false, shelvesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (shelvesRefs) db.shelves],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (roomId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.roomId,
                        referencedTable: $$CabinetsTableReferences._roomIdTable(
                          db,
                        ),
                        referencedColumn: $$CabinetsTableReferences
                            ._roomIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (shelvesRefs)
                    await $_getPrefetchedDataByColumns<
                      Cabinet,
                      $CabinetsTable,
                      Shelf,
                      $ShelvesTable
                    >(
                      currentTable: table,
                      referencedTable: $$CabinetsTableReferences
                          ._shelvesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CabinetsTableReferences(db, table, p0).shelvesRefs,
                      currentColumn: 'id',
                      referencedColumn: 'cabinet_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CabinetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CabinetsTable,
      Cabinet,
      $$CabinetsTableFilterComposer,
      $$CabinetsTableOrderingComposer,
      $$CabinetsTableAnnotationComposer,
      $$CabinetsTableCreateCompanionBuilder,
      $$CabinetsTableUpdateCompanionBuilder,
      (Cabinet, $$CabinetsTableReferences),
      Cabinet,
      PrefetchHooks Function({bool roomId, bool shelvesRefs})
    >;
typedef $$ShelvesTableCreateCompanionBuilder = ShelvesCompanion Function({
  Value<int> id,
  required int cabinetId,
  required int shelfIndex,
  Value<String?> label,
  Value<bool> filled,
});
typedef $$ShelvesTableUpdateCompanionBuilder = ShelvesCompanion Function({
  Value<int> id,
  Value<int> cabinetId,
  Value<int> shelfIndex,
  Value<String?> label,
  Value<bool> filled,
});

final class $$ShelvesTableReferences
    extends BaseReferences<_$AppDatabase, $ShelvesTable, Shelf> {
  $$ShelvesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CabinetsTable _cabinetIdTable(_$AppDatabase db) =>
      db.cabinets.createAlias('shelves__cabinet_id__cabinets__id');

  $$CabinetsTableProcessedTableManager get cabinetId {
    final $_column = $_itemColumn<int>('cabinet_id')!;

    final manager = $$CabinetsTableTableManager(
      $_db,
      $_db.cabinets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cabinetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ShelfRowsTable, List<ShelfRow>>
  _shelfRowsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.shelfRows,
    aliasName: 'shelves__id__shelf_rows__shelf_id',
  );

  $$ShelfRowsTableProcessedTableManager get shelfRowsRefs {
    final manager = $$ShelfRowsTableTableManager(
      $_db,
      $_db.shelfRows,
    ).filter((f) => f.shelfId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_shelfRowsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BooksTable, List<Book>> _booksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.books,
    aliasName: 'shelves__id__books__shelf_id',
  );

  $$BooksTableProcessedTableManager get booksRefs {
    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.shelfId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_booksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ShelvesTableFilterComposer
    extends Composer<_$AppDatabase, $ShelvesTable> {
  $$ShelvesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get shelfIndex => $composableBuilder(
    column: $table.shelfIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get filled => $composableBuilder(
    column: $table.filled,
    builder: (column) => ColumnFilters(column),
  );

  $$CabinetsTableFilterComposer get cabinetId {
    final $$CabinetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cabinetId,
      referencedTable: $db.cabinets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CabinetsTableFilterComposer(
            $db: $db,
            $table: $db.cabinets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> shelfRowsRefs(
    Expression<bool> Function($$ShelfRowsTableFilterComposer f) f,
  ) {
    final $$ShelfRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.shelfRows,
      getReferencedColumn: (t) => t.shelfId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShelfRowsTableFilterComposer(
            $db: $db,
            $table: $db.shelfRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> booksRefs(
    Expression<bool> Function($$BooksTableFilterComposer f) f,
  ) {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.shelfId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ShelvesTableOrderingComposer
    extends Composer<_$AppDatabase, $ShelvesTable> {
  $$ShelvesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get shelfIndex => $composableBuilder(
    column: $table.shelfIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get filled => $composableBuilder(
    column: $table.filled,
    builder: (column) => ColumnOrderings(column),
  );

  $$CabinetsTableOrderingComposer get cabinetId {
    final $$CabinetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cabinetId,
      referencedTable: $db.cabinets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CabinetsTableOrderingComposer(
            $db: $db,
            $table: $db.cabinets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShelvesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShelvesTable> {
  $$ShelvesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get shelfIndex => $composableBuilder(
    column: $table.shelfIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<bool> get filled =>
      $composableBuilder(column: $table.filled, builder: (column) => column);

  $$CabinetsTableAnnotationComposer get cabinetId {
    final $$CabinetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cabinetId,
      referencedTable: $db.cabinets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CabinetsTableAnnotationComposer(
            $db: $db,
            $table: $db.cabinets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> shelfRowsRefs<T extends Object>(
    Expression<T> Function($$ShelfRowsTableAnnotationComposer a) f,
  ) {
    final $$ShelfRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.shelfRows,
      getReferencedColumn: (t) => t.shelfId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShelfRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.shelfRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> booksRefs<T extends Object>(
    Expression<T> Function($$BooksTableAnnotationComposer a) f,
  ) {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.shelfId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ShelvesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShelvesTable,
          Shelf,
          $$ShelvesTableFilterComposer,
          $$ShelvesTableOrderingComposer,
          $$ShelvesTableAnnotationComposer,
          $$ShelvesTableCreateCompanionBuilder,
          $$ShelvesTableUpdateCompanionBuilder,
          (Shelf, $$ShelvesTableReferences),
          Shelf,
          PrefetchHooks Function({
            bool cabinetId,
            bool shelfRowsRefs,
            bool booksRefs,
          })
        > {
  $$ShelvesTableTableManager(_$AppDatabase db, $ShelvesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShelvesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShelvesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShelvesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> cabinetId = const Value.absent(),
                Value<int> shelfIndex = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<bool> filled = const Value.absent(),
              }) => ShelvesCompanion(
                id: id,
                cabinetId: cabinetId,
                shelfIndex: shelfIndex,
                label: label,
                filled: filled,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int cabinetId,
                required int shelfIndex,
                Value<String?> label = const Value.absent(),
                Value<bool> filled = const Value.absent(),
              }) => ShelvesCompanion.insert(
                id: id,
                cabinetId: cabinetId,
                shelfIndex: shelfIndex,
                label: label,
                filled: filled,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ShelvesTable, Shelf>(table),
                  $$ShelvesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({cabinetId = false, shelfRowsRefs = false, booksRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (shelfRowsRefs) db.shelfRows,
                    if (booksRefs) db.books,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (cabinetId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.cabinetId,
                            referencedTable: $$ShelvesTableReferences
                                ._cabinetIdTable(db),
                            referencedColumn: $$ShelvesTableReferences
                                ._cabinetIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (shelfRowsRefs)
                        await $_getPrefetchedDataByColumns<
                          Shelf,
                          $ShelvesTable,
                          ShelfRow,
                          $ShelfRowsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ShelvesTableReferences
                              ._shelfRowsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ShelvesTableReferences(
                                db,
                                table,
                                p0,
                              ).shelfRowsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'shelf_id',
                          typedResults: items,
                        ),
                      if (booksRefs)
                        await $_getPrefetchedDataByColumns<
                          Shelf,
                          $ShelvesTable,
                          Book,
                          $BooksTable
                        >(
                          currentTable: table,
                          referencedTable: $$ShelvesTableReferences
                              ._booksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ShelvesTableReferences(db, table, p0).booksRefs,
                          currentColumn: 'id',
                          referencedColumn: 'shelf_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ShelvesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShelvesTable,
      Shelf,
      $$ShelvesTableFilterComposer,
      $$ShelvesTableOrderingComposer,
      $$ShelvesTableAnnotationComposer,
      $$ShelvesTableCreateCompanionBuilder,
      $$ShelvesTableUpdateCompanionBuilder,
      (Shelf, $$ShelvesTableReferences),
      Shelf,
      PrefetchHooks Function({
        bool cabinetId,
        bool shelfRowsRefs,
        bool booksRefs,
      })
    >;
typedef $$ShelfRowsTableCreateCompanionBuilder = ShelfRowsCompanion Function({
  Value<int> id,
  required int shelfId,
  required int rowIndex,
  Value<String?> label,
  Value<int?> capacity,
});
typedef $$ShelfRowsTableUpdateCompanionBuilder = ShelfRowsCompanion Function({
  Value<int> id,
  Value<int> shelfId,
  Value<int> rowIndex,
  Value<String?> label,
  Value<int?> capacity,
});

final class $$ShelfRowsTableReferences
    extends BaseReferences<_$AppDatabase, $ShelfRowsTable, ShelfRow> {
  $$ShelfRowsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ShelvesTable _shelfIdTable(_$AppDatabase db) =>
      db.shelves.createAlias('shelf_rows__shelf_id__shelves__id');

  $$ShelvesTableProcessedTableManager get shelfId {
    final $_column = $_itemColumn<int>('shelf_id')!;

    final manager = $$ShelvesTableTableManager(
      $_db,
      $_db.shelves,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_shelfIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$BooksTable, List<Book>> _booksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.books,
    aliasName: 'shelf_rows__id__books__row_id',
  );

  $$BooksTableProcessedTableManager get booksRefs {
    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.rowId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_booksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ShelfRowsTableFilterComposer
    extends Composer<_$AppDatabase, $ShelfRowsTable> {
  $$ShelfRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rowIndex => $composableBuilder(
    column: $table.rowIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get capacity => $composableBuilder(
    column: $table.capacity,
    builder: (column) => ColumnFilters(column),
  );

  $$ShelvesTableFilterComposer get shelfId {
    final $$ShelvesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shelfId,
      referencedTable: $db.shelves,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShelvesTableFilterComposer(
            $db: $db,
            $table: $db.shelves,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> booksRefs(
    Expression<bool> Function($$BooksTableFilterComposer f) f,
  ) {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.rowId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ShelfRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $ShelfRowsTable> {
  $$ShelfRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rowIndex => $composableBuilder(
    column: $table.rowIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get capacity => $composableBuilder(
    column: $table.capacity,
    builder: (column) => ColumnOrderings(column),
  );

  $$ShelvesTableOrderingComposer get shelfId {
    final $$ShelvesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shelfId,
      referencedTable: $db.shelves,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShelvesTableOrderingComposer(
            $db: $db,
            $table: $db.shelves,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShelfRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShelfRowsTable> {
  $$ShelfRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get rowIndex =>
      $composableBuilder(column: $table.rowIndex, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get capacity =>
      $composableBuilder(column: $table.capacity, builder: (column) => column);

  $$ShelvesTableAnnotationComposer get shelfId {
    final $$ShelvesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shelfId,
      referencedTable: $db.shelves,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShelvesTableAnnotationComposer(
            $db: $db,
            $table: $db.shelves,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> booksRefs<T extends Object>(
    Expression<T> Function($$BooksTableAnnotationComposer a) f,
  ) {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.rowId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ShelfRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShelfRowsTable,
          ShelfRow,
          $$ShelfRowsTableFilterComposer,
          $$ShelfRowsTableOrderingComposer,
          $$ShelfRowsTableAnnotationComposer,
          $$ShelfRowsTableCreateCompanionBuilder,
          $$ShelfRowsTableUpdateCompanionBuilder,
          (ShelfRow, $$ShelfRowsTableReferences),
          ShelfRow,
          PrefetchHooks Function({bool shelfId, bool booksRefs})
        > {
  $$ShelfRowsTableTableManager(_$AppDatabase db, $ShelfRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShelfRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShelfRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShelfRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> shelfId = const Value.absent(),
                Value<int> rowIndex = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<int?> capacity = const Value.absent(),
              }) => ShelfRowsCompanion(
                id: id,
                shelfId: shelfId,
                rowIndex: rowIndex,
                label: label,
                capacity: capacity,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int shelfId,
                required int rowIndex,
                Value<String?> label = const Value.absent(),
                Value<int?> capacity = const Value.absent(),
              }) => ShelfRowsCompanion.insert(
                id: id,
                shelfId: shelfId,
                rowIndex: rowIndex,
                label: label,
                capacity: capacity,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ShelfRowsTable, ShelfRow>(table),
                  $$ShelfRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({shelfId = false, booksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (booksRefs) db.books],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (shelfId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.shelfId,
                        referencedTable: $$ShelfRowsTableReferences
                            ._shelfIdTable(db),
                        referencedColumn: $$ShelfRowsTableReferences
                            ._shelfIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (booksRefs)
                    await $_getPrefetchedDataByColumns<
                      ShelfRow,
                      $ShelfRowsTable,
                      Book,
                      $BooksTable
                    >(
                      currentTable: table,
                      referencedTable: $$ShelfRowsTableReferences
                          ._booksRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ShelfRowsTableReferences(db, table, p0).booksRefs,
                      currentColumn: 'id',
                      referencedColumn: 'row_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ShelfRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShelfRowsTable,
      ShelfRow,
      $$ShelfRowsTableFilterComposer,
      $$ShelfRowsTableOrderingComposer,
      $$ShelfRowsTableAnnotationComposer,
      $$ShelfRowsTableCreateCompanionBuilder,
      $$ShelfRowsTableUpdateCompanionBuilder,
      (ShelfRow, $$ShelfRowsTableReferences),
      ShelfRow,
      PrefetchHooks Function({bool shelfId, bool booksRefs})
    >;
typedef $$BooksTableCreateCompanionBuilder = BooksCompanion Function({
  Value<int> id,
  required String title,
  Value<String> subtitle,
  Value<String> description,
  Value<String> personalNote,
  Value<String?> isbn,
  Value<String?> coverPath,
  Value<String?> sourceUrl,
  Value<int?> shelfId,
  Value<int?> rowId,
  Value<int> positionIndex,
  Value<String> readingStatus,
  Value<DateTime> statusChangedAt,
  Value<String?> seriesName,
  Value<int?> seriesVolume,
  Value<String?> loanPerson,
  Value<DateTime?> loanDueAt,
  Value<DateTime> createdAt,
  Value<String> bookFormat,
  Value<String> placement,
  Value<String?> yandexId,
  Value<String> narrator,
  Value<int?> durationSeconds,
  Value<DateTime?> libraryDueAt,
  Value<int?> readerRating,
  Value<DateTime?> reminderSentForDue,
});
typedef $$BooksTableUpdateCompanionBuilder = BooksCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String> subtitle,
  Value<String> description,
  Value<String> personalNote,
  Value<String?> isbn,
  Value<String?> coverPath,
  Value<String?> sourceUrl,
  Value<int?> shelfId,
  Value<int?> rowId,
  Value<int> positionIndex,
  Value<String> readingStatus,
  Value<DateTime> statusChangedAt,
  Value<String?> seriesName,
  Value<int?> seriesVolume,
  Value<String?> loanPerson,
  Value<DateTime?> loanDueAt,
  Value<DateTime> createdAt,
  Value<String> bookFormat,
  Value<String> placement,
  Value<String?> yandexId,
  Value<String> narrator,
  Value<int?> durationSeconds,
  Value<DateTime?> libraryDueAt,
  Value<int?> readerRating,
  Value<DateTime?> reminderSentForDue,
});

final class $$BooksTableReferences
    extends BaseReferences<_$AppDatabase, $BooksTable, Book> {
  $$BooksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ShelvesTable _shelfIdTable(_$AppDatabase db) =>
      db.shelves.createAlias('books__shelf_id__shelves__id');

  $$ShelvesTableProcessedTableManager? get shelfId {
    final $_column = $_itemColumn<int>('shelf_id');
    if ($_column == null) return null;
    final manager = $$ShelvesTableTableManager(
      $_db,
      $_db.shelves,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_shelfIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ShelfRowsTable _rowIdTable(_$AppDatabase db) =>
      db.shelfRows.createAlias('books__row_id__shelf_rows__id');

  $$ShelfRowsTableProcessedTableManager? get rowId {
    final $_column = $_itemColumn<int>('row_id');
    if ($_column == null) return null;
    final manager = $$ShelfRowsTableTableManager(
      $_db,
      $_db.shelfRows,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_rowIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$BookPhotosTable, List<BookPhoto>>
  _bookPhotosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.bookPhotos,
    aliasName: 'books__id__book_photos__book_id',
  );

  $$BookPhotosTableProcessedTableManager get bookPhotosRefs {
    final manager = $$BookPhotosTableTableManager(
      $_db,
      $_db.bookPhotos,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_bookPhotosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BookAuthorsTable, List<BookAuthorLink>>
  _bookAuthorsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.bookAuthors,
    aliasName: 'books__id__book_authors__book_id',
  );

  $$BookAuthorsTableProcessedTableManager get bookAuthorsRefs {
    final manager = $$BookAuthorsTableTableManager(
      $_db,
      $_db.bookAuthors,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_bookAuthorsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BookGenresTable, List<BookGenreLink>>
  _bookGenresRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.bookGenres,
    aliasName: 'books__id__book_genres__book_id',
  );

  $$BookGenresTableProcessedTableManager get bookGenresRefs {
    final manager = $$BookGenresTableTableManager(
      $_db,
      $_db.bookGenres,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_bookGenresRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BookPublishersTable, List<BookPublisherLink>>
  _bookPublishersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.bookPublishers,
    aliasName: 'books__id__book_publishers__book_id',
  );

  $$BookPublishersTableProcessedTableManager get bookPublishersRefs {
    final manager = $$BookPublishersTableTableManager(
      $_db,
      $_db.bookPublishers,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_bookPublishersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BookHashtagsTable, List<BookHashtagLink>>
  _bookHashtagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.bookHashtags,
    aliasName: 'books__id__book_hashtags__book_id',
  );

  $$BookHashtagsTableProcessedTableManager get bookHashtagsRefs {
    final manager = $$BookHashtagsTableTableManager(
      $_db,
      $_db.bookHashtags,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_bookHashtagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BooksTableFilterComposer extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subtitle => $composableBuilder(
    column: $table.subtitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get personalNote => $composableBuilder(
    column: $table.personalNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get isbn => $composableBuilder(
    column: $table.isbn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverPath => $composableBuilder(
    column: $table.coverPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get positionIndex => $composableBuilder(
    column: $table.positionIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get readingStatus => $composableBuilder(
    column: $table.readingStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get statusChangedAt => $composableBuilder(
    column: $table.statusChangedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seriesName => $composableBuilder(
    column: $table.seriesName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seriesVolume => $composableBuilder(
    column: $table.seriesVolume,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get loanPerson => $composableBuilder(
    column: $table.loanPerson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get loanDueAt => $composableBuilder(
    column: $table.loanDueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookFormat => $composableBuilder(
    column: $table.bookFormat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get placement => $composableBuilder(
    column: $table.placement,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get yandexId => $composableBuilder(
    column: $table.yandexId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get narrator => $composableBuilder(
    column: $table.narrator,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get libraryDueAt => $composableBuilder(
    column: $table.libraryDueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get readerRating => $composableBuilder(
    column: $table.readerRating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get reminderSentForDue => $composableBuilder(
    column: $table.reminderSentForDue,
    builder: (column) => ColumnFilters(column),
  );

  $$ShelvesTableFilterComposer get shelfId {
    final $$ShelvesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shelfId,
      referencedTable: $db.shelves,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShelvesTableFilterComposer(
            $db: $db,
            $table: $db.shelves,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ShelfRowsTableFilterComposer get rowId {
    final $$ShelfRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rowId,
      referencedTable: $db.shelfRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShelfRowsTableFilterComposer(
            $db: $db,
            $table: $db.shelfRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> bookPhotosRefs(
    Expression<bool> Function($$BookPhotosTableFilterComposer f) f,
  ) {
    final $$BookPhotosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookPhotos,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookPhotosTableFilterComposer(
            $db: $db,
            $table: $db.bookPhotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> bookAuthorsRefs(
    Expression<bool> Function($$BookAuthorsTableFilterComposer f) f,
  ) {
    final $$BookAuthorsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookAuthors,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookAuthorsTableFilterComposer(
            $db: $db,
            $table: $db.bookAuthors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> bookGenresRefs(
    Expression<bool> Function($$BookGenresTableFilterComposer f) f,
  ) {
    final $$BookGenresTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookGenres,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookGenresTableFilterComposer(
            $db: $db,
            $table: $db.bookGenres,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> bookPublishersRefs(
    Expression<bool> Function($$BookPublishersTableFilterComposer f) f,
  ) {
    final $$BookPublishersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookPublishers,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookPublishersTableFilterComposer(
            $db: $db,
            $table: $db.bookPublishers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> bookHashtagsRefs(
    Expression<bool> Function($$BookHashtagsTableFilterComposer f) f,
  ) {
    final $$BookHashtagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookHashtags,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookHashtagsTableFilterComposer(
            $db: $db,
            $table: $db.bookHashtags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BooksTableOrderingComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subtitle => $composableBuilder(
    column: $table.subtitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get personalNote => $composableBuilder(
    column: $table.personalNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get isbn => $composableBuilder(
    column: $table.isbn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverPath => $composableBuilder(
    column: $table.coverPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get positionIndex => $composableBuilder(
    column: $table.positionIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get readingStatus => $composableBuilder(
    column: $table.readingStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get statusChangedAt => $composableBuilder(
    column: $table.statusChangedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seriesName => $composableBuilder(
    column: $table.seriesName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seriesVolume => $composableBuilder(
    column: $table.seriesVolume,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get loanPerson => $composableBuilder(
    column: $table.loanPerson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get loanDueAt => $composableBuilder(
    column: $table.loanDueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookFormat => $composableBuilder(
    column: $table.bookFormat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get placement => $composableBuilder(
    column: $table.placement,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get yandexId => $composableBuilder(
    column: $table.yandexId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get narrator => $composableBuilder(
    column: $table.narrator,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get libraryDueAt => $composableBuilder(
    column: $table.libraryDueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get readerRating => $composableBuilder(
    column: $table.readerRating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get reminderSentForDue => $composableBuilder(
    column: $table.reminderSentForDue,
    builder: (column) => ColumnOrderings(column),
  );

  $$ShelvesTableOrderingComposer get shelfId {
    final $$ShelvesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shelfId,
      referencedTable: $db.shelves,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShelvesTableOrderingComposer(
            $db: $db,
            $table: $db.shelves,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ShelfRowsTableOrderingComposer get rowId {
    final $$ShelfRowsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rowId,
      referencedTable: $db.shelfRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShelfRowsTableOrderingComposer(
            $db: $db,
            $table: $db.shelfRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get subtitle =>
      $composableBuilder(column: $table.subtitle, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get personalNote => $composableBuilder(
    column: $table.personalNote,
    builder: (column) => column,
  );

  GeneratedColumn<String> get isbn =>
      $composableBuilder(column: $table.isbn, builder: (column) => column);

  GeneratedColumn<String> get coverPath =>
      $composableBuilder(column: $table.coverPath, builder: (column) => column);

  GeneratedColumn<String> get sourceUrl =>
      $composableBuilder(column: $table.sourceUrl, builder: (column) => column);

  GeneratedColumn<int> get positionIndex => $composableBuilder(
    column: $table.positionIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get readingStatus => $composableBuilder(
    column: $table.readingStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get statusChangedAt => $composableBuilder(
    column: $table.statusChangedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get seriesName => $composableBuilder(
    column: $table.seriesName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get seriesVolume => $composableBuilder(
    column: $table.seriesVolume,
    builder: (column) => column,
  );

  GeneratedColumn<String> get loanPerson => $composableBuilder(
    column: $table.loanPerson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get loanDueAt =>
      $composableBuilder(column: $table.loanDueAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get bookFormat => $composableBuilder(
    column: $table.bookFormat,
    builder: (column) => column,
  );

  GeneratedColumn<String> get placement =>
      $composableBuilder(column: $table.placement, builder: (column) => column);

  GeneratedColumn<String> get yandexId =>
      $composableBuilder(column: $table.yandexId, builder: (column) => column);

  GeneratedColumn<String> get narrator =>
      $composableBuilder(column: $table.narrator, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get libraryDueAt => $composableBuilder(
    column: $table.libraryDueAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get readerRating => $composableBuilder(
    column: $table.readerRating,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get reminderSentForDue => $composableBuilder(
    column: $table.reminderSentForDue,
    builder: (column) => column,
  );

  $$ShelvesTableAnnotationComposer get shelfId {
    final $$ShelvesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shelfId,
      referencedTable: $db.shelves,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShelvesTableAnnotationComposer(
            $db: $db,
            $table: $db.shelves,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ShelfRowsTableAnnotationComposer get rowId {
    final $$ShelfRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rowId,
      referencedTable: $db.shelfRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShelfRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.shelfRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> bookPhotosRefs<T extends Object>(
    Expression<T> Function($$BookPhotosTableAnnotationComposer a) f,
  ) {
    final $$BookPhotosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookPhotos,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookPhotosTableAnnotationComposer(
            $db: $db,
            $table: $db.bookPhotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> bookAuthorsRefs<T extends Object>(
    Expression<T> Function($$BookAuthorsTableAnnotationComposer a) f,
  ) {
    final $$BookAuthorsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookAuthors,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookAuthorsTableAnnotationComposer(
            $db: $db,
            $table: $db.bookAuthors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> bookGenresRefs<T extends Object>(
    Expression<T> Function($$BookGenresTableAnnotationComposer a) f,
  ) {
    final $$BookGenresTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookGenres,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookGenresTableAnnotationComposer(
            $db: $db,
            $table: $db.bookGenres,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> bookPublishersRefs<T extends Object>(
    Expression<T> Function($$BookPublishersTableAnnotationComposer a) f,
  ) {
    final $$BookPublishersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookPublishers,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookPublishersTableAnnotationComposer(
            $db: $db,
            $table: $db.bookPublishers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> bookHashtagsRefs<T extends Object>(
    Expression<T> Function($$BookHashtagsTableAnnotationComposer a) f,
  ) {
    final $$BookHashtagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookHashtags,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookHashtagsTableAnnotationComposer(
            $db: $db,
            $table: $db.bookHashtags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BooksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BooksTable,
          Book,
          $$BooksTableFilterComposer,
          $$BooksTableOrderingComposer,
          $$BooksTableAnnotationComposer,
          $$BooksTableCreateCompanionBuilder,
          $$BooksTableUpdateCompanionBuilder,
          (Book, $$BooksTableReferences),
          Book,
          PrefetchHooks Function({
            bool shelfId,
            bool rowId,
            bool bookPhotosRefs,
            bool bookAuthorsRefs,
            bool bookGenresRefs,
            bool bookPublishersRefs,
            bool bookHashtagsRefs,
          })
        > {
  $$BooksTableTableManager(_$AppDatabase db, $BooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> subtitle = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> personalNote = const Value.absent(),
                Value<String?> isbn = const Value.absent(),
                Value<String?> coverPath = const Value.absent(),
                Value<String?> sourceUrl = const Value.absent(),
                Value<int?> shelfId = const Value.absent(),
                Value<int?> rowId = const Value.absent(),
                Value<int> positionIndex = const Value.absent(),
                Value<String> readingStatus = const Value.absent(),
                Value<DateTime> statusChangedAt = const Value.absent(),
                Value<String?> seriesName = const Value.absent(),
                Value<int?> seriesVolume = const Value.absent(),
                Value<String?> loanPerson = const Value.absent(),
                Value<DateTime?> loanDueAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> bookFormat = const Value.absent(),
                Value<String> placement = const Value.absent(),
                Value<String?> yandexId = const Value.absent(),
                Value<String> narrator = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<DateTime?> libraryDueAt = const Value.absent(),
                Value<int?> readerRating = const Value.absent(),
                Value<DateTime?> reminderSentForDue = const Value.absent(),
              }) => BooksCompanion(
                id: id,
                title: title,
                subtitle: subtitle,
                description: description,
                personalNote: personalNote,
                isbn: isbn,
                coverPath: coverPath,
                sourceUrl: sourceUrl,
                shelfId: shelfId,
                rowId: rowId,
                positionIndex: positionIndex,
                readingStatus: readingStatus,
                statusChangedAt: statusChangedAt,
                seriesName: seriesName,
                seriesVolume: seriesVolume,
                loanPerson: loanPerson,
                loanDueAt: loanDueAt,
                createdAt: createdAt,
                bookFormat: bookFormat,
                placement: placement,
                yandexId: yandexId,
                narrator: narrator,
                durationSeconds: durationSeconds,
                libraryDueAt: libraryDueAt,
                readerRating: readerRating,
                reminderSentForDue: reminderSentForDue,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String> subtitle = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> personalNote = const Value.absent(),
                Value<String?> isbn = const Value.absent(),
                Value<String?> coverPath = const Value.absent(),
                Value<String?> sourceUrl = const Value.absent(),
                Value<int?> shelfId = const Value.absent(),
                Value<int?> rowId = const Value.absent(),
                Value<int> positionIndex = const Value.absent(),
                Value<String> readingStatus = const Value.absent(),
                Value<DateTime> statusChangedAt = const Value.absent(),
                Value<String?> seriesName = const Value.absent(),
                Value<int?> seriesVolume = const Value.absent(),
                Value<String?> loanPerson = const Value.absent(),
                Value<DateTime?> loanDueAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> bookFormat = const Value.absent(),
                Value<String> placement = const Value.absent(),
                Value<String?> yandexId = const Value.absent(),
                Value<String> narrator = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<DateTime?> libraryDueAt = const Value.absent(),
                Value<int?> readerRating = const Value.absent(),
                Value<DateTime?> reminderSentForDue = const Value.absent(),
              }) => BooksCompanion.insert(
                id: id,
                title: title,
                subtitle: subtitle,
                description: description,
                personalNote: personalNote,
                isbn: isbn,
                coverPath: coverPath,
                sourceUrl: sourceUrl,
                shelfId: shelfId,
                rowId: rowId,
                positionIndex: positionIndex,
                readingStatus: readingStatus,
                statusChangedAt: statusChangedAt,
                seriesName: seriesName,
                seriesVolume: seriesVolume,
                loanPerson: loanPerson,
                loanDueAt: loanDueAt,
                createdAt: createdAt,
                bookFormat: bookFormat,
                placement: placement,
                yandexId: yandexId,
                narrator: narrator,
                durationSeconds: durationSeconds,
                libraryDueAt: libraryDueAt,
                readerRating: readerRating,
                reminderSentForDue: reminderSentForDue,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BooksTable, Book>(table),
                  $$BooksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                shelfId = false,
                rowId = false,
                bookPhotosRefs = false,
                bookAuthorsRefs = false,
                bookGenresRefs = false,
                bookPublishersRefs = false,
                bookHashtagsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (bookPhotosRefs) db.bookPhotos,
                    if (bookAuthorsRefs) db.bookAuthors,
                    if (bookGenresRefs) db.bookGenres,
                    if (bookPublishersRefs) db.bookPublishers,
                    if (bookHashtagsRefs) db.bookHashtags,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (shelfId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.shelfId,
                            referencedTable: $$BooksTableReferences
                                ._shelfIdTable(db),
                            referencedColumn: $$BooksTableReferences
                                ._shelfIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (rowId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.rowId,
                            referencedTable: $$BooksTableReferences._rowIdTable(
                              db,
                            ),
                            referencedColumn: $$BooksTableReferences
                                ._rowIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (bookPhotosRefs)
                        await $_getPrefetchedDataByColumns<
                          Book,
                          $BooksTable,
                          BookPhoto,
                          $BookPhotosTable
                        >(
                          currentTable: table,
                          referencedTable: $$BooksTableReferences
                              ._bookPhotosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BooksTableReferences(
                                db,
                                table,
                                p0,
                              ).bookPhotosRefs,
                          currentColumn: 'id',
                          referencedColumn: 'book_id',
                          typedResults: items,
                        ),
                      if (bookAuthorsRefs)
                        await $_getPrefetchedDataByColumns<
                          Book,
                          $BooksTable,
                          BookAuthorLink,
                          $BookAuthorsTable
                        >(
                          currentTable: table,
                          referencedTable: $$BooksTableReferences
                              ._bookAuthorsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BooksTableReferences(
                                db,
                                table,
                                p0,
                              ).bookAuthorsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'book_id',
                          typedResults: items,
                        ),
                      if (bookGenresRefs)
                        await $_getPrefetchedDataByColumns<
                          Book,
                          $BooksTable,
                          BookGenreLink,
                          $BookGenresTable
                        >(
                          currentTable: table,
                          referencedTable: $$BooksTableReferences
                              ._bookGenresRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BooksTableReferences(
                                db,
                                table,
                                p0,
                              ).bookGenresRefs,
                          currentColumn: 'id',
                          referencedColumn: 'book_id',
                          typedResults: items,
                        ),
                      if (bookPublishersRefs)
                        await $_getPrefetchedDataByColumns<
                          Book,
                          $BooksTable,
                          BookPublisherLink,
                          $BookPublishersTable
                        >(
                          currentTable: table,
                          referencedTable: $$BooksTableReferences
                              ._bookPublishersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BooksTableReferences(
                                db,
                                table,
                                p0,
                              ).bookPublishersRefs,
                          currentColumn: 'id',
                          referencedColumn: 'book_id',
                          typedResults: items,
                        ),
                      if (bookHashtagsRefs)
                        await $_getPrefetchedDataByColumns<
                          Book,
                          $BooksTable,
                          BookHashtagLink,
                          $BookHashtagsTable
                        >(
                          currentTable: table,
                          referencedTable: $$BooksTableReferences
                              ._bookHashtagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BooksTableReferences(
                                db,
                                table,
                                p0,
                              ).bookHashtagsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'book_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$BooksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BooksTable,
      Book,
      $$BooksTableFilterComposer,
      $$BooksTableOrderingComposer,
      $$BooksTableAnnotationComposer,
      $$BooksTableCreateCompanionBuilder,
      $$BooksTableUpdateCompanionBuilder,
      (Book, $$BooksTableReferences),
      Book,
      PrefetchHooks Function({
        bool shelfId,
        bool rowId,
        bool bookPhotosRefs,
        bool bookAuthorsRefs,
        bool bookGenresRefs,
        bool bookPublishersRefs,
        bool bookHashtagsRefs,
      })
    >;
typedef $$BookPhotosTableCreateCompanionBuilder = BookPhotosCompanion Function({
  Value<int> id,
  required int bookId,
  required String path,
  Value<int> sortOrder,
});
typedef $$BookPhotosTableUpdateCompanionBuilder = BookPhotosCompanion Function({
  Value<int> id,
  Value<int> bookId,
  Value<String> path,
  Value<int> sortOrder,
});

final class $$BookPhotosTableReferences
    extends BaseReferences<_$AppDatabase, $BookPhotosTable, BookPhoto> {
  $$BookPhotosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BooksTable _bookIdTable(_$AppDatabase db) =>
      db.books.createAlias('book_photos__book_id__books__id');

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<int>('book_id')!;

    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BookPhotosTableFilterComposer
    extends Composer<_$AppDatabase, $BookPhotosTable> {
  $$BookPhotosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookPhotosTableOrderingComposer
    extends Composer<_$AppDatabase, $BookPhotosTable> {
  $$BookPhotosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookPhotosTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookPhotosTable> {
  $$BookPhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookPhotosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookPhotosTable,
          BookPhoto,
          $$BookPhotosTableFilterComposer,
          $$BookPhotosTableOrderingComposer,
          $$BookPhotosTableAnnotationComposer,
          $$BookPhotosTableCreateCompanionBuilder,
          $$BookPhotosTableUpdateCompanionBuilder,
          (BookPhoto, $$BookPhotosTableReferences),
          BookPhoto,
          PrefetchHooks Function({bool bookId})
        > {
  $$BookPhotosTableTableManager(_$AppDatabase db, $BookPhotosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookPhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookPhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookPhotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> bookId = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => BookPhotosCompanion(
                id: id,
                bookId: bookId,
                path: path,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int bookId,
                required String path,
                Value<int> sortOrder = const Value.absent(),
              }) => BookPhotosCompanion.insert(
                id: id,
                bookId: bookId,
                path: path,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BookPhotosTable, BookPhoto>(table),
                  $$BookPhotosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bookId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.bookId,
                        referencedTable: $$BookPhotosTableReferences
                            ._bookIdTable(db),
                        referencedColumn: $$BookPhotosTableReferences
                            ._bookIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BookPhotosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookPhotosTable,
      BookPhoto,
      $$BookPhotosTableFilterComposer,
      $$BookPhotosTableOrderingComposer,
      $$BookPhotosTableAnnotationComposer,
      $$BookPhotosTableCreateCompanionBuilder,
      $$BookPhotosTableUpdateCompanionBuilder,
      (BookPhoto, $$BookPhotosTableReferences),
      BookPhoto,
      PrefetchHooks Function({bool bookId})
    >;
typedef $$AuthorsTableCreateCompanionBuilder = AuthorsCompanion Function({
  Value<int> id,
  required String name,
  required String nameKey,
});
typedef $$AuthorsTableUpdateCompanionBuilder = AuthorsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> nameKey,
});

final class $$AuthorsTableReferences
    extends BaseReferences<_$AppDatabase, $AuthorsTable, Author> {
  $$AuthorsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$BookAuthorsTable, List<BookAuthorLink>>
  _bookAuthorsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.bookAuthors,
    aliasName: 'authors__id__book_authors__author_id',
  );

  $$BookAuthorsTableProcessedTableManager get bookAuthorsRefs {
    final manager = $$BookAuthorsTableTableManager(
      $_db,
      $_db.bookAuthors,
    ).filter((f) => f.authorId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_bookAuthorsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AuthorsTableFilterComposer
    extends Composer<_$AppDatabase, $AuthorsTable> {
  $$AuthorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameKey => $composableBuilder(
    column: $table.nameKey,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> bookAuthorsRefs(
    Expression<bool> Function($$BookAuthorsTableFilterComposer f) f,
  ) {
    final $$BookAuthorsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookAuthors,
      getReferencedColumn: (t) => t.authorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookAuthorsTableFilterComposer(
            $db: $db,
            $table: $db.bookAuthors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AuthorsTableOrderingComposer
    extends Composer<_$AppDatabase, $AuthorsTable> {
  $$AuthorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameKey => $composableBuilder(
    column: $table.nameKey,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AuthorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuthorsTable> {
  $$AuthorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nameKey =>
      $composableBuilder(column: $table.nameKey, builder: (column) => column);

  Expression<T> bookAuthorsRefs<T extends Object>(
    Expression<T> Function($$BookAuthorsTableAnnotationComposer a) f,
  ) {
    final $$BookAuthorsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookAuthors,
      getReferencedColumn: (t) => t.authorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookAuthorsTableAnnotationComposer(
            $db: $db,
            $table: $db.bookAuthors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AuthorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AuthorsTable,
          Author,
          $$AuthorsTableFilterComposer,
          $$AuthorsTableOrderingComposer,
          $$AuthorsTableAnnotationComposer,
          $$AuthorsTableCreateCompanionBuilder,
          $$AuthorsTableUpdateCompanionBuilder,
          (Author, $$AuthorsTableReferences),
          Author,
          PrefetchHooks Function({bool bookAuthorsRefs})
        > {
  $$AuthorsTableTableManager(_$AppDatabase db, $AuthorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuthorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuthorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuthorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> nameKey = const Value.absent(),
          }) => AuthorsCompanion(id: id, name: name, nameKey: nameKey),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String nameKey,
          }) => AuthorsCompanion.insert(id: id, name: name, nameKey: nameKey),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AuthorsTable, Author>(table),
                  $$AuthorsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookAuthorsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (bookAuthorsRefs) db.bookAuthors],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (bookAuthorsRefs)
                    await $_getPrefetchedDataByColumns<
                      Author,
                      $AuthorsTable,
                      BookAuthorLink,
                      $BookAuthorsTable
                    >(
                      currentTable: table,
                      referencedTable: $$AuthorsTableReferences
                          ._bookAuthorsRefsTable(db),
                      managerFromTypedResult: (p0) => $$AuthorsTableReferences(
                        db,
                        table,
                        p0,
                      ).bookAuthorsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'author_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AuthorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AuthorsTable,
      Author,
      $$AuthorsTableFilterComposer,
      $$AuthorsTableOrderingComposer,
      $$AuthorsTableAnnotationComposer,
      $$AuthorsTableCreateCompanionBuilder,
      $$AuthorsTableUpdateCompanionBuilder,
      (Author, $$AuthorsTableReferences),
      Author,
      PrefetchHooks Function({bool bookAuthorsRefs})
    >;
typedef $$GenresTableCreateCompanionBuilder = GenresCompanion Function({
  Value<int> id,
  required String name,
  required String nameKey,
});
typedef $$GenresTableUpdateCompanionBuilder = GenresCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> nameKey,
});

final class $$GenresTableReferences
    extends BaseReferences<_$AppDatabase, $GenresTable, Genre> {
  $$GenresTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$BookGenresTable, List<BookGenreLink>>
  _bookGenresRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.bookGenres,
    aliasName: 'genres__id__book_genres__genre_id',
  );

  $$BookGenresTableProcessedTableManager get bookGenresRefs {
    final manager = $$BookGenresTableTableManager(
      $_db,
      $_db.bookGenres,
    ).filter((f) => f.genreId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_bookGenresRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GenresTableFilterComposer
    extends Composer<_$AppDatabase, $GenresTable> {
  $$GenresTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameKey => $composableBuilder(
    column: $table.nameKey,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> bookGenresRefs(
    Expression<bool> Function($$BookGenresTableFilterComposer f) f,
  ) {
    final $$BookGenresTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookGenres,
      getReferencedColumn: (t) => t.genreId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookGenresTableFilterComposer(
            $db: $db,
            $table: $db.bookGenres,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GenresTableOrderingComposer
    extends Composer<_$AppDatabase, $GenresTable> {
  $$GenresTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameKey => $composableBuilder(
    column: $table.nameKey,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GenresTableAnnotationComposer
    extends Composer<_$AppDatabase, $GenresTable> {
  $$GenresTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nameKey =>
      $composableBuilder(column: $table.nameKey, builder: (column) => column);

  Expression<T> bookGenresRefs<T extends Object>(
    Expression<T> Function($$BookGenresTableAnnotationComposer a) f,
  ) {
    final $$BookGenresTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookGenres,
      getReferencedColumn: (t) => t.genreId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookGenresTableAnnotationComposer(
            $db: $db,
            $table: $db.bookGenres,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GenresTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GenresTable,
          Genre,
          $$GenresTableFilterComposer,
          $$GenresTableOrderingComposer,
          $$GenresTableAnnotationComposer,
          $$GenresTableCreateCompanionBuilder,
          $$GenresTableUpdateCompanionBuilder,
          (Genre, $$GenresTableReferences),
          Genre,
          PrefetchHooks Function({bool bookGenresRefs})
        > {
  $$GenresTableTableManager(_$AppDatabase db, $GenresTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GenresTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GenresTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GenresTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> nameKey = const Value.absent(),
          }) => GenresCompanion(id: id, name: name, nameKey: nameKey),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String nameKey,
          }) => GenresCompanion.insert(id: id, name: name, nameKey: nameKey),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GenresTable, Genre>(table),
                  $$GenresTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookGenresRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (bookGenresRefs) db.bookGenres],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (bookGenresRefs)
                    await $_getPrefetchedDataByColumns<
                      Genre,
                      $GenresTable,
                      BookGenreLink,
                      $BookGenresTable
                    >(
                      currentTable: table,
                      referencedTable: $$GenresTableReferences
                          ._bookGenresRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$GenresTableReferences(db, table, p0).bookGenresRefs,
                      currentColumn: 'id',
                      referencedColumn: 'genre_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$GenresTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GenresTable,
      Genre,
      $$GenresTableFilterComposer,
      $$GenresTableOrderingComposer,
      $$GenresTableAnnotationComposer,
      $$GenresTableCreateCompanionBuilder,
      $$GenresTableUpdateCompanionBuilder,
      (Genre, $$GenresTableReferences),
      Genre,
      PrefetchHooks Function({bool bookGenresRefs})
    >;
typedef $$PublishersTableCreateCompanionBuilder = PublishersCompanion Function({
  Value<int> id,
  required String name,
  required String nameKey,
});
typedef $$PublishersTableUpdateCompanionBuilder = PublishersCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> nameKey,
});

final class $$PublishersTableReferences
    extends BaseReferences<_$AppDatabase, $PublishersTable, Publisher> {
  $$PublishersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$BookPublishersTable, List<BookPublisherLink>>
  _bookPublishersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.bookPublishers,
    aliasName: 'publishers__id__book_publishers__publisher_id',
  );

  $$BookPublishersTableProcessedTableManager get bookPublishersRefs {
    final manager = $$BookPublishersTableTableManager(
      $_db,
      $_db.bookPublishers,
    ).filter((f) => f.publisherId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_bookPublishersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PublishersTableFilterComposer
    extends Composer<_$AppDatabase, $PublishersTable> {
  $$PublishersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameKey => $composableBuilder(
    column: $table.nameKey,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> bookPublishersRefs(
    Expression<bool> Function($$BookPublishersTableFilterComposer f) f,
  ) {
    final $$BookPublishersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookPublishers,
      getReferencedColumn: (t) => t.publisherId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookPublishersTableFilterComposer(
            $db: $db,
            $table: $db.bookPublishers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PublishersTableOrderingComposer
    extends Composer<_$AppDatabase, $PublishersTable> {
  $$PublishersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameKey => $composableBuilder(
    column: $table.nameKey,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PublishersTableAnnotationComposer
    extends Composer<_$AppDatabase, $PublishersTable> {
  $$PublishersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nameKey =>
      $composableBuilder(column: $table.nameKey, builder: (column) => column);

  Expression<T> bookPublishersRefs<T extends Object>(
    Expression<T> Function($$BookPublishersTableAnnotationComposer a) f,
  ) {
    final $$BookPublishersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookPublishers,
      getReferencedColumn: (t) => t.publisherId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookPublishersTableAnnotationComposer(
            $db: $db,
            $table: $db.bookPublishers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PublishersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PublishersTable,
          Publisher,
          $$PublishersTableFilterComposer,
          $$PublishersTableOrderingComposer,
          $$PublishersTableAnnotationComposer,
          $$PublishersTableCreateCompanionBuilder,
          $$PublishersTableUpdateCompanionBuilder,
          (Publisher, $$PublishersTableReferences),
          Publisher,
          PrefetchHooks Function({bool bookPublishersRefs})
        > {
  $$PublishersTableTableManager(_$AppDatabase db, $PublishersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PublishersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PublishersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PublishersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> nameKey = const Value.absent(),
          }) => PublishersCompanion(id: id, name: name, nameKey: nameKey),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String nameKey,
              }) => PublishersCompanion.insert(
                id: id,
                name: name,
                nameKey: nameKey,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PublishersTable, Publisher>(table),
                  $$PublishersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookPublishersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (bookPublishersRefs) db.bookPublishers,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (bookPublishersRefs)
                    await $_getPrefetchedDataByColumns<
                      Publisher,
                      $PublishersTable,
                      BookPublisherLink,
                      $BookPublishersTable
                    >(
                      currentTable: table,
                      referencedTable: $$PublishersTableReferences
                          ._bookPublishersRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PublishersTableReferences(
                            db,
                            table,
                            p0,
                          ).bookPublishersRefs,
                      currentColumn: 'id',
                      referencedColumn: 'publisher_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PublishersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PublishersTable,
      Publisher,
      $$PublishersTableFilterComposer,
      $$PublishersTableOrderingComposer,
      $$PublishersTableAnnotationComposer,
      $$PublishersTableCreateCompanionBuilder,
      $$PublishersTableUpdateCompanionBuilder,
      (Publisher, $$PublishersTableReferences),
      Publisher,
      PrefetchHooks Function({bool bookPublishersRefs})
    >;
typedef $$HashtagsTableCreateCompanionBuilder = HashtagsCompanion Function({
  Value<int> id,
  required String nameKey,
  required String displayName,
});
typedef $$HashtagsTableUpdateCompanionBuilder = HashtagsCompanion Function({
  Value<int> id,
  Value<String> nameKey,
  Value<String> displayName,
});

final class $$HashtagsTableReferences
    extends BaseReferences<_$AppDatabase, $HashtagsTable, Hashtag> {
  $$HashtagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$BookHashtagsTable, List<BookHashtagLink>>
  _bookHashtagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.bookHashtags,
    aliasName: 'hashtags__id__book_hashtags__hashtag_id',
  );

  $$BookHashtagsTableProcessedTableManager get bookHashtagsRefs {
    final manager = $$BookHashtagsTableTableManager(
      $_db,
      $_db.bookHashtags,
    ).filter((f) => f.hashtagId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_bookHashtagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$HashtagsTableFilterComposer
    extends Composer<_$AppDatabase, $HashtagsTable> {
  $$HashtagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameKey => $composableBuilder(
    column: $table.nameKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> bookHashtagsRefs(
    Expression<bool> Function($$BookHashtagsTableFilterComposer f) f,
  ) {
    final $$BookHashtagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookHashtags,
      getReferencedColumn: (t) => t.hashtagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookHashtagsTableFilterComposer(
            $db: $db,
            $table: $db.bookHashtags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HashtagsTableOrderingComposer
    extends Composer<_$AppDatabase, $HashtagsTable> {
  $$HashtagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameKey => $composableBuilder(
    column: $table.nameKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HashtagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HashtagsTable> {
  $$HashtagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nameKey =>
      $composableBuilder(column: $table.nameKey, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  Expression<T> bookHashtagsRefs<T extends Object>(
    Expression<T> Function($$BookHashtagsTableAnnotationComposer a) f,
  ) {
    final $$BookHashtagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookHashtags,
      getReferencedColumn: (t) => t.hashtagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookHashtagsTableAnnotationComposer(
            $db: $db,
            $table: $db.bookHashtags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HashtagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HashtagsTable,
          Hashtag,
          $$HashtagsTableFilterComposer,
          $$HashtagsTableOrderingComposer,
          $$HashtagsTableAnnotationComposer,
          $$HashtagsTableCreateCompanionBuilder,
          $$HashtagsTableUpdateCompanionBuilder,
          (Hashtag, $$HashtagsTableReferences),
          Hashtag,
          PrefetchHooks Function({bool bookHashtagsRefs})
        > {
  $$HashtagsTableTableManager(_$AppDatabase db, $HashtagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HashtagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HashtagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HashtagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nameKey = const Value.absent(),
                Value<String> displayName = const Value.absent(),
              }) => HashtagsCompanion(
                id: id,
                nameKey: nameKey,
                displayName: displayName,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nameKey,
                required String displayName,
              }) => HashtagsCompanion.insert(
                id: id,
                nameKey: nameKey,
                displayName: displayName,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HashtagsTable, Hashtag>(table),
                  $$HashtagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookHashtagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (bookHashtagsRefs) db.bookHashtags],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (bookHashtagsRefs)
                    await $_getPrefetchedDataByColumns<
                      Hashtag,
                      $HashtagsTable,
                      BookHashtagLink,
                      $BookHashtagsTable
                    >(
                      currentTable: table,
                      referencedTable: $$HashtagsTableReferences
                          ._bookHashtagsRefsTable(db),
                      managerFromTypedResult: (p0) => $$HashtagsTableReferences(
                        db,
                        table,
                        p0,
                      ).bookHashtagsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'hashtag_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$HashtagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HashtagsTable,
      Hashtag,
      $$HashtagsTableFilterComposer,
      $$HashtagsTableOrderingComposer,
      $$HashtagsTableAnnotationComposer,
      $$HashtagsTableCreateCompanionBuilder,
      $$HashtagsTableUpdateCompanionBuilder,
      (Hashtag, $$HashtagsTableReferences),
      Hashtag,
      PrefetchHooks Function({bool bookHashtagsRefs})
    >;
typedef $$BookAuthorsTableCreateCompanionBuilder =
    BookAuthorsCompanion Function({
      required int bookId,
      required int authorId,
      Value<int> rowid,
    });
typedef $$BookAuthorsTableUpdateCompanionBuilder =
    BookAuthorsCompanion Function({
      Value<int> bookId,
      Value<int> authorId,
      Value<int> rowid,
    });

final class $$BookAuthorsTableReferences
    extends BaseReferences<_$AppDatabase, $BookAuthorsTable, BookAuthorLink> {
  $$BookAuthorsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BooksTable _bookIdTable(_$AppDatabase db) =>
      db.books.createAlias('book_authors__book_id__books__id');

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<int>('book_id')!;

    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AuthorsTable _authorIdTable(_$AppDatabase db) =>
      db.authors.createAlias('book_authors__author_id__authors__id');

  $$AuthorsTableProcessedTableManager get authorId {
    final $_column = $_itemColumn<int>('author_id')!;

    final manager = $$AuthorsTableTableManager(
      $_db,
      $_db.authors,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_authorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BookAuthorsTableFilterComposer
    extends Composer<_$AppDatabase, $BookAuthorsTable> {
  $$BookAuthorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AuthorsTableFilterComposer get authorId {
    final $$AuthorsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.authorId,
      referencedTable: $db.authors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuthorsTableFilterComposer(
            $db: $db,
            $table: $db.authors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookAuthorsTableOrderingComposer
    extends Composer<_$AppDatabase, $BookAuthorsTable> {
  $$BookAuthorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AuthorsTableOrderingComposer get authorId {
    final $$AuthorsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.authorId,
      referencedTable: $db.authors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuthorsTableOrderingComposer(
            $db: $db,
            $table: $db.authors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookAuthorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookAuthorsTable> {
  $$BookAuthorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AuthorsTableAnnotationComposer get authorId {
    final $$AuthorsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.authorId,
      referencedTable: $db.authors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuthorsTableAnnotationComposer(
            $db: $db,
            $table: $db.authors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookAuthorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookAuthorsTable,
          BookAuthorLink,
          $$BookAuthorsTableFilterComposer,
          $$BookAuthorsTableOrderingComposer,
          $$BookAuthorsTableAnnotationComposer,
          $$BookAuthorsTableCreateCompanionBuilder,
          $$BookAuthorsTableUpdateCompanionBuilder,
          (BookAuthorLink, $$BookAuthorsTableReferences),
          BookAuthorLink,
          PrefetchHooks Function({bool bookId, bool authorId})
        > {
  $$BookAuthorsTableTableManager(_$AppDatabase db, $BookAuthorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookAuthorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookAuthorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookAuthorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> bookId = const Value.absent(),
                Value<int> authorId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookAuthorsCompanion(
                bookId: bookId,
                authorId: authorId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int bookId,
                required int authorId,
                Value<int> rowid = const Value.absent(),
              }) => BookAuthorsCompanion.insert(
                bookId: bookId,
                authorId: authorId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BookAuthorsTable, BookAuthorLink>(table),
                  $$BookAuthorsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookId = false, authorId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bookId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.bookId,
                        referencedTable: $$BookAuthorsTableReferences
                            ._bookIdTable(db),
                        referencedColumn: $$BookAuthorsTableReferences
                            ._bookIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (authorId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.authorId,
                        referencedTable: $$BookAuthorsTableReferences
                            ._authorIdTable(db),
                        referencedColumn: $$BookAuthorsTableReferences
                            ._authorIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BookAuthorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookAuthorsTable,
      BookAuthorLink,
      $$BookAuthorsTableFilterComposer,
      $$BookAuthorsTableOrderingComposer,
      $$BookAuthorsTableAnnotationComposer,
      $$BookAuthorsTableCreateCompanionBuilder,
      $$BookAuthorsTableUpdateCompanionBuilder,
      (BookAuthorLink, $$BookAuthorsTableReferences),
      BookAuthorLink,
      PrefetchHooks Function({bool bookId, bool authorId})
    >;
typedef $$BookGenresTableCreateCompanionBuilder = BookGenresCompanion Function({
  required int bookId,
  required int genreId,
  Value<int> rowid,
});
typedef $$BookGenresTableUpdateCompanionBuilder = BookGenresCompanion Function({
  Value<int> bookId,
  Value<int> genreId,
  Value<int> rowid,
});

final class $$BookGenresTableReferences
    extends BaseReferences<_$AppDatabase, $BookGenresTable, BookGenreLink> {
  $$BookGenresTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BooksTable _bookIdTable(_$AppDatabase db) =>
      db.books.createAlias('book_genres__book_id__books__id');

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<int>('book_id')!;

    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $GenresTable _genreIdTable(_$AppDatabase db) =>
      db.genres.createAlias('book_genres__genre_id__genres__id');

  $$GenresTableProcessedTableManager get genreId {
    final $_column = $_itemColumn<int>('genre_id')!;

    final manager = $$GenresTableTableManager(
      $_db,
      $_db.genres,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_genreIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BookGenresTableFilterComposer
    extends Composer<_$AppDatabase, $BookGenresTable> {
  $$BookGenresTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GenresTableFilterComposer get genreId {
    final $$GenresTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.genreId,
      referencedTable: $db.genres,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GenresTableFilterComposer(
            $db: $db,
            $table: $db.genres,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookGenresTableOrderingComposer
    extends Composer<_$AppDatabase, $BookGenresTable> {
  $$BookGenresTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GenresTableOrderingComposer get genreId {
    final $$GenresTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.genreId,
      referencedTable: $db.genres,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GenresTableOrderingComposer(
            $db: $db,
            $table: $db.genres,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookGenresTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookGenresTable> {
  $$BookGenresTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GenresTableAnnotationComposer get genreId {
    final $$GenresTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.genreId,
      referencedTable: $db.genres,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GenresTableAnnotationComposer(
            $db: $db,
            $table: $db.genres,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookGenresTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookGenresTable,
          BookGenreLink,
          $$BookGenresTableFilterComposer,
          $$BookGenresTableOrderingComposer,
          $$BookGenresTableAnnotationComposer,
          $$BookGenresTableCreateCompanionBuilder,
          $$BookGenresTableUpdateCompanionBuilder,
          (BookGenreLink, $$BookGenresTableReferences),
          BookGenreLink,
          PrefetchHooks Function({bool bookId, bool genreId})
        > {
  $$BookGenresTableTableManager(_$AppDatabase db, $BookGenresTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookGenresTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookGenresTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookGenresTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> bookId = const Value.absent(),
                Value<int> genreId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookGenresCompanion(
                bookId: bookId,
                genreId: genreId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int bookId,
                required int genreId,
                Value<int> rowid = const Value.absent(),
              }) => BookGenresCompanion.insert(
                bookId: bookId,
                genreId: genreId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BookGenresTable, BookGenreLink>(table),
                  $$BookGenresTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookId = false, genreId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bookId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.bookId,
                        referencedTable: $$BookGenresTableReferences
                            ._bookIdTable(db),
                        referencedColumn: $$BookGenresTableReferences
                            ._bookIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (genreId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.genreId,
                        referencedTable: $$BookGenresTableReferences
                            ._genreIdTable(db),
                        referencedColumn: $$BookGenresTableReferences
                            ._genreIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BookGenresTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookGenresTable,
      BookGenreLink,
      $$BookGenresTableFilterComposer,
      $$BookGenresTableOrderingComposer,
      $$BookGenresTableAnnotationComposer,
      $$BookGenresTableCreateCompanionBuilder,
      $$BookGenresTableUpdateCompanionBuilder,
      (BookGenreLink, $$BookGenresTableReferences),
      BookGenreLink,
      PrefetchHooks Function({bool bookId, bool genreId})
    >;
typedef $$BookPublishersTableCreateCompanionBuilder =
    BookPublishersCompanion Function({
      required int bookId,
      required int publisherId,
      Value<int> rowid,
    });
typedef $$BookPublishersTableUpdateCompanionBuilder =
    BookPublishersCompanion Function({
      Value<int> bookId,
      Value<int> publisherId,
      Value<int> rowid,
    });

final class $$BookPublishersTableReferences
    extends
        BaseReferences<_$AppDatabase, $BookPublishersTable, BookPublisherLink> {
  $$BookPublishersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $BooksTable _bookIdTable(_$AppDatabase db) =>
      db.books.createAlias('book_publishers__book_id__books__id');

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<int>('book_id')!;

    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PublishersTable _publisherIdTable(_$AppDatabase db) => db.publishers
      .createAlias('book_publishers__publisher_id__publishers__id');

  $$PublishersTableProcessedTableManager get publisherId {
    final $_column = $_itemColumn<int>('publisher_id')!;

    final manager = $$PublishersTableTableManager(
      $_db,
      $_db.publishers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_publisherIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BookPublishersTableFilterComposer
    extends Composer<_$AppDatabase, $BookPublishersTable> {
  $$BookPublishersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PublishersTableFilterComposer get publisherId {
    final $$PublishersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.publisherId,
      referencedTable: $db.publishers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PublishersTableFilterComposer(
            $db: $db,
            $table: $db.publishers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookPublishersTableOrderingComposer
    extends Composer<_$AppDatabase, $BookPublishersTable> {
  $$BookPublishersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PublishersTableOrderingComposer get publisherId {
    final $$PublishersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.publisherId,
      referencedTable: $db.publishers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PublishersTableOrderingComposer(
            $db: $db,
            $table: $db.publishers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookPublishersTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookPublishersTable> {
  $$BookPublishersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PublishersTableAnnotationComposer get publisherId {
    final $$PublishersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.publisherId,
      referencedTable: $db.publishers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PublishersTableAnnotationComposer(
            $db: $db,
            $table: $db.publishers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookPublishersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookPublishersTable,
          BookPublisherLink,
          $$BookPublishersTableFilterComposer,
          $$BookPublishersTableOrderingComposer,
          $$BookPublishersTableAnnotationComposer,
          $$BookPublishersTableCreateCompanionBuilder,
          $$BookPublishersTableUpdateCompanionBuilder,
          (BookPublisherLink, $$BookPublishersTableReferences),
          BookPublisherLink,
          PrefetchHooks Function({bool bookId, bool publisherId})
        > {
  $$BookPublishersTableTableManager(
    _$AppDatabase db,
    $BookPublishersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookPublishersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookPublishersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookPublishersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> bookId = const Value.absent(),
                Value<int> publisherId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookPublishersCompanion(
                bookId: bookId,
                publisherId: publisherId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int bookId,
                required int publisherId,
                Value<int> rowid = const Value.absent(),
              }) => BookPublishersCompanion.insert(
                bookId: bookId,
                publisherId: publisherId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BookPublishersTable, BookPublisherLink>(table),
                  $$BookPublishersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookId = false, publisherId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bookId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.bookId,
                        referencedTable: $$BookPublishersTableReferences
                            ._bookIdTable(db),
                        referencedColumn: $$BookPublishersTableReferences
                            ._bookIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (publisherId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.publisherId,
                        referencedTable: $$BookPublishersTableReferences
                            ._publisherIdTable(db),
                        referencedColumn: $$BookPublishersTableReferences
                            ._publisherIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BookPublishersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookPublishersTable,
      BookPublisherLink,
      $$BookPublishersTableFilterComposer,
      $$BookPublishersTableOrderingComposer,
      $$BookPublishersTableAnnotationComposer,
      $$BookPublishersTableCreateCompanionBuilder,
      $$BookPublishersTableUpdateCompanionBuilder,
      (BookPublisherLink, $$BookPublishersTableReferences),
      BookPublisherLink,
      PrefetchHooks Function({bool bookId, bool publisherId})
    >;
typedef $$BookHashtagsTableCreateCompanionBuilder =
    BookHashtagsCompanion Function({
      required int bookId,
      required int hashtagId,
      Value<int> rowid,
    });
typedef $$BookHashtagsTableUpdateCompanionBuilder =
    BookHashtagsCompanion Function({
      Value<int> bookId,
      Value<int> hashtagId,
      Value<int> rowid,
    });

final class $$BookHashtagsTableReferences
    extends BaseReferences<_$AppDatabase, $BookHashtagsTable, BookHashtagLink> {
  $$BookHashtagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BooksTable _bookIdTable(_$AppDatabase db) =>
      db.books.createAlias('book_hashtags__book_id__books__id');

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<int>('book_id')!;

    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $HashtagsTable _hashtagIdTable(_$AppDatabase db) =>
      db.hashtags.createAlias('book_hashtags__hashtag_id__hashtags__id');

  $$HashtagsTableProcessedTableManager get hashtagId {
    final $_column = $_itemColumn<int>('hashtag_id')!;

    final manager = $$HashtagsTableTableManager(
      $_db,
      $_db.hashtags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_hashtagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BookHashtagsTableFilterComposer
    extends Composer<_$AppDatabase, $BookHashtagsTable> {
  $$BookHashtagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$HashtagsTableFilterComposer get hashtagId {
    final $$HashtagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.hashtagId,
      referencedTable: $db.hashtags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HashtagsTableFilterComposer(
            $db: $db,
            $table: $db.hashtags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookHashtagsTableOrderingComposer
    extends Composer<_$AppDatabase, $BookHashtagsTable> {
  $$BookHashtagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$HashtagsTableOrderingComposer get hashtagId {
    final $$HashtagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.hashtagId,
      referencedTable: $db.hashtags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HashtagsTableOrderingComposer(
            $db: $db,
            $table: $db.hashtags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookHashtagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookHashtagsTable> {
  $$BookHashtagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$HashtagsTableAnnotationComposer get hashtagId {
    final $$HashtagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.hashtagId,
      referencedTable: $db.hashtags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HashtagsTableAnnotationComposer(
            $db: $db,
            $table: $db.hashtags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookHashtagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookHashtagsTable,
          BookHashtagLink,
          $$BookHashtagsTableFilterComposer,
          $$BookHashtagsTableOrderingComposer,
          $$BookHashtagsTableAnnotationComposer,
          $$BookHashtagsTableCreateCompanionBuilder,
          $$BookHashtagsTableUpdateCompanionBuilder,
          (BookHashtagLink, $$BookHashtagsTableReferences),
          BookHashtagLink,
          PrefetchHooks Function({bool bookId, bool hashtagId})
        > {
  $$BookHashtagsTableTableManager(_$AppDatabase db, $BookHashtagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookHashtagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookHashtagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookHashtagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> bookId = const Value.absent(),
                Value<int> hashtagId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookHashtagsCompanion(
                bookId: bookId,
                hashtagId: hashtagId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int bookId,
                required int hashtagId,
                Value<int> rowid = const Value.absent(),
              }) => BookHashtagsCompanion.insert(
                bookId: bookId,
                hashtagId: hashtagId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BookHashtagsTable, BookHashtagLink>(table),
                  $$BookHashtagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookId = false, hashtagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bookId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.bookId,
                        referencedTable: $$BookHashtagsTableReferences
                            ._bookIdTable(db),
                        referencedColumn: $$BookHashtagsTableReferences
                            ._bookIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (hashtagId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.hashtagId,
                        referencedTable: $$BookHashtagsTableReferences
                            ._hashtagIdTable(db),
                        referencedColumn: $$BookHashtagsTableReferences
                            ._hashtagIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BookHashtagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookHashtagsTable,
      BookHashtagLink,
      $$BookHashtagsTableFilterComposer,
      $$BookHashtagsTableOrderingComposer,
      $$BookHashtagsTableAnnotationComposer,
      $$BookHashtagsTableCreateCompanionBuilder,
      $$BookHashtagsTableUpdateCompanionBuilder,
      (BookHashtagLink, $$BookHashtagsTableReferences),
      BookHashtagLink,
      PrefetchHooks Function({bool bookId, bool hashtagId})
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, AppSetting>(table),
                  BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RoomsTableTableManager get rooms =>
      $$RoomsTableTableManager(_db, _db.rooms);
  $$CabinetsTableTableManager get cabinets =>
      $$CabinetsTableTableManager(_db, _db.cabinets);
  $$ShelvesTableTableManager get shelves =>
      $$ShelvesTableTableManager(_db, _db.shelves);
  $$ShelfRowsTableTableManager get shelfRows =>
      $$ShelfRowsTableTableManager(_db, _db.shelfRows);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db, _db.books);
  $$BookPhotosTableTableManager get bookPhotos =>
      $$BookPhotosTableTableManager(_db, _db.bookPhotos);
  $$AuthorsTableTableManager get authors =>
      $$AuthorsTableTableManager(_db, _db.authors);
  $$GenresTableTableManager get genres =>
      $$GenresTableTableManager(_db, _db.genres);
  $$PublishersTableTableManager get publishers =>
      $$PublishersTableTableManager(_db, _db.publishers);
  $$HashtagsTableTableManager get hashtags =>
      $$HashtagsTableTableManager(_db, _db.hashtags);
  $$BookAuthorsTableTableManager get bookAuthors =>
      $$BookAuthorsTableTableManager(_db, _db.bookAuthors);
  $$BookGenresTableTableManager get bookGenres =>
      $$BookGenresTableTableManager(_db, _db.bookGenres);
  $$BookPublishersTableTableManager get bookPublishers =>
      $$BookPublishersTableTableManager(_db, _db.bookPublishers);
  $$BookHashtagsTableTableManager get bookHashtags =>
      $$BookHashtagsTableTableManager(_db, _db.bookHashtags);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
