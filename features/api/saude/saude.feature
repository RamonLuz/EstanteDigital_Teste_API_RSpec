# language: pt
Funcionalidade: Disponibilidade da API
  Para verificar se o serviço está disponível
  Como equipe de QA
  Quero validar o endpoint de saúde

  @smoke
  Cenário: CT001 - Consultar o estado da aplicação
    Quando envio uma requisição GET para "/health"
    Então o status HTTP deve ser 200
    E o campo JSON "status" deve ser igual a "UP"
    E o campo JSON "application" deve ser igual a "estantedigital"
