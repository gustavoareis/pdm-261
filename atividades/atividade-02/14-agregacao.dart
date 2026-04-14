// 14-agregacao.dart
// Agregação e Composição

import 'dart:convert';

class Dependente {
  late String _nome;

  Dependente(String nome) {
    this._nome = nome;
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': _nome,
    };
  }
}

class Funcionario {
  late String _nome;
  late List<Dependente> _dependentes;

  Funcionario(String nome, List<Dependente> dependentes) {
    this._nome = nome;
    this._dependentes = dependentes;
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': _nome,
      'dependentes': _dependentes.map((d) => d.toJson()).toList(),
    };
  }
}

class EquipeProjeto {
  late String _nomeProjeto;
  late List<Funcionario> _funcionarios;

  EquipeProjeto(String nomeprojeto, List<Funcionario> funcionarios) {
    _nomeProjeto = nomeprojeto;
    _funcionarios = funcionarios;
  }

  Map<String, dynamic> toJson() {
    return {
      'nomeProjeto': _nomeProjeto,
      'funcionarios': _funcionarios.map((f) => f.toJson()).toList(),
    };
  }
}

void main() {
  // 1. Criar varios objetos Dependentes
  Dependente dep1 = Dependente('Ana Lima');
  Dependente dep2 = Dependente('Carlos Lima');
  Dependente dep3 = Dependente('Beatriz Souza');
  Dependente dep4 = Dependente('Pedro Souza');
  Dependente dep5 = Dependente('Mariana Costa');

  // 2. Criar varios objetos Funcionario e
  // 3. Associar os Dependentes criados aos respectivos funcionarios
  Funcionario func1 = Funcionario('João Lima', [dep1, dep2]);
  Funcionario func2 = Funcionario('Maria Souza', [dep3, dep4]);
  Funcionario func3 = Funcionario('Paulo Costa', [dep5]);

  // 4. Criar uma lista de Funcionarios
  List<Funcionario> funcionarios = [func1, func2, func3];

  // 5. Criar um objeto EquipeProjeto com nome do projeto e lista de funcionarios
  EquipeProjeto equipe = EquipeProjeto('Projeto App Mobile', funcionarios);

  // 6. Printar no formato JSON o objeto EquipeProjeto
  String json = JsonEncoder.withIndent('  ').convert(equipe.toJson());
  print(json);
}
