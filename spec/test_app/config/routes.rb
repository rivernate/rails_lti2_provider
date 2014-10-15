Rails.application.routes.draw do
  mount RailsLti2Provider::Engine => "/rails_lti2_provider"
end
