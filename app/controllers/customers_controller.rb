class CustomersController < ApplicationController
	before_action :authenticate_user!
	before_action :check_user
	# before_action :set_project, only: [:edit, :update, :destroy, :detail_report]
	respond_to :html, :json, only: [:index, :new, :create, :edit, :update, :show, :destroy,:assign_project,:add_users,:reports,:users]

	def index
		@customers = current_user.whole_customers
		respond_with @customers
	end

	def new
		@customer = Customer.new
		# respond_with @customer
	end

	def create
		user_client = current_user.client
		params[:customer][:creator_id] = current_user.id 
		customer = user_client.customers.build(params_customer)
		# if customer.save
		cus_user = CustomersUser.new
		cus_user.user_id = current_user.id
		cus_user.customer_id = customer.id
		cus_user.save!
		# flash[:success] = "Customer successfully created."
		# redirect_to user_customers_path(current_user)
		respond_to do |format|
			if customer.save
				if current_user.role == "client"
					users = params[:customer][:userid] if params[:customer][:userid].present?
					users && users.each do |user|
						if user != ""
							cus_user = CustomersUser.new
							cus_user.user_id = user.to_i
							cus_user.customer_id = customer.id
							cus_user.save!
						end	
					end
				end
				cus_user = CustomersUser.where(user_id:current_user.id, customer_id: customer.id).first || CustomersUser.new
				cus_user.user_id = current_user.id
				cus_user.customer_id = customer.id
				cus_user.save!
				# flash[:notice] = "Project was successfully created." 
				format.html { redirect_to customers_path, success: "Customer successfully created." }
		        format.json {  render json: :true} 
			else
		        format.html { render action: 'new' }
		        format.json { render json: :false}
		        # format.json { render json: @incident.errors, status: :unprocessable_entity }
		    end
	    end
	end

	def users
		@customer = Customer.find(params[:id])
		@users = @customer.users
		respond_with @users
	end

	def assign_customer
		@customer = Customer.find(params[:id])
		@users = current_user.subordinates
		# respond_with @project
	end

	def unassign
		@customer = Customer.find(params[:id])
		cust_user = CustomersUser.where(customer_id: @customer.id, user_id: params[:uid]).first
		cust_user.destroy if cust_user.present?
		flash[:success] = "Unassigned successfully."
		redirect_to customer_path
	end

	def add_users
		
		id = params[:customerid]
		users = params[:customer][:userid] if params[:customer][:userid].present?
		customer = Customer.find(id)
		users && users.each do |user|
			if user != ""
				customer_user =  CustomersUser.where(user_id: user , customer_id: id).first || CustomersUser.new
				customer_user.user_id = user.to_i
				customer_user.customer_id = id.to_i
				customer_user.save!	
			end	
		end
		# respond_with project_user
		respond_to do |format|
	        format.html { redirect_to customers_path, notice: 'Users add successfully.' }
	        format.json { render :json=> true }
	    end
		# flash[:success] = "Users add successfully"
		# redirect_to projects_path		
	end



	private

	def params_customer
		params.require(:customer).permit(:creator_id,:name, :phone, :bill_of_laden, :loading_address, :destination_address, :tag_lot_number,:tag_lot_color,:agent_name,:date_of_pickup,:charges,:userid)
	end

	def check_user
		# puts "11111"*90
		if current_user.role == 'admin'
			# puts "0000"*90
			flash[:notice] = 'You are not Authorise'
			return redirect_to root_url
		end	
	end	
end
