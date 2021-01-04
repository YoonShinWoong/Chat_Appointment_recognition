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

        # 약속 날짜 체크

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

    # 주소검색 <1>
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

    # 주소검색 <2>
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

    # 날짜검색 <1>
    # 약속 날짜 체크
    def korean_date_check(str)

      # 며칠 뒤의 날짜인지 체크
      plus_date = nil
      if str.match(/(오늘)|(금일)/)
        plus_date = 0
      elsif str.match(/(내일)|(차일)/)
        plus_date = 1
      elsif str.match(/(모레)|(이틀)/) 
        plus_date = 2
      elsif str.match(/(사흘)/)
        plus_date = 3
      elsif str.match(/(나흘)/)
        plus_date = 4 
      elsif str.match(/(닷새)/)
        plus_date = 5
      end
      
      if plus_date
        return Date.today_to_datetime + plus_date.days
      else
        return nil
      end
    end

    # 날짜검색 <2>
    # 약속 날짜 요일만 체크
    def only_wday_check(str)
      when_wday = nil

      # 이번주 요일 검색
      if str.match(/[월](요일|욜|)/) 
        when_wday = 0
        plus_week = 0
      elsif str.match(/(이번|이번 |금)[주]\s[화](요일|욜|)/) 
        when_wday = 1
        plus_week = 0 
      elsif str.match(/(이번|이번 |금)[주]\s[수](요일|욜|)/) 
        when_wday = 2
        plus_week = 0
      elsif str.match(/(이번|이번 |금)[주]\s[목](요일|욜|)/) 
        when_wday = 3
        plus_week = 0
      elsif str.match(/(이번|이번 |금)[주]\s[금](요일|욜|)/) 
        when_wday = 4
        plus_week = 0 
      elsif str.match(/(이번|이번 |금)[주]\s[토](요일|욜|)/)
        when_wday = 5
        plus_week = 0
      elsif str.match(/(이번|이번 |금)[주]\s[일](요일|욜|)/) 
        when_wday = 6
        plus_week = 0
      end

      # 파싱 안되면 nil 반환
      if plus_week || when_wday
        return nil
      
      # 파싱되면 날짜 차이 계산
      else
        # 일 0 ~ 토 6 (변환)=> 월 0 ~ 일 6
        now_wday = (Date.today_to_datetime.wday-1) % 7
        plus_wday = when_wday - now_wday

        # 변환 날짜 계산 후 반환
        return Date.today_to_datetime + (plus_wday + (plus_week)*7).days
      end
    end


    # 날짜검색 <3>
    # 약속 날짜 요일 체크
    def wday_check(str)
      
      plus_week = nil
      when_wday = nil

      # 이번주 요일 검색
      if str.match(/(이번|이번 |금)[주]\s[월](요일|욜|)/) 
        when_wday = 0
        plus_week = 0
      elsif str.match(/(이번|이번 |금)[주]\s[화](요일|욜|)/) 
        when_wday = 1
        plus_week = 0 
      elsif str.match(/(이번|이번 |금)[주]\s[수](요일|욜|)/) 
        when_wday = 2
        plus_week = 0
      elsif str.match(/(이번|이번 |금)[주]\s[목](요일|욜|)/) 
        when_wday = 3
        plus_week = 0
      elsif str.match(/(이번|이번 |금)[주]\s[금](요일|욜|)/) 
        when_wday = 4
        plus_week = 0 
      elsif str.match(/(이번|이번 |금)[주]\s[토](요일|욜|)/)
        when_wday = 5
        plus_week = 0
      elsif str.match(/(이번|이번 |금)[주]\s[일](요일|욜|)/) 
        when_wday = 6
        plus_week = 0
      end

      # 다음주 요일 검색
      if str.match(/(다음|다음 |차)[주]\s[월](요일|욜|)/) 
        when_wday = 0
        plus_week = 1
      elsif str.match(/(다음|다음 |차)[주]\s[화](요일|욜|)/) 
        when_wday = 1
        plus_week = 1
      elsif str.match(/(다음|다음 |차)[주]\s[수](요일|욜|)/) 
        when_wday = 2
        plus_week = 1
      elsif str.match(/(다음|다음 |차)[주]\s[목](요일|욜|)/) 
        when_wday = 3
        plus_week = 1
      elsif str.match(/(다음|다음 |차)[주]\s[금](요일|욜|)/) 
        when_wday = 4
        plus_week = 1 
      elsif str.match(/(다음|다음 |차)[주]\s[토](요일|욜|)/)
        when_wday = 5
        plus_week = 1
      elsif str.match(/(다음|다음 |차)[주]\s[일](요일|욜|)/) 
        when_wday = 6
        plus_week = 1
      end

      # <주 + 요일> 파싱 안되면 단순 <요일> 파싱 
      if plus_week.nil? && when_wday.nil?
        
        if str.match(/[월](요일|욜)/) 
          when_wday = 0
        elsif str.match(/[화](요일|욜)/) 
          when_wday = 1
        elsif str.match(/[수](요일|욜)/) 
          when_wday = 2
        elsif str.match(/[목](요일|욜)/) 
          when_wday = 3
        elsif str.match(/[금](요일|욜)/) 
          when_wday = 4
        elsif str.match(/[토](요일|욜)/) 
          when_wday = 5
        elsif str.match(/[일](요일|욜)/) 
          when_wday = 6
        end

        # 단순 요일 파싱도 안되면 처리
        if when_wday.nil? 
          return nil

        # 단순 요일 파싱되면 처리
        else
          # 일 0 ~ 토 6 (변환)=> 월 0 ~ 일 6
          now_wday = (Date.today_to_datetime.wday-1) % 7
          
          if when_wday > now_wday
            plus_wday = (when_wday - now_wday) 
          
          else
            plus_wday = (when_wday + 7) - now_wday
          
          end
          # 변환 날짜 계산 후 반환
          return Date.today_to_datetime + plus_wday.days
        
        end

      # 파싱되면 날짜 차이 계산
      else
        # 일 0 ~ 토 6 (변환)=> 월 0 ~ 일 6
        now_wday = (Date.today_to_datetime.wday-1) % 7
        plus_wday = when_wday - now_wday

        # 변환 날짜 계산 후 반환
        return Date.today_to_datetime + (plus_wday + (plus_week)*7).days
      end
    end

    # 날짜검색 <4>
    # 약속 날짜 체크 
    def date_check(str)
      slash_date_str = str.match(/[0-1]?[0-9]\/[0-3]?[0-9]/)
      korean_date_str = str.match(/([0-1]?[0-9]월\s[0-3]?[0-9]일)|([0-1]?[0-9]월[0-3]?[0-9]일)/)

      # 00/00
      if slash_date_str
        # 내년을 말한 것인지 체크 
        slash_date = slash_date_str.to_s.to_date.
        if slash_date.change(year:0) < Date.today.change(year:0)
          return slash_date + 1.year
        else
          return slash_date
        end
      
      # 00월 00일
      elsif korean_date_str
        str_list = korean_date_str.to_s.split('월')
        # 내년을 말한 것인지 체크 
        korean_date = (str_list[0]+"/"+str_list[1]).to_date
        if korean_date.change(year:0) < Date.today.change(year:0)
          return korean_date + 1.year
        else
          return korean_date
        end
      end  
    end

    # 날짜검색 <5>
    # 약속 시간 체크
    def time_check(str)
      hour_minute_str = str.match(/([0-2]?[0-9]시[0-5][0-9]분)|([0-2]?[0-9]시\s[0-5][0-9]분)|([0-2]?[0-9]시)/)
      colon_time_str = str.match(/([0-2]?[0-9]:[0-5]?[0-9])/)
      
      # 00시 00분 , 00시00분, 00시
      if hour_minute_str
        str_list = hour_minute_str.to_s.split('시')
        if str_list.size == 1 
          return (str_list[0].to_i + 12).hours
        else 
          return (str_list[0].to_i + 12).hours + str_list[1].to_i.minutes
        end
      end

      # 00:00
      elsif colon_time_str 
        str_list = colon_time_str.to_s.split(':')
        return (str_list[0].to_i + 12).hours + str_list[1].to_i.minutes
      end

      # 파싱 안됨
      return nil
    end
end
