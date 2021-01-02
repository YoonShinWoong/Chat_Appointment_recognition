class ChatsController < ApplicationController
  before_action :set_chat, only: [:show, :edit, :update, :destroy]

  # GET /chats
  # GET /chats.json
  def index
    @chats = Chat.all
  end

  # GET /chats/1
  # GET /chats/1.json
  def show
  end

  # GET /chats/new
  def new
    @chat = Chat.new
    @chat.post_id = params[:post_id]
  end

  # GET /chats/1/edit
  def edit
  end

  # POST /chats
  # POST /chats.json
  def create
    @chat = Chat.new(chat_params)
    @post = Post.find(@chat.post_id)
    respond_to do |format|
      if @chat.save
        notice_msg =  'Chat was successfully created.'

        # 도로명 주소 체크
        street_addr = street_address_check(@chat.body)
        puts(street_addr)
        if street_addr 
          @post.address = street_addr
          @post.save
          notice_msg = '구체적인 약속 장소가 이야기되고 있네요!' 
        end
        
        # 지번 주소 체크
        lot_addr = lot_address_check(@chat.body)
        puts(lot_addr)
        if lot_addr
          @post.address = lot_addr
          @post.save
          notice_msg = '구체적인 약속 장소가 이야기되고 있네요!'
        end

        format.html { redirect_to @post, notice: notice_msg }
        format.json { render :show, status: :created, location: @chat }
      else
        format.html { render :new }
        format.json { render json: @chat.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /chats/1
  # PATCH/PUT /chats/1.json
  def update
    @post = Post.find(@chat.post_id)
    respond_to do |format|
      if @chat.update(chat_params)
        format.html { redirect_to @post, notice: 'Chat was successfully updated.' }
        format.json { render :show, status: :ok, location: @chat }
      else
        format.html { render :edit }
        format.json { render json: @chat.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /chats/1
  # DELETE /chats/1.json
  def destroy
    @post = Post.find(@chat.post_id)
    @chat.destroy
    respond_to do |format|
      format.html { redirect_to @post, notice: 'Chat was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_chat
      @chat = Chat.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def chat_params
      params.require(:chat).permit(:post_id, :body)
    end

    # 도로명 주소 검색 
    def street_address_check(str)
      addr_str = str.match(/(([가-힣A-Za-z·\d~\-\.]{2,}(로|길).[\d]+))/)
      street_str = addr_str.to_s().split(' ')[0]
      # 도로명 검색
      if !street_str.nil?
        # 테이블 내 검색 있으면 true
        if Address.where("street = ?", street_str).count != 0
          return addr_str
        end
      end

      # 도로명 주소 아님 false
      return false
    end

    # 지번 주소 검색 
    def lot_address_check(str)
      addr_str = str.match(/(([가-힣A-Za-z·\d~\-\.]+(읍|동)\s)[\d-]+)|(([가-힣A-Za-z·\d~\-\.]+(읍|동)\s)[\d]+)/)
      dong_str = addr_str.to_s().split(' ')[0]
      # 지번주소 검색
      if !dong_str.nil?
        # 테이블 내 검색 있으면 true
        if Address.where("dong = ?", dong_str).count != 0
          return addr_str
        end
      end

      # 지번 주소 아님 false
      return false
    end
end
