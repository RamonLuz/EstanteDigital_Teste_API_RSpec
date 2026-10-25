module RequestData
  module_function

  def book
    {
      title: "QA Book #{SecureRandom.hex(6)}",
      author: "EstanteDigital QA",
      price: 19.90
    }
  end

  def customer
    {
      name: "QA Customer #{SecureRandom.hex(4)}",
      cpf: random_digits(11),
      status: "ACTIVE"
    }
  end

  def employee
    {
      name: "QA Employee #{SecureRandom.hex(4)}",
      cpf: random_digits(11),
      registrationNumber: SecureRandom.random_number(900_000) + 100_000,
      position: "QA",
      status: "ACTIVE"
    }
  end

  def random_digits(length)
    Array.new(length) { SecureRandom.random_number(10) }.join
  end
end
