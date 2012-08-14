require 'sinatra'
require 'braintree'
require 'shotgun'

Braintree::Configuration.environment = :sandbox
Braintree::Configuration.merchant_id = "5yhyd43d5sws9378"
Braintree::Configuration.public_key = "tcrgrwbgvz974cjx"
Braintree::Configuration.private_key = "mrx3rh84sfktfjhb"

get "/" do
  tr_data = Braintree::TransparentRedirect.transaction_data(
    :redirect_url => "http://localhost:9393/braintree",
    :transaction => {
      :type => "sale",
      :amount => "1000.00",
      :options => {
        :submit_for_settlement => true
        }
      }
)

  erb :form, :locals => {:tr_data => tr_data}
end

get "/braintree" do
  result = Braintree::TransparentRedirect.confirm(request.query_string)

  if result.success?
    message = "Transaction Status: #{result.transaction.status}"
    # status will be authorized or submitted_for_settlement
  else
    message = "Message: #{result.message}"
  end

  erb :response, :locals => {:message => message}
end
