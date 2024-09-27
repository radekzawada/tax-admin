class Command::Result
  extend Dry::Initializer
  include Dry::Monads[:result]

  option :component, type: Types::Symbol.constrained(included_in: %i[command contract])
  option :errors, type: Types::Hash, default: proc { {} }
  option :data, type: Types::Hash, default: proc { {} }

  def success?
    errors.empty?
  end

  def failure?
    !success?
  end

  def to_monad
    success? ? Success(data) : Failure(errors)
  end
end
