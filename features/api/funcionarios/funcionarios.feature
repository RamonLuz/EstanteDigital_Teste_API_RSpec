# language: pt
Funcionalidade: Gerenciamento de funcionários
  Para consultar e manter funcionários
  Como consumidor da API
  Quero validar o ciclo de vida e as regras de funcionários

  @smoke @mutating
  Cenário: CT012 - Cadastrar um funcionário
    Quando envio uma requisição POST para "/employees" com o payload "funcionarios/payloads/create-employee.json"
    Então o status HTTP deve ser 201
    E o campo JSON "id" deve ser um numero positivo
    E o campo JSON "registrationNumber" deve ser igual a "${registration}"

  @smoke @mutating
  Cenário: CT013 - Consultar funcionário cadastrado por identificador
    Quando envio uma requisição POST para "/employees" com o payload "funcionarios/payloads/create-employee.json"
    Então o status HTTP deve ser 201
    Quando envio uma requisição GET para "/employees/${id}"
    Então o status HTTP deve ser 200
    E o campo JSON "registrationNumber" deve ser igual a "${registration}"

  @smoke @mutating
  Cenário: CT014 - Listar funcionários cadastrados
    Quando envio uma requisição POST para "/employees" com o payload "funcionarios/payloads/create-employee.json"
    Então o status HTTP deve ser 201
    Quando envio uma requisição GET para "/employees"
    Então o status HTTP deve ser 200
    E a lista JSON deve conter "Funcionário QA ${unique}" no campo "name"

  @smoke @mutating
  Cenário: CT015 - Atualizar o status de um funcionário
    Quando envio uma requisição POST para "/employees" com o payload "funcionarios/payloads/create-employee.json"
    Então o status HTTP deve ser 201
    Quando envio uma requisição PUT para "/employees/${id}" com o payload "funcionarios/payloads/update-employee.json"
    Então o status HTTP deve ser 200
    E o campo JSON "status" deve ser igual a "INACTIVE"
    Quando envio uma requisição GET para "/employees/${id}"
    Então o status HTTP deve ser 200
    E o campo JSON "status" deve ser igual a "INACTIVE"

  @smoke @mutating
  Cenário: CT016 - Excluir funcionário cadastrado
    Quando envio uma requisição POST para "/employees" com o payload "funcionarios/payloads/create-employee.json"
    Então o status HTTP deve ser 201
    Quando envio uma requisição DELETE para "/employees/${id}"
    Então o status HTTP deve ser 204
    Quando envio uma requisição GET para "/employees/${id}"
    Então o status HTTP deve ser 404

  @regression
  Esquema do Cenário: Rejeitar funcionário com campo obrigatório inválido, nulo ou ausente
    Quando envio uma requisição POST para "/employees" com o payload "funcionarios/payloads/create-employee.json" e altero o campo "<campo>" para "<mutacao>"
    Então o status HTTP deve ser 400

    Exemplos:
      | campo              | mutacao    |
      | name               | blank      |
      | name               | whitespace |
      | name               | null       |
      | name               | missing    |
      | cpf                | blank      |
      | cpf                | invalid-cpf|
      | cpf                | null       |
      | cpf                | missing    |
      | registrationNumber | zero       |
      | registrationNumber | null       |
      | registrationNumber | missing    |
      | registrationNumber | wrong-type |
      | position           | blank      |
      | position           | whitespace |
      | position           | null       |
      | position           | missing    |
      | status             | blank      |
      | status             | whitespace |
      | status             | null       |
      | status             | missing    |

  @regression @mutating
  Cenário: Rejeitar atualização de funcionário com status obrigatório inválido
    Quando envio uma requisição POST para "/employees" com o payload "funcionarios/payloads/create-employee.json"
    Então o status HTTP deve ser 201
    Quando envio uma requisição PUT para "/employees/${id}" com o payload "funcionarios/payloads/update-employee.json" e altero o campo "status" para "blank"
    Então o status HTTP deve ser 400

  @regression
  Esquema do Cenário: Informar identificador numérico inexistente para funcionários
    Quando envio uma requisição GET para "<rota>"
    Então o status HTTP deve ser 404

    Exemplos:
      | rota                   |
      | /employees/0           |
      | /employees/999999999   |

  @regression
  Cenário: Rejeitar identificador de funcionário não numérico na consulta
    Quando envio uma requisição GET para "/employees/nao-numerico"
    Então o status HTTP deve ser 400
    E o campo JSON "message" deve ser igual a "ID must be numeric"

  @regression
  Cenário: Rejeitar cadastro de funcionário sem corpo
    Quando envio uma requisição POST para "/employees"
    Então o status HTTP deve ser 400
    E o campo JSON "message" deve ser igual a "Request body is required"

  @regression
  Cenário: Rejeitar atualização de funcionário sem corpo
    Quando envio uma requisição PUT para "/employees/1"
    Então o status HTTP deve ser 400
    E o campo JSON "message" deve ser igual a "Request body is required"

  @regression
  Cenário: Rejeitar atualização de funcionário inexistente
    Quando envio uma requisição PUT para "/employees/999999999" com o payload "funcionarios/payloads/update-employee.json"
    Então o status HTTP deve ser 404

  @regression
  Cenário: Rejeitar exclusão de funcionário inexistente
    Quando envio uma requisição DELETE para "/employees/999999999"
    Então o status HTTP deve ser 404

  @regression
  Cenário: Rejeitar identificador não numérico na atualização de funcionário
    Quando envio uma requisição PUT para "/employees/invalido" com o payload "funcionarios/payloads/update-employee.json"
    Então o status HTTP deve ser 400
    E o campo JSON "message" deve ser igual a "ID must be numeric"

  @regression
  Cenário: Rejeitar identificador não numérico na exclusão de funcionário
    Quando envio uma requisição DELETE para "/employees/invalido"
    Então o status HTTP deve ser 400
    E o campo JSON "message" deve ser igual a "ID must be numeric"
