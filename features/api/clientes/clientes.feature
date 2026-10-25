# language: pt
Funcionalidade: Gerenciamento de clientes
  Para consultar e manter clientes
  Como consumidor da API
  Quero validar o ciclo de vida e as regras de clientes

  @smoke @mutating
  Cenário: CT007 - Cadastrar um cliente
    Quando envio uma requisição POST para "/customers" com o payload "clientes/payloads/create-customer.json"
    Então o status HTTP deve ser 201
    E o campo JSON "id" deve ser um numero positivo
    E o campo JSON "cpf" deve ser igual a "${unique}"

  @smoke @mutating
  Cenário: CT008 - Consultar cliente cadastrado por identificador
    Quando envio uma requisição POST para "/customers" com o payload "clientes/payloads/create-customer.json"
    Então o status HTTP deve ser 201
    Quando envio uma requisição GET para "/customers/${id}"
    Então o status HTTP deve ser 200
    E o campo JSON "cpf" deve ser igual a "${unique}"

  @smoke @mutating
  Cenário: CT009 - Listar clientes cadastrados
    Quando envio uma requisição POST para "/customers" com o payload "clientes/payloads/create-customer.json"
    Então o status HTTP deve ser 201
    Quando envio uma requisição GET para "/customers"
    Então o status HTTP deve ser 200
    E a lista JSON deve conter "Cliente QA ${unique}" no campo "name"

  @smoke @mutating
  Cenário: CT010 - Atualizar o status de um cliente
    Quando envio uma requisição POST para "/customers" com o payload "clientes/payloads/create-customer.json"
    Então o status HTTP deve ser 201
    Quando envio uma requisição PUT para "/customers/${id}" com o payload "clientes/payloads/update-customer.json"
    Então o status HTTP deve ser 200
    E o campo JSON "status" deve ser igual a "INACTIVE"
    Quando envio uma requisição GET para "/customers/${id}"
    Então o status HTTP deve ser 200
    E o campo JSON "status" deve ser igual a "INACTIVE"

  @smoke @mutating
  Cenário: CT011 - Excluir cliente cadastrado
    Quando envio uma requisição POST para "/customers" com o payload "clientes/payloads/create-customer.json"
    Então o status HTTP deve ser 201
    Quando envio uma requisição DELETE para "/customers/${id}"
    Então o status HTTP deve ser 204
    Quando envio uma requisição GET para "/customers/${id}"
    Então o status HTTP deve ser 404

  @regression
  Esquema do Cenário: Rejeitar cliente com campo obrigatório inválido, nulo ou ausente
    Quando envio uma requisição POST para "/customers" com o payload "clientes/payloads/create-customer.json" e altero o campo "<campo>" para "<mutacao>"
    Então o status HTTP deve ser 400

    Exemplos:
      | campo  | mutacao    |
      | name   | blank      |
      | name   | whitespace |
      | name   | null       |
      | name   | missing    |
      | cpf    | blank      |
      | cpf    | invalid-cpf|
      | cpf    | null       |
      | cpf    | missing    |
      | status | blank      |
      | status | whitespace |
      | status | null       |
      | status | missing    |

  @regression @mutating
  Cenário: Rejeitar cadastro com CPF já registrado
    Quando envio uma requisição POST para "/customers" com o payload "clientes/payloads/create-customer.json"
    Então o status HTTP deve ser 201
    Quando envio uma requisição POST para "/customers" com o payload "clientes/payloads/create-customer.json"
    Então o status HTTP deve ser 400
    E o campo JSON "message" deve ser igual a "CPF already registered"

  @regression @mutating
  Esquema do Cenário: Aceitar compras opcionais quando ausentes, nulas ou vazias
    Quando envio uma requisição POST para "/customers" com o payload "clientes/payloads/create-customer-with-purchases.json" e altero o campo "purchases" para "<mutacao>"
    Então o status HTTP deve ser 201

    Exemplos:
      | mutacao    |
      | empty-array|
      | null       |
      | missing    |

  @regression
  Cenário: Rejeitar compras com tipo inválido
    Quando envio uma requisição POST para "/customers" com o payload "clientes/payloads/create-customer-with-purchases.json" e altero o campo "purchases" para "wrong-type"
    Então o status HTTP deve ser 400

  @regression @mutating
  Cenário: Rejeitar atualização de cliente com status obrigatório inválido
    Quando envio uma requisição POST para "/customers" com o payload "clientes/payloads/create-customer.json"
    Então o status HTTP deve ser 201
    Quando envio uma requisição PUT para "/customers/${id}" com o payload "clientes/payloads/update-customer.json" e altero o campo "status" para "blank"
    Então o status HTTP deve ser 400

  @regression
  Esquema do Cenário: Informar identificador numérico inexistente para clientes
    Quando envio uma requisição GET para "<rota>"
    Então o status HTTP deve ser 404

    Exemplos:
      | rota                  |
      | /customers/0          |
      | /customers/999999999  |

  @regression
  Cenário: Rejeitar identificador de cliente não numérico na consulta
    Quando envio uma requisição GET para "/customers/nao-numerico"
    Então o status HTTP deve ser 400
    E o campo JSON "message" deve ser igual a "ID must be numeric"

  @regression
  Cenário: Rejeitar cadastro de cliente sem corpo
    Quando envio uma requisição POST para "/customers"
    Então o status HTTP deve ser 400
    E o campo JSON "message" deve ser igual a "Request body is required"

  @regression
  Cenário: Rejeitar atualização de cliente sem corpo
    Quando envio uma requisição PUT para "/customers/1"
    Então o status HTTP deve ser 400
    E o campo JSON "message" deve ser igual a "Request body is required"

  @regression
  Cenário: Rejeitar atualização de cliente inexistente
    Quando envio uma requisição PUT para "/customers/999999999" com o payload "clientes/payloads/update-customer.json"
    Então o status HTTP deve ser 404

  @regression
  Cenário: Rejeitar exclusão de cliente inexistente
    Quando envio uma requisição DELETE para "/customers/999999999"
    Então o status HTTP deve ser 404

  @regression
  Cenário: Rejeitar identificador não numérico na atualização de cliente
    Quando envio uma requisição PUT para "/customers/invalido" com o payload "clientes/payloads/update-customer.json"
    Então o status HTTP deve ser 400
    E o campo JSON "message" deve ser igual a "ID must be numeric"

  @regression
  Cenário: Rejeitar identificador não numérico na exclusão de cliente
    Quando envio uma requisição DELETE para "/customers/invalido"
    Então o status HTTP deve ser 400
    E o campo JSON "message" deve ser igual a "ID must be numeric"
