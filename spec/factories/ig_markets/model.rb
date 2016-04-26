FactoryGirl.define do
  factory :model do
    transient { dealing_platform nil }

    # Models that have Time attributes specified with a :time_zone Proc as an option need their @dealing_platform
    # instance variable set prior to assigning their attributes
    initialize_with do
      new.tap do |instance|
        instance.instance_variable_set :@dealing_platform, dealing_platform
        instance.send :initialize, attributes
      end
    end
  end
end
