require 'sinatra'
require 'braintree'
require 'shotgun'

Braintree::Configuration.environment = :sandbox
Braintree::Configuration.merchant_id = "5yhyd43d5sws9378"
Braintree::Configuration.public_key = "tcrgrwbgvz974cjx"
Braintree::Configuration.private_key = "mrx3rh84sfktfjhb"

get "/" do
  tr_data = Braintree::TransparentRedirect.create_customer_data(
    :redirect_url => "http://localhost:9393/braintree"
    )

  erb :form, :locals => {:tr_data => tr_data}
end

get "/braintree" do
  result = Braintree::TransparentRedirect.confirm(request.query_string)

  customer_id = nil
  if result.success?
    message = "Customer Created with the email: #{result.customer.email}"
    customer_id = result.customer.id
  else
    message = "Message: #{result.message}"
  end

  erb :response, :locals => { :message => message,
                              :customer_id => customer_id }
end

get "/subscriptions" do
  customer_id = request.params["id"]
  customer = Braintree::Customer.find(customer_id)
  payment_method_token = customer.credit_cards[0].token

  result = Braintree::Subscription.create(
    :payment_method_token => payment_method_token,
    :plan_id => "test_plan_1"
  )

  message = "Subscription status: #{result.subscription.status}"

  erb :subscriptions, :locals => { :message => message }
end
