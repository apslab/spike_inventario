class ProductsController < ApplicationController
  
  before_filter :login_required, :except => :index
  
  # GET /products
  # GET /products.json
  def index
    logger.debug("request.method: #{request.method}")
    logger.debug("request.headers['Host']: #{request.headers['Host']}")
    logger.debug("request.env['SERVER_PROTOCOL']: #{request.env['SERVER_PROTOCOL']}")
    ActionDispatch::Request::ENV_METHODS.each do |key|
      logger.debug("request.env['#{key}']: #{request.env[key]}")
    end
    logger.debug("request.env['HTTPS']: #{request.env['HTTPS']}")
    logger.debug("request.env['rack.url_scheme']: #{request.env['rack.url_scheme']}")
    logger.debug("------------------------------------------------------------------------------------")
    request.env.keys.each do |key|
      logger.debug("request.env['#{key}']: #{request.env[key]}")
    end
    logger.debug("------------------------------------------------------------------------------------")


    @products = Product.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @products }
    end
  end

  # GET /products/1
  # GET /products/1.json
  def show
    @product = Product.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @product }
    end
  end

  # GET /products/new
  # GET /products/new.json
  def new
    @product = Product.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @product }
    end
  end

  # GET /products/1/edit
  def edit
    @product = Product.find(params[:id])
  end

  # POST /products
  # POST /products.json
  def create
    @product = Product.new(params[:product])

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: 'Product was successfully created.' }
        format.json { render json: @product, status: :created, location: @product }
      else
        format.html { render action: "new" }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /products/1
  # PUT /products/1.json
  def update
    @product = Product.find(params[:id])

    respond_to do |format|
      if @product.update_attributes(params[:product])
        format.html { redirect_to @product, notice: 'Product was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    @product = Product.find(params[:id])
    @product.destroy

    respond_to do |format|
      format.html { redirect_to products_url }
      format.json { head :ok }
    end
  end
end
