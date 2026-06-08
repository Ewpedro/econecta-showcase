class Holerite {
  final String id;
  final String competencia;
  final int mes;
  final int ano;
  final double salarioBruto;
  final double totalDescontos;
  final double salarioLiquido;
  final double inss;
  final double irrf;
  final double fgts;
  final List<Desconto> outrosDescontos;
  final List<Provento> outrosProventos;
  final String? pdfUrl;
  final String? pdfPath;
  final bool baixado;
  final DateTime? dataBaixado;

  Holerite({
    required this.id,
    required this.competencia,
    required this.mes,
    required this.ano,
    required this.salarioBruto,
    required this.totalDescontos,
    required this.salarioLiquido,
    required this.inss,
    required this.irrf,
    required this.fgts,
    this.outrosDescontos = const [],
    this.outrosProventos = const [],
    this.pdfUrl,
    this.pdfPath,
    this.baixado = false,
    this.dataBaixado,
  });

  factory Holerite.fromJson(Map<String, dynamic> json) {
    return Holerite(
      id: json['id']?.toString() ?? '',
      competencia: json['competencia'] ?? json['descricao'] ?? '',
      mes: json['mes'] ?? 1,
      ano: json['ano'] ?? DateTime.now().year,
      salarioBruto: _toDouble(json['salario_bruto'] ?? json['valor_bruto'] ?? json['bruto']),
      totalDescontos: _toDouble(json['total_descontos'] ?? json['descontos']),
      salarioLiquido: _toDouble(json['salario_liquido'] ?? json['valor_liquido'] ?? json['liquido']),
      inss: _toDouble(json['inss']),
      irrf: _toDouble(json['irrf'] ?? json['ir']),
      fgts: _toDouble(json['fgts']),
      outrosDescontos: (json['descontos_lista'] as List<dynamic>? ?? [])
          .map((e) => Desconto.fromJson(e))
          .toList(),
      outrosProventos: (json['proventos_lista'] as List<dynamic>? ?? [])
          .map((e) => Provento.fromJson(e))
          .toList(),
      pdfUrl: json['pdf_url'] ?? json['url_pdf'] ?? json['link'],
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
    return 0.0;
  }

  Holerite copyWith({String? pdfPath, bool? baixado, DateTime? dataBaixado}) {
    return Holerite(
      id: id,
      competencia: competencia,
      mes: mes,
      ano: ano,
      salarioBruto: salarioBruto,
      totalDescontos: totalDescontos,
      salarioLiquido: salarioLiquido,
      inss: inss,
      irrf: irrf,
      fgts: fgts,
      outrosDescontos: outrosDescontos,
      outrosProventos: outrosProventos,
      pdfUrl: pdfUrl,
      pdfPath: pdfPath ?? this.pdfPath,
      baixado: baixado ?? this.baixado,
      dataBaixado: dataBaixado ?? this.dataBaixado,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'competencia': competencia,
    'mes': mes,
    'ano': ano,
    'salario_bruto': salarioBruto,
    'total_descontos': totalDescontos,
    'salario_liquido': salarioLiquido,
    'inss': inss,
    'irrf': irrf,
    'fgts': fgts,
    'pdf_url': pdfUrl,
    'pdf_path': pdfPath,
    'baixado': baixado,
    'data_baixado': dataBaixado?.toIso8601String(),
  };

  factory Holerite.fromMap(Map<String, dynamic> map) {
    return Holerite(
      id: map['id'] ?? '',
      competencia: map['competencia'] ?? '',
      mes: map['mes'] ?? 1,
      ano: map['ano'] ?? DateTime.now().year,
      salarioBruto: _toDouble(map['salario_bruto']),
      totalDescontos: _toDouble(map['total_descontos']),
      salarioLiquido: _toDouble(map['salario_liquido']),
      inss: _toDouble(map['inss']),
      irrf: _toDouble(map['irrf']),
      fgts: _toDouble(map['fgts']),
      pdfUrl: map['pdf_url'],
      pdfPath: map['pdf_path'],
      baixado: map['baixado'] ?? false,
      dataBaixado: map['data_baixado'] != null
          ? DateTime.tryParse(map['data_baixado'])
          : null,
    );
  }

  String get nomeArquivo => 'holerite_${ano}_${mes.toString().padLeft(2, '0')}.pdf';
}

class Desconto {
  final String descricao;
  final double valor;

  Desconto({required this.descricao, required this.valor});

  factory Desconto.fromJson(Map<String, dynamic> json) {
    return Desconto(
      descricao: json['descricao'] ?? json['nome'] ?? '',
      valor: Holerite._toDouble(json['valor']),
    );
  }
}

class Provento {
  final String descricao;
  final double valor;

  Provento({required this.descricao, required this.valor});

  factory Provento.fromJson(Map<String, dynamic> json) {
    return Provento(
      descricao: json['descricao'] ?? json['nome'] ?? '',
      valor: Holerite._toDouble(json['valor']),
    );
  }
}

class UserInfo {
  final String nome;
  final String matricula;
  final String cargo;
  final String orgao;
  final String? fotoUrl;

  UserInfo({
    required this.nome,
    required this.matricula,
    required this.cargo,
    required this.orgao,
    this.fotoUrl,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      nome: json['nome'] ?? json['name'] ?? '',
      matricula: json['matricula'] ?? json['registro'] ?? '',
      cargo: json['cargo'] ?? json['funcao'] ?? '',
      orgao: json['orgao'] ?? json['empresa'] ?? json['secretaria'] ?? '',
      fotoUrl: json['foto'] ?? json['avatar'],
    );
  }

  Map<String, dynamic> toMap() => {
    'nome': nome,
    'matricula': matricula,
    'cargo': cargo,
    'orgao': orgao,
    'foto': fotoUrl,
  };
}
