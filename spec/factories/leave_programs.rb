FactoryGirl.define do
  factory :leave_program do
    properties { {"e-mail"=>"cif@cambodianfamily.com", "age"=>"3", "description"=>"this is testing"}.to_json }
    association :client_enrollment
    association :program_stream
  end
end