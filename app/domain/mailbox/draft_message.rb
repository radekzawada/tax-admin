class Mailbox::DraftMessage < Dry::Struct
  attribute :id, Types::UUID.default { SecureRandom.uuid }
  attribute :index, Types::Integer
  attribute :variables, Types::Hash.constructor { |hash| hash.transform_keys(&:to_sym) }
  attribute :errors, Types::Hash.default { {} }
end
