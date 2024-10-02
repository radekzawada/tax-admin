Dry::Schema.load_extensions(:monads)
Dry::Validation.load_extensions(:monads)

Dry::Types::PredicateInferrer::Compiler.infer_predicate_by_class_name true
Dry::Schema::PredicateInferrer::Compiler.infer_predicate_by_class_name true
Dry::Validation::Contract.config.messages.backend = :i18n

require "dry/monads/do"
require "dry/schema/dsl"
require "dry/schema/version"
require "dry/schema/message"
require "dry/schema/messages"

if Dry::Schema::Message::Or::SinglePath.method_defined?(:text)
  raise "Check if it is still needed in dry-schema " \
    "#{Dry::Schema::VERSION}"
end

# Bug fixes required for correct behaviour of our code.
Dry::Schema::Message::Or::SinglePath.class_eval do
  alias_method :text, :dump

  def meta
    {}
  end
end

module Types
  include Dry.Types()
end