class RoomsController < ApplicationController
  # Loads:
  # @rooms = all rooms
  # @room = current room when applicable
  before_action :load_entities
  $usersReady = []

  def index
    @rooms = Room.all
  end

  def new
    @room = Room.new
  end

  def create
    @room = Room.new permitted_parameters

    if @room.save
      flash[:success] = "Room #{@room.name} was created successfully"
      redirect_to rooms_path
    else
      render :new
    end
  end

  def show
    @room_message = RoomMessage.new room: @room
    @room_messages = @room.room_messages.includes(:user)
  end

  def destroy
    Room.destroy(@room.id)
    redirect_to rooms_path
  end
  
  def buzzer
    @room = Room.find(params[:room])
    RoomChannel.broadcast_to @room,  command: "BUZZER", user: current_user
    countdown()
  end
  
  def countdown
    Thread.new do
      Rails.application.executor.wrap do
        i=10
        while i > -1  do
          RoomChannel.broadcast_to @room,  timer: i, user: current_user
          sleep 1
          i -=1
        end
      end
    end
  end
  
  def playerReady
    @room = Room.find(params[:room])
    if $usersReady[@room.id] == nil
      $usersReady[@room.id] = []
    end
    if !$usersReady[@room.id].include?(current_user.username)
      $usersReady[@room.id].push(current_user.username)
    end
    RoomChannel.broadcast_to @room,  command: "READY", usersReady: $usersReady[@room.id]
  end

  def update
    if @room.update_attributes(permitted_parameters)
      flash[:success] = "Room #{@room.name} was updated successfully"
      redirect_to rooms_path
    else
      render :new
    end
  end

  protected

  def load_entities
     @room = Room.find(params[:id]) if params[:id]
  end

  def permitted_parameters
    params.require(:room).permit(:name)
  end
end
