class SubscriptionsController < ApplicationController
  def index
    @subscriptions = Subscription.includes(:customer).all
  end
end
