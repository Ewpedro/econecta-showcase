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

  Holerite({required this.id, required this.competencia, required this.mes, required this.ano, required this.salarioBruto, required this.totalDescontos, required this.salarioLiquido, required this.inss, required this.irrf, required this.fgts, this.outrosDescontos = const [], this.outrosProventos = const [], this.pdfUrl, this.pdfPath, this.baixado = false, this.dataBaixado});

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
      outrosDescontos: (json['descontos_lista'] as List<dynamic>? ?? []).map((e) => Desconto.fromJson(e)).toList(),
      outrosProventos: (json['proventos_lista'] as List<dynamic>? ?? []).map((e) => Provento.fromJson(e)).toList(),
      pdfUrl: json['pdf_url'] ?? json['url_pdf'] ?? json['link'],
    );
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v.replaceAll(',', '.')) ?? 0.0;
    return 0.0;
  }

  Holerite copyWith({String? pdfPath, bool? baixado, DateTime? dataBaixado}) => Holerite(id: id, competencia: competencia, mes: mes, ano: ano, salarioBruto: salarioBruto, totalDescontos: totalDescontos, salarioLiquido: salarioLiquido, inss: inss, irrf: irrf, fgts: fgts, outrosDescontos: outrosDescontos, outrosProventos: outrosProventos, pdfUrl: pdfUrl, pdfPath: pdfPath ?? this.pdfPath, baixado: baixado ?? this.baixado, dataBaixado: dataBaixado ?? this.dataBaixado);

  Map<String, dynamic> toMap() => {'id': id, 'competencia': competencia, 'mes': mes, 'ano': ano, 'salario_bruto': salarioBruto, 'total_descontos': totalDescontos, 'salario_liquido': salarioLiquido, 'inss': inss, 'irrf': irrf, 'fgts': fgts, 'pdf_url': pdfUrl, 'pdf_path': pdfPath, 'baixado': baixado, 'data_baixado': dataBaixado?.toIso8601String()};

  factory Holerite.fromMap(Map<String, dynamic> m) => Holerite(id: m['id'] ?? '', competencia: m['competencia'] ?? '', mes: m['mes'] ?? 1, ano: m['ano'] ?? DateTime.now().year, salarioBruto: _toDouble(m['salario_bruto']), totalDescontos: _toDouble(m['total_descontos']), salarioLiquido: _toDouble(m['salario_liquido']), inss: _toDouble(m['inss']), irrf: _toDouble(m['irrf']), fgts: _toDouble(m['fgts']), pdfUrl: m['pdf_url'], pdfPath: m['pdf_path'], baixado: m['baixado'] ?? false, dataBaixado: m['data_baixado'] != null ? DateTime.tryParse(m['data_baixado']) : null);

  String get nomeArquivo => 'holerite_${ano}_${mes.toString().padLeft(2, '0')}.pdf';
}

class Desconto { final String descricao; final double valor; Desconto({required this.descricao, required this.valor}); factory Desconto.fromJson(Map<String, dynamic> j) => Desconto(descricao: j['descricao'] ?? j['nome'] ?? '', valor: Holerite._toDouble(j['valor'])); }
class Provento { final String descricao; final double valor; Provento({required this.descricao, required this.valor}); factory Provento.fromJson(Map<String, dynamic> j) => Provento(descricao: j['descricao'] ?? j['nome'] ?? '', valor: Holerite._toDouble(j['valor'])); }

class UserInfo {
  final String nome, matricula, cargo, orgao;
  final String? fotoUrl;
  UserInfo({required this.nome, required this.matricula, required this.cargo, required this.orgao, this.fotoUrl});
  factory UserInfo.fromJson(Map<String, dynamic> j) => UserInfo(nome: j['nome'] ?? j['name'] ?? '', matricula: j['matricula'] ?? j['registro'] ?? '', cargo: j['cargo'] ?? j['funcao'] ?? '', orgao: j['orgao'] ?? j['empresa'] ?? j['secretaria'] ?? '', fotoUrl: j['foto'] ?? j['avatar']);
  Map<String, dynamic> toMap() => {'nome': nome, 'matricula': matricula, 'cargo': cargo, 'orgao': orgao, 'foto': fotoUrl};
}
