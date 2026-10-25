# language: pt
Funcionalidade: Gerenciamento de livros
  Para consultar e manter o catálogo
  Como consumidor da API
  Quero validar o ciclo de vida e as regras de livros

  @smoke @mutating
  Cenário: CT002 - Cadastrar um livro
    Quando envio uma requisição POST para "/books" com o payload "livros/payloads/create-book.json"
    Então o status HTTP deve ser 201
    E o campo JSON "id" deve ser um numero positivo
    E o campo JSON "title" deve ser igual a "Livro QA ${unique}"

  @smoke @mutating
  Cenário: CT003 - Consultar livro cadastrado por identificador
    Quando envio uma requisição POST para "/books" com o payload "livros/payloads/create-book.json"
    Então o status HTTP deve ser 201
    Quando envio uma requisição GET para "/books/${id}"
    Então o status HTTP deve ser 200
    E o campo JSON "title" deve ser igual a "Livro QA ${unique}"
    E o campo JSON "author" deve ser igual a "Autor QA"

  @smoke @mutating
  Cenário: CT004 - Listar livros cadastrados
    Quando envio uma requisição POST para "/books" com o payload "livros/payloads/create-book.json"
    Então o status HTTP deve ser 201
    Quando envio uma requisição GET para "/books"
    Então o status HTTP deve ser 200
    E a lista JSON deve conter "Livro QA ${unique}" no campo "title"

  @smoke @mutating
  Cenário: CT005 - Atualizar livro cadastrado
    Quando envio uma requisição POST para "/books" com o payload "livros/payloads/create-book.json"
    Então o status HTTP deve ser 201
    Quando envio uma requisição PUT para "/books/${id}" com o payload "livros/payloads/update-book.json"
    Então o status HTTP deve ser 200
    E o campo JSON "title" deve ser igual a "Livro QA atualizado ${unique}"
    Quando envio uma requisição GET para "/books/${id}"
    Então o status HTTP deve ser 200
    E o campo JSON "author" deve ser igual a "Autor QA atualizado"

  @smoke @mutating
  Cenário: CT006 - Excluir livro cadastrado
    Quando envio uma requisição POST para "/books" com o payload "livros/payloads/create-book.json"
    Então o status HTTP deve ser 201
    Quando envio uma requisição DELETE para "/books/${id}"
    Então o status HTTP deve ser 204
    Quando envio uma requisição GET para "/books/${id}"
    Então o status HTTP deve ser 404

  @regression
  Cenário: Rejeitar livro com preço inválido
    Quando envio uma requisição POST para "/books" com o payload "livros/payloads/invalid-book.json"
    Então o status HTTP deve ser 400
    E o campo JSON "message" deve ser igual a "Required fields were not provided"

  @regression @mutating
  Cenário: Rejeitar cadastro duplicado pelo título e autor
    Quando envio uma requisição POST para "/books" com o payload "livros/payloads/create-book.json"
    Então o status HTTP deve ser 201
    Quando envio uma requisição POST para "/books" com o payload "livros/payloads/create-book.json"
    Então o status HTTP deve ser 400
    E o campo JSON "message" deve ser igual a "Book already exists for this author and title"

  @regression
  Esquema do Cenário: Rejeitar livro com campo obrigatório inválido, nulo ou ausente
    Quando envio uma requisição POST para "/books" com o payload "livros/payloads/create-book.json" e altero o campo "<campo>" para "<mutacao>"
    Então o status HTTP deve ser 400

    Exemplos:
      | campo  | mutacao    |
      | title  | blank      |
      | title  | whitespace |
      | title  | null       |
      | title  | missing    |
      | author | blank      |
      | author | whitespace |
      | author | null       |
      | author | missing    |
      | price  | zero       |
      | price  | negative   |
      | price  | null       |
      | price  | missing    |
      | price  | wrong-type |

  @regression @mutating
  Cenário: Rejeitar atualização de livro com preço inválido
    Quando envio uma requisição POST para "/books" com o payload "livros/payloads/create-book.json"
    Então o status HTTP deve ser 201
    Quando envio uma requisição PUT para "/books/${id}" com o payload "livros/payloads/update-book.json" e altero o campo "price" para "zero"
    Então o status HTTP deve ser 400

  @regression
  Esquema do Cenário: Informar identificador numérico inexistente para livros
    Quando envio uma requisição GET para "<rota>"
    Então o status HTTP deve ser 404

    Exemplos:
      | rota                |
      | /books/0            |
      | /books/999999999    |

  @regression
  Cenário: Rejeitar identificador de livro não numérico na consulta
    Quando envio uma requisição GET para "/books/nao-numerico"
    Então o status HTTP deve ser 400
    E o campo JSON "message" deve ser igual a "ID must be numeric"

  @regression
  Cenário: Rejeitar cadastro de livro sem corpo
    Quando envio uma requisição POST para "/books"
    Então o status HTTP deve ser 400
    E o campo JSON "message" deve ser igual a "Request body is required"

  @regression
  Cenário: Rejeitar atualização de livro sem corpo
    Quando envio uma requisição PUT para "/books/1"
    Então o status HTTP deve ser 400
    E o campo JSON "message" deve ser igual a "Request body is required"

  @regression
  Cenário: Rejeitar atualização de livro inexistente
    Quando envio uma requisição PUT para "/books/999999999" com o payload "livros/payloads/update-book.json"
    Então o status HTTP deve ser 404

  @regression
  Cenário: Rejeitar exclusão de livro inexistente
    Quando envio uma requisição DELETE para "/books/999999999"
    Então o status HTTP deve ser 404

  @regression
  Cenário: Rejeitar identificador não numérico na atualização de livro
    Quando envio uma requisição PUT para "/books/invalido" com o payload "livros/payloads/update-book.json"
    Então o status HTTP deve ser 400
    E o campo JSON "message" deve ser igual a "ID must be numeric"

  @regression
  Cenário: Rejeitar identificador não numérico na exclusão de livro
    Quando envio uma requisição DELETE para "/books/invalido"
    Então o status HTTP deve ser 400
    E o campo JSON "message" deve ser igual a "ID must be numeric"
