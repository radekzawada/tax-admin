FactoryBot.define do
  factory :messages_package_dispatch do
    status { MessagesPackageDispatch::STATUSES.sample }
    association :messages_package
    association :data_loaded_by, factory: :user
    association :dispatched_by, factory: :user
  end
end
