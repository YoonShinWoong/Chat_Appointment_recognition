class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  # GET /posts
  # GET /posts.json
  def index
    @posts = Post.all
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
    @chats = Chat.where("post_id = ?", params[:id])
    @chat = Chat.new
    @chat.post_id = params[:id]
  end

  # GET /posts/new
  def new
    @post = Post.new
    @check = 'new'
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts
  # POST /posts.json
  def create
    @post = Post.new(post_params)

    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: 'Post was successfully created.' }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to @post, notice: '알람이 정상적으로 수정되었습니다!' }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    
    # Chat 삭제
    for chat in @post.chats
      chat.destroy
    end

    # Alarm 삭제
    for alarm in @post.alarms
      alram.destroy
    end
    
    # Post 삭제
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # 알람 끄기
  def alarmoff
    @post = Post.find(params[:post_id])
    @post.alarmstat = '거부'

    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: '알람이 정상적으로 거부되었습니다! 다시 설정하고 싶으시면 언제든 알람 설정을 클릭해주세요!' }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.require(:post).permit(:partner, :address, :phone, :date, :time, :time_ago, :alarmstat)
    end
end
