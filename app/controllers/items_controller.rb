class ItemsController < ApplicationController
	before_action :authenticate_user!
	# before_action :check_user
	# before_action :set_project, only: [:edit, :update, :destroy, :detail_report]
	respond_to :html, :json, only: [:index, :new, :create, :edit, :update, :show, :destroy,:assign_project,:add_users,:reports,:users]

	def index
		# 
		@customer = Customer.find(params[:customer_id])
		@items = @customer.items
		respond_with @items
	end

	def new
		@customer = Customer.find(params[:customer_id])
		@item = @customer.items.build
		respond_with @item
	end

	def create
		customer = Customer.find(params[:customer_id])
		@item = customer.items.build(params_item)
		respond_to do |format|
			if @item.save
				format.html { redirect_to customer_items_path(customer), success: "Item successfully created." }
		        format.json {  render json: :true}
			else
				format.html { render action: 'new' }
		        format.json { render json: :false}
			end
		end
	end

	def edit
		@item = Item.find(params[:id])
		@customer = Customer.find(params[:customer_id])
		respond_with @item
	end

	def update
		@customer = Customer.find(params[:customer_id])
		@item = Item.find(params[:id])
		@item.update_attributes(params_item)
		respond_to do |format|
			format.html { redirect_to customer_items_path(@customer), success: "Item successfully updated." }
	        format.json {  render json: :true}
		end
	end 

	def destroy
		@item = Item.find(params[:id])
		@customer = Customer.find(params[:customer_id])
		@item.destroy if @item.present?
		flash[:success] = "Successfully deleted."
		respond_to do |format|
			format.html { redirect_to customer_items_path(@customer), success: "Item successfully updated." }
	        format.json {  render json: :true}
		end
	end

	def show
		@customer = Customer.find(params[:customer_id])
		@item = Item.find(params[:id])
		respond_with @item 
	end

	def upload_image   #upload image through app
		@customer = Customer.find(params[:customer_id])
		@item = Item.find(params[:id])
		# if params[:item][:itemId].present?
		# 	@item = Item.find(params[:itemId])
		# else
		# 	@item = @customer.items.build
		# end
		if params[:item][:file1].present?
			@item.file1 = uploaded_picture(params[:item][:file1]) if params[:item][:file1].present?
			@item.save!
			@url = @item.file1_url
		elsif params[:item][:file2].present?
			@item.file2 = uploaded_picture(params[:item][:file2]) if params[:item][:file2].present?
			@url = @item.file2_url
		end
		
		return render :json=>{url: @url}
	end




	private

	def params_item
		params.require(:item).permit(:item_number,:description_at_origin,:driver,:warehouse,:warehouse_cross,:shipper,:desr_symbole,:exception_symbol,:location_symbol,:file1,:file2,:exception)
	end

  	def uploaded_picture(base64)

	    tempfile = Tempfile.new ['upload', '.jpg']
	    tempfile.binmode
	    tempfile.write(Base64.decode64(base64))

	    # ActionDispatch::Http::UploadedFile.new(tempfile: tempfile,
	    #   filename: 'upload.jpg')
		tempfile
	end

end
