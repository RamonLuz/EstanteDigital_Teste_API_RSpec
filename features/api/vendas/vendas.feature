# language: pt
Funcionalidade: Registro e consulta de vendas
  Para registrar operações comerciais
  Como consumidor da API
  Quero validar os endpoints de vendas

  @smoke @mutating @preserve_data
  Cenário: CT017 - Registrar e consultar venda com entidades existentes
    Quando envio uma requisição POST para "/books" com o payload "vendas/payloads/create-sale-book.json"
    Então o status HTTP deve ser 201
    Quando envio uma requisição POST para "/customers" com o payload "vendas/payloads/create-sale-customer.json"
    Então o status HTTP deve ser 201
    Quando envio uma requisição POST para "/employees" com o payload "vendas/payloads/create-sale-employee.json"
    Então o status HTTP deve ser 201
    Quando envio uma requisição POST para "/sales" com o payload "vendas/payloads/create-sale.json"
    Então o status HTTP deve ser 201
    E o campo JSON "id" deve ser um numero positivo
    E o campo JSON "customer.cpf" deve ser igual a "${unique}"
    E o campo JSON "employee.registrationNumber" deve ser igual a "${registration}"
    E o campo JSON "book.title" deve ser igual a "Livro para venda ${unique}"
    Quando envio uma requisição GET para "/sales/${id}"
    Então o status HTTP deve ser 200
    E o campo JSON "book.title" deve ser igual a "Livro para venda ${unique}"
    Quando envio uma requisição GET para "/sales"
    Então o status HTTP deve ser 200
    E a lista JSON deve conter "Livro para venda ${unique}" no campo "book.title"

  @regression
  Esquema do Cenário: Rejeitar venda com campo obrigatório inválido, nulo ou ausente
    Quando envio uma requisição POST para "/sales" com o payload "vendas/payloads/create-sale.json" e altero o campo "<campo>" para "<mutacao>"
    Então o status HTTP deve ser 400

    Exemplos:
      | campo                      | mutacao     |
      | customerCpf                | blank       |
      | customerCpf                | whitespace  |
      | customerCpf                | null        |
      | customerCpf                | missing     |
      | employeeRegistrationNumber | zero        |
      | employeeRegistrationNumber | null        |
      | employeeRegistrationNumber | missing     |
      | employeeRegistrationNumber | wrong-type  |
      | bookTitle                  | blank       |
      | bookTitle                  | whitespace  |
      | bookTitle                  | null        |
      | bookTitle                  | missing     |
      | bookAuthor                 | blank       |
      | bookAuthor                 | whitespace  |
      | bookAuthor                 | null        |
      | bookAuthor                 | missing     |
      | saleDate                   | invalid-date|
      | saleDate                   | null        |
      | saleDate                   | missing     |

  @regression
  Cenário: Rejeitar venda sem cliente associado
    Quando envio uma requisição POST para "/sales" com o payload "vendas/payloads/create-sale.json"
    Então o status HTTP deve ser 400
    E o campo JSON "message" deve ser igual a "Customer does not exist"

  @regression @mutating
  Cenário: Rejeitar venda sem funcionário associado
    Quando envio uma requisição POST para "/books" com o payload "vendas/payloads/create-sale-book.json"
    Então o status HTTP deve ser 201
    Quando envio uma requisição POST para "/customers" com o payload "vendas/payloads/create-sale-customer.json"
    Então o status HTTP deve ser 201
    Quando envio uma requisição POST para "/sales" com o payload "vendas/payloads/create-sale.json"
    Então o status HTTP deve ser 400
    E o campo JSON "message" deve ser igual a "Employee does not exist"

  @regression @mutating
  Cenário: Rejeitar venda sem livro associado
    Quando envio uma requisição POST para "/customers" com o payload "vendas/payloads/create-sale-customer.json"
    Então o status HTTP deve ser 201
    Quando envio uma requisição POST para "/employees" com o payload "vendas/payloads/create-sale-employee.json"
    Então o status HTTP deve ser 201
    Quando envio uma requisição POST para "/sales" com o payload "vendas/payloads/create-sale.json"
    Então o status HTTP deve ser 400
    E o campo JSON "message" deve ser igual a "Book does not exist"

  @regression
  Esquema do Cenário: Informar identificador numérico inexistente para vendas
    Quando envio uma requisição GET para "<rota>"
    Então o status HTTP deve ser 404

    Exemplos:
      | rota              |
      | /sales/0          |
      | /sales/999999999  |

  @regression
  Cenário: Rejeitar identificador de venda não numérico na consulta
    Quando envio uma requisição GET para "/sales/nao-numerico"
    Então o status HTTP deve ser 400
    E o campo JSON "message" deve ser igual a "ID must be numeric"

  @regression
  Cenário: Rejeitar registro de venda sem corpo
    Quando envio uma requisição POST para "/sales"
    Então o status HTTP deve ser 400
    E o campo JSON "message" deve ser igual a "Request body is required"
