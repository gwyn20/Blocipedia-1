class ChargesController < ApplicationController
  def create
   
   @user = current_user
   # Creates a Stripe Customer object, for associating
   # with the charge
   customer = Stripe::Customer.create(
     email: current_user.email,
     card: params[:stripeToken]
   )
 
   # Where the real magic happens
   charge = Stripe::Charge.create(
     customer: customer.id, # Note -- this is NOT the user_id in your app
     amount: 15_00,
     description: "Upgrade to premium membership - #{current_user.email}",
     currency: 'usd'
   )
   current_user.premium!
   flash[:notice] = "Thanks for becoming a premium member #{current_user.email}!"
   redirect_to wikis_path # or wherever
 
   # Stripe will send back CardErrors, with friendly messages
   # when something goes wrong.
   # This `rescue block` catches and displays those errors.
   rescue Stripe::CardError => e
     flash[:alert] = e.message
     redirect_to new_charge_path
  end
  
  def new
   @stripe_btn_data = {
     key: "#{ Rails.configuration.stripe[:publishable_key] }",
     description: "Blocipedia membership - #{current_user.email}",
     amount: 15_00
   }
   end
   
  def downgrade
   @user = current_user
   current_user.standard!
   flash[:alert] = "You just downgraded your membership.  SAD!"
   @user.wikis.each do |pub|
   pub.update_attributes(private: false)
  end
   redirect_to root_path
  end
  
  def validate
   render "charges/validate.html.erb"
  end
end
