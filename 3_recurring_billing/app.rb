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
    "<h1>Customer created with name: #{result.customer.first_name} #{result.customer.last_name}</h1>" +
    "<br /><a href=\"/subscriptions?id=#{result.customer.id}\">Click here to sign this Customer up for a recurring payment</a>"
  else
    "<h1>Error: #{result.message}</h1>"
  end
end

get "/subscriptions" do
  begin
    customer_id = request.params["id"]
    customer = Braintree::Customer.find(customer_id)
    payment_method_token = customer.credit_cards[0].token

    result = Braintree::Subscription.create(
      :payment_method_token => payment_method_token,
      :plan_id => "test_plan_1"
    )

    if result.success?
      "<h1>Subscription Status #{result.subscription.status}"
    else
      "<h1>Error: #{result.message}</h1>"
    end
  rescue Braintree::NotFoundError
    "<h1>No customer found for id: #{request.params["id"]}"
  end
end
