# Testes QA da API EstanteDigital

Projeto de testes de integração HTTP em Ruby com RSpec, Cucumber e HTTParty para a
API localizada em `C:\Projeto\EstanteDigital\APIs`.

## Escopo da API coberta

A suíte é limitada às cinco classes de controller presentes nessa API:

| Recurso | Endpoints cobertos |
|---|---|
| Saúde | `GET /health` |
| Livros | `GET /books`, `GET /books/{id}`, `POST /books`, `PUT /books/{id}`, `DELETE /books/{id}` |
| Clientes | `GET /customers`, `GET /customers/{id}`, `POST /customers`, `PUT /customers/{id}`, `DELETE /customers/{id}` |
| Funcionários | `GET /employees`, `GET /employees/{id}`, `POST /employees`, `PUT /employees/{id}`, `DELETE /employees/{id}` |
| Vendas | `GET /sales`, `GET /sales/{id}`, `POST /sales` |

As features Cucumber estão em português e organizadas por recurso em
`features/api/<recurso>/`, com um diretório próprio para saúde, livros, clientes,
funcionários e vendas. Cada arquivo de feature contém as validações daquele recurso
e mantém os cenários `@smoke` e `@regression` identificados por códigos sequenciais
`CT001` a `CT017`. Os payloads versionados ficam em
`features/api/<recurso>/payloads/`; os cenários verificam operações válidas de CRUD, campos
obrigatórios, tipos, identificadores ausentes ou inválidos e dependências de venda.
As respostas HTTP são verificadas automaticamente contra os contratos JSON em
`spec/contracts/`, tanto no Cucumber quanto nos requests de integração RSpec.

Não há cenários para catálogo público, filiais, autenticação, pagamentos,
empréstimos ou outros recursos ausentes da API EstanteDigital.

## Pré-requisitos e instalação

- Ruby 3.2 ou superior
- Bundler
- API EstanteDigital em execução na porta 8080

```powershell
bundle install
Copy-Item .env.example .env
```

`API_BASE_URL` é `http://localhost:8080` por padrão. Ajuste `.env` se a API estiver
em outro endereço.

## Execução

Inicie a API na pasta `C:\Projeto\EstanteDigital\APIs`:

```powershell
.\mvnw.cmd spring-boot:run
```

Na pasta deste projeto de testes:

```powershell
# Specs de integração RSpec
$env:API_TESTS = "true"
bundle exec rspec spec/api
Remove-Item Env:API_TESTS

# Features Cucumber em português
bundle exec cucumber

# Cenários Cucumber que criam, atualizam ou removem registros
$env:API_ALLOW_MUTATIONS = "true"
bundle exec cucumber --profile mutating
Remove-Item Env:API_ALLOW_MUTATIONS

# Testes unitários dos componentes de suporte
bundle exec rspec spec/unit
```

Os specs que criam livros, clientes ou funcionários são opt-in. Eles também exigem
`API_ALLOW_MUTATIONS=true`, limpam os registros criados após o teste e devem ser
executados apenas contra uma base descartável:

```powershell
$env:API_TESTS = "true"
$env:API_ALLOW_MUTATIONS = "true"
bundle exec rspec spec/api
Remove-Item Env:API_ALLOW_MUTATIONS
Remove-Item Env:API_TESTS
```

O perfil Cucumber padrão exclui os cenários marcados `@mutating`. O perfil
`mutating` exige explicitamente `API_ALLOW_MUTATIONS=true` e limpa os livros,
clientes e funcionários criados pelos cenários, exceto quando marcado para
preservar dados. A venda de sucesso (`CT017`) não pode ser removida porque a API
não oferece `DELETE /sales`; esse cenário é marcado `@preserve_data` e deixa os
registros relacionados persistidos. Execute-o somente em uma base descartável.

## Organização

### Caminho recomendado para estudar

1. Comece por `features/api/saude/saude.feature`: é o cenário mais curto e não
   altera dados.
2. Leia uma feature de recurso, como
   `features/api/livros/livros.feature`, e veja como o Gherkin descreve a chamada
   e as verificações sem implementar detalhes HTTP.
3. Abra `features/step_definitions/common/api_steps.rb` para entender como cada
   passo da feature é ligado a código Ruby.
4. Acompanhe a requisição em `features/support/api_step_helpers.rb`,
   `config/environment.rb` e `lib/estante_digital_api/`.
5. Compare com `spec/api/health/health_spec.rb` e depois com os demais specs para
   ver a mesma API validada diretamente com RSpec.

O fluxo do Cucumber é:

```text
Feature Gherkin -> Step definition -> helper de cenário
                -> configuração -> cliente HTTP -> API
                                      |
                                      +-> contrato JSON
```

As **features Cucumber** são cenários de aceitação escritos em português. Os
**specs RSpec em `spec/api/`** fazem testes de integração HTTP. Os testes em
`spec/unit/` verificam os componentes Ruby deste framework (cliente, configuração
e validador), não regras internas da aplicação EstanteDigital.

### Mapa de pastas

```text
config/
  environment.rb                # disponibiliza configuração e cliente da API
features/
  api/
    livros/                     # feature e payloads de livros
    clientes/                   # feature e payloads de clientes
    funcionarios/               # feature e payloads de funcionários
    vendas/                     # feature e payloads de vendas
    saude/                      # feature de disponibilidade
  step_definitions/
    common/api_steps.rb         # transforma passos Gherkin em chamadas do helper
  support/
    env.rb                      # carrega dependências e registra o contexto Cucumber
    hooks.rb                    # prepara cenários e protege operações mutáveis
    api_step_helpers.rb         # envia requisições, resolve dados e confere respostas
lib/
  estante_digital_api.rb        # ponto de entrada da biblioteca interna
  estante_digital_api/
    configuration.rb            # lê e valida URL e timeout
    http_client.rb               # envia chamadas HTTP com HTTParty
    response_contract_validator.rb # seleciona e aplica contrato JSON por resposta
spec/
  api/
    books/                      # specs de integração HTTP para livros
    customers/                  # specs de integração HTTP para clientes
    employees/                  # specs de integração HTTP para funcionários
    health/                     # spec de integração HTTP para saúde
    sales/                      # specs de integração HTTP para vendas
  contracts/                    # schemas de resposta por recurso/operação
  support/
    api_test_base.rb            # métodos compartilhados pelos specs de API
    request_data.rb             # dados de requisição reutilizáveis no RSpec
  spec_helper.rb                # carrega bibliotecas e configura filtros do RSpec
  unit/
    estante_digital_api/        # specs unitários da biblioteca de suporte
```

Os arquivos na raiz configuram as ferramentas: `Gemfile` lista dependências,
`.rspec` define opções padrão do RSpec, `cucumber.yml` define perfis do Cucumber,
`.rubocop.yml` registra as convenções Ruby e `.env.example` mostra as opções de
ambiente sem incluir segredos. A documentação fica em `README.md` e a automação
de CI em `.github/workflows/`.

## Convenções Ruby

O RuboCop é executado na CI (`bundle exec rubocop`) e verifica sintaxe, indentação
com dois espaços, ausência de tabs/espaços finais e limite de 80 caracteres por
linha. O limite segue a recomendação do [Ruby Style Guide](https://rubystyle.guide/).
Os arquivos Ruby são mantidos em UTF-8 com finais de linha LF. Execute a mesma
checagem localmente após instalar as dependências:

```powershell
bundle exec rubocop
```
