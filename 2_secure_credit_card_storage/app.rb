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

  if result.success?
    message = "Customer Created with the email: #{result.customer.email}"
  else
    message = "Message: #{result.message}"
  end

  erb :response, :locals => {:message => message}
end
