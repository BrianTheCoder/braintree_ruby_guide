require "rubygems"
require "sinatra"
require "braintree"

Braintree::Configuration.environment = :sandbox
Braintree::Configuration.merchant_id = "use_your_merchant_id"
Braintree::Configuration.public_key = "use_your_public_key"
Braintree::Configuration.private_key = "use_your_private_key"

get "/" do
  erb :braintree
end

post "/create_transaction" do
  result = Braintree::Transaction.sale(
    :amount => "1000.00",
    :credit_card => {
      :number => params[:number],
      :cvv => params[:cvv],
      :expiration_month => params[:month],
      :expiration_year => params[:year]
    },
    :options => {
      :submit_for_settlement => true
    }
  )

  if result.success?
    "<h1>Success! Transaction ID: #{result.transaction.id}</h1>"
  else
    "<h1>Error: #{result.message}</h1>"
  end
end
