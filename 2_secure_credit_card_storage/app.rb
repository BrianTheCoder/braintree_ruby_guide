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
  if result.success?
    "<h1>Customer created with name: #{result.customer.first_name} #{result.customer.last_name}</h1>"
  else
    "<h1>Error: #{result.message}</h1>"
  end
end
