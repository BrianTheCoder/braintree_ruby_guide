require 'rubygems'
require 'sinatra'
require 'braintree'

Braintree::Configuration.environment = :sandbox
Braintree::Configuration.merchant_id = "use_your_merchant_id"
Braintree::Configuration.public_key = "use_your_public_key"
Braintree::Configuration.private_key = "use_your_private_key"

get "/" do
  erb :form
end

post '/create_customer' do
  result = Braintree::Customer.create(
    :first_name => params[:first_name],
    :last_name => params[:last_name],
    :credit_card => {
      :billing_address => {
        :postal_code => params[:postal_code]
      },
      :number => params[:number],
      :expiration_month => params[:month],
      :expiration_year => params[:year],
      :cvv => params[:cvv]
    }
  )

  erb :response, :locals => { :result => result }
end

get "/subscriptions" do
  customer_id = request.params["id"]
  customer = Braintree::Customer.find(customer_id)
  payment_method_token = customer.credit_cards[0].token

  result = Braintree::Subscription.create(
    :payment_method_token => payment_method_token,
    :plan_id => "test_plan_1"
  )

  erb :subscriptions, :locals => { :result => result }
end

get "/webhooks" do
  challenge = request.params["bt_challenge"]
  challenge_response = Braintree::WebhookNotification.verify(challenge)
  return [200, challenge_response]
end

post "/webhooks" do
  webhook_notification = Braintree::WebhookNotification.parse(
    request.params["bt_signature"],
    request.params["bt_payload"]
  )
  puts "[Webhook Received #{webhook_notification.timestamp}] Kind: #{webhook_notification.kind} | Subscription: #{webhook_notification.subscription.id}"
  return 200
end
